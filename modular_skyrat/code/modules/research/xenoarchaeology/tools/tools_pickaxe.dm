
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Excavation pickaxes - sorted in order of delicacy. Players will have to choose the right one for each part of excavation.
/obj/item/pickaxe
	var/excavation_amount = 0
	var/drill_verb = "picking"

/obj/item/pickaxe/brush
	name = "1 cm brush"
	icon = 'modular_skyrat/icons/obj/xenoarchaeology.dmi'
	icon_state = "pick_brush"
	item_state = "syringe_0"
	toolspeed = 0.2
	desc = "Thick metallic wires for clearing away dust and loose scree (1 centimetre excavation depth)."
	excavation_amount = 1
	usesound = list('sound/weapons/thudswoosh.ogg')
	drill_verb = "brushing"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/pickaxe/two_pick
	name = "2 cm pick"
	icon = 'modular_skyrat/icons/obj/xenoarchaeology.dmi'
	icon_state = "pick2"
	item_state = "syringe_0"
	toolspeed = 0.2
	desc = "A miniature excavation tool for precise digging (2 centimetre excavation depth)."
	excavation_amount = 2
	usesound = list('sound/items/Screwdriver.ogg')
	drill_verb = "delicately picking"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/pickaxe/three_pick
	name = "3 cm pick"
	icon = 'modular_skyrat/icons/obj/xenoarchaeology.dmi'
	icon_state = "pick3"
	item_state = "syringe_0"
	toolspeed = 0.2
	desc = "A miniature excavation tool for precise digging (3 centimetre excavation depth)."
	excavation_amount = 3
	usesound = list('sound/items/Screwdriver.ogg')
	drill_verb = "delicately picking"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/pickaxe/four_pick
	name = "4 cm pick"
	icon = 'modular_skyrat/icons/obj/xenoarchaeology.dmi'
	icon_state = "pick4"
	item_state = "syringe_0"
	toolspeed = 0.2
	desc = "A miniature excavation tool for precise digging (4 centimetre excavation depth)."
	excavation_amount = 4
	usesound = list('sound/items/Screwdriver.ogg')
	drill_verb = "delicately picking"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/pickaxe/five_pick
	name = "5 cm pick"
	icon = 'modular_skyrat/icons/obj/xenoarchaeology.dmi'
	icon_state = "pick5"
	item_state = "syringe_0"
	toolspeed = 0.2
	desc = "A miniature excavation tool for precise digging (5 centimetre excavation depth)."
	excavation_amount = 5
	usesound = list('sound/items/Screwdriver.ogg')
	drill_verb = "delicately picking"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/pickaxe/six_pick
	name = "6 cm pick"
	icon = 'modular_skyrat/icons/obj/xenoarchaeology.dmi'
	icon_state = "pick6"
	item_state = "syringe_0"
	toolspeed = 0.2
	desc = "A miniature excavation tool for precise digging (6 centimetre excavation depth)."
	excavation_amount = 6
	usesound = list('sound/items/Screwdriver.ogg')
	drill_verb = "delicately picking"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/pickaxe/hand
	name = "hand pickaxe"
	icon = 'modular_skyrat/icons/obj/xenoarchaeology.dmi'
	icon_state = "pick_hand"
	item_state = "syringe_0"
	toolspeed = 0.3
	desc = "A smaller, more precise version of the pickaxe (15 centimetre excavation depth)."
	excavation_amount = 15
	usesound = list('sound/items/Crowbar.ogg')
	drill_verb = "clearing"
	w_class = WEIGHT_CLASS_NORMAL

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Pack for holding pickaxes

/obj/item/storage/box/excavation
	name = "excavation pick set"
	desc = "A set of picks for excavation."

/obj/item/storage/box/excavation/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.can_hold = list("/obj/item/pickaxe/brush",\
	"/obj/item/pickaxe/two_pick",\
	"/obj/item/pickaxe/three_pick",\
	"/obj/item/pickaxe/four_pick",\
	"/obj/item/pickaxe/five_pick",\
	"/obj/item/pickaxe/six_pick")

/obj/item/weapon/storage/box/excavation/PopulateContents()
	new /obj/item/pickaxe/brush(src)
	new /obj/item/pickaxe/two_pick(src)
	new /obj/item/pickaxe/three_pick(src)
	new /obj/item/pickaxe/four_pick(src)
	new /obj/item/pickaxe/five_pick(src)
	new /obj/item/pickaxe/six_pick(src)
