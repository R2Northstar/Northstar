#include "pluginmanager.h"

#include <regex>
#include "plugins.h"
#include "config/profile.h"
#include "core/convar/concommand.h"

PluginManager* g_pPluginManager;

const std::vector<Plugin>& PluginManager::GetLoadedPlugins() const
{
	return this->plugins;
}

const std::optional<Plugin> PluginManager::GetPlugin(HMODULE handle) const
{
	for (const Plugin& plugin : GetLoadedPlugins())
		if (plugin.m_handle == handle)
			return plugin;
	return std::nullopt;
}

void PluginManager::LoadPlugin(fs::path path, bool reloaded)
{
	Plugin plugin = Plugin(path.string());

	if (!plugin.IsValid())
	{
		NS::log::PLUGINSYS->warn("Unloading invalid plugin '{}'", path.string());
		plugin.Unload();
		return;
	}

	plugins.push_back(plugin);
	plugin.Init(reloaded);
}

inline void FindPlugins(fs::path pluginPath, std::vector<fs::path>& paths)
{
	// ensure dirs exist
	if (!fs::exists(pluginPath) || !fs::is_directory(pluginPath))
	{
		return;
	}

	for (const fs::directory_entry& entry : fs::directory_iterator(pluginPath))
	{
		if (fs::is_regular_file(entry) && entry.path().extension() == ".dll")
			paths.emplace_back(entry.path());
	}
}

bool PluginManager::LoadPlugins(bool reloaded)
{
	if (strstr(GetCommandLineA(), "-noplugins") != NULL)
	{
		NS::log::PLUGINSYS->warn("-noplugins detected; skipping loading plugins");
		return false;
	}

	fs::create_directories(GetThunderstoreModFolderPath());

	std::vector<fs::path> paths;

	pluginPath = GetNorthstarPrefix() + "\\plugins";

	fs::path libPath = fs::absolute(pluginPath + "\\lib");
	if (fs::exists(libPath) && fs::is_directory(libPath))
		AddDllDirectory(libPath.wstring().c_str());

	FindPlugins(pluginPath, paths);

	// Special case for Thunderstore mods dir
	std::filesystem::directory_iterator thunderstoreModsDir = fs::directory_iterator(GetThunderstoreModFolderPath());
	// Set up regex for `AUTHOR-MOD-VERSION` pattern
	std::regex pattern(R"(.*\\([a-zA-Z0-9_]+)-([a-zA-Z0-9_]+)-(\d+\.\d+\.\d+))");
	for (fs::directory_entry dir : thunderstoreModsDir)
	{
		fs::path pluginsDir = dir.path() / "plugins";
		// Use regex to match `AUTHOR-MOD-VERSION` pattern
		if (!std::regex_match(dir.path().string(), pattern))
		{
			spdlog::warn("The following directory did not match 'AUTHOR-MOD-VERSION': {}", dir.path().string());
			continue; // skip loading package that doesn't match
		}

		fs::path libDir = fs::absolute(pluginsDir / "lib");
		if (fs::exists(libDir) && fs::is_directory(libDir))
			AddDllDirectory(libDir.wstring().c_str());

		FindPlugins(pluginsDir, paths);
	}

	if (paths.empty())
	{
		NS::log::PLUGINSYS->warn("Could not find any plugins. Skipped loading plugins");
		return false;
	}

	for (fs::path path : paths)
	{
		LoadPlugin(path, reloaded);
	}

	InformAllPluginsInitialized();

	return true;
}

void PluginManager::ReloadPlugins()
{
	for (const Plugin& plugin : this->GetLoadedPlugins())
	{
		plugin.Unload();
	}

	this->plugins.clear();
	this->LoadPlugins(true);
}

void PluginManager::RemovePlugin(HMODULE handle)
{
	for (size_t i = 0; i < plugins.size(); i++)
	{
		Plugin* plugin = &plugins[i];
		if (plugin->m_handle == handle)
		{
			plugins.erase(plugins.begin() + i);
			return;
		}
	}
}

void PluginManager::InformAllPluginsInitialized() const
{
	for (const Plugin& plugin : GetLoadedPlugins())
	{
		plugin.Finalize();
	}
}

void PluginManager::InformSqvmCreated(CSquirrelVM* sqvm) const
{
	for (const Plugin& plugin : GetLoadedPlugins())
	{
		plugin.OnSqvmCreated(sqvm);
	}
}

void PluginManager::InformSqvmDestroying(CSquirrelVM* sqvm) const
{
	for (const Plugin& plugin : GetLoadedPlugins())
	{
		plugin.OnSqvmDestroying(sqvm);
	}
}

void PluginManager::InformDllLoad(HMODULE module, fs::path path) const
{
	std::string fn = path.filename().string(); // without this the string gets freed immediately lmao
	const char* filename = fn.c_str();
	for (const Plugin& plugin : GetLoadedPlugins())
	{
		plugin.OnLibraryLoaded(module, filename);
	}
}

void PluginManager::RunFrame() const
{
	for (const Plugin& plugin : GetLoadedPlugins())
	{
		plugin.RunFrame();
	}
}

void ConCommand_reload_plugins(const CCommand& args)
{
	g_pPluginManager->ReloadPlugins();
}

ON_DLL_LOAD_RELIESON("engine.dll", PluginManager, ConCommand, (CModule module))
{
	RegisterConCommand("reload_plugins", ConCommand_reload_plugins, "reloads plugins", FCVAR_NONE);
}
