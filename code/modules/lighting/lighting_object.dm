/atom/movable/lighting_object
	name          = ""

	anchored      = TRUE

	icon             = LIGHTING_ICON
	icon_state       = "transparent"
	color            = LIGHTING_BASE_MATRIX
	plane            = LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility     = INVISIBILITY_LIGHTING

	var/needs_update = FALSE
	var/turf/myturf
	var/mutable_appearance/additive_underlay

/atom/movable/lighting_object/Initialize(mapload)
	. = ..()
	remove_verb(verbs)
	atom_colours.Cut()

	myturf = loc
	if (myturf.lighting_object)
		qdel(myturf.lighting_object, force = TRUE)
	myturf.lighting_object = src

	additive_underlay = mutable_appearance(LIGHTING_ICON, "light", FLOAT_LAYER, LIGHTING_PLANE_ADDITIVE, 255, RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM)
	additive_underlay.blend_mode = BLEND_ADD

	needs_update = TRUE
	SSlighting.objects_queue += src

/atom/movable/lighting_object/Destroy(var/force)
	if (force)
		SSlighting.objects_queue -= src
		if (loc != myturf)
			var/turf/oldturf = get_turf(myturf)
			var/turf/newturf = get_turf(loc)
			stack_trace("A lighting object was qdeleted with a different loc then it is suppose to have ([COORD(oldturf)] -> [COORD(newturf)])")
		if (isturf(myturf))
			myturf.lighting_object = null
			myturf.underlays -= additive_underlay
		myturf = null

		return ..()

	else
		return QDEL_HINT_LETMELIVE

/atom/movable/lighting_object/proc/update()
	if (loc != myturf)
		if (loc)
			var/turf/oldturf = get_turf(myturf)
			var/turf/newturf = get_turf(loc)
			warning("A lighting object realised it's loc had changed in update() ([myturf]\[[myturf ? myturf.type : "null"]]([COORD(oldturf)]) -> [loc]\[[ loc ? loc.type : "null"]]([COORD(newturf)]))!")

		qdel(src, TRUE)
		return

	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	// See LIGHTING_CORNER_DIAGONAL in lighting_corner.dm for why these values are what they are.
	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	var/datum/lighting_corner/cr = myturf.lighting_corner_SW || dummy_lighting_corner
	var/datum/lighting_corner/cg = myturf.lighting_corner_SE || dummy_lighting_corner
	var/datum/lighting_corner/cb = myturf.lighting_corner_NW || dummy_lighting_corner
	var/datum/lighting_corner/ca = myturf.lighting_corner_NE || dummy_lighting_corner

	var/max = max(cr.largest_color_luminosity, cg.largest_color_luminosity, cb.largest_color_luminosity, ca.largest_color_luminosity)

	var/rr = cr.cache_r
	var/rg = cr.cache_g
	var/rb = cr.cache_b

	var/gr = cg.cache_r
	var/gg = cg.cache_g
	var/gb = cg.cache_b

	var/br = cb.cache_r
	var/bg = cb.cache_g
	var/bb = cb.cache_b

	var/ar = ca.cache_r
	var/ag = ca.cache_g
	var/ab = ca.cache_b

	#if LIGHTING_SOFT_THRESHOLD != 0
	var/set_luminosity = max > LIGHTING_SOFT_THRESHOLD
	#else
	// Because of floating points�?, it won't even be a flat 0.
	// This number is mostly arbitrary.
	var/set_luminosity = max > 1e-6
	#endif

	if((rr & gr & br & ar) && (rg + gg + bg + ag + rb + gb + bb + ab == 8))
	//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		icon_state = "transparent"
		color = null
	else if(!set_luminosity)
		icon_state = "dark"
		color = null
	else
		icon_state = null
		color = list(
			rr, rg, rb, 00,
			gr, gg, gb, 00,
			br, bg, bb, 00,
			ar, ag, ab, 00,
			00, 00, 00, 01
		)

	if(cr.applying_additive || cg.applying_additive || cb.applying_additive || ca.applying_additive)
		myturf.underlays -= additive_underlay
		additive_underlay.icon_state = "light"
		var/arr = cr.add_r
		var/arb = cr.add_b
		var/arg = cr.add_g

		var/agr = cg.add_r
		var/agb = cg.add_b
		var/agg = cg.add_g

		var/abr = cb.add_r
		var/abb = cb.add_b
		var/abg = cb.add_g

		var/aarr = ca.add_r
		var/aarb = ca.add_b
		var/aarg = ca.add_g

		additive_underlay.color = list(
			arr, arg, arb, 00,
			agr, agg, agb, 00,
			abr, abg, abb, 00,
			aarr, aarg, aarb, 00,
			00, 00, 00, 01
		)
		myturf.underlays += additive_underlay
	else
		myturf.underlays -= additive_underlay

	// Use luminosity directly because we are the lighting object
	// and not the turf
	luminosity = set_luminosity

	if (myturf.above)
		if(myturf.above.shadower)
			myturf.above.shadower.copy_lighting(src, myturf.loc, myturf)
		else
			myturf.above.update_mimic()

// Variety of overrides so the overlays don't get affected by weird things.

/atom/movable/lighting_object/update_luminosity()
	return

/atom/movable/lighting_object/ex_act(severity)
	return 0

/atom/movable/lighting_object/singularity_act()
	return

/atom/movable/lighting_object/singularity_pull()
	return

/atom/movable/lighting_object/blob_act()
	return

/atom/movable/lighting_object/onTransitZ()
	return

/atom/movable/lighting_object/wash(clean_types)
	SHOULD_CALL_PARENT(FALSE)
	return

// Override here to prevent things accidentally moving around overlays.
/atom/movable/lighting_object/forceMove(atom/destination, var/no_tp=FALSE, var/harderforce = FALSE)
	if(harderforce)
		. = ..()
