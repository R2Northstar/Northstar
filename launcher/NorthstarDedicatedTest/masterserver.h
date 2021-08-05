#pragma once
#include "convar.h"
#include <WinSock2.h>

class RemoteServerInfo
{
public:
	char id[32];

	// server info
	char name[64];
	char* description;
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
	~RemoteServerInfo(); 
};

class MasterServerManager
{
private:
	bool m_requestingServerList;

public:
	bool m_scriptRequestingServerList;
	bool m_successfullyConnected = true;
	std::list<RemoteServerInfo> m_remoteServers;

public:
	void ClearServerList();
	void RequestServerList();
};

void InitialiseSharedMasterServer(HMODULE baseAddress);

extern MasterServerManager* g_MasterServerManager;