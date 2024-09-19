# Chathooks

This document provides usage of the Chathook API added in Northstar `v1.6.0`.
For an example of chathooks in use, check out EmmaM's [OwOfier mod](https://github.com/emma-miler/OwOfier/).


!!! warning

    Your mod needs to be load priority 1 or above to use the structs and callbacks in your script.


## Client chat API

### Callbacks

The client chat callbacks allow you to intercept chat messages and modify or block them.


!!! cpp-struct "struct ClClient_MessageStruct"

    Contains details on a chat message to be displayed. You can receive one of these by adding a chat callback with
    `AddCallback_OnReceivedSayTextMessage`.


    !!! cpp-var "string message"

        the text sent by the player.
    !!! cpp-var "entity player"

        the player who sent the chat.
    !!! cpp-var "string playerName"

       the display name of the player who sent the chat.
    !!! cpp-var "bool isTeam"

        whether this chat has a `[TEAM]` tag.
    !!! cpp-var "bool isDead"

        whether this chat has a `[DEAD]` tag.
    !!! cpp-var "bool isWhisper"

        whether this chat has a `[WHISPER]` tag.
    !!! cpp-var "bool shouldBlock"

        if true, this chat will not be displayed.



!!! cpp-function "void AddCallback_OnReceivedSayTextMessage(callbackFunc)"

    Adds a callback that will be run when a chat message is received from the server. This will only be triggered for
    messages from players, not server messages.

    The provided function should accept a `ClClient_MessageStruct` and return an optionally modified copy of it. When a
    chat message is received, each registered callback is run in sequence to modify or block the message.

    **Example:**

    ```squirrel

        ClClient_MessageStruct function MyChatFilter(ClClient_MessageStruct message)
        {
            if (message.message.find("nft") != null)
            {
                message.shouldBlock = true
            }

            message.message = StringReplace(message.message, "yes", "no", true, true)

            return message
        }

        void function MyModInit()
        {
            AddCallback_OnReceivedSayTextMessage(MyChatFilter)
        }
    ```


### Writing to Chat

A handful of functions are provided to write messages in local chat windows. These do not send messages to other
players, they only display them locally.

!!! cpp-function "void Chat_GameWriteLine(string text)"

    Writes a line of text in local game chat panels. Supports [ANSI escape codes](#ansi_escape).

    **Example:**

    ```squirrel

        void function OnGameStarted()
        {
            Chat_GameWriteLine("You got this, " + GetLocalClientPlayer().GetPlayerName() + "!")
        }
    ```


!!! cpp-function "void Chat_GameWrite(string text)"

    Appends text to local game chat panels. Supports [ANSI escape codes](#ansi_escape).

    **Example:**

    ```squirrel

        void function InitialiseHEVSuit()
        {
            Chat_GameWriteLine("SENSOR ARRAYS-")
            ActivateSensorArrays()
            Chat_GameWrite("ACTIVATED")
            wait 1
            Chat_GameWriteLine("BIOMETRIC MONITORING SYSTEMS-")
            ActivateBiometricMonitoringSystems()
            Chat_GameWrite("ACTIVATED")
            wait 1
            Chat_GameWriteLine("HAVE A VERY SAFE DAY.")
        }
    ```

!!! cpp-function "void Chat_NetworkWriteLine(string text)"

    Writes a line of text in local network chat panels. Supports [ANSI escape codes](#ansi_escape).

    **Example:**

    ```squirrel

        void function MyModInit()
        {
            Chat_NetworkWriteLine("MyMod v1.0.0 is good to go!")
        }
    ```


!!! cpp-function "void Chat_NetworkWrite(string text)"

    Appends text to local network chat panels. Supports [ANSI escape codes](#ansi_escape).

    **Example:**

    ```squirrel

        void function OnButtonPressed()
        {
            Chat_NetworkWrite("Connecting in 3...")
            wait 1
            Chat_NetworkWrite("2...")
            wait 1
            Chat_NetworkWrite("1...")
            wait 1
            Chat_NetworkWrite("0")
            Connect()
        }
    ```



## Server Chat API

### Callbacks

The server chat callbacks allow you to intercept incoming chat messages and modify or block them.

!!! cpp-struct "ClServer_MessageStruct"

    Contains details on an incoming chat message. You can receive one of these by adding a chat callback with
    `AddCallback_OnReceivedSayTextMessage`.

    !!! cpp-var "string message"

        the text sent by the player.
    !!! cpp-var "entity player"

        the player who sent the chat.
    !!! cpp-var "bool isTeam"

        whether this chat is only sent to the player's team.
    !!! cpp-var "bool shouldBlock"

        if true, this chat will not be sent.


!!! cpp-function "void AddCallback_OnReceivedSayTextMessage(callbackFunc)"

    Adds a callback that will be run when a chat message is received from a player. This will not be fired for custom
    messages sent by server mods.

    The provided function should accept a `ClServer_MessageStruct` and return an
    optionally modified copy of it. When a chat message is received, each registered callback is run in sequence to modify
    or block the message.

    **Example:**

    ```squirrel

        ClServer_MessageStruct function MyChatFilter(ClServer_MessageStruct message)
        {
            if (message.message.find("nft") != null)
            {
                message.shouldBlock = true
            }

            message.message = StringReplace(message.message, "yes", "no", true, true)

            return message
        }
        void function MyModInit()
        {
            AddCallback_OnReceivedSayTextMessage(MyChatFilter)
        }
    ```


### Custom Messages

With custom messages you can send chat messages at any time, to all players or to specific players.

!!! cpp-function "void Chat_Impersonate(entity player, string text, bool isTeamChat)"

    Displays a chat message as if the player sent it. Only use this when the player has performed a clear action to send a
    chat message.

    **Parameters:**

    - `entity player` - the player that the chat message will appear to be from.
    - `string text` - the contents of the chat message. Supports [ANSI escape codes](#ansi_escape)  for colors.
    - `bool isTeamChat` - whether this chat is only sent to the player's team.

    **Example:**

    ```squirrel

        void function OnSayRedCommand(entity player, string text)
        {
            Chat_Impersonate(player, "red text -> \x1b[31m" + text)
        }
    ```


!!! cpp-function "void Chat_PrivateMessage(entity fromPlayer, entity toPlayer, string text, bool whisper)"

    Sends a private chat message from a player that is only displayed to one other player. Only use this when the player has
    performed a clear action to send a chat message.

    **Parameters:**

    - `entity fromPlayer` - the player the message will be from.
    - `entity toPlayer` - the player that the message will be shown to.
    - `string text` - the contents of the chat message. Supports [ANSI escape codes](#ansi_escape) for colors.
    - `bool whisper` - if true, `[WHISPER]` will be displayed before the message to indicate the message is private.

    **Example:**

    ```squirrel

        void function OnSendToFriendsCommand(entity fromPlayer, string text)
        {
            array<entity> friends = GetPlayerFriends(fromPlayer)
            foreach (friend in friends)
            {
                Chat_PrivateMessage(fromPlayer, friend, text, true)
            }
        }
    ```


!!! cpp-function "void Chat_ServerBroadcast(string text, bool withServerTag = true)"

    Displays a server message to all players in the chat.

    **Parameters:**

    - `string text` - the contents of the chat message. Supports [ANSI escape codes](#ansi_escape) for colors.
    - `bool withServerTag` - if true, `[SERVER]` will appear before the message in chat. Defaults to true.

    **Example:**

    ```squirrel

        void function RestartServerThread()
        {
            // wait one hour
            wait 3600
            Chat_ServerBroadcast("Server will be shut down in \x1b[93m5 seconds")
            wait 1
            Chat_ServerBroadcast("Server will be shut down in \x1b[93m4 seconds")
            wait 1
            Chat_ServerBroadcast("Server will be shut down in \x1b[93m3 seconds")
            wait 1
            Chat_ServerBroadcast("Server will be shut down in \x1b[93m2 seconds")
            wait 1
            Chat_ServerBroadcast("Server will be shut down in \x1b[93m1 second")
            wait 1
            StopServer()
        }
    ```


!!! cpp-function "void Chat_ServerPrivateMessage(entity toPlayer, string text, bool whisper, bool withServerTag = true)"

    Sends a server message to a specific player in the chat.

    **Parameters:**

    - `entity toPlayer` - the player that the message will be shown to.
    - `string text` - the contents of the chat message. Supports [ANSI escape codes](#ansi_escape) for colors.
    - `bool whisper` - if true, `[WHISPER]` will be displayed before the message to indicate the message is private.
    - `bool withServerTag` - if true, `[SERVER]` will appear before the message in chat. Defaults to true.

    **Example:**

    ```squirrel

        void function OnBanCommand(entity player, array<string> args)
        {
            if (!PlayerIsModerator(player))
            {
                Chat_ServerPrivateMessage(player, "You do not have the permissions to perform this command.", true, false)
                return
            }

            BanPlayerByName(args[0])
        }
    ```


## ANSI Escape Codes {#ansi_escape}

All messages support ANSI escape codes for customising text color. These are commands in strings that have special
meaning. For example, the string:

```text

    Hello world, \x1b[31mthis text is red\x1b[0m. And \x1b[34mthis text is blue\x1b[0m.
```

`\x1b` is a special character that Squirrel (and other languages) replace with a reserved ASCII character. For future
reference this will be referred to with `ESC` (e.g. setting red text is `ESC[31m`).

The following commands are available:


|Codes|Description|
|-----|-----------|
|`ESC[0m` and `ESC[39m`|Reset text formatting.|
|`ESC[30-37m`, `ESC[90-97m`|Set to one of [the available color presets](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit).|
|`ESC[38;5;Xm`|Set to one of [the available 8-bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit).|
|`ESC[38;2;R;G;Bm`|Set to an RGB color, with `R`, `G` and `B` in the range 0-255.|
|`ESC[110m`|Set to chat text color.|
|`ESC[111m`|Set to friendly player name color.|
|`ESC[112m`|Set to enemy player name color.|
|`ESC[113m`|Set to network name color.|
