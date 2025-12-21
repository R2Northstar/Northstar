#include "mods/modmanager.h"
#include "squirrel/squirrel.h"

template <ScriptContext context> void ModToSquirrel(HSQUIRRELVM sqvm, Mod& mod)
{
	g_pSquirrel[context]->pushnewstructinstance(sqvm, 9);

	// name
	g_pSquirrel[context]->pushstring(sqvm, mod.Name.c_str(), -1);
	g_pSquirrel[context]->sealstructslot(sqvm, 0);

	// description
	g_pSquirrel[context]->pushstring(sqvm, mod.Description.c_str(), -1);
	g_pSquirrel[context]->sealstructslot(sqvm, 1);

	// version
	g_pSquirrel[context]->pushstring(sqvm, mod.Version.c_str(), -1);
	g_pSquirrel[context]->sealstructslot(sqvm, 2);

	// download link
	g_pSquirrel[context]->pushstring(sqvm, mod.DownloadLink.c_str(), -1);
	g_pSquirrel[context]->sealstructslot(sqvm, 3);

	// load priority
	g_pSquirrel[context]->pushinteger(sqvm, mod.LoadPriority);
	g_pSquirrel[context]->sealstructslot(sqvm, 4);

	// enabled
	g_pSquirrel[context]->pushbool(sqvm, mod.m_bEnabled);
	g_pSquirrel[context]->sealstructslot(sqvm, 5);

	// required on client
	g_pSquirrel[context]->pushbool(sqvm, mod.RequiredOnClient);
	g_pSquirrel[context]->sealstructslot(sqvm, 6);

	// is remote
	g_pSquirrel[context]->pushbool(sqvm, mod.m_bIsRemote);
	g_pSquirrel[context]->sealstructslot(sqvm, 7);

	// convars
	g_pSquirrel[context]->newarray(sqvm);
	for (ModConVar* cvar : mod.ConVars)
	{
		g_pSquirrel[context]->pushstring(sqvm, cvar->Name.c_str());
		g_pSquirrel[context]->arrayappend(sqvm, -2);
	}
	g_pSquirrel[context]->sealstructslot(sqvm, 8);

	// add current object to squirrel array
	g_pSquirrel[context]->arrayappend(sqvm, -2);
}

ADD_SQFUNC("array<ModInfo>", NSGetModsInformation, "", "", ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	g_pSquirrel[context]->newarray(sqvm, 0);

	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		ModToSquirrel<context>(sqvm, mod);
	}

	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("array<ModInfo>", NSGetModInformation, "string modName", "", ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	const SQChar* modName = g_pSquirrel[context]->getstring(sqvm, 1);
	g_pSquirrel[context]->newarray(sqvm, 0);

	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (mod.Name.compare(modName) != 0)
		{
			continue;
		}
		ModToSquirrel<context>(sqvm, mod);
	}

	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("array<string>", NSGetModNames, "", "", ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	g_pSquirrel[context]->newarray(sqvm, 0);

	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		g_pSquirrel[context]->pushstring(sqvm, mod.Name.c_str());
		g_pSquirrel[context]->arrayappend(sqvm, -2);
	}

	return SQRESULT_NOTNULL;
}

ADD_SQFUNC(
	"void",
	NSSetModEnabled,
	"string modName, string modVersion, bool enabled",
	"",
	ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	const SQChar* modName = g_pSquirrel[context]->getstring(sqvm, 1);
	const SQChar* modVersion = g_pSquirrel[context]->getstring(sqvm, 2);
	const SQBool enabled = g_pSquirrel[context]->getbool(sqvm, 3);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName) && !mod.Version.compare(modVersion))
		{
			mod.m_bEnabled = enabled;
			return SQRESULT_NULL;
		}
	}

	return SQRESULT_NULL;
}

ADD_SQFUNC("void", NSReloadMods, "", "", ScriptContext::UI)
{
	NOTE_UNUSED(sqvm);
	g_pModManager->LoadMods();
	return SQRESULT_NULL;
}
