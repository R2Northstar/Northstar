#include "pch.h"
#include "convar.h"
#include "hookutils.h"
#include "gameutils.h"
#include "sourceinterface.h"
#include <set>

// should this be in modmanager?
std::unordered_map<std::string, ConVar*> g_CustomConvars; // this is used in modloading code to determine whether we've registered a mod convar already
SourceInterface<ICvar>* g_pCvar;

typedef void(*ConVarConstructorType)(ConVar* newVar, const char* name, const char* defaultValue, int flags, const char* helpString);
ConVarConstructorType conVarConstructor;
typedef bool(*CvarIsFlagSetType)(ConVar* self, int flags);
CvarIsFlagSetType CvarIsFlagSet;

ConVar* RegisterConVar(const char* name, const char* defaultValue, int flags, const char* helpString)
{
	spdlog::info("Registering Convar {}", name);

	// no need to free this ever really, it should exist as long as game does
	ConVar* newVar = new ConVar;
	conVarConstructor(newVar, name, defaultValue, flags, helpString);

	g_CustomConvars.emplace(name, newVar);

	return newVar;
}

ConVar* FindConVar(const char* name)
{
	ICvar* icvar = *g_pCvar; // hellish call because i couldn't get icvar vtable stuff in convar.h to get the right offset for whatever reason
	typedef ConVar* (*FindConVarType)(ICvar* self, const char* varName);
	FindConVarType FindConVarInternal = *(FindConVarType*)((*(char**)icvar) + 128);
	return FindConVarInternal(icvar, name);
}

bool CvarIsFlagSetHook(ConVar* self, int flags)
{
	// unrestrict FCVAR_DEVELOPMENTONLY and FCVAR_HIDDEN
	if (self && (flags == FCVAR_DEVELOPMENTONLY || flags == FCVAR_HIDDEN))
		return false;

	return CvarIsFlagSet(self, flags);
}

void InitialiseConVars(HMODULE baseAddress)
{
	conVarConstructor = (ConVarConstructorType)((char*)baseAddress + 0x416200);
	g_pCvar = new SourceInterface<ICvar>("vstdlib.dll", "VEngineCvar007");

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x417FA0, &CvarIsFlagSetHook, reinterpret_cast<LPVOID*>(&CvarIsFlagSet));
}