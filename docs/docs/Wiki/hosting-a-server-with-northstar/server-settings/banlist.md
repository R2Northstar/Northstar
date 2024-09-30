# Banlist

The `banlist.txt` file found at `R2Northstar\banlist.txt` is a list of players that you have either banned or unbanned from your server.

The UIDs can be formatted as shown below:
```
1111111111

4444444444
```

This file also supports the use of comments with the `#` symbol:

```
# This is a comment
1111111111

4444444444 # Banned for being uncool
```

## Banning

When banning a player in game using the `ban` command in console, their UID will be added to the list in `banlist.txt`.

The `ban` command is used alongside the name of the player you want to ban (e.g. `ban realPlayerFr`), or with their UID (e.g. `ban 1111111111`). The console will auto-complete the name for you, given you have typed something close to a valid name of a player in the game.

## Unbanning

When unbanning a player in game using the `unban` command in console, their UID will be commented out in the file, as well as a comment next to their UID displaying the unban date.

The `unban` command is used alongisde the UID of the player you want to unban (e.g. `unban 1111111111`).
