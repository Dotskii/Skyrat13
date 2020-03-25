//Used to process and handle roundstart extra languages
//mostly copypasted off quirks code
PROCESSING_SUBSYSTEM_DEF(languages)
	name = "Languages"
	init_order = INIT_ORDER_LANGUAGES
	flags = SS_BACKGROUND
	wait = 10
	runlevels = RUNLEVEL_GAME

	var/list/languages = list()		//Assoc. list of all roundstart language datum types; "name" = /path/
	var/list/language_names_by_path = list()
	var/list/language_blacklist = list() //A list a list of languages that cannot be selected roundstart
	var/defaultvalue

/datum/controller/subsystem/processing/languages/Initialize(timeofday)
	if(!languages.len)
		language_blacklist = list(/datum/language/codespeak, /datum/language/drone, /datum/language/common, /datum/language/narsie, /datum/language/ratvar, /datum/language/swarmer, /datum/language/vampiric, /datum/language/xenocommon)
		SetupLanguages()
	return ..()

/datum/controller/subsystem/processing/languages/proc/SetupLanguages()
	var/list/language_list = subtypesof(/datum/language)
	for(var/V in language_list)
		var/datum/language/T = V
		if(!language_blacklist.Find(T))
			languages[initial(T.name)] = T
			language_names_by_path[T] = initial(T.name)

/datum/controller/subsystem/processing/languages/proc/AssignLanguages(mob/living/user, client/cli, spawn_effects, roundstart = FALSE, datum/job/job, silent = FALSE, mob/to_chat_target)
	var/list/my_languages = cli.prefs.language.Copy()
	if(!(my_languages.len > MAX_LANGUAGES))
		for(var/V in my_languages)
			var/datum/language/L = V
			if(L)
				if(!(L in language_blacklist))
					if(!user.grant_language(L))
						to_chat(user, "<span class='boldannounce'>Something went wrong and you couldn't be granted the [L] language. Huh.</span>")
				else
					to_chat(user, "<span class='boldannounce'>[L] couldn't be granted as it is a blacklisted language... how did you even do that?</span>")
	else
		to_chat(user, "<span class='boldannounce'>No languages will be granted, since your selected language list is somehow larger than the maximum amount of roundstart extra languages. How did you do that?</span>")

/datum/controller/subsystem/processing/languages/proc/language_path_by_name(name)
	return languages[name]

/datum/controller/subsystem/processing/languages/proc/language_name_by_path(path)
	return language_names_by_path[path]

/datum/controller/subsystem/processing/languages/proc/total_languages(list/language_names)
	. = 0
	for(var/i in language_names)
		var/datum/language/L = i
		if(L)
			.++