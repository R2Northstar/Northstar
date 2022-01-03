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
#include "miscserverscript.h"
#include "clientauthhooks.h"
#include "scriptbrowserhooks.h"
#include "scriptmainmenupromos.h"
#include "miscclientfixes.h"
#include "miscserverfixes.h"
#include "rpakfilesystem.h"
#include "bansystem.h"
#include "memalloc.h"
#include "maxplayers.h"
#include "languagehooks.h"

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

    return TRUE;
}

void WaitForDebugger(HMODULE baseAddress)
{
    // earlier waitfordebugger call than is in vanilla, just so we can debug stuff a little easier
    if (CommandLine()->CheckParm("-waitfordebugger"))
    {
        spdlog::info("waiting for debugger...");

        while (!IsDebuggerPresent())
            Sleep(100);
    }
}

bool InitialiseNorthstar()
{
    if (initialised)
    {
        //spdlog::warn("Called InitialiseNorthstar more than once!"); // it's actually 100% fine for that to happen
        return false;
    }

    initialised = true;

    curl_global_init_mem(CURL_GLOBAL_DEFAULT, _malloc_base, _free_base, _realloc_base, _strdup_base, _calloc_base);

    InitialiseLogging();

    // apply initial hooks
    InstallInitialHooks();
    InitialiseInterfaceCreationHooks();

    AddDllLoadCallback("tier0.dll", InitialiseTier0GameUtilFunctions);
    AddDllLoadCallback("engine.dll", WaitForDebugger);
    AddDllLoadCallback("engine.dll", InitialiseEngineGameUtilFunctions);
    AddDllLoadCallback("server.dll", InitialiseServerGameUtilFunctions);

    // dedi patches
    {
        AddDllLoadCallback("tier0.dll", InitialiseDedicatedOrigin);
        AddDllLoadCallback("engine.dll", InitialiseDedicated);
        AddDllLoadCallback("server.dll", InitialiseDedicatedServerGameDLL);
        AddDllLoadCallback("materialsystem_dx11.dll", InitialiseDedicatedMaterialSystem);
        // this fucking sucks, but seemingly we somehow load after rtech_game???? unsure how, but because of this we have to apply patches here, not on rtech_game load
        AddDllLoadCallback("engine.dll", InitialiseDedicatedRtechGame);
    }
    
    AddDllLoadCallback("engine.dll", InitialiseConVars);
    AddDllLoadCallback("engine.dll", InitialiseConCommands);

    // client-exclusive patches
    {
        AddDllLoadCallback("tier0.dll", InitialiseTier0LanguageHooks);
        AddDllLoadCallback("engine.dll", InitialiseClientEngineSecurityPatches);
        AddDllLoadCallback("client.dll", InitialiseClientSquirrel);
        AddDllLoadCallback("client.dll", InitialiseSourceConsole);
        AddDllLoadCallback("engine.dll", InitialiseChatCommands);
        AddDllLoadCallback("client.dll", InitialiseScriptModMenu);
        AddDllLoadCallback("client.dll", InitialiseScriptServerBrowser);
        AddDllLoadCallback("localize.dll", InitialiseModLocalisation);
        AddDllLoadCallback("engine.dll", InitialiseClientAuthHooks);
        AddDllLoadCallback("engine.dll", InitialiseScriptExternalBrowserHooks);
        AddDllLoadCallback("client.dll", InitialiseScriptMainMenuPromos);
        AddDllLoadCallback("client.dll", InitialiseMiscClientFixes);
    }

    AddDllLoadCallback("engine.dll", InitialiseEngineSpewFuncHooks);
    AddDllLoadCallback("server.dll", InitialiseServerSquirrel);
    AddDllLoadCallback("engine.dll", InitialiseBanSystem);
    AddDllLoadCallback("engine.dll", InitialiseServerAuthentication);
    AddDllLoadCallback("server.dll", InitialiseServerAuthenticationServerDLL);
    AddDllLoadCallback("engine.dll", InitialiseSharedMasterServer);
    AddDllLoadCallback("server.dll", InitialiseMiscServerScriptCommand);
    AddDllLoadCallback("server.dll", InitialiseMiscServerFixes);

    AddDllLoadCallback("engine.dll", InitialisePlaylistHooks);

    AddDllLoadCallback("filesystem_stdio.dll", InitialiseFilesystem);
    AddDllLoadCallback("engine.dll", InitialiseEngineRpakFilesystem);
    AddDllLoadCallback("engine.dll", InitialiseKeyValues);

    // maxplayers increase
    AddDllLoadCallback("engine.dll", InitialiseMaxPlayersOverride_Engine);
    AddDllLoadCallback("client.dll", InitialiseMaxPlayersOverride_Client);
    AddDllLoadCallback("server.dll", InitialiseMaxPlayersOverride_Server);

    // mod manager after everything else
    AddDllLoadCallback("engine.dll", InitialiseModManager);

    // run callbacks for any libraries that are already loaded by now
    CallAllPendingDLLLoadCallbacks();

    return true;
}