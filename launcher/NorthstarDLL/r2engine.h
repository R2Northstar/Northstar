#pragma once

// use the R2 namespace for game funcs
namespace R2
{
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

#pragma pack(push, 1)
	struct CBaseClient // 0x2D728 bytes
	{
		char pad0[0x16];

		// +0x16
		char m_Name[64];

		// +0x56
		char pad1[0x202];

		void** m_ConVars; // this is a KeyValues* object but not got that struct mapped out atm

		char pad2[0x240];

		// +0x4A0
		ePersistenceReady m_iPersistenceReady;
		// +0x4A1

		char pad3[0x59];

		// +0x4FA
		char m_PersistenceBuffer[PERSISTENCE_MAX_SIZE];

		char pad4[0x2006];

		// +0xF500
		char m_UID[32];
		// +0xF520

		char pad5[0x1E208];
	};
#pragma pack(pop)

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
} // namespace R2
