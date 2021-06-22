# Northstar

All interfaces exposed by Northstar.

## ISys

!!! cpp-class "ISys"

    Provides basic functions to interact with northstar.

    !!! cpp-function "void Log(HMODULE pluginHandle, LogLevel level, char* msg)"

        Log a message using the console managed by northstar.

        Messages logged using this method are prefixed with the `LOG_NAME` retrieved via your `PluginId` implementation and printed to the game's console.

    !!! cpp-function "void Unload(HMODULE pluginHandle)"

        Gracefully unload a plugin (usually your own plugin)

    !!! cpp-function "void Reload(HMODULE pluginHandle)"

        Reload a plugin. The plugin can know if it has been reloaded via the `reloaded` parameter passed in the `Init` callback exposed in the `IPluginCallbacks` Interface.

!!! cpp-enum "LogLevel : i32"

    !!! cpp-member "INFO = 0"

    !!! cpp-member "WARN = 0"

    !!! cpp-member "ERR = 0"