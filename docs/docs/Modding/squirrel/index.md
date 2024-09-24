# squirrel_re

Squirrel is the programming language used by Respawn. A lot of the logic for the game is written in squirrel scripts because of how convenient it is, even for people with little programming knowledge.

Squirrel is an dynamically typed interpreted language that is compiled to bytecode when loading.
The version of squirrel used by Respawn is heavily modified. Most notable is the added optional static typing of the language.

Respawn's fork branched off at version 2.3 of vanilla squirrel so newer features do not exist, like generators.

Because of how different Respawn's fork of squirrel is, the language is often called "squirrel_re" (the official name found in Apex Legends).

## Syntax Highlighting

## Notepad++

For Notepad++, define a custom language for Squirrel. Luckily, [samisalreadytaken has
written a squirrel highlighter](https://gist.github.com/samisalreadytaken/5bcf322332074f31545ccb6651b88f2d#file-squirrel-xml).

1. Download Squirrel.xml
2. At the top, edit `ext="nut"` to `ext="nut gnut"` so it works with gnut files as
   well
3. Open Notepad++
4. Navigate to Language > User Defined Language > Define your language
5. Click import, and select Squirrel.xml

(If the colors/style are not to your taste) 1. Select `Squirrel` in User Language at
the top 2. Navigate through the tabs to find what you want to change 3. Click its
'`Styler`' button and make the changes you wish to

## VSCode

RespawnSquirrel has been added to the vscode marketplace, you can download it here:

https://marketplace.visualstudio.com/items?itemName=Sandwhiched.rspn-squirrel

Otherwise you can simply search "Respawn Squirrel" in the extensions tab

## Kate

[Kate syntax highlighting for Squirrel](https://gist.github.com/CTalvio/6de535f9258cfebd71ab64d7e6af4ee6)


