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

public:
	void AddPlayerAuth(char* authToken, char* uid, char* pdata, size_t pdataSize);
	bool AuthenticatePlayer(void* player, char* authToken);
	bool RemovePlayerAuthData(void* player);
	void WritePersistentData(void* player);
};

void InitialiseServerAuthentication(HMODULE baseAddress);

extern ServerAuthenticationManager* g_ServerAuthenticationManager;