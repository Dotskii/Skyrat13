/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanite swarm"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	icon = 'icons/obj/nanopaste.dmi'
	icon_state = "tube"
	amount = 6
	max_amount = 6
	toolspeed = 1

/obj/item/stack/nanopaste/attack(mob/living/M, mob/living/user)
	if(!istype(M) || !istype(user))
		return 0
	if(istype(M,/mob/living/silicon/robot))	//Repairing cyborgs
		var/mob/living/silicon/robot/R = M
		if(R.getBruteLoss() || R.getFireLoss() )
			R.heal_overall_damage(15, 15)
			use(1)
			user.visible_message("<span class='notice'>\The [user] applied some [src] at [R]'s damaged areas.</span>",\
				"<span class='notice'>You apply some [src] at [R]'s damaged areas.</span>")
		else
			to_chat(user, "<span class='notice'>All [R]'s systems are nominal.</span>")
		return

	if(istype(M,/mob/living/carbon/human)) //Repairing robotic limbs and IPCs
		var/mob/living/carbon/human/H = M
		var/obj/item/bodypart/S = H.get_bodypart(user.zone_selected)

		var/is_robotic = !S.is_organic_limb()
		if(S && is_robotic)
			if(S.get_damage())
				use(1)
				S.heal_damage(15)
				var/list/organs = H.getorganszone(user.zone_selected)
				var/list/roboorgans
				for(var/obj/item/organ/O in organs)
					if(O.organ_flags & ORGAN_SYNTHETIC || O.status == ORGAN_ROBOTIC)
						if(O.damage > 0)
							roboorgans += O
				for(var/obj/item/organ/OR in roboorgans)
					OR.damage = max((OR.damage - 15/roboorgans.len), 0) //just to be sure
			if(H.bleed_rate)
				H.bleed_rate = 0
			user.visible_message("<span class='notice'>\The [user] applies some nanite paste at \the [M]'s [S.name] with \the [src].</span>")
		else
			to_chat(user, "<span class='notice'>Nothing to fix here.</span>")
	else
		to_chat(user, "<span class='notice'>[src] won't work on that.</span>")
	return
