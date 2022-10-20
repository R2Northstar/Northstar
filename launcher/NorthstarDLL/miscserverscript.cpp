#include "pch.h"
#include "squirrel.h"
#include "masterserver.h"
#include "serverauthentication.h"
#include "dedicated.h"
#include "r2client.h"
#include "r2server.h"

#include <filesystem>

// void function NSEarlyWritePlayerPersistenceForLeave( entity player )
SQRESULT SQ_EarlyWritePlayerPersistenceForLeave(HSquirrelVM* sqvm)
{
	const R2::CBasePlayer* pPlayer = g_pSquirrel<ScriptContext::SERVER>->getentity<R2::CBasePlayer>(sqvm, 1);
	if (!pPlayer)
	{
		spdlog::warn("NSEarlyWritePlayerPersistenceForLeave got null player");

		g_pSquirrel<ScriptContext::SERVER>->pushbool(sqvm, false);
		return SQRESULT_NOTNULL;
	}

	R2::CBaseClient* pClient = &R2::g_pClientArray[pPlayer->m_nPlayerIndex - 1];
	if (g_pServerAuthentication->m_PlayerAuthenticationData.find(pClient) == g_pServerAuthentication->m_PlayerAuthenticationData.end())
	{
		g_pSquirrel<ScriptContext::SERVER>->pushbool(sqvm, false);
		return SQRESULT_NOTNULL;
	}

	g_pServerAuthentication->m_PlayerAuthenticationData[pClient].needPersistenceWriteOnLeave = false;
	g_pServerAuthentication->WritePersistentData(pClient);
	return SQRESULT_NULL;
}

// bool function NSIsWritingPlayerPersistence()
SQRESULT SQ_IsWritingPlayerPersistence(HSquirrelVM* sqvm)
{
	g_pSquirrel<ScriptContext::SERVER>->pushbool(sqvm, g_pMasterServerManager->m_bSavingPersistentData);
	return SQRESULT_NOTNULL;
}

// bool function NSIsPlayerLocalPlayer( entity player )
SQRESULT SQ_IsPlayerLocalPlayer(HSquirrelVM* sqvm)
{
	const R2::CBasePlayer* pPlayer = g_pSquirrel<ScriptContext::SERVER>->getentity<R2::CBasePlayer>(sqvm, 1);
	if (!pPlayer)
	{
		spdlog::warn("NSIsPlayerLocalPlayer got null player");

		g_pSquirrel<ScriptContext::SERVER>->pushbool(sqvm, false);
		return SQRESULT_NOTNULL;
	}

	R2::CBaseClient* pClient = &R2::g_pClientArray[pPlayer->m_nPlayerIndex - 1];
	g_pSquirrel<ScriptContext::SERVER>->pushbool(sqvm, !strcmp(R2::g_pLocalPlayerUserID, pClient->m_UID));
	return SQRESULT_NOTNULL;
}

// bool function NSIsDedicated()
SQRESULT SQ_IsDedicated(HSquirrelVM* sqvm)
{
	g_pSquirrel<ScriptContext::SERVER>->pushbool(sqvm, IsDedicatedServer());
	return SQRESULT_NOTNULL;
}

ON_DLL_LOAD_RELIESON("server.dll", MiscServerScriptCommands, ServerSquirrel, (CModule module))
{
	g_pSquirrel<ScriptContext::SERVER>->AddFuncRegistration(
		"void", "NSEarlyWritePlayerPersistenceForLeave", "entity player", "", SQ_EarlyWritePlayerPersistenceForLeave);
	g_pSquirrel<ScriptContext::SERVER>->AddFuncRegistration("bool", "NSIsWritingPlayerPersistence", "", "", SQ_IsWritingPlayerPersistence);
	g_pSquirrel<ScriptContext::SERVER>->AddFuncRegistration("bool", "NSIsPlayerLocalPlayer", "entity player", "", SQ_IsPlayerLocalPlayer);
	g_pSquirrel<ScriptContext::SERVER>->AddFuncRegistration("bool", "NSIsDedicated", "", "", SQ_IsDedicated);
}
