#include "pch.h"

#include "gamepresence.h"
#include "plugins/pluginbackend.h"
#include "plugins/plugins.h"
#include "dedicated/dedicated.h"
#include "server/serverpresence.h"
#include "masterserver/masterserver.h"
#include "squirrel/squirrel.h"

GameStatePresence* g_pGameStatePresence;

GameStatePresence::GameStatePresence()
{
	g_pServerPresence->AddPresenceReporter(&m_GameStateServerPresenceReporter);
}

void GameStateServerPresenceReporter::RunFrame(double flCurrentTime, const ServerPresence* pServerPresence)
{
	g_pGameStatePresence->id = pServerPresence->m_sServerId;
	g_pGameStatePresence->name = pServerPresence->m_sServerName;
	g_pGameStatePresence->description = pServerPresence->m_sServerDesc;
	g_pGameStatePresence->password = pServerPresence->m_Password;

	g_pGameStatePresence->map = pServerPresence->m_MapName;
	g_pGameStatePresence->playlist = pServerPresence->m_PlaylistName;
	g_pGameStatePresence->currentPlayers = pServerPresence->m_iPlayerCount;
	g_pGameStatePresence->maxPlayers = pServerPresence->m_iMaxPlayers;

	g_pGameStatePresence->isLocal = !IsDedicatedServer();
}

void GameStatePresence::RunFrame()
{
	if (g_pSquirrel<ScriptContext::UI>->m_pSQVM != nullptr && g_pSquirrel<ScriptContext::UI>->m_pSQVM->sqvm != nullptr)
		g_pSquirrel<ScriptContext::UI>->Call("NorthstarCodeCallback_GenerateUIPresence");

	if (g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM != nullptr && g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM->sqvm != nullptr)
	{
		auto test = g_pSquirrel<ScriptContext::CLIENT>->Call("NorthstarCodeCallback_GenerateGameState");
	}
	g_pPluginCommunicationhandler->GeneratePresenceObjects();
}

ADD_SQFUNC("void", NSPushGameStateData, "GameStateStruct gamestate", "", ScriptContext::CLIENT)
{
	SQStructInstance* structInst = g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM->sqvm->_stackOfCurrentFunction[1]._VAL.asStructInstance;
	g_pGameStatePresence->map = structInst->data[0]._VAL.asString->_val;
	g_pGameStatePresence->mapDisplayname = structInst->data[1]._VAL.asString->_val;
	g_pGameStatePresence->playlist = structInst->data[2]._VAL.asString->_val;
	g_pGameStatePresence->playlistDisplayname = structInst->data[3]._VAL.asString->_val;

	g_pGameStatePresence->currentPlayers = structInst->data[4]._VAL.asInteger;
	g_pGameStatePresence->maxPlayers = structInst->data[5]._VAL.asInteger;
	g_pGameStatePresence->ownScore = structInst->data[6]._VAL.asInteger;
	g_pGameStatePresence->otherHighestScore = structInst->data[7]._VAL.asInteger;
	g_pGameStatePresence->maxScore = structInst->data[8]._VAL.asInteger;
	g_pGameStatePresence->timestampEnd = ceil(structInst->data[9]._VAL.asFloat);

	if (g_pMasterServerManager->m_currentServer)
	{
		g_pGameStatePresence->id = g_pMasterServerManager->m_currentServer->id;
		g_pGameStatePresence->name = g_pMasterServerManager->m_currentServer->name;
		g_pGameStatePresence->description = g_pMasterServerManager->m_currentServer->description;
		g_pGameStatePresence->password = g_pMasterServerManager->m_sCurrentServerPassword;
	}

	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("void", NSPushUIPresence, "UIPresenceStruct presence", "", ScriptContext::UI)
{
	SQStructInstance* structInst = g_pSquirrel<ScriptContext::UI>->m_pSQVM->sqvm->_stackOfCurrentFunction[1]._VAL.asStructInstance;

	g_pGameStatePresence->isLoading = structInst->data[0]._VAL.asInteger;
	g_pGameStatePresence->isLobby = structInst->data[1]._VAL.asInteger;
	g_pGameStatePresence->loadingLevel = structInst->data[2]._VAL.asString->_val;
	g_pGameStatePresence->uiMap = structInst->data[3]._VAL.asString->_val;

	return SQRESULT_NOTNULL;
}
