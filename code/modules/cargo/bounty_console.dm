#define PRINTER_TIMEOUT 10

/obj/machinery/computer/bounty
	name = "\improper Nanotrasen bounty console"
	desc = "Used to check and claim bounties offered by Nanotrasen"
	icon_screen = "bounty"
	circuit = /obj/item/circuitboard/computer/bounty
	light_color = "#E2853D"//orange
	var/printer_ready = 0 //cooldown var
	var/static/datum/bank_account/cargocash

/obj/machinery/computer/bounty/Initialize(mapload)
	. = ..()
	printer_ready = world.time + PRINTER_TIMEOUT
	cargocash = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)

/obj/machinery/computer/bounty/proc/print_paper()
	new /obj/item/paper/bounty_printout(loc)

/obj/item/paper/bounty_printout
	name = "paper - Bounties"
/*
/obj/item/paper/bounty_printout/Initialize(mapload)
	. = ..()
	var/final_paper_text = "<h2>Nanotrasen Cargo Bounties</h2></br>"

	for(var/datum/bounty/B in GLOB.bounties_list)
		if(B.claimed)
			continue
		final_paper_text += "<h3>[B.name]</h3>"
		final_paper_text += "<ul><li>Reward: [B.reward_string()]</li>"
		final_paper_text += "<li>Completed: [B.completion_string()]</li></ul>"
	add_raw_text(final_paper_text)
	update_appearance()
*/
/obj/machinery/computer/bounty/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CargoBountyConsole")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/bounty/ui_data()
	var/list/data = list()
	data["location"] = SSshuttle.supply.getStatusText()
	var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	if(D)
		data["points"] = D.account_balance
	var/message = "Remember to stamp and send back the supply manifests."
	if(SSshuttle.centcom_message)
		message = SSshuttle.centcom_message
	data["message"] = message

	var/list/exportrate_info = list()
	for(var/datum/market_category/E in GLOB.market_categories_list)
		exportrate_info += list(list(
			"name" = E.name,
			"desc" = E.description,
			"multiplier" = (E.pricemult + E.pricemult_offset) * 100))

	data["exportrates"] = exportrate_info

	return data

/obj/machinery/computer/bounty/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("ClaimBounty")
			var/datum/bounty/cashmoney = locate(params["bounty"]) in SSbounties.accepted_bounties
			if(cashmoney)
				cashmoney.claim()
			return TRUE
		if("Print")
			if(printer_ready < world.time)
				printer_ready = world.time + PRINTER_TIMEOUT
				print_paper()
				return

#undef PRINTER_TIMEOUT
