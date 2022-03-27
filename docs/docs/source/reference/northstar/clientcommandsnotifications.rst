
ClientCommand Notifications
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Since version 1.5 mods can receive notifications when a client command has been handled. This is different from :cpp:func:`AddClientCommandCallback`

.. cpp:function:: void AddClientCommandNotifyCallback( string, void functionref( entity, array<string>))

    Example usage with the :doc:`PrivateMatchLaunch` clientcommand

    .. code-block:: javascript

        void function init(){
            AddClientCommandNotifyCallback("PrivateMatchLaunch", started)
        }

        void function started(entity player, array<string> args){
            print(player + " started the match")
        }

Please refer to :ref:`list_client_commands` for a list of native client commands you could catch.