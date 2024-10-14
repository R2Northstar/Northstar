#ifndef IPLUGIN_ID_H
#define IPLUGIN_ID_H

#include <stdint.h>
#include "squirrel/squirrelclasstypes.h"

#define PLUGIN_ID_VERSION "PluginId001"

// an identifier for the type of string data requested from the plugin
enum class PluginString : int
{
	NAME = 0,
	LOG_NAME = 1,
	DEPENDENCY_NAME = 2,
};

// an identifier for the type of bitflag requested from the plugin
enum class PluginField : int
{
	CONTEXT = 0,
	COLOR = 1,
};

// an interface that is required from every plugin to query data about it
class IPluginId
{
public:
	virtual const char* GetString(PluginString prop) = 0;
	virtual int64_t GetField(PluginField prop) = 0;
};

#endif
