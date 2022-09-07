#pragma once
#include "convar.h"
#include <winsock2.h>
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
		const char* newId,
		const char* newName,
		const char* newDescription,
		const char* newMap,
		const char* newPlaylist,
		int newPlayerCount,
		int newMaxPlayers,
		bool newRequiresPassword);
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
	bool m_bRequestingServerList = false;
	bool m_bAuthenticatingWithGameServer = false;

  public:
	char m_sOwnServerId[33];
	char m_sOwnServerAuthToken[33];
	char m_sOwnClientAuthToken[33];

	std::string m_sOwnModInfoJson;
	std::string m_sUnicodeServerName; // Unicode unescaped version of Cvar_ns_auth_servername for support in cjk characters
	std::string m_sUnicodeServerDesc; // Unicode unescaped version of Cvar_ns_auth_serverdesc for support in cjk characters

	bool m_bOriginAuthWithMasterServerDone = false;
	bool m_bOriginAuthWithMasterServerInProgress = false;

	bool m_bRequireClientAuth = false;
	bool m_bSavingPersistentData = false;

	bool m_bScriptRequestingServerList = false;
	bool m_bSuccessfullyConnected = true;

	bool m_bNewgameAfterSelfAuth = false;
	bool m_bScriptAuthenticatingWithGameServer = false;
	bool m_bSuccessfullyAuthenticatedWithGameServer = false;

	std::string s_authfail_reason {};

	bool m_bHasPendingConnectionInfo = false;
	RemoteServerConnectionInfo m_pendingConnectionInfo;

	std::vector<RemoteServerInfo> m_vRemoteServers;

	bool m_bHasMainMenuPromoData = false;
	MainMenuPromoData m_sMainMenuPromoData;

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
extern ConVar* Cvar_ns_server_password;
