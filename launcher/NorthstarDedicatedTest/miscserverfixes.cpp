#include "pch.h"
#include "miscserverfixes.h"
#include "hookutils.h"

void InitialiseMiscServerFixes(HMODULE baseAddress)
{
	// ret at the start of the concommand GenerateObjFile as it can crash servers
	{
		char* ptr = reinterpret_cast<char*>(baseAddress) + 0x38D920;
		TempReadWrite rw(ptr);
		*ptr = 0xC3;
	}

	// nop out call to VGUI shutdown since it crashes the game when quitting from the console
	{
		char* ptr = reinterpret_cast<char*>(baseAddress) + 0x154A96;
		TempReadWrite rw(ptr);
		*(ptr++) = 0x90; // nop
		*(ptr++) = 0x90; // nop
		*(ptr++) = 0x90; // nop
		*(ptr++) = 0x90; // nop
		*ptr = 0x90;	 // nop
	}

	// ret at the start of CServerGameClients::ClientCommandKeyValues as it has no benefit and is forwarded to client (i.e. security issue)
	// this prevents the attack vector of client=>server=>client, however server=>client also has clientside patches
	{
		char* ptr = reinterpret_cast<char*>(baseAddress) + 0x153920;
		TempReadWrite rw(ptr);
		*ptr = 0xC3;
	}
}

void InitialiseMiscEngineServerFixes(HMODULE baseAddress) 
{
	
}