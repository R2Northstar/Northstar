#include "pch.h"
#include "serverauthentication.h"
#include "limits.h"
#include "cvar.h"
#include "convar.h"
#include "masterserver.h"
#include "serverpresence.h"
#include "hoststate.h"
#include "maxplayers.h"
#include "bansystem.h"
#include "concommand.h"
#include "dedicated.h"
#include "nsprefix.h"
#include "tier0.h"
#include "r2engine.h"
#include "r2client.h"
#include "r2server.h"

#include "httplib.h"

#include <fstream>
#include <filesystem>
#include <thread>

AUTOHOOK_INIT()

const char* AUTHSERVER_VERIFY_STRING = "I am a northstar server!";

// global vars
ServerAuthenticationManager* g_pServerAuthentication;
CBaseServer__RejectConnectionType CBaseServer__RejectConnection;

void ServerAuthenticationManager::StartPlayerAuthServer()
{
	if (m_bRunningPlayerAuthThread)
	{
		spdlog::warn("ServerAuthenticationManager::StartPlayerAuthServer was called while m_bRunningPlayerAuthThread is true");
		return;
	}

	g_pServerPresence->SetAuthPort(Cvar_ns_player_auth_port->GetInt()); // set auth port for presence
	m_bRunningPlayerAuthThread = true;

	// listen is a blocking call so thread this
	std::thread serverThread(
		[this]
		{
			// this is just a super basic way to verify that servers have ports open, masterserver will try to read this before ensuring
			// server is legit
			m_PlayerAuthServer.Get(
				"/verify",
				[](const httplib::Request& request, httplib::Response& response)
				{ response.set_content(AUTHSERVER_VERIFY_STRING, "text/plain"); });

			m_PlayerAuthServer.Post(
				"/authenticate_incoming_player",
				[this](const httplib::Request& request, httplib::Response& response)
				{
					if (!request.has_param("id") || !request.has_param("authToken") || request.body.size() >= R2::PERSISTENCE_MAX_SIZE ||
						!request.has_param("serverAuthToken") ||
						strcmp(g_pMasterServerManager->m_sOwnServerAuthToken, request.get_param_value("serverAuthToken").c_str()))
					{
						response.set_content("{\"success\":false}", "application/json");
						return;
					}

					RemoteAuthData newAuthData {};
					strncpy_s(newAuthData.uid, sizeof(newAuthData.uid), request.get_param_value("id").c_str(), sizeof(newAuthData.uid) - 1);
					strncpy_s(
						newAuthData.username,
						sizeof(newAuthData.username),
						request.get_param_value("username").c_str(),
						sizeof(newAuthData.username) - 1);

					newAuthData.pdataSize = request.body.size();
					newAuthData.pdata = new char[newAuthData.pdataSize];
					memcpy(newAuthData.pdata, request.body.c_str(), newAuthData.pdataSize);

					std::lock_guard<std::mutex> guard(m_AuthDataMutex);
					m_RemoteAuthenticationData.insert(std::make_pair(request.get_param_value("authToken"), newAuthData));

					response.set_content("{\"success\":true}", "application/json");
				});

			m_PlayerAuthServer.listen("0.0.0.0", Cvar_ns_player_auth_port->GetInt());
		});

	serverThread.detach();
}

void ServerAuthenticationManager::StopPlayerAuthServer()
{
	if (!m_bRunningPlayerAuthThread)
	{
		spdlog::warn("ServerAuthenticationManager::StopPlayerAuthServer was called while m_bRunningPlayerAuthThread is false");
		return;
	}

	m_bRunningPlayerAuthThread = false;
	m_PlayerAuthServer.stop();
}

void ServerAuthenticationManager::AddPlayer(R2::CBaseClient* player, const char* pToken)
{
	PlayerAuthenticationData additionalData;
	additionalData.pdataSize = m_RemoteAuthenticationData[pToken].pdataSize;
	additionalData.usingLocalPdata = player->m_iPersistenceReady == R2::ePersistenceReady::READY_INSECURE;

	m_PlayerAuthenticationData.insert(std::make_pair(player, additionalData));
}

void ServerAuthenticationManager::RemovePlayer(R2::CBaseClient* player)
{
	if (m_PlayerAuthenticationData.count(player))
		m_PlayerAuthenticationData.erase(player);
}

bool checkIsPlayerNameValid(const char* name)
{
	int len = strlen(name);
	// Restricts name to max 63 characters
	if (len >= 64)
		return false;
	for (int i = 0; i < len; i++)
	{
		// Restricts the characters in the name to a restricted range in ASCII
		if (static_cast<int>(name[i]) < 32 || static_cast<int>(name[i]) > 126)
		{
			return false;
		}
	}
	return true;
}

bool ServerAuthenticationManager::VerifyPlayerName(const char* authToken, const char* name)
{
	std::lock_guard<std::mutex> guard(m_AuthDataMutex);

	if (CVar_ns_auth_allow_insecure->GetInt())
	{
		spdlog::info("Allowing player with name '{}' because ns_auth_allow_insecure is enabled", name);
		return true;
	}

	if (!checkIsPlayerNameValid(name))
	{
		spdlog::info("Rejecting player with name '{}' because the name contains forbidden characters", name);
		return false;
	}
	// TODO: We should really have a better way of doing this for singleplayer
	// Best way of doing this would be to check if server is actually in singleplayer mode, or just running a SP map in multiplayer
	// Currently there's not an easy way of checking this, so we just disable this check if mapname starts with `sp_`
	// This means that player names are not checked on singleplayer
	if ((m_RemoteAuthenticationData.empty() || m_RemoteAuthenticationData.count(std::string(authToken)) == 0) &&
		strncmp(R2::g_pHostState->m_levelName, "sp_", 3) != 0)
	{
		spdlog::info("Rejecting player with name '{}' because authToken '{}' was not found", name, authToken);
		return false;
	}

	const RemoteAuthData& authData = m_RemoteAuthenticationData[authToken];

	if (*authData.username && strncmp(name, authData.username, 64) != 0)
	{
		spdlog::info("Rejecting player with name '{}' because name does not match expected name '{}'", name, authData.username);
		return false;
	}

	return true;
}

bool ServerAuthenticationManager::CheckDuplicateAccounts(R2::CBaseClient* player)
{
	if (m_bAllowDuplicateAccounts)
		return true;

	bool bHasUidPlayer = false;
	for (int i = 0; i < R2::GetMaxPlayers(); i++)
		if (&R2::g_pClientArray[i] != player && !strcmp(R2::g_pClientArray[i].m_UID, player->m_UID))
			return false;

	return true;
}

bool ServerAuthenticationManager::AuthenticatePlayer(R2::CBaseClient* player, uint64_t uid, char* authToken)
{
	std::string strUid = std::to_string(uid);
	std::lock_guard<std::mutex> guard(m_AuthDataMutex);

	if (!strncmp(R2::g_pHostState->m_levelName, "sp_", 3))
		return true;

	// copy uuid
	strcpy(player->m_UID, strUid.c_str());

	bool authFail = true;
	if (!m_RemoteAuthenticationData.empty() && m_RemoteAuthenticationData.count(std::string(authToken)))
	{
		if (!CheckDuplicateAccounts(player))
			return false;

		// use stored auth data
		RemoteAuthData authData = m_RemoteAuthenticationData[authToken];

		if (!strcmp(strUid.c_str(), authData.uid)) // connecting client's uid is the same as auth's uid
		{
			// if we're resetting let script handle the reset
			if (!m_bForceResetLocalPlayerPersistence || strcmp(authData.uid, R2::g_pLocalPlayerUserID))
			{
				// copy pdata into buffer
				memcpy(player->m_PersistenceBuffer, authData.pdata, authData.pdataSize);
			}

			// set persistent data as ready
			player->m_iPersistenceReady = R2::ePersistenceReady::READY_REMOTE;
			authFail = false;
		}
	}

	if (authFail)
	{
		if (CVar_ns_auth_allow_insecure->GetBool())
		{
			// set persistent data as ready
			// note: actual placeholder persistent data is populated in script with InitPersistentData()
			player->m_iPersistenceReady = R2::ePersistenceReady::READY_INSECURE;
			return true;
		}
		else
			return false;
	}

	return true; // auth successful, client stays on
}

bool ServerAuthenticationManager::RemovePlayerAuthData(R2::CBaseClient* player)
{
	if (!Cvar_ns_erase_auth_info->GetBool()) // keep auth data forever
		return false;

	// hack for special case where we're on a local server, so we erase our own newly created auth data on disconnect
	if (m_bNeedLocalAuthForNewgame && !strcmp(player->m_UID, R2::g_pLocalPlayerUserID))
		return false;

	// we don't have our auth token at this point, so lookup authdata by uid
	for (auto& auth : m_RemoteAuthenticationData)
	{
		if (!strcmp(player->m_UID, auth.second.uid))
		{
			// pretty sure this is fine, since we don't iterate after the erase
			// i think if we iterated after it'd be undefined behaviour tho
			std::lock_guard<std::mutex> guard(m_AuthDataMutex);

			delete[] auth.second.pdata;
			m_RemoteAuthenticationData.erase(auth.first);
			return true;
		}
	}

	return false;
}

void ServerAuthenticationManager::WritePersistentData(R2::CBaseClient* player)
{
	if (player->m_iPersistenceReady == R2::ePersistenceReady::READY_REMOTE)
	{
		g_pMasterServerManager->WritePlayerPersistentData(
			player->m_UID, (const char*)player->m_PersistenceBuffer, m_PlayerAuthenticationData[player].pdataSize);
	}
	else if (CVar_ns_auth_allow_insecure_write->GetBool())
	{
		// todo: write pdata to disk here
	}
}

// auth hooks

// store these in vars so we can use them in CBaseClient::Connect
// this is fine because ptrs won't decay by the time we use this, just don't use it outside of calls from cbaseclient::connectclient
char* pNextPlayerToken;
uint64_t iNextPlayerUid;

// clang-format off
AUTOHOOK(CBaseServer__ConnectClient, engine.dll + 0x114430,
void*,, (
	void* self,
	void* addr,
	void* a3,
	uint32_t a4,
	uint32_t a5,
	int32_t a6,
	void* a7,
	char* playerName,
	char* serverFilter,
	void* a10,
	char a11,
	void* a12,
	char a13,
	char a14,
	int64_t uid,
	uint32_t a16,
	uint32_t a17))
// clang-format on
{
	// auth tokens are sent with serverfilter, can't be accessed from player struct to my knowledge, so have to do this here
	pNextPlayerToken = serverFilter;
	iNextPlayerUid = uid;

	spdlog::info(
		"CBaseServer__ClientConnect attempted connection with uid {}, playerName '{}', serverFilter '{}'", uid, playerName, serverFilter);

	if (!g_pServerAuthentication->VerifyPlayerName(pNextPlayerToken, playerName))
	{
		CBaseServer__RejectConnection(self, *((int*)self + 3), addr, "Invalid Name.\n");
		return nullptr;
	}
	if (!g_pBanSystem->IsUIDAllowed(uid))
	{
		CBaseServer__RejectConnection(self, *((int*)self + 3), addr, "Banned From server.\n");
		return nullptr;
	}

	return CBaseServer__ConnectClient(self, addr, a3, a4, a5, a6, a7, playerName, serverFilter, a10, a11, a12, a13, a14, uid, a16, a17);
}

// clang-format off
AUTOHOOK(CBaseClient__Connect, engine.dll + 0x101740,
bool,, (R2::CBaseClient* self, char* name, void* netchan_ptr_arg, char b_fake_player_arg, void* a5, char* Buffer, void* a7))
// clang-format on
{
	// try to auth player, dc if it fails
	// we connect regardless of auth, because returning bad from this function can fuck client state p bad
	bool ret = CBaseClient__Connect(self, name, netchan_ptr_arg, b_fake_player_arg, a5, Buffer, a7);
	if (!ret)
		return ret;

	if (!g_pServerAuthentication->VerifyPlayerName(pNextPlayerToken, name))
	{
		R2::CBaseClient__Disconnect(self, 1, "Invalid Name.\n");
		return false;
	}
	if (!g_pBanSystem->IsUIDAllowed(iNextPlayerUid))
	{
		R2::CBaseClient__Disconnect(self, 1, "Banned From server.\n");
		return false;
	}
	if (!g_pServerAuthentication->AuthenticatePlayer(self, iNextPlayerUid, pNextPlayerToken))
	{
		R2::CBaseClient__Disconnect(self, 1, "Authentication Failed.\n");
		return false;
	}

	g_pServerAuthentication->AddPlayer(self, pNextPlayerToken);
	g_pServerLimits->AddPlayer(self);

	return ret;
}

// clang-format off
AUTOHOOK(CBaseClient__ActivatePlayer, engine.dll + 0x100F80,
void,, (R2::CBaseClient* self))
// clang-format on
{
	// if we're authed, write our persistent data
	// RemovePlayerAuthData returns true if it removed successfully, i.e. on first call only, and we only want to write on >= second call
	// (since this func is called on map loads)
	if (self->m_iPersistenceReady >= R2::ePersistenceReady::READY && !g_pServerAuthentication->RemovePlayerAuthData(self))
	{
		g_pServerAuthentication->m_bForceResetLocalPlayerPersistence = false;
		g_pServerAuthentication->WritePersistentData(self);
		g_pServerPresence->SetPlayerCount(g_pServerAuthentication->m_PlayerAuthenticationData.size());
	}

	CBaseClient__ActivatePlayer(self);
}

// clang-format off
AUTOHOOK(_CBaseClient__Disconnect, engine.dll + 0x1012C0,
void,, (R2::CBaseClient* self, uint32_t unknownButAlways1, const char* pReason, ...))
// clang-format on
{
	// have to manually format message because can't pass varargs to original func
	char buf[1024];

	va_list va;
	va_start(va, pReason);
	vsprintf(buf, pReason, va);
	va_end(va);

	// this reason is used while connecting to a local server, hacky, but just ignore it
	if (strcmp(pReason, "Connection closing"))
	{
		spdlog::info("Player {} disconnected: \"{}\"", self->m_Name, buf);

		// dcing, write persistent data
		if (g_pServerAuthentication->m_PlayerAuthenticationData[self].needPersistenceWriteOnLeave)
			g_pServerAuthentication->WritePersistentData(self);
		g_pServerAuthentication->RemovePlayerAuthData(self); // won't do anything 99% of the time, but just in case
	}

	g_pServerAuthentication->RemovePlayer(self);
	g_pServerLimits->RemovePlayer(self);

	g_pServerPresence->SetPlayerCount(g_pServerAuthentication->m_PlayerAuthenticationData.size());

	_CBaseClient__Disconnect(self, unknownButAlways1, buf);
}

void ConCommand_ns_resetpersistence(const CCommand& args)
{
	if (*R2::g_pServerState == R2::server_state_t::ss_active)
	{
		spdlog::error("ns_resetpersistence must be entered from the main menu");
		return;
	}

	spdlog::info("resetting persistence on next lobby load...");
	g_pServerAuthentication->m_bForceResetLocalPlayerPersistence = true;
}

ON_DLL_LOAD_RELIESON("engine.dll", ServerAuthentication, (ConCommand, ConVar), (CModule module))
{
	AUTOHOOK_DISPATCH()

	g_pServerAuthentication = new ServerAuthenticationManager;

	g_pServerAuthentication->Cvar_ns_player_auth_port = new ConVar("ns_player_auth_port", "8081", FCVAR_GAMEDLL, "");
	g_pServerAuthentication->Cvar_ns_erase_auth_info =
		new ConVar("ns_erase_auth_info", "1", FCVAR_GAMEDLL, "Whether auth info should be erased from this server on disconnect or crash");
	g_pServerAuthentication->CVar_ns_auth_allow_insecure =
		new ConVar("ns_auth_allow_insecure", "0", FCVAR_GAMEDLL, "Whether this server will allow unauthenicated players to connect");
	g_pServerAuthentication->CVar_ns_auth_allow_insecure_write = new ConVar(
		"ns_auth_allow_insecure_write",
		"0",
		FCVAR_GAMEDLL,
		"Whether the pdata of unauthenticated clients will be written to disk when changed");

	RegisterConCommand(
		"ns_resetpersistence", ConCommand_ns_resetpersistence, "resets your pdata when you next enter the lobby", FCVAR_NONE);

	// patch to disable kicking based on incorrect serverfilter in connectclient, since we repurpose it for use as an auth token
	module.Offset(0x114655).Patch("EB");

	// patch to disable fairfight marking players as cheaters and kicking them
	module.Offset(0x101012).Patch("E9 90 00");

	CBaseServer__RejectConnection = module.Offset(0x1182E0).As<CBaseServer__RejectConnectionType>();

	if (Tier0::CommandLine()->CheckParm("-allowdupeaccounts"))
	{
		// patch to allow same of multiple account
		module.Offset(0x114510).Patch("EB");

		g_pServerAuthentication->m_bAllowDuplicateAccounts = true;
	}
}
