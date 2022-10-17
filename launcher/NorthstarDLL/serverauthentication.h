#pragma once
#include "convar.h"
#include "httplib.h"
#include "r2engine.h"
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

class ServerAuthenticationManager
{
  private:
	httplib::Server m_PlayerAuthServer;

  public:
	ConVar* Cvar_ns_player_auth_port;
	ConVar* Cvar_ns_erase_auth_info;
	ConVar* CVar_ns_auth_allow_insecure;
	ConVar* CVar_ns_auth_allow_insecure_write;

	std::mutex m_AuthDataMutex;
	std::unordered_map<std::string, RemoteAuthData> m_RemoteAuthenticationData;
	std::unordered_map<R2::CBaseClient*, PlayerAuthenticationData> m_PlayerAuthenticationData;
	bool m_bRequireClientAuth = true;
	bool m_bAllowDuplicateAccounts = false;
	bool m_bRunningPlayerAuthThread = false;
	bool m_bNeedLocalAuthForNewgame = false;
	bool m_bForceResetLocalPlayerPersistence = false;

  public:
	void StartPlayerAuthServer();
	void StopPlayerAuthServer();
	void AddPlayer(R2::CBaseClient* player, const char* pToken);
	void RemovePlayer(R2::CBaseClient* player);
	bool CheckDuplicateAccounts(R2::CBaseClient* player);
	bool AuthenticatePlayer(R2::CBaseClient* player, uint64_t uid, char* authToken);
	void VerifyPlayerName(R2::CBaseClient* player, char* authToken, char* name);
	bool RemovePlayerAuthData(R2::CBaseClient* player);
	void WritePersistentData(R2::CBaseClient* player);
};

extern ServerAuthenticationManager* g_pServerAuthentication;
