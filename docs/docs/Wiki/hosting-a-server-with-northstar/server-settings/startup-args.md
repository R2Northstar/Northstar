## Startup Arguments

Startup arguments can be added in the `ns_startup_args_dedi.txt` file.\
Example: `+setplaylist private_match +mp_gamemode ps`

| Arguments                  | Accepted Values                                                 | Description                                                               |
| -------------------------- | --------------------------------------------------------------  | ------------------------------------------------------------------------- |
| `+setplaylist`             | see [Gamemodes](../server-settings/file-names.md#gamemodes) (Should be the same as `mp_gamemode` unless you want a private match) | Set the server type (If it is not `private_match`, make sure you have also included `+map` and NOT `mp_lobby` or else you can't search your server in the game) |
| `+setplaylistvaroverrides` | see [PlaylistOverrides](playlistvar.md)                         | Edits the behaviour of the server                                         |
| `-port`                    | int beteween `1-65535`                                          | Determines which UDP port the server will listen to                       |
| `+mp_gamemode`             | see [Gamemodes](../server-settings/file-names.md#gamemodes)     | Forces the gamemode of the server                                         |
| `+map`                     | see [Maps](../server-settings/file-names.md#maps) (`mp_lobby` is the default if not included) | Forces the map of the server at the first start                           |

| Flags                 | Description                                                                    |
| --------------------- | ------------------------------------------------------------------------------ |
| `-maxplayersplaylist` | Allows [PlaylistOverrides](playlistvar.md) to override max player count        |
| `-enablechathooks`    | Allows send the commands using in-game chat                                    |
| `-allowdupeaccounts`  | Allows the same account joining multiple times                                 |
