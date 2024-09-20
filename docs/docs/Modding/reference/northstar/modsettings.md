# Mod Settings

## Setup

ConVars are the easiest way to implement settings for your mod using the Mod Settings API.

Your mod needs to register itself and all ConVars that are a part of your mod that should be accessible in the Mod Settings menu. To do this, simply add a new script to your mod that runs only in the UI VM like this:

```json
  "Path": "ui/ms_example_mod.nut",
  "RunOn": "UI",
  "UICallback": {
    "Before": "ExampleMod_AddModSettings"
  }
```

Inside of the callback specified here, you can add your settings.

## API

!!! warning

    ConVar values will only persist if the ConVar has an ARCHIVE flag. For Clients, use `FCVAR_ARCHIVE_PLAYERPROFILE`.

    All Mod Settings functions have a `stackPos` paramter. This parameter should only be changed if you're writing custom wrappers for the settings.

!!! cpp-function "void ModSettings_AddModTitle( string modName, int stackPos = 2 )"

    Adds a new category in the settings for your mod

    !!! note

        It's mandatory to register a mod before you can add any settings

!!! cpp-function "void ModSettings_AddModCategory( string categoryName )"

    Adds a new category to your mod

    !!! note

        It's mandatory to register a category for your mod. A mod may have multiple categories

!!! cpp-function "void ModSettings_AddSetting( string conVar, string displayName, string type = "", int stackPos = 2 )"

    Adds a basic setting to the last declared category.

    **Parameters:**

    * `string conVar` - the ConVar this setting modifies
    * `string displayName` - The display string of this setting. This can be a localization token.
    * `string type = ""` - Optional type of this ConVar. This guards against users inserting invalid values.
    * `int stackPos = 2`

    **Types:**

    * `int`
    * `bool`
    * `float`
    * `float2`
    * `float3` / `vector`

    other types will default to setting a string for the ConVar.

!!! cpp-function "void ModSettings_AddEnumSetting( string conVar, string displayName, array<string> values, int stackPos = 2 )"

    Adds a setting to the menu that uses an enum. Users can navigate with buttons next to the input between possible values.

    **Parameters:**

    * `string conVar` - the ConVar this setting modifies
    * `string displayName` - The display string of this setting. This can be a localization token.
    * `array<string> values` - all possible values of this enum. The ConVar value will be set to the index of the selected value.
    * `int stackPos = 2`

!!! cpp-function "void ModSettings_AddSliderSetting( string conVar, string displayName, float min = 0.0, float max = 1.0, float stepSize = 0.1, bool forceClamp = false )"

    Adds a ConVar setting to the menu that has a slider.

    **Parameters:**

    * `string conVar` - the conVar this setting modifies
    * `string displayName` - The display string of this setting. This can be a localization token.
    * `float min = 0.0` - the minimum value of the ConVar
    * `float max = 0.0` - the maximum value of the ConVar
    * `float stepSize = 0.1` - the distance between each possible value.
    * `bool forceClamp = false` - wether to force the value to round to the nearest interval of `stepValue`.

    !!! note

        Whenever Mod Settings is used, the value will be clamped to the nearest value available in the slider.

!!! cpp-function "void ModSettings_AddButton( string buttonLabel, void functionref() onPress, int stackPos = 2 )"

    Adds a button to the menu that has a custom click callback.

    **Parameters:**

    * `string conVar` - the conVar this setting modifies
    * `void functionref() onPress` - callback that gets triggered when this button is pressed.
    * `int stackPos`

## Examples

### Settings Declaration

```squirrel
  AddModTitle( "#MY_LOCALIZED_MOD_TITLE" )

  AddModCategory( "Gameplay" )
  AddConVarSetting( "my_mod_gamer_setting", "Gamer Setting", "string" )
  AddConVarSettingEnum( "my_mod_enum_setting_whatever", "Cool Feature", [ "Disabled", "Enabled" ] )

  AddModCategory( "Visuals" )
  AddConVarSetting( "my_mod_display_color", "Display Color", "vector" )
  AddModSettingsButton( "Preview", void function(){ AdvanceMenu( "MyModMenu" ) } )  // Assumes you have "MyModMenu" set up etc.
```

### Wrapper

To create custom wrapper functions you need to specify the stack position where the root of your Mod Setting declarations take place.

```squirrel
  void function AddModSettingsDropDown( string displayName, array<string> options )
  {
    NSModSettingsAddButton( displayName, void function() { OpenDropDown( options ) }, 3 )
  }
```

Note that in this example the stack position is `3`, since `AddModSettingsButton` needs to walk one additional step to the callback function.
