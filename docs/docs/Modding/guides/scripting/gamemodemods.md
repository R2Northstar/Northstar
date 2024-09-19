# Creating gamemodes

Creating a gamemode is **significantly** more complex than making mutators. The main differences are the number of things you must define in order to create a functioning gamemode.

For example, the client localisation, the way the gamemode is defined (FFA, TDM, etc), the scoring system, respawn system (FFA or TDM spawnpoints) and team mechanics must all be considered.

## The `mod.json`

The `mod.json` is responsible for governing when, and where your mod is loaded, and follows a layout that is fairly complicated at first glance.
However, once you get the hang of it, it should be fairly easy to use.

```json

    {
        "Name" : "SimpleRandomiser",
        "Description" : "A randomiser gamemode that randomizes your loadouts!",
        "Version": "0.1.0",
        "LoadPriority": 1,
```

The script above defines the pubic and listed details of the mod.

```json

    "Scripts": [
        {
            "Path": "gamemodes/_gamemode_simplerandomiser.nut",
        "RunOn": "SERVER && MP"
        },
        {
            "Path": "gamemodes/cl_gamemode_simplerandomiser.nut",
            "RunOn": "CLIENT && MP"
        },
        {
            "Path": "sh_gamemode_simplerandomiser.nut",
            "RunOn": "MP",
            "ClientCallback": {
                "Before": "simplerandomiser_init"
            },
            "ServerCallback": {
                "Before": "simplerandomiser_init"
            }
        }
    ],
```

The script above defines both what functions to run, when to run them and WHERE to run them,

The first one being `_gamemode_simplerandomiser.nut` runs the server scripts, which handles the portion of everything related to the player, such as taking their weapons and replacing it with a different one.

Second one being `cl_gamemode_simplerandomiser.nut` is where the client scripts run to perform stuff locally on the player's game, such as playing music, receiving announcement texts from the server and so on.

Lastly, `sh_gamemode_simplerandomiser.nut` is a shared script between server and client, in this case it runs your `simplerandomiser_init` in order to assign many variables for the server and client to "know" about this gamemode.

For example, both server and client needs to know whether if this gamemode exists in the private match settings, the scoring HUD and system, the spawnpoints configuration and many more.



```json

        "Localisation": [
            "resource/simplerandomiser_localisation_%language%.txt"
        ]
    }
```

This defines the path to the language file, and its main use is to localize strings such as the announcement texts, gamemode and so on.

Name this file `mod.json`, and it should go in the mods root folder, that being /yourmodname.

Here's what the end result would look like:

```json

    {
        "Name" : "SimpleRandomiser",
        "Description" : "SimpleRandomiser",
        "Version": "0.1.0",
        "LoadPriority": 1,
        "Scripts": [
        {
            "Path": "gamemodes/_gamemode_simplerandomiser.nut",
        "RunOn": "SERVER && MP"
        },
        {
            "Path": "gamemodes/cl_gamemode_simplerandomiser.nut",
            "RunOn": "CLIENT && MP"
        },
        {
            "Path": "sh_gamemode_simplerandomiser.nut",
            "RunOn": "MP",
            "ClientCallback": {
                "Before": "simplerandomiser_init"
            },
            "ServerCallback": {
                "Before": "simplerandomiser_init"
            }
        }
    ],
        "Localisation": [
            "resource/simplerandomiser_localisation_%language%.txt"
        ]
    }
```

## Language file

This follows a fairly simple template, the only thing of note is that you often get strange behaviour using `UTF-8` when saving the file instead of using `UTF-16 LE`.


```
    "lang"
    {
        "Language" "english"
        "Tokens"
        {
            "MODE_SETTING_CATEGORY_SIMPLERANDOMISER" "Simple Randomiser"
            "SIMPLERANDOMISER" "Randomise"
        }
    }
```

Name this file `simplerandomiser_localisation_english.txt` and place it in the `yourmodsname/mod/resource/` folder.

## Shared functions

Let's begin the process by first creating the file `sh_gamemode_simplerandomiser.nut` and making the core components of the gamemode, which is to define the gamemode properties.

```squirrel

    global function simplerandomiser_init // initializing functions
    global const string GAMEMODE_SIMPLERANDOMISER = "rand"
    // we want a short term to use which allows server owners to
    // select our gamemode without typing the entire name
    // also makes it easier for us lol

    void function simplerandomiser_init()
    {
        // start defining what to do before the map loads on this gamemode
    AddCallback_OnCustomGamemodesInit( CreateGamemodeRand ) // define various properties such as name, desc, so on
    AddCallback_OnRegisteringCustomNetworkVars( RandRegisterNetworkVars ) // server callbacks stuff
    }

    void function CreateGamemodeRand()
    {
    GameMode_Create( GAMEMODE_SIMPLERANDOMISER )
    GameMode_SetName( GAMEMODE_SIMPLERANDOMISER, "#GAMEMODE_SIMPLERANDOMISER" ) // localizations will be handled later
    GameMode_SetDesc( GAMEMODE_SIMPLERANDOMISER, "#PL_rand_desc" )
    GameMode_SetGameModeAnnouncement( GAMEMODE_SIMPLERANDOMISER, "grnc_modeDesc" )
    GameMode_SetDefaultTimeLimits( GAMEMODE_SIMPLERANDOMISER, 10, 0.0 ) // a time limit of 10 minutes
    GameMode_AddScoreboardColumnData( GAMEMODE_SIMPLERANDOMISER, "#SCOREBOARD_SCORE", PGS_ASSAULT_SCORE, 2 ) // dont fuck with it
    GameMode_AddScoreboardColumnData( GAMEMODE_SIMPLERANDOMISER, "#SCOREBOARD_PILOT_KILLS", PGS_PILOT_KILLS, 2 ) // dont fuck with it
    GameMode_SetColor( GAMEMODE_SIMPLERANDOMISER, [147, 204, 57, 255] ) // dont fuck with it

    AddPrivateMatchMode( GAMEMODE_SIMPLERANDOMISER ) // add to private lobby modes

    AddPrivateMatchModeSettingEnum("#PL_rand", "rand_enableannouncements", ["#SETTING_DISABLED", "#SETTING_ENABLED"], "1")
    // creates a togglable riff whether or not we want to announce a text to the client
    AddPrivateMatchModeSettingArbitrary("#PL_rand", "rand_announcementduration", "3")
    // Creates a riff with an arbitrary numerical value for how long the announcement text remains on screen
    // These riffs can be accessed from server configs or from the private match settings screen, under the "Simple Randomiser" category


    // set this to 25 score limit default
    GameMode_SetDefaultScoreLimits( GAMEMODE_SIMPLERANDOMISER, 25, 0 )

    #if SERVER
        GameMode_AddServerInit( GAMEMODE_SIMPLERANDOMISER, GamemodeRand_Init ) // server side initalizing function
        GameMode_SetPilotSpawnpointsRatingFunc( GAMEMODE_SIMPLERANDOMISER, RateSpawnpoints_Generic )
        GameMode_SetTitanSpawnpointsRatingFunc( GAMEMODE_SIMPLERANDOMISER, RateSpawnpoints_Generic )
                // until northstar adds more spawnpoints algorithm, we are using the default.
    #elseif CLIENT
        GameMode_AddClientInit( GAMEMODE_SIMPLERANDOMISER, ClGamemodeRand_Init ) // client side initializing function
    #endif
    #if !UI
        GameMode_SetScoreCompareFunc( GAMEMODE_SIMPLERANDOMISER, CompareAssaultScore )
                // usually compares which team's score is higher and places the winning team on top of the losing team in the scoreboard
    #endif
    }

    void function RandRegisterNetworkVars()
    {
    if ( GAMETYPE != GAMEMODE_SIMPLERANDOMISER )
        return

    Remote_RegisterFunction( "ServerCallback_Randomiser" )
        // will come in useful later when we want the server to communicate to the client
        // for example, making an announcement appear on the client
    }
```

The comments should hopefully explain what most of everything does, but just to summarize:

- we defined the gamemode's name and description using a string that we will localize ourselves later.
- we set the default scoring method, what spawnpoint algorithm to use, as well as the scoreboard size.
- we defined server callbacks, which we will use later on in the server scripts portion of this gamemode.

Now that we're done, name this file `sh_gamemode_simplerandomiser.nut` and place it in the `yourmodsname/mod/scripts/vscripts/gamemodes` folder.

## Server-side function

Now that we're down with defining the gamemode, its time to focus on the component on that makes the gamemode function in-game. For this, it will be mostly handled by the server scripts, so head into `_gamemode_simplerandomiser.nut` to begin writing the randomizing script.

```squirrel

    global function GamemodeRand_Init

    void function GamemodeRand_Init()
    {
        #if SERVER
    SetLoadoutGracePeriodEnabled( false ) // prevent modifying loadouts with grace period
    SetWeaponDropsEnabled( false ) // prevents picking up weapons on the ground
        AddCallback_OnPlayerRespawned( GiveRandomGun )
        #endif
    }
```

As you may have noticed, checking if it is a server is a special case, so we use `#if SERVER` and `#endif` instead of the usual `if(thing){stuff}`

Now that our initial function is created, we now have the game triggering `GiveRandomGun` when a player spawns, but we don't have any such function, so let's begin creating one.

Firstly, we need to know what weapons we can equip.
For this we define an array:

```squirrel

    array<string> pilotWeapons = ["mp_weapon_alternator_smg",
                                  "mp_weapon_autopistol",
                                  "mp_weapon_car",
                                  "mp_weapon_dmr"]
```

Here we have defined an array with only 4 weapons in it, you can make this list however you like but remember to separate all but the last item with a `,`

### Randomise function

As we already know its going to call the function `GiveRandomGun` when a player respawns, let's define that now.
First we strip any existing weapons:

```squirrel

    void function GiveRandomGun(entity player)
    {
        foreach ( entity weapon in player.GetMainWeapons() )
            player.TakeWeaponNow( weapon.GetWeaponClassName() )
```

This iterates through each weapon (that being the primary, secondary and anti-titan weapons) and removes them individually.

Then lets give them a new, random weapon by selecting a random item from our previous array:

```squirrel

    player.GiveWeapon( pilotWeapons[ RandomInt( pilotWeapons.len() ) ] )
```

Now, remember the server callback that we defined earlier in `sh_gamemode_simplerandomiser.nut`? Let's put that to use.
We are going to make it so the player receives an announcement whenever they have their weapons randomized.

```squirrel

    // checks if the toggle option is set to enabled
    if ( GetCurrentPlaylistVarInt( "rand_enableannouncements", 1 ) == 1 )
        Remote_CallFunction_NonReplay( player, "ServerCallback_Randomiser" ) // call the function that will be used client-side
```

Overall, the server script should look like this.

```squirrel

    global function GamemodeRand_Init

    void function GamemodeRand_Init()
    {
        #if SERVER
    SetLoadoutGracePeriodEnabled( false ) // prevent modifying loadouts with grace period
    SetWeaponDropsEnabled( false ) // prevents picking up weapons on the ground
        AddCallback_OnPlayerRespawned( GiveRandomGun )
        #endif
    }

    array<string> pilotWeapons = ["mp_weapon_alternator_smg",
                                  "mp_weapon_autopistol",
                                  "mp_weapon_car",
                                  "mp_weapon_dmr"]

    void function GiveRandomGun(entity player)
    {
        foreach ( entity weapon in player.GetMainWeapons() )
            player.TakeWeaponNow( weapon.GetWeaponClassName() )

        player.GiveWeapon( pilotWeapons[ RandomInt( pilotWeapons.len() ) ] )

        // checks if the toggle option is set to enabled
        if ( GetCurrentPlaylistVarInt( "rand_enableannouncements", 1 ) == 1 )
            Remote_CallFunction_NonReplay( player, "ServerCallback_Randomiser", GetCurrentPlaylistVarFloat( "rand_announcementduration", 3 ) ) // call the function that will be used client-side
    }
```

Name this file `_gamemode_simplerandomiser.nut` and place it in the `yourmodsname/mod/scripts/vscripts/gamemodes` folder as well.
Make sure to double check that all spellings are correct in your mod as everything is case-sensitive.

## Client-side functions
Lastly, for your `cl_gamemode_simplerandomiser.nut`, we are going to utilize the callback functions from earlier, as well as add some music to play during the gamemode.

```squirrel

    global function ClGamemodeRand_Init
    global function ServerCallback_Randomiser

    void function ClGamemodeRand_Init()
    {
        RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "music_mp_freeagents_intro", TEAM_IMC )
    RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "music_mp_freeagents_intro", TEAM_MILITIA )

    RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "music_mp_freeagents_outro_win", TEAM_IMC )
    RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "music_mp_freeagents_outro_win", TEAM_MILITIA )

    RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "music_mp_freeagents_outro_lose", TEAM_IMC )
    RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "music_mp_freeagents_outro_lose", TEAM_MILITIA )

    RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "music_mp_freeagents_outro_lose", TEAM_IMC )
    RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "music_mp_freeagents_outro_lose", TEAM_MILITIA )

    RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_THREE_MINUTE, "music_mp_freeagents_almostdone", TEAM_IMC )
    RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_THREE_MINUTE, "music_mp_freeagents_almostdone", TEAM_MILITIA )

    RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LAST_MINUTE, "music_mp_freeagents_lastminute", TEAM_IMC )
    RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LAST_MINUTE, "music_mp_freeagents_lastminute", TEAM_MILITIA )
    }

    void function ServerCallback_Randomiser( float duration )
    {
        AnnouncementData announcement = Announcement_Create( "#RAND_RANDOMIZED" )
    Announcement_SetSubText( announcement, "#RAND_RANDOMIZED_DESC" )
    Announcement_SetTitleColor( announcement, <0,0,1> )
    Announcement_SetPurge( announcement, true )
    Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
    Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
    Announcement_SetDuration( announcement, duration )
    Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
    AnnouncementFromClass( GetLocalViewPlayer(), announcement )
    }
```

What this script does is quite simple. It registers default music to play during the intro portion, when winning, drawing or losing, as well as the event when the timelimit reaches 3 minutes or 1 minute left.

Also, it also displays an announcement towards the player when they have their weapons randomized.

## Localization

"So we're all done with the scripting stuff, right? That means we can finally run the gamemode itself!"

Technically, yes, you could. But it wouldn't look pretty. Remember all those strings with the # symbol in front of them? We have to localize them first so it displays correctly.

Hence, open your `simplerandomiser_localisation_english.txt` which is located in the `yourmodsname/mod/resource/` folder.

```json

    "lang"
    {
    "Language" "english"
    "Tokens"
    {
        "PL_rand" "Simple Randomiser" // displays in the lobby settings
                "rand_enableannouncements" "Toggle announcements" // describe the togglable setting
        "rand_announcementduration" "Announcement duration" // describe the numerical setting
        "PL_rand_lobby" "Simple Randomiser Lobby" // displays in lobby
        "PL_rand_desc" "Your weapons are randomised! Fight and win!" // displays in the description of the gamemode in the lobby
        "PL_rand_hint" "Your weapons are randomised! Fight and win!" // displays in the scoreboard of the gamemode ingame
        "PL_rand_abbr" "RAND"
        "GAMEMODE_TBAG" "Simple Randomiser" // displays in the loading screen
                "RAND_RANDOMIZED" "Weapons Randomized" // displays in the announcement text
                "RAND_RANDOMIZED_DESC" "Fight and win!" // displays below the announcement text, as a description
    }
    }
```

Alright, we're finally done! However, there's just one thing missing, which is to let the game know what maps are available for this gamemode to play on.

## Maps

We will need to create a file called `playlists_v2.txt` and place it in `yourmodsname/keyvalues` folder.

Yes, you will need to create a folder called `keyvalues` which is separate from the `mod` folder that we placed all our scripts and localization inside.

Next, inside this `playlists_v2.txt`, we will need to allow/disallow what maps can the gamemode be played on.

```text

    playlists
    {
    Gamemodes
    {
        rand
        {
            inherit defaults
            vars
            {
                name #PL_rand
                lobbytitle #PL_rand_lobby
                description #PL_rand_desc
                hint #PL_rand_hint
                abbreviation #PL_rand_abbr
                max_players 12
                max_teams 2
                classic_mp 1

                gamemode_score_hint #GAMEMODE_SCORE_HINT_TDM
            }
        }
        }
        Playlists
    {
        rand
        {
            inherit defaults
            vars
            {
                name #PL_rand
                lobbytitle #PL_rand_lobby
                description #PL_rand_desc
                abbreviation #PL_rand_abbr
                image ps
                //mixtape_slot 7
                mixtape_timeout 120
                visible 0
            }
            gamemodes
            {
                rand
                {
                        maps
                    {
                            mp_forwardbase_kodai 1
                                                mp_grave 1
                                                mp_homestead 1
                                                mp_thaw 1
                                                mp_black_water_canal 1
                                                mp_eden 1
                                                mp_drydock 1
                                                mp_crashsite3 1
                                                mp_complex3 1
                                                mp_angel_city 1
                                                mp_colony02 1
                                                mp_glitch 1
                        mp_lf_stacks 1
                        mp_lf_deck 1
                        mp_lf_meadow 1
                        mp_lf_traffic 1
                        mp_lf_township 1
                        mp_lf_uma 1
                        mp_relic02 1
                        mp_wargames 1
                        mp_rise 1
                                                mp_coliseum 1
                                                mp_coliseum_column 1
                    }
                }
            }
        }
        }
    }
```

There isn't much to say here except that we enabled this gamemode to played on all maps. So if this gamemode is set to auto-rotate maps in a server, it will go from one map to the next in order. You could disable certain maps by changing the `1` to a `0`.

Another thing to note is that under the `Playlists` tab, there is an `image` slot. You could change the image that displays when selecting a gamemode in the private match lobby. You can find out what the keyvalues for the other images by checking out other gamemodes in `Northstar.Custom/keyvalues/playlists_v2.txt`.

## Closing words

And that should be all you need in order to create a gamemode. Thanks for reading all the way to this point, and I hope you have learnt a thing or two.

If you ever have a question or two, feel free to head into the Northstar Discord and ask about in #modding-chat.

- Revised by `x3Karma#6984`
