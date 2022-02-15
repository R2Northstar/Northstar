Getting Started
===================================

Northstar supports the creation of many user mods. 
This guide will teach you the basics of modding to get you started.

Check out the :doc:`usage` section for further information, including
:ref:`installation`.

Basics
------

This guide assumes you have basic understanding with programming and know how to use developer environments. Listed below are tools useful for exporting file formats

If you'd like a more lengthy set of tutorials covering many topics. Look at:

:doc:`moddingtutorials`

Tools
-----
* RSPNVPK
* Cra0 VPK Tool (Titanfall VPK Tool)
* Legion by DZXTPorter

.. TODO actually link the tools here


Quick Start
-----------
In order to get started with making your mod, create a folder in ``R2Northstar/mods``. 
While it isn't required, it is best practise by mod authors to follow the naming scheme ``Author.ModName``, such as ``Northstar.Client``.

After making this folder, inside it add a folder named ``mod`` and a file named ``mod.json``.

Provided is a template ``mod.json``, for a detailed list of values read the :doc:`cheatsheet`


.. code-block:: json

   {
      "Name": "Yourname.Modname",
      "Description": "Woo yeah wooo!",

      "LoadPriority": 0,
      "ConVars": [],
      "Scripts": [],
      "Localisation": []
   }

Inside the ``mod`` folder, existing files found in the engine's virtual file system will be overwritten and new files can be added.
If you need to define new Squirrel files ``(.nut/.gnut)`` they *must* be declared in the ``"Scripts"`` array in `mod.json`.
An example for this might be:

.. code-block:: json

   "Scripts": [
      {
         "Path": "path/to/file.nut",
         "RunOn": "( CLIENT || SERVER ) && MP"
      },
      {
         "Path": "path/to/another_file.nut",
         "RunOn": "( CLIENT || SERVER ) && MP",
         "ClientCallback": {
            "Before": "ClientPreMapspawnThing",
            "After": "AfterMapspawnClientThing"
         },
         "ServerCallback": {
            "Before": "ServerPreMapspawncrap",
            "After": "ServerAfterMapspawnWoo"
         }
      }
   ]


``"Path"`` indicates where the script is, ``"RunOn"`` is the Squirrel VM context (see :doc:`../native/sqvm`) as an expression, and ``"ClientCallback"`` and ``"ServerCallback"`` specify a function call that can be ``"Before"`` and/or ``"After"`` map-spawn.

.. note::

   This project is under active development.