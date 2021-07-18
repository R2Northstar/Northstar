#include "pch.h"
#include "hooks.h"
#include "main.h"
#include "squirrel.h"
#include "dedicated.h"
#include "sourceconsole.h"
#include "logging.h"
#include "concommand.h"
#include "modmanager.h"
#include <iostream>

bool initialised = false;

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
        DisableThreadLibraryCalls(hModule);
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }

    if (!initialised)
        InitialiseNorthstar();
    initialised = true;

    return TRUE;
}

// in the future this will be called from launcher instead of dllmain
void InitialiseNorthstar()
{
    InitialiseLogging();
    // apply initial hooks
    InstallInitialHooks();
    InitialiseInterfaceCreationHooks();

    if (IsDedicated())
        AddDllLoadCallback("engine.dll", InitialiseDedicated);
    
    AddDllLoadCallback("engine.dll", InitialiseConVars);
    AddDllLoadCallback("engine.dll", InitialiseConCommands);

    if (!IsDedicated())
    {
        AddDllLoadCallback("client.dll", InitialiseClientSquirrel);
        AddDllLoadCallback("client.dll", InitialiseSourceConsole);
    }

    AddDllLoadCallback("server.dll", InitialiseServerSquirrel);


    // do this after all the other callbacks
    AddDllLoadCallback("engine.dll", InitialiseModManager);
}