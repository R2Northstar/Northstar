#include "pch.h"
#include "miscserverscript.h"
#include "squirrel.h"
#include "masterserver.h"
#include "serverauthentication.h"
#include "gameutils.h"

// annoying helper function because i can't figure out getting players or entities from sqvm rn
// wish i didn't have to do it like this, but here we are
void* GetPlayerByIndex(int playerIndex)
{
	const int PLAYER_ARRAY_OFFSET = 0x12A53F90;
	const int PLAYER_SIZE = 0x2D728;

	void* playerArrayBase = (char*)GetModuleHandleA("engine.dll") + PLAYER_ARRAY_OFFSET;
	void* player = (char*)playerArrayBase + (playerIndex * PLAYER_SIZE);

	return player;
}

// void function NSEarlyWritePlayerIndexPersistenceForLeave( int playerIndex )
SQRESULT SQ_EarlyWritePlayerIndexPersistenceForLeave(void* sqvm)
{
	int playerIndex = ServerSq_getinteger(sqvm, 1);
	void* player = GetPlayerByIndex(playerIndex);

	if (!g_ServerAuthenticationManager->m_additionalPlayerData.count(player))
	{
		ServerSq_pusherror(sqvm, fmt::format("Invalid playerindex {}", playerIndex).c_str());
		return SQRESULT_ERROR;
	}

	g_ServerAuthenticationManager->m_additionalPlayerData[player].needPersistenceWriteOnLeave = false;
	g_ServerAuthenticationManager->WritePersistentData(player);
	return SQRESULT_NULL;
}

// bool function NSIsWritingPlayerPersistence()
SQRESULT SQ_IsWritingPlayerPersistence(void* sqvm)
{
	ServerSq_pushbool(sqvm, g_MasterServerManager->m_savingPersistentData);
	return SQRESULT_NOTNULL;
}

// bool function NSIsPlayerIndexLocalPlayer( int playerIndex )
SQRESULT SQ_IsPlayerIndexLocalPlayer(void* sqvm)
{
	int playerIndex = ServerSq_getinteger(sqvm, 1);
	void* player = GetPlayerByIndex(playerIndex);
	if (!g_ServerAuthenticationManager->m_additionalPlayerData.count(player))
	{
		ServerSq_pusherror(sqvm, fmt::format("Invalid playerindex {}", playerIndex).c_str());
		return SQRESULT_ERROR;
	}

	ServerSq_pushbool(sqvm, !strcmp(g_LocalPlayerUserID, (char*)player + 0xF500));
	return SQRESULT_NOTNULL;
}

void InitialiseMiscServerScriptCommand(HMODULE baseAddress)
{
	g_ServerSquirrelManager->AddFuncRegistration(
		"void", "NSEarlyWritePlayerIndexPersistenceForLeave", "int playerIndex", "", SQ_EarlyWritePlayerIndexPersistenceForLeave);
	g_ServerSquirrelManager->AddFuncRegistration("bool", "NSIsWritingPlayerPersistence", "", "", SQ_IsWritingPlayerPersistence);
	g_ServerSquirrelManager->AddFuncRegistration("bool", "NSIsPlayerIndexLocalPlayer", "int playerIndex", "", SQ_IsPlayerIndexLocalPlayer);
}