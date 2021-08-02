#include "pch.h"
#include "scriptmodmenu.h"
#include "modmanager.h"
#include "squirrel.h"

// array<string> NSGetModNames()
SQInteger SQ_GetModNames(void* sqvm)
{
	ClientSq_newarray(sqvm, 0);

	for (Mod* mod : g_ModManager->m_loadedMods)
	{
		ClientSq_pushstring(sqvm, mod->Name.c_str(), -1);
		ClientSq_arrayappend(sqvm, -2);
	}

	return 1;
}

// string NSGetModDescriptionByModName(string modName)
SQInteger SQ_GetModDescription(void* sqvm)
{
	const SQChar* modName = ClientSq_getstring(sqvm, 1);
	
	// manual lookup, not super performant but eh not a big deal
	for (Mod* mod : g_ModManager->m_loadedMods)
	{
		if (!mod->Name.compare(modName))
		{
			ClientSq_pushstring(sqvm, mod->Description.c_str(), -1);
			return 1;
		}
	}

	return 0; // return null
}

// string NSGetModVersionByModName(string modName)
SQInteger SQ_GetModVersion(void* sqvm)
{
	const SQChar* modName = ClientSq_getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod* mod : g_ModManager->m_loadedMods)
	{
		if (!mod->Name.compare(modName))
		{
			ClientSq_pushstring(sqvm, mod->Version.c_str(), -1);
			return 1;
		}
	}

	return 0; // return null
}

// string NSGetModDownloadLinkByModName(string modName)
SQInteger SQ_GetModDownloadLink(void* sqvm)
{
	const SQChar* modName = ClientSq_getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod* mod : g_ModManager->m_loadedMods)
	{
		if (!mod->Name.compare(modName))
		{
			ClientSq_pushstring(sqvm, mod->DownloadLink.c_str(), -1);
			return 1;
		}
	}

	return 0; // return null
}

// int NSGetModLoadPriority(string modName)
SQInteger SQ_GetModLoadPriority(void* sqvm)
{
	const SQChar* modName = ClientSq_getstring(sqvm, 1);

	// manual lookup, not super performant but eh not a big deal
	for (Mod* mod : g_ModManager->m_loadedMods)
	{
		if (!mod->Name.compare(modName))
		{
			ClientSq_pushinteger(sqvm, mod->LoadPriority);
			return 1;
		}
	}

	return 0; // return null
}

// array<string> NSGetModConvarsByModName(string modName)
SQInteger SQ_GetModConvars(void* sqvm)
{
	const SQChar* modName = ClientSq_getstring(sqvm, 1);
	ClientSq_newarray(sqvm, 0);

	// manual lookup, not super performant but eh not a big deal
	for (Mod* mod : g_ModManager->m_loadedMods)
	{
		if (!mod->Name.compare(modName))
		{
			for (ModConVar* cvar : mod->ConVars)
			{
				ClientSq_pushstring(sqvm, cvar->Name.c_str(), -1);
				ClientSq_arrayappend(sqvm, -2);
			}

			return 1;
		}
	}

	return 1; // return empty array
}

// void NSReloadMods()
SQInteger SQ_ReloadMods(void* sqvm)
{
	g_ModManager->LoadMods();
	return 0;
}

void InitialiseScriptModMenu(HMODULE baseAddress)
{
	g_UISquirrelManager->AddFuncRegistration("array<string>", "NSGetModNames", "", "Returns the names of all loaded mods", SQ_GetModNames);
	g_UISquirrelManager->AddFuncRegistration("string", "NSGetModDescriptionByModName", "string modName", "Returns a given mod's description", SQ_GetModDescription);
	g_UISquirrelManager->AddFuncRegistration("string", "NSGetModVersionByModName", "string modName", "Returns a given mod's version", SQ_GetModVersion);	
	g_UISquirrelManager->AddFuncRegistration("string", "NSGetModDownloadLinkByModName", "string modName", "Returns a given mod's download link", SQ_GetModDownloadLink);
	g_UISquirrelManager->AddFuncRegistration("int", "NSGetModLoadPriority", "string modName", "Returns a given mod's load priority", SQ_GetModLoadPriority);
	g_UISquirrelManager->AddFuncRegistration("array<string>", "NSGetModConvarsByModName", "string modName", "Returns the names of all a given mod's cvars", SQ_GetModConvars);

	g_UISquirrelManager->AddFuncRegistration("void", "NSReloadMods", "", "Reloads mods", SQ_ReloadMods);
}