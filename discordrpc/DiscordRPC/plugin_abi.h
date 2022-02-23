#pragma once
#include <string>

#define ABI_VERSION 1

/// <summary>
/// This enum is used for referencing the different types of objects we can pass to a plugin
/// Anything exposed to a plugin must not a be C++ type, as they could break when compiling with a different compiler.
/// Any ABI incompatible change must increment the version number.
/// Nothing must be removed from this enum, only appended. When it absolutely necessary to deprecate an object, it should return UNSUPPORTED when retrieved
/// </summary>
enum PluginObject
{
	UNSUPPORTED = 0,
	GAMESTATE = 1,
	SERVERINFO = 2,
	PLAYERINFO = 3,
	DUMMY = 0xFFFF
};

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


enum GameStateInfoType
{
	ourScore,
	secondHighestScore,
	highestScore,
	connected,
	loading,
	map,
	mapDisplayName,
	playlist,
	playlistDisplayName,
	players
};
struct GameState
{
	int (*getGameStateChar)(char* out_buf, size_t out_buf_len, GameStateInfoType var);
	int (*getGameStateInt)(int* out_ptr, GameStateInfoType var);
	int (*getGameStateBool)(bool* out_ptr, GameStateInfoType var);
};

enum ServerInfoType
{
	id, name, description, password, maxPlayers, roundBased, scoreLimit, endTime
};
struct ServerInfo
{
	int (*getServerInfoChar)(char* out_buf, size_t out_buf_len, ServerInfoType var);
	int (*getServerInfoInt)(int* out_ptr, ServerInfoType var);
	int (*getServerInfoBool)(bool* out_ptr, ServerInfoType var);
};

enum PlayerInfoType
{
	uid
};
struct PlayerInfo
{
	int (*getPlayerInfoChar)(char* out_buf, size_t out_buf_len, PlayerInfoType var);
	int (*getPlayerInfoInt)(int* out_ptr, PlayerInfoType var);
	int (*getPlayerInfoBool)(bool* out_ptr, PlayerInfoType var);
};
