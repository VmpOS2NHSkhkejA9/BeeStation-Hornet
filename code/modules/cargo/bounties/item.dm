/datum/bounty/item
	var/list/wanted_types  // Types accepted for the bounty. Key as type, value as required amount.
	var/include_subtypes = TRUE     // Set to FALSE to make the datum apply only to a strict type.
	var/list/exclude_types = list() // Types excluded.
	var/list/shipped_types = list()
	var/list/wanted_types_cache //supposedly checking for types in typecaches is very fast

/datum/bounty/item/New()
	..()
	wanted_types_cache = typecacheof(wanted_types)
	exclude_types = typecacheof(exclude_types)
	for(var/type in wanted_types) //this works if it's var/atom/type, but not if it's just var/type, for reasons beyond me.
		to_chat(world, type)
		shipped_types[type] = 0

/datum/bounty/item/completion_string()
	for(var/type in wanted_types)
		var/atom/type_atom = type
		. += {"\[[shipped_types[type]]/[wanted_types[type]]\] [capitalize(type_atom.name)] \n"}

/datum/bounty/item/can_claim()
	. = TRUE
	for(var/type in wanted_types)
		if(shipped_types[type] >= wanted_types[type])
			continue
		. = FALSE
		break
	return ..() && .

/datum/bounty/item/applies_to(obj/O)
	if(!wanted_types_cache[O.type] || exclude_types[O.type])
		return FALSE
	if(!include_subtypes && !(O.type in wanted_types))
		return FALSE
	if(O.flags_1 & HOLOGRAM_1)
		return FALSE
	return TRUE //TODO: make this not not bad

/datum/bounty/item/ship(obj/O)
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

/datum/bounty/item/compatible_with(datum/other_bounty)
	return type != other_bounty.type

/datum/bounty/item/testbounty
	name = "testing bounty"
	description = "woohoo my code works (maybe)"
	author = "whatever they name the supply corporation"
	category = BOUNTY_CATEGORY_TEST
	wanted_types = list(
		/obj/item/bikehorn = 1,
		/obj/item/food/grown/banana = 1)

