# Prerequisites

**TL;DR:** Port forward `37015` (UDP) and `8081` (TCP)

Make sure you already installed Northstar [as described here](../installing-northstar/basic-setup.md).

{% hint style="warning" %}
Hosting your own server of any kind requires basic knowledge of computer networks!\
If you for example don't know what "port forwarding" means and just want to play private matches with your friends it is generally recommended to just find an empty public server instead of trying to host your own server.
{% endhint %}

## Check whether you can port forward

In order for others to join your game they need to be able to reach you. Most likely your router acts as a NAT so you need to port forward two ports to your PC for [NAT traversal](https://en.wikipedia.org/wiki/NAT\_traversal).

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
* `8081` (TCP) for Northstar auth so your server shows up in server browser

to your PC that you're running Northstar on.

## Final checks

To check whether you set everything up correctly, start the game via Northstar and go into a private match. Another Northstar user should now be able to see your server on the server browser and join it.\
You can also use a web based server browser like the one made by [Taskinoz](https://taskinoz.com/northstar/) or [cpdt](https://cpdt.dev/northstar/) to see if your server shows up in there.

You can also use a third-party site like [this one](https://www.ipfingerprints.com/portscan.php) to see whether you set up the TCP port forwarding correctly for the authentication port (usually `8081`) by performing a scan while your Northstar server is running.

![Example check](https://raw.githubusercontent.com/R2Northstar/NorthstarWiki/main/docs/images/portforwarding-testing.png)

![Working portforwarding for the TCP port](https://raw.githubusercontent.com/R2Northstar/NorthstarWiki/main/docs/images/portforwarding-working.png)

Testing port forwarding like this only works for the TCP port due to the way UDP and Northstar work.

Note that by default your server is called `Unnamed Northstar Server`. You can change this name as described in the next page.
