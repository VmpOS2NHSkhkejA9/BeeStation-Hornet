//improvised explosives//

/obj/item/grenade/iedcasing
	name = "improvised firebomb"
	desc = "A weak, improvised incendiary device."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "improvised_grenade"
	icon_state_preview = "ied_preview"
	item_state = "flashbang"
	icon_state_preview = "chemg" // a black stick is bad to recognise as a preview
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	active = 0
	det_time = 50
	display_timer = 0
	var/range = 3
	var/list/times

/obj/item/grenade/iedcasing/Initialize(mapload)
	. = ..()
	add_overlay("improvised_grenade_filled")
	add_overlay("improvised_grenade_wired")
	times = list("5" = 10, "-1" = 20, "[rand(30,80)]" = 50, "[rand(65,180)]" = 20)// "Premature, Dud, Short Fuse, Long Fuse"=[weighting value]
	det_time = text2num(pick_weight(times))
	if(det_time < 0) //checking for 'duds'
		range = 1
		det_time = rand(30,80)
	else
		range = pick(2,2,2,3,3,3,4)

/obj/item/grenade/iedcasing/CheckParts(list/parts_list)
	..()
	var/obj/item/reagent_containers/cup/soda_cans/can = locate() in contents
	if(can)
		can.pixel_x = 0 //Reset the sprite's position to make it consistent with the rest of the IED
		can.pixel_y = 0
		var/mutable_appearance/can_underlay = new(can)
		can_underlay.layer = FLOAT_LAYER
		can_underlay.plane = FLOAT_PLANE
		underlays += can_underlay


/obj/item/grenade/iedcasing/attack_self(mob/user) //
	if(!active)
		if(!botch_check(user))
			to_chat(user, span_warning("You light the [name]!"))
			cut_overlay("improvised_grenade_filled")
			preprime(user, null, FALSE)

/obj/item/grenade/iedcasing/prime(mob/living/lanced_by) //Blowing that can up
	. = ..()
	if(!.)
		return
	update_mob()
	explosion(src.loc,-1,-1,2, flame_range = 4)	// small explosion, plus a very large fireball.
	qdel(src)

/obj/item/grenade/iedcasing/examine(mob/user)
	. = ..()
	. += "You can't tell when it will explode!"
