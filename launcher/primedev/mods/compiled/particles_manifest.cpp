#include "mods/modmanager.h"
#include "core/filesystem/filesystem.h"
#include "shared/keyvalues.h"

#include <fstream>

const char* PARTICLES_MANIFEST_PATH = "particles\\particles_manifest.txt";

void ParseParticlesFile(std::string& fileStr, std::vector<std::string>& entries)
{
	// looks for:
	// any amount of #base commands
	// "particles_manifest"
	// {
	// <some stuff that gets captured
	// }
	static std::regex regex(R"(^(?:#base.+\n)*\s*particles_manifest\s+\{\s*?\n\s*([^\x00]*)\}\s*$)");

	std::smatch matches;
	if (std::regex_search(fileStr, matches, regex))
	{
		if (matches.size() < 2)
			return;
		entries.push_back(matches[1]);
	}
}

// compiles the particles_manifest file
void ModManager::BuildParticlesManifest()
{
	spdlog::info("Building particles_manifest.txt");

	fs::create_directories(GetCompiledAssetsPath() / "particles");

	// gather particle entries from vanilla and mod particles_manifest.txt
	std::vector<std::string> entries = {};

	// read the original version of the manifest
	std::string originalFile = ReadVPKFile(PARTICLES_MANIFEST_PATH, FileSourceType_Original);
	ParseParticlesFile(originalFile, entries);

	for (auto& mod : m_LoadedMods)
	{
		if (!mod.m_bEnabled)
			continue;

		// check to see if mod wants to edit the file?
		std::string path = g_pModManager->NormaliseModFilePath(mod.m_ModDirectory / MOD_OVERRIDE_DIR / PARTICLES_MANIFEST_PATH);
		if (!fs::is_regular_file(path))
			continue;

		std::ifstream t(path);
		std::stringstream fileStream;
		fileStream << t.rdbuf();
		std::string modFile = fileStream.str();
		t.close();

		entries.push_back(std::format("// [{}]\n", mod.Name));
		ParseParticlesFile(modFile, entries);
	}

	// write the output file
	fs::create_directories(GetCompiledAssetsPath() / "particles");
	std::ofstream soCompiledParticles(GetCompiledAssetsPath() / PARTICLES_MANIFEST_PATH, std::ios::binary);

	soCompiledParticles << "particles_manifest\n{\n";
	for (auto& entry : entries)
	{
		soCompiledParticles << '\t' << entry << '\n';
	}
	soCompiledParticles << "}\n";

	soCompiledParticles.close();

	// push to compiled files
	m_CompiledFiles.insert(PARTICLES_MANIFEST_PATH);
}
