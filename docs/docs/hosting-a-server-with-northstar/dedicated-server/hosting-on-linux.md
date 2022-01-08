# Hosting on Linux

{% hint style="info" %}
Hosting on Linux is still WIP.
{% endhint %}

[This issue thread on Github](https://github.com/R2Northstar/Northstar/issues/49) contains some instructions to succesfully host a dedicated server on Linux.

Linux users can launch the server executable using Wine.

As servers currently needs DirectX 11 capabilities, a dedicated hosted on linux will need a graphics card and a working X11 environment to work.

If one of those two conditions are not met, you'll want to know how to host a [Headless Server](#headless-servers)

# <a name="Headless_Servers">Headless Servers</a>

## Using Docker
Two docker images are currently available
- [pg9182/northstar_dedicated](https://github.com/pg9182/northstar-dedicated) : Advanced image with server management tools and better performance
- [legonzaur/northstar-server-headless](https://github.com/Legonzaur/northstar-server-headless) : Basic image without management tools

Those two docker images are using XVFB internally, an headless fork on Xorg.

## Without using Docker

Hosting on a headless linux server without docker on Linux is not reccomended, as you'll be forced to build packages yourself.

You can find instruction on pg9182's repository [pg9182/northstar_dedicatd#running-with-wine](https://github.com/pg9182/northstar-dedicated#running-with-wine)
