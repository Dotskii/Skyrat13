/turf/closed/mineral
	var/datum/geosample/geologic_data
	var/excavation_level = 0
	var/list/finds = list()
	var/archaeo_overlay = ""
	var/excav_overlay = ""
	var/obj/item/weapon/last_find
	var/datum/artifact_find/artifact_find
	var/busy = 0 //Used for a bunch of do_after actions, because we can walk into the rock to trigger them
	var/no_finds = 0
	var/rockernaut = NONE
