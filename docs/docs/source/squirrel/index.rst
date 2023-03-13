rSquirrel
=========

Squirrel is the programming language used by Respawn to code Titanfall 2, however it was
heavily modified fron the original version, it was roughly forked at version 2.3 . The
most notable change is the additon of types to the language.

Syntax Highlighting
-------------------

Notepad++
---------

For Notepad++, define a custom language for Squirrel. Luckily, `samisalreadytaken has
written a squirrel highlighter
<https://gist.github.com/samisalreadytaken/5bcf322332074f31545ccb6651b88f2d#file-squirrel-xml>`_.

1. Download Squirrel.xml
2. At the top, edit ``ext="nut"`` to ``ext="nut gnut"`` so it works with gnut files as
   well
3. Open Notepad++
4. Navigate to Language > User Defined Language > Define your language
5. Click import, and select Squirrel.xml

(If the colors/style are not to your taste) 1. Select '`Squirrel'`` in User Language at
the top 2. Navigate through the tabs to find what you want to change 3. Click its
'`Styler`' button and make the changes you wish to

VSCode
------

VSCode has extensions avaliable for working with squirrel, and searching "squirrel" in
the extensions marketplace will give you them.

However, installing this will only create an associastion for .nut files, and not .gnut
files. To fix this:

1. Open a .gnut file
2. Do CTRL+K, M (not CTRL+K, CTRL+M)
3. Select ``Configure File Association for .gnut``
4. Select ``Squirrel`` (only appears if you have the extension)

Kate
----

`Kate syntax highlighting for Squirrel
<https://gist.github.com/CTalvio/6de535f9258cfebd71ab64d7e6af4ee6>`_

.. toctree::
    :maxdepth: 2
    :hidden:
    :caption: Squirrel

    /squirrel/intro
    /squirrel/complex_types
    /squirrel/functions
    /squirrel/statements
    /squirrel/class
    /squirrel/async
    /squirrel/networking
