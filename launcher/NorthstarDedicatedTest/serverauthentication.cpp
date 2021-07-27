#include "pch.h"
#include "serverauthentication.h"
#include "convar.h"
#include "hookutils.h"
#include <fstream>
#include <filesystem>

// hooks
typedef void(*RejectClientType)(void* a1, const char* a2, void* player, const char* fmt, ...);
RejectClientType RejectClient;

typedef void*(*CBaseServer__ConnectClientType)(void* server, void* a2, void* a3, uint32_t a4, uint32_t a5, int32_t a6, void* a7, void* a8, char* serverFilter, void* a10, char a11, void* a12, char a13, char a14, void* a15, uint32_t a16, uint32_t a17);
CBaseServer__ConnectClientType CBaseServer__ConnectClient;

typedef char(*CBaseClient__ConnectType)(void* self, char* name, __int64 netchan_ptr_arg, char b_fake_player_arg, __int64 a5, char* Buffer, int a7);
CBaseClient__ConnectType CBaseClient__Connect;

// global vars
ServerAuthenticationManager* g_ServerAuthenticationManager;

ConVar* CVar_ns_auth_allow_insecure;
ConVar* CVar_ns_auth_allow_insecure_write;

ServerAuthenticationManager::ServerAuthenticationManager() : m_authData(std::unordered_map<std::string, AuthData*>())
{}

void ServerAuthenticationManager::AddPlayerAuth(char* authToken, char* uid, char* pdata, size_t pdataSize)
{
	
}

bool ServerAuthenticationManager::AuthenticatePlayer(__int64 player, char* authToken)
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
	}
	else
	{
		if (!CVar_ns_auth_allow_insecure->m_nValue) // no auth data and insecure connections aren't allowed, so dc the client
			return false;

		spdlog::info("wtf");
		spdlog::info(player);

		// no auth data available and insecure connections are allowed, try reading from disk, using authtoken as uid
		
		// uuid
		strcpy((char*)(player + 0xF500), authToken);

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
		

		pdataStream.read((char*)(player + 0x4FA), length);
	}

	// set persistent data as ready
	*(char*)(player + 0x4a0) = (char)0x3;

	return true; // auth successful, client stays on
}

// store this in a var so we can use it in CBaseClient::Connect
// this is fine because serverfilter ptr won't decay by the time we use this
char* nextPlayerToken;

void* CBaseServer__ConnectClientHook(void* server, void* a2, void* a3, uint32_t a4, uint32_t a5, int32_t a6, void* a7, void* a8, char* serverFilter, void* a10, char a11, void* a12, char a13, char a14, void* a15, uint32_t a16, uint32_t a17)
{
	// auth tokens are sent with serverfilter, can't be accessed from player struct to my knowledge, so have to do this here
	nextPlayerToken = serverFilter;

	return CBaseServer__ConnectClient(server, a2, a3, a4, a5, a6, a7, a8, serverFilter, a10, a11, a12, a13, a14, a15, a16, a17);
}

char CBaseClient__ConnectHook(void* self, char* name, __int64 netchan_ptr_arg, char b_fake_player_arg, __int64 a5, char* Buffer, int a7)
{
	if (!g_ServerAuthenticationManager->AuthenticatePlayer((__int64)self, nextPlayerToken))
	{
		//RejectClient(nullptr, "Authentication failed", self, "Authentication failed");
		//return 0;
	}

	return CBaseClient__Connect(self, name, netchan_ptr_arg, b_fake_player_arg, a5, Buffer, a7);
}

void InitialiseServerAuthentication(HMODULE baseAddress)
{
	g_ServerAuthenticationManager = new ServerAuthenticationManager;

	RejectClient = (RejectClientType)((char*)baseAddress + 0x1182E0);

	CVar_ns_auth_allow_insecure = RegisterConVar("ns_auth_allow_insecure", "0", FCVAR_GAMEDLL, "Whether this server will allow unauthenicated players to connect");
	CVar_ns_auth_allow_insecure_write = RegisterConVar("ns_auth_allow_insecure_write", "0", FCVAR_GAMEDLL, "Whether the pdata of unauthenticated clients will be written to disk when changed");

	spdlog::info((void*)CVar_ns_auth_allow_insecure);
	spdlog::info((void*)&CVar_ns_auth_allow_insecure->m_nValue);

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x114430, &CBaseServer__ConnectClientHook, reinterpret_cast<LPVOID*>(&CBaseServer__ConnectClient));
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x101740, &CBaseClient__ConnectHook, reinterpret_cast<LPVOID*>(&CBaseClient__Connect));

	// patch to disable kicking based on incorrect serverfilter in connectclient, since we repurpose it for use as an auth token
	{
		void* ptr = (char*)baseAddress + 0x114655;
		TempReadWrite rw(ptr);
		*((char*)ptr) = (char)0xEB; // jz => jmp
	}
}