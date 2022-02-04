#pragma once
#include "convar.h"
#include <WinSock2.h>
#include <string>
#include <cstring>
struct RemoteModInfo
{
  public:
	std::string Name;
	std::string Version;
};

class RemoteServerInfo
{
  public:
	char id[33]; // 32 bytes + nullterminator

	// server info
	char name[64];
	std::string description;
	char map[32];
	char playlist[16];
	std::vector<RemoteModInfo> requiredMods;

	int playerCount;
	int maxPlayers;

	// connection stuff
	bool requiresPassword;

  public:
	RemoteServerInfo(
		const char* newId, const char* newName, const char* newDescription, const char* newMap, const char* newPlaylist, int newPlayerCount,
		int newMaxPlayers, bool newRequiresPassword);
};

struct RemoteServerConnectionInfo
{
  public:
	char authToken[32];

	in_addr ip;
	unsigned short port;
};

struct MainMenuPromoData
{
  public:
	std::string newInfoTitle1;
	std::string newInfoTitle2;
	std::string newInfoTitle3;

	std::string largeButtonTitle;
	std::string largeButtonText;
	std::string largeButtonUrl;
	int largeButtonImageIndex;

	std::string smallButton1Title;
	std::string smallButton1Url;
	int smallButton1ImageIndex;

	std::string smallButton2Title;
	std::string smallButton2Url;
	int smallButton2ImageIndex;
};

class MasterServerManager
{
  private:
	bool m_requestingServerList = false;
	bool m_authenticatingWithGameServer = false;

  public:
	char m_ownServerId[33];
	char m_ownServerAuthToken[33];
	char m_ownClientAuthToken[33];

	std::string m_ownModInfoJson;
	std::string ns_auth_srvName; // Unicode unescaped version of Cvar_ns_auth_servername for support in cjk characters
	std::string ns_auth_srvDesc; // Unicode unescaped version of Cvar_ns_auth_serverdesc for support in cjk characters

	bool m_bOriginAuthWithMasterServerDone = false;
	bool m_bOriginAuthWithMasterServerInProgress = false;

	bool m_bRequireClientAuth = false;
	bool m_savingPersistentData = false;

	bool m_scriptRequestingServerList = false;
	bool m_successfullyConnected = true;

	bool m_bNewgameAfterSelfAuth = false;
	bool m_scriptAuthenticatingWithGameServer = false;
	bool m_successfullyAuthenticatedWithGameServer = false;

	bool m_hasPendingConnectionInfo = false;
	RemoteServerConnectionInfo m_pendingConnectionInfo;

	std::vector<RemoteServerInfo> m_remoteServers;

	bool m_bHasMainMenuPromoData = false;
	MainMenuPromoData m_MainMenuPromoData;

  private:
	void SetCommonHttpClientOptions(CURL* curl);

  public:
	MasterServerManager();
	void ClearServerList();
	void RequestServerList();
	void RequestMainMenuPromos();
	void AuthenticateOriginWithMasterServer(char* uid, char* originToken);
	void AuthenticateWithOwnServer(char* uid, char* playerToken);
	void AuthenticateWithServer(char* uid, char* playerToken, char* serverId, char* password);
	void
	AddSelfToServerList(int port, int authPort, char* name, char* description, char* map, char* playlist, int maxPlayers, char* password);
	void UpdateServerMapAndPlaylist(char* map, char* playlist, int playerCount);
	void UpdateServerPlayerCount(int playerCount);
	void WritePlayerPersistentData(char* playerId, char* pdata, size_t pdataSize);
	void RemoveSelfFromServerList();
};
std::string unescape_unicode(const std::string& str);
void UpdateServerInfoFromUnicodeToUTF8();
void InitialiseSharedMasterServer(HMODULE baseAddress);

extern MasterServerManager* g_MasterServerManager;
extern ConVar* Cvar_ns_masterserver_hostname;