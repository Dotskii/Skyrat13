/obj/item/storage/book/bible/attack_self(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(!H.can_read(src))
		return FALSE
	// If H is the Chaplain, we can set the icon_state of the bible (but only once!)
	if(!GLOB.bible_icon_state && (H.mind.holy_role == HOLY_ROLE_HIGHPRIEST || H.job = "Chaplain"))
		var/dat = "<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>Pick Bible Style</title></head><body><center><h2>Pick a bible style</h2></center><table>"
		for(var/i in 1 to GLOB.biblestates.len)
			var/icon/bibleicon = icon('icons/obj/storage.dmi', GLOB.biblestates[i])
			var/nicename = GLOB.biblenames[i]
			H << browse_rsc(bibleicon, nicename)
			dat += {"<tr><td><img src="[nicename]"></td><td><a href="?src=[REF(src)];seticon=[i]">[nicename]</a></td></tr>"}
		dat += "</table></body></html>"
		H << browse(dat, "window=editicon;can_close=0;can_minimize=0;size=250x650")

/obj/item/storage/book/bible/bless(mob/living/L, mob/living/user)
	if(GLOB.religious_sect)
		return GLOB.religious_sect.sect_bless(L,user)
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	for(var/X in H.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.status == BODYPART_ROBOTIC)
			to_chat(user, "<span class='warning'>[src.deity_name] refuses to heal this metallic taint!</span>")
			return 0

	var/heal_amt = 10
	var/list/hurt_limbs = H.get_damaged_bodyparts(1, 1, null, BODYPART_ORGANIC)

	if(hurt_limbs.len)
		for(var/X in hurt_limbs)
			var/obj/item/bodypart/affecting = X
			if(affecting.heal_damage(heal_amt, heal_amt, null, BODYPART_ORGANIC))
				H.update_damage_overlays()
		H.visible_message("<span class='notice'>[user] heals [H] with the power of [deity_name]!</span>")
		to_chat(H, "<span class='boldnotice'>May the power of [deity_name] compel you to be healed!</span>")
		playsound(src.loc, "punch", 25, TRUE, -1)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return 1

/obj/item/storage/book/bible/attack(mob/living/M, mob/living/carbon/human/user, heal_mode = TRUE)

	if (!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if (HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, "<span class='danger'>[src] slips out of your hand and hits your head.</span>")
		user.take_bodypart_damage(10)
		user.Unconscious(400)
		return

	var/chaplain = 0
	if(user.mind && (user.mind.holy_role || user.mind.isholy))
		chaplain = 1

	if(!chaplain)
		to_chat(user, "<span class='danger'>The book sizzles in your hands.</span>")
		user.take_bodypart_damage(0,10)
		return

	if (!heal_mode)
		return ..()

	var/smack = 1

	if (M.stat != DEAD)
		if(chaplain && user == M)
			to_chat(user, "<span class='warning'>You can't heal yourself!</span>")
			return

		if(prob(60) && bless(M, user))
			smack = 0
		else if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(!istype(C.head, /obj/item/clothing/head/helmet))
				C.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 60)
				to_chat(C, "<span class='danger'>You feel dumber.</span>")

		if(smack)
			M.visible_message("<span class='danger'>[user] beats [M] over the head with [src]!</span>", \
					"<span class='userdanger'>[user] beats [M] over the head with [src]!</span>")
			playsound(src.loc, "punch", 25, TRUE, -1)
			log_combat(user, M, "attacked", src)

	else
		M.visible_message("<span class='danger'>[user] smacks [M]'s lifeless corpse with [src].</span>")
		playsound(src.loc, "punch", 25, TRUE, -1)

/obj/item/storage/book/bible/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(isfloorturf(A))
		to_chat(user, "<span class='notice'>You hit the floor with the bible.</span>")
		if(user.mind && (user.mind.holy_role || user.mind.isholy))
			for(var/obj/effect/rune/R in orange(2,user))
				R.invisibility = 0
	if(user?.mind?.holy_role || (user.mind && user.mind.isholy))
		if(A.reagents && A.reagents.has_reagent(/datum/reagent/water)) // blesses all the water in the holder
			to_chat(user, "<span class='notice'>You bless [A].</span>")
			var/water2holy = A.reagents.get_reagent_amount(/datum/reagent/water)
			A.reagents.del_reagent(/datum/reagent/water)
			A.reagents.add_reagent(/datum/reagent/water/holywater,water2holy)
		if(A.reagents && A.reagents.has_reagent(/datum/reagent/fuel/unholywater)) // yeah yeah, copy pasted code - sue me
			to_chat(user, "<span class='notice'>You purify [A].</span>")
			var/unholy2clean = A.reagents.get_reagent_amount(/datum/reagent/fuel/unholywater)
			A.reagents.del_reagent(/datum/reagent/fuel/unholywater)
			A.reagents.add_reagent(/datum/reagent/water/holywater,unholy2clean)
		if(istype(A, /obj/item/storage/book/bible) && !istype(A, /obj/item/storage/book/bible/syndicate))
			to_chat(user, "<span class='notice'>You purify [A], conforming it to your belief.</span>")
			var/obj/item/storage/book/bible/B = A
			B.name = name
			B.icon_state = icon_state
			B.item_state = item_state
	if(istype(A, /obj/item/twohanded/required/cult_bastard) && !iscultist(user))
		var/obj/item/twohanded/required/cult_bastard/sword = A
		to_chat(user, "<span class='notice'>You begin to exorcise [sword].</span>")
		playsound(src,'sound/hallucinations/veryfar_noise.ogg',40,TRUE)
		if(do_after(user, 40, target = sword))
			playsound(src,'sound/effects/pray_chaplain.ogg',60,TRUE)
			for(var/obj/item/soulstone/SS in sword.contents)
				SS.usability = TRUE
				for(var/mob/living/simple_animal/shade/EX in SS)
					SSticker.mode.remove_cultist(EX.mind, 1, 0)
					EX.icon_state = "ghost1"
					EX.name = "Purified [EX.name]"
				SS.release_shades(user)
				qdel(SS)
			new /obj/item/nullrod/claymore(get_turf(sword))
			user.visible_message("<span class='notice'>[user] has purified [sword]!</span>")
			qdel(sword)
	else if(istype(A, /obj/item/soulstone) && !iscultist(user))
		var/obj/item/soulstone/SS = A
		if(SS.purified)
			return
		to_chat(user, "<span class='notice'>You begin to exorcise [SS].</span>")
		playsound(src,'sound/hallucinations/veryfar_noise.ogg',40,TRUE)
		if(do_after(user, 40, target = SS))
			playsound(src,'sound/effects/pray_chaplain.ogg',60,TRUE)
			SS.usability = TRUE
			SS.purified = TRUE
			SS.icon_state = "purified_soulstone"
			for(var/mob/M in SS.contents)
				if(M.mind)
					SS.icon_state = "purified_soulstone2"
					if(iscultist(M))
						SSticker.mode.remove_cultist(M.mind, FALSE, FALSE)
			for(var/mob/living/simple_animal/shade/EX in SS)
				EX.icon_state = "ghost1"
				EX.name = "Purified [initial(EX.name)]"
			user.visible_message("<span class='notice'>[user] has purified [SS]!</span>")
	else if(istype(A, /obj/item/nullrod/scythe/talking))
		var/obj/item/nullrod/scythe/talking/sword = A
		to_chat(user, "<span class='notice'>You begin to exorcise [sword]...</span>")
		playsound(src,'sound/hallucinations/veryfar_noise.ogg',40,TRUE)
		if(do_after(user, 40, target = sword))
			playsound(src,'sound/effects/pray_chaplain.ogg',60,TRUE)
			for(var/mob/living/simple_animal/shade/S in sword.contents)
				to_chat(S, "<span class='userdanger'>You were destroyed by the exorcism!</span>")
				qdel(S)
			sword.possessed = FALSE //allows the chaplain (or someone else) to reroll a new spirit for their sword
			sword.name = initial(sword.name)
			REMOVE_TRAIT(sword, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT) //in case the "sword" is a possessed dummy
			user.visible_message("<span class='notice'>[user] has exorcised [sword]!</span>", \
								"<span class='notice'>You successfully exorcise [sword]!</span>")

/obj/item/storage/book/bible/syndicate/attack_self(mob/living/carbon/human/H)
	if (uses)
		H.mind.holy_role = HOLY_ROLE_PRIEST
		uses -= 1
		to_chat(H, "<span class='userdanger'>You try to open the book AND IT BITES YOU!</span>")
		playsound(src.loc, 'sound/effects/snap.ogg', 50, TRUE)
		H.apply_damage(5, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		to_chat(H, "<span class='notice'>Your name appears on the inside cover, in blood.</span>")
		var/ownername = H.real_name
		desc += "<span class='warning'>The name [ownername] is written in blood inside the cover.</span>"