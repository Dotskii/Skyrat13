/obj/item/beacon
	var/code = "electronic"
	var/frequency = 1459

/obj/item/beacon/attack_self(mob/user as mob)
	..()
	var/newfreq = input(user, "Input a new frequency for the beacon", "Frequency", null) as num
	if(!newfreq)
		return
	frequency = format_frequency(sanitize_frequency(newfreq))

/obj/item/beacon/verb/alter_signal(t as text)
	set name = "Alter Beacon's Signal"
	set category = "Object"
	set src in usr

	if (!(usr.restrained()))
		src.code = t
	if (!(src.code))
		src.code = "beacon"
	src.add_fingerprint(usr)
	return
