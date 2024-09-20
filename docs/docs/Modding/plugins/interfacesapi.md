# Interface API

the plugins system now use source interfaces.

The launcher exposes almost everything required by plugins in interfaces that allow for backwards compatibility.
The only thing that's passed to a plugin directly is the northstar dll HWND and a struct of data that's different for each plugin.

Plugins are required to expose a `void* CreateInterface(const char* name, int* status)` function to share their own interfaces.
The launcher loads the `PluginId` interface from the plugin to query info such as it's name.

Plugins can use the `CreateInterface` function exposed by the northstarDll to use northstar interfaces such as for logging.
An interface is just an abstract class to force all functions into a vftable.

## Northstar Interfaces

### NSSys001

Exposes some system functionality to plugins

```cpp
// 32 bit
enum LogLevel {
    INFO,
    WARN,
    ERR,
};

// handle: handle of the plugin. Passed to the plugin on init.
void Log(HMODULE handle, LogLevel level, char* msg); // logs a message with the plugin's log name
void Unload(HMODULE handle); // unloads the plugin
void Reload(HMODULE handle);
```

## Required Plugin Interfaces

Interfaces that have to be exposed for the plugin to be loaded.

### PluginId001

```cpp
// strings of data about the plugin itself. may be extended in the future
// 32 bit
enum PluginString {
    NAME, // the name of the plugin
    LOG_NAME, // the name used for logging
    DEPENDENCY_NAME, // the name used for squirrel dependency constants created. The value returned for this has to be a valid squirrel identifier or the plugin will fail to load
}

// bitfields about the plugin
// 32 bit
enum PluginField {
    CONTEXT // 0x1 if the plugin is allowed to run on dedicated servers and 0x2 if the plugin is allowed to run on clients (is this even needed seems useless to me)
}

char* GetString(PluginString prop);
i64 GetField(PluginField prop);
```

### PluginCallbacks001

```cpp
struct PluginNorthstarData { HMODULE handle; };

// COPY THE initData IT MAY BE MOVED AT RUNTIME
void Init(HMODULE nsModule, const PluginNorthstarData* initData, bool reloaded); // called after the plugin has been validated. The nsmodule allows northstar plugins to work for the ronin client as well (assuming they update their fork lmao)
void Finalize(); // called after all plugins have been loaded. Useful for dependencies
void Unload(); // called just before the plugin is getting unloaded
void OnSqvmCreated(CSquirrelVM* sqvm); // the context of the sqvm is contained in the instance
void OnSqvmDestroying(CSquirrelVM* sqvm); // callback with the sqvm instance that's about to be destroyed (for UI, CLIENT is destroyed for some reason??)
void OnLibraryLoaded(HMODULE module, const char* libraryName); // called for any library loaded by the game (for example engine.dll)
void RunFrame(); // just runs on every frame of the game I think
```

## What's an interface anyways?

Interfaces are just abstract classes. So make sure the first parameter is always a pointer to the instance of the interface you're using.

an example what NSSys001 looks like in C:

```cpp
typedef enum {
    LOG_INFO,
    LOG_WARN,
    LOG_ERR,
};

typedef struct CSys {
    struct {
        void (*log)(struct CSys* self, HMODULE handle, LogLevel level, char* msg);
        void (*unload)(struct CSys* self, HMODULE handle);
    }* vftable;
} CSys;

// use like this
g_c_sys->vftable->log(g_c_sys, g_handle, LOG_INFO, "my balls are itching");
```

Interfaces are created with CreateInterface that's exposed in another dll.
