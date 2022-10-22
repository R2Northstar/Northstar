#include "pch.h"
#include "misccommands.h"
#include "concommand.h"
#include "playlist.h"
#include "r2engine.h"
#include "r2client.h"
#include "tier0.h"
#include "hoststate.h"
#include "masterserver.h"
#include "modmanager.h"
#include "serverauthentication.h"
#include "squirrel.h"

void ConCommand_force_newgame(const CCommand& arg)
{
	if (arg.ArgC() < 2)
		return;

	R2::g_pHostState->m_iNextState = R2::HostState_t::HS_NEW_GAME;
	strncpy(R2::g_pHostState->m_levelName, arg.Arg(1), sizeof(R2::g_pHostState->m_levelName));
}

void ConCommand_ns_start_reauth_and_leave_to_lobby(const CCommand& arg)
{
	// hack for special case where we're on a local server, so we erase our own newly created auth data on disconnect
	g_pMasterServerManager->m_bNewgameAfterSelfAuth = true;
	g_pMasterServerManager->AuthenticateWithOwnServer(R2::g_pLocalPlayerUserID, g_pMasterServerManager->m_sOwnClientAuthToken);
}

void ConCommand_ns_end_reauth_and_leave_to_lobby(const CCommand& arg)
{
	if (g_pServerAuthentication->m_RemoteAuthenticationData.size())
		R2::g_pCVar->FindVar("serverfilter")->SetValue(g_pServerAuthentication->m_RemoteAuthenticationData.begin()->first.c_str());

	// weird way of checking, but check if client script vm is initialised, mainly just to allow players to cancel this
	if (g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM)
	{
		g_pServerAuthentication->m_bNeedLocalAuthForNewgame = true;

		// this won't set playlist correctly on remote clients, don't think they can set playlist until they've left which sorta
		// fucks things should maybe set this in HostState_NewGame?
		R2::SetCurrentPlaylist("tdm");
		strcpy(R2::g_pHostState->m_levelName, "mp_lobby");
		R2::g_pHostState->m_iNextState = R2::HostState_t::HS_NEW_GAME;
	}
}

void AddMiscConCommands()
{
	RegisterConCommand(
		"force_newgame",
		ConCommand_force_newgame,
		"forces a map load through directly setting g_pHostState->m_iNextState to HS_NEW_GAME",
		FCVAR_NONE);

	RegisterConCommand(
		"ns_start_reauth_and_leave_to_lobby",
		ConCommand_ns_start_reauth_and_leave_to_lobby,
		"called by the server, used to reauth and return the player to lobby when leaving a game",
		FCVAR_SERVER_CAN_EXECUTE);

	// this is a concommand because we make a deferred call to it from another thread
	RegisterConCommand("ns_end_reauth_and_leave_to_lobby", ConCommand_ns_end_reauth_and_leave_to_lobby, "", FCVAR_NONE);
}

// fixes up various cvar flags to have more sane values
void FixupCvarFlags()
{
	if (Tier0::CommandLine()->CheckParm("-allowdevcvars"))
	{
		// strip hidden and devonly cvar flags
		int iNumCvarsAltered = 0;
		for (auto& pair : R2::g_pCVar->DumpToMap())
		{
			// strip flags
			int flags = pair.second->GetFlags();
			if (flags & FCVAR_DEVELOPMENTONLY)
			{
				flags &= ~FCVAR_DEVELOPMENTONLY;
				iNumCvarsAltered++;
			}

			if (flags & FCVAR_HIDDEN)
			{
				flags &= ~FCVAR_HIDDEN;
				iNumCvarsAltered++;
			}

			pair.second->m_nFlags = flags;
		}

		spdlog::info("Removed {} hidden/devonly cvar flags", iNumCvarsAltered);
	}

	// make all engine client commands FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS
	// these are usually checked through CGameClient::IsEngineClientCommand, but we get more control over this if we just do it through
	// cvar flags
	const char** ppEngineClientCommands = CModule("engine.dll").Offset(0x7C5EF0).As<const char**>();

	int i = 0;
	do
	{
		ConCommandBase* pCommand = R2::g_pCVar->FindCommandBase(ppEngineClientCommands[i]);
		if (pCommand) // not all the commands in this array actually exist in respawn source
			pCommand->m_nFlags |= FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS;
	} while (ppEngineClientCommands[++i]);

	// array of cvars and the flags we want to add to them
	const std::vector<std::tuple<const char*, uint32_t>> CVAR_FIXUP_ADD_FLAGS = {
		// system commands (i.e. necessary for proper functionality)
		// servers need to be able to disconnect
		{"disconnect", FCVAR_SERVER_CAN_EXECUTE},

		// cheat commands
		{"give", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"give_server", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"givecurrentammo", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"takecurrentammo", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},

		{"switchclass", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"set", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"_setClassVarServer", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},

		{"ent_create", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"ent_throw", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"ent_setname", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"ent_teleport", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"ent_remove", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"ent_remove_all", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"ent_fire", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},

		{"particle_create", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"particle_recreate", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"particle_kill", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},

		{"test_setteam", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"melee_lunge_ent", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},

		// fcvars that should be cheats
		{"net_ignoreAllSnapshots", FCVAR_CHEAT},
		{"highlight_draw", FCVAR_CHEAT},
		// these should potentially be replicated rather than cheat, like sv_footsteps is
		// however they're defined on client, so can't make replicated atm sadly
		{"cl_footstep_event_max_dist", FCVAR_CHEAT},
		{"cl_footstep_event_max_dist_titan", FCVAR_CHEAT},
	};

	// array of cvars and the flags we want to remove from them
	const std::vector<std::tuple<const char*, uint32_t>> CVAR_FIXUP_REMOVE_FLAGS = {
		// unsure how this command works, not even sure it's used on retail servers, deffo shouldn't be used on northstar
		{"migrateme", FCVAR_SERVER_CAN_EXECUTE | FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"recheck", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS}, // we don't need this on northstar servers, it's for communities

		// unsure how these work exactly (rpt system likely somewhat stripped?), removing anyway since they won't be used
		{"rpt_client_enable", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},
		{"rpt_password", FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS},

		// these are devonly by default but should be modifyable
		// NOTE: not all of these may actually do anything or work properly in practice
		// network settings
		{"cl_updaterate_mp", FCVAR_DEVELOPMENTONLY},
		{"cl_updaterate_sp", FCVAR_DEVELOPMENTONLY},
		{"clock_bias_sp", FCVAR_DEVELOPMENTONLY},
		{"clock_bias_mp", FCVAR_DEVELOPMENTONLY},
		{"cl_interpolate", FCVAR_DEVELOPMENTONLY}, // super duper ultra fucks anims if changed
		{"cl_interpolateSoAllAnimsLoop", FCVAR_DEVELOPMENTONLY},
		{"cl_cmdrate", FCVAR_DEVELOPMENTONLY},
		{"cl_cmdbackup", FCVAR_DEVELOPMENTONLY},
		{"rate", FCVAR_DEVELOPMENTONLY},
		{"net_minroutable", FCVAR_DEVELOPMENTONLY},
		{"net_maxroutable", FCVAR_DEVELOPMENTONLY},
		{"net_lerpFields", FCVAR_DEVELOPMENTONLY},
		{"net_ignoreAllSnapshots", FCVAR_DEVELOPMENTONLY},
		{"net_chokeloop", FCVAR_DEVELOPMENTONLY},
		{"sv_unlag", FCVAR_DEVELOPMENTONLY},
		{"sv_maxunlag", FCVAR_DEVELOPMENTONLY},
		{"sv_lagpushticks", FCVAR_DEVELOPMENTONLY},
		{"sv_instancebaselines", FCVAR_DEVELOPMENTONLY},
		{"sv_voiceEcho", FCVAR_DEVELOPMENTONLY},
		{"net_compresspackets", FCVAR_DEVELOPMENTONLY},
		{"net_compresspackets_minsize", FCVAR_DEVELOPMENTONLY},
		{"net_verifyEncryption", FCVAR_DEVELOPMENTONLY}, // unsure if functional in retail

		// gameplay settings
		{"vel_samples", FCVAR_DEVELOPMENTONLY},
		{"vel_sampleFrequency", FCVAR_DEVELOPMENTONLY},
		{"sv_friction", FCVAR_DEVELOPMENTONLY},
		{"sv_stopspeed", FCVAR_DEVELOPMENTONLY},
		{"sv_airaccelerate", FCVAR_DEVELOPMENTONLY},
		{"sv_forceGrapplesToFail", FCVAR_DEVELOPMENTONLY},
		{"sv_maxvelocity", FCVAR_DEVELOPMENTONLY},
		{"sv_footsteps", FCVAR_DEVELOPMENTONLY},
		// these 2 are flagged as CHEAT above, could be made REPLICATED later potentially
		{"cl_footstep_event_max_dist", FCVAR_DEVELOPMENTONLY},
		{"cl_footstep_event_max_dist_titan", FCVAR_DEVELOPMENTONLY},
		{"sv_balanceTeams", FCVAR_DEVELOPMENTONLY},
		{"rodeo_enable", FCVAR_DEVELOPMENTONLY},
		{"sv_forceRodeoToFail", FCVAR_DEVELOPMENTONLY},
		{"player_find_rodeo_target_per_cmd", FCVAR_DEVELOPMENTONLY}, // todo test before merge
		{"hud_takesshots", FCVAR_DEVELOPMENTONLY}, // very likely does not work but would be cool if it did

		{"cam_collision", FCVAR_DEVELOPMENTONLY},
		{"cam_idealdelta", FCVAR_DEVELOPMENTONLY},
		{"cam_ideallag", FCVAR_DEVELOPMENTONLY},

		// graphics/visual settings
		{"r_hbaoRadius", FCVAR_DEVELOPMENTONLY},
		{"r_hbaoDepthMax", FCVAR_DEVELOPMENTONLY},
		{"r_hbaoBlurSharpness", FCVAR_DEVELOPMENTONLY},
		{"r_hbaoIntensity", FCVAR_DEVELOPMENTONLY},
		{"r_hbaoBias", FCVAR_DEVELOPMENTONLY},
		{"r_hbaoDistanceLerp", FCVAR_DEVELOPMENTONLY},
		{"r_hbaoBlurRadius", FCVAR_DEVELOPMENTONLY},
		{"r_hbaoExponent", FCVAR_DEVELOPMENTONLY},
		{"r_hbaoDepthFadePctDefault", FCVAR_DEVELOPMENTONLY},
		{"r_drawscreenspaceparticles", FCVAR_DEVELOPMENTONLY},
		{"ui_loadingscreen_fadeout_time", FCVAR_DEVELOPMENTONLY},
		{"ui_loadingscreen_fadein_time", FCVAR_DEVELOPMENTONLY},
		{"ui_loadingscreen_transition_time", FCVAR_DEVELOPMENTONLY},
		{"ui_loadingscreen_mintransition_time", FCVAR_DEVELOPMENTONLY},
		// these 2 could be FCVAR_CHEAT, i guess?
		{"cl_draw_player_model", FCVAR_DEVELOPMENTONLY},
		{"cl_always_draw_3p_player", FCVAR_DEVELOPMENTONLY},
		{"idcolor_neutral", FCVAR_DEVELOPMENTONLY},
		{"idcolor_ally", FCVAR_DEVELOPMENTONLY},
		{"idcolor_ally_cb1", FCVAR_DEVELOPMENTONLY},
		{"idcolor_ally_cb2", FCVAR_DEVELOPMENTONLY},
		{"idcolor_ally_cb3", FCVAR_DEVELOPMENTONLY},
		{"idcolor_enemy", FCVAR_DEVELOPMENTONLY},
		{"idcolor_enemy_cb1", FCVAR_DEVELOPMENTONLY},
		{"idcolor_enemy_cb2", FCVAR_DEVELOPMENTONLY},
		{"idcolor_enemy_cb3", FCVAR_DEVELOPMENTONLY},
		{"playerListPartyColorR", FCVAR_DEVELOPMENTONLY},
		{"playerListPartyColorG", FCVAR_DEVELOPMENTONLY},
		{"playerListPartyColorB", FCVAR_DEVELOPMENTONLY},
		{"playerListUseFriendColor", FCVAR_DEVELOPMENTONLY},
		{"fx_impact_neutral", FCVAR_DEVELOPMENTONLY},
		{"fx_impact_ally", FCVAR_DEVELOPMENTONLY},
		{"fx_impact_enemy", FCVAR_DEVELOPMENTONLY},
		{"hitch_alert_color", FCVAR_DEVELOPMENTONLY},
		{"particles_cull_all", FCVAR_DEVELOPMENTONLY},
		{"particles_cull_dlights", FCVAR_DEVELOPMENTONLY},
		{"map_settings_override", FCVAR_DEVELOPMENTONLY},
		{"highlight_draw", FCVAR_DEVELOPMENTONLY},

		// sys/engine settings
		{"sleep_when_meeting_framerate", FCVAR_DEVELOPMENTONLY},
		{"sleep_when_meeting_framerate_headroom_ms", FCVAR_DEVELOPMENTONLY},
		{"not_focus_sleep", FCVAR_DEVELOPMENTONLY},
		{"sp_not_focus_pause", FCVAR_DEVELOPMENTONLY},
		{"joy_requireFocus", FCVAR_DEVELOPMENTONLY},

		{"host_thread_mode", FCVAR_DEVELOPMENTONLY},
		{"phys_enable_simd_optimizations", FCVAR_DEVELOPMENTONLY},
		{"phys_enable_experimental_optimizations", FCVAR_DEVELOPMENTONLY},

		{"community_frame_run", FCVAR_DEVELOPMENTONLY},
		{"sv_single_core_dedi", FCVAR_DEVELOPMENTONLY},
		{"sv_stressbots", FCVAR_DEVELOPMENTONLY},

		{"fatal_script_errors", FCVAR_DEVELOPMENTONLY},
		{"fatal_script_errors_client", FCVAR_DEVELOPMENTONLY},
		{"fatal_script_errors_server", FCVAR_DEVELOPMENTONLY},
		{"script_error_on_midgame_load", FCVAR_DEVELOPMENTONLY}, // idk what this is

		{"ai_ainRebuildOnMapStart", FCVAR_DEVELOPMENTONLY},

		// cheat commands
		{"switchclass", FCVAR_DEVELOPMENTONLY},
		{"set", FCVAR_DEVELOPMENTONLY},
		{"_setClassVarServer", FCVAR_DEVELOPMENTONLY},

		// reparse commands
		{"aisettings_reparse", FCVAR_DEVELOPMENTONLY},
		{"aisettings_reparse_client", FCVAR_DEVELOPMENTONLY},
		{"damagedefs_reparse", FCVAR_DEVELOPMENTONLY},
		{"damagedefs_reparse_client", FCVAR_DEVELOPMENTONLY},
		{"playerSettings_reparse", FCVAR_DEVELOPMENTONLY},
		{"_playerSettings_reparse_Server", FCVAR_DEVELOPMENTONLY},
	};

	const std::vector<std::tuple<const char*, const char*>> CVAR_FIXUP_DEFAULT_VALUES = {
		{"sv_stressbots", "0"}, // not currently used but this is probably a bad default if we get bots working
		{"cl_pred_optimize", "0"} // fixes issues with animation prediction in thirdperson
	};

	for (auto& fixup : CVAR_FIXUP_ADD_FLAGS)
	{
		ConCommandBase* command = R2::g_pCVar->FindCommandBase(std::get<0>(fixup));
		if (command)
			command->m_nFlags |= std::get<1>(fixup);
	}

	for (auto& fixup : CVAR_FIXUP_REMOVE_FLAGS)
	{
		ConCommandBase* command = R2::g_pCVar->FindCommandBase(std::get<0>(fixup));
		if (command)
			command->m_nFlags &= ~std::get<1>(fixup);
	}

	for (auto& fixup : CVAR_FIXUP_DEFAULT_VALUES)
	{
		ConVar* cvar = R2::g_pCVar->FindVar(std::get<0>(fixup));
		if (cvar && !strcmp(cvar->GetString(), cvar->m_pszDefaultValue))
		{
			cvar->SetValue(std::get<1>(fixup));
			cvar->m_pszDefaultValue = std::get<1>(fixup);
		}
	}
}
