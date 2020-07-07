//skyrat edit beatbox
/**
  * scars are cosmetic datums that are assigned to bodyparts once they recover from wounds. Each wound type and severity have their own descriptions for what the scars
  * look like, and then each body part has a list of "specific locations" like your elbow or wrist or wherever the scar can appear, to make it more interesting than "right arm"
  *
  *
  * Arguments:
  * *
  */
/datum/scar
	var/obj/item/bodypart/limb
	var/mob/living/carbon/victim
	var/severity
	var/description
	var/precise_location

	/// Scars from the longtimer quirk are "fake" and won't be saved with persistent scarring, since it makes you spawn with a lot by default
	var/fake=FALSE

	/// How many tiles away someone can see this scar, goes up with severity. Clothes covering this limb will decrease visibility by 1 each, except for the head/face which is a binary "is mask obscuring face" check
	var/visibility = 2
	/// Whether this scar can actually be covered up by clothing
	var/coverable = TRUE
	/// What zones this scar can be applied to
	var/list/applicable_zones = ALL_BODYPARTS
	/// Can this scar be removed via normal means? Used for character setup cosmetic scars
	var/permanent = FALSE

/datum/scar/Destroy(force, ...)
	if(limb)
		LAZYREMOVE(limb.scars, src)
	if(victim)
		LAZYREMOVE(victim.all_scars, src)
	. = ..()

/**
  * generate() is used to actually fill out the info for a scar, according to the limb and wound it is provided.
  *
  * After creating a scar, call this on it while targeting the scarred bodypart with a given wound to apply the scar.
  *
  * Arguments:
  * * BP- The bodypart being targeted
  * * W- The wound being used to generate the severity and description info
  * * add_to_scars- Should always be TRUE unless you're just storing a scar for later usage, like how cuts want to store a scar for the highest severity of cut, rather than the severity when the wound is fully healed (probably demoted to moderate)
  */
/datum/scar/proc/generate(obj/item/bodypart/BP, datum/wound/W, add_to_scars=TRUE)
	if(!(BP.body_zone in applicable_zones) || BP.is_organic_limb())
		qdel(src)
		return
	limb = BP
	severity = W.severity
	if(limb.owner)
		victim = limb.owner
	if(add_to_scars)
		LAZYADD(limb.scars, src)
		if(victim)
			LAZYADD(victim.all_scars, src)

	description = pick(W.scarring_descriptions)
	precise_location = pick(limb.specific_locations)
	visibility = W.severity
	if(visibility == WOUND_SEVERITY_LOSS)
		precise_location = "amputation"

/datum/scar/proc/pref_apply(obj/item/bodypart/BP, specific_location, new_description, new_severity = 0, add_to_scars=TRUE)
	if(!(BP.body_zone in applicable_zones))
		qdel(src)
		return
	limb = BP
	severity = new_severity
	if(limb.owner)
		victim = limb.owner
	if(add_to_scars)
		LAZYADD(limb.scars, src)
		if(victim)
			LAZYADD(victim.all_scars, src)

	description = new_description
	precise_location = specific_location
	switch(severity)
		if(WOUND_SEVERITY_MODERATE)
			visibility = 2
		if(WOUND_SEVERITY_SEVERE)
			visibility = 3
		if(WOUND_SEVERITY_CRITICAL)
			visibility = 5

/// Used when we finalize a scar from a healing cut
/datum/scar/proc/lazy_attach(obj/item/bodypart/BP, datum/wound/W)
	LAZYADD(BP.scars, src)
	if(BP.owner)
		victim = BP.owner
		LAZYADD(victim.all_scars, src)

/// Used to "load" a persistent scar
/datum/scar/proc/load(obj/item/bodypart/BP, version, description, specific_location, severity=WOUND_SEVERITY_SEVERE)
	if(!(BP.body_zone in applicable_zones) || !BP.is_organic_limb())
		qdel(src)
		return
	
	limb = BP
	src.severity = severity
	LAZYADD(limb.scars, src)
	if(BP.owner)
		victim = BP.owner
		LAZYADD(victim.all_scars, src)
	src.description = description
	precise_location = specific_location
	switch(severity)
		if(WOUND_SEVERITY_MODERATE)
			visibility = 2
		if(WOUND_SEVERITY_SEVERE)
			visibility = 3
		if(WOUND_SEVERITY_CRITICAL)
			visibility = 5
		if(WOUND_SEVERITY_LOSS)
			visibility = 7
	return TRUE

/// What will show up in examine_more() if this scar is visible
/datum/scar/proc/get_examine_description(mob/viewer)
	if(!victim || !is_visible(viewer))
		return

	var/msg = "[victim.p_they(TRUE)] [victim.p_have()] [description] on [victim.p_their()] [precise_location]."
	switch(severity)
		if(WOUND_SEVERITY_MODERATE)
			msg = "<span class='tinynotice'><i>[msg]</i></span>"
		if(WOUND_SEVERITY_SEVERE)
			msg = "<span class='smallnotice'><i>[msg]</i></span>"
		if(WOUND_SEVERITY_CRITICAL to WOUND_SEVERITY_PERMANENT)
			msg = "<span class='smallnotice'><b><i>[msg]</i></b></span>"
		if(WOUND_SEVERITY_LOSS)
			msg = "[victim.p_their(TRUE)] [limb.name] [description]." // different format
			msg = "<span class='notice'><i><b>[msg]</b></i></span>"
	return "\t[msg]"

/// Whether a scar can currently be seen by the viewer
/datum/scar/proc/is_visible(mob/viewer)
	if(!victim || !viewer || !limb)
		return FALSE

	if(!ishuman(victim) || isobserver(viewer) || victim == viewer)
		return TRUE

	var/mob/living/carbon/human/H = victim
	if(istype(limb, /obj/item/bodypart/head))
		if((H.wear_mask && (H.wear_mask.flags_inv & HIDEFACE)) || (H.head && (H.head.flags_inv & HIDEFACE)))
			return FALSE
	
	else if(limb.scars_covered_by_clothes && H.clothingonpart(limb))
		return FALSE

	return TRUE

/// Used to format a scar to save in preferences for persistent scars
/datum/scar/proc/format()
	if(!fake)
		return "[SCAR_CURRENT_VERSION]|[limb.body_zone]|[description]|[precise_location]|[severity]"

/// Used to format a scar to safe in preferences for persistent scars
/datum/scar/proc/format_amputated(body_zone)
	description = pick(list("is several skintone shades paler than the rest of the body", "is a gruesome patchwork of artificial flesh", "has a large series of attachment scars at the articulation points"))
	return "[SCAR_CURRENT_VERSION]|[body_zone]|[description]|amputated|[WOUND_SEVERITY_LOSS]"
