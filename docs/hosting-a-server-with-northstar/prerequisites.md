**TL;DR:** Port forward `37015` (UDP) and `8081` (TCP)

# Prerequisites:

Make sure you already installed Northstar [as described here](Installing-Northstar).

## Check whether you can port forward:

In order for others to join your game they need to be able to reach you. Most likely your router acts as a NAT so you need to port forward two ports to your PC for [NAT traversal](https://en.wikipedia.org/wiki/NAT_traversal).

## CGNAT

First we want to make sure you're not behind a [CGNAT](https://en.wikipedia.org/wiki/Carrier-grade_NAT) as this basically means you won't be able to host at all.

For this find out your external IP address [by visiting this site](https://www.whatsmyip.org/).

Then [open CMD](https://www.lifewire.com/how-to-open-command-prompt-2618089#toc-open-command-prompt-in-windows-10) and type in:

```
tracert <your external IP address here>
```

if only your external IP address shows up when the commands exits you're good.


If you get 2 entries or more you're likely behind a [CGNAT](https://en.wikipedia.org/wiki/Carrier-grade_NAT). Your only options in this case are either to ask your ISP to give you a public IP address or check whether at least your IPv6 address is public.

## Port forwarding

Access your router via it's web interface and port forward

- `37015` (UDP) for game logic
- `8081` (TCP) for Northstar auth so your server shows up in server browser

to your PC that you're running Northstar on.

## Final checks

To check whether you set everything up correctly, start the game via Northstar and go into a private match. Another Northstar user should now be able to see your server on the server browser.  
Note that by default your server is called `Unnamed Northstar Server`. You can change this as described below.

## Extras:

Northstar uses a config file to set various settings for your custom server. The file is located at `Titanfall2\R2Northstar\mods\Northstar.CustomServers\mod\cfg\autoexec_ns_server.cfg`

In particular:
- `ns_server_name` sets the name of your server on the server browser. You probably want to change this to something the people you play with recognise.
- `ns_auth_allow_insecure` decides whether to allow players not authenticated with Northstar master server. Change the value from `0` to `1` if you want to play with vanilla clients. To find out what else you need to do for vanilla clients to join, read [the instruction for setting up Northstar for PUGs](Northstar-PUGs-Setup).

