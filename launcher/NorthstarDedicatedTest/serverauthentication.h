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

class ServerAuthenticationManager
{
private:
	httplib::Server m_playerAuthServer;

public:
	std::mutex m_authDataMutex;
	std::unordered_map<std::string, AuthData> m_authData;
	bool m_runningPlayerAuthThread = false;

public:
	void StartPlayerAuthServer();
	void StopPlayerAuthServer();
	bool AuthenticatePlayer(void* player, int64_t uid, char* authToken);
	bool RemovePlayerAuthData(void* player);
	void WritePersistentData(void* player);
};

void InitialiseServerAuthentication(HMODULE baseAddress);

extern ServerAuthenticationManager* g_ServerAuthenticationManager;
extern ConVar* Cvar_ns_player_auth_port;