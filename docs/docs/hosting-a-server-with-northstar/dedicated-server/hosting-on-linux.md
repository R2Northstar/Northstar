# Hosting on Linux

{% hint style="info" %}
This page is currently work-in-progress.
{% endhint %}

Linux users can launch the server executable using a Docker image or by using Wine.
If you do not have a DirectX 11 capable GPU in your system (for example if you are using a hosting service), you will want to host a **Headless server.**

# <a name="Headless_Servers">Headless Servers</a>

## Using Docker
Two docker images are currently available:
- [pg9182/northstar_dedicated](https://github.com/pg9182/northstar-dedicated) : Advanced image with server management tools and better performance *(recommended)*
- [legonzaur/northstar-server-headless](https://github.com/Legonzaur/northstar-server-headless) : Basic image without management tools

Check the `README` page for instructions on the appropriate repository to set up your server.

## Without using Docker

> Hosting on a headless Linux server without Docker on Linux is not recommended, as you'll be forced to build packages yourself.

You can find instructions for running a dedicated server using Wine on [pg9182's repository.](https://github.com/pg9182/northstar-dedicated#running-with-wine)

[This comment on GitHub](https://github.com/R2Northstar/Northstar/issues/49#issuecomment-1001094694) also contains some information for hosting a dedicated server on Linux.
