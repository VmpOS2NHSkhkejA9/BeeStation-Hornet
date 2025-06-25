/datum/bounty
	var/name
	var/author //just a fluff string
	var/description
	var/reward = 1000 // In credits. Modified by a bunch of outside variables, so this is not the real amount of credits awarded.
	var/high_priority = FALSE
	var/category = BOUNTY_CATEGORY_TEST
	var/status = BOUNTY_STATUS_AVAILABLE
	var/expiration_time = 5 MINUTES //expiration time when unaccepted
	var/expiration_time_accepted = 20 MINUTES //this much time is added as a bonus when accepted
	var/list/datum/bounty_requirement/requirements = list() //formatted as the requirement datum as key, and a list of args to create that datum with as value

/datum/bounty/New()
	expiration_time += world.time

	to_chat(world, "[name] has [LAZYLEN(requirements)] requirements")
	var/list/datum/bounty_requirement/requirements_created = list()
	for(var/req in requirements)
		var/datum/bounty_requirement/requirement = req
		requirements_created += new requirement(arglist(requirements[requirement]))
		to_chat(world, "created [requirement]")
	requirements = requirements_created

	START_PROCESSING(SSprocessing, src)

/datum/bounty/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/datum/bounty/process(delta_time)
	if(expiration_time > world.time)
		return TRUE
	switch(status)
		if(BOUNTY_STATUS_AVAILABLE)
			SSbounties.available_bounties -= src
			qdel(src) //unaccepted bounties go straight to the bin
		if(BOUNTY_STATUS_ACTIVE)
			SSbounties.accepted_bounties -= src
			SSbounties.archived_bounties += src
			status = BOUNTY_STATUS_FAILED
			archive() //your failure will be remembered

/datum/bounty/proc/archive()
	STOP_PROCESSING(SSprocessing, src)

/datum/bounty/proc/accept()
	expiration_time += expiration_time_accepted
	SSbounties.available_bounties -= src
	SSbounties.accepted_bounties += src
	status = BOUNTY_STATUS_ACTIVE

// Displayed on bounty UI screen.
/datum/bounty/proc/completion_string()
	for(var/datum/bounty_requirement/requirement in requirements)
		. += requirement.completion_string()


/datum/bounty/proc/try_ship(atom/movable/thing, dry_run=FALSE)
	for(var/datum/bounty_requirement/requirement in requirements)
		if(requirement.applies_to(thing))
			if(!dry_run)
				requirement.ship(thing)
			return TRUE
	return FALSE

/datum/bounty/proc/can_claim()
	if(!((status == BOUNTY_STATUS_ACTIVE) && (src in SSbounties.accepted_bounties) && (world.time < expiration_time)))
		return FALSE
	. = TRUE
	for(var/datum/bounty_requirement/requirement in requirements)
		if(requirement.check_completion())
			continue
		. = FALSE
		break

// Called when the claim button is clicked. Override to provide fancy rewards.
/datum/bounty/proc/claim()
	if(can_claim())
		SSeconomy.distribute_funds(reward * SSeconomy.bounty_modifier)
		status = BOUNTY_STATUS_COMPLETED
		SSbounties.accepted_bounties -= src
		SSbounties.archived_bounties += src

/datum/bounty/proc/applies_to(atom/movable/thing)
	. = FALSE
	for(var/datum/bounty_requirement/requirement in requirements)
		if(requirement.applies_to(thing))
			return TRUE

// When randomly generating the bounty list, duplicate bounties must be avoided.
// This proc is used to determine if two bounties are duplicates, or incompatible in general.
/datum/bounty/proc/compatible_with(datum/other_bounty)
	return type != other_bounty.type

/datum/bounty/proc/mark_high_priority(scale_reward = 2)
	if(high_priority)
		return
	high_priority = TRUE
	reward = round(reward * scale_reward)

// This proc is called when the shuttle docks at CentCom.
// It handles items shipped for bounties.
/proc/bounty_ship_item_and_contents(atom/movable/AM, dry_run=FALSE)

	var/list/matched_bounties = list()
	for(var/thing in reverse_range(AM.GetAllContents()))
		var/matched_this = FALSE
		for(var/datum/bounty/B in SSbounties.accepted_bounties)
			if(B.try_ship(thing, dry_run))
				matched_bounties += B
				matched_this = TRUE
		if(!dry_run && matched_this)
			qdel(thing)
	return matched_bounties

/proc/completed_bounty_count()
	var/count = 0
	for(var/i in SSbounties.archived_bounties)
		var/datum/bounty/B = i
		if(B.status == BOUNTY_STATUS_COMPLETED)
			++count
	return count

//this only has functionality for /atom/movable, but subtypes can easily be added that check for reagents or other special criteria
/datum/bounty_requirement
	var/name
	var/list/wanted_types = list()
	var/list/wanted_types_cache = list()
	var/list/exclude_types = list()
	var/include_subtypes = TRUE
	var/required_amount = 1
	var/shipped_amount = 0

/datum/bounty_requirement/New(requirementname = "", includedtypes = list(), excludedtypes = list(), allowsubtypes = TRUE, requiredamount = 1)
	name = requirementname
	wanted_types = includedtypes
	wanted_types_cache = typecacheof(includedtypes)
	exclude_types = typecacheof(excludedtypes)
	include_subtypes = allowsubtypes
	required_amount = requiredamount

/datum/bounty_requirement/proc/applies_to(atom/movable/thing)
	if(!(shipped_amount < required_amount) || !thing || !wanted_types_cache[thing.type] || exclude_types[thing.type])
		return FALSE
	if(!include_subtypes && !(thing.type in wanted_types))
		return FALSE
	if(thing.flags_1 & HOLOGRAM_1)
		return FALSE
	return TRUE

// this is only called if applies_to was already checked, so we can assume it's our desired obj
/datum/bounty_requirement/proc/ship(atom/movable/thing)
	var/amount = 1
	if(istype(thing, /obj/item/stack))
		var/obj/item/stack/shipped_stack = thing
		amount = shipped_stack.amount
	shipped_amount += amount

// Displayed on bounty UI screen.
/datum/bounty_requirement/proc/completion_string()
	. = {"\[[shipped_amount]/[required_amount]\] [capitalize(name)] \n"}

/datum/bounty_requirement/proc/check_completion()
	return shipped_amount >= required_amount

/datum/bounty_requirement/reagent
	wanted_types = list(/obj/item/reagent_containers)
	var/wanted_reagents = list()

/datum/bounty_requirement/reagent/New(requirementname = "", includedtypes = list(/obj/item/reagent_containers), excludedtypes = list(), allowsubtypes = TRUE, requiredamount = 1, includedreagents = list())
	. = ..()
	wanted_reagents = includedreagents

/datum/bounty_requirement/reagent/applies_to(atom/movable/thing)
	if(!..())
		return FALSE
	for(var/r in thing?.reagents?.reagent_list)
		var/datum/reagent/reagent = r
		if(reagent.type in wanted_reagents)
			return TRUE
	return FALSE

/datum/bounty_requirement/reagent/ship(atom/movable/thing)
	for(var/r in thing?.reagents?.reagent_list)
		var/datum/reagent/reagent = r
		if(reagent.type in wanted_reagents)
			shipped_amount += reagent.volume
	return TRUE
/*
//another base type with a bunch of functionality to generate random bounties; the power of RNG will bring us variety
/datum/bounty/random
	var/total_required_min
	var/total_required_max
	var/different_types_min
	var/different_types_max
	var/list/possible_types = list()
	var/list/possible_descriptions = list()
	var/distribution_factor = 1 //higher values tend more towards one type making up the bulk of the wanted types

/datum/bounty/random/New()

	var/types_total = rand(different_types_min, different_types_max)
	var/total_required = rand(total_required_min, total_required_max)

	var/random_assigned_total = 0
	for(var/i = 1 to types_total)
		if(!LAZYLEN(possible_types))
			break
		var/random_number = rand(1,10) ** distribution_factor
		var/random_type = pick(possible_types)
		possible_types -= random_type
		wanted_types[random_type] = random_number
		random_assigned_total += random_number

	for(var/type in wanted_types)
		wanted_types[type] = round(total_required * (wanted_types[type] / random_assigned_total))


	description = pick(possible_descriptions)

	..()
*/
