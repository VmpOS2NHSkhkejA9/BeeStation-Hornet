/datum/bounty
	var/name
	var/author //just a fluff string
	var/description
	var/reward = 1000 // In credits. Modified by a bunch of outside variables, so this is not the real amount of credits awarded.
	var/high_priority = FALSE
	var/category
	var/status = BOUNTY_STATUS_AVAILABLE
	var/expiration_time = 5 MINUTES //expiration time when unaccepted
	var/expiration_time_accepted = 20 MINUTES //this much time is added as a bonus when accepted
	var/requirements = list() //list of lists each with key "requirementtype" as the requirement datum's path, every other value is passed through in an arglist in the new proc

/datum/bounty/New()
	expiration_time += world.time

	var/list/datum/bounty_requirement/requirements_created = list()
	for(var/list/req in requirements)
		var/datum/bounty_requirement/requirement_datum = req["requirementtype"]
		req.Remove("requirementtype") //not sure why but -= "requirementtype" doesnt work
		requirements_created += new requirement_datum(arglist(req))
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

//base type with a bunch of functionality to generate semi-randomized bounties made up of items and/or reagents; the power of RNG will bring us variety
//a degree of control is lost over completely hand-designed bounties (this code would need to be extremely complex otherwise)
/datum/bounty/random
	var/total_required_min
	var/total_required_max
	var/different_types_min
	var/different_types_max
	var/list/possible_types = list()
	var/list/possible_descriptions = list()
	var/distribution_factor = 1 //higher values tend more towards one type making up the bulk of the wanted types
	var/allow_requirement_subtypes = FALSE
	var/reagent_quantity_mult = 5 //multiply required amounts of reagents by this AFTER all other required amount calculations

/datum/bounty/random/New()

	var/types_total = rand(different_types_min, different_types_max)
	var/total_required = rand(total_required_min, total_required_max)
	var/list/types_and_nums = list()

	var/random_assigned_total = 0
	for(var/i = 1 to types_total)
		if(!LAZYLEN(possible_types))
			break
		var/random_number = rand(1,100) * distribution_factor
		var/random_type = pick(possible_types)
		types_and_nums[random_type] = random_number
		random_assigned_total += random_number
		possible_types -= random_type

	for(var/type in types_and_nums)
		types_and_nums[type] = ceil(total_required * (types_and_nums[type] / random_assigned_total)) //round *up* so we dont get 0/0 requirements
		var/isreagent = ispath(type, /datum/reagent)
		requirements += list(list(
			requirementname = type:name, //this works for reagents and atoms, since they both have a name property
			requirementtype = isreagent ? /datum/bounty_requirement/reagent : /datum/bounty_requirement,
			includedtypes = list(isreagent ? /obj/item/reagent_containers : type),
			requiredamount = (types_and_nums[type]) * (isreagent ? reagent_quantity_mult : 1),
			allowsubtypes = allow_requirement_subtypes
			))

		to_chat(world, "added requirement for [type] to [src]")

	return ..()
