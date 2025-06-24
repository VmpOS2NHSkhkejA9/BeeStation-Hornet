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
	var/list/wanted_types  // Types accepted for the bounty. Key as type, value as required amount.
	var/include_subtypes = TRUE     // Set to FALSE to make the datum apply only to a strict type.
	var/list/exclude_types = list() // Types excluded.
	var/list/shipped_types = list()
	var/list/wanted_types_cache //supposedly checking for types in typecaches is very fast


/datum/bounty/New()
	expiration_time += world.time
	START_PROCESSING(SSprocessing, src)
	wanted_types_cache = typecacheof(wanted_types)
	exclude_types = typecacheof(exclude_types)
	for(var/type in wanted_types) //this works if it's var/atom/type, but not if it's just var/type, for reasons beyond me.
		to_chat(world, type)
		shipped_types[type] = 0

/datum/bounty/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/datum/bounty/proc/archive()
	STOP_PROCESSING(SSprocessing, src)

/datum/bounty/proc/accept()
	expiration_time += expiration_time_accepted
	SSbounties.available_bounties -= src
	SSbounties.accepted_bounties += src
	status = BOUNTY_STATUS_ACTIVE

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


// Displayed on bounty UI screen.
/datum/bounty/proc/completion_string()
	for(var/type in wanted_types)
		var/atom/type_atom = type
		. += {"\[[shipped_types[type]]/[wanted_types[type]]\] [capitalize(type_atom.name)] \n"}

/datum/bounty/proc/can_claim()
	if(!((status == BOUNTY_STATUS_ACTIVE) && (src in SSbounties.accepted_bounties) && (world.time < expiration_time)))
		return FALSE
	. = TRUE
	for(var/type in wanted_types)
		if(shipped_types[type] >= wanted_types[type])
			continue
		. = FALSE
		break
	return

// Called when the claim button is clicked. Override to provide fancy rewards.
/datum/bounty/proc/claim()
	if(can_claim())
		SSeconomy.distribute_funds(reward * SSeconomy.bounty_modifier)
		status = BOUNTY_STATUS_COMPLETED
		SSbounties.accepted_bounties -= src
		SSbounties.archived_bounties += src

// If an item sent in the cargo shuttle can satisfy the bounty.
/datum/bounty/proc/applies_to(obj/O)
	if(!wanted_types_cache[O.type] || exclude_types[O.type])
		return FALSE
	if(!include_subtypes && !(O.type in wanted_types))
		return FALSE
	if(O.flags_1 & HOLOGRAM_1)
		return FALSE
	return TRUE //TODO: make this not not bad

// Called when an object is shipped on the cargo shuttle.
/datum/bounty/proc/ship(obj/O)
	var/shipped_type
	var/amount = 1
	for(var/type in wanted_types)
		if(istype(O, type))
			shipped_type = type
	if(!shipped_type)
		return FALSE //this should never happen
	if(istype(O, /obj/item/stack))
		var/obj/item/stack/shipped_stack = O
		amount = shipped_stack.amount

	shipped_types[shipped_type] += amount

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
			if(B.applies_to(thing))
				matched_bounties += B
				matched_this = TRUE
				if(!dry_run)
					B.ship(thing)
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

