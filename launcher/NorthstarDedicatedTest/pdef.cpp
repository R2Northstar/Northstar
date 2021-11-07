#include "pch.h"
#include "modmanager.h"
#include "filesystem.h"
#include "hookutils.h"
#include "pdef.h"

void ModManager::BuildPdef()
{
	spdlog::info("Building persistent_player_data_version_231.pdef...");

	std::string originalPdef = ReadVPKOriginalFile(VPK_PDEF_PATH);
	spdlog::info(originalPdef);
}