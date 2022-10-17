#include "pch.h"
#include "playlist.h"
#include "concommand.h"
#include "convar.h"
#include "squirrel.h"
#include "hoststate.h"
#include "serverpresence.h"

AUTOHOOK_INIT()

// use the R2 namespace for game funcs
namespace R2
{
	const char* (*GetCurrentPlaylistName)();
	void (*SetCurrentPlaylist)(const char* pPlaylistName);
	void (*SetPlaylistVarOverride)(const char* pVarName, const char* pValue);
	const char* (*GetCurrentPlaylistVar)(const char* pVarName, bool bUseOverrides);
} // namespace R2

ConVar* Cvar_ns_use_clc_SetPlaylistVarOverride;

// clang-format off
AUTOHOOK(clc_SetPlaylistVarOverride__Process, engine.dll + 0x222180,
char, __fastcall, (void* a1, void* a2))
// clang-format on
{
	// the private_match playlist on mp_lobby is the only situation where there should be any legitimate sending of this netmessage
	if (!Cvar_ns_use_clc_SetPlaylistVarOverride->GetBool() || strcmp(R2::GetCurrentPlaylistName(), "private_match") ||
		strcmp(R2::g_pHostState->m_levelName, "mp_lobby"))
		return 1;

	return clc_SetPlaylistVarOverride__Process(a1, a2);
}

// clang-format off
AUTOHOOK(SetCurrentPlaylist, engine.dll + 0x18EB20,
bool, __fastcall, (const char* pPlaylistName))
// clang-format on
{
	bool bSuccess = SetCurrentPlaylist(pPlaylistName);

	if (bSuccess)
	{
		spdlog::info("Set playlist to {}", R2::GetCurrentPlaylistName());
		g_pServerPresence->SetPlaylist(R2::GetCurrentPlaylistName());
	}

	return bSuccess;
}

// clang-format off
AUTOHOOK(SetPlaylistVarOverride, engine.dll + 0x18ED00,
void, __fastcall, (const char* pVarName, const char* pValue))
// clang-format on
{
	if (strlen(pValue) >= 64)
		return;

	SetPlaylistVarOverride(pVarName, pValue);
}

// clang-format off
AUTOHOOK(GetCurrentPlaylistVar, engine.dll + 0x18C680,
const char*, __fastcall, (const char* pVarName, bool bUseOverrides))
// clang-format on
{
	if (!bUseOverrides && !strcmp(pVarName, "max_players"))
		bUseOverrides = true;

	return GetCurrentPlaylistVar(pVarName, bUseOverrides);
}

// clang-format off
AUTOHOOK(GetCurrentGamemodeMaxPlayers, engine.dll + 0x18C430,
int, __fastcall, ())
// clang-format on
{
	const char* pMaxPlayers = R2::GetCurrentPlaylistVar("max_players", 0);
	if (!pMaxPlayers)
		return GetCurrentGamemodeMaxPlayers();

	int iMaxPlayers = atoi(pMaxPlayers);
	return iMaxPlayers;
}

void ConCommand_playlist(const CCommand& args)
{
	if (args.ArgC() < 2)
		return;

	R2::SetCurrentPlaylist(args.Arg(1));
}

void ConCommand_setplaylistvaroverride(const CCommand& args)
{
	if (args.ArgC() < 3)
		return;

	for (int i = 1; i < args.ArgC(); i += 2)
		R2::SetPlaylistVarOverride(args.Arg(i), args.Arg(i + 1));
}

ON_DLL_LOAD_RELIESON("engine.dll", PlaylistHooks, (ConCommand, ConVar), (CModule module))
{
	AUTOHOOK_DISPATCH()

	R2::GetCurrentPlaylistName = module.Offset(0x18C640).As<const char* (*)()>();
	R2::SetCurrentPlaylist = module.Offset(0x18EB20).As<void (*)(const char*)>();
	R2::SetPlaylistVarOverride = module.Offset(0x18ED00).As<void (*)(const char*, const char*)>();
	R2::GetCurrentPlaylistVar = module.Offset(0x18C680).As<const char* (*)(const char*, bool)>();

	// playlist is the name of the command on respawn servers, but we already use setplaylist so can't get rid of it
	RegisterConCommand("playlist", ConCommand_playlist, "Sets the current playlist", FCVAR_NONE);
	RegisterConCommand("setplaylist", ConCommand_playlist, "Sets the current playlist", FCVAR_NONE);
	RegisterConCommand("setplaylistvaroverrides", ConCommand_setplaylistvaroverride, "sets a playlist var override", FCVAR_NONE);

	// note: clc_SetPlaylistVarOverride is pretty insecure, since it allows for entirely arbitrary playlist var overrides to be sent to the
	// server, this is somewhat restricted on custom servers to prevent it being done outside of private matches, but ideally it should be
	// disabled altogether, since the custom menus won't use it anyway this should only really be accepted if you want vanilla client
	// compatibility
	Cvar_ns_use_clc_SetPlaylistVarOverride = new ConVar(
		"ns_use_clc_SetPlaylistVarOverride", "0", FCVAR_GAMEDLL, "Whether the server should accept clc_SetPlaylistVarOverride messages");

	// patch to prevent clc_SetPlaylistVarOverride from being able to crash servers if we reach max overrides due to a call to Error (why is
	// this possible respawn, wtf) todo: add a warning for this
	module.Offset(0x18ED8D).Patch("C3");

	// patch to allow setplaylistvaroverride to be called before map init on dedicated and private match launched through the game
	module.Offset(0x18ED17).NOP(6);
}
