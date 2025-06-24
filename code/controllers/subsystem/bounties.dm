#define NATURAL_BOUNTY_COUNT 5 //bounties will be replenished over time until this many available bounties exist
#define ROUNDSTART_BOUNTY_COUNT 8 //start with more bounties than usual, let cargo pick some off the bat

SUBSYSTEM_DEF(bounties)
	name = "Bounties"
	//check every so often if we want to top up the available bounties
	wait = 1 MINUTES
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	var/list/datum/bounty/available_bounties = list() //not accepted and still valid
	var/list/datum/bounty/accepted_bounties = list() //in progress
	var/list/datum/bounty/archived_bounties = list() //accepted and then completed (or failed)
	var/list/datum/bounty/weights = list()
	var/list/categorized_bounties = list() //key as a string corresponding to a category, value is a list of bounties that fall under that category
	var/reputation //background number that controls the chances for rewards or punishments for completing/failing contracts

//set up the lists used for picking bounties and then actually pick some
/datum/controller/subsystem/bounties/Initialize()
	to_chat(world, "there are [LAZYLEN(typesof(/datum/bounty))] subtypes of /datum/bounty")
	for(var/type in typesof(/datum/bounty)) //for reasons beyond me for(var/datum/bounty/bounty in typesof(/datum/bounty)) simply does not work
		var/datum/bounty/bounty = type
		if(!bounty || !bounty.name || !bounty.category) //no name = basetype. bounties with no category are also excluded.
			continue
		to_chat(world, "iterated over [bounty.name]")
		if(!categorized_bounties[bounty.category])
			categorized_bounties[bounty.category] = list()
		categorized_bounties[bounty.category] += bounty

	to_chat(world, "------------------- WEIGHTS -----------------")
	for(var/category in categorized_bounties)
		weights[category] = 10
		to_chat(world, "[category]: [10]")


	to_chat(world, "--- SELECTED ROUNDSTART BOUNTIES ---")
	for(var/n = 1 to ROUNDSTART_BOUNTY_COUNT)
		var/datum/bounty/selected_bounty = pick_weighted_bounty()
		selected_bounty = new selected_bounty
		selected_bounty.expiration_time += rand(0, 5 MINUTES) //"slightly" randomize the times so that they don't all expire at the same time
		available_bounties += selected_bounty

	if(!LAZYLEN(available_bounties))
		return SS_INIT_FAILURE //something went wrong and we could not pick a single bounty

	for(var/datum/bounty/bounty in available_bounties)
		to_chat(world, bounty.name)

	return SS_INIT_SUCCESS

/datum/controller/subsystem/bounties/fire()
	if(!(LAZYLEN(available_bounties) < NATURAL_BOUNTY_COUNT))
		return
	var/datum/bounty/selected_bounty = pick_weighted_bounty()
	selected_bounty = new selected_bounty
	selected_bounty.expiration_time += rand(0, 1 MINUTES) //slightly randomize the times so that they don't all show the exact same number of seconds remaining
	available_bounties += selected_bounty

/datum/controller/subsystem/bounties/Recover()
	categorized_bounties = SSbounties.categorized_bounties
	available_bounties = SSbounties.available_bounties
	accepted_bounties = SSbounties.accepted_bounties
	archived_bounties = SSbounties.archived_bounties
	weights = SSbounties.weights
	reputation = SSbounties.reputation

/datum/controller/subsystem/bounties/proc/pick_weighted_bounty()
	if(!LAZYLEN(weights))
		return FALSE
	. = pick_weight(weights) //this picks a *category* for the bounty
	for(var/datum/bounty/weight_to_modify in weights)
		weights[weight_to_modify] += 5
	weights[.] = 0
	. = pick(categorized_bounties[.])

#undef NATURAL_BOUNTY_COUNT
#undef ROUNDSTART_BOUNTY_COUNT
