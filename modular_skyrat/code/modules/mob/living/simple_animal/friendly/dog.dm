//haha its the funny yellow doggy

/mob/living/simple_animal/pet/dog/shiba
	name = "Shiba Inu"
	desc = "Funny yellow dog."
	icon = 'modular_skyrat/icons/mob/pet/funnydog.dmi'
	icon_state = "shiba"
	icon_living = "shiba"
	icon_dead = "shiba_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/corgi = 3, /obj/item/stack/sheet/animalhide/corgi = 1)
	animal_species = /mob/living/simple_animal/pet/dog
	gold_core_spawnable = FRIENDLY_SPAWN
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.","pants.")
	emote_see = list("shakes its head.", "chases its tail.","shivers.")
	faction = list("dog")
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 10
	held_icon = "corgi"

	do_footstep = TRUE

/mob/living/simple_animal/pet/dog/shiba/doge
	name = "Doge"
	desc = "Isn't that the funny dog that does uncharacteristic thing?"
	speak = list("Karen you swine!", "This meme isn't funny anymore.", "Ok retard.", "Oh boy it sure is great to be inhabiting a NanoTrasen space station in the year 2560.", "Cringe.")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.","pants.")
	emote_see = list("shakes its head.", "chases its tail.","shivers.")