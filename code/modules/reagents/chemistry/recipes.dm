/datum/chemical_reaction
	var/name = null
	var/id = null
	var/list/results = new/list()
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()
	var/list/hints = list()

	/// If required_container will check for the exact type, or will also accept subtypes
	var/required_container_accepts_subtypes = FALSE
	/// the exact container path required for the reaction to happen, typepath
	var/atom/required_container
	/// Set this to true to call pre_reaction_other_checks() on react and do some more interesting reaction logic
	var/required_other = FALSE

	var/mob_react = TRUE //Determines if a chemical reaction can occur inside a mob

	var/required_temp = 0
	var/is_cold_recipe = 0 // Set to 1 if you want the recipe to only react when it's BELOW the required temp.
	var/mix_message = "The solution begins to bubble." //The message shown to nearby people upon mixing, if applicable
	var/mix_sound = 'sound/effects/bubbles.ogg' //The sound played upon mixing, if applicable

	/// Tags for the reactions
	var/reaction_tags = NONE

// Extra checks for the reaction to occur.
/datum/chemical_reaction/proc/can_react(datum/reagents/holder)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)
	return TRUE

/**
 * Checks if this reaction can occur. Only is ran if required_other is set to TRUE.
 */
/datum/chemical_reaction/proc/pre_reaction_other_checks(datum/reagents/holder)
	return TRUE

/**
 * Shit that happens on reaction
 * Only procs at the START of a reaction
 * use reaction_step() for each step of a reaction
 * or reaction_end() when the reaction stops
 * If reaction_flags & REACTION_INSTANT then this is the only proc that is called.
 *
 * Proc where the additional magic happens.
 * You dont want to handle mob spawning in this since there is a dedicated proc for that.client
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * created_volume - volume created when this is mixed. look at 'var/list/results'.
 */
/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return
	//I recommend you set the result amount to the total volume of all components.

/datum/chemical_reaction/proc/chemical_mob_spawn(datum/reagents/holder, amount_to_spawn, reaction_name, mob_class = HOSTILE_SPAWN, mob_faction = FACTION_CHEMICAL_SUMMON, random = TRUE)
	if(holder && holder.my_atom)
		var/atom/A = holder.my_atom
		var/turf/T = get_turf(A)
		var/message = "A [reaction_name] reaction has occurred in [ADMIN_VERBOSEJMP(T)]"
		message += " (<A HREF='BYOND://?_src_=vars;Vars=[REF(A)]'>VV</A>)"

		var/mob/M = get(A, /mob)
		if(M)
			message += " - Carried By: [ADMIN_LOOKUPFLW(M)]"
		else
			message += " - Last Fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"

		message_admins(message, 0, 1)
		log_game("[reaction_name] chemical mob spawn reaction occuring at [AREACOORD(T)] carried by [key_name(M)] with last fingerprint [A.fingerprintslast? A.fingerprintslast : "N/A"]")

		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

		for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom)))
			C.flash_act()

		for(var/i in 1 to amount_to_spawn)
			var/mob/living/spawned_mob
			if(random)
				spawned_mob = create_random_mob(get_turf(holder.my_atom), mob_class)
			else
				spawned_mob = new mob_class(get_turf(holder.my_atom))//Spawn our specific mob_class
			spawned_mob.faction |= mob_faction
			if(prob(50))
				for(var/j in 1 to rand(1, 3))
					step(spawned_mob, pick(NORTH,SOUTH,EAST,WEST))

///Simulates a vortex that moves nearby movable atoms towards or away from the turf T. Range also determines the strength of the effect. High values cause nearby objects to be thrown.
/proc/goonchem_vortex(turf/T, setting_type, range)
	for(var/atom/movable/X in orange(range, T))
		if(X.anchored)
			continue
		if(iseffect(X) || iscameramob(X) || isdead(X))
			continue
		var/distance = get_dist(X, T)
		var/moving_power = max(range - distance, 1)
		if(moving_power > 2) //if the vortex is powerful and we're close, we get thrown
			if(setting_type)
				var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, T)))
				X.throw_at(throw_target, moving_power, 1)
			else
				X.throw_at(T, moving_power, 1)
		else
			if(setting_type)
				if(step_away(X, T) && moving_power > 1) //Can happen twice at most. So this is fine.
					addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step_away), X, T), 2)
			else
				if(step_towards(X, T) && moving_power > 1)
					addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step_towards), X, T), 2)

/datum/chemical_reaction/proc/check_other() //override this proc if using required_other, and return TRUE to allow the chemical reaction. Slime cores do not use this.
	return FALSE
