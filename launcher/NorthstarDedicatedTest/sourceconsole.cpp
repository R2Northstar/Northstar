#include "pch.h"
#include "sourceconsole.h"
#include "sourceinterface.h"

SourceInterface<CGameConsole>* g_SourceGameConsole;

void InitialiseSourceConsole(HMODULE baseAddress)
{
	SourceInterface<CGameConsole> console = SourceInterface<CGameConsole>("client.dll", "CGameConsole");
	console->Initialize();
	console->Activate();

	g_SourceGameConsole = &console;
}