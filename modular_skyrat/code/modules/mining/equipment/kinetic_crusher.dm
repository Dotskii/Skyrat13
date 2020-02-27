//legion (the big one!)
/obj/item/crusher_trophy/legion_shard
	name = "legion bone shard"
	desc = "Part of a legion's cranium. Suitable as a trophy for a kinetic crusher."
	icon = 'icons/obj/mining.dmi'
	icon_state = "bone"
	denied_type = /obj/item/crusher_trophy/legion_shard

/obj/item/crusher_trophy/legion_shard/effect_desc()
	return "a kinetic crusher to make dead animals into friendly fauna, as well as turning corpses into legions"

/obj/item/crusher_trophy/legion_shard/on_mark_detonation(mob/living/target, mob/living/user)
	if(target.stat == DEAD)
		if(istype(target, /mob/living/simple_animal/hostile/asteroid))
			var/mob/living/simple_animal/hostile/asteroid/L = target
			L.revive(full_heal = 1, admin_revive = 1)
			if(ishostile(L))
				L.attack_same = 0
			L.loot = null
			L.crusher_loot = null
			user.visible_message("<span class='notice'>[user] revives [target] with [src], as a friendly fauna</span>")
			playsound(src,'sound/effects/supermatter.ogg',50,1)

/obj/item/crusher_trophy/legion_shard/on_melee_hit(mob/living/target, mob/living/user)
	if(ishuman(target) && (target.stat == DEAD))
		var/confirm = input("Are you sure you want to turn [target] into a friendly legion?", "Sure?") in list("Yes", "No")
		if(confirm == "Yes")
			var/mob/living/carbon/human/H = target
			var/mob/living/simple_animal/hostile/asteroid/hivelord/legion/L = new /mob/living/simple_animal/hostile/asteroid/hivelord/legion(H.loc)
			L.stored_mob = H
			H.forceMove(L)
			L.faction = list("neutral")
			L.revive(full_heal = 1, admin_revive = 1)
			if(ishostile(L))
				L.attack_same = 0
			L.loot = null
			L.crusher_loot = null
			user.visible_message("<span class='notice'>[user] revives [target] with [src], as a friendly legion.</span>")
			playsound(src,'sound/effects/supermatter.ogg',50,1)
		else
			(to_chat(user, "<span class='notice'>You cancel turning [target] into a legion.</span>"))
//rogue process
/obj/item/crusher_trophy/brokentech
	name = "broken AI"
	desc = "It used to control a mecha, now it's just trash. Suitable as a trophy for a kinetic crusher."
	denied_type = /obj/item/crusher_trophy/brokentech
	icon = 'icons/obj/aicards.dmi'
	icon_state = "pai"
	var/range = 4
	var/cooldowntime

/obj/item/crusher_trophy/brokentech/effect_desc()
	return "a kinetic crusher to create shockwaves when fired."

/obj/item/crusher_trophy/brokentech/on_projectile_fire(obj/item/projectile/destabilizer/marker, mob/living/user)
	. = ..()
	if(cooldowntime < world.time)
		INVOKE_ASYNC(src, .proc/invokesmoke, user)

/obj/item/crusher_trophy/brokentech/proc/invokesmoke(mob/living/user)
	cooldowntime = world.time + 50
	var/list/hit_things = list()
	var/turf/T = get_turf(get_step(user, user.dir))
	var/ogdir = user.dir
	for(var/i = 0, i < src.range, i++)
		new /obj/effect/temp_visual/small_smoke/halfsecond(T)
		for(var/mob/living/L in T.contents)
			if(L != src && !(L in hit_things) && !ishuman(L))
				L.Stun(10)
				L.adjustBruteLoss(10)
		if(ismineralturf(T))
			var/turf/closed/mineral/M = T
			M.gets_drilled(user)
		T = get_step(T, ogdir)
		sleep(2)

//traitor crusher

/obj/item/projectile/destabilizer/harm
	name = "harmful destabilzing force"
	range = 10

/obj/item/projectile/destabilizer/harm/on_hit(atom/target, blocked = FALSE)
	if(isliving(target))
		var/mob/living/L = target
		var/had_effect = (L.has_status_effect(STATUS_EFFECT_CRUSHERMARK_HARM)) //used as a boolean
		var/datum/status_effect/crusher_mark/CM = L.apply_status_effect(STATUS_EFFECT_CRUSHERMARK_HARM, hammer_synced)
		if(hammer_synced)
			for(var/t in hammer_synced.trophies)
				var/obj/item/crusher_trophy/T = t
				T.on_mark_application(target, CM, had_effect)
	var/target_turf = get_turf(target)
	if(ismineralturf(target_turf))
		var/turf/closed/mineral/M = target_turf
		new /obj/effect/temp_visual/kinetic_blast(M)
		M.gets_drilled(firer)
	..()

/obj/item/twohanded/kinetic_crusher/harm
	desc = "An early design of the proto-kinetic accelerator, it is little more than an combination of various mining tools cobbled together, forming a high-tech club. \
	While it is an effective mining tool, it did little to aid any but the most skilled and/or suicidal miners against local fauna. Something's very odd about this one, however..."

/obj/item/twohanded/kinetic_crusher/harm/afterattack(atom/target, mob/living/user, proximity_flag, clickparams)
	if(istype(target, /obj/item/crusher_trophy))
		var/obj/item/crusher_trophy/T = target
		T.add_to(src, user)
	if(!wielded)
		return
	if(!proximity_flag && charged)//Mark a target, or mine a tile.
		var/turf/proj_turf = user.loc
		if(!isturf(proj_turf))
			return
		var/obj/item/projectile/destabilizer/harm/D = new /obj/item/projectile/destabilizer/harm(proj_turf)
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_projectile_fire(D, user)
		D.preparePixelProjectile(target, user, clickparams)
		D.firer = user
		D.hammer_synced = src
		playsound(user, 'sound/weapons/plasma_cutter.ogg', 100, 1)
		D.fire()
		charged = FALSE
		update_icon()
		addtimer(CALLBACK(src, .proc/Recharge), charge_time)
		return
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		var/datum/status_effect/crusher_mark/CM = L.has_status_effect(STATUS_EFFECT_CRUSHERMARK_HARM)
		if(!CM || CM.hammer_synced != src || !L.remove_status_effect(STATUS_EFFECT_CRUSHERMARK_HARM))
			return
		var/datum/status_effect/crusher_damage/C = L.has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
		var/target_health = L.health
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_mark_detonation(target, user)
		if(!QDELETED(L))
			if(!QDELETED(C))
				C.total_damage += target_health - L.health //we did some damage, but let's not assume how much we did
			new /obj/effect/temp_visual/kinetic_blast(get_turf(L))
			var/backstab_dir = get_dir(user, L)
			var/def_check = L.getarmor(type = "bomb")
			if((user.dir & backstab_dir) && (L.dir & backstab_dir))
				if(!QDELETED(C))
					C.total_damage += detonation_damage + backstab_bonus //cheat a little and add the total before killing it, so certain mobs don't have much lower chances of giving an item
				L.apply_damage(detonation_damage + backstab_bonus, BRUTE, blocked = def_check)
				playsound(user, 'sound/weapons/kenetic_accel.ogg', 100, 1) //Seriously who spelled it wrong
			else
				if(!QDELETED(C))
					C.total_damage += detonation_damage
				L.apply_damage(detonation_damage, BRUTE, blocked = def_check)

			if(user && lavaland_equipment_pressure_check(get_turf(user))) //CIT CHANGE - makes sure below only happens in low pressure environments
				user.adjustStaminaLoss(-30)//CIT CHANGE - makes crushers heal stamina
	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target, user, proximity_flag, clickparams)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_AFTERATTACK, target, user, proximity_flag, clickparams)