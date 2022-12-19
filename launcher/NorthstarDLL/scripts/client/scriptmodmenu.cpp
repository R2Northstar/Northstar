#include "pch.h"
#include "mods/modmanager.h"
#include "squirrel/squirrel.h"

ADD_SQFUNC("array<string>", NSGetModNames, "", "", ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	g_pSquirrel<context>->newarray(sqvm, 0);

	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		g_pSquirrel<context>->pushstring(sqvm, mod.Name.c_str());
		g_pSquirrel<context>->arrayappend(sqvm, -2);
	}

	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("bool", NSIsModEnabled, "string modName", "", ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	const SQChar* modName = g_pSquirrel<context>->getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			g_pSquirrel<context>->pushbool(sqvm, mod.m_bEnabled);
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

ADD_SQFUNC("void", NSSetModEnabled, "string modName, bool enabled", "", ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	const SQChar* modName = g_pSquirrel<context>->getstring(sqvm, 1);
	const SQBool enabled = g_pSquirrel<context>->getbool(sqvm, 2);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			mod.m_bEnabled = enabled;
			return SQRESULT_NULL;
		}
	}

	return SQRESULT_NULL;
}

ADD_SQFUNC("string", NSGetModDescriptionByModName, "string modName", "", ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	const SQChar* modName = g_pSquirrel<context>->getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			g_pSquirrel<context>->pushstring(sqvm, mod.Description.c_str());
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

ADD_SQFUNC("string", NSGetModVersionByModName, "string modName", "", ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	const SQChar* modName = g_pSquirrel<context>->getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			g_pSquirrel<context>->pushstring(sqvm, mod.Version.c_str());
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

ADD_SQFUNC("string", NSGetModDownloadLinkByModName, "string modName", "", ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	const SQChar* modName = g_pSquirrel<context>->getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			g_pSquirrel<context>->pushstring(sqvm, mod.DownloadLink.c_str());
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

ADD_SQFUNC("int", NSGetModLoadPriority, "string modName", "", ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	const SQChar* modName = g_pSquirrel<context>->getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			g_pSquirrel<context>->pushinteger(sqvm, mod.LoadPriority);
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

ADD_SQFUNC("bool", NSIsModRequiredOnClient, "string modName", "", ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	const SQChar* modName = g_pSquirrel<context>->getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			g_pSquirrel<context>->pushbool(sqvm, mod.RequiredOnClient);
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

ADD_SQFUNC(
	"array<string>", NSGetModConvarsByModName, "string modName", "", ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	const SQChar* modName = g_pSquirrel<context>->getstring(sqvm, 1);
	g_pSquirrel<context>->newarray(sqvm, 0);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			for (ModConVar* cvar : mod.ConVars)
			{
				g_pSquirrel<context>->pushstring(sqvm, cvar->Name.c_str());
				g_pSquirrel<context>->arrayappend(sqvm, -2);
			}

			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NOTNULL; // return empty array
}

ADD_SQFUNC("void", NSReloadMods, "", "", ScriptContext::UI)
{
	g_pModManager->LoadMods();
	return SQRESULT_NULL;
}
