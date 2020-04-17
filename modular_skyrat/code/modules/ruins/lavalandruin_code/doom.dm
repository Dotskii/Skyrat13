/obj/item/stack/sheet/animalhide/goliath_hide/vest
	name = "green armor vest"
	desc = "100% armor pickup. Can be used to improve some types of armor."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "armoralt"
	item_state = "armoralt"
	color = "#00FF00"
	light_power = 1
	light_range = 2
	light_color = "#00FF00"

/obj/item/stack/sheet/animalhide/goliath_hide/vest/blue
	name = "mega armor vest"
	desc = "200% armor pickup. Can be used to improve some types of armor."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "armoralt"
	item_state = "armoralt"
	color = "#0000FF"
	light_power = 2
	light_range = 3
	light_color = "#0000FF"

/obj/item/reagent_containers/glass/beaker/synthflesh/healthvial
	name = "health potion"
	desc = "+1% health. Can be splashed to heal brute and burn damage."
	color = "#0000FF"
	light_power = 1
	light_range = 2
	light_color = "#0000FF"

/obj/item/book/granter/martial/berserk
	name = "Strange Rune"
	desc = "Tales tell that this rune may grant the user power beyond measure... for a limited time."
	icon = 'modular_skyrat/icons/obj/items/berserk.dmi'
	icon_state = "bruhrserk"
	martial = /datum/martial_art/berserk
	martialname = "berserk"
	greet = "<span class='userdanger' style='color:rgb(0, 0, 0);'><b>DIG THE PROWESS. THE CAPACITY FOR VIOLENCE!</b></span>"
	pages_to_mastery = 0
	remarks = list("In the first age, in the first battle...", "Rip and tear...", "Huge guts...", "Big fucking gun...")

/turf/open/floor/carpet/blue/doomed
	name = "marine base carpet"
	desc = "Carpet, so barefoot demons can have some comfort."
	floor_tile = null
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/closed/wall/mineral/plastitanium/doomed
	name = "marine base wall"
	desc = "A very doomed wall."
	explosion_block = 50

/obj/machinery/door/airlock/titanium/doomed
	name = "marine base airlock"
	desc = "Knee deep in the dead."

/obj/machinery/door/airlock/titanium/doomed/locked
	name = "jammed airlock"
	desc = "It seems to be functional... there has to be a way to open it."
	explosion_block = 50
	var/list/candylist = list()
	var/shouldunlock = FALSE

/obj/machinery/door/airlock/titanium/doomed/locked/obj/machinery/door/airlock/titanium/doomed/locked/Initialize()
	for(var/mob/living/simple_animal/hostile/asteroid/elite/candy/C in view(15))
		candylist += C
	if(candylist.len)
		close()
		sleep(5)
		bolt()

/obj/machinery/door/airlock/titanium/doomed/locked/obj/machinery/door/airlock/titanium/doomed/locked/process()
	. = ..()
	candylist = list()
	for(var/mob/living/simple_animal/hostile/asteroid/elite/candy/C in view(15))
		if(C.stat != DEAD)
			candylist += C
		return
	if(!candylist.len)
		STOP_PROCESSING(SSprocessing, src)
		unbolt()

/obj/item/gun/ballistic/shotgun/doomed
	name = "classic pump-action shotgun"
	desc = "Shotguns can deliver a heavy punch at close range and a generous pelting from a distance. Not nearly as powerful as it's super variant."
	w_class = WEIGHT_CLASS_NORMAL

/obj/structure/fermenting_barrel/doom
	name = "toxic waste barrel"
	desc = "Filled with bad stuff. Probably explodes."
	icon = 'modular_skyrat/icons/obj/doom.dmi'
	icon_state = "barrel"

/obj/structure/fermenting_barrel/doom/Initialize()
	..()
	src.reagents.add_reagent(pick(subtypesof(/datum/reagent/toxin)), 300)

/obj/structure/fermenting_barrel/doom/Destroy()
	. = ..()
	explosion(src.loc, -1, -1, 1, -1, 0, 3)

/area/ruin/powered/e1m1
	name = "Hangar"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	icon_state = "dk_yellow"
