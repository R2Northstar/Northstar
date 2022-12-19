#include "pch.h"
#include "engine/hoststate.h"
#include "masterserver/masterserver.h"
#include "server/auth/serverauthentication.h"
#include "server/serverpresence.h"
#include "shared/playlist.h"
#include "core/tier0.h"
#include "engine/r2engine.h"
#include "shared/exploit_fixes/ns_limits.h"
#include "squirrel/squirrel.h"

AUTOHOOK_INIT()

using namespace R2;

// use the R2 namespace for game funcs
namespace R2
{
	CHostState* g_pHostState;
} // namespace R2

ConVar* Cvar_hostport;

void ServerStartingOrChangingMap()
{
	// net_data_block_enabled is required for sp, force it if we're on an sp map
	// sucks for security but just how it be
	if (!strncmp(g_pHostState->m_levelName, "sp_", 3))
		g_pCVar->FindVar("net_data_block_enabled")->SetValue(true);
}

// clang-format off
AUTOHOOK(CHostState__State_NewGame, engine.dll + 0x16E7D0,
void, __fastcall, (CHostState* self))
// clang-format on
{
	spdlog::info("HostState: NewGame");

	Cbuf_AddText(Cbuf_GetCurrentPlayer(), "exec autoexec_ns_server", cmd_source_t::kCommandSrcCode);
	Cbuf_Execute();

	// need to do this to ensure we don't go to private match
	if (g_pServerAuthentication->m_bNeedLocalAuthForNewgame)
		SetCurrentPlaylist("tdm");

	ServerStartingOrChangingMap();

	double dStartTime = Tier0::Plat_FloatTime();
	CHostState__State_NewGame(self);
	spdlog::info("loading took {}s", Tier0::Plat_FloatTime() - dStartTime);

	// setup server presence
	g_pServerPresence->CreatePresence();
	g_pServerPresence->SetMap(g_pHostState->m_levelName, true);
	g_pServerPresence->SetPlaylist(GetCurrentPlaylistName());
	g_pServerPresence->SetPort(Cvar_hostport->GetInt());

	g_pServerAuthentication->StartPlayerAuthServer();
	g_pServerAuthentication->m_bNeedLocalAuthForNewgame = false;
}

// clang-format off
AUTOHOOK(CHostState__State_ChangeLevelMP, engine.dll + 0x16E520,
void, __fastcall, (CHostState* self))
// clang-format on
{
	spdlog::info("HostState: ChangeLevelMP");

	ServerStartingOrChangingMap();

	double dStartTime = Tier0::Plat_FloatTime();
	CHostState__State_ChangeLevelMP(self);
	spdlog::info("loading took {}s", Tier0::Plat_FloatTime() - dStartTime);

	g_pServerPresence->SetMap(g_pHostState->m_levelName);
}

// clang-format off
AUTOHOOK(CHostState__State_GameShutdown, engine.dll + 0x16E640,
void, __fastcall, (CHostState* self))
// clang-format on
{
	spdlog::info("HostState: GameShutdown");

	g_pServerPresence->DestroyPresence();
	g_pServerAuthentication->StopPlayerAuthServer();

	CHostState__State_GameShutdown(self);
}

// clang-format off
AUTOHOOK(CHostState__FrameUpdate, engine.dll + 0x16DB00,
void, __fastcall, (CHostState* self, double flCurrentTime, float flFrameTime))
// clang-format on
{
	CHostState__FrameUpdate(self, flCurrentTime, flFrameTime);

	if (*R2::g_pServerState == R2::server_state_t::ss_active)
	{
		// update server presence
		g_pServerPresence->RunFrame(flCurrentTime);

		// update limits for frame
		g_pServerLimits->RunFrame(flCurrentTime, flFrameTime);
	}

	// Run Squirrel message buffer
	if (g_pSquirrel<ScriptContext::UI>->m_pSQVM != nullptr && g_pSquirrel<ScriptContext::UI>->m_pSQVM->sqvm != nullptr)
		g_pSquirrel<ScriptContext::UI>->ProcessMessageBuffer();

	if (g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM != nullptr && g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM->sqvm != nullptr)
		g_pSquirrel<ScriptContext::CLIENT>->ProcessMessageBuffer();

	if (g_pSquirrel<ScriptContext::SERVER>->m_pSQVM != nullptr && g_pSquirrel<ScriptContext::SERVER>->m_pSQVM->sqvm != nullptr)
		g_pSquirrel<ScriptContext::SERVER>->ProcessMessageBuffer();
}

ON_DLL_LOAD_RELIESON("engine.dll", HostState, ConVar, (CModule module))
{
	AUTOHOOK_DISPATCH()

	g_pHostState = module.Offset(0x7CF180).As<CHostState*>();
	Cvar_hostport = module.Offset(0x13FA6070).As<ConVar*>();
}
