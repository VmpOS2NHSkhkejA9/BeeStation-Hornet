/datum/market_category //holds price multipliers for price fluctuations and repeated sales/purchases affecting prices
	var/name = "Objects, Things and Entities"
	var/description = "The base category that you really shouldn't see."
	var/category_ID
	var/pricemult = 1 //base pricemult decided at the start of the round
	var/pricemult_offset = 0 //offset affected by sales
	var/price_normalization = 0.9975 //higher = returns to base price slower
	var/price_drift = 0
	var/last_price_drift_adjustment = -10 MINUTES

/datum/market_category/New()
	..()
	START_PROCESSING(SSprocessing, src)

/datum/market_category/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/market_category/process()
	pricemult_offset *= price_normalization
	if((world.time - last_price_drift_adjustment) > 10 MINUTES)
		var/new_price_drift = (0.01 * rand(-25,25))
		pricemult_offset += new_price_drift - price_drift
		price_drift = new_price_drift
		last_price_drift_adjustment = world.time

/datum/market_category/proc/get_modified_sell_price(var/baseprice)
	return baseprice * (pricemult + pricemult_offset) //this is simple enough, but having it as a proc means we can easily have special behaviour later on

/datum/market_category/proc/after_sale(var/datum/export/exporttype, amount)
	pricemult_offset -= (pricemult + pricemult_offset) * (1 - (exporttype.pricemult_per_sale ** amount))

//these are mostly meant to be per-department; to make it harder for a single department to rake in too much cash.

/datum/market_category/mining
	name = "Materials & Mining Goods"
	description = "Most installations on or around lavaland will buy materials, refined and unrefined, along with rare objects taken from slain fauna."
	category_ID = MARKET_CATEGORY_MINING

/datum/market_category/security
	name = "Peacekeeping & Combat Supplies"
	description = "Aiuri Private Security will always accept more weapons and armour for their armouries. Selling such items to anyone else is forbidden on SS13."
	category_ID = MARKET_CATEGORY_SECURITY

/datum/market_category/engineering
	name = "Engineering Equipment & Byproducts"
	description = "Exotic gases, mass-produced anomalies (preferably stabilized) and other safety hazards that come out of engineering are valuable to a wide number of corporations."
	category_ID = MARKET_CATEGORY_ENGINEERING

/datum/market_category/science
	name = "Research Materials"
	description = "Nanotrasen will pay a pretty penny for every export of the slime extracts and artifacts their research division pumps out, along with the rarer types of anomaly core that can't be produced by engineering."
	category_ID = MARKET_CATEGORY_SCIENCE

/datum/market_category/medical
	name = "Pharmaceutical Products"
	description = "Advanced chemical mixtures along with fresh organs and a reserve of blood are absolute necessities for any ship, station and base on or around lavaland."
	category_ID = MARKET_CATEGORY_MEDICAL

/datum/market_category/service
	name = "Culinary, Mixology & Botanical Produce"
	description = "Almost every single installation on and around lavaland imports food in some capacity, but the massive market also means that only selling vast quantities of, or very difficult to produce products will be worthwhile."
	category_ID = MARKET_CATEGORY_SERVICE

//the stuff cargo techs tend to scavenge for in maints
/datum/market_category/supply
	name = "Uncategorized Supplies"
	description = "Basic supplies produced by anyone and everyone and useful for a variety of reasons. Most commonly, bulk water and welding fuel."
	category_ID = MARKET_CATEGORY_MISC
