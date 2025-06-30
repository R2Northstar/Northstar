#include "core/tier1.h"
#include "plugins/interfaces/interface.h"
#include "ISys.h"
#include "plugins/plugins.h"
#include "plugins/pluginmanager.h"

class CSys : public ISys
{
public:
	void Log(int64_t unused, LogLevel level, char* msg)
	{
		void* callee = _ReturnAddress();
		void* pluginHandle;
		RtlPcToFileHeader(callee, &pluginHandle);

		// This should never happen
		if (!pluginHandle)
		{

			NS::log::PLUGINSYS->warn("Unmapped plugin attempted to log from callee {}", static_cast<void*>(pluginHandle));
			return;
		}

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

		std::optional<const Plugin*> plugin = g_pPluginManager->GetPlugin((HMODULE)pluginHandle);
		if (plugin.has_value())
		{
			plugin.value()->Log(spdLevel, msg);
		}
		else
		{
			NS::log::PLUGINSYS->warn("Attempted to log message '{}' with invalid plugin handle {}", msg, static_cast<void*>(pluginHandle));
		}
	}

	void Unload(int64_t unused)
	{
		void* callee = _ReturnAddress();
		void* pluginHandle;
		RtlPcToFileHeader(callee, &pluginHandle);

		// This should never happen
		if (!pluginHandle)
		{
			NS::log::PLUGINSYS->warn("Attempted to unload unmapped plugin from callee {}", static_cast<void*>(pluginHandle));
			return;
		}

		std::optional<const Plugin*> plugin = g_pPluginManager->GetPlugin((HMODULE)pluginHandle);
		if (plugin.has_value())
		{
			plugin.value()->Unload();
		}
		else
		{
			NS::log::PLUGINSYS->warn("Attempted to unload plugin with invalid handle {}", static_cast<void*>(pluginHandle));
		}
	}

	void Reload(int64_t unused)
	{
		void* callee = _ReturnAddress();
		void* pluginHandle = 0;
		RtlPcToFileHeader(callee, &pluginHandle);

		// This should never happen
		if (!pluginHandle)
		{
			NS::log::PLUGINSYS->warn("Attempted to reload unmapped plugin from callee {}", static_cast<void*>(pluginHandle));
			return;
		}

		std::optional<const Plugin*> plugin = g_pPluginManager->GetPlugin((HMODULE)pluginHandle);
		if (plugin.has_value())
		{
			plugin.value()->Reload();
		}
		else
		{
			NS::log::PLUGINSYS->warn("Attempted to reload plugin with invalid handle {}", static_cast<void*>(pluginHandle));
		}
	}
};

EXPOSE_SINGLE_INTERFACE(CSys, ISys, SYS_VERSION);
