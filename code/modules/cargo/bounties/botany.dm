/datum/bounty/random/botany
	category = BOUNTY_CATEGORY_SERVICE

/datum/bounty/random/botany/bulk //lots of simple produce
	name = "Bulk Produce"
	author = "aiuri's #1 muncher"
	total_required_min = 50 //this is very little
	total_required_min = 500
	different_types_min = 1
	different_types_max = 5
	distribution_factor = 2
	possible_descriptions = list(
		"description 1",
		"description 2",
		"description 3"
	)
	possible_types = list(
		/obj/item/food/grown/wheat,
		/obj/item/food/grown/tomato,
		/obj/item/food/grown/potato,
		/obj/item/food/grown/banana,
		/obj/item/food/grown/chili,
		/obj/item/food/grown/garlic,
		/obj/item/food/grown/berries
	)



