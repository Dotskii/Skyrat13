/datum/element/mob_holder/yoink
	var/damage = 15
	var/sharpness = IS_SHARP
	var/gibs = TRUE
	var/attack_sound = 'modular_skyrat/sound/effects/yoink.wav'
	var/pickup_sound = 'modular_skyrat/sound/effects/rat_pickup.wav'

/datum/element/mob_holder/yoink/mob_try_pickup(mob/living/source, mob/user)
	if(!ishuman(user) || !user.Adjacent(source) || user.incapacitated())
		return FALSE
	if(user.get_active_held_item())
		to_chat(user, "<span class='warning'>Your hands are full!</span>")
		return FALSE
	if(source.buckled)
		to_chat(user, "<span class='warning'>[source] is buckled to something!</span>")
		return FALSE
	if(source == user)
		to_chat(user, "<span class='warning'>You can't pick yourself up.</span>")
		return FALSE
	source.visible_message("<span class='warning'>[user] starts picking up [source].</span>", \
					"<span class='userdanger'>[user] starts picking you up!</span>")
	if(!do_after(user, 20, target = source) || source.buckled)
		return FALSE

	source.visible_message("<span class='warning'>[user] picks up [source]!</span>", \
					"<span class='userdanger'>[user] picks you up!</span>")
	to_chat(user, "<span class='notice'>You pick [source] up.</span>")
	source.drop_all_held_items()
	var/obj/item/clothing/head/mob_holder/holder = new(get_turf(source), source, worn_state, alt_worn, right_hand, left_hand, inv_slots, damage, sharpness, rand(0, 1), attack_sound, pickup_sound)
	if(proctype)
		INVOKE_ASYNC(src, proctype, source, holder, user)
	user.put_in_hands(holder)
	return TRUE
