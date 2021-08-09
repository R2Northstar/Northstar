#pragma once
#include <unordered_map>
#include <string>

struct AuthData
{
	char* uid;

	// pdata
	char* pdata;
	size_t pdataSize;
};

class ServerAuthenticationManager
{
public:
	std::unordered_map<std::string, AuthData*> m_authData;
	bool m_runningPlayerAuthThread = false;

public:
	void StartPlayerAuthServer();
	void AddPlayerAuthData(char* authToken, char* uid, char* pdata, size_t pdataSize);
	bool AuthenticatePlayer(void* player, int64_t uid, char* authToken);
	bool RemovePlayerAuthData(void* player);
	void WritePersistentData(void* player);
};

void InitialiseServerAuthentication(HMODULE baseAddress);

extern ServerAuthenticationManager* g_ServerAuthenticationManager;
extern ConVar* Cvar_ns_player_auth_port;