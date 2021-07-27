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
	ServerAuthenticationManager();
	void AddPlayerAuth(char* authToken, char* uid, char* pdata, size_t pdataSize);
	bool AuthenticatePlayer(__int64 player, char* authToken);
	void WritePersistentData(void* player);
};

void InitialiseServerAuthentication(HMODULE baseAddress);

extern ServerAuthenticationManager* g_ServerAuthenticationManager;