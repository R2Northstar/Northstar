#include "pluginbackend.h"
#include "plugin_abi.h"
#include "server/serverpresence.h"
#include "masterserver/masterserver.h"
#include "squirrel/squirrel.h"
#include "plugins.h"

#include "core/convar/concommand.h"

#define EXPORT extern "C" __declspec(dllexport)

AUTOHOOK_INIT()

PluginCommunicationHandler* g_pPluginCommunicationhandler;

static PluginDataRequest storedRequest {PluginDataRequestType::END, (PluginRespondDataCallable) nullptr};

void init_plugincommunicationhandler()
{
	g_pPluginCommunicationhandler = new PluginCommunicationHandler;
	g_pPluginCommunicationhandler->requestQueue = {};
}

void PluginCommunicationHandler::RunFrame()
{
	std::lock_guard<std::mutex> lock(requestMutex);
	if (!requestQueue.empty())
	{
		storedRequest = requestQueue.front();
		switch (storedRequest.type)
		{
		default:
			spdlog::error("{} was called with invalid request type '{}'", __FUNCTION__, static_cast<int>(storedRequest.type));
		}
		requestQueue.pop();
	}
}

void PluginCommunicationHandler::PushRequest(PluginDataRequestType type, PluginRespondDataCallable func)
{
	std::lock_guard<std::mutex> lock(requestMutex);
	requestQueue.push(PluginDataRequest {type, func});
}

void PluginCommunicationHandler::GeneratePresenceObjects()
{
	PluginGameStatePresence presence {};

	presence.id = g_pGameStatePresence->id.c_str();
	presence.name = g_pGameStatePresence->name.c_str();
	presence.description = g_pGameStatePresence->description.c_str();
	presence.password = g_pGameStatePresence->password.c_str();

	presence.isServer = g_pGameStatePresence->isServer;
	presence.isLocal = g_pGameStatePresence->isLocal;

	if (g_pGameStatePresence->isLoading)
		presence.state = GameState::LOADING;
	else if (g_pGameStatePresence->uiMap == "")
		presence.state = GameState::MAINMENU;
	else if (g_pGameStatePresence->map == "mp_lobby" && g_pGameStatePresence->isLocal && g_pGameStatePresence->isLobby)
		presence.state = GameState::LOBBY;
	else
		presence.state = GameState::INGAME;

	presence.map = g_pGameStatePresence->map.c_str();
	presence.mapDisplayname = g_pGameStatePresence->mapDisplayname.c_str();
	presence.playlist = g_pGameStatePresence->playlist.c_str();
	presence.playlistDisplayname = g_pGameStatePresence->playlistDisplayname.c_str();

	presence.currentPlayers = g_pGameStatePresence->currentPlayers;
	presence.maxPlayers = g_pGameStatePresence->maxPlayers;
	presence.ownScore = g_pGameStatePresence->ownScore;
	presence.otherHighestScore = g_pGameStatePresence->otherHighestScore;
	presence.maxScore = g_pGameStatePresence->maxScore;
	presence.timestampEnd = g_pGameStatePresence->timestampEnd;
	g_pPluginManager->PushPresence(&presence);
}

ON_DLL_LOAD_RELIESON("engine.dll", PluginBackendEngine, ConCommand, (CModule module))
{
	g_pPluginManager->InformDLLLoad(PluginLoadDLL::ENGINE, &g_pPluginCommunicationhandler->m_sEngineData);
}

ON_DLL_LOAD_RELIESON("client.dll", PluginBackendClient, ConCommand, (CModule module))
{
	g_pPluginManager->InformDLLLoad(PluginLoadDLL::CLIENT, nullptr);
}

ON_DLL_LOAD_RELIESON("server.dll", PluginBackendServer, ConCommand, (CModule module))
{
	g_pPluginManager->InformDLLLoad(PluginLoadDLL::SERVER, nullptr);
}
