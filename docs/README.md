# NorthstarDocs

This repo contains documentation and guides on most things you need to know about using and creating mods for Northstar.

It is partitioned into:
- the **Wiki** section which contains a variety of information on how to install and use Northstar as well as troubleshooting tips.
- the **Modding** section which contains all the information necessary to create mods for Northstar as well as further technical details for developing for Northstar.

Especially the technical documentation is not done yet and might be incorrect or outdated in some places.

If you have some knowledge to share, but don't want to write a PR, you can make an issue explaining what you know and we can try to integrate that into the docs.

## Contributing

The only prerequisites are python and pip. On Linux simply run `run.sh` in the root dir and in windows execute `run.ps1` with powershell in the root dir. You may need to change the Powershell execution policies in order to run the script.

Running the script will install all dependencies required and build the docs locally. The local version is available at [port 8000](http://127.0.0.1:8000/). The server will get opened in your browser when the script finishes.
When you change a file the server will automatically rebuild it and refresh your browser window.
