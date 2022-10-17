#include "pch.h"
#include "printmaps.h"
#include "convar.h"
#include "concommand.h"
#include "modmanager.h"
#include "tier0.h"
#include "r2engine.h"

#include <filesystem>
#include <regex>

AUTOHOOK_INIT()

enum class MapSource_t
{
	VPK,
	GAMEDIR,
	MOD
};

const std::unordered_map<MapSource_t, const char*> PrintMapSource = {
	{MapSource_t::VPK, "VPK"}, {MapSource_t::MOD, "MOD"}, {MapSource_t::GAMEDIR, "R2"}};

struct MapVPKInfo
{
	std::string name;
	std::string parent;
	MapSource_t source;
};

// our current list of maps in the game
std::vector<MapVPKInfo> vMapList;

void RefreshMapList()
{
	vMapList.clear();

	// get modded maps
	// TODO: could probably check mod vpks to get mapnames from there too?
	for (auto& modFilePair : g_pModManager->m_ModFiles)
	{
		ModOverrideFile file = modFilePair.second;
		if (file.m_Path.extension() == ".bsp" && file.m_Path.parent_path().string() == "maps") // only allow mod maps actually in /maps atm
		{
			MapVPKInfo& map = vMapList.emplace_back();
			map.name = file.m_Path.stem().string();
			map.parent = file.m_pOwningMod->Name;
			map.source = MapSource_t::MOD;
		}
	}

	// get maps in vpk
	{
		const int iNumRetailNonMapVpks = 1;
		static const char* const ppRetailNonMapVpks[] = {
			"englishclient_frontend.bsp.pak000_dir.vpk"}; // don't include mp_common here as it contains mp_lobby

		// matches directory vpks, and captures their map name in the first group
		static const std::regex rVpkMapRegex("englishclient_([a-zA-Z_]+)\\.bsp\\.pak000_dir\\.vpk", std::regex::icase);

		for (fs::directory_entry file : fs::directory_iterator("./vpk"))
		{
			std::string pathString = file.path().filename().string();

			bool bIsValidMapVpk = true;
			for (int i = 0; i < iNumRetailNonMapVpks; i++)
			{
				if (!pathString.compare(ppRetailNonMapVpks[i]))
				{
					bIsValidMapVpk = false;
					break;
				}
			}

			if (!bIsValidMapVpk)
				continue;

			// run our map vpk regex on the filename
			std::smatch match;
			std::regex_match(pathString, match, rVpkMapRegex);

			if (match.length() < 2)
				continue;

			std::string mapName = match[1].str();
			// special case: englishclient_mp_common contains mp_lobby, so hardcode the name here
			if (mapName == "mp_common")
				mapName = "mp_lobby";

			MapVPKInfo& map = vMapList.emplace_back();
			map.name = mapName;
			map.parent = pathString;
			map.source = MapSource_t::VPK;
		}
	}

	// get maps in game dir
	for (fs::directory_entry file : fs::directory_iterator(fmt::format("{}/maps", R2::g_pModName)))
	{
		if (file.path().extension() == ".bsp")
		{
			MapVPKInfo& map = vMapList.emplace_back();
			map.name = file.path().stem().string();
			map.parent = "R2";
			map.source = MapSource_t::GAMEDIR;
		}
	}
}

// clang-format off
AUTOHOOK(_Host_Map_f_CompletionFunc, engine.dll + 0x161AE0,
int, __fastcall, (const char const* cmdname, const char const* partial, char commands[COMMAND_COMPLETION_MAXITEMS][COMMAND_COMPLETION_ITEM_LENGTH]))
// clang-format on
{
	// don't update our map list often from this func, only refresh every 10 seconds so we avoid constantly reading fs
	static double flLastAutocompleteRefresh = -999;

	if (flLastAutocompleteRefresh + 10.0 < Tier0::Plat_FloatTime())
	{
		RefreshMapList();
		flLastAutocompleteRefresh = Tier0::Plat_FloatTime();
	}

	// use a custom autocomplete func for all map loading commands
	const int cmdLength = strlen(cmdname);
	const char* query = partial + cmdLength;
	const int queryLength = strlen(query);

	int numMaps = 0;
	for (int i = 0; i < vMapList.size() && numMaps < COMMAND_COMPLETION_MAXITEMS; i++)
	{
		if (!strncmp(query, vMapList[i].name.c_str(), queryLength))
		{
			strcpy(commands[numMaps], cmdname);
			strncpy_s(
				commands[numMaps++] + cmdLength,
				COMMAND_COMPLETION_ITEM_LENGTH,
				&vMapList[i].name[0],
				COMMAND_COMPLETION_ITEM_LENGTH - cmdLength);
		}
	}

	return numMaps;
}

void ConCommand_maps(const CCommand& args)
{
	if (args.ArgC() < 2)
	{
		spdlog::info("Usage: maps <substring>");
		spdlog::info("maps * for full listing");
		return;
	}

	RefreshMapList();

	for (MapVPKInfo& map : vMapList) // need to figure out a nice way to include parent path without making the formatting awful
		if ((*args.Arg(1) == '*' && !args.Arg(1)[1]) || strstr(map.name.c_str(), args.Arg(1)))
			spdlog::info("({}) {}", PrintMapSource.at(map.source), map.name);
}

void InitialiseMapsPrint()
{
	AUTOHOOK_DISPATCH()

	ConCommand* mapsCommand = R2::g_pCVar->FindCommand("maps");
	mapsCommand->m_pCommandCallback = ConCommand_maps;
}
