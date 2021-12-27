#include "pch.h"
#include "miscserverfixes.h"
#include "hookutils.h"

void InitialiseMiscServerFixes(HMODULE baseAddress)
{
	// ret at the start of the concommand GenerateObjFile as it can crash servers
	{
		void* ptr = (char*)baseAddress + 0x38D920;
		TempReadWrite rw(ptr);
		*((char*)ptr) = (char)0xC3;
	}
}