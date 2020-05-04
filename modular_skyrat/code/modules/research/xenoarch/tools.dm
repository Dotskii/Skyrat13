/obj/item/xenoarch
	name = "Parent Xenoarch"
	desc = "Debug. Parent Clean"
	icon = 'modular_skyrat/code/modules/research/xenoarch/tools.dmi'

/obj/item/xenoarch/Initialize()
	..()

/obj/item/xenoarch/clean/hammer
	name = "Parent hammer"
	desc = "Debug. Parent Hammer."
	var/cleandepth = 15

/obj/item/xenoarch/clean/hammer/cm1
	name = "mining hammer cm1"
	desc = "removes 1cm of material."
	icon_state = "pick1"
	cleandepth = 1

/obj/item/xenoarch/clean/hammer/cm2
	name = "mining hammer cm2"
	desc = "removes 2cm of material."
	icon_state = "pick2"
	cleandepth = 2

/obj/item/xenoarch/clean/hammer/cm3
	name = "mining hammer cm3"
	desc = "removes 3cm of material."
	icon_state = "pick3"
	cleandepth = 3

/obj/item/xenoarch/clean/hammer/cm4
	name = "mining hammer cm4"
	desc = "removes 4cm of material."
	icon_state = "pick4"
	cleandepth = 4

/obj/item/xenoarch/clean/hammer/cm5
	name = "mining hammer cm5"
	desc = "removes 5cm of material."
	icon_state = "pick5"
	cleandepth = 5

/obj/item/xenoarch/clean/hammer/cm6
	name = "mining hammer cm6"
	desc = "removes 6cm of material."
	icon_state = "pick6"
	cleandepth = 6

/obj/item/xenoarch/clean/hammer/cm15
	name = "mining hammer cm15"
	desc = "removes 15cm of material."
	icon_state = "pick_hand"
	cleandepth = 15

/obj/item/xenoarch/clean/hammer/advanced
	name = "advanced hammer"
	desc = "Removes a custom amount of debris."
	icon_state = "advpick"
	cleandepth = 30

/obj/item/xenoarch/clean/hammer/advanced/attack_self(mob/living/carbon/user)
	var/depthchoice = input(user, "What depth would you like to mine with? (1-30)", "Change Dig Depth") as null|num
	if(depthchoice && (depthchoice > 0 && depthchoice <= 30))
		cleandepth = depthchoice
		desc = "Removes a custom amount of debris. It will dig [cleandepth] centimeters."
		to_chat(user, "<span class='notice'>You set the dig depth of the hammer to [cleandepth] centimeters.</span>")
//

/obj/item/xenoarch/clean/brush
	name = "mining brush"
	desc = "cleans off the remaining debris."
	icon_state = "pick_brush"

//

/obj/item/xenoarch/help/scanner
	name = "mining scanner"
	desc = "Inaccurately scans a rock's depths."
	icon_state = "scanner"

/obj/item/xenoarch/help/scanneradv
	name = "advanced mining scanner"
	desc = "Accurately scans a rock's depths."
	icon_state = "adv_scanner"

/obj/item/xenoarch/help/measuring
	name = "measuring tape"
	desc = "Measures how far a rock has been dug into."
	icon_state = "measuring"

/obj/item/xenoarch/help/research
	name = "research analyzer"
	desc = "Deconstructs artifacts for research."
	icon_state = "researchscanner"

/obj/item/xenoarch/help/plant
	name = "fossil seed extractor"
	desc = "Takes flora fossils and extracts the prehistoric seeds."
	icon_state = "plantscanner"

// Eventually, make it work on afterattack(atom/target, mob/user , proximity)
// I dont want to take more time currently though.
// Would have to create a list and then check if the item is in the list.

/obj/item/xenoarch/help/cargo
	name = "dimensional cargo scanner"
	desc = "teleports items to be sold."
	icon_state = "cargoscanner"

/obj/item/xenoarch/help/cargo/afterattack(atom/target, mob/user , proximity)
	if(!proximity)
		return
	var/export_categories = EXPORT_CARGO
	if(!istype(target,/obj/item))
		return
	var/datum/export_report/ex = new
	if(!do_after(user,300,target=target))
		to_chat(user,"You need to stand still to export items.")
		return
	export_item_and_contents(target, export_categories , dry_run = FALSE, external_report = ex)
	for(var/datum/export/E in ex.total_amount)
		var/export_text = E.total_printout(ex)
		if(!export_text)
			continue
		SSshuttle.points += ex.total_value[E]
	to_chat(user,"You sell the [target].")


// Storage: Belt and Locker

/obj/item/storage/belt/xenoarch
	name = "xenoarchaeologist belt"
	desc = "used to store your tools for xenoarchaeology."
	icon = 'modular_skyrat/code/modules/research/xenoarch/tools.dmi'
	icon_state = "miningbelt"

/obj/item/storage/belt/xenoarch/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	var/static/list/can_hold = typecacheof(list(
		/obj/item/xenoarch/help,
		/obj/item/xenoarch/clean,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/gps
		))
	STR.can_hold = can_hold
	STR.max_items = 12
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.max_combined_w_class = 200

/obj/item/storage/belt/xenoarch/full/PopulateContents()
	new /obj/item/xenoarch/help/measuring(src)
	new /obj/item/xenoarch/help/scanner(src)
	new /obj/item/xenoarch/clean/brush(src)
	new /obj/item/xenoarch/clean/hammer/cm15(src)
	new /obj/item/xenoarch/clean/hammer/cm6(src)
	new /obj/item/xenoarch/clean/hammer/cm5(src)
	new /obj/item/xenoarch/clean/hammer/cm4(src)
	new /obj/item/xenoarch/clean/hammer/cm3(src)
	new /obj/item/xenoarch/clean/hammer/cm2(src)
	new /obj/item/xenoarch/clean/hammer/cm1(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/gps(src)
	return

/obj/structure/closet/wardrobe/xenoarch
	name = "science wardrobe"
	icon_state = "science"
	icon_door = "science"

/obj/structure/closet/wardrobe/xenoarch/PopulateContents()
	new /obj/item/xenoarch/help/measuring(src)
	new /obj/item/xenoarch/help/scanner(src)
	new /obj/item/xenoarch/clean/brush(src)
	new /obj/item/xenoarch/clean/hammer/cm15(src)
	new /obj/item/xenoarch/clean/hammer/cm6(src)
	new /obj/item/xenoarch/clean/hammer/cm5(src)
	new /obj/item/xenoarch/clean/hammer/cm4(src)
	new /obj/item/xenoarch/clean/hammer/cm3(src)
	new /obj/item/xenoarch/clean/hammer/cm2(src)
	new /obj/item/xenoarch/clean/hammer/cm1(src)
	new /obj/item/pickaxe(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/gps(src)
	new /obj/item/storage/belt/xenoarch(src)
	return

//

//Research WEB

/datum/techweb_node/xenoarchtools
	id = "xenoarchtools"
	starting_node = TRUE
	display_name = "Xenoarchaeology Tools"
	description = "Xenoarchaeology tools that are used for xenoarchaeology, who knew."
	design_ids = list("hammercm1","hammercm2","hammercm3","hammercm4","hammercm5","hammercm6","hammercm15","hammerbrush","xenoscanner","xenomeasure","xenobelt")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/portxenoarch
	id = "portxenoarch"
	display_name = "Portable Xenoarchaeology Tools"
	description = "Tools for extracting seeds, and for getting some research points."
	prereq_ids = list("xenoarchtools")
	design_ids = list("xenoresearch","xenoplant")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/advportcargo
	id = "advportcargo"
	display_name = "Advanced Cargo Technology"
	description = "A tool for selling stuff not through a shuttle. Careful with its use."
	prereq_ids = list("portxenoarch")
	design_ids = list("advcargoscanner")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

/datum/techweb_node/advxenoarch
	id = "advxenoarch"
	display_name = "Man Machine Interface"
	description = "Tools that can make your excavation and recovering of artifacts easier."
	prereq_ids = list("xenoarchtools")
	design_ids = list("advxenoscanner")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

//Research DESIGNS

/datum/design/hammercm1
	name = "Hammer cm1"
	desc = "A hammer that destroys 1 cm of debris."
	id = "hammercm1"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/xenoarch/clean/hammer/cm1
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/hammercm2
	name = "Hammer cm2"
	desc = "A hammer that destroys 2 cm of debris."
	id = "hammercm2"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/xenoarch/clean/hammer/cm2
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/hammercm3
	name = "Hammer cm3"
	desc = "A hammer that destroys 3 cm of debris."
	id = "hammercm3"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/xenoarch/clean/hammer/cm3
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/hammercm4
	name = "Hammer cm4"
	desc = "A hammer that destroys 4 cm of debris."
	id = "hammercm4"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/xenoarch/clean/hammer/cm4
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/hammercm5
	name = "Hammer cm5"
	desc = "A hammer that destroys 5 cm of debris."
	id = "hammercm5"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/xenoarch/clean/hammer/cm5
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/hammercm6
	name = "Hammer cm6"
	desc = "A hammer that destroys 6 cm of debris."
	id = "hammercm6"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/xenoarch/clean/hammer/cm6
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/hammercm15
	name = "Hammer cm15"
	desc = "A hammer that destroys 15 cm of debris."
	id = "hammercm15"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/xenoarch/clean/hammer/cm15
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/hammercmadv
	name = "Advanced Hammer"
	desc = "A hammer that destroys up to 30 cm of debris."
	id = "hammercmadv"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 1500)
	build_path = /obj/item/xenoarch/clean/hammer/advanced
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/cleanbrush
	name = "Brush"
	desc = "A brush that cleans debris."
	id = "hammerbrush"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/xenoarch/clean/brush
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

// Designs for tools

/datum/design/xenoscanner
	name = "Mining Scanner"
	desc = "A tool that scans depths of rocks."
	id = "xenoscanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/xenoarch/help/scanner
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/advxenoscanner
	name = "Advanced Mining Scanner"
	desc = "A tool that scans depths of rocks."
	id = "advxenoscanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500, /datum/material/bluespace = 250)
	build_path = /obj/item/xenoarch/help/scanneradv
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/xenomeasure
	name = "Measuring Tape"
	desc = "A tool to measure the dug depth of rocks."
	id = "xenomeasure"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/xenoarch/help/measuring
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/xenoresearch
	name = "Fossil Researcher"
	desc = "A tool used to get research points from artifacts."
	id = "xenoresearch"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/xenoarch/help/research
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/xenoplant
	name = "Fossil Seed Extractor"
	desc = "A tool to extract the seeds from prehistoric fossils."
	id = "xenoplant"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/xenoarch/help/plant
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/advcargoscanner
	name = "Cargo Scanner"
	desc = "A tool used to sell items, virtually."
	id = "advcargoscanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500, /datum/material/bluespace = 500)
	build_path = /obj/item/xenoarch/help/cargo
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_CARGO

/datum/design/xenobelt
	name = "Xenoarchaeology Belt"
	desc = "A belt used to store some xenoarch tools."
	id = "xenobelt"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 1000)
	build_path = /obj/item/storage/belt/xenoarch
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE