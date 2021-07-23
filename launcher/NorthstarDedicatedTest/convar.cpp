#include "pch.h"
#include "convar.h"
#include <set>

// should this be in modmanager?
std::set<std::string> g_CustomConvars; // this is used in modloading code to determine whether we've registered a mod convar already

typedef void(*ConVarConstructorType)(ConVar* newVar, const char* name, const char* defaultValue, int flags, const char* helpString);
ConVarConstructorType conVarConstructor;

ConVar* RegisterConVar(const char* name, const char* defaultValue, int flags, const char* helpString)
{
	spdlog::info("Registering Convar {}", name);

	// no need to free this ever really, it should exist as long as game does
	ConVar* newVar = new ConVar;
	conVarConstructor(newVar, name, defaultValue, flags, helpString);

	g_CustomConvars.insert(name);

	return newVar;
}

void InitialiseConVars(HMODULE baseAddress)
{
	conVarConstructor = (ConVarConstructorType)((char*)baseAddress + 0x416200);
}