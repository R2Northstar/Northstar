#include "pch.h"
#include "scriptmodmenu.h"
#include "modmanager.h"
#include "squirrel.h"
#include "dedicated.h"

// array<string> function NSGetModNames()
SQRESULT SQ_GetModNames(void* sqvm)
{
	ClientSq_newarray(sqvm, 0);

	for (Mod& mod : g_ModManager->m_loadedMods)
	{
		ClientSq_pushstring(sqvm, mod.Name.c_str(), -1);
		ClientSq_arrayappend(sqvm, -2);
	}

	return SQRESULT_NOTNULL;
}

// bool function NSIsModEnabled(string modName)
SQRESULT SQ_IsModEnabled(void* sqvm)
{
	const SQChar* modName = ClientSq_getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_ModManager->m_loadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			ClientSq_pushbool(sqvm, mod.Enabled);
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

// void function NSSetModEnabled(string modName, bool enabled)
SQRESULT SQ_SetModEnabled(void* sqvm)
{
	const SQChar* modName = ClientSq_getstring(sqvm, 1);
	const SQBool enabled = ClientSq_getbool(sqvm, 2);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_ModManager->m_loadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			mod.Enabled = enabled;
			return SQRESULT_NULL;
		}
	}

	return SQRESULT_NULL;
}

// string function NSGetModDescriptionByModName(string modName)
SQRESULT SQ_GetModDescription(void* sqvm)
{
	const SQChar* modName = ClientSq_getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_ModManager->m_loadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			ClientSq_pushstring(sqvm, mod.Description.c_str(), -1);
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

// string function NSGetModVersionByModName(string modName)
SQRESULT SQ_GetModVersion(void* sqvm)
{
	const SQChar* modName = ClientSq_getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_ModManager->m_loadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			ClientSq_pushstring(sqvm, mod.Version.c_str(), -1);
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

// string function NSGetModDownloadLinkByModName(string modName)
SQRESULT SQ_GetModDownloadLink(void* sqvm)
{
	const SQChar* modName = ClientSq_getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_ModManager->m_loadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			ClientSq_pushstring(sqvm, mod.DownloadLink.c_str(), -1);
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

// int function NSGetModLoadPriority(string modName)
SQRESULT SQ_GetModLoadPriority(void* sqvm)
{
	const SQChar* modName = ClientSq_getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_ModManager->m_loadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			ClientSq_pushinteger(sqvm, mod.LoadPriority);
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

// bool function NSIsModRequiredOnClient(string modName)
SQRESULT SQ_IsModRequiredOnClient(void* sqvm)
{
	const SQChar* modName = ClientSq_getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_ModManager->m_loadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			ClientSq_pushbool(sqvm, mod.RequiredOnClient);
			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NULL;
}

// array<string> function NSGetModConvarsByModName(string modName)
SQRESULT SQ_GetModConvars(void* sqvm)
{
	const SQChar* modName = ClientSq_getstring(sqvm, 1);
	ClientSq_newarray(sqvm, 0);

	// manual lookup, not super performant but eh not a big deal
	for (Mod& mod : g_ModManager->m_loadedMods)
	{
		if (!mod.Name.compare(modName))
		{
			for (ModConVar* cvar : mod.ConVars)
			{
				ClientSq_pushstring(sqvm, cvar->Name.c_str(), -1);
				ClientSq_arrayappend(sqvm, -2);
			}

			return SQRESULT_NOTNULL;
		}
	}

	return SQRESULT_NOTNULL; // return empty array
}

// void function NSReloadMods()
SQRESULT SQ_ReloadMods(void* sqvm)
{
	g_ModManager->LoadMods();
	return SQRESULT_NULL;
}

void InitialiseScriptModMenu(HMODULE baseAddress)
{
	if (IsDedicated())
		return;

	g_UISquirrelManager->AddFuncRegistration("array<string>", "NSGetModNames", "", "Returns the names of all loaded mods", SQ_GetModNames);
	g_UISquirrelManager->AddFuncRegistration(
		"bool", "NSIsModEnabled", "string modName", "Returns whether a given mod is enabled", SQ_IsModEnabled);
	g_UISquirrelManager->AddFuncRegistration(
		"void", "NSSetModEnabled", "string modName, bool enabled", "Sets whether a given mod is enabled", SQ_SetModEnabled);
	g_UISquirrelManager->AddFuncRegistration(
		"string", "NSGetModDescriptionByModName", "string modName", "Returns a given mod's description", SQ_GetModDescription);
	g_UISquirrelManager->AddFuncRegistration(
		"string", "NSGetModVersionByModName", "string modName", "Returns a given mod's version", SQ_GetModVersion);
	g_UISquirrelManager->AddFuncRegistration(
		"string", "NSGetModDownloadLinkByModName", "string modName", "Returns a given mod's download link", SQ_GetModDownloadLink);
	g_UISquirrelManager->AddFuncRegistration(
		"bool", "NSIsModRequiredOnClient", "string modName", "Returns whether a given mod is required on connecting clients",
		SQ_IsModRequiredOnClient);
	g_UISquirrelManager->AddFuncRegistration(
		"int", "NSGetModLoadPriority", "string modName", "Returns a given mod's load priority", SQ_GetModLoadPriority);
	g_UISquirrelManager->AddFuncRegistration(
		"array<string>", "NSGetModConvarsByModName", "string modName", "Returns the names of all a given mod's cvars", SQ_GetModConvars);

	g_UISquirrelManager->AddFuncRegistration("void", "NSReloadMods", "", "Reloads mods", SQ_ReloadMods);
}