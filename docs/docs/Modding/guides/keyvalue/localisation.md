# Localisation

For your content to reach as many people as possible, it is important to have it
translated in users' natural language. This guide will help you do that!

## Languages list

Languages natively supported by Titanfall2 are:

- English
- French
- German
- Italian
- Japanese
- Polish
- Portuguese
- Russian
- Spanish
- Traditional Chinese (`"tchinese"`)

## Create translation files

Here's what a translation file looks like:

```json

    "lang"
    {
        "Language" "english"
        "Tokens"
        {
            "MENU_LAUNCH_NORTHSTAR" "Launch Northstar"
            "MENU_TITLE_MODS" "Mods"
            "RELOAD_MODS" "Reload Mods"
            "WARNING" "Warning"
            "CORE_MOD_DISABLE_WARNING" "Disabling core mods can break your client!"
            "DISABLE" "Disable"
        }
    }
```

It begins with the `"lang"` instruction, contains a `"Language"` key indicating
language of current file's translations, and a `"Token"` key indexing all
translations.

!!! warning

    If the translation file contains any non-ASCII character, it must use `"UTF-16
    LE"` encoding.

You'll have to create one file per supported language, and all your files must be named
in a similar fashion.

For example, Northstar translation files are named
`"northstar_client_localisation_english.txt"`,
`"northstar_client_localisation_french.txt"`,
`"northstar_client_localisation_german.txt"` etc.

You can import them from your `mod.json` manifesto this way:

```json

    {
        "Localisation": [
            "resource/northstar_client_localisation_%language%.txt"
        ]
    }
```

!!! note

    The `"%language%"` syntax allows VM to load up translations matching game language
    (e.g. an English client will automatically use
    `"northstar_client_localisation_english.txt"` file)

## Use translations in your code

To translate UI elements like menus, you have to insert strings containing your
translation keys, preceded by a `#`.

For example, to translate the "Launch Northstar" button on main menu, instead of
calling:

```

    AddComboButton( comboStruct, headerIndex, buttonIndex++, "Launch Northstar" )
```

We'll use:

``` 

    AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_LAUNCH_NORTHSTAR" )
```

You can also use the `Localize` method client-side:

```

    Localize( "#MENU_LAUNCH_NORTHSTAR" )
```

## Northstar translations

Northstar adds new strings to the game which can be localised to match the language you
are using on your Titanfall 2 installation.

They're all located in `"Northstar.Client"` mod: [Northstar localisation files on
GitHub]
(https://github.com/R2Northstar/NorthstarMods/blob/main/Northstar.Client/mod/resource)

!!! note

    To test your modifications, change your game language: with Origin, go to `Origin
    (My games library) -> Titanfall 2 (right click) -> Game Properties -> Advanced
    Launch Options`; with Steam, go to `Titanfall 2 page -> Manage (cog) -> Properties
    -> Language`.
