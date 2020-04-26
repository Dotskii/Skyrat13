/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/dead_icon
	var/mob/living/carbon/owner = null
	var/state = ORGAN_ORGANIC //Organic or robotic?
	var/vital = FALSE
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	// DO NOT add slots with matching names to different zones - it will break internal_organs_slot list!
	var/organ_flags = 0
	var/maxHealth = STANDARD_ORGAN_THRESHOLD
	var/damage = 0		//total damage this organ has sustained
	var/min_bruised_damage = 10
	var/min_broken_damage = 30
	var/max_damage
	var/organ_tag = "organ"
	var/zone = BODY_ZONE_CHEST
	var/slot
	var/status = 0 //Broken, dead, splinted, etc
	//Autopsy stuff
	var/list/datum/autopsy_data/autopsy_data = list()
	var/list/trace_chemicals = list() // traces of chemicals in the organ,
									// links chemical IDs to number of ticks for which they'll stay in the blood
	germ_level = 0
	var/datum/dna/dna

	// Stuff for tracking if this is on a tile with an open freezer or not
	var/last_freezer_update_time = 0
	var/freezer_update_period = 100
	var/is_in_freezer = 0

	var/sterile = FALSE //can the organ be infected by germs?
	var/tough = FALSE //can organ be easily damaged?
	var/emp_proof = FALSE //is the organ immune to EMPs?
	var/hidden_pain = FALSE //will it skip pain messages?
	var/requires_robotic_bodypart = FALSE

	///Healing factor and decay factor function on % of maxhealth, and do not work by applying a static number per tick
	var/healing_factor 	= 0										//fraction of maxhealth healed per on_life(), set to 0 for generic organs
	var/decay_factor 	= 0										//same as above but when without a living owner, set to 0 for generic organs
	var/high_threshold	= STANDARD_ORGAN_THRESHOLD * 0.45		//when severe organ damage occurs
	var/low_threshold	= STANDARD_ORGAN_THRESHOLD * 0.1		//when minor organ damage occurs

	///Organ variables for determining what we alert the owner with when they pass/clear the damage thresholds
	var/prev_damage = 0
	var/low_threshold_passed
	var/high_threshold_passed
	var/now_failing
	var/now_fixed
	var/high_threshold_cleared
	var/low_threshold_cleared
	rad_flags = RAD_NO_CONTAMINATE

/obj/item/organ/proc/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	if(!iscarbon(M) || owner == M)
		return FALSE

	var/obj/item/organ/replaced = M.getorganslot(slot)
	if(replaced)
		replaced.Remove(TRUE)
		if(drop_if_replaced)
			replaced.forceMove(get_turf(M))
		else
			qdel(replaced)

	//Hopefully this doesn't cause problems
	organ_flags &= ~ORGAN_FROZEN

	owner = M
	M.internal_organs |= src
	M.internal_organs_slot[slot] = src
	moveToNullspace()
	for(var/X in actions)
		var/datum/action/A = X
		A.Grant(M)
	STOP_PROCESSING(SSobj, src)

	return TRUE

//Special is for instant replacement like autosurgeons
/obj/item/organ/proc/Remove(special = FALSE)
	if(owner)
		owner.internal_organs -= src
		if(owner.internal_organs_slot[slot] == src)
			owner.internal_organs_slot.Remove(slot)
		if((organ_flags & ORGAN_VITAL) && !special && !(owner.status_flags & GODMODE))
			owner.death()
		for(var/X in actions)
			var/datum/action/A = X
			A.Remove(owner)
		. = owner //for possible subtypes specific post-removal code.
	owner = null
	START_PROCESSING(SSobj, src)

/obj/item/organ/proc/on_find(mob/living/finder)
	return

/obj/item/organ/process()
	if(status & ORGAN_DEAD && damage >= maxHealth)
		return
	if(is_cold())
		return
	if(organ_flags & ORGAN_SYNTHETIC || sterile || (owner && (NO_GERMS in owner.dna.species.species_traits)))
		return
	applyOrganDamage(maxHealth * decay_factor)
	if(!owner)
		// Maybe scale it down a bit, have it REALLY kick in once past the basic infection threshold
		// Another mercy for surgeons preparing transplant organs
		germ_level++
		if(germ_level >= INFECTION_LEVEL_ONE)
			germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_TWO)
			germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_THREE)
			necrotize()
	else if(owner.bodytemperature >= 170) //cryo stops germs from moving and doing their bad stuffs
		//** Handle antibiotics and curing infections
		handle_antibiotics()
		handle_germ_effects()
	on_death() //runs decay when outside of a person AND ONLY WHEN OUTSIDE (i.e. long obj). //Kinda hate doing it like this, but I really don't want to call process directly.

/obj/item/organ/proc/handle_germ_effects()
	//** Handle the effects of infections
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if(germ_level > 0 && germ_level < INFECTION_LEVEL_ONE/2 && prob(30))
		germ_level--

	if(germ_level >= INFECTION_LEVEL_ONE/2)
		//aiming for germ level to go from ambient to INFECTION_LEVEL_TWO in an average of 15 minutes
		if(antibiotics < 5 && prob(round(germ_level/6)))
			germ_level++

	if(germ_level >= INFECTION_LEVEL_ONE)
		var/fever_temperature = (owner.dna.species.heat_level_1 - owner.dna.species.body_temperature - 5)* min(germ_level/INFECTION_LEVEL_TWO, 1) + owner.dna.species.body_temperature
		owner.bodytemperature += between(0, (fever_temperature - T20C)/BODYTEMP_COLD_DIVISOR + 1, fever_temperature - owner.bodytemperature)

	if(germ_level >= INFECTION_LEVEL_TWO)
		var/obj/item/organ/external/parent = owner.get_organ(parent_organ)
		//spread germs
		if(antibiotics < 5 && parent.germ_level < germ_level && ( parent.germ_level < INFECTION_LEVEL_ONE*2 || prob(30) ))
			parent.germ_level++
	if(germ_level >= INFECTION_LEVEL_TWO)
		if(prob(3))	//about once every 30 seconds
			receive_damage(1,silent=prob(30))

/obj/item/organ/proc/receive_damage(amount, silent = 0)
	if(tough)
		return
	damage = between(0, damage + amount, max_damage)

	//only show this if the organ is not robotic
	if(owner && parent_organ && amount > 0)
		var/obj/item/organ/external/parent = owner.get_organ(parent_organ)
		if(parent && !silent)
			owner.custom_pain("Something inside your [parent.name] hurts a lot.")

		//check if we've hit max_damage
	if(damage >= max_damage)
		necrotize()

/obj/item/organ/proc/rejuvenate()
	damage = 0
	germ_level = 0
	surgeryize()
	if(is_robotic())	//Robotic organs stay robotic.
		status = ORGAN_ROBOT
	else
		status = 0
	if(!owner)
		START_PROCESSING(SSobj, src)

/obj/item/organ/proc/is_damaged()
	return damage > 0

/obj/item/organ/proc/is_bruised()
	return damage >= min_bruised_damage

/obj/item/organ/proc/is_broken()
	return (damage >= min_broken_damage || ((status & ORGAN_BROKEN) && !(status & ORGAN_SPLINTED)))

//Germs
/obj/item/organ/proc/handle_antibiotics()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if(!germ_level || antibiotics <= 0.4)
		return

	if(germ_level < INFECTION_LEVEL_ONE)
		germ_level = 0	//cure instantly
	else if(germ_level < INFECTION_LEVEL_TWO)
		germ_level -= 24	//at germ_level == 500, this should cure the infection in 15 seconds
	else
		germ_level -= 8	// at germ_level == 1000, this will cure the infection in 1 minute, 15 seconds
						// Let's not drag this on, medbay has only so much antibiotics

//Adds autopsy data for used_weapon.
/obj/item/organ/proc/add_autopsy_data(var/used_weapon = "Unknown", var/damage)
	var/datum/autopsy_data/W = autopsy_data[used_weapon]
	if(!W)
		W = new()
		W.weapon = used_weapon
		autopsy_data[used_weapon] = W

	W.hits += 1
	W.damage += damage
	W.time_inflicted = world.time

//Sources; life.dm process_organs
/obj/item/organ/proc/on_death() //Runs when outside AND inside.
	decay()

//Applys the slow damage over time decay
/obj/item/organ/proc/decay()
	if(!can_decay())
		return
	is_cold()
	if(organ_flags & ORGAN_FROZEN)
		return
	if(organ_flags & ORGAN_SYNTHETIC || sterile || (owner && (NO_GERMS in owner.dna.species.species_traits)))
		return
	applyOrganDamage(maxHealth * decay_factor)
	if(!owner)
		// Maybe scale it down a bit, have it REALLY kick in once past the basic infection threshold
		// Another mercy for surgeons preparing transplant organs
		germ_level++
		if(germ_level >= INFECTION_LEVEL_ONE)
			germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_TWO)
			germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_THREE)
			necrotize()

/obj/item/organ/proc/can_decay()
	if(CHECK_BITFIELD(organ_flags, ORGAN_NO_SPOIL | ORGAN_SYNTHETIC | ORGAN_FAILING))
		return FALSE
	return TRUE

//Checks to see if the organ is frozen from temperature
/obj/item/organ/proc/is_cold()
	if(istype(loc, /obj/))//Freezer of some kind, I hope.
		if(is_type_in_typecache(loc, GLOB.freezing_objects))
			if(!(organ_flags & ORGAN_FROZEN))//Incase someone puts them in when cold, but they warm up inside of the thing. (i.e. they have the flag, the thing turns it off, this rights it.)
				organ_flags |= ORGAN_FROZEN
			return TRUE
		return (organ_flags & ORGAN_FROZEN) //Incase something else toggles it

	var/local_temp
	if(istype(loc, /turf/))//Only concern is adding an organ to a freezer when the area around it is cold.
		var/turf/T = loc
		var/datum/gas_mixture/enviro = T.return_air()
		local_temp = enviro.temperature

	else if(istype(loc, /mob/) && !owner)
		var/mob/M = loc
		if(is_type_in_typecache(M.loc, GLOB.freezing_objects))
			if(!(organ_flags & ORGAN_FROZEN))
				organ_flags |= ORGAN_FROZEN
			return TRUE
		var/turf/T = M.loc
		var/datum/gas_mixture/enviro = T.return_air()
		local_temp = enviro.temperature

	if(owner)
		//Don't interfere with bodies frozen by structures.
		if(is_type_in_typecache(owner.loc, GLOB.freezing_objects))
			if(!(organ_flags & ORGAN_FROZEN))
				organ_flags |= ORGAN_FROZEN
			return TRUE
		local_temp = owner.bodytemperature

	if(!local_temp)//Shouldn't happen but in case
		return
	if(local_temp < 154)//I have a pretty shaky citation that states -120 allows indefinite cyrostorage
		organ_flags |= ORGAN_FROZEN
		return TRUE
	organ_flags &= ~ORGAN_FROZEN
	return FALSE

/obj/item/organ/proc/on_life()	//repair organ damage if the organ is not failing
	if(organ_flags & ORGAN_FAILING)
		return
	if(is_cold())
		return
	///Damage decrements by a percent of its maxhealth
	var/healing_amount = -(maxHealth * healing_factor)
	///Damage decrements again by a percent of its maxhealth, up to a total of 4 extra times depending on the owner's health
	healing_amount -= owner.satiety > 0 ? 4 * healing_factor * owner.satiety / MAX_SATIETY : 0
	if(healing_amount)
		applyOrganDamage(healing_amount) //to FERMI_TWEAK
		//Make it so each threshold is stuck.

/obj/item/organ/examine(mob/user)
	. = ..()
	if(organ_flags & ORGAN_FAILING)
		if(state == ORGAN_ROBOTIC)
			. += "<span class='warning'>[src] seems to be broken!</span>"
			return
		. += "<span class='warning'>[src] has decayed for too long, and has turned a sickly color! It doesn't look like it will work anymore!</span>"
		return
	if(damage > high_threshold)
		. += "<span class='warning'>[src] is starting to look discolored.</span>"


/obj/item/organ/proc/prepare_eat()
	var/obj/item/reagent_containers/food/snacks/organ/S = new
	S.name = name
	S.desc = desc
	S.icon = icon
	S.icon_state = icon_state
	S.w_class = w_class

	return S

/obj/item/reagent_containers/food/snacks/organ
	name = "appendix"
	icon_state = "appendix"
	icon = 'icons/obj/surgery.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	foodtype = RAW | MEAT | GROSS


/obj/item/organ/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(owner)
		// The special flag is important, because otherwise mobs can die
		// while undergoing transformation into different mobs.
		Remove(TRUE)
	QDEL_LIST_ASSOC_VAL(autopsy_data)
	QDEL_NULL(dna)
	return ..()

/obj/item/organ/proc/update_health()
	return

/obj/item/organ/New(mob/living/carbon/holder, datum/species/species_override = null)
	..(holder)
	if(!max_damage)
		max_damage = min_broken_damage * 2
	if(istype(holder))
		if(holder.dna)
			dna = holder.dna.Clone()
		else
			log_runtime(EXCEPTION("[holder] spawned without a proper DNA."), holder)
		var/mob/living/carbon/human/H = holder
		if(istype(H))
			if(dna)
				if(!blood_DNA)
					blood_DNA = list()
				blood_DNA[dna.unique_enzymes] = dna.blood_type
	else
		dna = new /datum/dna(null)
		if(species_override)
			dna.species = new species_override

/obj/item/organ/attackby(obj/item/I, mob/user, params)
	if((organ_flags & ORGAN_SYNTHETIC || state == ORGAN_ROBOTIC) && istype(I, /obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/nano = I
		nano.use(1)
		rejuvenate()
		to_chat(user, "<span class='notice'>You repair the damage on [src].</span>")
		return
	return ..()

/obj/item/organ/proc/set_dna(var/datum/dna/new_dna)
	if(new_dna)
		dna = new_dna.Clone()
		if(blood_DNA)
			blood_DNA.Cut()
		else
			blood_DNA = list()
		blood_DNA[dna.unique_enzymes] = dna.blood_type

/obj/item/organ/proc/necrotize(update_sprite = TRUE)
	damage = max_damage
	status |= ORGAN_DEAD
	STOP_PROCESSING(SSobj, src)
	if(dead_icon && !(organ_flags & ORGAN_SYNTHETIC))
		icon_state = dead_icon
	if(owner && vital)
		owner.death()

/obj/item/organ/attack(mob/living/carbon/M, mob/user)
	if(M == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(state == ORGAN_ORGANIC)
			var/obj/item/reagent_containers/food/snacks/S = prepare_eat()
			if(S)
				qdel(src)
				if(H.put_in_active_hand(S))
					S.attack(H, H)
	else
		..()

/obj/item/organ/item_action_slot_check(slot,mob/user)
	return //so we don't grant the organ's action to mobs who pick up the organ.

///Adjusts an organ's damage by the amount "d", up to a maximum amount, which is by default max damage
/obj/item/organ/proc/applyOrganDamage(var/d, var/maximum = maxHealth)	//use for damaging effects
	if(!d) //Micro-optimization.
		return FALSE
	if(maximum < damage)
		return FALSE
	damage = clamp(damage + d, 0, maximum)
	var/mess = check_damage_thresholds()
	prev_damage = damage
	if(mess && owner)
		to_chat(owner, mess)
	return TRUE

///SETS an organ's damage to the amount "d", and in doing so clears or sets the failing flag, good for when you have an effect that should fix an organ if broken
/obj/item/organ/proc/setOrganDamage(var/d)	//use mostly for admin heals
	applyOrganDamage(d - damage)

/** check_damage_thresholds
  * input: M (a mob, the owner of the organ we call the proc on)
  * output: returns a message should get displayed.
  * description: By checking our current damage against our previous damage, we can decide whether we've passed an organ threshold.
  *				 If we have, send the corresponding threshold message to the owner, if such a message exists.
  */
/obj/item/organ/proc/check_damage_thresholds()
	if(damage == prev_damage)
		return
	var/delta = damage - prev_damage
	if(delta > 0)
		if(damage >= maxHealth)
			organ_flags |= ORGAN_FAILING
			if(owner)
				owner.med_hud_set_status()
			return now_failing
		if(damage > high_threshold && prev_damage <= high_threshold)
			return high_threshold_passed
		if(damage > low_threshold && prev_damage <= low_threshold)
			return low_threshold_passed
	else
		organ_flags &= ~ORGAN_FAILING
		if(owner)
			owner.med_hud_set_status()
		if(!owner)//Processing is stopped when the organ is dead and outside of someone. This hopefully should restart it if a removed organ is repaired outside of a body.
			START_PROCESSING(SSobj, src)
		if(prev_damage > low_threshold && damage <= low_threshold)
			return low_threshold_cleared
		if(prev_damage > high_threshold && damage <= high_threshold)
			return high_threshold_cleared
		if(prev_damage == maxHealth)
			return now_fixed

//Runs some code on the organ when damage is taken/healed
/obj/item/organ/proc/onDamage(var/d, var/maximum = maxHealth)
	return

//Runs some code on the organ when damage is taken/healed
/obj/item/organ/proc/onSetDamage(var/d, var/maximum = maxHealth)
	return

//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm

/mob/living/proc/regenerate_organs()
	return 0

/mob/living/carbon/regenerate_organs(only_one = FALSE)
	var/breathes = TRUE
	var/blooded = TRUE
	if(dna && dna.species)
		if(HAS_TRAIT_FROM(src, TRAIT_NOBREATH, SPECIES_TRAIT))
			breathes = FALSE
		if(NOBLOOD in dna.species.species_traits)
			blooded = FALSE
		var/has_liver = (!(NOLIVER in dna.species.species_traits))
		var/has_stomach = (!(NOSTOMACH in dna.species.species_traits))

		for(var/obj/item/organ/O in internal_organs)
			if(O.organ_flags & ORGAN_FAILING)
				O.setOrganDamage(0)
				if(only_one)
					return TRUE

		if(has_liver && !getorganslot(ORGAN_SLOT_LIVER))
			var/obj/item/organ/liver/LI

			if(dna.species.mutantliver)
				LI = new dna.species.mutantliver()
			else
				LI = new()
			LI.Insert(src)
			if(only_one)
				return TRUE

		if(has_stomach && !getorganslot(ORGAN_SLOT_STOMACH))
			var/obj/item/organ/stomach/S

			if(dna.species.mutantstomach)
				S = new dna.species.mutantstomach()
			else
				S = new()
			S.Insert(src)
			if(only_one)
				return TRUE

	if(breathes && !getorganslot(ORGAN_SLOT_LUNGS))
		var/obj/item/organ/lungs/L = new()
		L.Insert(src)
		if(only_one)
			return TRUE

	if(blooded && !getorganslot(ORGAN_SLOT_HEART))
		var/obj/item/organ/heart/H = new()
		H.Insert(src)
		if(only_one)
			return TRUE

	if(!getorganslot(ORGAN_SLOT_TONGUE))
		var/obj/item/organ/tongue/T

		if(dna && dna.species && dna.species.mutanttongue)
			T = new dna.species.mutanttongue()
		else
			T = new()

		// if they have no mutant tongues, give them a regular one
		T.Insert(src)
		if(only_one)
			return TRUE

	else if (!only_one)
		var/obj/item/organ/tongue/oT = getorganslot(ORGAN_SLOT_TONGUE)
		if(oT.name == "fluffy tongue")
			var/obj/item/organ/tongue/T
			if(dna && dna.species && dna.species.mutanttongue)
				T = new dna.species.mutanttongue()
			else
				T = new()
			oT.Remove()
			qdel(oT)
			T.Insert(src)

	if(!getorganslot(ORGAN_SLOT_EYES))
		var/obj/item/organ/eyes/E

		if(dna && dna.species && dna.species.mutanteyes)
			E = new dna.species.mutanteyes()

		else
			E = new()
		E.Insert(src)
		if(only_one)
			return TRUE

	if(!getorganslot(ORGAN_SLOT_EARS))
		var/obj/item/organ/ears/ears
		if(dna && dna.species && dna.species.mutantears)
			ears = new dna.species.mutantears
		else
			ears = new

		ears.Insert(src)
		if(only_one)
			return TRUE

	if(!getorganslot(ORGAN_SLOT_TAIL))
		var/obj/item/organ/tail/tail
		if(dna && dna.species && dna.species.mutanttail)
			tail = new dna.species.mutanttail
			tail.Insert(src)
			if(only_one)
				return TRUE


/obj/item/organ/random
	name = "Illegal organ"
	desc = "Something hecked up"

/obj/item/organ/random/Initialize()
	..()
	var/list = list(/obj/item/organ/tongue, /obj/item/organ/brain, /obj/item/organ/heart, /obj/item/organ/liver, /obj/item/organ/ears, /obj/item/organ/eyes, /obj/item/organ/tail, /obj/item/organ/stomach)
	var/newtype = pick(list)
	new newtype(loc)
	return INITIALIZE_HINT_QDEL
