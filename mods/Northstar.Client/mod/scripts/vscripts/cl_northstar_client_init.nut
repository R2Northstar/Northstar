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
    int serverGameState
    int fd_waveNumber
    int fd_totalWaves
}

global struct UIPresenceStruct {
    int gameState
}

global struct ModInfo
{
    string name = ""
    string description = ""
    string version = ""
    string downloadLink = ""
    int loadPriority = 0
    bool enabled = false
    bool requiredOnClient = false
    bool isRemote
    array<string> conVars = []
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
