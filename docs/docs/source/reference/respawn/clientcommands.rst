Client Commands
===============

Client commands are how the clients communicate with the server. Mods can define custom Client Commands that people can then use from the console, or that can be called from a clientside script.

.. cpp:function:: void AddClientCommandCallback(string, void functionref(entity, array<string> ))

    Registers a function as a callback for a client command. This can only be done once per client command string.

    .. code-block:: javascript

        AddClientCommandCallback("commandname", commandcallback)

        void CommandCalled(entity player, array<string> args) {
            print("commandname: was kalled with " + args);
        }

.. _list_client_commands:

List of Client Commands
^^^^^^^^^^^^^^^^^^^^^^^

Heres a (incomplete) list of client commands that are used in the game.

.. note::

    Please note that this list is very incomplete. If you find any new ones, please PR them into the referenced CSV.


.. csv-table:: Client Commands
   :file: ./clientcommands.csv
   :header-rows: 1
   :delim: ;