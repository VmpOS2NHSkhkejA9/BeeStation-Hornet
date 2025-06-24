/datum/export/grown
	cost = 5 // per plant, each plant bag containing 50. 250 per plant bag's worth by default.
	pricemult_per_sale = 0.999
	unit_name = "unit(s) of produce"
	export_types = list(/obj/item/food/grown)
	market_category_ID = MARKET_CATEGORY_SERVICE

/datum/export/grown/get_cost(obj/O)
	var/obj/item/food/grown/plant = O
	. = (..() + (plant.seed.rarity / 5)) * (plant.seed.potency / 100)

/datum/export/food
	cost = 100
	export_types = list(/obj/item/food)
	exclude_types = list(/obj/item/food/grown)
	market_category_ID = MARKET_CATEGORY_SERVICE

/datum/export/food/get_cost(obj/O)
	var/obj/item/food/food = O
	return max(..() * food.crafting_complexity, 50)


