# Networked Data

## Networked Variables

!!! cpp-function "void RegisterNetworkedVariable( string name, int SNDC_category, int SNVT_type, var defaultValue = 0, float rangemin = 0, float rangemax = 0 )"

  Registers a named networked variable.

!!! cpp-function "int GetNetworkedVariableIndex( string name )"

  Gets the internal index used to reference a scripted network variable. For use with `FX_PATTACH_SCRIPT_NETWORK_VAR`.

!!! cpp-function "void SetGlobalNetBool( string name, bool value )"

!!! cpp-function "void SetGlobalNetInt( string name, int value )"

!!! cpp-function "void SetGlobalNetFloat( string name, float value )"

!!! cpp-function "void SetGlobalNetFloatOverTime( string name, float value, float time )"

!!! cpp-function "void SetGlobalNetTime( string name, float value )"

!!! cpp-function "void SetGlobalNetEnt( string name, entity value )"

!!! cpp-function "bool GetGlobalNetBool( string name )"

!!! cpp-function "int GetGlobalNetInt( string name )"

!!! cpp-function "float GetGlobalNetFloat( string name )"

!!! cpp-function "float GetGlobalNetTime( string name )"

!!! cpp-function "entity GetGlobalNetEnt( string name )"

## Remote Functions

Remote functions allow the `SERVER` to call registered script functions on the `CLIENT` and `UI` VM.

!!! cpp-function "void Remote_BeginRegisteringFunctions()"

  Begin registration of remote functions.

!!! cpp-function "void Remote_EndRegisteringFunctions()"

  Finish registration of remote functions.

!!! cpp-function "void AddCallback_OnRegisteringCustomNetworkVars( void functionref() callback )"

    !!! note

        This function is not native. It's defined in [Northstar.CustomServers](https://github.com/R2Northstar/NorthstarMods/blob/main/Northstar.CustomServers/mod/scripts/vscripts/sh_remote_functions_mp_custom.gnut)

  Registers a callback when Remote functions are being registered.

  To register custom remote functions you are **required** to use this callback because functions can only be registered once.

  ```squirrel
globalize_all_functions

void function MyMod_Init()
{
    AddCallback_OnRegisteringCustomNetworkVars( MyModRegisterRemoteFunctions )
}

void function MyModRegisterRemoteFunctions()
{
    Remote_RegisterFunction( "ExampleRemoteFunction" )
}

void function ExampleRemoteFunction() {}
  ```

!!! cpp-function "void Remote_RegisterFunction( string name )"

  Register a function name to be used in remote calls.


!!! cpp-function "void Remote_CallFunction_Replay( entity player, string functionName, ... )"

    !!! note

        Allowed extra parameter types are null, bool, int, and float.

  Given a player, function name, and optional parameters, call function in client script.

  Then call it again if we rewind and play a kill replay.
  The command will not reach the client at all if called during a span of time the player skips because they were watching a replay.

!!! cpp-function "void Remote_CallFunction_NonReplay( entity player, string functionName, ... )"

    !!! note

        Allowed extra parameter types are null, bool, int, and float.

  Given a player, function name, and optional parameters, call function in client script.

  Does not get called again in replays.

!!! cpp-function "void Remote_CallFunction_UI( entity player, string functionName, ... )"

    !!! note

        Allowed extra parameter types are null, bool, int, and float.

  Given a player, function name and optional parameters, call function in UI script.

## Replays

While not being networked themselves, these are used by remote functions.

!!! cpp-function "bool ShouldDoReplayIsForcedByCode()"

!!! cpp-function "bool Replay_IsEnabled()"
