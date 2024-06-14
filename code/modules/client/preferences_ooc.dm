/datum/preferences/proc/handle_ooc_topic(mob/user, href_list)
	switch(href_list["preference"])
		if("erp_select")
			var/erp_input = input(user, "Choose your ERP preference.", "ERP Preference") as null|anything in ERP_PREF_LIST
			if(erp_input)
				erp_pref = erp_input
		if("erp_nc_select")
			var/erp_nc_input = input(user, "Choose your non-con preference. This has the ability to disable non-con mechanics for your character.", "Non-Con Preference") as null|anything in ERP_PREF_LIST
			if(erp_nc_input)
				erp_nc_pref = erp_nc_input
		if("erp_mechanics_select")
			var/erp_mechanics_input = input(user, "Choose your ERP mechanics preference. This has the ability to completely disable ERP mechanics for your character.", "ERP Mechanics Preference") as null|anything in ERP_MECHANICS_LIST
			if(erp_mechanics_input)
				erp_mechanics_pref = erp_mechanics_input
		if("ooc_notes")
			var/msg = stripped_multiline_input(usr, "Set always-visible OOC notes related to content preferences. THIS IS NOT FOR CHARACTER DESCRIPTIONS!", "OOC Notes", html_decode(features["ooc_notes"]), MAX_FLAVOR_LEN, TRUE)
			if(!isnull(msg))
				features["ooc_notes"] = msg

/datum/preferences/proc/print_ooc_page()
	var/list/dat = list()
	dat += "<b>ERP:</b> <a href='?_src_=prefs;preference=erp_select;task=change_ooc_prefs'>[erp_pref || "FUCK!"]</a><BR>"
	dat += "<b>Non-Con:</b> <a href='?_src_=prefs;preference=erp_nc_select;task=change_ooc_prefs'>[erp_nc_pref || "FUCK!"]</a><BR>"
	dat += "<b>ERP Mechanics:</b> <a href='?_src_=prefs;preference=erp_mechanics_select;task=change_ooc_prefs'>[erp_mechanics_pref || "FUCK!"]</a><BR>"
	dat += "<br><b>OOC Notes:</b> <a href='?_src_=prefs;preference=ooc_notes;task=change_ooc_prefs'>Change</a>"
	if(length(features["ooc_notes"]) <= 40)
		if(!length(features["ooc_notes"]))
			dat += "\[...\]"
		else
			dat += "[features["ooc_notes"]]"
	else
		dat += "[TextPreview(features["ooc_notes"])]..."
	return dat

/datum/preferences/proc/ShowOOCPrefs(mob/user)
	var/list/dat = list()
	dat += "<style>span.color_holder_box{display: inline-block; width: 20px; height: 8px; border:1px solid #000; padding: 0px;}</style>"
	dat += print_ooc_page()
	var/datum/browser/popup = new(user, "ooc_prefs", "<div align='center'>OOC Prefs</div>", 400, 300)
	popup.set_content(dat.Join())
	popup.open(FALSE)
