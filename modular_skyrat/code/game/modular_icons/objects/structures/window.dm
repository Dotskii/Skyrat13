/obj/structure/window
	icon = 'modular_skyrat/icons/eris/obj/structures/windows.dmi'

/obj/structure/window/Initialize(mapload, direct)
	. = ..()
	if(length(canSmoothWith))
		canSmoothWith |= (typesof(/obj/machinery/door) - typesof(/obj/machinery/door/window) - typesof(/obj/machinery/door/firedoor) - typesof(/obj/machinery/door/poddoor))

/obj/structure/window/fulltile
	icon = 'modular_skyrat/icons/eris/obj/smooth_structures/window.dmi'
	canSmoothWith = list(
	/obj/structure/window/fulltile,
	/obj/structure/window/reinforced/fulltile,
	/obj/structure/window/reinforced/tinted/fulltile,
	/obj/structure/window/plasma/fulltile,
	/obj/structure/window/plasma/reinforced/fulltile,
	/obj/structure/window/shuttle,
	/obj/structure/window/plastitanium/fulltile,
	/obj/structure/falsewall,
	/obj/structure/falsewall/brass,
	/obj/structure/falsewall/reinforced,
	/turf/closed/wall,
	/turf/closed/wall/r_wall,
	/turf/closed/wall/rust,
	/turf/closed/wall/r_wall/rust,
	/turf/closed/wall/clockwork,
	)

/obj/structure/window/reinforced
	icon = 'modular_skyrat/icons/eris/obj/structures/windows.dmi'

/obj/structure/window/reinforced/fulltile
	icon = 'modular_skyrat/icons/eris/obj/smooth_structures/reinforced_window.dmi'
	canSmoothWith = list(
	/obj/structure/window/fulltile,
	/obj/structure/window/reinforced/fulltile,
	/obj/structure/window/reinforced/tinted/fulltile,
	/obj/structure/window/plasma/fulltile,
	/obj/structure/window/plasma/reinforced/fulltile,
	/obj/structure/window/shuttle,
	/obj/structure/window/plastitanium/fulltile,
	/obj/structure/falsewall,
	/obj/structure/falsewall/brass,
	/obj/structure/falsewall/reinforced,
	/turf/closed/wall,
	/turf/closed/wall/r_wall,
	/turf/closed/wall/rust,
	/turf/closed/wall/r_wall/rust,
	/turf/closed/wall/clockwork,
	)

/obj/structure/window/plasma
	icon = 'modular_skyrat/icons/eris/obj/structures/windows.dmi'

/obj/structure/window/plasma/fulltile
	icon = 'modular_skyrat/icons/eris/obj/smooth_structures/plasma_window.dmi'
	canSmoothWith = list(
	/obj/structure/window/fulltile,
	/obj/structure/window/reinforced/fulltile,
	/obj/structure/window/reinforced/tinted/fulltile,
	/obj/structure/window/plasma/fulltile,
	/obj/structure/window/plasma/reinforced/fulltile,
	/obj/structure/window/shuttle,
	/obj/structure/window/plastitanium/fulltile,
	/obj/structure/falsewall,
	/obj/structure/falsewall/brass,
	/obj/structure/falsewall/reinforced,
	/turf/closed/wall,
	/turf/closed/wall/r_wall,
	/turf/closed/wall/rust,
	/turf/closed/wall/r_wall/rust,
	/turf/closed/wall/clockwork,
	)

/obj/structure/window/plasma/reinforced
	icon = 'modular_skyrat/icons/eris/obj/structures/windows.dmi'

/obj/structure/window/plasma/reinforced/fulltile
	icon = 'modular_skyrat/icons/eris/obj/smooth_structures/rplasma_window.dmi'
	canSmoothWith = list(
	/obj/structure/window/fulltile,
	/obj/structure/window/reinforced/fulltile,
	/obj/structure/window/reinforced/tinted/fulltile,
	/obj/structure/window/plasma/fulltile,
	/obj/structure/window/plasma/reinforced/fulltile,
	/obj/structure/window/shuttle,
	/obj/structure/window/plastitanium/fulltile,
	/obj/structure/falsewall,
	/obj/structure/falsewall/brass,
	/obj/structure/falsewall/reinforced,
	/turf/closed/wall,
	/turf/closed/wall/r_wall,
	/turf/closed/wall/rust,
	/turf/closed/wall/r_wall/rust,
	/turf/closed/wall/clockwork,
	)

/obj/structure/window/reinforced/tinted
	icon = 'modular_skyrat/icons/eris/obj/structures/windows.dmi'

/obj/structure/window/reinforced/tinted/fulltile
	icon = 'modular_skyrat/icons/eris/obj/smooth_structures/tinted_window.dmi'
	canSmoothWith = list(
	/obj/structure/window/fulltile,
	/obj/structure/window/reinforced/fulltile,
	/obj/structure/window/reinforced/tinted/fulltile,
	/obj/structure/window/plasma/fulltile,
	/obj/structure/window/plasma/reinforced/fulltile,
	/obj/structure/window/shuttle,
	/obj/structure/window/plastitanium/fulltile,
	/obj/structure/falsewall,
	/obj/structure/falsewall/brass,
	/obj/structure/falsewall/reinforced,
	/turf/closed/wall,
	/turf/closed/wall/r_wall,
	/turf/closed/wall/rust,
	/turf/closed/wall/r_wall/rust,
	/turf/closed/wall/clockwork,
	)

/obj/structure/window/plastitanium
	icon = 'modular_skyrat/icons/eris/obj/structures/windows.dmi'

/obj/structure/window/plastitanium/fulltile
	icon = 'modular_skyrat/icons/eris/obj/smooth_structures/plastitanium_window.dmi'
	canSmoothWith = list(
	/obj/structure/window/fulltile,
	/obj/structure/window/reinforced/fulltile,
	/obj/structure/window/reinforced/tinted/fulltile,
	/obj/structure/window/plasma/fulltile,
	/obj/structure/window/plasma/reinforced/fulltile,
	/obj/structure/window/shuttle,
	/obj/structure/window/plastitanium/fulltile,
	/obj/structure/falsewall,
	/obj/structure/falsewall/brass,
	/obj/structure/falsewall/reinforced,
	/turf/closed/wall,
	/turf/closed/wall/r_wall,
	/turf/closed/wall/rust,
	/turf/closed/wall/r_wall/rust,
	/turf/closed/wall/clockwork,
	)

//shuttle windows are retarded
/obj/structure/window/shuttle
	icon = 'modular_skyrat/icons/eris/obj/smooth_structures/plastitanium_window.dmi'
	canSmoothWith = list(
	/obj/structure/window/fulltile,
	/obj/structure/window/reinforced/fulltile,
	/obj/structure/window/reinforced/tinted/fulltile,
	/obj/structure/window/plasma/fulltile,
	/obj/structure/window/plasma/reinforced/fulltile,
	/obj/structure/window/shuttle,
	/obj/structure/window/plastitanium/fulltile,
	/obj/structure/falsewall,
	/obj/structure/falsewall/brass,
	/obj/structure/falsewall/reinforced,
	/turf/closed/wall,
	/turf/closed/wall/r_wall,
	/turf/closed/wall/rust,
	/turf/closed/wall/r_wall/rust,
	/turf/closed/wall/clockwork,
	)
