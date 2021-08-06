#pragma once
#include "convar.h"
#include <WinSock2.h>

class RemoteServerInfo
{
public:
	char id[32];

	// server info
	char name[64];
	std::string description;
	char map[32];
	char playlist[16];

	int playerCount;
	int maxPlayers;

	// connection stuff
	bool requiresPassword;
	in_addr ip;
	int port;

public:
	RemoteServerInfo(const char* newId, const char* newName, const char* newDescription, const char* newMap, const char* newPlaylist, int newPlayerCount, int newMaxPlayers);
	RemoteServerInfo(const char* newId, const char* newName, const char* newDescription, const char* newMap, const char* newPlaylist, int newPlayerCount, int newMaxPlayers, in_addr newIp, int newPort);
};

struct RemoteServerConnectionInfo
{
public:
	char authToken[32];

	in_addr ip;
	int port;
};

class MasterServerManager
{
private:
	bool m_requestingServerList = false;
	bool m_authenticatingWithGameServer = false;

public:
	bool m_scriptRequestingServerList = false;
	bool m_successfullyConnected = true;

	bool m_scriptAuthenticatingWithGameServer = false;
	bool m_successfullyAuthenticatedWithGameServer = false;

	bool m_hasPendingConnectionInfo = false;
	RemoteServerConnectionInfo m_pendingConnectionInfo;

	std::vector<RemoteServerInfo> m_remoteServers;

public:
	void ClearServerList();
	void RequestServerList();
	void TryAuthenticateWithServer(char* serverId, char* password);
};

void InitialiseSharedMasterServer(HMODULE baseAddress);

extern MasterServerManager* g_MasterServerManager;