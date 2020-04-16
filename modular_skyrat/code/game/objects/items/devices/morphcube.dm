/obj/item/morphcube
	name = "strange cube"
	desc = "It has a small red button hidden on it."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	var/uses = 1
	var/list/blacklistedmobs = list()
	var/mob/living/ourmob = /mob/living/simple_animal/mouse
	var/mob/living/targettype
	var/obj/effect/proc_holder/spell/targeted/shapeshift/morphcube/ourspell
	var/list/cubelist = list()

/obj/item/morphcube/Initialize()
	. = ..()
	for(var/NO in typesof(/mob/living/simple_animal/hostile/megafauna))
		blacklistedmobs += NO
	for(var/NO in typesof(/mob/living/carbon))
		blacklistedmobs += NO

/obj/item/morphcube/attack_self(mob/user)
	if(uses > 0)
		uses--
		var/obj/effect/proc_holder/spell/targeted/shapeshift/morphcube/spell = new /obj/effect/proc_holder/spell/targeted/shapeshift/morphcube()
		user.mind.AddSpell(spell)
		spell.owner = user.mind
		spell.possible_shapes = list()
		spell.possible_shapes += ourmob
		spell.shapeshift_type = ourmob
		ourspell = spell
		to_chat(user, "<span class='danger'>[src] grants you a new ability...</span>")
	else
		to_chat(user, "<span class='notice'>[src] fizzles uselessly.</span>")

/obj/item/morphcube/attack(mob/living/target, mob/living/carbon/human/user)
	if(ourspell && user.mind == ourspell.owner)
		for(var/M in blacklistedmobs)
			if(istype(target, M))
				to_chat(user, "<span class='danger'>The target is too complex to be scanned.</span>")
				return FALSE
		for(var/mob/living/delete in src)
			qdel(delete)
		targettype = target.type
		to_chat(user, "<span class='danger'>[src] stores the form of the target.</span>")
		ourspell.possible_shapes = list()
		ourspell.possible_shapes += targettype
		ourspell.shapeshift_type = targettype
		ourmob = targettype
	else if(user.mind)
		for(var/M in blacklistedmobs)
			if(istype(target, M))
				to_chat(user, "<span class='danger'>The target is too complex to be scanned.</span>")
				return FALSE
		for(var/mob/living/delete in src)
			qdel(delete)
		var/mob/living/targettype = target.type
		to_chat(user, "<span class='notice'>[src] stores the form of the target.</span>")
		ourmob = targettype

/obj/effect/proc_holder/spell/targeted/shapeshift/morphcube
	name = "Morphing"
	desc = "Take the shape of the animal selected by your morph cube. Only works within a 7 tile range of the cube!"
	invocation = "MORPH!!"
	charge_max = 100
	possible_shapes = list()
	var/datum/mind/owner = null

/obj/effect/proc_holder/spell/targeted/shapeshift/cast(list/targets, mob/user = usr)
	if(istype(user, /mob/living/carbon))
		for(var/obj/item/morphcube/ourcube in view(user, 7))
			if(ourcube.ourspell == src)
				..()
				return TRUE
		to_chat(user, "<span class='danger'>The cube is out of range, or has been entirely destroyed!</span>")
		return FALSE
	else
		..()
		return TRUE
