# Contributing to ModdingDocs

**How can I contribute?**

All contributions to ModdingDocs are welcome.

Including:

- GitHub Issues containing any knowledge you want to share
- Pull Requests with changes to the docs, even small ones

**What do I need to know to contribute?**

The Northstar modding documentation uses [Markdown](https://en.wikipedia.org/wiki/Markdown).

The `.md` files can be found in the `docs/source` directory.

## Contributing without a local build

You don't necessarily need to set up a local build environment.

To contribute without doing so, you can just edit the files in an editor of your choice and create a GitHub pull request from them.


## Building locally

You need to have a relatively recent version of Python installed - 3.8 or higher. [Download here](https://www.python.org/downloads/)



=== "Windows"

    ```powershell
    git clone https://github.com/R2Northstar/ModdingDocs/
    cd ModdingDocs
    ./run.ps1
    ```

=== "Linux"

    ```bash
    git clone https://github.com/R2Northstar/ModdingDocs/
    cd ModdingDocs
    ./run.sh
    ```

!!! warning
    On Windows, if you are not able to run the script by running `./run.ps1`, try running it with: `powershell.exe -ExecutionPolicy Bypass -File .\run.ps1`

    After this you should be able to run with just `./run.ps1`.
