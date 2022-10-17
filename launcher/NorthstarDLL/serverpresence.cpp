#include "pch.h"
#include "serverpresence.h"
#include "playlist.h"
#include "tier0.h"
#include "convar.h"

#include <regex>

ServerPresenceManager* g_pServerPresence;

ConVar* Cvar_hostname;

// Convert a hex digit char to integer.
inline int hctod(char c)
{
	if (c >= 'A' && c <= 'F')
	{
		return c - 'A' + 10;
	}
	else if (c >= 'a' && c <= 'f')
	{
		return c - 'a' + 10;
	}
	else
	{
		return c - '0';
	}
}

// This function interprets all 4-hexadecimal-digit unicode codepoint characters like \u4E2D to UTF-8 encoding.
std::string UnescapeUnicode(const std::string& str)
{
	std::string result;

	std::regex r("\\\\u([a-f\\d]{4})", std::regex::icase);
	auto matches_begin = std::sregex_iterator(str.begin(), str.end(), r);
	auto matches_end = std::sregex_iterator();
	std::smatch last_match;

	for (std::sregex_iterator i = matches_begin; i != matches_end; ++i)
	{
		last_match = *i;
		result.append(last_match.prefix());
		unsigned int cp = 0;
		for (int i = 2; i <= 5; ++i)
		{
			cp *= 16;
			cp += hctod(last_match.str()[i]);
		}
		if (cp <= 0x7F)
		{
			result.push_back(cp);
		}
		else if (cp <= 0x7FF)
		{
			result.push_back((cp >> 6) | 0b11000000 & (~(1 << 5)));
			result.push_back(cp & ((1 << 6) - 1) | 0b10000000 & (~(1 << 6)));
		}
		else if (cp <= 0xFFFF)
		{
			result.push_back((cp >> 12) | 0b11100000 & (~(1 << 4)));
			result.push_back((cp >> 6) & ((1 << 6) - 1) | 0b10000000 & (~(1 << 6)));
			result.push_back(cp & ((1 << 6) - 1) | 0b10000000 & (~(1 << 6)));
		}
	}

	if (!last_match.ready())
		return str;
	else
		result.append(last_match.suffix());

	return result;
}

ServerPresenceManager::ServerPresenceManager()
{
	// clang-format off
	// register convars
	Cvar_ns_server_presence_update_rate = new ConVar(
		"ns_server_presence_update_rate", "5000", FCVAR_GAMEDLL, "How often we update our server's presence on server lists in ms");

	Cvar_ns_server_name = new ConVar("ns_server_name", "Unnamed Northstar Server", FCVAR_GAMEDLL, "This server's description", false, 0, false, 0, [](ConVar* cvar, const char* pOldValue, float flOldValue) {
			g_pServerPresence->SetName(UnescapeUnicode(g_pServerPresence->Cvar_ns_server_name->GetString()));

			// update engine hostname cvar
			Cvar_hostname->SetValue(g_pServerPresence->Cvar_ns_server_name->GetString());
		});

	Cvar_ns_server_desc = new ConVar("ns_server_desc", "Default server description", FCVAR_GAMEDLL, "This server's name", false, 0, false, 0, [](ConVar* cvar, const char* pOldValue, float flOldValue) {
			g_pServerPresence->SetDescription(UnescapeUnicode(g_pServerPresence->Cvar_ns_server_desc->GetString()));
		});

	Cvar_ns_server_password = new ConVar("ns_server_password", "", FCVAR_GAMEDLL, "This server's password", false, 0, false, 0, [](ConVar* cvar, const char* pOldValue, float flOldValue) {
			g_pServerPresence->SetPassword(g_pServerPresence->Cvar_ns_server_password->GetString());
		});

	Cvar_ns_report_server_to_masterserver = new ConVar("ns_report_server_to_masterserver", "1", FCVAR_GAMEDLL, "Whether we should report this server to the masterserver");
	Cvar_ns_report_sp_server_to_masterserver = new ConVar("ns_report_sp_server_to_masterserver", "0", FCVAR_GAMEDLL, "Whether we should report this server to the masterserver, when started in singleplayer");
	// clang-format on
}

void ServerPresenceManager::AddPresenceReporter(ServerPresenceReporter* reporter)
{
	m_vPresenceReporters.push_back(reporter);
}

void ServerPresenceManager::CreatePresence()
{
	// reset presence fields that rely on runtime server state
	// these being: port/auth port, map/playlist name, and playercount/maxplayers
	m_ServerPresence.m_iPort = 0;
	m_ServerPresence.m_iAuthPort = 0;

	m_ServerPresence.m_iPlayerCount = 0; // this should actually be 0 at this point, so shouldn't need updating later
	m_ServerPresence.m_iMaxPlayers = 0;

	memset(m_ServerPresence.m_MapName, 0, sizeof(m_ServerPresence.m_MapName));
	memset(m_ServerPresence.m_PlaylistName, 0, sizeof(m_ServerPresence.m_PlaylistName));
	m_ServerPresence.m_bIsSingleplayerServer = false;

	m_bHasPresence = true;
	m_bFirstPresenceUpdate = true;

	// code that's calling this should set up the reset fields at this point
}

void ServerPresenceManager::DestroyPresence()
{
	m_bHasPresence = false;

	for (ServerPresenceReporter* reporter : m_vPresenceReporters)
		reporter->DestroyPresence(&m_ServerPresence);
}

void ServerPresenceManager::RunFrame(double flCurrentTime)
{
	if (!m_bHasPresence || !Cvar_ns_report_server_to_masterserver->GetBool()) // don't run until we actually have server presence
		return;

	// don't run if we're sp and don't want to report sp
	if (m_ServerPresence.m_bIsSingleplayerServer && !Cvar_ns_report_sp_server_to_masterserver->GetBool())
		return;

	// Call RunFrame() so that reporters can, for example, handle std::future results as soon as they arrive.
	for (ServerPresenceReporter* reporter : m_vPresenceReporters)
		reporter->RunFrame(flCurrentTime, &m_ServerPresence);

	// run on a specified delay
	if ((flCurrentTime - m_flLastPresenceUpdate) * 1000 < Cvar_ns_server_presence_update_rate->GetFloat())
		return;

	// is this the first frame we're updating this presence?
	if (m_bFirstPresenceUpdate)
	{
		// let reporters setup/clear any state
		for (ServerPresenceReporter* reporter : m_vPresenceReporters)
			reporter->CreatePresence(&m_ServerPresence);

		m_bFirstPresenceUpdate = false;
	}

	m_flLastPresenceUpdate = flCurrentTime;

	for (ServerPresenceReporter* reporter : m_vPresenceReporters)
		reporter->ReportPresence(&m_ServerPresence);
}

void ServerPresenceManager::SetPort(const int iPort)
{
	// update port
	m_ServerPresence.m_iPort = iPort;
}

void ServerPresenceManager::SetAuthPort(const int iAuthPort)
{
	// update authport
	m_ServerPresence.m_iAuthPort = iAuthPort;
}

void ServerPresenceManager::SetName(const std::string sServerNameUnicode)
{
	// update name
	m_ServerPresence.m_sServerName = sServerNameUnicode;
}

void ServerPresenceManager::SetDescription(const std::string sServerDescUnicode)
{
	// update desc
	m_ServerPresence.m_sServerDesc = sServerDescUnicode;
}

void ServerPresenceManager::SetPassword(const char* pPassword)
{
	// update password
	strncpy_s(m_ServerPresence.m_Password, sizeof(m_ServerPresence.m_Password), pPassword, sizeof(m_ServerPresence.m_Password) - 1);
}

void ServerPresenceManager::SetMap(const char* pMapName, bool isInitialising)
{
	// if the server is initialising (i.e. this is first map) on sp, set the server to sp
	if (isInitialising)
		m_ServerPresence.m_bIsSingleplayerServer = !strncmp(pMapName, "sp_", 3);

	// update map
	strncpy_s(m_ServerPresence.m_MapName, sizeof(m_ServerPresence.m_MapName), pMapName, sizeof(m_ServerPresence.m_MapName) - 1);
}

void ServerPresenceManager::SetPlaylist(const char* pPlaylistName)
{
	// update playlist
	strncpy_s(
		m_ServerPresence.m_PlaylistName,
		sizeof(m_ServerPresence.m_PlaylistName),
		pPlaylistName,
		sizeof(m_ServerPresence.m_PlaylistName) - 1);

	// update maxplayers
	const char* pMaxPlayers = R2::GetCurrentPlaylistVar("max_players", true);

	// can be null in some situations, so default 6
	if (pMaxPlayers)
		m_ServerPresence.m_iMaxPlayers = std::stoi(pMaxPlayers);
	else
		m_ServerPresence.m_iMaxPlayers = 6;
}

void ServerPresenceManager::SetPlayerCount(const int iPlayerCount)
{
	m_ServerPresence.m_iPlayerCount = iPlayerCount;
}

ON_DLL_LOAD_RELIESON("engine.dll", ServerPresence, ConVar, (CModule module))
{
	g_pServerPresence = new ServerPresenceManager;

	Cvar_hostname = module.Offset(0x1315BAE8).Deref().As<ConVar*>();
}
