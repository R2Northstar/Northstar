#include "pch.h"
#include "miscserverfixes.h"
#include "hookutils.h"

#include "NSMem.h"

void InitialiseMiscServerFixes(HMODULE baseAddress)
{
	uintptr_t ba = (uintptr_t)baseAddress;

	// ret at the start of the concommand GenerateObjFile as it can crash servers
	{
		NSMem::BytePatch(ba + 0x38D920, "C3");
	}

	// nop out call to VGUI shutdown since it crashes the game when quitting from the console
	{
		NSMem::NOP(ba + 0x154A96, 5);
	}

	// ret at the start of CServerGameClients::ClientCommandKeyValues as it has no benefit and is forwarded to client (i.e. security issue)
	// this prevents the attack vector of client=>server=>client, however server=>client also has clientside patches
	{
		NSMem::BytePatch(ba + 0x153920, "C3");
	}
}