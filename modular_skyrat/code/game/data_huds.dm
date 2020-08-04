//Fauna health hud. We don't actually check for sensors, we just check if the mob is a simple animal.
/datum/atom_hud/data/human/medical/basic/fauna/check_sensors(mob/living/carbon/human/H)
	var/mob/living/simple_animal/animal_mob = H
	if(istype(animal_mob))
		return 1
	return 0
