# Communicating between CLIENT, UI and SERVER scripts

All VMs (`CLIENT`, `UI`, `SERVER`) are seperate from each other and do not share any variables, even when running on the same machine.

However, there are different interfaces to communicate between all VMs.

## `SERVER` to `CLIENT` vm

### Remote Functions

Remote functions allow the `SERVER` vm to call a function from the `CLIENT` vm with parameters.

To use remote functions, you have to make a registration on both the `CLIENT` and the `SERVER` vm with `Remote_RegisterFunction`.

Northstar provides the

!!! cpp-function "AddCallback_OnRegisteringCustomNetworkVars( void functionref() identifierFn)"

callback in which you can use the

!!! cpp-function "Remote_RegisterFunction(string identifier)"

function. It's not possible to register remote functions after `Remote_EndRegisteringFunctions` has been called. The callback exists to allow multiple mods to register remote vars.

!!! warning

    You can only pass parameters of the types `null`, `int`, `float` or `bool`.

    It is possible to communicate entities using eHandles. To get an eHandle, use the `entity.GetEncodedEHandle()` function. To get the corresponding entity of a handle, use `entity ent = GetEntityFromEncodedEHandle( eHandle )`. eHandles are of type `int`.

#### Example

mod.json extract:

```json
"Scripts": [
{
    "Path": "sh_spaceships.nut",
    "RunOn": "CLIENT || SERVER", // execute the same function on both CLIENT and SERVER
    "ClientCallback": {
        "Before": "Spaceship_Network"
    },
    "ServerCallback": {
        "Before": "Spaceship_Network"
    }
},
{
    // more script registrations ...
```

sh_spaceships.nut:

The networked `CLIENT` function has to be global

```squirrel
#if CLIENT
global function Server_GetNetworkedVariable // make the networked function only global on CLIENT
#endif //CLIENT

global function Spaceship_Network // this gets executed on both CLIENT & SERVER

void function Spaceship_Network()
{
    AddCallback_OnRegisteringCustomNetworkVars( RegisterNetworkVars ) // you can only register remote functions inside of this callback
}

void function RegisterNetworkVars()
{
    // this has to be executed on both CLIENT and SERVER, else they will be out of sync and the client disconnects
    Remote_RegisterFunction( "Server_GetNetworkedVariable" ) // register a remote function. Note that the parameters are not declared here
}

#if CLIENT
void function Server_GetNetworkedVariable( int number ) // you can declare as many or few parameters as you wish
{
    printt("got integer", number)
}
#endif //CLIENT
```

Calling the `CLIENT` function `Server_GetNetworkedVariable` on `SERVER` vm:

```squirrel
// player: CPlayer entity that should execute the function
// func: function identifier string
// ...: any parameters passed to the function
Remote_CallFunction_NonReplay( entity player, string func, ... ) // NOT reexecuted in a replay
Remote_CallFunction_Replay( entity player, string func, ... ) // reexecuted in a replay

// for the previous example, this would be a valid remote function call:

Remote_CallFunction_NonReplay( player, "Server_GetNetworkedVariable", RandomIntRange( 1, 100 ) )
```

### Server to Client command callbacks

Allows the `SERVER` vm to create a `ServerToClientStringCommand` on a player which is linked to a Callback locally

#### Register a server command

!!! note

    this has to be executed on the `Before` Client callback

    the formatting for the server command is like a normal console command. Arguments are seperated by spaces

Register with the function clientside:

!!! cpp-function "AddServerToClientStringCommandCallback( string func, void functionref( array<string> ) reference )"


and execute with the function serverside:

!!! cpp-function "ServerToClientStringCommand( entity player /*CPlayer*/, string command )"


#### Example

```squirrel
void function MessageUtils_ClientInit()
{
    AddServerToClientStringCommandCallback( "ServerHUDMessageShow", ServerCallback_CreateServerHUDMessage )
}

void function ServerCallback_CreateServerHUDMessage ( array<string> args )
{
    // client side command handle logic ...
}
```

## `SERVER` to `UI` vm

!!! cpp-function "Remote_CallFunction_UI( entity player, string functionName, ... )"

    Given a player, function name, and optional parameters, call function in UI script. Allowed var types are null, bool, int, and float.

#### Example

```squirrel
Remote_CallFunction_UI( player, "ScriptCallback_UnlockAchievement", achievementID )
```

## `CLIENT` to `SERVER` vm

### Client to Server command callbacks

Register a client command callback serverside with

!!! cpp-function "AddClientCommandCallback( string command, bool functionref( entity player /*CPlayer*/, array<string> "args ) callback )

`player` is the player that called the command clientside. The callback function should return `true` if the command was accepted and `false` if it was invalid.

The `CLIENT` vm can execute commands with the function:

!!! cpp-function "player.ClientCommand( string command )"

These will be handled by the `SERVER` if the command is registered.

### ClientCommand Notifications

Since version 1.5 mods can receive notifications when a client command has been handled. This is different from `AddClientCommandCallback`

!!! cpp-function "void AddClientCommandNotifyCallback( string, void functionref( entity, array<string>))"

    Example usage with the :doc:`PrivateMatchLaunch` clientcommand

    ```squirrel
    void function init(){
        AddClientCommandNotifyCallback("PrivateMatchLaunch", started)
    }

    void function started(entity player, array<string> args){
        print(player + " started the match")
    }
    ```

Please refer to :ref:`list_client_commands` for a list of native client commands you could catch.

### `CLIENT` to `UI` vm

Create a global function in the `UI` vm and call it in the `CLIENT` vm with the function:

!!! cpp-function "RunUIScript( string identifier, ... ) "


You can also pass parameters to the function. `identifier` is the name of the function you want to call.

## Example

```squirrel
#if UI
global function CallMe

void function CallMe( int a, int b )
{
    printt( a + b )
}
#elseif CLIENT
RunUIScript( "CallMe", 1, 2 ) // 3
#endif
```

## `UI` to `CLIENT` vm

Create a global function in the `CLIENT` vm and call it in the `UI` vm with the function:

!!! cpp-function "RunClientScript( string identifier, ... )"


You can also pass parameters to the function. `identifier` is the name of the function you want to call.

#### Example

```squirrel
#if CLIENT
global function CallMe

void function CallMe( int a, int b )
{
    printt( a + b )
}
#elseif UI
RunClientScript( "CallMe", 1, 2 ) // 3
#endif
```


