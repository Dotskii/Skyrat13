/datum/techweb_node/integrated_HUDs/New()
	. = ..()
	design_ids += "mining_hud"
	design_ids += "mining_hud_prescription"
	design_ids += "fauna_hud"
	design_ids += "fauna_hud_prescription"

/datum/techweb_node/telecomms/New()
	. = ..()
	design_ids += "message-server"

/datum/techweb_node/computer_board_gaming/New()
	. = ..()
	design_ids += "tetris"
