#include "core/convar/convar.h"
#include "dedicated/dedicated.h"
#include "silver-bun/module.h"

ConVar* Cvar_idleKickLocal_enable;

ON_DLL_LOAD("server.dll", IdleKick, (CModule module))
{
	// Jump over the check for match_useMatchmaking in the function that handles idling
	module.Offset(0x157e68).Patch("EB 17 90 90 90 90 90 90 90 90");

	// Skip the first player (local player) in the idle kick function
	if (!IsDedicatedServer())
		CModule("server.dll").Offset(0x157ea6).Patch("BF 02");

	Cvar_idleKickLocal_enable = new ConVar(
		"idleKickLocal_enable",
		"0",
		FCVAR_GAMEDLL,
		"Enables/disables whether the local player would get kicked or not; doesn't work on dedicated servers",
		false,
		0,
		false,
		0,
		[](ConVar* cvar, const char* pOldValue, float flOldValue)
		{
			NOTE_UNUSED(cvar);
			NOTE_UNUSED(pOldValue);
			NOTE_UNUSED(flOldValue);
			if (IsDedicatedServer())
				return;

			// Toggles if the first player would get skipped in the idle kick function
			if (Cvar_idleKickLocal_enable->GetBool())
				CModule("server.dll").Offset(0x157ea6).Patch("BF 01");
			else
				CModule("server.dll").Offset(0x157ea6).Patch("BF 02");
		});
}
