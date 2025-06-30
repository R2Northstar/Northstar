#ifndef PLUGIN_MANAGER_H
#define PLUGIN_MANAGER_H

#include <windows.h>

namespace fs = std::filesystem;

class Plugin;

class PluginManager
{
public:
	const std::vector<Plugin>& GetLoadedPlugins() const;
	const std::optional<const Plugin*> GetPlugin(HMODULE handle) const;
	bool LoadPlugins(bool reloaded = false);
	std::optional<HMODULE> LoadPlugin(fs::path path, bool reloaded = false);
	void ReloadPlugins();
	void RemovePlugin(HMODULE handle);

	// callback triggers
	void InformSqvmCreated(CSquirrelVM* sqvm) const;
	void InformSqvmDestroying(CSquirrelVM* sqvm) const;
	void InformDllLoad(HMODULE module, fs::path path) const;
	void RunFrame() const;

private:
	void InformAllPluginsInitialized() const;

	std::vector<Plugin> plugins;
	std::string pluginPath;
};

extern PluginManager* g_pPluginManager;

#endif
