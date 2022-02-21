#pragma once
#include "convar.h"
#include "httplib.h"
#include <unordered_map>
#include <string>

struct AuthData
{
	char uid[33];

	// pdata
	char* pdata;
	size_t pdataSize;
};

struct AdditionalPlayerData
{
	bool usingLocalPdata;
	size_t pdataSize;
	bool needPersistenceWriteOnLeave = true;

	double lastClientCommandQuotaStart = -1.0;
	int numClientCommandsInQuota = 0;

	double lastNetChanProcessingLimitStart = -1.0;
	double netChanProcessingLimitTime = 0.0;

	double lastSayTextLimitStart = -1.0;
	int sayTextLimitCount = 0;
};

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
	void* message;		 // easy bitbuf data access // 'inpacket.message' etc etc (pointer)
	char unk2[16];
	int size;

	// bf_read			message;	// easy bitbuf data access // 'inpacket.message' etc etc (pointer)
	// int				size;		// size in bytes
	// int				wiresize;   // size in bytes before decompression
	// bool			stream;		// was send as stream
	// struct netpacket_s* pNext;	// for internal use, should be NULL in public
} netpacket_t;
#pragma pack(pop)

struct UnconnectedPlayerSendData
{
	char ip[16];
	double lastQuotaStart = 0.0;
	int packetCount = 0;
	double timeoutEnd = -1.0;
};

class ServerAuthenticationManager
{
  private:
	httplib::Server m_playerAuthServer;

  public:
	std::mutex m_authDataMutex;
	std::unordered_map<std::string, AuthData> m_authData;
	std::unordered_map<void*, AdditionalPlayerData> m_additionalPlayerData;
	std::vector<UnconnectedPlayerSendData> m_unconnectedPlayerSendData;
	bool m_runningPlayerAuthThread = false;
	bool m_bNeedLocalAuthForNewgame = false;
	bool m_bForceReadLocalPlayerPersistenceFromDisk = false;

  public:
	void StartPlayerAuthServer();
	void StopPlayerAuthServer();
	bool AuthenticatePlayer(void* player, int64_t uid, char* authToken);
	bool RemovePlayerAuthData(void* player);
	void WritePersistentData(void* player);
	bool CheckPlayerChatRatelimit(void* player);
};

typedef void (*CBaseClient__DisconnectType)(void* self, uint32_t unknownButAlways1, const char* reason, ...);
extern CBaseClient__DisconnectType CBaseClient__Disconnect;

void InitialiseServerAuthentication(HMODULE baseAddress);

extern ServerAuthenticationManager* g_ServerAuthenticationManager;
extern ConVar* Cvar_ns_player_auth_port;