/datum/bounty
	var/name
	var/description
	var/reward = 1000 // In credits. Modified by a bunch of outside variables, so this is not the real amount of credits awarded.
	var/high_priority = FALSE
	var/category = BOUNTY_CATEGORY_TEST
	var/status

// Displayed on bounty UI screen.
/datum/bounty/proc/completion_string()
	return ""

// Displayed on bounty UI screen.
/datum/bounty/proc/reward_string()
	// Simulates claiming the bounty (SSeconomy.distribute_funds) to get the actual reward amount
	// As of april 2025, this returns (reward * 1.5)
	var/amount_shared = reward * SSeconomy.bounty_modifier // We get the amount to distribute among the departments
	var/part = round(amount_shared / SSeconomy.distribution_sum()) // We get the value of a share of the amount to distribute
	var/datum/bank_account/department/cargo_account = SSeconomy.get_budget_account(ACCOUNT_CAR_ID) // We get the cargo department budget account
	var/actual_reward = part * cargo_account.budget_ratio // We get the share of the cargo department

	return "[actual_reward] Credits"

/datum/bounty/proc/can_claim()
	return status == BOUNTY_STATUS_ACTIVE

// Called when the claim button is clicked. Override to provide fancy rewards.
/datum/bounty/proc/claim()
	if(can_claim())
		SSeconomy.distribute_funds(reward * SSeconomy.bounty_modifier)

// If an item sent in the cargo shuttle can satisfy the bounty.
/datum/bounty/proc/applies_to(obj/O)
	return FALSE

// Called when an object is shipped on the cargo shuttle.
/datum/bounty/proc/ship(obj/O)
	return

// When randomly generating the bounty list, duplicate bounties must be avoided.
// This proc is used to determine if two bounties are duplicates, or incompatible in general.
/datum/bounty/proc/compatible_with(other_bounty)
	return TRUE

/datum/bounty/proc/mark_high_priority(scale_reward = 2)
	if(high_priority)
		return
	high_priority = TRUE
	reward = round(reward * scale_reward)

// This proc is called when the shuttle docks at CentCom.
// It handles items shipped for bounties.
/proc/bounty_ship_item_and_contents(atom/movable/AM, dry_run=FALSE)

	var/list/matched_one = FALSE
	for(var/thing in reverse_range(AM.GetAllContents()))
		var/matched_this = FALSE
		for(var/datum/bounty/B in SSbounties.accepted_bounties)
			if(B.applies_to(thing))
				matched_one = TRUE
				matched_this = TRUE
				if(!dry_run)
					B.ship(thing)
		if(!dry_run && matched_this)
			qdel(thing)
	return matched_one

/proc/completed_bounty_count()
	var/count = 0
	for(var/i in SSbounties.archived_bounties)
		var/datum/bounty/B = i
		if(B.status == BOUNTY_STATUS_COMPLETED)
			++count
	return count

