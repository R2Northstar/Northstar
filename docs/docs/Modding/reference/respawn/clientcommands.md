# Client Commands

Client commands are how the clients communicate with the server. Mods can define custom Client Commands that people can then use from the console, or that can be called from a clientside script.

!!! cpp-function "void AddClientCommandCallback(string, void functionref(entity, array<string> ))"

    Registers a function as a callback for a client command. This can only be done once per client command string.

    ```squirrel
        AddClientCommandCallback("commandname", commandcallback)

        void CommandCalled(entity player, array<string> args) {
            print("commandname: was called with " + args);
        }
    ```


## List of Client Commands {#list_client_commands}

Heres a (incomplete) list of client commands that are used in the game.

!!! note

    Please note that this list is very incomplete. If you find any new ones, please PR them into the referenced CSV.


|Client Command|Arguments|Description|
|--------------|---------|-----------|
|PrivateMatchSetMode|mode shortname|Player changed the mode in private lobby menu|
|SetCustomMap|map name|Player changed the map in private lobby menu |
|PrivateMatchSetPlaylistVarOverride||playlistvaroverride, value|Player changed the playlistvaroverride to value in private lobby menu|
|RequestPilotLoadout|index|Player has changed their loadout to index 2|
|ClearNewStatus|pilot_loadout_3|
|VModEnable|number|unknown, logged with number 0|
|vban|number|unknown, logged with number 0|
|HoldToRodeo|number0|unknown, logged with number 0|
|ClientStatus|number|unknown, logged with number 0|
|AllDialogueFinished||unknown|
