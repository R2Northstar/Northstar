#include "pch.h"
#include "concommand.h"
#include "gameutils.h"
#include "misccommands.h"
#include <iostream>

typedef void (*ConCommandConstructorType)(
	ConCommand* newCommand, const char* name, void (*callback)(const CCommand&), const char* helpString, int flags, void* parent);
ConCommandConstructorType conCommandConstructor;

void RegisterConCommand(const char* name, void (*callback)(const CCommand&), const char* helpString, int flags)
{
	spdlog::info("Registering ConCommand {}", name);

	// no need to free this ever really, it should exist as long as game does
	ConCommand* newCommand = new ConCommand;
	conCommandConstructor(newCommand, name, callback, helpString, flags, nullptr);
}

ConCommand* FindConCommand(const char* name)
{
	ICvar* icvar =
		*g_pCvar; // hellish call because i couldn't get icvar vtable stuff in convar.h to get the right offset for whatever reason
	typedef ConCommand* (*FindCommandBaseType)(ICvar * self, const char* varName);
	FindCommandBaseType FindCommandBase = *(FindCommandBaseType*)((*(char**)icvar) + 112);
	return FindCommandBase(icvar, name);
}

void InitialiseConCommands(HMODULE baseAddress)
{
	conCommandConstructor = (ConCommandConstructorType)((char*)baseAddress + 0x415F60);
	AddMiscConCommands();
}