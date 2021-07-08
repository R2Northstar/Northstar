#include "pch.h"
#include "hooks.h"
#include "main.h"
#include "squirrel.h"
#include "dedicated.h"
#include "sourceconsole.h"
#include <iostream>

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
    
    InitialiseNorthstar();

    return TRUE;
}

// this is called from the injector and initialises stuff, dllmain is called multiple times while this should only be called once
void InitialiseNorthstar()
{
    AllocConsole();
    freopen("CONOUT$", "w", stdout);
    AddLoggingSink(DefaultLoggingSink);

    // apply hooks
    InstallInitialHooks();

    if (IsDedicated())
        AddDllLoadCallback("engine.dll", InitialiseDedicated);
    
    if (!IsDedicated())
    {
        AddDllLoadCallback("client.dll", InitialiseClientSquirrel);
        AddDllLoadCallback("client.dll", InitialiseSourceConsole);
    }

    AddDllLoadCallback("server.dll", InitialiseServerSquirrel);
}