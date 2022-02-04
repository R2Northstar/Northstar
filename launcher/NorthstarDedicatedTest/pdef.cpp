#include "pch.h"
#include "modmanager.h"
#include "filesystem.h"
#include "hookutils.h"
#include "pdef.h"
#include <map>
#include <sstream>
#include <fstream>

void ModManager::BuildPdef()
{
	spdlog::info("Building persistent_player_data_version_231.pdef...");

	fs::path MOD_PDEF_PATH = fs::path(GetCompiledAssetsPath() / MOD_PDEF_SUFFIX);

	fs::remove(MOD_PDEF_PATH);
	std::string pdef = ReadVPKOriginalFile(VPK_PDEF_PATH);

	for (Mod& mod : m_loadedMods)
	{
		if (!mod.Enabled || !mod.Pdiff.size())
			continue;

		// this code probably isn't going to be pretty lol
		// refer to shared/pjson.js for an actual okish parser of the pdiff format
		// but pretty much, $ENUM_ADD blocks define members added to preexisting enums
		// $PROP_START ends the custom stuff, and from there it's just normal props we append to the pdef

		std::map<std::string, std::vector<std::string>> enumAdds;

		// read pdiff
		bool inEnum = false;
		bool inProp = false;
		std::string currentEnum;
		std::string currentLine;
		std::istringstream pdiffStream(mod.Pdiff);

		while (std::getline(pdiffStream, currentLine))
		{
			if (inProp)
			{
				// just append to pdef here
				pdef += currentLine;
				pdef += '\n';
				continue;
			}

			// trim leading whitespace
			size_t start = currentLine.find_first_not_of(" \n\r\t\f\v");
			size_t end = currentLine.find("//");
			if (end == std::string::npos)
				end = currentLine.size() - 1; // last char

			if (!currentLine.size() || !currentLine.compare(start, 2, "//"))
				continue;

			if (inEnum)
			{
				if (!currentLine.compare(start, 9, "$ENUM_END"))
					inEnum = false;
				else
					enumAdds[currentEnum].push_back(currentLine); // only need to push_back current line, if there's syntax errors then game
																  // pdef parser will handle them
			}
			else if (!currentLine.compare(start, 9, "$ENUM_ADD"))
			{
				inEnum = true;
				currentEnum = currentLine.substr(start + 10 /*$ENUM_ADD + 1*/, currentLine.size() - end - (start + 10));
				enumAdds.insert(std::make_pair(currentEnum, std::vector<std::string>()));
			}
			else if (!currentLine.compare(start, 11, "$PROP_START"))
			{
				inProp = true;
				pdef += "\n// $PROP_START ";
				pdef += mod.Name;
				pdef += "\n";
			}
		}

		// add new members to preexisting enums
		// note: this code could 100% be messed up if people put //$ENUM_START comments and the like
		// could make it protect against this, but honestly not worth atm
		for (auto enumAdd : enumAdds)
		{
			std::string addStr;
			for (std::string enumMember : enumAdd.second)
			{
				addStr += enumMember;
				addStr += '\n';
			}

			// start of enum we're adding to
			std::string startStr = "$ENUM_START ";
			startStr += enumAdd.first;

			// insert enum values into enum
			size_t insertIdx = pdef.find("$ENUM_END", pdef.find(startStr));
			pdef.reserve(addStr.size());
			pdef.insert(insertIdx, addStr);
		}
	}

	fs::create_directories(MOD_PDEF_PATH.parent_path());

	std::ofstream writeStream(MOD_PDEF_PATH, std::ios::binary);
	writeStream << pdef;
	writeStream.close();

	ModOverrideFile overrideFile;
	overrideFile.owningMod = nullptr;
	overrideFile.path = VPK_PDEF_PATH;

	if (m_modFiles.find(VPK_PDEF_PATH) == m_modFiles.end())
		m_modFiles.insert(std::make_pair(VPK_PDEF_PATH, overrideFile));
	else
		m_modFiles[VPK_PDEF_PATH] = overrideFile;
}