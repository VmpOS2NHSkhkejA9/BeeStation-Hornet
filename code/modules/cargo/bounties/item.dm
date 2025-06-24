/datum/bounty/testbounty
	name = "testing bounty"
	description = "woohoo my code works (maybe)"
	author = "whatever they name the supply corporation"
	category = BOUNTY_CATEGORY_TEST
	wanted_types = list(
		/obj/item/bikehorn = 1,
		/obj/item/food/grown/banana = 1)

/datum/bounty/mechbounty
	name = "mech bounty"
	description = "get in the fucking robot shinji"
	author = "people who really need a mech for some reason"
	category = BOUNTY_CATEGORY_TEST
	wanted_types = list(
		/obj/vehicle/sealed/mecha/working/ripley = 1,
		/obj/item/mecha_parts/mecha_equipment/drill = 1,
		/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp = 1
	)

