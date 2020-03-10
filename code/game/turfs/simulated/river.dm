#define RANDOM_UPPER_X 200
#define RANDOM_UPPER_Y 200

#define RANDOM_LOWER_X 50
#define RANDOM_LOWER_Y 50

#define RIVERGEN_SAFETY_LOCK 1000000

/proc/spawn_rivers(target_z, nodes = 4, turf_type = /turf/open/lava/smooth/lava_land_surface, whitelist_area = /area/lavaland/surface/outdoors/unexplored, min_x = RANDOM_LOWER_X, min_y = RANDOM_LOWER_Y, max_x = RANDOM_UPPER_X, max_y = RANDOM_UPPER_Y, new_baseturfs)
	var/list/river_nodes = list()
	var/num_spawned = 0
	var/list/possible_locs = block(locate(min_x, min_y, target_z), locate(max_x, max_y, target_z))
	var/safety = 0
	while(num_spawned < nodes && possible_locs.len && (safety++ < RIVERGEN_SAFETY_LOCK))
		var/turf/T = pick(possible_locs)
		var/area/A = get_area(T)
		if(!istype(A, whitelist_area) || (T.flags_1 & NO_LAVA_GEN_1))
			possible_locs -= T
		else
			river_nodes += new /obj/effect/landmark/river_waypoint(T)
			num_spawned++

	safety = 0
	//make some randomly pathing rivers
	for(var/A in river_nodes)
		var/obj/effect/landmark/river_waypoint/W = A
		if (W.z != target_z || W.connected)
			continue
		W.connected = 1
		var/turf/cur_turf = get_turf(W)
		cur_turf.ChangeTurf(turf_type, new_baseturfs, CHANGETURF_IGNORE_AIR)
		var/turf/target_turf = get_turf(pick(river_nodes - W))
		if(!target_turf)
			break
		var/detouring = 0
		var/cur_dir = get_dir(cur_turf, target_turf)
		while(cur_turf != target_turf && (safety++ < RIVERGEN_SAFETY_LOCK))

			if(detouring) //randomly snake around a bit
				if(prob(20))
					detouring = 0
					cur_dir = get_dir(cur_turf, target_turf)
			else if(prob(20))
				detouring = 1
				if(prob(50))
					cur_dir = turn(cur_dir, 45)
				else
					cur_dir = turn(cur_dir, -45)
			else
				cur_dir = get_dir(cur_turf, target_turf)

			cur_turf = get_step(cur_turf, cur_dir)
			var/area/new_area = get_area(cur_turf)
			if(!istype(new_area, whitelist_area) || (cur_turf.flags_1 & NO_LAVA_GEN_1)) //Rivers will skip ruins
				detouring = 0
				cur_dir = get_dir(cur_turf, target_turf)
				cur_turf = get_step(cur_turf, cur_dir)
				continue
			else
				var/turf/river_turf = cur_turf.ChangeTurf(turf_type, new_baseturfs, CHANGETURF_IGNORE_AIR)
				river_turf.Spread(25, 11, whitelist_area)

	for(var/WP in river_nodes)
		qdel(WP)

/proc/spawn_empty_spaces(target_z, turf_type = /turf/open/floor/plating/asteroid/snow, whitelist_area = /area/icemoon/surface) //currently no idea how the fuck this would work. Leaving here for now.
	return


/proc/spawn_bridges(var/list/L, turf_type = /turf/open/floor/wood, whitelist_area = /area/icemoon/surface)
	if(!L)
		return
	for(var/obj/effect/landmark/bridgecreator/B in L) //we do this thing for every single landmark
		var/obj/effect/landmark/bridgecreator/first = B
		var/list/otherlandmarks = list()
		var/list/all_landmarks = list()
		for(var/turf/T in L)
			for(var/obj/effect/landmark/bridgecreator/fuckyou in T)
				if(fuckyou != B)
					all_landmarks += fuckyou
		for(var/obj/effect/landmark/bridgecreator/other in all_landmarks) // i'm not adding checks to see if the landmark is already bridged because it probably won't cause problems. you can write this in my grave.
			if(other)
				var/smart = 1 // is it smart to make a bridge on this line?
				for(var/area/cumzone in getline(first, other))
					if(!istype(cumzone, whitelist_area)) // you are not welcum
						smart = 0
				if(smart)
					otherlandmarks[other] = get_dist(first, other)
			else
				return FALSE //something went wrong, most probably there is only one landmark on the level.
		var/obj/effect/landmark/bridgecreator/last = min(otherlandmarks)
		if(last) //confirms that we do have a "smart" bridge and are not fucked
			var/bridgedir = get_dir(first, last) // we get the direction this dumb thing goes, you'll see why later
			for(var/turf/T in getline(first, last))
				if(T.loc != whitelist_area || (first in T.contents) || (last in T.contents)) // fuck we hit a ruin or something (not supposed to happen) this is bad and not very good. Or this is where the landmark is.
					continue
				T.TerraformTurf(turf_type, turf_type)
				var/turf/T2 = get_step(T, turn(bridgedir, 90)) // there it is
				var/turf/T3 = get_step(T, turn(bridgedir, -90)) // we get the two tiles to it's "left" and "right" and terraform then too. this is needed otherwise diagonal bridges would be just for show.
				T2.TerraformTurf(turf_type, turf_type)
				T3.TerraformTurf(turf_type, turf_type)
		else //we don't have the smartbridge(tm), abort.
			return

/obj/effect/landmark/river_waypoint
	name = "river waypoint"
	var/connected = 0
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/landmark/empty_space // empty as in, no minerals
	name = "empty space"
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/landmark/bridgecreator //wayponts for bridges or whatever yeah
	name = "bridge creator"
	invisibility = INVISIBILITY_ABSTRACT

/turf/proc/Spread(probability = 30, prob_loss = 25, whitelisted_area)
	if(probability <= 0)
		return
	var/list/cardinal_turfs = list()
	var/list/diagonal_turfs = list()
	var/logged_turf_type
	for(var/F in RANGE_TURFS(1, src) - src)
		var/turf/T = F
		var/area/new_area = get_area(T)
		if(!T || (T.density && !ismineralturf(T)) || istype(T, /turf/open/indestructible) || (whitelisted_area && !istype(new_area, whitelisted_area)) || (T.flags_1 & NO_LAVA_GEN_1) )
			continue

		if(!logged_turf_type && ismineralturf(T))
			var/turf/closed/mineral/M = T
			logged_turf_type = M.turf_type

		if(get_dir(src, F) in GLOB.cardinals)
			cardinal_turfs += F
		else
			diagonal_turfs += F

	for(var/F in cardinal_turfs) //cardinal turfs are always changed but don't always spread
		var/turf/T = F
		if(!istype(T, logged_turf_type) && T.ChangeTurf(type, baseturfs, CHANGETURF_IGNORE_AIR) && prob(probability))
			T.Spread(probability - prob_loss, prob_loss, whitelisted_area)

	for(var/F in diagonal_turfs) //diagonal turfs only sometimes change, but will always spread if changed
		var/turf/T = F
		if(!istype(T, logged_turf_type) && prob(probability) && T.ChangeTurf(type, baseturfs, CHANGETURF_IGNORE_AIR))
			T.Spread(probability - prob_loss, prob_loss, whitelisted_area)
		else if(ismineralturf(T))
			var/turf/closed/mineral/M = T
			M.ChangeTurf(M.turf_type, M.baseturfs, CHANGETURF_IGNORE_AIR)


#undef RANDOM_UPPER_X
#undef RANDOM_UPPER_Y

#undef RANDOM_LOWER_X
#undef RANDOM_LOWER_Y
