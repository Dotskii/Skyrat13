
/obj/item/weapon/storage/belt/archaeology
	name = "excavation gear-belt"
	desc = "Can hold various excavation gear."
	icon_state = "gearbelt"
	item_state = "utility"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/weapon/storage/belt/archaeology/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	var/static/list/can_hold = list(
		"/obj/item/storage/box/samplebags",
		"/obj/item/device/core_sampler",
		"/obj/item/device/beacon_locator",
		"/obj/item/beacon",
		"/obj/item/device/gps",
		"/obj/item/device/measuring_tape",
		"/obj/item/flashlight",
		"/obj/item/pickaxe",
		"/obj/item/device/depth_scanner",
		"/obj/item/device/camera",
		"/obj/item/paper",
		"/obj/item/photo",
		"/obj/item/folder",
		"/obj/item/pen",
		"/obj/item/folder",
		"/obj/item/storage/bag/clipboard",
		"/obj/item/anodevice",
		"/obj/item/clothing/glasses",
		"/obj/item/wrench",
		"/obj/item/storage/box/excavation",
		"/obj/item/anobattery",
		"/obj/item/weldingtool",
		"/obj/item/device/xenoarch_scanner")
	STR.can_hold = can_hold

