#include "serverauthentication.h"
#include "shared/exploit_fixes/ns_limits.h"
#include "core/convar/cvar.h"
#include "core/convar/convar.h"
#include "masterserver/masterserver.h"
#include "server/serverpresence.h"
#include "engine/hoststate.h"
#include "bansystem.h"
#include "core/convar/concommand.h"
#include "dedicated/dedicated.h"
#include "config/profile.h"
#include "core/tier0.h"
#include "engine/r2engine.h"
#include "client/r2client.h"
#include "server/r2server.h"

#include <fstream>
#include <filesystem>
#include <string>
#include <thread>

AUTOHOOK_INIT()

// global vars
ServerAuthenticationManager* g_pServerAuthentication;
CBaseServer__RejectConnectionType CBaseServer__RejectConnection;

typedef void (*CBaseServer__PushDisconnectReasonType)(void*, int32_t, void*, const char*);
CBaseServer__PushDisconnectReasonType CBaseServer__PushDisconnectReason;

void ServerAuthenticationManager::AddRemotePlayer(std::string token, uint64_t uid, std::string username, std::string pdata)
{
	std::string uidS = std::to_string(uid);

	RemoteAuthData newAuthData {};
	strncpy_s(newAuthData.uid, sizeof(newAuthData.uid), uidS.c_str(), uidS.length());
	strncpy_s(newAuthData.username, sizeof(newAuthData.username), username.c_str(), username.length());
	newAuthData.pdata = new char[pdata.length()];
	newAuthData.pdataSize = pdata.length();
	memcpy(newAuthData.pdata, pdata.c_str(), newAuthData.pdataSize);

	std::lock_guard<std::mutex> guard(m_AuthDataMutex);
	m_RemoteAuthenticationData[token] = newAuthData;
}

void ServerAuthenticationManager::AddPlayer(R2::CBaseClient* pPlayer, const char* pToken)
{
	PlayerAuthenticationData additionalData;

	auto remoteAuthData = m_RemoteAuthenticationData.find(pToken);
	if (remoteAuthData != m_RemoteAuthenticationData.end())
		additionalData.pdataSize = remoteAuthData->second.pdataSize;
	else
		additionalData.pdataSize = R2::PERSISTENCE_MAX_SIZE;

	additionalData.usingLocalPdata = pPlayer->m_iPersistenceReady == R2::ePersistenceReady::READY_INSECURE;

	m_PlayerAuthenticationData.insert(std::make_pair(pPlayer, additionalData));
}

void ServerAuthenticationManager::RemovePlayer(R2::CBaseClient* pPlayer)
{
	if (m_PlayerAuthenticationData.count(pPlayer))
		m_PlayerAuthenticationData.erase(pPlayer);
}

bool ServerAuthenticationManager::VerifyPlayerName(const char* pAuthToken, const char* pName, char pOutVerifiedName[64])
{
	std::lock_guard<std::mutex> guard(m_AuthDataMutex);

	// always use name from masterserver if available
	// use of strncpy_s here should verify that this is always nullterminated within valid buffer size
	auto authData = m_RemoteAuthenticationData.find(pAuthToken);
	if (authData != m_RemoteAuthenticationData.end() && *authData->second.username)
		strncpy_s(pOutVerifiedName, 64, authData->second.username, 63);
	else
		strncpy_s(pOutVerifiedName, 64, pName, 63);

	// now, check that whatever name we have is actually valid
	// first, make sure it's >1 char
	if (!*pOutVerifiedName)
		return false;

	// next, make sure it's within a valid range of ascii characters
	for (int i = 0; pOutVerifiedName[i]; i++)
	{
		if (pOutVerifiedName[i] < 32 || pOutVerifiedName[i] > 126)
			return false;
	}

	return true;
}

bool ServerAuthenticationManager::IsDuplicateAccount(R2::CBaseClient* pPlayer, const char* pPlayerUid)
{
	if (m_bAllowDuplicateAccounts)
		return false;

	bool bHasUidPlayer = false;
	for (int i = 0; i < R2::g_pGlobals->m_nMaxClients; i++)
		if (&R2::g_pClientArray[i] != pPlayer && !strcmp(pPlayerUid, R2::g_pClientArray[i].m_UID))
			return true;

	return false;
}

bool ServerAuthenticationManager::CheckAuthentication(R2::CBaseClient* pPlayer, uint64_t iUid, const char* pAuthToken)
{
	std::string sUid = std::to_string(iUid);

	// check whether this player's authentication is valid but don't actually write anything to the player, we'll do that later
	// if we don't need auth this is valid
	if (Cvar_ns_auth_allow_insecure->GetBool())
		return true;

	// local server that doesn't need auth (probably sp) and local player
	if (m_bStartingLocalSPGame && !strcmp(sUid.c_str(), R2::g_pLocalPlayerUserID))
		return true;

	// don't allow duplicate accounts
	if (IsDuplicateAccount(pPlayer, sUid.c_str()))
		return false;

	std::lock_guard<std::mutex> guard(m_AuthDataMutex);
	auto authData = m_RemoteAuthenticationData.find(pAuthToken);
	if (authData != m_RemoteAuthenticationData.end() && !strcmp(sUid.c_str(), authData->second.uid))
		return true;

	return false;
}

void ServerAuthenticationManager::AuthenticatePlayer(R2::CBaseClient* pPlayer, uint64_t iUid, const char* pAuthToken)
{
	// for bot players, generate a new uid
	if (pPlayer->m_bFakePlayer)
		iUid = 0; // is this a good way of doing things :clueless:

	std::string sUid = std::to_string(iUid);

	// copy uuid
	strcpy(pPlayer->m_UID, sUid.c_str());

	std::lock_guard<std::mutex> guard(m_AuthDataMutex);
	auto authData = m_RemoteAuthenticationData.find(pAuthToken);
	if (authData != m_RemoteAuthenticationData.end())
	{
		// if we're resetting let script handle the reset with InitPersistentData() on connect
		if (!m_bForceResetLocalPlayerPersistence || strcmp(sUid.c_str(), R2::g_pLocalPlayerUserID))
		{
			// copy pdata into buffer
			memcpy(pPlayer->m_PersistenceBuffer, authData->second.pdata, authData->second.pdataSize);
		}

		// set persistent data as ready
		pPlayer->m_iPersistenceReady = R2::ePersistenceReady::READY_REMOTE;
	}
	// we probably allow insecure at this point, but make sure not to write anyway if not insecure
	else if (Cvar_ns_auth_allow_insecure->GetBool() || pPlayer->m_bFakePlayer)
	{
		// set persistent data as ready
		// note: actual placeholder persistent data is populated in script with InitPersistentData()
		pPlayer->m_iPersistenceReady = R2::ePersistenceReady::READY_INSECURE;
	}
}

bool ServerAuthenticationManager::RemovePlayerAuthData(R2::CBaseClient* pPlayer)
{
	if (!Cvar_ns_erase_auth_info->GetBool()) // keep auth data forever
		return false;

	// hack for special case where we're on a local server, so we erase our own newly created auth data on disconnect
	if (m_bNeedLocalAuthForNewgame && !strcmp(pPlayer->m_UID, R2::g_pLocalPlayerUserID))
		return false;

	// we don't have our auth token at this point, so lookup authdata by uid
	for (auto& auth : m_RemoteAuthenticationData)
	{
		if (!strcmp(pPlayer->m_UID, auth.second.uid))
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

void ServerAuthenticationManager::WritePersistentData(R2::CBaseClient* pPlayer)
{
	if (pPlayer->m_iPersistenceReady == R2::ePersistenceReady::READY_REMOTE)
	{
		g_pMasterServerManager->WritePlayerPersistentData(
			pPlayer->m_UID, (const char*)pPlayer->m_PersistenceBuffer, m_PlayerAuthenticationData[pPlayer].pdataSize);
	}
	else if (Cvar_ns_auth_allow_insecure_write->GetBool())
	{
		// todo: write pdata to disk here
	}
}

// auth hooks

// clang-format off
AUTOHOOK(CBaseServer__ConnectClient, engine.dll + 0x114430,
R2::CBaseClient*,, (
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
	// try to connect the client to get a client object
	R2::CBaseClient* client =
		CBaseServer__ConnectClient(self, addr, a3, a4, a5, a6, a7, playerName, serverFilter, a10, a11, a12, a13, a14, uid, a16, a17);
	if (!client)
		return nullptr;

	const char* pAuthenticationFailure = nullptr;
	char pVerifiedName[64];
	const char* authToken = serverFilter;

	if (!client->m_bFakePlayer)
	{
		if (!g_pServerAuthentication->VerifyPlayerName(authToken, playerName, pVerifiedName))
			pAuthenticationFailure = "Invalid Name.";
		else if (!g_pBanSystem->IsUIDAllowed(uid))
			pAuthenticationFailure = "Banned From server.";
		else if (!g_pServerAuthentication->CheckAuthentication(client, uid, authToken))
			pAuthenticationFailure = "Authentication Failed.";
	}
	else
	{
		spdlog::error("A bot called CBaseServer__ConnectClient, should be impossible!");

		CBaseServer__PushDisconnectReason(self, (int32_t)((uintptr_t)self + 0xc), addr, "A bot was init in CServer__ConnectClient");
		return nullptr;
	}

	if (pAuthenticationFailure)
	{
		spdlog::info("{}'s (uid {}) connection was rejected: \"{}\"", playerName, uid, pAuthenticationFailure);

		CBaseServer__PushDisconnectReason(self, (int32_t)((uintptr_t)self + 0xc), addr, pAuthenticationFailure);
		return nullptr;
	}

	// write name into the client
	strncpy_s(pVerifiedName, client->m_Name, 63);

	// we already know this player's authentication data is legit, actually write it to them now
	g_pServerAuthentication->AuthenticatePlayer(client, uid, authToken);

	g_pServerAuthentication->AddPlayer(client, authToken);
	g_pServerLimits->AddPlayer(client);
}

ConVar* Cvar_ns_allowuserclantags;

// clang-format off
AUTOHOOK(CBaseClient__Connect, engine.dll + 0x101740,
bool,, (R2::CBaseClient* self, char* pName, void* pNetChannel, char bFakePlayer, void* a5, char pDisconnectReason[256], void* a7))
// clang-format on
{
	// only remains to count bots in player count,
	// since bots take player slots and it will give if not counted a false player count on the server browser.

	if (!bFakePlayer)
		return CBaseClient__Connect(self, pName, pNetChannel, bFakePlayer, a5, pDisconnectReason, a7);

	// try to actually connect the bot
	if (!CBaseClient__Connect(self, pName, pNetChannel, bFakePlayer, a5, pDisconnectReason, a7))
		return false;

	g_pServerAuthentication->AuthenticatePlayer(self, 0, "0");

	g_pServerAuthentication->AddPlayer(self, "0");
	g_pServerLimits->AddPlayer(self);

	return true;
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

		memset(self->m_PersistenceBuffer, 0, g_pServerAuthentication->m_PlayerAuthenticationData[self].pdataSize);
		g_pServerAuthentication->RemovePlayerAuthData(self); // won't do anything 99% of the time, but just in case

		g_pServerAuthentication->RemovePlayer(self);
		g_pServerLimits->RemovePlayer(self);
	}

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

	g_pServerAuthentication->Cvar_ns_erase_auth_info =
		new ConVar("ns_erase_auth_info", "1", FCVAR_GAMEDLL, "Whether auth info should be erased from this server on disconnect or crash");
	g_pServerAuthentication->Cvar_ns_auth_allow_insecure =
		new ConVar("ns_auth_allow_insecure", "0", FCVAR_GAMEDLL, "Whether this server will allow unauthenicated players to connect");
	g_pServerAuthentication->Cvar_ns_auth_allow_insecure_write = new ConVar(
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

	CBaseServer__RejectConnection = module.Offset(0x1182E0).RCast<CBaseServer__RejectConnectionType>();
	CBaseServer__PushDisconnectReason = module.Offset(0x1155D0).RCast<CBaseServer__PushDisconnectReasonType>();

	if (Tier0::CommandLine()->CheckParm("-allowdupeaccounts"))
	{
		// patch to allow same of multiple account
		module.Offset(0x114510).Patch("EB");

		g_pServerAuthentication->m_bAllowDuplicateAccounts = true;
	}
}
