global enum eDiscordGameState
{
    LOADING = 0
    MAINMENU
    LOBBY
    INGAME
}

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
    int gameState
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

global struct MasterServerAuthResult
{
    bool success
    string errorCode
    string errorMessage
}

global struct ModInstallState
{
    int status
    int progress
    int total
    float ratio
}
