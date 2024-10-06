# Interfaces

!!! note

    The term "Interface" sometimes describes both an abstract C++ class or an instance of a class that implements the abstract class (Interface).

The interface API of Northstar Plugins is modelled after [Source Interfaces](https://developer.valvesoftware.com/wiki/Category:Interfaces). For examples how interfaces are created in-engine, you can check search leaked code of source engine games [using these macros to expose an interface](https://sourcegraph.com/github.com/perilouswithadollarsign/cstrike15_src@f82112a2388b841d72cb62ca48ab1846dfcc11c8/-/blob/public/tier1/interface.h?L86-148).

For example, [search](https://sourcegraph.com/search?q=repo:%5Egithub%5C.com/perilouswithadollarsign/cstrike15_src%24+EXPOSE_SINGLE_INTERFACE_GLOBALVAR+&patternType=keyword&sm=0) for `EXPOSE_SINGLE_INTERFACE_GLOBALVAR` for exposed single static pointers to interface implementations.

This design choice of interface ABI layout was chosen to mimic interfaces binaries of Titanfall 2 exposes and to provide one uniform Interface API between the game, Northstar and any Plugin.

Therefore any plugin is not restricted to interfaces exposed by Northstar but can use the entire suite the game and other plugins offer.

## Memory Layout

!!! warning

    In some cases, different compilers use different layouts for virtual function tables.

    If you're using a compiler that is not msvc, either change your interface or use structs with an explicit vtable member.

    If your plugin is not compiled with C or C++ **make sure the structure follows the C ABI**

Because interface instances are C++ class instances that extend a virtual class, every instance has a [vtable](https://en.wikipedia.org/wiki/Virtual_method_table) pointer at offset `0`.

### VTables

!!! note

    Methods interfaces are always documented in the order they appear in the vtable.

A vtable is a list of pointers to methods of that interface.

The first parameter of these methods is always a pointer to the instance. In C++ this parameter is passed implicitly.

For example, the method [`ISys::Reload`](https://github.com/R2Northstar/NorthstarLauncher/blob/71349f05b69923dbf091d27f8e256bcc3022e859/primedev/plugins/interfaces/sys/ISys.h#L18) has two parameters: `ISys*` and `HMODULE`, even though only one is defined explicitly. Keep this in mind when you're writing plugins not in C++.

The complete [`ISys`](exposed-interfaces/northstar.md#isys) interface instance layout looks like this in C:

```c
typedef struct CSys {
  struct {
    // the vtable contains all methods of this interface
    void (*log)(struct CSys *self, HMODULE handle, LogLevel level, const char *msg);
    void (*unload)(struct CSys *self, HMODULE handle);
    void (*reload)(struct CSys *self, HMODULE handle);
  } *vftable; // the instance only contains a pointer to the vtable
} CSys;

// CSys* sys;
// sys->vtable->log(sys, handle, 0, "hello world");
```

!!! error

    The first parameter (implicit instance pointer) **is omitted in the documentation of interfaces**, remember to include the parameter if you're implementing a plugin in a language that is not C++.

An interface may include more than one vtable, depending on the definition. Usually one for every class it extends.

## CreateInterface

Every plugin, northstar and some binaries of the game expose a set of interfaces via `CreateInterface`.

!!! cpp-function "void* CreateInterface(char* name, int* status)"

    **Parameters:**

    - `[in] char* name` - null terminated name of the interface requested

    - `[out, optional] int* status` -  a pointer to an int where the status code is written to. `0` means an interface was created, `1` means no interface could be instantiated.

    **Returns:**

    - A pointer to the instantiated interface or NULL if failed.

`CreateInterface` is an exported function. The address of it can be obtained via [`GetProcAddress`](https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getprocaddress)

## Exposing an interface

Exposing an interface means in practice that it has to be possible to obtain a pointer to an instance if `CreateInterface` of your plugin is called for the respective interface name.

In the source engine this is implemented as a linked list, however you're free to implement this however you want.

In essence, this is what the functionality of `CreateInterface` boils down to:

```c
void* CreateInterface(char* name, int* status)  {
    if(strcmp(name, "IPluginId001") == 0) {
        if(status) *status = 0;
        return g_IPluginId;
    }

    if(strcmp(name, "IPluginCallbacks001") == 0) {
        if(status) *status = 0;
        return g_IPluginCallbacks;
    }

    // repeat for every interface you expose ...

    if(status) *status = 1;
    return 0;
}
```

## Interface Names

An interface name is a unique string associated with an interface. Names consist of a) the interface name and b) the version of the interface (usually 3 digits in decimal).

Every interface is expected to be fully backwards compatible. This means in practice, that (public) members can only be added to an interface, not removed.

For example, consider this fictional interface `ILog`:

```c++
class ILog {
    public:
    virtual void print(char* msg) = 0;
}
```

The vtable would like this:

```c
struct ILog_vtable {
    void* print;
};
```

This interface would be called `ILog001`, because it's the first version of the interface.

Now we want to extend the interface to also expose a function called `fmt` to format a string:

```c++
class ILog {
    public:
    virtual void print(char* msg) = 0;
    virutal void fmt(char* fmt, ...) = 0;
}
```

This would turn the vtable into this:

```c
struct ILog_vtable {
    void* print;
    void* fmt;
};
```

Now we would call this interface `ILog002` because it's the second iteration of the interface.

!!! warning

    Because you are only allowed to increase the size of an interface while keeping the offsets of all previous members the same, the interfaces **`ILog002` is backwards compatible with `ILog001`**.

    In practice this means that you only need to expose the newest version of an interface.

    It is expected of [CreateInterface](#createinterface) to return an instance, even if only a newer version of that interface is exposed.
