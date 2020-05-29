/datum/quirk/family_heirloom/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/heirloom_type
	switch(quirk_holder.mind.assigned_role)
		if("Clown")
			heirloom_type = pick(/obj/item/paint/anycolor, /obj/item/bikehorn/golden)
		if("Mime")
			heirloom_type = pick(/obj/item/paint/anycolor, /obj/item/toy/dummy)
		if("Cook")
			heirloom_type = /obj/item/kitchen/knife/scimitar
		if("Botanist")
			heirloom_type = pick(/obj/item/cultivator, /obj/item/reagent_containers/glass/bucket, /obj/item/storage/bag/plants, /obj/item/toy/plush/beeplushie)
		if("Medical Doctor")
			heirloom_type = /obj/item/healthanalyzer/advanced
		if("Paramedic")
			heirloom_type = pick(/obj/item/clothing/neck/stethoscope, /obj/item/bodybag)
		if("Station Engineer")
			heirloom_type = /obj/item/wirecutters/brass
		if("Atmospheric Technician")
			heirloom_type = /obj/item/extinguisher/mini/family
		if("Lawyer")
			heirloom_type = /obj/item/storage/briefcase/lawyer/family
		if("Brig Physician")
			heirloom_type = pick(/obj/item/clothing/neck/stethoscope, /obj/item/roller, /obj/item/book/manual/wiki/security_space_law)
		if("Prisoner")
			heirloom_type = /obj/item/pen/blue
		if("Janitor")
			heirloom_type = /obj/item/mop
		if("Security Officer")
			heirloom_type = /obj/item/clothing/accessory/medal/silver/valor
		if("Scientist")
			heirloom_type = /obj/item/toy/plush/slimeplushie
		if("Assistant")
			heirloom_type = /obj/item/clothing/gloves/cut/family
		if("Chaplain")
			heirloom_type = /obj/item/camera/spooky/family
		if("Captain")
			heirloom_type = /obj/item/clothing/accessory/medal/gold/captain/family
	if(!heirloom_type)
		heirloom_type = pick(
		/obj/item/toy/cards/deck,
		/obj/item/lighter,
		/obj/item/dice/d20)
	heirloom = new heirloom_type(get_turf(quirk_holder))
	GLOB.family_heirlooms += heirloom
	var/list/slots = list(
		"in your left pocket" = SLOT_L_STORE,
		"in your right pocket" = SLOT_R_STORE,
		"in your backpack" = SLOT_IN_BACKPACK
	)
	where = H.equip_in_one_of_slots(heirloom, slots, FALSE) || "at your feet"

//airhead
/datum/quirk/airhead
	name = "Airhead"
	desc = "You are exceptionally airheaded... but who cares?"
	value = -1
	mob_trait = TRAIT_DUMB
	medical_record_text = "Patient exhibits rather low mental capabilities."

//specism
/datum/quirk/specism
	name = "Specist"
	desc = "Other species are a mistake on the gene pool and you know it. Seeing people of differing species negatively impacts your mood, \
			and seeing people of the same species as yours will positively impact your mood."
	value = -1
	medical_record_text = "Patient exhibits an unnatural distaste for people of differing species."
	var/pcooldown = 0
	var/pcooldown_time = 15 SECONDS
	var/master_race

/datum/quirk/specism/add()
	. = ..()
	if(!ishuman(quirk_holder))
		remove() //prejudice is a human problem.
	var/mob/living/carbon/human/trianglehatman = quirk_holder
	master_race = trianglehatman.dna.species.type

/datum/quirk/specism/on_process()
	. = ..()
	if(pcooldown > world.time)
		return
	pcooldown = world.time + pcooldown_time
	if(!ishuman(quirk_holder))
		remove() //prejudice is a human problem.
	var/mob/living/carbon/human/trianglehatman = quirk_holder
	if(!master_race)
		master_race = trianglehatman.dna.species.type
	var/pridecount = 0
	var/hatecount = 0
	for(var/mob/living/carbon/human/H in (view(5, trianglehatman) - trianglehatman))
		if(H.dna.species.type != master_race)
			hatecount++
		else
			pridecount++
	if(hatecount > pridecount)
		SEND_SIGNAL(trianglehatman, COMSIG_ADD_MOOD_EVENT, "specism_hate", /datum/mood_event/specism_hate)
	else if(pridecount > hatecount)
		SEND_SIGNAL(trianglehatman, COMSIG_ADD_MOOD_EVENT, "specism_pride", /datum/mood_event/specism_pride)

//clumsyness
/datum/quirk/disaster_artist
	name = "Disaster Artist"
	desc = "You always manage to wreak havoc on everything you touch."
	value = -2
	mob_trait = TRAIT_CLUMSY
	medical_record_text = "Patient lacks proper spatial awareness."

//aaa i dont know my mood aaa
/datum/quirk/screwy_mood
	name = "Alexithymia"
	desc = "You cannot accurately assess your feelings."
	value = -1
	mob_trait = TRAIT_SCREWY_MOOD
	medical_record_text = "Patient is incapable of communicating their emotions."

//aaaaaa im bleeding aaaaaaaaa
/datum/quirk/hemophiliac
	name = "Hemophiliac"
	desc = "Your body is bad at coagulating blood. Bleeding will always be two times worse when compared to the average person."
	value = -2
	mob_trait = TRAIT_HEMOPHILIA
	medical_record_text = "Patient exhibits abnormal blood coagulation behavior."

//remember collar bans? i do and i miss them
/datum/quirk/state_property
	name = "Collared"
	desc = "Due to your concerning behavior, NanoTrasen has installed a permanent shock collar on you, with a publically available code and channel."
	value = -2
	medical_record_text = "Patient has been deemed unstable by NanoTrasen and local authorities."
	var/pcooldown = 0
	var/pcooldown_time = 30 SECONDS
	var/storedcode = 2
	var/storedfreq = FREQ_ELECTROPACK

/datum/quirk/state_property/add()
	. = ..()
	storedcode = rand(1, 100)
	storedfreq = sanitize_frequency(rand(MIN_FREE_FREQ, MAX_FREE_FREQ), TRUE)
	if(.)
		collar(TRUE)

/datum/quirk/state_property/on_process()
	if(pcooldown > world.time)
		return
	pcooldown = world.time + pcooldown_time
	collar(FALSE)

/datum/quirk/state_property/proc/collar(var/initial = FALSE)
	var/mob/living/carbon/human/H = quirk_holder
	if(istype(H))
		if(!istype(H.get_item_by_slot(SLOT_NECK), /obj/item/electropack/shockcollar))
			if(H.get_item_by_slot(SLOT_NECK))
				var/obj/item/I = H.get_item_by_slot(SLOT_NECK)
				I.forceMove(get_turf(H))
			var/obj/item/electropack/shockcollar/woops = new /obj/item/electropack/shockcollar(get_turf(H))
			H.equip_to_slot_or_del(woops, SLOT_NECK)
			if(!woops)
				return FALSE
			ADD_TRAIT(woops, TRAIT_NODROP, "stateproperty")
			woops.set_frequency(storedfreq)
			woops.code = storedcode
			woops.name = "CentComm issue shock collar - freq: [woops.frequency/10] code: [woops.code]"
			woops.desc = "Issued to those who have been deemed naughty."
			var/datum/signal/singnal = new /datum/signal
			singnal.frequency = woops.frequency
			singnal.data["code"] = woops.code
			if(!initial)
				to_chat(H, "<span class='userdanger'>Your collar grows like a raging tumor!</span>")
				woops.receive_signal(singnal)
		else
			var/obj/item/electropack/shockcollar/cooler = H.get_item_by_slot(SLOT_NECK)
			cooler.frequency = storedfreq
			cooler.code = storedcode
			cooler.on = TRUE

//i cant run help
/datum/quirk/asthmatic
	name = "Asthmatic"
	desc = "You have been diagnosed with asthma. You can only run half of what a healthy person can, and running may cause oxygen damage."
	value = -2
	mob_trait = TRAIT_ASTHMATIC
	medical_record_text = "Patient exhibits asthmatic symptoms."

//owie everythign hurt
/datum/quirk/paper_skin
	name = "Paper skin"
	desc = "Your skin and body are fragile. Damage from most sources is increased by 10%."
	value = -3
	medical_record_text = "Patient is frail and  tends to be damaged quite easily."

/datum/quirk/paper_skin/add()
	. = ..()
	if(.)
		var/mob/living/carbon/human/H = quirk_holder
		if(H && istype(H))
			H.physiology.armor -= 10

//mom grab the epipen
/datum/quirk/allergic
	name = "Allergic"
	desc = "You have had terrible allergies for as long as you can remember. Some foods will become toxic to your palate."
	value = -1
	medical_record_text = "Patient is allergic to a certain type of food."

/datum/quirk/allergic/add()
	. = ..()
	if(.)
		var/mob/living/carbon/human/H = quirk_holder
		if(H && istype(H))
			var/foodie = pick(GLOB.food)
			var/randumb = GLOB.food[foodie]
			while((H.dna.species.toxic_food | randumb) == H.dna.species.toxic_food)
				foodie = pick(GLOB.food)
				randumb = GLOB.food[foodie]
			H.dna.species.toxic_food |= randumb
			H.dna.species.liked_food -= randumb
			addtimer(CALLBACK(src, .proc/inform, foodie), 5 SECONDS)

/datum/quirk/allergic/proc/inform(var/allergy = "bad coders")
	to_chat(quirk_holder, "<span class='danger'><b><i>You are allergic to [lowertext(allergy)].</i></b></span>")

//incel quirk
/datum/quirk/ugly
	name = "Ugly"
	desc = "Your face looks like a tumor. People around you will have their mood negatively impacted if you don't cover your face."
	value = -1
	mob_trait = TRAIT_UGLY
	medical_record_text = "Patient is considered exceptionally ugly by most standards."
	var/pcooldown = 0
	var/pcooldown_time = 20 SECONDS

/datum/quirk/ugly/process()
	if(pcooldown > world.time)
		return
	pcooldown = world.time + pcooldown_time
	var/mob/living/carbon/human/H = quirk_holder
	if(H && istype(H))
		if(!H.is_mouth_covered())
			for(var/mob/living/carbon/human/disgusted in (view(7, H) - H))
				SEND_SIGNAL(disgusted, COMSIG_ADD_MOOD_EVENT, "ugly", /datum/mood_event/ugly)
