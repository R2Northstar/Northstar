global struct GameStateStruct {

    string map
    string mapDisplayname

    string playlist
    string playlistDisplayname

    int currentPlayers
    int maxPlayers
    int ownScore
    int otherHighestScore
    int maxScore
    float timeEnd
}

global struct UIPresenceStruct {
	bool isLoading
	bool isLobby
	string loadingLevel
	string loadedLevel
}

global struct RequiredModInfo
{
    string name
    string version
}

global struct ServerInfo
{
    int index
    string id
    string name
    string description
    string map
    string playlist
    int playerCount
    int maxPlayerCount
    bool requiresPassword
    string region
    array< RequiredModInfo > requiredMods
}
