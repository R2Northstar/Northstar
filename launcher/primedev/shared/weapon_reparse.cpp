#include "mods/modmanager.h"
#include <string>
#include <algorithm>

static void RemoveCompiledWeaponScripts()
{
	// avoid clearing literally everything, just weapons
	auto& files = g_pModManager->m_CompiledFiles;
	std::erase_if(
		files, [](const std::string& val) { return val.starts_with("scripts/weapons/") || val.starts_with("scripts\\weapons\\"); });
}

static void(__fastcall* o_pConCommand_weapon_reparse_server)(const CCommand& arg) = nullptr;
static void __fastcall h_ConCommand_weapon_reparse_server(const CCommand& arg)
{
	RemoveCompiledWeaponScripts();
	o_pConCommand_weapon_reparse_server(arg);
}

static void(__fastcall* o_pConCommand_weapon_reparse)(const CCommand& arg) = nullptr;
static void __fastcall h_ConCommand_weapon_reparse(const CCommand& arg)
{
	RemoveCompiledWeaponScripts();
	o_pConCommand_weapon_reparse(arg);
}

ON_DLL_LOAD("server.dll", WeaponReparse_Server, (CModule module))
{
	o_pConCommand_weapon_reparse_server = module.Offset(0x6D2B70).RCast<decltype(o_pConCommand_weapon_reparse_server)>();
	HookAttach(&(PVOID&)o_pConCommand_weapon_reparse_server, (PVOID)h_ConCommand_weapon_reparse_server);
}

ON_DLL_LOAD("client.dll", WeaponReparse_Client, (CModule module))
{
	o_pConCommand_weapon_reparse = module.Offset(0x3D4930).RCast<decltype(o_pConCommand_weapon_reparse)>();
	HookAttach(&(PVOID&)o_pConCommand_weapon_reparse, (PVOID)h_ConCommand_weapon_reparse);
}
