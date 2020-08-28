/mob/living/carbon/can_feel_pain()
	if(HAS_TRAIT(src, TRAIT_PAINLESS))
		return FALSE
	return TRUE

/mob/living/carbon/handle_pain()
	if((stat >= UNCONSCIOUS) || !can_feel_pain())
		return
	
	if(world.time < next_pain_time)
		return
	
	var/maxdam = 0
	var/obj/item/bodypart/damaged_bodypart = null
	for(var/obj/item/bodypart/BP in bodyparts)
		if(!BP.can_feel_pain())
			continue
		var/dam = BP.get_damage(include_pain = TRUE)
		// make the choice of the organ depend on damage,
		// but also sometimes use one of the less damaged ones
		if(dam >= maxdam && (maxdam <= 0 || prob(70)) )
			damaged_bodypart = BP
			maxdam = dam
	
	if(damaged_bodypart && (chem_effects[CE_PAINKILLER] < maxdam))
		if(maxdam > 10 && IsParalyzed())
			var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed(FALSE)
			if(P)
				P.duration -= round(maxdam/10)
		if((damaged_bodypart.held_index) && maxdam > 50 && prob(maxdam/5))
			var/obj/item/droppy = get_item_for_held_index(damaged_bodypart.held_index)
			if(droppy)
				dropItemToGround(droppy)
		var/burning = damaged_bodypart.burn_dam > damaged_bodypart.brute_dam
		var/msg
		switch(maxdam)
			if(1 to 10)
				msg =  "Your [damaged_bodypart.name] [burning ? "burns" : "hurts"]."
			if(11 to 90)
				msg = "Your [damaged_bodypart.name] [burning ? "burns" : "hurts"] badly!"
			if(91 to INFINITY)
				msg = "OH GOD! Your [damaged_bodypart.name] is [burning ? "on fire" : "hurting terribly"]!"
		custom_pain(msg, maxdam, FALSE, damaged_bodypart)
	
	// Damage to internal organs hurts a lot.
	for(var/obj/item/organ/O in internal_organs)
		if(prob(1) && !((O.organ_flags & ORGAN_FAILING) || (O.status & ORGAN_ROBOTIC)) && O.damage >= 5)
			var/obj/item/bodypart/parent = get_bodypart(O.zone)
			var/pain = 10
			var/message = "You feel a dull pain in your [parent.name]"
			if(O.damage >= O.low_threshold)
				pain = 25
				message = "You feel a pain in your [parent.name]"
			if((O.damage >= O.high_threshold) || (O.organ_flags & ORGAN_FAILING))
				pain = 50
				message = "You feel a sharp pain in your [parent.name]"
			custom_pain(message, pain, FALSE, parent)

	var/toxDamageMessage = null
	var/toxMessageProb = 1
	var/toxin_damage = getToxLoss()
	switch(toxin_damage)
		if(1 to 5)
			toxMessageProb = 1
			toxDamageMessage = "Your body stings slightly."
		if(5 to 10)
			toxMessageProb = 2
			toxDamageMessage = "Your whole body hurts a little."
		if(10 to 20)
			toxMessageProb = 2
			toxDamageMessage = "Your whole body hurts."
		if(20 to 30)
			toxMessageProb = 3
			toxDamageMessage = "Your whole body hurts badly."
		if(30 to INFINITY)
			toxMessageProb = 5
			toxDamageMessage = "Your body aches all over, it's driving you mad!"
	
	if(toxDamageMessage && prob(toxMessageProb))
		custom_pain(toxDamageMessage, toxin_damage)

/mob/living/carbon/update_pain()
	if(!client || !hud_used)
		return
	if(hud_used.pains)
		if(stat != DEAD)
			. = 1
			if(!HAS_TRAIT(src, TRAIT_SCREWY_CHECKSELF))
				switch(get_shock())
					if(-INFINITY to 5)
						hud_used.pains.icon_state = "pain0"
					if(5 to 15)
						hud_used.pains.icon_state = "pain1"
					if(15 to 30)
						hud_used.pains.icon_state = "pain2"
					if(30 to 45)
						hud_used.pains.icon_state = "pain3"
					if(45 to 60)
						hud_used.pains.icon_state = "pain4"
					if(60 to 75)
						hud_used.pains.icon_state = "pain5"
					if(75 to INFINITY)
						hud_used.pains.icon_state = "pain6"
			else
				hud_used.pains.icon_state = "pain0"
		else
			hud_used.pains.icon_state = "pain7"

/mob/living/carbon/proc/print_pain()
	var/msg = "<span class='info'>*---------*\n<EM>My current pain</EM></span>\n"
	msg += "<span class='notice'>In general: </span>"
	if(stat != DEAD)
		if(!HAS_TRAIT(src, TRAIT_SCREWY_CHECKSELF))
			switch(getPainLoss())
				if(-INFINITY to 5) //pain0
					msg += "<span class='nicegreen'>I feel healthy.</span>\n"
				if(5 to 15) //pain1
					msg += "<span class='nicegreen'>I'm a bit sore.</span>\n"
				if(15 to 30) //pain2
					msg += "<span class='notice'>I'm a bit hurt.</span>\n"
				if(30 to 45) //pain3
					msg += "<span class='danger'>I don't feel great...</span>\n"
				if(45 to 60) //pain4
					msg += "<span class='bolddanger'>I feel terrible!</span>\n"
				if(60 to 75) //pain5
					msg += "<span class='mediumdanger'>I'm miserable!</span>\n"
				if(75 to INFINITY) //pain6
					msg += "<span class='bigdanger'>I want to die!</span>\n"
		else
			msg += "<span class='nicegreen'>I feel healthy.</span>\n"
	else
		msg += "<span class='deadsay'>I am dead!</span>\n"
	msg += "<span class='notice'>Bodyparts:\n</span>"
	if(stat != DEAD)
		if(!HAS_TRAIT(src, TRAIT_SCREWY_CHECKSELF))
			var/list/damaged_bodyparts = list()
			for(var/obj/item/bodypart/BP in bodyparts)
				var/bpain = BP.get_pain()
				if(bpain >= BP.max_damage)
					damaged_bodyparts += "<span class='bigdanger'>I want to tear my [BP.name] off!</span>\n"
				else if(bpain > BP.max_damage*0.8)
					damaged_bodyparts += "<span class='mediumdanger'>My [BP.name] feels horrendous!</span>\n"
				else if(bpain > BP.max_damage*0.6)
					damaged_bodyparts += "<span class='bolddanger'>My [BP.name] feels terrible!</span>\n"
				else if(bpain > BP.max_damage*0.4)
					damaged_bodyparts += "<span class='danger'>My [BP.name] feels a bit battered...</span>\n"
				else if(bpain > BP.max_damage*0.2)
					damaged_bodyparts += "<span class='notice'>My [BP.name] feels somewhat damaged.</span>\n"
				else if(bpain > 0)
					damaged_bodyparts += "<span class='notice'>My [BP.name] is just a bit sore.</span>\n"
			if(!length(damaged_bodyparts))
				msg += "<span class='nicegreen'>My whole body feels just fine.</span>\n"
			else
				for(var/i in damaged_bodyparts)
					msg += i
		else
			msg += "<span class='nicegreen'>My whole body feels just fine.</span>\n"
	else
		msg += "<span class='deadsay'>All of my bodyparts are lifeless!</span>\n"
	to_chat(src, msg)

//How much we are actually in shock
/mob/living/carbon/proc/get_shock()
	if(!can_feel_pain())
		return 0

	var/traumatic_shock = getPainLoss() //How much pain we are in
	traumatic_shock -= chem_effects[CE_PAINKILLER]

	return max(0,traumatic_shock)

/mob/living/carbon/proc/InShock()
	return (get_shock() >= SHOCK_STAGE_3)

/mob/living/carbon/proc/InFullShock()
	return (get_shock() >= SHOCK_STAGE_6)

/mob/living/carbon/proc/handle_shock()
	if(!can_feel_pain())
		shock_stage = 0
		return
	
	if(is_asystole())
		shock_stage = max(shock_stage + 1, SHOCK_STAGE_4)
	
	var/traumatic_shock = get_shock()
	if(traumatic_shock >= max(SHOCK_STAGE_2, 0.8*shock_stage))
		shock_stage += 1
	else if(!is_asystole())
		shock_stage = min(shock_stage, SHOCK_STAGE_7)
		var/recovery = 1
		if(traumatic_shock < 0.5 * shock_stage) //lower shock faster if pain is gone completely
			recovery++
		if(traumatic_shock < 0.25 * shock_stage)
			recovery++
		shock_stage = max(shock_stage - recovery, 0)
		return

	if(stat > UNCONSCIOUS)
		return
	
	if(shock_stage == SHOCK_STAGE_1)
		// Please be very careful when calling custom_pain() from within code that relies on pain/trauma values. There's the
		// possibility of a feedback loop from custom_pain() being called with a positive power, incrementing pain on a limb,
		// which triggers this proc, which calls custom_pain(), etc. Make sure you call it with nopainloss = TRUE in these cases!
		custom_pain("[pick("It hurts so much", "You really need some painkillers", "Dear god, the pain")]!", 10, nopainloss = TRUE)

	if(shock_stage >= SHOCK_STAGE_2)
		if(shock_stage == SHOCK_STAGE_2)
			visible_message("<b>[src]</b> is having trouble keeping [p_their()] eyes open.")
		if(prob(30))
			blur_eyes(2)
			stuttering = max(stuttering, 5)

	if(shock_stage == SHOCK_STAGE_3)
		custom_pain("[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!", 40, nopainloss = TRUE)
	
	if(shock_stage >= SHOCK_STAGE_4)
		if(shock_stage == SHOCK_STAGE_4)
			visible_message("<b>[src]</b>'s body becomes limp.")
		if(prob(2))
			custom_pain("[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!", shock_stage, nopainloss = TRUE)
			Knockdown(400)

	if(shock_stage >= SHOCK_STAGE_5)
		if(prob(5))
			custom_pain("[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!", shock_stage, nopainloss = TRUE)
			Stun(400)
		
	if(shock_stage >= SHOCK_STAGE_6)
		if(prob(2))
			if(!IsUnconscious())
				custom_pain("[pick("You black out", "You feel like you could die any moment now", "You're about to lose consciousness")]!", shock_stage, nopainloss = TRUE)
			Unconscious(rand(500, 1000))

	if(shock_stage == SHOCK_STAGE_7)
		if(IsKnockdown())
			visible_message("<b>[src]</b> can no longer stand, collapsing!")
		Knockdown(500)

	if(shock_stage >= SHOCK_STAGE_7)
		Paralyze(500)
		if(prob(4))
			Unconscious(600)
	
	if(shock_stage >= SHOCK_STAGE_8)
		if(!IsUnconscious())
			to_chat(src, "<span class='warning'>[dna.species.painloss_message_self]</span>")
			visible_message("<span class='warning'>[dna.species.painloss_message]</span>", "<span class='danger'>[dna.species.painloss_message_self]</span>")
		Unconscious(800)

/mob/living/carbon/fully_heal(admin_revive)
	. = ..()
	shock_stage = 0
	setPainLoss(0, FALSE)
