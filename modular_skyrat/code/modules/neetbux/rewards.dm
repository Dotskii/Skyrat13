//the rewards themselves
/* shitposts for testing
/datum/neetbux_reward/thuxtk
	name = "MODO THUXTK"
	desc = "COMPRE PARA VIRAR THUXTK"
	buy_message = "VOCE AGORA E UM BOIOLA VIADO TRAVECO COM PENIS"
	id = "thuxtk"
	cost = 10

/datum/neetbux_reward/thuxtk/can_buy(client/neet, silent = FALSE, fail_message = "You don't have enough neetbux to buy NAME!")
	. = ..()
	if(.)
		if(!ishuman(neet.mob))
			to_chat(neet, "<span class='neetbux'>You need to be controlling a human mob to ATIVAR MODO THUXTK!</span>")
			return FALSE

/datum/neetbux_reward/thuxtk/on_buy(client/neet)
	. = ..()
	var/mob/living/carbon/human/H = neet.mob
	H.set_gender(FEMALE)
	var/obj/item/organ/genital/vagina/vagina = H.getorganslot(ORGAN_SLOT_VAGINA)
	if(vagina)
		qdel(vagina)
	var/obj/item/organ/genital/penis/penis = H.getorganslot(ORGAN_SLOT_PENIS)
	if(!penis)
		penis = new(H)
		penis.Insert(H)
	var/obj/item/organ/genital/testicles/testicles = H.getorganslot(ORGAN_SLOT_TESTICLES)
	if(!testicles)
		testicles = new(H)
		testicles.Insert(H)
	H.dna?.features["body_model"] = FEMALE
	H.name = "Yuri Tamashiro"
	H.real_name = "Yuri Tamashiro"

/datum/neetbux_reward/mayer_summer_car
	name = "CORTAR DE GIRO MAYER SUMMER CAR"
	desc = "CORTANDO DE GIRO NO MAYER SUMMER CAR"
	buy_message = "SE VOCE SABE TROCAR DE MARCHA NO MAYER SUMMER CAR DE LIKE FAVORITO"
	id = "mayersummercar"
	cost = 10

/datum/neetbux_reward/mayer_summer_car/on_buy(client/neet)
	. = ..()
	new /obj/vehicle/ridden/scooter(get_turf(neet.mob))
*/
