/datum/bounty/testbounty
	name = "testing bounty"
	description = "woohoo my code works (maybe)"
	author = "whatever they name the supply corporation"
	category = BOUNTY_CATEGORY_TEST
	requirements = list(
		list(
			requirementtype = /datum/bounty_requirement,
			requirementname = "bikehorns",
			includedtypes = list(/obj/item/bikehorn),
			allowsubtypes = TRUE,
			requiredamount = 3))

/datum/bounty/random/rngtestbounty
	name = "randomized testing bounty"
	description = "woohoo my code works (maybe)"
	author = "whatever they name the supply corporation"
	category = BOUNTY_CATEGORY_TEST
	total_required_min = 10
	total_required_max = 30
	different_types_min = 1
	different_types_max = 4
	possible_types = list(
			/obj/item/food/grown/banana,
			/obj/item/food/grown/apple,
			/obj/item/food/grown/watermelon,
			/datum/reagent/water
	)
	possible_descriptions = list(
		"we need to randomize the code",
		"we need to randomize the description",
		"we need to randomize the bounty",
	)
	distribution_factor = 2 //higher values tend more towards one type making up the bulk of the wanted types
	reagent_quantity_mult = 5 //multiply required amounts of reagents by this AFTER all other required amount calculations


