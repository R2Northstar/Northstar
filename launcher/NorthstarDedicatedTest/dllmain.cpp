#include "pch.h"
#include "hooks.h"
#include "main.h"
#include "squirrel.h"
#include "dedicated.h"
#include "dedicatedmaterialsystem.h"
#include "sourceconsole.h"
#include "logging.h"
#include "concommand.h"
#include "modmanager.h"
#include "filesystem.h"
#include "serverauthentication.h"
#include "scriptmodmenu.h"
#include "scriptserverbrowser.h"
#include "keyvalues.h"
#include "masterserver.h"
#include "gameutils.h"
#include "chatcommand.h"
#include "modlocalisation.h"
#include "playlist.h"
#include "securitypatches.h"

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

    AddDllLoadCallback("engine.dll", InitialiseEngineGameUtilFunctions);

    if (IsDedicated())
    {
        AddDllLoadCallback("engine.dll", InitialiseDedicated);
        AddDllLoadCallback("materialsystem_dx11.dll", InitialiseDedicatedMaterialSystem);
    }
    
    AddDllLoadCallback("engine.dll", InitialiseConVars);
    AddDllLoadCallback("engine.dll", InitialiseConCommands);

    if (!IsDedicated())
    {
        AddDllLoadCallback("engine.dll", InitialiseClientEngineSecurityPatches);
        AddDllLoadCallback("client.dll", InitialiseClientSquirrel);
        AddDllLoadCallback("client.dll", InitialiseSourceConsole);
        AddDllLoadCallback("engine.dll", InitialiseChatCommands);
        AddDllLoadCallback("client.dll", InitialiseScriptModMenu);
        AddDllLoadCallback("client.dll", InitialiseScriptServerBrowser);
        AddDllLoadCallback("localize.dll", InitialiseModLocalisation);
    }

    AddDllLoadCallback("server.dll", InitialiseServerSquirrel);
    AddDllLoadCallback("engine.dll", InitialiseServerAuthentication);
    AddDllLoadCallback("engine.dll", InitialiseSharedMasterServer);

    AddDllLoadCallback("engine.dll", InitialisePlaylistHooks);

    AddDllLoadCallback("filesystem_stdio.dll", InitialiseFilesystem);
    AddDllLoadCallback("engine.dll", InitialiseKeyValues);

    // mod manager after everything else
    AddDllLoadCallback("engine.dll", InitialiseModManager);
}