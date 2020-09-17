/obj/effect/overlay/emote_popup
	icon = 'modular_skyrat/icons/mob/popup_flicks.dmi'
	icon_state = "combat"
	layer = FLY_LAYER
	plane = GAME_PLANE
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	mouse_opacity = 0

/proc/flick_emote_popup_on_mob(mob/M, state, time)
	var/obj/effect/overlay/emote_popup/I = new
	I.icon_state = state
	M.vis_contents += I
	animate(I, alpha = 255, time = 5, easing = BOUNCE_EASING, pixel_y = 10)
	QDEL_IN_CLIENT_TIME(I, time)

/mob/emote(act, m_type = null, message = null, intentional = FALSE)
	. = ..()
	set_typing_indicator(FALSE)

/datum/emote/living/quill
	key = "quill"
	key_third_person = "quills"
	message = "rustles their quills."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	restraint_check = FALSE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/quill/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	playsound(user, 'modular_skyrat/sound/emotes/voxrustle.ogg', 50, 1, -1)

/datum/emote/living/scream/run_emote(mob/living/user, params) //I can't not port this shit, come on.
	if(user.nextsoundemote >= world.time || user.stat != CONSCIOUS)
		return
	var/sound
	var/miming = user.mind ? user.mind.miming : 0
	if(!user.is_muzzled() && !miming)
		user.nextsoundemote = world.time + 7
		if(issilicon(user))
			sound = 'modular_citadel/sound/voice/scream_silicon.ogg'
			if(iscyborg(user))
				var/mob/living/silicon/robot/S = user
				if(S.cell?.charge < 20)
					to_chat(S, "<span class='warning'>Scream module deactivated. Please recharge.</span>")
					return
				S.cell.use(200)
		if(ismonkey(user))
			sound = 'modular_citadel/sound/voice/scream_monkey.ogg'
		if(istype(user, /mob/living/simple_animal/hostile/gorilla))
			sound = 'sound/creatures/gorilla.ogg'
		if(ishuman(user))
			user.adjustOxyLoss(5)
			var/mob/living/carbon/human/H = user
			var/datum/species/userspecies = H.dna.species
			if(H)
				if(userspecies.screamsounds.len)
					sound = pick(userspecies.screamsounds)
				if(H.gender == FEMALE)
					if(userspecies.femalescreamsounds.len)
						sound = pick(userspecies.femalescreamsounds)
		if(isalien(user))
			sound = 'sound/voice/hiss6.ogg'
		LAZYINITLIST(user.alternate_screams)
		if(LAZYLEN(user.alternate_screams))
			sound = pick(user.alternate_screams)
		playsound(user.loc, sound, 50, 1, 4, 1.2)
		message = "screams!"
	else if(miming)
		message = "acts out a scream."
	else
		message = "makes a very loud noise."
	. = ..()

//new era emotes start
/datum/emote/living/fingerguns
	key = "fingergun"
	key_third_person = "fingerguns"
	restraint_check = TRUE

/datum/emote/living/fingerguns/run_emote(mob/user, params)
	. = ..()
	if(!.)
		return
	var/obj/item/toy/gun/finger/G = new(user)
	if(user.put_in_hands(G))
		to_chat(user, "<span class='notice'>You ready your finger gun.</span>")
	else
		to_chat(user, "<span class='warning'>You're incapable of finger gunning in your current state.</span>")
		qdel(G)

/obj/item/toy/gun/finger
	name = "finger gun"
	desc = "BANG! BANG! BANG!"
	item_state = null
	shotsound = sound('modular_skyrat/sound/emotes/trash/pew.ogg')
	dry_fire = FALSE
	infiniteboolet = TRUE
	shoot_cooldown_time = 10

/obj/item/toy/gun/finger/dropped(mob/user)
	..()
	if(loc != user)
		qdel(src)
/* bad emotes do not uncomment
/datum/emote/living/dothemario
	key = "dothemario"
	key_third_person = "doesthemario"
	message = "swings their arm from side to side!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/dothemario/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(.)
		playsound(get_turf(user), 'modular_skyrat/sound/emotes/trash/themario.ogg', 50, 0)
		var/mob/living/u = user
		if(u)
			u.dothemario()

/mob/living/proc/dothemario()
	animate(src, pixel_x = pixel_x + 6, time =  5)
	sleep(10)
	animate(src, pixel_x = pixel_x - 12, time =  10)
	sleep(15)
	animate(src, pixel_x = pixel_x + 6, time = 5)

/datum/emote/living/dab/ultra
	key = "ultradab"
	key_third_person = "ultradabs"
	message = "does the sickest dab a humanoid could ever possibly conjure!"

/datum/emote/living/dab/ultra/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(.)
		playsound(get_turf(user), 'modular_skyrat/sound/emotes/trash/dab.ogg', 20, 0)
		var/initialcolor = user.color
		user.color = "#8B4513"
		sleep(5)
		user.color = initialcolor

/datum/emote/spin/speen
	key = "speen"
	key_third_person = "speens"
	message = "speens!"

/datum/emote/spin/speen/run_emote(mob/user)
	. = ..()
	if(.)
		playsound(get_turf(user), 'modular_skyrat/sound/emotes/trash/speen.ogg', 30, 0)
*/

/datum/emote/flip/run_emote(mob/living/user, params) //no fun allowed :)
	if(prob(20))
		user.visible_message("<span class='warning'>[user] tries to flip, but lands flat on their face!</span>", "<span class='danger'>You try to flip, but land flat on your face!</span>")
		user.Knockdown(20)
		user.setDir(NORTH)
		user.apply_damage(rand(1, 8), BRUTE, BODY_ZONE_HEAD)
		user.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(1, 5), 20)
	else
		. = ..()
//new era emotes end

/datum/emote/living/cough/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	if (isvox(user))
		playsound(user, 'modular_skyrat/sound/emotes/voxcough.ogg', 50, 1, -1)

/datum/emote/living/sneeze/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	if (isvox(user))
		playsound(user, 'modular_skyrat/sound/emotes/voxsneeze.ogg', 50, 1, -1)

/datum/emote/living/peep
	key = "peep"
	key_third_person = "peeps like a bird"
	message = "peeps like a bird!"
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = FALSE
	restraint_check = FALSE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/peep/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	playsound(user, 'modular_skyrat/sound/voice/peep_once.ogg', 50, 1, -1)

/datum/emote/living/peep2
	key = "peep2"
	key_third_person = "peeps twice like a bird"
	message = "peeps twice like a bird!"
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = FALSE
	restraint_check = FALSE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/peep2/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	playsound(user, 'modular_citadel/sound/voice/peep.ogg', 50, 1, -1)
