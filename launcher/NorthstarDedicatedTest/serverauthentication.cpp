#include "pch.h"
#include "serverauthentication.h"
#include "convar.h"
#include "hookutils.h"
#include <fstream>
#include <filesystem>

// hook types

typedef void*(*CBaseServer__ConnectClientType)(void* server, void* a2, void* a3, uint32_t a4, uint32_t a5, int32_t a6, void* a7, void* a8, char* serverFilter, void* a10, char a11, void* a12, char a13, char a14, void* a15, uint32_t a16, uint32_t a17);
CBaseServer__ConnectClientType CBaseServer__ConnectClient;

typedef char(*CBaseClient__ConnectType)(void* self, char* name, __int64 netchan_ptr_arg, char b_fake_player_arg, __int64 a5, char* Buffer, int a7);
CBaseClient__ConnectType CBaseClient__Connect;

typedef void(*CBaseClient__ActivatePlayerType)(void* self);
CBaseClient__ActivatePlayerType CBaseClient__ActivatePlayer;

typedef void(*CBaseClient__DisconnectType)(void* self, uint32_t unknownButAlways1, const char* reason, ...);
CBaseClient__DisconnectType CBaseClient__Disconnect;

typedef char(*CGameClient__ExecuteStringCommandType)(void* self, uint32_t unknown, const char* pCommandString);
CGameClient__ExecuteStringCommandType CGameClient__ExecuteStringCommand;

// global vars
ServerAuthenticationManager* g_ServerAuthenticationManager;

ConVar* CVar_ns_auth_allow_insecure;
ConVar* CVar_ns_auth_allow_insecure_write;
ConVar* CVar_sv_quota_stringcmdspersecond;

void ServerAuthenticationManager::AddPlayerAuth(char* authToken, char* uid, char* pdata, size_t pdataSize)
{
	
}

bool ServerAuthenticationManager::AuthenticatePlayer(void* player, char* authToken)
{
	// straight up just given up
	if (!m_authData.empty() && m_authData.count(authToken))
	{
		// use stored auth data
		AuthData* authData = m_authData[authToken];
		
		// uuid
		strcpy((char*)player + 0xF500, authData->uid);

		// copy pdata into buffer
		memcpy((char*)player + 0x4FA, authData->pdata, authData->pdataSize);

		// set persistent data as ready, we use 0x4 internally to mark the client as using remote persistence
		*((char*)player + 0x4a0) = (char)0x4;
	}
	else
	{
		if (!CVar_ns_auth_allow_insecure->m_nValue) // no auth data and insecure connections aren't allowed, so dc the client
			return false;

		// insecure connections are allowed, try reading from disk, using authtoken as uid
		
		// uuid
		strcpy((char*)player + 0xF500, authToken);

		// try reading pdata file for player
		std::string pdataPath = "playerdata/playerdata_";
		pdataPath += authToken;
		pdataPath += ".pdata";

		std::fstream pdataStream(pdataPath, std::ios_base::in);
		if (pdataStream.fail()) // file doesn't exist, use placeholder
			pdataStream = std::fstream("playerdata/placeholder_playerdata.pdata");
		
		// get file length
		pdataStream.seekg(0, pdataStream.end);
		int length = pdataStream.tellg();
		pdataStream.seekg(0, pdataStream.beg);

		// copy pdata into buffer
		pdataStream.read((char*)player + 0x4FA, length);

		pdataStream.close();

		// set persistent data as ready, we use 0x3 internally to mark the client as using local persistence
		*((char*)player + 0x4a0) = (char)0x3;
	}

	return true; // auth successful, client stays on
}

bool ServerAuthenticationManager::RemovePlayerAuthData(void* player)
{
	// we don't have our auth token at this point, so lookup authdata by uid
	for (auto& auth : m_authData)
	{
		if (!strcmp((char*)player + 0xF500, auth.second->uid))
		{
			// pretty sure this is fine, since we don't iterate after the erase
			// i think if we iterated after it'd be undefined behaviour tho
			m_authData.erase(auth.first);
			return true;
		}
	}

	return false;
}

void ServerAuthenticationManager::WritePersistentData(void* player)
{
	// we use 0x4 internally to mark clients as using remote persistence
	if (*((char*)player + 0x4A0) == (char)0x4)
	{

	}
	else if (CVar_ns_auth_allow_insecure_write->m_nValue)
	{
		// todo: write pdata to disk here
	}
}


// auth hooks

// store this in a var so we can use it in CBaseClient::Connect
// this is fine because serverfilter ptr won't decay by the time we use this, just don't use it outside of cbaseclient::connect
char* nextPlayerToken;

void* CBaseServer__ConnectClientHook(void* server, void* a2, void* a3, uint32_t a4, uint32_t a5, int32_t a6, void* a7, void* a8, char* serverFilter, void* a10, char a11, void* a12, char a13, char a14, void* a15, uint32_t a16, uint32_t a17)
{
	// auth tokens are sent with serverfilter, can't be accessed from player struct to my knowledge, so have to do this here
	nextPlayerToken = serverFilter;

	return CBaseServer__ConnectClient(server, a2, a3, a4, a5, a6, a7, a8, serverFilter, a10, a11, a12, a13, a14, a15, a16, a17);
}

char CBaseClient__ConnectHook(void* self, char* name, __int64 netchan_ptr_arg, char b_fake_player_arg, __int64 a5, char* Buffer, int a7)
{
	// try to auth player, dc if it fails
	// we connect irregardless of auth, because returning bad from this function can fuck client state p bad
	char ret = CBaseClient__Connect(self, name, netchan_ptr_arg, b_fake_player_arg, a5, Buffer, a7);
	if (strlen(name) >= 64) // fix for name overflow bug
		CBaseClient__Disconnect(self, 1, "Invalid name");
	else if (!g_ServerAuthenticationManager->AuthenticatePlayer(self, nextPlayerToken))
		CBaseClient__Disconnect(self, 1, "Authentication Failed");

	return ret;
}

void CBaseClient__ActivatePlayerHook(void* self)
{
	// if we're authed, write our persistent data
	// RemovePlayerAuthData returns true if it removed successfully, i.e. on first call only, and we only want to write on >= second call (since this func is called on map loads)
	if (*((char*)self + 0x4A0) >= (char)0x3 && !g_ServerAuthenticationManager->RemovePlayerAuthData(self))
		g_ServerAuthenticationManager->WritePersistentData(self);

	CBaseClient__ActivatePlayer(self);
}

void CBaseClient__DisconnectHook(void* self, uint32_t unknownButAlways1, const char* reason, ...)
{
	// have to manually format message because can't pass varargs to original func
	char buf[1024];

	va_list va;
	va_start(va, reason);
	vsprintf(buf, reason, va);
	va_end(va);

	// dcing, write persistent data
	g_ServerAuthenticationManager->WritePersistentData(self);

	CBaseClient__Disconnect(self, unknownButAlways1, buf);
}

// maybe this should be done outside of auth code, but effort to refactor rn and it sorta fits
char CGameClient__ExecuteStringCommandHook(void* self, uint32_t unknown, const char* pCommandString)
{
	// todo later, basically just limit to CVar_sv_quota_stringcmdspersecond->m_nValue stringcmds per client per second
	return CGameClient__ExecuteStringCommand(self, unknown, pCommandString);
}

void InitialiseServerAuthentication(HMODULE baseAddress)
{
	g_ServerAuthenticationManager = new ServerAuthenticationManager;

	CVar_ns_auth_allow_insecure = RegisterConVar("ns_auth_allow_insecure", "0", FCVAR_GAMEDLL, "Whether this server will allow unauthenicated players to connect");
	CVar_ns_auth_allow_insecure_write = RegisterConVar("ns_auth_allow_insecure_write", "0", FCVAR_GAMEDLL, "Whether the pdata of unauthenticated clients will be written to disk when changed");
	// literally just stolen from a fix valve used in csgo
	CVar_sv_quota_stringcmdspersecond = RegisterConVar("sv_quota_stringcmdspersecond", "40", FCVAR_NONE, "How many string commands per second clients are allowed to submit, 0 to disallow all string commands");

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x114430, &CBaseServer__ConnectClientHook, reinterpret_cast<LPVOID*>(&CBaseServer__ConnectClient));
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x101740, &CBaseClient__ConnectHook, reinterpret_cast<LPVOID*>(&CBaseClient__Connect));
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x100F80, &CBaseClient__ActivatePlayerHook, reinterpret_cast<LPVOID*>(&CBaseClient__ActivatePlayer));
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x1012C0, &CBaseClient__DisconnectHook, reinterpret_cast<LPVOID*>(&CBaseClient__Disconnect));
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x1022E0, &CGameClient__ExecuteStringCommandHook, reinterpret_cast<LPVOID*>(&CGameClient__ExecuteStringCommand));

	// patch to disable kicking based on incorrect serverfilter in connectclient, since we repurpose it for use as an auth token
	{
		void* ptr = (char*)baseAddress + 0x114655;
		TempReadWrite rw(ptr);
		*((char*)ptr) = (char)0xEB; // jz => jmp
	}

	// patch to disable fairfight marking players as cheaters and kicking them
	{
		void* ptr = (char*)baseAddress + 0x101012;
		TempReadWrite rw(ptr);
		*((char*)ptr) = (char)0xE9; // jz => jmp
		*((char*)ptr + 1) = (char)0x90;
		*((char*)ptr + 2) = (char)0x0;

		*((char*)ptr + 5) = (char)0x90; // nop extra byte we no longer use
	}
}