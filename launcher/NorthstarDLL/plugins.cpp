#include "pch.h"
#include "squirrel.h"
#include "plugins.h"
#include "masterserver.h"
#include "convar.h"
#include "serverpresence.h"

#include <chrono>
#include <windows.h>

/// <summary>
/// The data is split into two different representations: one for internal, and one for plugins, for thread safety reasons
/// The struct exposed to plugins contains getter functions for the various data types.
/// We can safely use C++ types like std::string here since these are only ever handled by Northstar internally
/// </summary>
struct InternalGameState
{
	int ourScore;
	int secondHighestScore;
	int highestScore;

	bool connected;
	bool loading;
	std::string map;
	std::string mapDisplayName;
	std::string playlist;
	std::string playlistDisplayName;
	int players;
};
struct InternalServerInfo
{
	std::string id;
	std::string name;
	std::string description;
	std::string password;
	int maxPlayers;
	bool roundBased;
	int scoreLimit;
	int endTime;
};
// TODO: need to extend this to include current player data like loadouts
struct InternalPlayerInfo
{
	int uid;
};

InternalGameState gameState;
InternalServerInfo serverInfo;
InternalPlayerInfo playerInfo;

GameState gameStateExport;
ServerInfo serverInfoExport;
PlayerInfo playerInfoExport;

/// <summary>
/// We use SRW Locks because plugins will often be running their own thread
/// To ensure thread safety, and to make it difficult to fuck up, we force them to use *our* functions to get data
/// </summary>
static SRWLOCK gameStateLock;
static SRWLOCK serverInfoLock;
static SRWLOCK playerInfoLock;

void* getPluginObject(PluginObject var)
{
	switch (var)
	{
	case PluginObject::GAMESTATE:
		return &gameStateExport;
	case PluginObject::SERVERINFO:
		return &serverInfoExport;
	case PluginObject::PLAYERINFO:
		return &playerInfoExport;
	default:
		return (void*)-1;
	}
}

void initGameState()
{
	// Initalize the Slim Reader / Writer locks
	InitializeSRWLock(&gameStateLock);
	InitializeSRWLock(&serverInfoLock);
	InitializeSRWLock(&playerInfoLock);

	gameStateExport.getGameStateChar = &getGameStateChar;
	gameStateExport.getGameStateInt = &getGameStateInt;
	gameStateExport.getGameStateBool = &getGameStateBool;

	serverInfoExport.getServerInfoChar = &getServerInfoChar;
	serverInfoExport.getServerInfoInt = &getServerInfoInt;
	serverInfoExport.getServerInfoBool = &getServerInfoBool;

	playerInfoExport.getPlayerInfoChar = &getPlayerInfoChar;
	playerInfoExport.getPlayerInfoInt = &getPlayerInfoInt;
	playerInfoExport.getPlayerInfoBool = &getPlayerInfoBool;

	serverInfo.id = "";
	serverInfo.name = "";
	serverInfo.description = "";
	serverInfo.password = "";
	serverInfo.maxPlayers = 0;
	gameState.connected = false;
	gameState.loading = false;
	gameState.map = "";
	gameState.mapDisplayName = "";
	gameState.playlist = "";
	gameState.playlistDisplayName = "";
	gameState.players = 0;

	playerInfo.uid = 123;
}

// string gamemode, string gamemodeName, string map, string mapName, bool connected, bool loading
SQRESULT SQ_UpdateGameStateUI(HSquirrelVM* sqvm)
{
	AcquireSRWLockExclusive(&gameStateLock);
	gameState.map = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 1);
	gameState.mapDisplayName = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 2);
	gameState.playlist = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 3);
	gameState.playlistDisplayName = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 4);
	gameState.connected = g_pSquirrel<ScriptContext::UI>->getbool(sqvm, 5);
	gameState.loading = g_pSquirrel<ScriptContext::UI>->getbool(sqvm, 6);
	ReleaseSRWLockExclusive(&gameStateLock);
	return SQRESULT_NOTNULL;
}

// int playerCount, int outScore, int secondHighestScore, int highestScore, bool roundBased, int scoreLimit
SQRESULT SQ_UpdateGameStateClient(HSquirrelVM* sqvm)
{
	AcquireSRWLockExclusive(&gameStateLock);
	AcquireSRWLockExclusive(&serverInfoLock);
	gameState.players = g_pSquirrel<ScriptContext::CLIENT>->getinteger(sqvm, 1);
	serverInfo.maxPlayers = g_pSquirrel<ScriptContext::CLIENT>->getinteger(sqvm, 2);
	gameState.ourScore = g_pSquirrel<ScriptContext::CLIENT>->getinteger(sqvm, 3);
	gameState.secondHighestScore = g_pSquirrel<ScriptContext::CLIENT>->getinteger(sqvm, 4);
	gameState.highestScore = g_pSquirrel<ScriptContext::CLIENT>->getinteger(sqvm, 5);
	serverInfo.roundBased = g_pSquirrel<ScriptContext::CLIENT>->getbool(sqvm, 6);
	serverInfo.scoreLimit = g_pSquirrel<ScriptContext::CLIENT>->getbool(sqvm, 7);
	ReleaseSRWLockExclusive(&gameStateLock);
	ReleaseSRWLockExclusive(&serverInfoLock);
	return SQRESULT_NOTNULL;
}

// string id, string name, string password, int players, int maxPlayers, string map, string mapDisplayName, string playlist, string
// playlistDisplayName
SQRESULT SQ_UpdateServerInfo(HSquirrelVM* sqvm)
{
	AcquireSRWLockExclusive(&gameStateLock);
	AcquireSRWLockExclusive(&serverInfoLock);
	serverInfo.id = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 1);
	serverInfo.name = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 2);
	serverInfo.password = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 3);
	gameState.players = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 4);
	serverInfo.maxPlayers = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 5);
	gameState.map = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 6);
	gameState.mapDisplayName = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 7);
	gameState.playlist = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 8);
	gameState.playlistDisplayName = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 9);
	ReleaseSRWLockExclusive(&gameStateLock);
	ReleaseSRWLockExclusive(&serverInfoLock);
	return SQRESULT_NOTNULL;
}

// int maxPlayers
SQRESULT SQ_UpdateServerInfoBetweenRounds(HSquirrelVM* sqvm)
{
	AcquireSRWLockExclusive(&serverInfoLock);
	serverInfo.id = g_pSquirrel<ScriptContext::CLIENT>->getstring(sqvm, 1);
	serverInfo.name = g_pSquirrel<ScriptContext::CLIENT>->getstring(sqvm, 2);
	serverInfo.password = g_pSquirrel<ScriptContext::CLIENT>->getstring(sqvm, 3);
	serverInfo.maxPlayers = g_pSquirrel<ScriptContext::CLIENT>->getinteger(sqvm, 4);
	ReleaseSRWLockExclusive(&serverInfoLock);
	return SQRESULT_NOTNULL;
}

// float timeInFuture
SQRESULT SQ_UpdateTimeInfo(HSquirrelVM* sqvm)
{
	AcquireSRWLockExclusive(&serverInfoLock);
	serverInfo.endTime = ceil(g_pSquirrel<ScriptContext::CLIENT>->getfloat(sqvm, 1));
	ReleaseSRWLockExclusive(&serverInfoLock);
	return SQRESULT_NOTNULL;
}

// bool loading
SQRESULT SQ_SetConnected(HSquirrelVM* sqvm)
{
	AcquireSRWLockExclusive(&gameStateLock);
	gameState.loading = g_pSquirrel<ScriptContext::UI>->getbool(sqvm, 1);
	ReleaseSRWLockExclusive(&gameStateLock);
	return SQRESULT_NOTNULL;
}

SQRESULT SQ_UpdateListenServer(HSquirrelVM* sqvm)
{
	AcquireSRWLockExclusive(&serverInfoLock);
	serverInfo.id = g_pMasterServerManager->m_sOwnServerId;
	serverInfo.password = ""; // g_pServerPresence->Cvar_ns_server_password->GetString(); todo this fr
	ReleaseSRWLockExclusive(&serverInfoLock);
	return SQRESULT_NOTNULL;
}

int getServerInfoChar(char* out_buf, size_t out_buf_len, ServerInfoType var)
{
	AcquireSRWLockShared(&serverInfoLock);
	int n = 0;
	switch (var)
	{
	case ServerInfoType::id:
		strncpy(out_buf, serverInfo.id.c_str(), out_buf_len);
		break;
	case ServerInfoType::name:
		strncpy(out_buf, serverInfo.name.c_str(), out_buf_len);
		break;
	case ServerInfoType::description:
		strncpy(out_buf, serverInfo.id.c_str(), out_buf_len);
		break;
	case ServerInfoType::password:
		strncpy(out_buf, serverInfo.password.c_str(), out_buf_len);
		break;
	default:
		n = -1;
	}

	ReleaseSRWLockShared(&serverInfoLock);

	return n;
}
int getServerInfoInt(int* out_ptr, ServerInfoType var)
{
	AcquireSRWLockShared(&serverInfoLock);
	int n = 0;
	switch (var)
	{
	case ServerInfoType::maxPlayers:
		*out_ptr = serverInfo.maxPlayers;
		break;
	case ServerInfoType::scoreLimit:
		*out_ptr = serverInfo.scoreLimit;
		break;
	case ServerInfoType::endTime:
		*out_ptr = serverInfo.endTime;
		break;
	default:
		n = -1;
	}

	ReleaseSRWLockShared(&serverInfoLock);

	return n;
}
int getServerInfoBool(bool* out_ptr, ServerInfoType var)
{
	AcquireSRWLockShared(&serverInfoLock);
	int n = 0;
	switch (var)
	{
	case ServerInfoType::roundBased:
		*out_ptr = serverInfo.roundBased;
		break;
	default:
		n = -1;
	}

	ReleaseSRWLockShared(&serverInfoLock);

	return n;
}

int getGameStateChar(char* out_buf, size_t out_buf_len, GameStateInfoType var)
{
	AcquireSRWLockShared(&gameStateLock);
	int n = 0;
	switch (var)
	{
	case GameStateInfoType::map:
		strncpy(out_buf, gameState.map.c_str(), out_buf_len);
		break;
	case GameStateInfoType::mapDisplayName:
		strncpy(out_buf, gameState.mapDisplayName.c_str(), out_buf_len);
		break;
	case GameStateInfoType::playlist:
		strncpy(out_buf, gameState.playlist.c_str(), out_buf_len);
		break;
	case GameStateInfoType::playlistDisplayName:
		strncpy(out_buf, gameState.playlistDisplayName.c_str(), out_buf_len);
		break;
	default:
		n = -1;
	}

	ReleaseSRWLockShared(&gameStateLock);

	return n;
}
int getGameStateInt(int* out_ptr, GameStateInfoType var)
{
	AcquireSRWLockShared(&gameStateLock);
	int n = 0;
	switch (var)
	{
	case GameStateInfoType::ourScore:
		*out_ptr = gameState.ourScore;
		break;
	case GameStateInfoType::secondHighestScore:
		*out_ptr = gameState.secondHighestScore;
		break;
	case GameStateInfoType::highestScore:
		*out_ptr = gameState.highestScore;
		break;
	case GameStateInfoType::players:
		*out_ptr = gameState.players;
		break;
	default:
		n = -1;
	}

	ReleaseSRWLockShared(&gameStateLock);

	return n;
}
int getGameStateBool(bool* out_ptr, GameStateInfoType var)
{
	AcquireSRWLockShared(&gameStateLock);
	int n = 0;
	switch (var)
	{
	case GameStateInfoType::connected:
		*out_ptr = gameState.connected;
		break;
	case GameStateInfoType::loading:
		*out_ptr = gameState.loading;
		break;
	default:
		n = -1;
	}

	ReleaseSRWLockShared(&gameStateLock);

	return n;
}

int getPlayerInfoChar(char* out_buf, size_t out_buf_len, PlayerInfoType var)
{
	AcquireSRWLockShared(&playerInfoLock);
	int n = 0;
	switch (var)
	{
	default:
		n = -1;
	}

	ReleaseSRWLockShared(&playerInfoLock);

	return n;
}
int getPlayerInfoInt(int* out_ptr, PlayerInfoType var)
{
	AcquireSRWLockShared(&playerInfoLock);
	int n = 0;
	switch (var)
	{
	case PlayerInfoType::uid:
		*out_ptr = playerInfo.uid;
		break;
	default:
		n = -1;
	}

	ReleaseSRWLockShared(&playerInfoLock);

	return n;
}
int getPlayerInfoBool(bool* out_ptr, PlayerInfoType var)
{
	AcquireSRWLockShared(&playerInfoLock);
	int n = 0;
	switch (var)
	{
	default:
		n = -1;
	}

	ReleaseSRWLockShared(&playerInfoLock);

	return n;
}

ON_DLL_LOAD_CLIENT_RELIESON("client.dll", PluginCommands, ClientSquirrel, (CModule module))
{
	// i swear there's a way to make this not have be run in 2 contexts but i can't figure it out
	// some funcs i need are just not available in UI or CLIENT

	if (g_pSquirrel<ScriptContext::UI> && g_pSquirrel<ScriptContext::CLIENT>)
	{
		g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
			"void",
			"NSUpdateGameStateUI",
			"string gamemode, string gamemodeName, string map, string mapName, bool connected, bool loading",
			"",
			SQ_UpdateGameStateUI);
		g_pSquirrel<ScriptContext::CLIENT>->AddFuncRegistration(
			"void",
			"NSUpdateGameStateClient",
			"int playerCount, int maxPlayers, int outScore, int secondHighestScore, int highestScore, bool roundBased, int scoreLimit",
			"",
			SQ_UpdateGameStateClient);
		g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
			"void",
			"NSUpdateServerInfo",
			"string id, string name, string password, int players, int maxPlayers, string map, string mapDisplayName, string playlist, "
			"string "
			"playlistDisplayName",
			"",
			SQ_UpdateServerInfo);
		g_pSquirrel<ScriptContext::CLIENT>->AddFuncRegistration(
			"void", "NSUpdateServerInfoReload", "int maxPlayers", "", SQ_UpdateServerInfoBetweenRounds);
		g_pSquirrel<ScriptContext::CLIENT>->AddFuncRegistration("void", "NSUpdateTimeInfo", "float timeInFuture", "", SQ_UpdateTimeInfo);
		g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("void", "NSSetLoading", "bool loading", "", SQ_SetConnected);
		g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("void", "NSUpdateListenServer", "", "", SQ_UpdateListenServer);
	}
}
