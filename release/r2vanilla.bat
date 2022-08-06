:: This launches Northstar with a profile that usually shouldn't exist. As such it won't load any NorthstarMods and behave close to a vanilla client outside of patches in Launcher code
:: Disabling ClientCommands with `-norestrictservercommands` is needed for vanilla to be able to transfer you to a game from lobby with `connect`
NorthstarLauncher.exe -norestrictservercommands -profile=R2Vanilla
