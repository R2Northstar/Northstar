# Required Interfaces

!!! error

    Remember that the first parameter of any function for every interface is always a pointer to an instance of that interface

    **The first implicit parameter is omitted in this documentation for simplicity and C++ code parity**

!!! warning

    Every enum in this file should be treated as non exhaustive and members can be added in future Northstar versions.

Some interfaces are required to be exposed by every plugin.

Plugins without all of these interfaces will be unloaded immediately.

## IPluginId

!!! note

    Current latest version: `IPluginId001`

The IPluginId provides information about the plugin itself, like the name and when to run.

!!! cpp-class "IPluginId"

    !!! cpp-function "char* GetString(PluginString id)"

        Returns a string associated with the id, or `0` if the id is unknown.

    !!! cpp-function "int64_t GetField(PluginField id)"

        Returns a number associated with the id, or `0` if the id is unknown.

!!! cpp-enum "enum PluginString : i32"

    To distinguish what string is requested with `IPluginId::GetString`

    !!! cpp-member "NAME = 0"

        The name of the plugin

    !!! cpp-member "LOG_NAME = 1"

        The prefix to use for logs in northstar. Use 8 characters to align with northstar prefixes.

    !!! cpp-member "DEPENDENCY_NAME = 1"

        For every loaded plugin a squirrel global constant is registered with this value. Has to be a valid squirrel identifier.

        The constant can be used to control when a script is compiled and can be used in the "RunOn" field of the mod.json or in a script directly

        ```squirrel
        #if MYPLUGIN
        print("my plugin is loaded");
        #else
        print("my plugin is not loaded :(");
        #endif
        ```

!!! cpp-enum "enum PluginField : i32"

    To distinguish what integer is requested with `IPluginId::GetField`

    !!! cpp-member "CONTEXT = 0"

        A bitfield used to determine if the plugin should loaded in the current context.

        - DEDICATED: 0x1

            Keep the plugin loaded on dedicated northstar servers

        - CLIENT: 0x3

            Keep the plugin loaded on dedicated northstar clients

    !!! cpp-member "COLOR = 1"

        Determines the color used for the log prefix of the plugin.

        If all channels are 0, Northstar will use a default color.

        * \[bits 0-8\]: RED

        * \[bits 8-16\]: BLUE

        * \[bits 16-24\]: GREEN

## IPluginCallbacks

!!! note

    Current latest version: `IPluginCallbacks001`


For some commonly used events northstar provides callbacks.

!!! cpp-class "IPluginCallbacks"

    !!! cpp-function "void Init(HMODULE northstarModule, const PluginNorthstarData* initData, bool reloaded)"

        Called after the plugin has been loaded and validated.

        Use [DllMain](https://learn.microsoft.com/en-us/windows/win32/dlls/dllmain) to initialize systems required for the validation of your plugin, like registering all interfaces for your `CreateInterface` export.

    !!! cpp-function "void Finalize()"

        Called after all plugins are initialized

    !!! cpp-function "void Unload()"

        Called right before this plugin is unloaded

    !!! cpp-function "void OnSqvmCreated(CSquirrelVM* sqvm)"

        Called after an sqvm is created

    !!! cpp-function "void OnSqvmDestroying(CSquirrelVM* sqvm)"

        Called just before the sqvm is destroyed

    !!! cpp-function "void OnLibraryLoaded(HMODULE module, char* name)"

        Called whenever any module is loaded, either by northstar, the game or any plugin

    !!! cpp-function "void RunFrame()"

        Called every game frame

!!! cpp-class "PluginNorthstarData"

    Data that's useful for the initialization of your plugin

    !!! cpp-member "HMODULE pluginHandle"

        The handle of the initializing plugin
