//i dont know what classifies a cargo thing as special.
/datum/supply_pack/security/armory/usp
	name = "USP pistol Crate"
	desc = "Why are 9mm guns still a thing? Well, you can still get them anyways."
	cost = 4500
	contains = list(/obj/item/gun/ballistic/automatic/pistol/uspm,
					/obj/item/gun/ballistic/automatic/pistol/uspm,
					/obj/item/gun/ballistic/automatic/pistol/uspm,
					/obj/item/ammo_box/magazine/usp,
					/obj/item/ammo_box/magazine/usp,
					/obj/item/ammo_box/magazine/usp)
	crate_name = "USP pistols crate"

/datum/supply_pack/security/armory/combine
	name = "Civil Protection Crate"
	desc = "With this crate, you'll never deadline on the frontlines. Contains full Civil Protection clothing (including hardsuit), a stun baton and an USP pistol with spare magazines."
	cost = 8000
	contains = list(/obj/item/clothing/under/rank/security/civilprotection,
					/obj/item/clothing/head/helmet/cphood,
					/obj/item/gun/ballistic/automatic/pistol/uspm,
					/obj/item/clothing/suit/armor/vest/cparmor,
					/obj/item/clothing/mask/gas/sechailer/cpmask,
					/obj/item/ammo_box/magazine/usp,
					/obj/item/ammo_box/magazine/usp,
					/obj/item/melee/baton,
					/obj/item/clothing/suit/space/hardsuit/security/metrocop)
	crate_name = "metrocop crate"