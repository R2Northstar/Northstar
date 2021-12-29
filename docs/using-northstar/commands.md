# Commands

### Opening the Console

Commands are run on the console. To open it, press `` ` `` (the key above `TAB`).\
Note that this key generally only exists in this form on English keybords (ANSI US, ISO UK, ...).

If you for example have a German keyboard you'll notice that this key is located left of `BACKSPACE` but won't open the console when you press it.

To open your console you'll either have to switch to the English (US) layout **before** starting the game or rebinding the key to open console.

To rebind it make sure neither Titanfall nor Northstar are running, then go to `My Documents\Respawn\Titanfall2\local\` and open `settings.cfg`.\
Look for the line containing `toggleconsole`, i.e.

```
bind "`" "toggleconsole"
```

and replace the `` ` `` key with your prefered key to open console. So if you want to open console with `F5`, change the line to

```
bind "F5" "toggleconsole"
```

{% hint style="info" %}
In the future this keybind should hopefully be adjustable via `Controls > Settings > Key Binds` from within Titanfall.\
**Note** that if you're using the [Enhanced Menu Mod](https://github.com/taskinoz/Enhanced-Menu-Mod) this might already be the case
{% endhint %}

### List of commands

| Command                 | Result         |
| ----------------------- | -------------- |
| `sv_cheats 1`           | Enable cheats  |
| `sv_cheats 0`           | Disable cheats |
| TODO more commands here |                |
