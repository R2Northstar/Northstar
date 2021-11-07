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

			if (!currentLine.compare(start, 2, "//") || end < 1)
				continue;

			if (inEnum)
			{
				if (!currentLine.compare(start, 9, "$ENUM_END"))
					inEnum = false;
				else
				{
					std::string enumMember = currentLine.substr(start, currentLine.size() - end - start);
					// seek to first whitespace, just in case
					int whitespaceIdx = 0;
					for (; whitespaceIdx < enumMember.size(); whitespaceIdx++)
						if (enumMember[whitespaceIdx] == ' ' || enumMember[whitespaceIdx] == '\t')
							break;

					enumAdds[currentEnum].push_back(enumMember.substr(0, whitespaceIdx));
				}
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

		// todo: enum stuff

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