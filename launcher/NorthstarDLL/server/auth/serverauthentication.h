#pragma once
#include "core/convar/convar.h"
#include "engine/r2engine.h"
#include <unordered_map>
#include <string>

struct RemoteAuthData
{
	char uid[33];
	char username[64];

	// pdata
	char* pdata;
	size_t pdataSize;
};

struct PlayerAuthenticationData
{
	bool usingLocalPdata;
	size_t pdataSize;
	bool needPersistenceWriteOnLeave = true;
};

typedef int64_t (*CBaseServer__RejectConnectionType)(void* a1, unsigned int a2, void* a3, const char* a4, ...);
extern CBaseServer__RejectConnectionType CBaseServer__RejectConnection;

class ServerAuthenticationManager
{
  public:
	ConVar* Cvar_ns_erase_auth_info;
	ConVar* Cvar_ns_auth_allow_insecure;
	ConVar* Cvar_ns_auth_allow_insecure_write;

	std::mutex m_AuthDataMutex;
	std::unordered_map<std::string, RemoteAuthData> m_RemoteAuthenticationData;
	std::unordered_map<R2::CBaseClient*, PlayerAuthenticationData> m_PlayerAuthenticationData;

	bool m_bAllowDuplicateAccounts = false;
	bool m_bNeedLocalAuthForNewgame = false;
	bool m_bForceResetLocalPlayerPersistence = false;
	bool m_bStartingLocalSPGame = false;

  public:
	void AddRemotePlayer(std::string token, uint64_t uid, std::string username, std::string pdata);

	void AddPlayer(R2::CBaseClient* pPlayer, const char* pAuthToken);
	void RemovePlayer(R2::CBaseClient* pPlayer);

	bool VerifyPlayerName(const char* pAuthToken, const char* pName, char pOutVerifiedName[64]);
	bool IsDuplicateAccount(R2::CBaseClient* pPlayer, const char* pUid);
	bool CheckAuthentication(R2::CBaseClient* pPlayer, uint64_t iUid, char* pAuthToken);

	void AuthenticatePlayer(R2::CBaseClient* pPlayer, uint64_t iUid, char* pAuthToken);
	bool RemovePlayerAuthData(R2::CBaseClient* pPlayer);
	void WritePersistentData(R2::CBaseClient* pPlayer);
};

extern ServerAuthenticationManager* g_pServerAuthentication;
