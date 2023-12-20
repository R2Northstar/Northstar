#pragma once
#include "shared/keyvalues.h"

// Cbuf
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
	// via FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS.
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

typedef void (*Cbuf_AddTextType)(ECommandTarget_t eTarget, const char* text, cmd_source_t source);
extern Cbuf_AddTextType Cbuf_AddText;

typedef void (*Cbuf_ExecuteType)();
extern Cbuf_ExecuteType Cbuf_Execute;

extern bool (*CCommand__Tokenize)(CCommand& self, const char* pCommandString, cmd_source_t commandSource);

// CEngine

enum EngineQuitState
{
	QUIT_NOTQUITTING = 0,
	QUIT_TODESKTOP,
	QUIT_RESTART
};

enum class EngineState_t
{
	DLL_INACTIVE = 0, // no dll
	DLL_ACTIVE, // engine is focused
	DLL_CLOSE, // closing down dll
	DLL_RESTART, // engine is shutting down but will restart right away
	DLL_PAUSED, // engine is paused, can become active from this state
};

class CEngine
{
  public:
	virtual void unknown() = 0; // unsure if this is where
	virtual bool Load(bool dedicated, const char* baseDir) = 0;
	virtual void Unload() = 0;
	virtual void SetNextState(EngineState_t iNextState) = 0;
	virtual EngineState_t GetState() = 0;
	virtual void Frame() = 0;
	virtual double GetFrameTime() = 0;
	virtual float GetCurTime() = 0;

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

extern void (*CBaseClient__Disconnect)(void* self, uint32_t unknownButAlways1, const char* reason, ...);

#pragma once
typedef enum
{
	NA_NULL = 0,
	NA_LOOPBACK,
	NA_IP,
} netadrtype_t;

#pragma pack(push, 1)
typedef struct netadr_s
{
	netadrtype_t type;
	unsigned char ip[16]; // IPv6
	// IPv4's 127.0.0.1 is [::ffff:127.0.0.1], that is:
	// 00 00 00 00 00 00 00 00    00 00 FF FF 7F 00 00 01
	unsigned short port;
} netadr_t;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct netpacket_s
{
	netadr_t adr; // sender address
	// int				source;		// received source
	char unk[10];
	double received_time;
	unsigned char* data; // pointer to raw packet data
	void* message; // easy bitbuf data access // 'inpacket.message' etc etc (pointer)
	char unk2[16];
	int size;

	// bf_read			message;	// easy bitbuf data access // 'inpacket.message' etc etc (pointer)
	// int				size;		// size in bytes
	// int				wiresize;   // size in bytes before decompression
	// bool			stream;		// was send as stream
	// struct netpacket_s* pNext;	// for internal use, should be NULL in public
} netpacket_t;
#pragma pack(pop)

// #56169 $DB69 PData size
// #512   $200	Trailing data
// #100	  $64	Safety buffer
const int PERSISTENCE_MAX_SIZE = 0xDDCD;

// note: NOT_READY and READY are the only entries we have here that are defined by the vanilla game
// entries after this are custom and used to determine the source of persistence, e.g. whether it is local or remote
enum class ePersistenceReady : char
{
	NOT_READY,
	READY = 3,
	READY_INSECURE = 3,
	READY_REMOTE
};

enum class eSignonState : int
{
	NONE = 0, // no state yet; about to connect
	CHALLENGE = 1, // client challenging server; all OOB packets
	CONNECTED = 2, // client is connected to server; netchans ready
	NEW = 3, // just got serverinfo and string tables
	PRESPAWN = 4, // received signon buffers
	GETTINGDATA = 5, // respawn-defined signonstate, assumedly this is for persistence
	SPAWN = 6, // ready to receive entity packets
	FIRSTSNAP = 7, // another respawn-defined one
	FULL = 8, // we are fully connected; first non-delta packet received
	CHANGELEVEL = 9, // server is changing level; please wait
};

// clang-format off
OFFSET_STRUCT(CBaseClient)
{
	STRUCT_SIZE(0x2D728)
	FIELD(0x16, char m_Name[64])
	FIELD(0x258, KeyValues* m_ConVars)
	FIELD(0x2A0, eSignonState m_Signon)
	FIELD(0x358, char m_ClanTag[16])
	FIELD(0x484, bool m_bFakePlayer)
	FIELD(0x4A0, ePersistenceReady m_iPersistenceReady)
	FIELD(0x4FA, char m_PersistenceBuffer[PERSISTENCE_MAX_SIZE])
	FIELD(0xF500, char m_UID[32])
};
// clang-format on

extern CBaseClient* g_pClientArray;

enum server_state_t
{
	ss_dead = 0, // Dead
	ss_loading, // Spawning
	ss_active, // Running
	ss_paused, // Running, but paused
};

extern server_state_t* g_pServerState;

extern char* g_pModName;

// clang-format off
OFFSET_STRUCT(CGlobalVars)
{
	FIELD(0x0,
		// Absolute time (per frame still - Use Plat_FloatTime() for a high precision real time 
		//  perf clock, but not that it doesn't obey host_timescale/host_framerate)
		double m_flRealTime);

	FIELDS(0x8,
		// Absolute frame counter - continues to increase even if game is paused
		int m_nFrameCount;
		
		// Non-paused frametime
		float m_flAbsoluteFrameTime;
		
		// Current time 
		//
		// On the client, this (along with tickcount) takes a different meaning based on what
		// piece of code you're in:
		// 
		//   - While receiving network packets (like in PreDataUpdate/PostDataUpdate and proxies),
		//     this is set to the SERVER TICKCOUNT for that packet. There is no interval between
		//     the server ticks.
		//     [server_current_Tick * tick_interval]
		//
		//   - While rendering, this is the exact client clock 
		//     [client_current_tick * tick_interval + interpolation_amount]
		//
		//   - During prediction, this is based on the client's current tick:
		//     [client_current_tick * tick_interval]
		float m_flCurTime;
	)

	FIELDS(0x30,
		// Time spent on last server or client frame (has nothing to do with think intervals)
		float m_flFrameTime;

		// current maxplayers setting
		int m_nMaxClients;
	)

	FIELDS(0x3C,
		// Simulation ticks - does not increase when game is paused
		uint32_t m_nTickCount; // this is weird and doesn't seem to increase once per frame?

		// Simulation tick interval
		float m_flTickInterval;
	)

	FIELDS(0x60,
		const char* m_pMapName;
		int m_nMapVersion;
	)

	//FIELD(0x98, double m_flRealTime); // again?
};
// clang-format on

extern CGlobalVars* g_pGlobals;
