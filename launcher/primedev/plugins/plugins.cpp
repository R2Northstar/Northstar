#include "plugins.h"
#include "pluginmanager.h"
#include "squirrel/squirrel.h"
#include "util/wininfo.h"
#include "core/sourceinterface.h"
#include "logging/logging.h"
#include "dedicated/dedicated.h"

bool isValidSquirrelIdentifier(std::string s)
{
	if (!s.size())
		return false; // identifiers can't be empty
	if (s[0] <= 57)
		return false; // identifier can't start with a number
	for (char& c : s)
	{
		// only allow underscores, 0-9, A-Z and a-z
		if ((c >= '0' && c <= '9') || (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c == '_')
			continue;
		return false;
	}
	return true;
}

Plugin::Plugin(std::string path)
	: m_location(path)
{
	HMODULE pluginModule = GetModuleHandleA(path.c_str());

	if (pluginModule)
	{
		// plugins may refuse to get unloaded for any reason so we need to prevent them getting loaded twice when reloading plugins
		NS::log::PLUGINSYS->warn("Plugin has already been loaded");
		return;
	}

	m_handle = LoadLibraryExA(path.c_str(), 0, LOAD_LIBRARY_SEARCH_USER_DIRS | LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);

	NS::log::PLUGINSYS->info("loaded plugin handle {}", static_cast<void*>(m_handle));

	if (!m_handle)
	{
		NS::log::PLUGINSYS->error("Failed to load plugin '{}' (Error: {})", path, GetLastError());
		return;
	}

	m_initData = {.pluginHandle = m_handle};

	m_pCreateInterface = (CreateInterfaceFn)GetProcAddress(m_handle, "CreateInterface");

	if (!m_pCreateInterface)
	{
		NS::log::PLUGINSYS->error("Plugin at '{}' does not expose CreateInterface()", path);
		return;
	}

	m_pluginId = (IPluginId*)m_pCreateInterface(PLUGIN_ID_VERSION, 0);

	if (!m_pluginId)
	{
		NS::log::PLUGINSYS->error("Could not load IPluginId interface of plugin at '{}'", path);
		return;
	}

	const char* name = m_pluginId->GetString(PluginString::NAME);
	const char* logName = m_pluginId->GetString(PluginString::LOG_NAME);
	const char* dependencyName = m_pluginId->GetString(PluginString::DEPENDENCY_NAME);
	int64_t context = m_pluginId->GetField(PluginField::CONTEXT);

	m_runOnServer = context & PluginContext::DEDICATED;
	m_runOnClient = context & PluginContext::CLIENT;

	if (!name)
	{
		NS::log::PLUGINSYS->error("Could not load name of plugin at '{}'", path);
		return;
	}

	if (!logName)
	{
		NS::log::PLUGINSYS->error("Could not load logName of plugin {}", name);
		return;
	}

	if (!dependencyName)
	{
		NS::log::PLUGINSYS->error("Could not load dependencyName of plugin {}", name);
		return;
	}

	m_name = std::string(name);
	m_logName = std::string(logName);
	m_dependencyName = std::string(dependencyName);

	if (!isValidSquirrelIdentifier(m_dependencyName))
	{
		NS::log::PLUGINSYS->error("Dependency name \"{}\" of plugin {} is not valid", dependencyName, name);
		return;
	}

	m_callbacks = (IPluginCallbacks*)m_pCreateInterface("PluginCallbacks001", 0);

	if (!m_callbacks)
	{
		NS::log::PLUGINSYS->error("Could not create callback interface of plugin {}", name);
		return;
	}

	m_logger = std::make_shared<ColoredLogger>(m_logName, NS::Colors::PLUGIN);
	RegisterLogger(m_logger);

	if (IsDedicatedServer() && !m_runOnServer)
	{
		NS::log::PLUGINSYS->info("Unloading {} because it's not supposed to run on dedicated servers", m_name);
		return;
	}

	if (!IsDedicatedServer() && !m_runOnClient)
	{
		NS::log::PLUGINSYS->info("Unloading {} because it's only supposed to run on dedicated servers", m_name);
		return;
	}

	m_valid = true;
}

bool Plugin::Unload() const
{
	if (!m_handle)
		return true;

	if (IsValid())
	{
		bool unloaded = m_callbacks->Unload();

		if (!unloaded)
			return false;
	}

	if (!FreeLibrary(m_handle))
	{
		NS::log::PLUGINSYS->error("Failed to unload plugin at '{}'", m_location);
		return false;
	}

	g_pPluginManager->RemovePlugin(m_handle);
	return true;
}

void Plugin::Reload() const
{
	bool unloaded = Unload();

	if (!unloaded)
		return;

	g_pPluginManager->LoadPlugin(fs::path(m_location), true);
}

void Plugin::Log(spdlog::level::level_enum level, char* msg) const
{
	m_logger->log(level, msg);
}

bool Plugin::IsValid() const
{
	return m_valid && m_pCreateInterface && m_pluginId && m_callbacks && m_handle;
}

const std::string& Plugin::GetName() const
{
	return m_name;
}

const std::string& Plugin::GetLogName() const
{
	return m_logName;
}

const std::string& Plugin::GetDependencyName() const
{
	return m_dependencyName;
}

const std::string& Plugin::GetLocation() const
{
	return m_location;
}

bool Plugin::ShouldRunOnServer() const
{
	return m_runOnServer;
}

bool Plugin::ShouldRunOnClient() const
{
	return m_runOnClient;
}

void* Plugin::CreateInterface(const char* name, int* status) const
{
	return m_pCreateInterface(name, status);
}

void Plugin::Init(bool reloaded) const
{
	m_callbacks->Init(g_NorthstarModule, &m_initData, reloaded);
}

void Plugin::Finalize() const
{
	m_callbacks->Finalize();
}

void Plugin::OnSqvmCreated(CSquirrelVM* sqvm) const
{
	m_callbacks->OnSqvmCreated(sqvm);
}

void Plugin::OnSqvmDestroying(CSquirrelVM* sqvm) const
{
	NS::log::PLUGINSYS->info("destroying sqvm {}", sqvm->vmContext);
	m_callbacks->OnSqvmDestroying(sqvm);
}

void Plugin::OnLibraryLoaded(HMODULE module, const char* name) const
{
	m_callbacks->OnLibraryLoaded(module, name);
}

void Plugin::RunFrame() const
{
	m_callbacks->RunFrame();
}
