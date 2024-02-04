#include "plugins/interfaces/interface.h"
#include "ISys.h"
#include "plugins/plugins.h"
#include "plugins/pluginmanager.h"

class CSys : public ISys
{
public:
	void Log(HMODULE handle, LogLevel level, char* msg)
	{
		spdlog::level::level_enum spdLevel;

		switch (level)
		{
		case LogLevel::WARN:
			spdLevel = spdlog::level::level_enum::warn;
			break;
		case LogLevel::ERR:
			spdLevel = spdlog::level::level_enum::err;
			break;
		default:
			NS::log::PLUGINSYS->warn("Attempted to log with invalid level {}. Defaulting to info", (int)level);
		case LogLevel::INFO:
			spdLevel = spdlog::level::level_enum::info;
			break;
		}

		std::optional<Plugin> plugin = g_pPluginManager->GetPlugin(handle);
		if (plugin)
		{
			plugin->Log(spdLevel, msg);
		}
		else
		{
			NS::log::PLUGINSYS->warn("Attempted to log message '{}' with invalid plugin handle {}", msg, static_cast<void*>(handle));
		}
	}

	void Unload(HMODULE handle)
	{
		std::optional<Plugin> plugin = g_pPluginManager->GetPlugin(handle);
		if (plugin)
		{
			plugin->Unload();
		}
		else
		{
			NS::log::PLUGINSYS->warn("Attempted to unload plugin with invalid handle {}", static_cast<void*>(handle));
		}
	}

	void Reload(HMODULE handle)
	{
		std::optional<Plugin> plugin = g_pPluginManager->GetPlugin(handle);
		if (plugin)
		{
			plugin->Reload();
		}
		else
		{
			NS::log::PLUGINSYS->warn("Attempted to reload plugin with invalid handle {}", static_cast<void*>(handle));
		}
	}
};

EXPOSE_SINGLE_INTERFACE(CSys, ISys, SYS_VERSION);
