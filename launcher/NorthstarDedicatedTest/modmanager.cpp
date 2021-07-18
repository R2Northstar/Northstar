#include "pch.h"
#include "ModManager.h"
#include "rapidjson/rapidjson.h"

ModManager* g_ModManager;

ModManager::ModManager()
{
	LoadMods();
}

void ModManager::LoadMods()
{

}

void InitialiseModManager(HMODULE baseAddress)
{
	g_ModManager = new ModManager;
}