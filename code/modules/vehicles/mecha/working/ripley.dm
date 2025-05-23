/obj/vehicle/sealed/mecha/working/ripley
	desc = "Autonomous Power Loader Unit MK-I. Designed primarily around heavy lifting, the Ripley can be outfitted with utility equipment to fill a number of roles."
	name = "\improper APLU MK-I \"Ripley\""
	icon_state = "ripley"
	base_icon_state = "ripley"
	silicon_icon_state = "ripley-empty"
	movedelay = 1.5 //Move speed, lower is faster.
	/// How fast the mech is in low pressure
	var/fast_pressure_step_in = 1.5
	/// How fast the mech is in normal pressure
	var/slow_pressure_step_in = 2
	max_temperature = 20000
	max_integrity = 200
	lights_power = 7
	deflect_chance = 15
	armor_type = /datum/armor/working_ripley
	max_equip = 6
	wreckage = /obj/structure/mecha_wreckage/ripley
	internals_req_access = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING)
	enclosed = FALSE //Normal ripley has an open cockpit design
	enter_delay = 10 //can enter in a quarter of the time of other mechs
	exit_delay = 10
	/// Amount of Goliath hides attached to the mech
	var/hides = 0
	/// List of all things in Ripley's Cargo Compartment
	var/list/cargo
	/// How much things Ripley can carry in their Cargo Compartment
	var/cargo_capacity = 15
	/// Custom Ripley step and turning sounds (from TGMC)
	stepsound = 'sound/mecha/powerloader_step.ogg'
	turnsound = 'sound/mecha/powerloader_turn2.ogg'


/datum/armor/working_ripley
	melee = 40
	bullet = 20
	laser = 10
	energy = 20
	bomb = 40
	rad = 20
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/working/ripley/Move()
	. = ..()
	update_pressure()

/obj/vehicle/sealed/mecha/working/ripley/generate_actions() //isnt allowed to have internal air
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_eject)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_cycle_equip)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_lights)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_view_stats)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/strafe)

/obj/vehicle/sealed/mecha/working/ripley/check_for_internal_damage(list/possible_int_damage, ignore_threshold = FALSE)
	if(!enclosed) //if we don't even have an air tank, these two doesn't make a ton of sense.
		possible_int_damage -= (MECHA_INT_TEMP_CONTROL + MECHA_INT_TANK_BREACH)
	return ..()

/obj/vehicle/sealed/mecha/working/ripley/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate, 3 ,/obj/item/stack/sheet/animalhide/goliath_hide, /datum/armor/armor_plate_ripley_goliath)

/datum/armor/armor_plate_ripley_goliath
	melee = 10
	bullet = 5
	laser = 5

/obj/vehicle/sealed/mecha/working/ripley/Destroy()
	for(var/atom/movable/A in cargo)
		A.forceMove(drop_location())
		step_rand(A)
	QDEL_LIST(cargo)
	return ..()

/obj/vehicle/sealed/mecha/working/ripley/mk2
	desc = "Autonomous Power Loader Unit MK-II. This prototype Ripley is refitted with a pressurized cabin, trading its prior speed for atmospheric protection and armor."
	name = "\improper APLU MK-II \"Ripley\""
	icon_state = "ripleymkii"
	base_icon_state = "ripleymkii"
	fast_pressure_step_in = 1.75 //step_in while in low pressure conditions
	slow_pressure_step_in = 3 //step_in while in normal pressure conditions
	movedelay = 4
	armor_type = /datum/armor/ripley_mk2
	wreckage = /obj/structure/mecha_wreckage/ripley/mk2
	enclosed = TRUE
	enter_delay = 40
	silicon_icon_state = null


/datum/armor/ripley_mk2
	melee = 40
	bullet = 20
	laser = 10
	energy = 20
	bomb = 40
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/working/ripley/mk2/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_eject)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_internals)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_cycle_equip)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_lights)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_view_stats)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/strafe)


/obj/vehicle/sealed/mecha/working/ripley/deathripley
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE"
	name = "\improper DEATH-RIPLEY"
	icon_state = "deathripley"
	base_icon_state = "deathripley"
	fast_pressure_step_in = 2 //step_in while in low pressure conditions
	slow_pressure_step_in = 3 //step_in while in normal pressure conditions
	movedelay = 4
	lights_power = 7
	wreckage = /obj/structure/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0
	enclosed = TRUE
	enter_delay = 40
	silicon_icon_state = null

/obj/vehicle/sealed/mecha/working/ripley/deathripley/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/fake/clamper = new(loc)
	clamper.attach(src)

/obj/vehicle/sealed/mecha/working/ripley/deathripley/real
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE. FOR REAL"

/obj/vehicle/sealed/mecha/working/ripley/deathripley/real/Initialize(mapload)
	. = ..()
	for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
		E.detach()
		qdel(E)
	LAZYCLEARLIST(equipment)
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/clamper = new(loc)
	clamper.attach(src)

/obj/vehicle/sealed/mecha/working/ripley/mining
	desc = "An old, dusty mining Ripley."
	name = "\improper APLU \"Miner\""

/obj/vehicle/sealed/mecha/working/ripley/mining/Initialize(mapload)
	. = ..()
	if(cell)
		cell.charge = FLOOR(cell.charge * 0.25, 1) //Starts at very low charge
	if(prob(70)) //Maybe add a drill
		if(prob(15)) //Possible diamond drill... Feeling lucky?
			var/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill/D = new
			D.attach(src)
		else
			var/obj/item/mecha_parts/mecha_equipment/drill/D = new
			D.attach(src)

	else //Add plasma cutter if no drill
		var/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/P = new
		P.attach(src)

	//Attach hydraulic clamp
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src)

	take_damage(max_integrity * 0.5, sound_effect=FALSE) //Low starting health

	var/obj/item/mecha_parts/mecha_equipment/mining_scanner/scanner = new
	scanner.attach(src)

/obj/vehicle/sealed/mecha/working/ripley/Exit(atom/movable/O)
	if(O in cargo)
		return FALSE
	return ..()

/obj/vehicle/sealed/mecha/working/ripley/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/cargoobj = locate(href_list["drop_from_cargo"]) in cargo
		if(cargoobj)
			to_chat(occupants, "[icon2html(src, occupants)][span_notice("You unload [cargoobj].")]")
			cargoobj.forceMove(drop_location())
			LAZYREMOVE(cargo, cargoobj)
			if(cargoobj == box)
				box = null
			log_message("Unloaded [cargoobj]. Cargo compartment capacity: [cargo_capacity - LAZYLEN(cargo)]", LOG_MECHA)


/obj/vehicle/sealed/mecha/working/ripley/contents_explosion(severity, target)
	for(var/i in cargo)
		var/obj/cargoobj = i
		if(prob(30/severity))
			LAZYREMOVE(cargo, cargoobj)
			cargoobj.forceMove(drop_location())
	return ..()

/obj/vehicle/sealed/mecha/working/ripley/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(LAZYLEN(cargo))
		for(var/obj/O in cargo)
			output += "<a href='byond://?src=[REF(src)];drop_from_cargo=[REF(O)]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/vehicle/sealed/mecha/working/ripley/relay_container_resist(mob/living/user, obj/O)
	to_chat(user, span_notice("You lean on the back of [O] and start pushing so it falls out of [src]."))
	if(do_after(user, 300, target = O))
		if(!user || user.stat != CONSCIOUS || user.loc != src || O.loc != src )
			return
		to_chat(user, span_notice("You successfully pushed [O] out of [src]!"))
		O.forceMove(drop_location())
		LAZYREMOVE(cargo, O)
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, span_warning("You fail to push [O] out of [src]!"))

/**
  * Makes the mecha go faster and halves the mecha drill cooldown if in Lavaland pressure.
  *
  * Checks for Lavaland pressure, if that works out the mech's speed is equal to fast_pressure_step_in and the cooldown for the mecha drill is halved. If not it uses slow_pressure_step_in and drill cooldown is normal.
  */
/obj/vehicle/sealed/mecha/working/ripley/proc/update_pressure()
	var/turf/T = get_turf(loc)

	if(lavaland_equipment_pressure_check(T))
		movedelay = fast_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)/2
	else
		movedelay = slow_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)
