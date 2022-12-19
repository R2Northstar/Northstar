#include "pch.h"

ON_DLL_LOAD("server.dll", MiscServerFixes, (CModule module))
{
	// nop out call to VGUI shutdown since it crashes the game when quitting from the console
	module.Offset(0x154A96).NOP(5);
}
