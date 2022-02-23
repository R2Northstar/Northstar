#include "pch.h"
#include "dedicated.h"
#include "hookutils.h"
#include "gameutils.h"
#include "serverauthentication.h"
#include "masterserver.h"
bool IsDedicated()
{
	// return CommandLine()->CheckParm("-dedicated");
	return strstr(GetCommandLineA(), "-dedicated");
}

// CDedidcatedExports defs
struct CDedicatedExports; // forward declare

typedef void (*DedicatedSys_PrintfType)(CDedicatedExports* dedicated, const char* msg);
typedef void (*DedicatedRunServerType)(CDedicatedExports* dedicated);

// would've liked to just do this as a class but have not been able to get it to work
struct CDedicatedExports
{
	void* vtable; // because it's easier, we just set this to &this, since CDedicatedExports has no props we care about other than funcs

	char unused[56];

	DedicatedSys_PrintfType Sys_Printf;
	DedicatedRunServerType RunServer;
};

void Sys_Printf(CDedicatedExports* dedicated, const char* msg) { spdlog::info("[DEDICATED PRINT] {}", msg); }

typedef void (*CHostState__InitType)(CHostState* self);

void RunServer(CDedicatedExports* dedicated)
{
	spdlog::info("CDedicatedExports::RunServer(): starting");
	spdlog::info(CommandLine()->GetCmdLine());

	// initialise engine
	g_pEngine->Frame();

	// add +map if not present
	// don't manually execute this from cbuf as users may have it in their startup args anyway, easier just to run from stuffcmds if present
	if (!CommandLine()->CheckParm("+map"))
		CommandLine()->AppendParm("+map", Cvar_match_defaultMap->GetString());

	// run server autoexec and re-run commandline
	Cbuf_AddText(Cbuf_GetCurrentPlayer(), "exec autoexec_ns_server", cmd_source_t::kCommandSrcCode);
	Cbuf_AddText(Cbuf_GetCurrentPlayer(), "stuffcmds", cmd_source_t::kCommandSrcCode);
	Cbuf_Execute();

	// ensure playlist initialises right, if we've not explicitly called setplaylist
	SetCurrentPlaylist(GetCurrentPlaylistName());

	// note: we no longer manually set map and hoststate to start server in g_pHostState, we just use +map which seems to initialise stuff
	// better

	// main loop
	double frameTitle = 0;
	while (g_pEngine->m_nQuitting == EngineQuitState::QUIT_NOTQUITTING)
	{
		double frameStart = Plat_FloatTime();
		g_pEngine->Frame();

		// only update the title after at least 500ms since the last update
		if ((frameStart - frameTitle) > 0.5)
		{
			frameTitle = frameStart;

			// this way of getting playercount/maxplayers honestly really sucks, but not got any other methods of doing it rn
			const char* maxPlayers = GetCurrentPlaylistVar("max_players", false);
			if (!maxPlayers)
				maxPlayers = "6";

			SetConsoleTitleA(fmt::format(
								 "{} - {} {}/{} players ({})", g_MasterServerManager->ns_auth_srvName, g_pHostState->m_levelName,
								 g_ServerAuthenticationManager->m_additionalPlayerData.size(), maxPlayers, GetCurrentPlaylistName())
								 .c_str());
		}

		std::this_thread::sleep_for(std::chrono::duration<double, std::ratio<1>>(
			Cvar_base_tickinterval_mp->GetFloat() - fmin(Plat_FloatTime() - frameStart, 0.25)));
	}
}

typedef bool (*IsGameActiveWindowType)();
IsGameActiveWindowType IsGameActiveWindow;
bool IsGameActiveWindowHook() { return true; }

HANDLE consoleInputThreadHandle = NULL;

DWORD WINAPI ConsoleInputThread(PVOID pThreadParameter)
{
	while (!g_pEngine || !g_pHostState || g_pHostState->m_iCurrentState != HostState_t::HS_RUN)
		Sleep(1000);

	// Bind stdin to receive console input.
	FILE* fp = nullptr;
	freopen_s(&fp, "CONIN$", "r", stdin);

	spdlog::info("Ready to receive console commands.");

	{
		// Process console input
		std::string input;
		while (g_pEngine && g_pEngine->m_nQuitting == EngineQuitState::QUIT_NOTQUITTING && std::getline(std::cin, input))
		{
			input += "\n";
			Cbuf_AddText(Cbuf_GetCurrentPlayer(), input.c_str(), cmd_source_t::kCommandSrcCode);
		}
	}

	return 0;
}

void InitialiseDedicated(HMODULE engineAddress)
{
	if (!IsDedicated())
		return;

	spdlog::info("InitialiseDedicated");

	{
		// Host_Init
		// prevent a particle init that relies on client dll

		char* ptr = (char*)engineAddress + 0x156799;
		TempReadWrite rw(ptr);

		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
	}

	{
		// CModAppSystemGroup::Create
		// force the engine into dedicated mode by changing the first comparison to IsServerOnly to an assignment
		char* ptr = (char*)engineAddress + 0x1C4EBD;
		TempReadWrite rw(ptr);

		// cmp => mov
		*(ptr + 1) = (char)0xC6;
		*(ptr + 2) = (char)0x87;

		// 00 => 01
		*((char*)ptr + 7) = (char)0x01;
	}

	{
		// Some init that i'm not sure of that crashes
		char* ptr = (char*)engineAddress + 0x156A63;
		TempReadWrite rw(ptr);

		// nop the call to it
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
	}

	{
		// runframeserver
		char* ptr = (char*)engineAddress + 0x159819;
		TempReadWrite rw(ptr);

		// nop some access violations
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
		*(ptr + 5) = (char)0x90;
		*(ptr + 6) = (char)0x90;
		*(ptr + 7) = (char)0x90;
		*(ptr + 8) = (char)0x90;
		*(ptr + 9) = (char)0x90;
		*(ptr + 10) = (char)0x90;
		*(ptr + 11) = (char)0x90;
		*(ptr + 12) = (char)0x90;
		*(ptr + 13) = (char)0x90;
		*(ptr + 14) = (char)0x90;
		*(ptr + 15) = (char)0x90;
		*(ptr + 16) = (char)0x90;
	}

	{
		// HostState_State_NewGame
		char* ptr = (char*)engineAddress + 0x156B4C;
		TempReadWrite rw(ptr);

		// nop some access violations
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
		*(ptr + 5) = (char)0x90;
		*(ptr + 6) = (char)0x90;

		// previously patched these, took me a couple weeks to figure out they were the issue
		// removing these will mess up register state when this function is over, so we'll write HS_RUN to the wrong address
		// so uhh, don't do that
		//*(ptr + 7) = (char)0x90;
		//*(ptr + 8) = (char)0x90;
		//*(ptr + 9) = (char)0x90;
		//*(ptr + 10) = (char)0x90;
		//*(ptr + 11) = (char)0x90;
		//*(ptr + 12) = (char)0x90;
		//*(ptr + 13) = (char)0x90;
		//*(ptr + 14) = (char)0x90;

		*(ptr + 15) = (char)0x90;
		*(ptr + 16) = (char)0x90;
		*(ptr + 17) = (char)0x90;
		*(ptr + 18) = (char)0x90;
		*(ptr + 19) = (char)0x90;
		*(ptr + 20) = (char)0x90;
		*(ptr + 21) = (char)0x90;
		*(ptr + 22) = (char)0x90;
		*(ptr + 23) = (char)0x90;
	}

	{
		// HostState_State_NewGame
		char* ptr = (char*)engineAddress + 0xB934C;
		TempReadWrite rw(ptr);

		// nop an access violation
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
		*(ptr + 5) = (char)0x90;
		*(ptr + 6) = (char)0x90;
		*(ptr + 7) = (char)0x90;
		*(ptr + 8) = (char)0x90;
	}

	{
		// CEngineAPI::Connect
		char* ptr = (char*)engineAddress + 0x1C4D7D;
		TempReadWrite rw(ptr);

		// remove call to Shader_Connect
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
	}

	// currently does not work, crashes stuff, likely gotta keep this here
	//{
	//	// CEngineAPI::Connect
	//	char* ptr = (char*)engineAddress + 0x1C4E07;
	//	TempReadWrite rw(ptr);
	//
	//	// remove calls to register ui rpak asset types
	//	*ptr = 0x90;
	//	*(ptr + 1) = (char)0x90;
	//	*(ptr + 2) = (char)0x90;
	//	*(ptr + 3) = (char)0x90;
	//	*(ptr + 4) = (char)0x90;
	//}

	// not sure if this should be done, not loading ui at least is good, but should everything be gone?
	{
		// Host_Init
		char* ptr = (char*)engineAddress + 0x15653B;
		TempReadWrite rw(ptr);

		// change the number of rpaks to load from 6 to 1, so we only load common.rpak
		*(ptr + 1) = (char)0x01;
	}

	{
		// Host_Init
		char* ptr = (char*)engineAddress + 0x156595;
		TempReadWrite rw(ptr);

		// remove call to ui loading stuff
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
	}

	{
		// some function that gets called from RunFrameServer
		char* ptr = (char*)engineAddress + 0x15A0BB;
		TempReadWrite rw(ptr);

		// nop a function that makes requests to stryder, this will eventually access violation if left alone and isn't necessary anyway
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
	}

	{
		// RunFrameServer
		char* ptr = (char*)engineAddress + 0x159BF3;
		TempReadWrite rw(ptr);

		// nop a function that access violations
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
	}

	{
		// func that checks if origin is inited
		char* ptr = (char*)engineAddress + 0x183B70;
		TempReadWrite rw(ptr);

		// always return 1
		*ptr = (char)0xB0; // mov al,01
		*(ptr + 1) = (char)0x01;
		*(ptr + 2) = (char)0xC3; // ret
	}

	{
		// HostState_State_ChangeLevel
		char* ptr = (char*)engineAddress + 0x1552ED;
		TempReadWrite rw(ptr);

		// nop clientinterface call
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
		*(ptr + 5) = (char)0x90;
		*(ptr + 6) = (char)0x90;
		*(ptr + 7) = (char)0x90;
		*(ptr + 8) = (char)0x90;
		*(ptr + 9) = (char)0x90;
		*(ptr + 10) = (char)0x90;
		*(ptr + 11) = (char)0x90;
		*(ptr + 12) = (char)0x90;
		*(ptr + 13) = (char)0x90;
		*(ptr + 14) = (char)0x90;
		*(ptr + 15) = (char)0x90;
	}

	{
		// HostState_State_ChangeLevel
		char* ptr = (char*)engineAddress + 0x155363;
		TempReadWrite rw(ptr);

		// nop clientinterface call
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
		*(ptr + 5) = (char)0x90;
		*(ptr + 6) = (char)0x90;
		*(ptr + 7) = (char)0x90;
		*(ptr + 8) = (char)0x90;
		*(ptr + 9) = (char)0x90;
		*(ptr + 10) = (char)0x90;
		*(ptr + 11) = (char)0x90;
		*(ptr + 12) = (char)0x90;
		*(ptr + 13) = (char)0x90;
		*(ptr + 14) = (char)0x90;
		*(ptr + 15) = (char)0x90;
	}

	// note: previously had DisableDedicatedWindowCreation patches here, but removing those rn since they're all shit and unstable and bad
	// and such check commit history if any are needed for reimplementation
	{
		// IVideoMode::CreateGameWindow
		char* ptr = (char*)engineAddress + 0x1CD146;
		TempReadWrite rw(ptr);

		// nop call to ShowWindow
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
	}

	CDedicatedExports* dedicatedExports = new CDedicatedExports;
	dedicatedExports->vtable = dedicatedExports;
	dedicatedExports->Sys_Printf = Sys_Printf;
	dedicatedExports->RunServer = RunServer;

	CDedicatedExports** exports = (CDedicatedExports**)((char*)engineAddress + 0x13F0B668);
	*exports = dedicatedExports;

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)engineAddress + 0x1CDC80, &IsGameActiveWindowHook, reinterpret_cast<LPVOID*>(&IsGameActiveWindow));

	// extra potential patches:
	// nop engine.dll+1c67d1 and +1c67d8 to skip videomode creategamewindow
	// also look into launcher.dll+d381, seems to cause renderthread to get made
	// this crashes HARD if no window which makes sense tbh
	// also look into materialsystem + 5B344 since it seems to be the base of all the renderthread stuff

	// big note: datatable gets registered in window creation
	// make sure it still gets registered

	// add cmdline args that are good for dedi
	CommandLine()->AppendParm("-nomenuvid", 0);
	CommandLine()->AppendParm("-nosound", 0);
	CommandLine()->AppendParm("-windowed", 0);
	CommandLine()->AppendParm("+host_preload_shaders", "0");
	CommandLine()->AppendParm("+net_usesocketsforloopback", "1");

	// Disable Quick Edit mode to reduce chance of user unintentionally hanging their server by selecting something.
	if (!CommandLine()->CheckParm("-bringbackquickedit"))
	{
		HANDLE stdIn = GetStdHandle(STD_INPUT_HANDLE);
		DWORD mode = 0;

		if (GetConsoleMode(stdIn, &mode))
		{
			if (mode & ENABLE_QUICK_EDIT_MODE)
			{
				mode &= ~ENABLE_QUICK_EDIT_MODE;
				mode &= ~ENABLE_MOUSE_INPUT;

				mode |= ENABLE_PROCESSED_INPUT;

				SetConsoleMode(stdIn, mode);
			}
		}
	}
	else
		spdlog::info("Quick Edit enabled by user request");

	// create console input thread
	if (!CommandLine()->CheckParm("-noconsoleinput"))
		consoleInputThreadHandle = CreateThread(0, 0, ConsoleInputThread, 0, 0, NULL);
	else
		spdlog::info("Console input disabled by user request");
}

void InitialiseDedicatedOrigin(HMODULE baseAddress)
{
	// disable origin on dedicated
	// for any big ea lawyers, this can't be used to play the game without origin, game will throw a fit if you try to do anything without
	// an origin id as a client for dedi it's fine though, game doesn't care if origin is disabled as long as there's only a server

	if (!IsDedicated())
		return;

	char* ptr = (char*)GetProcAddress(GetModuleHandleA("tier0.dll"), "Tier0_InitOrigin");
	TempReadWrite rw(ptr);
	*ptr = (char)0xC3; // ret
}

typedef void (*PrintFatalSquirrelErrorType)(void* sqvm);
PrintFatalSquirrelErrorType PrintFatalSquirrelError;
void PrintFatalSquirrelErrorHook(void* sqvm)
{
	PrintFatalSquirrelError(sqvm);
	g_pEngine->m_nQuitting = EngineQuitState::QUIT_TODESKTOP;
}

void InitialiseDedicatedServerGameDLL(HMODULE baseAddress)
{
	if (!IsDedicated())
		return;

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, baseAddress + 0x794D0, &PrintFatalSquirrelErrorHook, reinterpret_cast<LPVOID*>(&PrintFatalSquirrelError));
}