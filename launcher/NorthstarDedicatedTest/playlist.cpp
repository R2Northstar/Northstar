#include "pch.h"
#include "playlist.h"
#include "concommand.h"
#include "convar.h"
#include "gameutils.h"
#include "hookutils.h"

typedef char(*Onclc_SetPlaylistVarOverrideType)(void* a1, void* a2);
Onclc_SetPlaylistVarOverrideType Onclc_SetPlaylistVarOverride;

ConVar* Cvar_ns_use_clc_SetPlaylistVarOverride;

void SetPlaylistCommand(const CCommand& args)
{
	if (args.ArgC() < 2)
		return;

	SetCurrentPlaylist(args.Arg(1));
}

char Onclc_SetPlaylistVarOverrideHook(void* a1, void* a2)
{
	// the private_match playlist is the only situation where there should be any legitimate sending of this netmessage
	// todo: check mp_lobby here too
	if (!Cvar_ns_use_clc_SetPlaylistVarOverride->m_nValue || strcmp(GetCurrentPlaylistName(), "private_match"))
		return 1;

	return Onclc_SetPlaylistVarOverride(a1, a2);
}

void InitialisePlaylistHooks(HMODULE baseAddress)
{
	RegisterConCommand("setplaylist", SetPlaylistCommand, "Sets the current playlist", FCVAR_NONE);
	// note: clc_SetPlaylistVarOverride is pretty insecure, since it allows for entirely arbitrary playlist var overrides to be sent to the server
	// this is somewhat restricted on custom servers to prevent it being done outside of private matches, but ideally it should be disabled altogether, since the custom menus won't use it anyway
	// this should only really be accepted if you want vanilla client compatibility
	Cvar_ns_use_clc_SetPlaylistVarOverride = RegisterConVar("ns_use_clc_SetPlaylistVarOverride", "0", FCVAR_GAMEDLL, "Whether the server should accept clc_SetPlaylistVarOverride messages");

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x222180, &Onclc_SetPlaylistVarOverrideHook, reinterpret_cast<LPVOID*>(&Onclc_SetPlaylistVarOverride));

	// patch to prevent clc_SetPlaylistVarOverride from being able to crash servers if we reach max overrides due to a call to Error (why is this possible respawn, wtf)
	// todo: add a warning for this
	{
		void* ptr = (char*)baseAddress + 0x18ED8D;
		TempReadWrite rw(ptr);
		*((char*)ptr) = 0xC3; // jmp => ret
	}
}