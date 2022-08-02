# RCON

{% hint style="danger" %}
RCON has not yet been merged and is still in development. As such information here only applies if you're running the RCON branch of NorthstarLauncher!
{% endhint %}

WIP

RCON requires TCP port open on same port as as gameserver UDP port to connect, i.e. `37015` both UDP and TCP

RCON only runs on dedicated server (no point to have it on listen server anyway)

RCON only runs if >=8 password is set in `rcon_password` convar

- RCON PR: https://github.com/R2Northstar/NorthstarLauncher/pull/100
- cpdt's rust based RCON client: https://github.com/cpdt/northstar-rcon-client


