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
	data["active_bounties"] = bounties_to_ui_data(SSbounties.accepted_bounties)
	data["available_bounties"] = bounties_to_ui_data(SSbounties.available_bounties)
	data["archived_bounties"] = bounties_to_ui_data(SSbounties.archived_bounties)
	data["reputation"] = SSbounties.reputation
	return data

/obj/machinery/computer/bounty/proc/bounties_to_ui_data(bountylist)
	. = list()
	for(var/datum/bounty/bounty in bountylist)
		. += list(list(
			"title" = bounty.name,
			"description" = bounty.description,
			"author" = bounty.author,
			"reward" = bounty.reward,
			"completion" = bounty.completion_string(),
			"status" = bounty.status,
			"reference" = FAST_REF(bounty),
			"timeremaining" = bounty.expiration_time - world.time
		))
	return .

/obj/machinery/computer/bounty/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("Accept")
			var/datum/bounty/cashmoney = locate(params["reference"]) in SSbounties.available_bounties
			if(cashmoney)
				cashmoney.accept()
			return TRUE

#undef PRINTER_TIMEOUT
