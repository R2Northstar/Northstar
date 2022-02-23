#include "pch.h"
#include "playlist.h"
#include "concommand.h"
#include "convar.h"
#include "gameutils.h"
#include "hookutils.h"
#include "dedicated.h"
#include "squirrel.h"

typedef char (*Onclc_SetPlaylistVarOverrideType)(void* a1, void* a2);
Onclc_SetPlaylistVarOverrideType Onclc_SetPlaylistVarOverride;

typedef int (*GetCurrentGamemodeMaxPlayersType)();
GetCurrentGamemodeMaxPlayersType GetCurrentGamemodeMaxPlayers;

// function type defined in gameutils.h
SetPlaylistVarOverrideType SetPlaylistVarOverrideOriginal;
GetCurrentPlaylistVarType GetCurrentPlaylistVarOriginal;

ConVar* Cvar_ns_use_clc_SetPlaylistVarOverride;

void SetPlaylistCommand(const CCommand& args)
{
	if (args.ArgC() < 2)
		return;

	SetCurrentPlaylist(args.Arg(1));
}

void SetPlaylistVarOverrideCommand(const CCommand& args)
{
	if (args.ArgC() < 3)
		return;

	for (int i = 1; i < args.ArgC(); i += 2)
		SetPlaylistVarOverride(args.Arg(i), args.Arg(i + 1));
}

char Onclc_SetPlaylistVarOverrideHook(void* a1, void* a2)
{
	// the private_match playlist is the only situation where there should be any legitimate sending of this netmessage
	// todo: check mp_lobby here too
	if (!Cvar_ns_use_clc_SetPlaylistVarOverride->GetBool() || strcmp(GetCurrentPlaylistName(), "private_match"))
		return 1;

	return Onclc_SetPlaylistVarOverride(a1, a2);
}

void SetPlaylistVarOverrideHook(const char* varName, const char* value)
{
	if (strlen(value) >= 64)
		return;

	SetPlaylistVarOverrideOriginal(varName, value);
}

char* GetCurrentPlaylistVarHook(const char* varName, bool useOverrides)
{
	if (!useOverrides && !strcmp(varName, "max_players"))
		useOverrides = true;

	return GetCurrentPlaylistVarOriginal(varName, useOverrides);
}

int GetCurrentGamemodeMaxPlayersHook()
{
	char* maxPlayersStr = GetCurrentPlaylistVar("max_players", 0);
	if (!maxPlayersStr)
		return GetCurrentGamemodeMaxPlayers();

	int maxPlayers = atoi(maxPlayersStr);
	return maxPlayers;
}

void InitialisePlaylistHooks(HMODULE baseAddress)
{
	RegisterConCommand("setplaylist", SetPlaylistCommand, "Sets the current playlist", FCVAR_NONE);
	RegisterConCommand("setplaylistvaroverrides", SetPlaylistVarOverrideCommand, "sets a playlist var override", FCVAR_NONE);
	// note: clc_SetPlaylistVarOverride is pretty insecure, since it allows for entirely arbitrary playlist var overrides to be sent to the
	// server this is somewhat restricted on custom servers to prevent it being done outside of private matches, but ideally it should be
	// disabled altogether, since the custom menus won't use it anyway this should only really be accepted if you want vanilla client
	// compatibility
	Cvar_ns_use_clc_SetPlaylistVarOverride = new ConVar(
		"ns_use_clc_SetPlaylistVarOverride", "0", FCVAR_GAMEDLL, "Whether the server should accept clc_SetPlaylistVarOverride messages");

	HookEnabler hook;
	ENABLER_CREATEHOOK(
		hook, (char*)baseAddress + 0x222180, &Onclc_SetPlaylistVarOverrideHook, reinterpret_cast<LPVOID*>(&Onclc_SetPlaylistVarOverride));
	ENABLER_CREATEHOOK(
		hook, (char*)baseAddress + 0x18ED00, &SetPlaylistVarOverrideHook, reinterpret_cast<LPVOID*>(&SetPlaylistVarOverrideOriginal));
	ENABLER_CREATEHOOK(
		hook, (char*)baseAddress + 0x18C680, &GetCurrentPlaylistVarHook, reinterpret_cast<LPVOID*>(&GetCurrentPlaylistVarOriginal));
	ENABLER_CREATEHOOK(
		hook, (char*)baseAddress + 0x18C430, &GetCurrentGamemodeMaxPlayersHook, reinterpret_cast<LPVOID*>(&GetCurrentGamemodeMaxPlayers));

	// patch to prevent clc_SetPlaylistVarOverride from being able to crash servers if we reach max overrides due to a call to Error (why is
	// this possible respawn, wtf) todo: add a warning for this
	{
		void* ptr = (char*)baseAddress + 0x18ED8D;
		TempReadWrite rw(ptr);
		*((char*)ptr) = (char)0xC3; // jmp => ret
	}

	// patch to allow setplaylistvaroverride to be called before map init on dedicated and private match launched through the game
	void* ptr = (char*)baseAddress + 0x18ED17;
	TempReadWrite rw(ptr);
	*((char*)ptr) = (char)0x90;
	*((char*)ptr + 1) = (char)0x90;
	*((char*)ptr + 2) = (char)0x90;
	*((char*)ptr + 3) = (char)0x90;
	*((char*)ptr + 4) = (char)0x90;
	*((char*)ptr + 5) = (char)0x90;
}
