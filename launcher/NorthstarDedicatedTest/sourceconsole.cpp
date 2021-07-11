#include "pch.h"
#include "sourceconsole.h"
#include "sourceinterface.h"
#include "hookutils.h"
#include <iostream>

SourceInterface<CGameConsole>* g_pSourceGameConsole;

typedef void(*weaponlisttype)();
weaponlisttype weaponlist;
void CommandWeaponListHook()
{
	std::cout << "TEMP: toggling console... REPLACE THIS WITH ACTUAL CONCOMMAND SUPPORT SOON" << std::endl;

	(*g_pSourceGameConsole)->Activate();
}

CreateInterfaceFn createInterface;
void* __fastcall InitialiseConsoleOnUIInit(const char* pName, int* pReturnCode)
{
	std::cout << pName << std::endl;
	void* ret = createInterface(pName, pReturnCode);

	if (!strcmp(pName, "GameClientExports001"))
		(*g_pSourceGameConsole)->Initialize();

	return ret;
}

void InitialiseSourceConsole(HMODULE baseAddress)
{
	g_pSourceGameConsole = new SourceInterface<CGameConsole>("client.dll", "GameConsole004");

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x73BA00, &InitialiseConsoleOnUIInit, reinterpret_cast<LPVOID*>(&createInterface));
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x10C080, &CommandWeaponListHook, reinterpret_cast<LPVOID*>(&weaponlist));
}