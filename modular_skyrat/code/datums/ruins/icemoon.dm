// Hey! Listen! Update \config\iceruinblacklist.txt with your new ruins!

/datum/map_template/ruin/icemoon
	prefix = "_maps/RandomRuins/IceRuins/"
	allow_duplicates = FALSE

// above ground only

/datum/map_template/ruin/icemoon/puzzle
	name = "Ancient Puzzle"
	id = "puzzle"
	description = "Mystery to be solved."
	suffix = "icemoon_surface_puzzle.dmm"
	cost = 5

// above and below ground together

/datum/map_template/ruin/icemoon/mining_site
	name = "Mining Site"
	id = "miningsite"
	description = "Ruins of a site where people once mined with primitive tools for ore."
	suffix = "icemoon_surface_mining_site.dmm"
	cost = 10

/datum/map_template/ruin/icemoon/underground/mining_site_below
	name = "Mining Site Underground"
	id = "miningsite-underground"
	description = "Who knew ladders could be so useful?"
	suffix = "icemoon_underground_mining_site.dmm"
	cost = 10

// below ground only

/datum/map_template/ruin/icemoon/underground
	name = "underground ruin"

/datum/map_template/ruin/icemoon/underground/abandonedvillage
	name = "Abandoned Village"
	id = "abandonedvillage"
	description = "Who knows what lies within?"
	suffix = "icemoon_underground_abandoned_village.dmm"
	cost = 5