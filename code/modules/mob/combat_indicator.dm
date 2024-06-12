#define COMBAT_NOTICE_COOLDOWN 10 SECONDS
/proc/GenerateCombatOverlay()
	var/mutable_appearance/combat_indicator = mutable_appearance('icons/mob/combat_indicator.dmi', "combat", FLY_LAYER)
	combat_indicator.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	return combat_indicator

/mob/living
	/// Is combat indicator enabled for this mob? Boolean.
	var/combat_indicator = FALSE
	/// The actual combat indicator
	var/static/mutable_appearance/combat_indicator_overlay
	/// When is the next time this mob will be able to use flick_emote and put the fluff text in chat?
	var/nextcombatpopup = 0

/mob/living/proc/combat_indicator_unconscious_signal()
	SIGNAL_HANDLER
	if(stat < UNCONSCIOUS) // sanity check because something is calling this signal improperly -- it may be due to adjustconciousness()
		stack_trace("Improper COMSIG_LIVING_STATUS_UNCONSCIOUS sent; mob is not unconscious")
		return
	set_combat_indicator(FALSE)

/**
 * Called whenever a mob's CI status changes for any reason.
 *
 * Checks if the mob is dead, if config disallows CI, or if the current CI status is the same as state, and if it is, it will change CI status to state.
 *
 * Arguments:
 * * state -- Boolean. Inherited from the procs that call this, basically it's what that proc wants CI to change to - true or false, on or off.
 */

/mob/living/proc/set_combat_indicator(state)
	if(!combat_indicator_overlay)
		combat_indicator_overlay = GenerateCombatOverlay()
	
	if(stat == DEAD)
		combat_indicator = FALSE

	if(combat_indicator == state) // If the mob is dead (should not happen) or if the combat_indicator is the same as state (also shouldnt happen) kill the proc.
		return

	combat_indicator = state

	if(combat_indicator)
		if(world.time > nextcombatpopup) // As of the time of writing, COMBAT_NOTICE_COOLDOWN is 10 secs, so this is asking "has 10 secs past between last activation of CI?"
			nextcombatpopup = world.time + COMBAT_NOTICE_COOLDOWN
			// playsound(src, 'sound/machines/chime.ogg', 10, ignore_walls = FALSE)
			add_overlay(combat_indicator_overlay)
			visible_message("<span class='warning'>[src] gets ready for combat!</span>")
		combat_indicator = TRUE
		log_message("<font color='red'>has turned ON the combat indicator!</font>", LOG_ATTACK)
		RegisterSignal(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, .proc/combat_indicator_unconscious_signal) //From now on, whenever this mob falls unconcious, the referenced proc will fire.
	else
		cut_overlay(combat_indicator_overlay)
		combat_indicator = FALSE
		log_message("<font color='blue'>has turned OFF the combat indicator!</font>", LOG_ATTACK)
		UnregisterSignal(src, COMSIG_LIVING_STATUS_UNCONSCIOUS) //combat_indicator_unconcious_signal will no longer be fired if this mob is unconcious.
	update_vision_cone()
