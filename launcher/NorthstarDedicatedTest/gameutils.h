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


// hoststate stuff

struct CHostState
{
public:
	int32_t m_iCurrentState;
	int32_t m_iNextState;

	float m_vecLocation[3];
	float m_angLocation[3];

	char m_levelName[32];

	// not reversed past this point, struct seems weird
};

extern CHostState* g_GameCHostStateSingleton;

// network stuff

extern ConVar* Cvar_hostport;


// playlist stuff

typedef const char*(*GetCurrentPlaylistType)();
extern GetCurrentPlaylistType GetCurrentPlaylistName;

// uid

extern char* g_LocalPlayerUserID;

void InitialiseEngineGameUtilFunctions(HMODULE baseAddress);