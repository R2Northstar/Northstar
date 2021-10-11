#include "pch.h"
#include "serverscriptpersistence.h"
#include "squirrel.h"
#include "masterserver.h"
#include "serverauthentication.h"

// void function NSEarlyWritePlayerPersistenceForLeave( entity player )
SQInteger SQ_EarlyWritePlayerPersistenceForLeave(void* sqvm)
{
	void* player;
	if (!ServerSq_getentity(sqvm, &player) || !g_ServerAuthenticationManager->m_additionalPlayerData.count(player))
		return 0;

	g_ServerAuthenticationManager->m_additionalPlayerData[player].needPersistenceWriteOnLeave = false;
	g_ServerAuthenticationManager->WritePersistentData(player);
	return 0;
}

// bool function NSIsWritingPlayerPersistence()
SQInteger SQ_IsWritingPlayerPersistence(void* sqvm)
{
	ServerSq_pushbool(sqvm, g_MasterServerManager->m_savingPersistentData);
	return 1;
}

void InitialiseServerScriptPersistence(HMODULE baseAddress)
{
	g_ServerSquirrelManager->AddFuncRegistration("void", "NSEarlyWritePlayerPersistenceForLeave", "entity player", "", SQ_EarlyWritePlayerPersistenceForLeave);
	g_ServerSquirrelManager->AddFuncRegistration("bool", "NSIsWritingPlayerPersistence", "", "", SQ_IsWritingPlayerPersistence);
}