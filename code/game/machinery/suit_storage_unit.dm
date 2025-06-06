// SUIT STORAGE UNIT /////////////////
/obj/machinery/suit_storage_unit
	name = "suit storage unit"
	desc = "An industrial unit made to hold and decontaminate irradiated equipment. It comes with a built-in UV cauterization mechanism. A small warning label advises that organic matter should not be placed into the unit."
	icon = 'icons/obj/machines/suit_storage.dmi'
	icon_state = "close"
	obj_flags = CAN_BE_HIT | USES_TGUI
	use_power = ACTIVE_POWER_USE
	active_power_usage = 60
	power_channel = AREA_USAGE_EQUIP
	density = TRUE
	obj_flags = BLOCKS_CONSTRUCTION // Becomes undense when the unit is open
	max_integrity = 250
	circuit = /obj/item/circuitboard/machine/suit_storage_unit

	var/obj/item/clothing/suit/space/suit = null
	var/obj/item/clothing/head/helmet/space/helmet = null
	var/obj/item/clothing/mask/mask = null
	var/obj/item/storage = null
	// if you add more storage slots, update cook() to clear their radiation too.

	/// What type of spacesuit the unit starts with when spawned.
	var/suit_type = null
	/// What type of space helmet the unit starts with when spawned.
	var/helmet_type = null
	/// What type of breathmask the unit starts with when spawned.
	var/mask_type = null
	/// What type of additional item the unit starts with when spawned.
	var/storage_type = null

	state_open = FALSE
	/// If the SSU's doors are locked closed. Can be toggled manually via the UI, but is also locked automatically when the UV decontamination sequence is running.
	var/locked = FALSE
	panel_open = FALSE
	/// If the safety wire is cut/pulsed, the SSU can run the decontamination sequence while occupied by a mob. The mob will be burned during every cycle of cook().
	var/safeties = TRUE

	/// If UV decontamination sequence is running. See cook()
	var/uv = FALSE
	/**
	* If the hack wire is cut/pulsed.
	* Modifies effects of cook()
	* * If FALSE, decontamination sequence will clear radiation for all atoms (and their contents) contained inside the unit, and burn any mobs inside.
	* * If TRUE, decontamination sequence will burn and decontaminate all items contained within, and if occupied by a mob, intensifies burn damage delt. All wires will be cut at the end.
	*/
	///how strong is the burn damage during cook(), decreases with micro laser tier
	var/laser_strength = 10
	///how strong is the burn damage if hacked/emagged during cook(), increases with micro laser tier
	var/laser_strength_hacked = 20
	var/uv_super = FALSE
	/// For managing the messages sent back when the machine was hacked
	var/toasted = FALSE
	/// How many cycles remain for the decontamination sequence.
	var/uv_cycles = 6
	/// Cooldown for occupant breakout messages via relaymove()
	var/message_cooldown
	/// How long it takes to break out of the SSU.
	var/breakout_time = 300
	/// How fast it charges cells in a suit
	var/charge_rate = 250

/obj/machinery/suit_storage_unit/Initialize(mapload)
	. = ..()
	interaction_flags_machine |= INTERACT_MACHINE_OFFLINE

/obj/machinery/suit_storage_unit/standard_unit
	suit_type = /obj/item/clothing/suit/space/eva
	helmet_type = /obj/item/clothing/head/helmet/space/eva
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/gps/off

/obj/machinery/suit_storage_unit/captain
	suit_type = /obj/item/clothing/suit/space/hardsuit/swat/captain
	mask_type = /obj/item/clothing/mask/gas/sechailer
	storage_type = /obj/item/tank/jetpack/oxygen/captain

/obj/machinery/suit_storage_unit/engine
	suit_type = /obj/item/clothing/suit/space/hardsuit/engine
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/ce
	suit_type = /obj/item/clothing/suit/space/hardsuit/engine/elite
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/clothing/shoes/magboots/advance

/obj/machinery/suit_storage_unit/security
	suit_type = /obj/item/clothing/suit/space/hardsuit/security
	mask_type = /obj/item/clothing/mask/gas/sechailer
	storage_type = /obj/item/gps/security/off

/obj/machinery/suit_storage_unit/hos
	suit_type = /obj/item/clothing/suit/space/hardsuit/security/head_of_security
	mask_type = /obj/item/clothing/mask/gas/sechailer
	storage_type = /obj/item/gps/security/off

/obj/machinery/suit_storage_unit/atmos
	suit_type = /obj/item/clothing/suit/space/hardsuit/engine/atmos
	mask_type = /obj/item/clothing/mask/gas
	storage_type = /obj/item/watertank/atmos

/obj/machinery/suit_storage_unit/mining
	suit_type = /obj/item/clothing/suit/hooded/explorer
	mask_type = /obj/item/clothing/mask/gas/explorer
	storage_type = /obj/item/gps/mining/off

/obj/machinery/suit_storage_unit/mining/eva
	suit_type = /obj/item/clothing/suit/space/hardsuit/mining
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/gps/mining/off

/obj/machinery/suit_storage_unit/exploration
	suit_type = /obj/item/clothing/suit/space/hardsuit/exploration
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/gps/mining/exploration/off

/obj/machinery/suit_storage_unit/cmo
	suit_type = /obj/item/clothing/suit/space/hardsuit/medical/cmo
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/gps/off

/obj/machinery/suit_storage_unit/rd
	suit_type = /obj/item/clothing/suit/space/hardsuit/research_director
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/gps/off

/obj/machinery/suit_storage_unit/syndicate
	suit_type = /obj/item/clothing/suit/space/hardsuit/syndi
	mask_type = /obj/item/clothing/mask/gas/syndicate
	storage_type = /obj/item/tank/jetpack/oxygen/harness

/obj/machinery/suit_storage_unit/ert/command
	suit_type = /obj/item/clothing/suit/space/hardsuit/ert
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/security
	suit_type = /obj/item/clothing/suit/space/hardsuit/ert/sec
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/engineer
	suit_type = /obj/item/clothing/suit/space/hardsuit/ert/engi
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/ert/medical
	suit_type = /obj/item/clothing/suit/space/hardsuit/ert/med
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/machinery/suit_storage_unit/radsuit
	name = "radiation suit storage unit"
	suit_type = /obj/item/clothing/suit/utility/radiation
	helmet_type = /obj/item/clothing/head/utility/radiation
	storage_type = /obj/item/geiger_counter

/obj/machinery/suit_storage_unit/bounty
	name = "bounty suit storage unit"
	helmet_type = /obj/item/clothing/head/helmet/space/hunter
	suit_type = /obj/item/clothing/suit/space/hunter
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/gps/off

/obj/machinery/suit_storage_unit/open
	state_open = TRUE
	density = FALSE

/obj/machinery/suit_storage_unit/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/suit_storage_unit(src)
	if(suit_type)
		suit = new suit_type(src)
	if(helmet_type)
		helmet = new helmet_type(src)
	if(mask_type)
		mask = new mask_type(src)
	if(storage_type)
		storage = new storage_type(src)
	RefreshParts()
	update_appearance()

/obj/machinery/suit_storage_unit/Destroy()
	QDEL_NULL(wires)
	dump_inventory_contents()
	return ..()

/obj/machinery/suit_storage_unit/update_overlays()
	. = ..()

	if(uv)
		if(uv_super || (obj_flags & EMAGGED))
			. += "super"
			return
		if(occupant)
			. += "uvhuman"
			return

		. += "uv"
		return

	if(state_open)
		if(machine_stat & BROKEN)
			. += "broken"
			return

		. += "open"
		if(suit)
			. += "suit"
		if(helmet)
			. += "helm"
		if(storage)
			. += "storage"
		return

	if(occupant)
		. += "human"
		return

/obj/machinery/suit_storage_unit/power_change()
	. = ..()
	if(!is_operational && state_open)
		open_machine()
		dump_inventory_contents()
	update_appearance()

/obj/machinery/suit_storage_unit/RefreshParts()
	var/calculated_laser_rating = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		calculated_laser_rating += laser.rating
	laser_strength_hacked = 15 + (5 * (calculated_laser_rating)) //20 on T1, 35 on T4
	laser_strength = 12 - (2 * (calculated_laser_rating)) //10 on T1, 4 on T4

/obj/machinery/suit_storage_unit/dump_inventory_contents()
	. = ..()
	helmet = null
	suit = null
	mask = null
	storage = null
	set_occupant(null)

/obj/machinery/suit_storage_unit/proc/is_empty()
	return isnull(helmet) && isnull(suit) && isnull(mask) && isnull(storage) && isnull(occupant)

/obj/machinery/suit_storage_unit/emp_act()
	. = ..()
	uv_super = !uv_super
	wires.ui_update()
	ui_update()

/obj/machinery/suit_storage_unit/on_emag(mob/user)
	..()
	to_chat(user, span_warning("You reprogram [src]'s decontamination subroutines."))

/obj/machinery/suit_storage_unit/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		open_machine()
		dump_inventory_contents()
		spawn_frame(disassembled)
		for(var/obj/item/I in component_parts)
			I.forceMove(loc)
			component_parts.Cut()
	qdel(src)

/obj/machinery/suit_storage_unit/interact(mob/living/user)
	var/static/list/items

	if (!items)
		items = list(
			"suit" = create_silhouette_of(/obj/item/clothing/suit/space/eva),
			"helmet" = create_silhouette_of(/obj/item/clothing/head/helmet/space/eva),
			"mask" = create_silhouette_of(/obj/item/clothing/mask/breath),
			"storage" = create_silhouette_of(/obj/item/tank/internals/oxygen),
		)

	. = ..()
	if (.)
		return

	if (!check_interactable(user))
		return

	var/list/choices = list()

	if (locked)
		choices["unlock"] = icon('icons/hud/radials/radial_generic.dmi', "radial_unlock")
	else if (state_open)
		choices["close"] = icon('icons/hud/radials/radial_generic.dmi', "radial_close")

		for (var/item_key in items)
			var/item = vars[item_key]
			if (item)
				choices[item_key] = item
			else
				// If the item doesn't exist, put a silhouette in its place
				choices[item_key] = items[item_key]
	else
		choices["open"] = icon('icons/hud/radials/radial_generic.dmi', "radial_open")
		choices["disinfect"] = icon('icons/hud/radials/radial_generic.dmi', "radial_disinfect")
		choices["lock"] = icon('icons/hud/radials/radial_generic.dmi', "radial_lock")

	var/choice = show_radial_menu(
		user,
		src,
		choices,
		custom_check = CALLBACK(src, PROC_REF(check_interactable), user),
		require_near = !issiliconoradminghost(user),
	)

	if (!choice)
		return

	switch (choice)
		if ("open")
			if (!state_open)
				open_machine(drop = FALSE)
				if (occupant)
					dump_contents()
		if ("close")
			if (state_open)
				close_machine()
		if ("disinfect")
			if (occupant && safeties)
				return
			else if (!helmet && !mask && !suit && !storage && !occupant)
				return
			else
				if (occupant)
					var/mob/living/mob_occupant = occupant
					to_chat(mob_occupant, span_userdanger("[src]'s confines grow warm, then hot, then scorching. You're being burned [!mob_occupant.stat ? "alive" : "away"]!"))
				cook()
		if ("lock", "unlock")
			if (!state_open)
				locked = !locked
		else
			var/obj/item/item_to_dispense = vars[choice]
			if (item_to_dispense)
				vars[choice] = null
				try_put_in_hand(item_to_dispense, user)
			else
				var/obj/item/in_hands = user.get_active_held_item()
				if (in_hands)
					attackby(in_hands, user)

	interact(user)

/obj/machinery/suit_storage_unit/proc/check_interactable(mob/user)
	if (!state_open && !can_interact(user))
		return FALSE

	if (panel_open)
		return FALSE

	if (uv)
		return FALSE

	return TRUE

/obj/machinery/suit_storage_unit/proc/create_silhouette_of(atom/item)
	var/image/image = image(initial(item.icon), initial(item.icon_state))
	image.alpha = 128
	image.color = COLOR_RED
	return image

/obj/machinery/suit_storage_unit/MouseDrop_T(atom/A, mob/living/user)
	if(!istype(user) || user.stat || !Adjacent(user) || !Adjacent(A) || !isliving(A))
		return
	if(isliving(user))
		var/mob/living/L = user
		if(L.body_position == LYING_DOWN)
			return
	var/mob/living/target = A
	if(!state_open)
		to_chat(user, span_warning("The unit's doors are shut!"))
		return
	if(!is_operational)
		to_chat(user, span_warning("The unit is not operational!"))
		return
	if(occupant || helmet || suit || storage)
		to_chat(user, span_warning("It's too cluttered inside to fit in!"))
		return
	if(target == user)
		user.visible_message(span_warning("[user] starts squeezing into [src]!"), span_notice("You start working your way into [src]..."))
	else
		target.visible_message(span_warning("[user] starts shoving [target] into [src]!"), span_userdanger("[user] starts shoving you into [src]!"))

	if(do_after(user, 30, target))
		if(occupant || helmet || suit || storage)
			return
		if(target == user)
			user.visible_message(span_warning("[user] slips into [src] and closes the door behind [user.p_them()]!"), span_notice("You slip into [src]'s cramped space and shut its door."))
		else
			target.visible_message(span_warning("[user] pushes [target] into [src] and shuts its door!"), span_userdanger("[user] shoves you into [src] and shuts the door!"))
		close_machine(target)
		add_fingerprint(user)

/**
  * UV decontamination sequence.
  * Duration is determined by the uv_cycles var.
  * Effects determined by the uv_super var.
  * * If FALSE, all atoms (and their contents) contained are cleared of radiation. If a mob is inside, they are burned every cycle.
  * * If TRUE, all items contained are destroyed, and burn damage applied to the mob is increased. All wires will be cut at the end.
  * All atoms still inside at the end of all cycles are ejected from the unit.
*/
/obj/machinery/suit_storage_unit/proc/cook()
	var/mob/living/mob_occupant = occupant
	var/burn_damage = uv_super || (obj_flags & EMAGGED) ? laser_strength_hacked : laser_strength
	if(uv_cycles)
		uv_cycles--
		uv = TRUE
		locked = TRUE
		update_appearance()
		if(mob_occupant)
			mob_occupant.adjustFireLoss(rand(burn_damage, burn_damage * 1.5))
			mob_occupant.emote("scream")
		addtimer(CALLBACK(src, PROC_REF(cook)), 50)
	else
		uv_cycles = initial(uv_cycles)
		uv = FALSE
		locked = FALSE
		if(uv_super || (obj_flags & EMAGGED))
			toasted = TRUE
			if(mob_occupant)
				visible_message(span_warning("[src]'s door creaks open with a loud whining noise. A foul stench and a cloud of smoke exit the chamber."))
				mob_occupant.radiation = 0 //The guy inside is toasted to a crisp, no need to leave him with the rads
			else
				visible_message(span_warning("[src]'s door creaks open with a loud whining noise. A cloud of foul black smoke escapes from its chamber."))
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 50, TRUE)
			if(helmet)
				helmet.take_damage(burn_damage * 10, BURN, FIRE)
			if(suit)
				suit.take_damage(burn_damage * 10, BURN, FIRE)
			if(mask)
				mask.take_damage(burn_damage * 10, BURN, FIRE)
			if(storage)
				storage.take_damage(burn_damage * 10, BURN, FIRE)
			// The wires get damaged too.
			wires.cut_all(null)
		if(!toasted) //Special toast check to prevent a double finishing message.
			if(mob_occupant)
				visible_message(span_warning("[src]'s door slides open, barraging you with the nauseating smell of charred flesh."))
				mob_occupant.radiation = 0
			else
				visible_message(span_notice("[src]'s door slides open. The glowing yellow lights dim to a gentle green."))
		toasted = FALSE
		playsound(src, 'sound/machines/airlockclose.ogg', 25, TRUE)
		var/list/things_to_clear = list() //Done this way since using GetAllContents on the SSU itself would include circuitry and such.
		if(suit)
			things_to_clear += suit
			things_to_clear += suit.GetAllContents()
		if(helmet)
			things_to_clear += helmet
			things_to_clear += helmet.GetAllContents()
		if(mask)
			things_to_clear += mask
			things_to_clear += mask.GetAllContents()
		if(storage)
			things_to_clear += storage
			things_to_clear += storage.GetAllContents()
		if(mob_occupant)
			things_to_clear += mob_occupant
			things_to_clear += mob_occupant.GetAllContents()
		for(var/am in things_to_clear) //Scorches away blood and forensic evidence, although the SSU itself is unaffected
			var/atom/movable/dirty_movable = am
			dirty_movable.wash(CLEAN_ALL)
		open_machine(FALSE)
		if(mob_occupant)
			dump_inventory_contents()

/obj/machinery/suit_storage_unit/process()
	if(!suit)
		return
	if(!istype(suit, /obj/item/clothing/suit/space))
		return
	if(!suit.cell)
		return

	var/obj/item/stock_parts/cell/C = suit.cell
	use_power(charge_rate)
	C.give(charge_rate)

/obj/machinery/suit_storage_unit/proc/shock(mob/user, prb)
	if(!prob(prb))
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		if(electrocute_mob(user, src, src, 1, TRUE))
			return 1

/obj/machinery/suit_storage_unit/relaymove(mob/living/user, direction)
	if(locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, span_warning("[src]'s door won't budge!"))
		return
	open_machine()
	dump_inventory_contents()

/obj/machinery/suit_storage_unit/container_resist(mob/living/user)
	if(!locked)
		open_machine()
		dump_inventory_contents()
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(span_notice("You see [user] kicking against the doors of [src]!"), \
		span_notice("You start kicking against the doors... (this will take about [DisplayTimeText(breakout_time)].)"), \
		span_hear("You hear a thump from [src]."))
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src )
			return
		user.visible_message(span_warning("[user] successfully broke out of [src]!"), \
			span_notice("You successfully break out of [src]!"))
		locked = FALSE
		open_machine()
		dump_inventory_contents()

	add_fingerprint(user)


/obj/machinery/suit_storage_unit/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_CROWBAR && user.combat_mode && !panel_open && machine_stat & NOPOWER)
		if(locked)
			to_chat(user, span_warning("[src]'s door won't budge!"))
			return
		if(!state_open)
			visible_message(span_notice("[user] starts prying open the doors of [src]!"), span_notice("You start prying open the doors of [src]!"))
			I.play_tool_sound(src, 50)
			if(do_after(user, 20, target=src))
				playsound(src, 'sound/effects/bin_open.ogg', 50, TRUE)
				open_machine(0)
				return
		else
			I.play_tool_sound(src, 50)
			visible_message(span_notice("[user] pulls out the contents of [src] outside!"), span_notice("You pull [src]'s contents outside!"))
			dump_inventory_contents()
			update_icon()
			return
	if(state_open && is_operational)
		if(istype(I, /obj/item/clothing/suit))
			if(suit)
				to_chat(user, span_warning("The unit already contains a suit!"))
				return
			if(!user.transferItemToLoc(I, src))
				return
			suit = I
		else if(istype(I, /obj/item/clothing/head))
			if(helmet)
				to_chat(user, span_warning("The unit already contains a helmet!"))
				return
			if(!user.transferItemToLoc(I, src))
				return
			helmet = I
		else if(istype(I, /obj/item/clothing/mask))
			if(mask)
				to_chat(user, span_warning("The unit already contains a mask!"))
				return
			if(!user.transferItemToLoc(I, src))
				return
			mask = I
		else
			if(storage)
				to_chat(user, span_warning("The auxiliary storage compartment is full!"))
				return
			if(!user.transferItemToLoc(I, src))
				return
			storage = I

		visible_message(span_notice("[user] inserts [I] into [src]"), span_notice("You load [I] into [src]."))
		update_appearance()
		return

	if(panel_open && is_wire_tool(I))
		wires.interact(user)
		return
	if(!state_open)
		if(default_deconstruction_screwdriver(user, "panel", "close", I))
			return
		if(is_empty())
			if(default_deconstruction_crowbar(I))
				return
	if(default_pry_open(I))
		dump_inventory_contents()
		return

	return ..()

/*	ref tg-git issue #45036
	screwdriving it open while it's running a decontamination sequence without closing the panel prior to finish
	causes the SSU to break due to state_open being set to TRUE at the end, and the panel becoming inaccessible.
*/
/obj/machinery/suit_storage_unit/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	if(!(flags_1 & NODECONSTRUCT_1) && I.tool_behaviour == TOOL_SCREWDRIVER && uv)
		to_chat(user, span_warning("It might not be wise to fiddle with [src] while it's running..."))
		return TRUE
	return ..()


/obj/machinery/suit_storage_unit/default_pry_open(obj/item/I)//needs to check if the storage is locked.
	. = !(state_open || panel_open || is_operational || locked || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message(span_notice("[usr] pries open \the [src]."), span_notice("You pry open \the [src]."))
		open_machine()
