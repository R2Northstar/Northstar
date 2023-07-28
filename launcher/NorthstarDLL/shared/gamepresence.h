#pragma once

#include "server/serverpresence.h"

class GameStateServerPresenceReporter : public ServerPresenceReporter
{
	void RunFrame(double flCurrentTime, const ServerPresence* pServerPresence);
};

class GameStatePresence
{
  public:
	std::string id;
	std::string name;
	std::string description;
	std::string password; // NOTE: May be empty

	bool isServer;
	bool isLocal = false;
	bool isLoading;
	bool isLobby;
	std::string loadingLevel;

	std::string uiMap;

	std::string map;
	std::string mapDisplayname;
	std::string playlist;
	std::string playlistDisplayname;

	int currentPlayers;
	int maxPlayers;

	int ownScore;
	int otherHighestScore; // NOTE: The highest score OR the second highest score if we have the highest
	int maxScore;

	int timestampEnd;

	GameStatePresence();
	void RunFrame();

  protected:
	GameStateServerPresenceReporter m_GameStateServerPresenceReporter;
};

extern GameStatePresence* g_pGameStatePresence;
