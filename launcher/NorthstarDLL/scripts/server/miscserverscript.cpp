#include "pch.h"
#include "squirrel/squirrel.h"
#include "masterserver/masterserver.h"
#include "server/auth/serverauthentication.h"
#include "dedicated/dedicated.h"
#include "client/r2client.h"
#include "server/r2server.h"

#include <filesystem>

ADD_SQFUNC("void", NSEarlyWritePlayerPersistenceForLeave, "entity player", "", ScriptContext::SERVER)
{
	const R2::CBasePlayer* pPlayer = g_pSquirrel<context>->getentity<R2::CBasePlayer>(sqvm, 1);
	if (!pPlayer)
	{
		spdlog::warn("NSEarlyWritePlayerPersistenceForLeave got null player");

		g_pSquirrel<context>->pushbool(sqvm, false);
		return SQRESULT_NOTNULL;
	}

	R2::CBaseClient* pClient = &R2::g_pClientArray[pPlayer->m_nPlayerIndex - 1];
	if (g_pServerAuthentication->m_PlayerAuthenticationData.find(pClient) == g_pServerAuthentication->m_PlayerAuthenticationData.end())
	{
		g_pSquirrel<context>->pushbool(sqvm, false);
		return SQRESULT_NOTNULL;
	}

	g_pServerAuthentication->m_PlayerAuthenticationData[pClient].needPersistenceWriteOnLeave = false;
	g_pServerAuthentication->WritePersistentData(pClient);
	return SQRESULT_NULL;
}

ADD_SQFUNC("bool", NSIsWritingPlayerPersistence, "", "", ScriptContext::SERVER)
{
	g_pSquirrel<context>->pushbool(sqvm, g_pMasterServerManager->m_bSavingPersistentData);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("bool", NSIsPlayerLocalPlayer, "entity player", "", ScriptContext::SERVER)
{
	const R2::CBasePlayer* pPlayer = g_pSquirrel<ScriptContext::SERVER>->getentity<R2::CBasePlayer>(sqvm, 1);
	if (!pPlayer)
	{
		spdlog::warn("NSIsPlayerLocalPlayer got null player");

		g_pSquirrel<context>->pushbool(sqvm, false);
		return SQRESULT_NOTNULL;
	}

	R2::CBaseClient* pClient = &R2::g_pClientArray[pPlayer->m_nPlayerIndex - 1];
	g_pSquirrel<context>->pushbool(sqvm, !strcmp(R2::g_pLocalPlayerUserID, pClient->m_UID));
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("bool", NSIsDedicated, "", "", ScriptContext::SERVER)
{
	g_pSquirrel<context>->pushbool(sqvm, IsDedicatedServer());
	return SQRESULT_NOTNULL;
}
