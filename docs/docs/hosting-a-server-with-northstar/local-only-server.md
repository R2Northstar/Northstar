# Hosting a Local-Only Server

If you just want to host server (listen or dedicated) for people in your local network (as in computer network, not the in-game Networks system), you can simply not enable port-forwarding and set `ns_auth_allow_insecure` to `1` in the `autoexec_ns_server.cfg`.

This way players can connect to your server directly by using the `connect` command with the local IP of your server, e.g. `connect 192.168.420.500` (replace with actual local IP of your server).


{% hint style="info" %}
Loadouts are saved by the server and connecting to a server directly using `connect` means that the loadout is not loaded from masterserver. This means your loadouts will be reset while playing on said server.

You should see your saved loadouts again when leaving the local-only server
{% endhint %}

{% hint style="info" %}
Even with local-only servers you still need an internet connection to authenticate your account and game ownership with masterserver.
{% endhint %}
