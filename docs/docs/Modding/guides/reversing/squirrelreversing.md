# Pushing Values to the SQVM Stack

Before starting to reverse engineer how to push values to the Squirrel stack, it's recommended to read the [Squirrel documentation](http://www.squirrel-lang.org/squirreldoc/index.html),
especially the [Embedding-](http://www.squirrel-lang.org/squirreldoc/reference/embedding_squirrel.html)
and [API Reference](http://www.squirrel-lang.org/squirreldoc/reference/api_reference.html).

A lot of Respawn's fork of Squirrel is very similar to Squirrel3, especially the Squirrel API functions.

## Setup

Before you can start reverse engineering you need to install software to disassemble and decompile the binaries. This guide will use [Ghidra](https://ghidra-sre.org/), an open source reverse engineering tool developed by the NSA.

Since code decompiled by Ghidra is often closer to the raw assembly than the original code, you might want to use [IDA](https://hex-rays.com/) for decompilation.
Keep in mind that IDA is not open source and the free version is lacking a lot of features and only offers a cloud decompiler.

1. Download the latest Ghidra archive from the [Github releases page](https://github.com/NationalSecurityAgency/ghidra/releases). Usually the archive is called like `ghidra_[version]_PUBLIC_[date]`.

2. Unzip the archive in a new folder.

3. Run `ghidraRun.bat` on windows or if you're on Linux make `ghidraRun` executable and run it. On Linux, there's a [Flatpak image](https://flathub.org/apps/org.ghidra_sre.Ghidra) available as well.

3. Create a new project under `File > New Project` and select `Non-Shared Project`, then hit next. Afterwards select a location for the project and a name like `Titanfall2`.

4. Import the binary you want to reverse with `File > Import File`. This guide will use `server.dll`, found in your Titanfall2 install directory. Don't change the settings ghidra auto detects when importing the file.

5. Open `server.dll` in the Ghidra project overview. When Ghidra asks you if you want to analyse the file now, click yes. You do not need to change any analysis settings.

6. Wait for Ghidra to finish the analysis.

## Understanding native Squirrel Closures

In vanilla Squirrel you can push values with functions like `sq_pushbool`. Since Respawn changed a lot in the SQVM, you should expect these API functions to be different as well.

To start you'll need a simple Squirrel function that is executing native code without any calculations or similar, like `IsServer`, or `IsClient`.
These Squirrel functions are registered in native code and return `true` / `false` if the script VM is being ran in the `SERVER` or `CLIENT`.

You can search for a string in memory with `Search > Memory`. Select `String` as the format you're searching for and enter `IsServer` as the search value.

The first occurence is at `server.dll+0x2b44f3`. If you wait for the function to be decompiled, you'll see the string in this code:

```c
    _DAT_181055f60 = "IsServer";
    _DAT_181055f68 = "IsServer";
    _DAT_181055fb8 = 0;
    _DAT_181055f90 = 0;
    _DAT_181055f98 = 0;
    _DAT_181055fc0 = FUN_18029a630;
    _DAT_181055f88 = _DAT_181055f88 & 0xff;
    _DAT_181055f70 = ZEXT816(0x1808fa7f8);
    _DAT_181055f80 = 0;
    _DAT_181055f8c = 0;
    _DAT_181055f9c = 6;
```

Because the squirrel function executes native code, the callback `FUN_18029a630` is probably where it's located. You can double click the reference to decompile the function.

```c
    undefined4 FUN_18029a630(undefined8 param_1)
    {
        char cVar1;
        undefined4 uVar2;

        uVar2 = 1;
        FUN_180003710(param_1,1);
        cVar1 = FUN_18001d840(param_1);
        if (cVar1 != '\0') {
            uVar2 = 0xffffffff;
        }
        return uVar2;
    }
```

From this you can assume that native closures in squirrel_re still use the `SQRESULT` convention, because the closure returns `-1` if `FUN_18001d840` returns `NULL`, which is typically an error and `1` if nothing happens.
It's also obvious that either `FUN_180003710` or `FUN_18001d840` pushes a boolean to the stack. It's probably `FUN_180003710` because it takes an extra parameter but you can check `IsClient` at `server.dll+0x29a4d0` as a reference.

```c
    undefined4 FUN_18029a4d0(undefined8 param_1)
    {
        char cVar1;
        undefined4 uVar2;

        FUN_180003710(param_1,0);
        cVar1 = FUN_18001d840(param_1);
        uVar2 = 1;
        if (cVar1 != '\0') {
            uVar2 = 0xffffffff;
        }
        return uVar2;
    }
```

This is virtually the same, except that `FUN_180003710` is being called with a `0`.
This makes it pretty obvious that `FUN_180003710` is the equivalent of `sq_pushbool`.
Decompile the function, then right click the function and select `Edit Function Signature`.
Right now the signature looks like this:

```c
    void FUN_180003710(longlong param_1, int param_2)
```

`param_1` has to be a pointer to the Squirrel VM, because a pointer on 64x systems is 8 bytes long (the same as `longlong`) and the `HSquirrelVM` struct is larger than 8 bytes.

The second parameter has to be the value that will be pushed to the VM as a boolean, since it was `1` in `IsServer` (which always returns `true`) and `0` in `IsClient` which always returns `false`.

You can change the signature now to this, to make code using the function more readable. Because `HSquirrelVM` isn't defined yet, the type needs to stay `longlong` for now.

```c
    void sq_pushbool(longlong sqvm, int value)
```
