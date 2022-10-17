#pragma once
#include "convar.h"

struct ServerPresence
{
	int m_iPort;
	int m_iAuthPort;

	std::string m_sServerName;
	std::string m_sServerDesc;
	char m_Password[256]; // probably bigger than will ever be used in practice, lol

	char m_MapName[32];
	char m_PlaylistName[64];
	bool m_bIsSingleplayerServer; // whether the server started in sp

	int m_iPlayerCount;
	int m_iMaxPlayers;

	ServerPresence()
	{
		memset(this, 0, sizeof(this));
	}

	ServerPresence(const ServerPresence* obj)
	{
		m_iPort = obj->m_iPort;
		m_iAuthPort = obj->m_iAuthPort;

		m_sServerName = obj->m_sServerName;
		m_sServerDesc = obj->m_sServerDesc;
		memcpy(m_Password, obj->m_Password, sizeof(m_Password));

		memcpy(m_MapName, obj->m_MapName, sizeof(m_MapName));
		memcpy(m_PlaylistName, obj->m_PlaylistName, sizeof(m_PlaylistName));

		m_iPlayerCount = obj->m_iPlayerCount;
		m_iMaxPlayers = obj->m_iMaxPlayers;
	}
};

class ServerPresenceReporter
{
  public:
	virtual void CreatePresence(const ServerPresence* pServerPresence) {}
	virtual void ReportPresence(const ServerPresence* pServerPresence) {}
	virtual void DestroyPresence(const ServerPresence* pServerPresence) {}
	virtual void RunFrame(double flCurrentTime, const ServerPresence* pServerPresence) {}
};

class ServerPresenceManager
{
  private:
	ServerPresence m_ServerPresence;

	bool m_bHasPresence = false;
	bool m_bFirstPresenceUpdate = false;

	std::vector<ServerPresenceReporter*> m_vPresenceReporters;

	double m_flLastPresenceUpdate = 0;
	ConVar* Cvar_ns_server_presence_update_rate;

	ConVar* Cvar_ns_server_name;
	ConVar* Cvar_ns_server_desc;
	ConVar* Cvar_ns_server_password;

	ConVar* Cvar_ns_report_server_to_masterserver;
	ConVar* Cvar_ns_report_sp_server_to_masterserver;

  public:
	ServerPresenceManager();

	void AddPresenceReporter(ServerPresenceReporter* reporter);

	void CreatePresence();
	void DestroyPresence();
	void RunFrame(double flCurrentTime);

	void SetPort(const int iPort);
	void SetAuthPort(const int iPort);

	void SetName(const std::string sServerNameUnicode);
	void SetDescription(const std::string sServerDescUnicode);
	void SetPassword(const char* pPassword);

	void SetMap(const char* pMapName, bool isInitialising = false);
	void SetPlaylist(const char* pPlaylistName);
	void SetPlayerCount(const int iPlayerCount);
};

extern ServerPresenceManager* g_pServerPresence;
