#pragma once
#include "convar.h"

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

typedef ECommandTarget_t(*Cbuf_GetCurrentPlayerType)();
extern Cbuf_GetCurrentPlayerType Cbuf_GetCurrentPlayer;

// compared to the defs i've seen, this is missing an arg, it could be nTickInterval or source, not sure, guessing it's source
typedef void(*Cbuf_AddTextType)(ECommandTarget_t eTarget, const char* text, cmd_source_t source);
extern Cbuf_AddTextType Cbuf_AddText;

typedef void(*Cbuf_ExecuteType)();
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

	//virtual const char** GetParms() const {}
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

	// not reversed past this point, struct seems weird
	// pretty decent chance m_levelname is bigger, given it was 256 long in normal source
};

extern CHostState* g_pHostState;

// cengine stuff

enum EngineState_t
{
	DLL_INACTIVE = 0,		// no dll
	DLL_ACTIVE,				// engine is focused
	DLL_CLOSE,				// closing down dll
	DLL_RESTART,			// engine is shutting down but will restart right away
	DLL_PAUSED,				// engine is paused, can become active from this state
};

struct CEngine
{
public:
	void* vtable;

	int m_nQuitting;
	EngineState_t m_nDllState;
	EngineState_t m_nNextDllState;
	double m_flCurrentTime;
	float m_flFrameTime;
	double m_flPreviousTime;
	float m_flFilteredTime;
	float m_flMinFrameTime; // Expected duration of a frame, or zero if it is unlimited.
};

extern CEngine* g_pEngine;

// network stuff

extern ConVar* Cvar_hostport;


// playlist stuff

typedef const char*(*GetCurrentPlaylistType)();
extern GetCurrentPlaylistType GetCurrentPlaylistName;

typedef void(*SetCurrentPlaylistType)(const char* playlistName);
extern SetCurrentPlaylistType SetCurrentPlaylist;

// uid

extern char* g_LocalPlayerUserID;

void InitialiseEngineGameUtilFunctions(HMODULE baseAddress);