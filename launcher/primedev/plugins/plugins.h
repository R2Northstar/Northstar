#pragma once
#include "core/tier1.h"
#include "plugins/interfaces/interface.h"
#include "plugins/interfaces/IPluginId.h"
#include "plugins/interfaces/IPluginCallbacks.h"

class Plugin
{
private:
	CreateInterfaceFn m_pCreateInterface;
	IPluginId* m_pluginId = 0;
	IPluginCallbacks* m_callbacks = 0;

	std::shared_ptr<ColoredLogger> m_logger;

	bool m_valid = false;
	std::string m_name;
	std::string m_logName;
	std::string m_dependencyName;
	std::string m_location; // path of the dll
	bool m_runOnServer;
	bool m_runOnClient;

public:
	HMODULE m_handle;
	PluginNorthstarData m_initData;

	Plugin(std::string path);
	bool Unload() const;
	void Reload() const;

	// sys
	void Log(spdlog::level::level_enum level, char* msg) const;

	// callbacks
	bool IsValid() const;
	const std::string& GetName() const;
	const std::string& GetLogName() const;
	const std::string& GetDependencyName() const;
	const std::string& GetLocation() const;
	bool ShouldRunOnServer() const;
	bool ShouldRunOnClient() const;
	void* CreateInterface(const char* pName, int* pStatus) const;
	void Init(bool reloaded) const;
	void Finalize() const;
	void OnSqvmCreated(CSquirrelVM* sqvm) const;
	void OnSqvmDestroying(CSquirrelVM* sqvm) const;
	void OnLibraryLoaded(HMODULE module, const char* name) const;
	void RunFrame() const;
};
