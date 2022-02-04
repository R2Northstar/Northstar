#pragma once
#include "convar.h"

// memory
class IMemAlloc
{
  public:
	struct VTable
	{
		void* unknown[1]; // alloc debug
		void* (*Alloc)(IMemAlloc* memAlloc, size_t nSize);
		void* unknown2[1]; // realloc debug
		void* (*Realloc)(IMemAlloc* memAlloc, void* pMem, size_t nSize);
		void* unknown3[1]; // free #1
		void (*Free)(IMemAlloc* memAlloc, void* pMem);
		void* unknown4[2]; // nullsubs, maybe CrtSetDbgFlag
		size_t (*GetSize)(IMemAlloc* memAlloc, void* pMem);
		void* unknown5[9]; // they all do literally nothing
		void (*DumpStats)(IMemAlloc* memAlloc);
		void (*DumpStatsFileBase)(IMemAlloc* memAlloc, const char* pchFileBase);
		void* unknown6[4];
		int (*heapchk)(IMemAlloc* memAlloc);
	};

	VTable* m_vtable;
};

extern IMemAlloc* g_pMemAllocSingleton;
typedef IMemAlloc* (*CreateGlobalMemAllocType)();
extern CreateGlobalMemAllocType CreateGlobalMemAlloc;

// cmd.h
enum class ECommandTarget_t
{
	CBUF_FIRST_PLAYER = 0,
	CBUF_LAST_PLAYER = 1, // MAX_SPLITSCREEN_CLIENTS - 1, MAX_SPLITSCREEN_CLIENTS = 2
	CBUF_SERVER = CBUF_LAST_PLAYER + 1,

	CBUF_COUNT,
};

enum class cmd_source_t
{
	// Added to the console buffer by gameplay code.  Generally unrestricted.
	kCommandSrcCode,

	// Sent from code via engine->ClientCmd, which is restricted to commands visible
	// via FCVAR_CLIENTCMD_CAN_EXECUTE.
	kCommandSrcClientCmd,

	// Typed in at the console or via a user key-bind.  Generally unrestricted, although
	// the client will throttle commands sent to the server this way to 16 per second.
	kCommandSrcUserInput,

	// Came in over a net connection as a clc_stringcmd
	// host_client will be valid during this state.
	//
	// Restricted to FCVAR_GAMEDLL commands (but not convars) and special non-ConCommand
	// server commands hardcoded into gameplay code (e.g. "joingame")
	kCommandSrcNetClient,

	// Received from the server as the client
	//
	// Restricted to commands with FCVAR_SERVER_CAN_EXECUTE
	kCommandSrcNetServer,

	// Being played back from a demo file
	//
	// Not currently restricted by convar flag, but some commands manually ignore calls
	// from this source.  FIXME: Should be heavily restricted as demo commands can come
	// from untrusted sources.
	kCommandSrcDemoFile,

	// Invalid value used when cleared
	kCommandSrcInvalid = -1
};

typedef ECommandTarget_t (*Cbuf_GetCurrentPlayerType)();
extern Cbuf_GetCurrentPlayerType Cbuf_GetCurrentPlayer;

// compared to the defs i've seen, this is missing an arg, it could be nTickInterval or source, not sure, guessing it's source
typedef void (*Cbuf_AddTextType)(ECommandTarget_t eTarget, const char* text, cmd_source_t source);
extern Cbuf_AddTextType Cbuf_AddText;

typedef void (*Cbuf_ExecuteType)();
extern Cbuf_ExecuteType Cbuf_Execute;

// commandline stuff
class CCommandLine
{
  public:
	// based on the defs in the 2013 source sdk, but for some reason has an extra function (may be another CreateCmdLine overload?)
	// these seem to line up with what they should be though
	virtual void CreateCmdLine(const char* commandline) {}
	virtual void CreateCmdLine(int argc, char** argv) {}
	virtual void unknown() {}
	virtual const char* GetCmdLine(void) const {}

	virtual const char* CheckParm(const char* psz, const char** ppszValue = 0) const {}
	virtual void RemoveParm() const {}
	virtual void AppendParm(const char* pszParm, const char* pszValues) {}

	virtual const char* ParmValue(const char* psz, const char* pDefaultVal = 0) const {}
	virtual int ParmValue(const char* psz, int nDefaultVal) const {}
	virtual float ParmValue(const char* psz, float flDefaultVal) const {}

	virtual int ParmCount() const {}
	virtual int FindParm(const char* psz) const {}
	virtual const char* GetParm(int nIndex) const {}
	virtual void SetParm(int nIndex, char const* pParm) {}

	// virtual const char** GetParms() const {}
};

// hoststate stuff
enum HostState_t
{
	HS_NEW_GAME = 0,
	HS_LOAD_GAME,
	HS_CHANGE_LEVEL_SP,
	HS_CHANGE_LEVEL_MP,
	HS_RUN,
	HS_GAME_SHUTDOWN,
	HS_SHUTDOWN,
	HS_RESTART,
};

struct CHostState
{
  public:
	HostState_t m_iCurrentState;
	HostState_t m_iNextState;

	float m_vecLocation[3];
	float m_angLocation[3];

	char m_levelName[32];
	char m_mapGroupName[32];
	char m_landmarkName[32];
	char m_saveName[32];
	float m_flShortFrameTime; // run a few one-tick frames to avoid large timesteps while loading assets

	bool m_activeGame;
	bool m_bRememberLocation;
	bool m_bBackgroundLevel;
	bool m_bWaitingForConnection;
	bool m_bLetToolsOverrideLoadGameEnts; // During a load game, this tells Foundry to override ents that are selected in Hammer.
	bool m_bSplitScreenConnect;
	bool m_bGameHasShutDownAndFlushedMemory; // This is false once we load a map into memory, and set to true once the map is unloaded and
											 // all memory flushed
	bool m_bWorkshopMapDownloadPending;
};

extern CHostState* g_pHostState;

// cengine stuff
enum EngineQuitState
{
	QUIT_NOTQUITTING = 0,
	QUIT_TODESKTOP,
	QUIT_RESTART
};

enum EngineState_t
{
	DLL_INACTIVE = 0, // no dll
	DLL_ACTIVE,		  // engine is focused
	DLL_CLOSE,		  // closing down dll
	DLL_RESTART,	  // engine is shutting down but will restart right away
	DLL_PAUSED,		  // engine is paused, can become active from this state
};

class CEngine
{
  public:
	virtual void unknown() {} // unsure if this is where
	virtual bool Load(bool dedicated, const char* baseDir) {}
	virtual void Unload() {}
	virtual void SetNextState(EngineState_t iNextState) {}
	virtual EngineState_t GetState() {}
	virtual void Frame() {}
	virtual double GetFrameTime() {}
	virtual float GetCurTime() {}

	EngineQuitState m_nQuitting;
	EngineState_t m_nDllState;
	EngineState_t m_nNextDllState;
	double m_flCurrentTime;
	float m_flFrameTime;
	double m_flPreviousTime;
	float m_flFilteredTime;
	float m_flMinFrameTime; // Expected duration of a frame, or zero if it is unlimited.
};

extern CEngine* g_pEngine;

enum server_state_t
{
	ss_dead = 0, // Dead
	ss_loading,	 // Spawning
	ss_active,	 // Running
	ss_paused,	 // Running, but paused
};

extern server_state_t* sv_m_State;

// network stuff
extern ConVar* Cvar_hostport;
extern ConVar* Cvar_net_datablock_enabled;

// playlist stuff
typedef const char* (*GetCurrentPlaylistType)();
extern GetCurrentPlaylistType GetCurrentPlaylistName;

typedef void (*SetCurrentPlaylistType)(const char* playlistName);
extern SetCurrentPlaylistType SetCurrentPlaylist;

typedef void (*SetPlaylistVarOverrideType)(const char* varName, const char* value);
extern SetPlaylistVarOverrideType SetPlaylistVarOverride;

typedef char* (*GetCurrentPlaylistVarType)(const char* varName, bool useOverrides);
extern GetCurrentPlaylistVarType GetCurrentPlaylistVar;

// server entity stuff
typedef void* (*Server_GetEntityByIndexType)(int index);
extern Server_GetEntityByIndexType Server_GetEntityByIndex;

// server tickrate stuff
extern ConVar* Cvar_base_tickinterval_mp;
extern ConVar* Cvar_base_tickinterval_sp;

// auth
extern char* g_LocalPlayerUserID;
extern char* g_LocalPlayerOriginToken;

// misc stuff
extern ConVar* Cvar_match_defaultMap;
extern ConVar* Cvar_communities_hostname;

typedef void (*ErrorType)(const char* fmt, ...);
extern ErrorType Error;

typedef CCommandLine* (*CommandLineType)();
extern CommandLineType CommandLine;

typedef double (*Plat_FloatTimeType)();
extern Plat_FloatTimeType Plat_FloatTime;

typedef bool (*ThreadInServerFrameThreadType)();
extern ThreadInServerFrameThreadType ThreadInServerFrameThread;

typedef void* (*GetBaseLocalClientType)();
extern GetBaseLocalClientType GetBaseLocalClient;

void InitialiseEngineGameUtilFunctions(HMODULE baseAddress);
void InitialiseServerGameUtilFunctions(HMODULE baseAddress);
void InitialiseTier0GameUtilFunctions(HMODULE baseAddress);