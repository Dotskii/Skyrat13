//entire file is a skyrat edit
#define WOUND_DAMAGE_EXPONENT	1.4

#define WOUND_MINIMUM_DAMAGE		5 // an attack must do this much damage after armor in order to roll for being a wound (incremental pressure damage need not apply)
#define DISMEMBER_MINIMUM_DAMAGE	10 // an attack must do this much damage after armor in order to be eliigible to dismember a suitably mushed bodypart

#define WOUND_SEVERITY_NONE		0
#define WOUND_SEVERITY_TRIVIAL	1 // for jokey/meme wounds like stubbed toe, no standard messages/sounds or second winds
#define WOUND_SEVERITY_MODERATE	2
#define WOUND_SEVERITY_SEVERE	3
#define WOUND_SEVERITY_CRITICAL	4
#define WOUND_SEVERITY_LOSS		5 // theoretical total limb loss, like dismemberment for cuts
#define WOUND_SEVERITY_PERMANENT 6 // for wounds, severe or not, that cannot be removed via normal means (e.g just amputate the limb affected)

#define WOUND_BLUNT 0 // any brute weapon/attack that doesn't have sharpness. rolls for blunt bone wounds
#define WOUND_SLASH 1 // any brute weapon/attack with sharpness = SHARP_EDGED. rolls for slash wounds
#define WOUND_PIERCE 2 // any brute weapon/attack with sharpness = SHARP_POINTY. rolls for piercing wounds
#define WOUND_BURN	4 // any concentrated burn attack (lasers really). rolls for burning wounds

// the ones below will be implemented in the future, but dont exist atm
#define WOUND_TOXIN 3
#define WOUND_RADIATION 4 //arguably could just use the cellular wound thing, but i'm an asshole and want cancer/tumors to be a separate thing
#define WOUND_CELLULAR 5
#define WOUND_STAMINA 6
#define WOUND_ORGAN 7

// How much determination reagent to add each time someone gains a new wound in [/datum/wound/proc/second_wind()]
#define WOUND_DETERMINATION_MODERATE	1
#define WOUND_DETERMINATION_SEVERE		2.5
#define WOUND_DETERMINATION_CRITICAL	5
#define WOUND_DETERMINATION_PERMANENT	7.5
#define WOUND_DETERMINATION_LOSS		10

#define WOUND_DETERMINATION_MAX			10 // the max amount of determination you can have

// set wound_bonus on an item or attack to this to disable checking wounding for the attack
#define CANT_WOUND -100

// list in order of highest severity to lowest
#define WOUND_LIST_MECHANICAL list(/datum/wound/mechanical)
#define WOUND_LIST_BLUNT		list(/datum/wound/blunt/critical, /datum/wound/blunt/severe, /datum/wound/blunt/moderate/ribcage, /datum/wound/blunt/moderate/hips, /datum/wound/blunt/moderate)
#define WOUND_LIST_BLUNT_MECHANICAL list(/datum/wound/mechanical/blunt/critical, /datum/wound/mechanical/blunt/severe, /datum/wound/mechanical/blunt/moderate)
#define WOUND_LIST_SLASH		list(/datum/wound/slash/critical, /datum/wound/slash/severe, /datum/wound/slash/moderate)
#define WOUND_LIST_SLASH_MECHANICAL		list(/datum/wound/mechanical/slash/critical, /datum/wound/mechanical/slash/severe, /datum/wound/mechanical/slash/moderate)
#define WOUND_LIST_LOSS			list(/datum/wound/loss, /datum/wound/slash/loss)
#define WOUND_LIST_PIERCE		list(/datum/wound/pierce/critical, /datum/wound/pierce/severe, /datum/wound/pierce/moderate)
#define WOUND_LIST_PIERCE_MECHANICAL		list(/datum/wound/mechanical/pierce/critical, /datum/wound/mechanical/pierce/severe, /datum/wound/mechanical/pierce/moderate)
#define WOUND_LIST_BURN		list(/datum/wound/burn/critical, /datum/wound/burn/severe, /datum/wound/burn/moderate)
#define WOUND_LIST_BURN_MECHANICAL		list(/datum/wound/mechanical/burn/critical, /datum/wound/mechanical/burn/severe, /datum/wound/mechanical/burn/moderate)

// Thresholds for infection for burn wounds, once infestation hits each threshold, things get steadily worse
#define WOUND_INFECTION_MODERATE	4 // below this has no ill effects from infection
#define WOUND_INFECTION_SEVERE		8 // then below here, you ooze some pus and suffer minor tox damage, but nothing serious
#define WOUND_INFECTION_CRITICAL	12 // then below here, your limb occasionally locks up from damage and infection and briefly becomes disabled. Things are getting really bad
#define WOUND_INFECTION_SEPTIC		20 // below here, your skin is almost entirely falling off and your limb locks up more frequently. You are within a stone's throw of septic paralysis and losing the limb
// above WOUND_INFECTION_SEPTIC, your limb is completely putrid and you start rolling to lose the entire limb by way of paralyzation. After 3 failed rolls (~4-5% each probably), the limb is paralyzed

#define WOUND_BURN_SANITIZATION_RATE 0.15 // how quickly sanitization removes infestation and decays per tick
#define WOUND_SLASH_MAX_BLOODFLOW		8 // how much blood you can lose per tick per slash max. 8 is a LOT of blood for one cut so don't worry about hitting it easily
#define WOUND_PIERCE_MAX_BLOODFLOW		8 // same as above, but for piercing wounds
#define WOUND_SLASH_DEAD_CLOT_MIN		0.05 // dead people don't bleed, but they can clot! this is the minimum amount of clotting per tick on dead people, so even critical cuts will slowly clot in dead people
#define WOUND_PIERCE_DEAD_CLOT_MIN		0.05 // same as above but for piercing wounds
#define WOUND_BONE_HEAD_TIME_VARIANCE 	20 // if we suffer a bone wound to the head that creates brain traumas, the timer for the trauma cycle is +/- by this percent (0-100)

// The following are for persistent scar save formats
// Do note that cosmetic scars don't use this format.
#define SCAR_SAVE_VERS				1 // The version number of the scar we're saving
#define SCAR_SAVE_ZONE				2 // The body_zone we're applying to on granting
#define SCAR_SAVE_DESC				3 // The description we're loading
#define SCAR_SAVE_PRECISE_LOCATION	4 // The precise location we're loading
#define SCAR_SAVE_SEVERITY			5 // The severity the scar had

// increment this number when you update the persistent scarring format in a way that invalidates previous saved scars (new fields, reordering, etc)
// saved scars with a version lower than this will be discarded
#define SCAR_CURRENT_VERSION				1

// General dismemberment now requires 3 things for a limb to be dismemberable:
//	1. Skin is mangled: At least a moderate slash or pierce wound
// 	2. Muscle is mangled: A critical slash or pierce wound
// 	3. Bone is mangled: At least a severe bone wound on that limb
// see [/obj/item/bodypart/proc/get_mangled_state()] for more information
#define BODYPART_MANGLED_NONE	0
#define BODYPART_MANGLED_SKIN	(1<<1)
#define BODYPART_MANGLED_MUSCLE (1<<2)
#define BODYPART_MANGLED_BONE	(1<<3)
#define BODYPART_MANGLED_BOTH (BODYPART_MANGLED_SKIN | BODYPART_MANGLED_MUSCLE | BODYPART_MANGLED_BONE)
