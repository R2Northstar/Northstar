# Getting started

**TL;DR:** Port forward `37015` (UDP), and no [CGNAT](getting-started.md#cgnat)

Make sure you already installed Northstar [as described here](../installing-northstar/basic-setup.md).

{% hint style="warning" %}
Hosting your own server of any kind requires basic knowledge of computer networks!\
If you for example don't know what "port forwarding" means and just want to play private matches with your friends it is generally recommended to just find an empty public server instead of trying to host your own server.
{% endhint %}

## Check whether you can port forward

In order for others to join your game they need to be able to reach you. Most likely your router acts as a NAT so you need to port forward two ports to your PC for [NAT traversal](https://en.wikipedia.org/wiki/NAT\_traversal).

An explanation of what port-forwarding is exactly can be found in the following video:

{% embed url="https://www.youtube.com/watch?v=WOZQppVNGvA" %}

## CGNAT

First we want to make sure you're not behind a [CGNAT](https://en.wikipedia.org/wiki/Carrier-grade\_NAT) as this basically means you [won't be able to host at all](https://en.wikipedia.org/wiki/Carrier-grade_NAT#Disadvantages).

For this find out your external IP address [by visiting this site](https://www.whatsmyip.org).

Then [open CMD](https://www.lifewire.com/how-to-open-command-prompt-2618089#toc-open-command-prompt-in-windows-10) and type in:

```txt
tracert <your external IP address here>
```

if only your external IP address shows up when the commands exits you're good.

If you get 2 entries or more you're likely behind a [CGNAT](https://en.wikipedia.org/wiki/Carrier-grade\_NAT). Your only options in this case are either to ask your ISP to give you a public IP address or check whether at least your IPv6 address is public.

## Port forwarding

Access your router via it's web interface and port forward

* `37015` (UDP) for game logic

to your PC that you're running Northstar on.

## Firewall

You need to allow the `NorthstarLauncher.exe` in the firewall so that it can connect to the internet. By default, when you launch the server, it should pop up the Windows security alert and let you decide if the application able to connect to the network.

If you accidentally click the deny button, then follow the step to allow it.

* Open Windows Firewall
* Select "Allow an app or feature through Windows Defender Firewall"
* Click "Allow other applications"
* Click "Browse"
* Locate `NorthstarLauncher.exe` and select it
* Click "Add"

## Final checks

To check whether you set everything up correctly, start the game via Northstar and go into a private match. Another Northstar user should now be able to see your server on the server browser and join it.\
You can also use a web based server browser like the one made by [Taskinoz](https://taskinoz.com/northstar/) or [cpdt](https://cpdt.dev/northstar/) to see if your server shows up in there.

Note that by default your server is called `Unnamed Northstar Server`. You can change this name as described in the next page.
