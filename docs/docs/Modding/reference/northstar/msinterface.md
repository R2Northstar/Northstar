# Server Authentification

!!! note

    All of these functions are only exposed to the `UI` VM.

These are functions required for the ingame server browser and the authorization process for the Masterserver and game servers.

## Masterserver Authentification

!!! cpp-function "bool NSIsMasterServerAuthenticated()"

    Returns `true` if the client is authenticated with the Masterserver

!!! cpp-function "bool NSMasterServerConnectionSuccessful()"

    Returns `true` if a successful connection has been established

## Game Server Authentification

!!! cpp-function "void NSTryAuthWithServer( int serverIndex, string password = "" )"

    Tries authing with the fetched server at `serverIndex` and the provided password

!!! cpp-function "bool NSIsAuthenticatingWithServer()"

    Returns `true` if the client is currently authing with a game server


!!! cpp-function "bool NSWasAuthSuccessful()"

    Returns `true` if the client successfully authed with a game server

!!! cpp-function "void NSConnectToAuthedServer()"

    Tries to connect to the game server that has previously been authenticated with


!!! cpp-function "string NSGetAuthFailReason()"

    Returns the API reason why the last authentification failed

!!! cpp-function "void NSTryAuthWithLocalServer()"

    Tries to authenticate with the local game server

!!! cpp-function "void NSCompleteAuthWithLocalServer()"

    Call this after `NSWasAuthSuccessful` returns `true` to complete the local authorization process.

## Server Information

!!! cpp-function "void NSRequestServerList()"

    Start fetching all available game servers from the Masterserver

!!! cpp-function "bool NSIsRequestingServerList()"

    Returns `true` if the last request by

!!! cpp-function "int NSGetServerCount()"

    Returns the total amount of fetched game servers

!!! cpp-function "void NSClearRecievedServerList()"

    Clears all fetched game servers

!!! cpp-function "array<ServerInfo> NSGetGameServers()"

    Returns an array of all available Servers fetched from the Masterserver.

## Connection Callbacks


!!! cpp-function "void AddConnectToServerCallback( void functionref( ServerInfo ) callback )"

    Add a callback to be executed right before connecting to a game server via the Server Browser

!!! cpp-function "void RemoveConnectToServerCallback( void functionref( ServerInfo ) callback )"

    Remove a function object from the list of callbacks

!!! cpp-function "void TriggerConnectToServerCallbacks()"

    Runs all callbacks that have been registered with `AddConnectToServerCallback`

## Script Structs

!!! cpp-struct "ServerInfo"

    Contains all info about a game server.

    !!! cpp-var "int index"

        Index of the native Object equivalent

    !!! cpp-var "string id"

        ID assigned to the game server by the Masterserver in the registration

    !!! cpp-var "string name"

        Name of this game server

    !!! cpp-var "string description"

        Description of this game server

    !!! cpp-var "string map"

        Unlocalized name of the map that's currently running on the game server

    !!! cpp-var "string playlist"

        Unlocalized name of the playlist that's currently running on the game server

    !!! cpp-var "int playerCount"

        The total amount of players currently connected to the player

    !!! cpp-var "int maxPlayerCount"

        The maximum amount of players that can connect to the server

    !!! cpp-var "bool requiresPassword"

        If `true` an extra password is required to connect to the server. Otherwise the password is an empty string

    !!! cpp-var "string region"

        Unlocalized region where the physical server is located

    !!! cpp-var "array<RequiredModInfo> requiredMods"

        Array of all mods that are required to be loaded on the client to be able to join the server

!!! cpp-struct "RequiredModInfo"

    Information of a mod that has to be loaded on the client in order to join a game server

    !!! cpp-var "string name"

        Name of the mod

    !!! cpp-var "string version"

        Version of the mod
