/datum/bounty/testbounty
	name = "testing bounty"
	description = "woohoo my code works (maybe)"
	author = "whatever they name the supply corporation"
	category = BOUNTY_CATEGORY_TEST
	requirements = list(
		/datum/bounty_requirement = list(
			requirementname = "bikehorns",
			includedtypes = list(/obj/item/bikehorn),
			allowsubtypes = TRUE,
			requiredamount = 3),

		/datum/bounty_requirement/reagent = list(
			requirementname = "Water",
			includedreagents = list(/datum/reagent/water),
			requiredamount = 50)
		)

