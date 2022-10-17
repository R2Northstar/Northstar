#include "pch.h"
#include "modmanager.h"
#include "squirrel.h"

// array<string> function NSGetModNames()
SQRESULT SQ_GetModNames(HSquirrelVM* sqvm)
{
	g_pSquirrel<ScriptContext::UI>->newarray(sqvm, 0);

	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, mod.Name.c_str());
		g_pSquirrel<ScriptContext::UI>->arrayappend(sqvm, -2);
	}

	return SQRESULT_NOTNULL;
}

// bool function NSIsModEnabled(string modName)
SQRESULT SQ_IsModEnabled(HSquirrelVM* sqvm)
{
	const SQChar* modName = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			g_pSquirrel<ScriptContext::UI>->pushbool(sqvm, mod.m_bEnabled);
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

// void function NSSetModEnabled(string modName, bool enabled)
SQRESULT SQ_SetModEnabled(HSquirrelVM* sqvm)
{
	const SQChar* modName = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 1);
	const SQBool enabled = g_pSquirrel<ScriptContext::UI>->getbool(sqvm, 2);

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

// string function NSGetModDescriptionByModName(string modName)
SQRESULT SQ_GetModDescription(HSquirrelVM* sqvm)
{
	const SQChar* modName = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, mod.Description.c_str());
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

// string function NSGetModVersionByModName(string modName)
SQRESULT SQ_GetModVersion(HSquirrelVM* sqvm)
{
	const SQChar* modName = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, mod.Version.c_str());
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

// string function NSGetModDownloadLinkByModName(string modName)
SQRESULT SQ_GetModDownloadLink(HSquirrelVM* sqvm)
{
	const SQChar* modName = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, mod.DownloadLink.c_str());
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

// int function NSGetModLoadPriority(string modName)
SQRESULT SQ_GetModLoadPriority(HSquirrelVM* sqvm)
{
	const SQChar* modName = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			g_pSquirrel<ScriptContext::UI>->pushinteger(sqvm, mod.LoadPriority);
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

// bool function NSIsModRequiredOnClient(string modName)
SQRESULT SQ_IsModRequiredOnClient(HSquirrelVM* sqvm)
{
	const SQChar* modName = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			g_pSquirrel<ScriptContext::UI>->pushbool(sqvm, mod.RequiredOnClient);
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

// array<string> function NSGetModConvarsByModName(string modName)
SQRESULT SQ_GetModConvars(HSquirrelVM* sqvm)
{
	const SQChar* modName = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 1);
	g_pSquirrel<ScriptContext::UI>->newarray(sqvm, 0);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			for (ModConVar* cvar : mod.ConVars)
			{
				g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, cvar->Name.c_str());
				g_pSquirrel<ScriptContext::UI>->arrayappend(sqvm, -2);
			}

			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NOTNULL; // return empty array
}

// void function NSReloadMods()
SQRESULT SQ_ReloadMods(HSquirrelVM* sqvm)
{
	g_pModManager->LoadMods();
	return SQRESULT_NULL;
}

ON_DLL_LOAD_CLIENT_RELIESON("client.dll", ScriptModMenu, ClientSquirrel, (CModule module))
{
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"array<string>", "NSGetModNames", "", "Returns the names of all loaded mods", SQ_GetModNames);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"bool", "NSIsModEnabled", "string modName", "Returns whether a given mod is enabled", SQ_IsModEnabled);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"void", "NSSetModEnabled", "string modName, bool enabled", "Sets whether a given mod is enabled", SQ_SetModEnabled);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"string", "NSGetModDescriptionByModName", "string modName", "Returns a given mod's description", SQ_GetModDescription);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"string", "NSGetModVersionByModName", "string modName", "Returns a given mod's version", SQ_GetModVersion);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"string", "NSGetModDownloadLinkByModName", "string modName", "Returns a given mod's download link", SQ_GetModDownloadLink);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"bool",
		"NSIsModRequiredOnClient",
		"string modName",
		"Returns whether a given mod is required on connecting clients",
		SQ_IsModRequiredOnClient);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"int", "NSGetModLoadPriority", "string modName", "Returns a given mod's load priority", SQ_GetModLoadPriority);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"array<string>", "NSGetModConvarsByModName", "string modName", "Returns the names of all a given mod's cvars", SQ_GetModConvars);

	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("void", "NSReloadMods", "", "Reloads mods", SQ_ReloadMods);
}
