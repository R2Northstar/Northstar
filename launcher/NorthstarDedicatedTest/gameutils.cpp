#include "pch.h"
#include "gameutils.h"
#include "convar.h"
#include "concommand.h"

// memory
IMemAlloc* g_pMemAllocSingleton;
typedef IMemAlloc* (*CreateGlobalMemAllocType)();
CreateGlobalMemAllocType CreateGlobalMemAlloc;

// cmd.h
Cbuf_GetCurrentPlayerType Cbuf_GetCurrentPlayer;
Cbuf_AddTextType Cbuf_AddText;
Cbuf_ExecuteType Cbuf_Execute;

// hoststate stuff
CHostState* g_pHostState;

// cengine stuff
CEngine* g_pEngine;
server_state_t* sv_m_State;

// network stuff
ConVar* Cvar_hostport;
ConVar* Cvar_net_datablock_enabled;

// playlist stuff
GetCurrentPlaylistType GetCurrentPlaylistName;
SetCurrentPlaylistType SetCurrentPlaylist;
SetPlaylistVarOverrideType SetPlaylistVarOverride;
GetCurrentPlaylistVarType GetCurrentPlaylistVar;

// server entity stuff
Server_GetEntityByIndexType Server_GetEntityByIndex;

// server tickrate stuff
ConVar* Cvar_base_tickinterval_mp;
ConVar* Cvar_base_tickinterval_sp;

// auth
char* g_LocalPlayerUserID;
char* g_LocalPlayerOriginToken;

// misc stuff
ConVar* Cvar_match_defaultMap;
ConVar* Cvar_communities_hostname;
ErrorType Error;
CommandLineType CommandLine;
Plat_FloatTimeType Plat_FloatTime;
ThreadInServerFrameThreadType ThreadInServerFrameThread;
GetBaseLocalClientType GetBaseLocalClient;

void InitialiseEngineGameUtilFunctions(HMODULE baseAddress)
{
	Cbuf_GetCurrentPlayer = (Cbuf_GetCurrentPlayerType)((char*)baseAddress + 0x120630);
	Cbuf_AddText = (Cbuf_AddTextType)((char*)baseAddress + 0x1203B0);
	Cbuf_Execute = (Cbuf_ExecuteType)((char*)baseAddress + 0x1204B0);

	g_pHostState = (CHostState*)((char*)baseAddress + 0x7CF180);
	g_pEngine = *(CEngine**)((char*)baseAddress + 0x7D70C8);
	sv_m_State = (server_state_t*)((char*)baseAddress + 0x12A53D48);

	GetCurrentPlaylistName = (GetCurrentPlaylistType)((char*)baseAddress + 0x18C640);
	SetCurrentPlaylist = (SetCurrentPlaylistType)((char*)baseAddress + 0x18EB20);
	SetPlaylistVarOverride = (SetPlaylistVarOverrideType)((char*)baseAddress + 0x18ED00);
	GetCurrentPlaylistVar = (GetCurrentPlaylistVarType)((char*)baseAddress + 0x18C680);

	g_LocalPlayerUserID = (char*)baseAddress + 0x13F8E688;
	g_LocalPlayerOriginToken = (char*)baseAddress + 0x13979C80;

	GetBaseLocalClient = (GetBaseLocalClientType)((char*)baseAddress + 0x78200);

	/* NOTE:
		g_pCVar->FindVar("convar_name") now works. These are no longer needed.
		You can also itterate over every ConVar using CCVarIteratorInternal
		dump the pointers to a vector and access them from there.
	Example:
		std::vector<ConVar*> g_pAllConVars;
		for (auto& map : g_pCVar->DumpToMap())
		{
			ConVar* pConVar = g_pCVar->FindVar(map.first.c_str());
			if (pConVar)
			{
				g_pAllConVars.push_back(pConVar);
			}
		}*/
	Cvar_hostport = (ConVar*)((char*)baseAddress + 0x13FA6070);
	Cvar_net_datablock_enabled = (ConVar*)((char*)baseAddress + 0x12A4F6D0);
	Cvar_match_defaultMap = (ConVar*)((char*)baseAddress + 0x8AB530);
	Cvar_communities_hostname = (ConVar*)((char*)baseAddress + 0x13157E50);
}

void InitialiseServerGameUtilFunctions(HMODULE baseAddress)
{
	Server_GetEntityByIndex = (Server_GetEntityByIndexType)((char*)baseAddress + 0xFB820);
	Cvar_base_tickinterval_mp = (ConVar*)((char*)baseAddress + 0xBFC360);
	Cvar_base_tickinterval_sp = (ConVar*)((char*)baseAddress + 0xBFBEA0);
}

void InitialiseTier0GameUtilFunctions(HMODULE baseAddress)
{
	if (!baseAddress)
	{
		spdlog::critical("tier0 base address is null, but it should be already loaded");
		throw "tier0 base address is null, but it should be already loaded";
	}
	if (g_pMemAllocSingleton)
		return; // seems this function was already called
	CreateGlobalMemAlloc = reinterpret_cast<CreateGlobalMemAllocType>(GetProcAddress(baseAddress, "CreateGlobalMemAlloc"));
	IMemAlloc** ppMemAllocSingleton = reinterpret_cast<IMemAlloc**>(GetProcAddress(baseAddress, "g_pMemAllocSingleton"));
	if (!ppMemAllocSingleton)
	{
		spdlog::critical("Address of g_pMemAllocSingleton is a null pointer, this should never happen");
		throw "Address of g_pMemAllocSingleton is a null pointer, this should never happen";
	}
	if (!*ppMemAllocSingleton)
	{
		g_pMemAllocSingleton = CreateGlobalMemAlloc();
		*ppMemAllocSingleton = g_pMemAllocSingleton;
		spdlog::info("Created new g_pMemAllocSingleton");
	}
	else
	{
		g_pMemAllocSingleton = *ppMemAllocSingleton;
	}

	Error = reinterpret_cast<ErrorType>(GetProcAddress(baseAddress, "Error"));
	CommandLine = reinterpret_cast<CommandLineType>(GetProcAddress(baseAddress, "CommandLine"));
	Plat_FloatTime = reinterpret_cast<Plat_FloatTimeType>(GetProcAddress(baseAddress, "Plat_FloatTime"));
	ThreadInServerFrameThread = reinterpret_cast<ThreadInServerFrameThreadType>(GetProcAddress(baseAddress, "ThreadInServerFrameThread"));
}