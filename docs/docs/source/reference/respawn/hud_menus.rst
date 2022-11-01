HUD Menus
====

Before working on HUD, it's recommended to `extract <https://noskill.gitbook.io/titanfall2/intro/duction/vpk-packpack>`_ the ``englishclient_frontend.bsp.pak000_dir.vpk`` vpk. This file contains all vanilla menus and UI logic and will be a very helpful reference!

Registering a menu
----

In your ``mod.json``, add a ``before`` UI callback like this:

.. code-block::

        {
            "Path": "ui/profiles_menu.nut",
            "RunOn": "UI",
	"UICallback": {
		"Before": "InitProfilesMenu",
	}
        }

In the script you referenced, create a global function in which you register your menu with the ``AddMenu`` function like this:

.. code-block:: javascript

    global function InitProfilesMenu

    void function InitProfilesMenu()
    {
        AddMenu( "MenuName", $"path/to/menu.menu"  )
    }

If you want to, you can add a init function to ``AddMenu`` like this: ``AddMenu( "MenuName", $"path/to/menu.menu", func )``

The function returns ``void`` and takes no parameters. It gets called once the menu is initialized.

It's recommended to create a file struct in which you store menu states:

.. code-block:: javascript

    struct {
        var menu
    } file

    void function MenuInitCallback()
    {
        file.menu = GetMenu( "MenuName" )
    }

Menu Functions
^^^^

Useless functions have been left out. From ``_menus.nut``

.. cpp:function:: UICodeCallback_ActivateMenus

Open Menus
~~~~

.. cpp:function:: void AdvanceMenu( string name )

    Push a menu to the stack / open a menu

Retrieve Menus
~~~~

.. cpp:function:: var GetMenu( string name )

    Get the menu reference

.. cpp:function:: var GetPanel( string name )

.. cpp:function:: var GetActiveMenu()

.. cpp:function:: array<var> GetAllMenuPanels( var menu )

Close Menus
~~~~~

.. cpp:function:: void CloseActiveMenu( bool cancelled = false, bool openStackMenu = true )

.. cpp:function:: void CloseAllMenus()

.. cpp:function:: void CloseAllDialogs()

.. cpp:function:: void CloseAllToTargetMenu( var menu )

    Close until the menu is the most recent opened.

.. cpp:function:: void CleanupInGameMenus()

.. cpp:function:: void AddMenuElementsByClassname( var menu, string classname )

.. cpp:function:: void FocusDefaultMenuItem( var menu )

    Set the default focus element to be focused

.. cpp:function:: void FocusDefault( var menu )

    Like ``FocusDefaultMenuItem`` but excludes some menus.

Callbacks
~~~~

.. cpp:function:: void AddMenuEventHandler( var menu, int event, void functionref() func )

    Accepted events:

    * ``eUIEvent.MENU_OPEN``

    * ``eUIEvent.MENU_CLOSE``

    * ``eUIEvent.MENU_SHOW``

    * ``eUIEvent.MENU_HIDE``

    * ``eUIEvent.MENU_NAVIGATE_BACK``

    * ``eUIEvent.MENU_TAB_CHANGED``

    * ``eUIEvent.MENU_ENTITLEMENTS_CHANGED``

    * ``eUIEvent.MENU_INPUT_MODE_CHANGED``

.. cpp:function:: void AddPanelEventHandler( var panel, int event, void functionref() func )

    Accepted events:

    * ``eUIEvent.PANEL_SHOW``

    *  ``eUIEvent.PANEL_HIDE``

.. cpp:function:: void AddButtonEventHandler( var button, int event, void functionref( var ) func )

.. cpp:function:: void AddEventHandlerToButton( var menu, string buttonName, int event, void functionref( var ) func )

    Add an event handler to an element.

    If you have a reference to the element, use ``Hud_AddEventHandler``

.. cpp:function:: void AddEventHandlerToButtonClass( var menu, string classname, int event, void functionref( var ) func )

    Add a event handler for every element of a class

.. cpp:function:: var GetTopNonDialogMenu()

    Get the last openend menu that isn't a dialog

.. cpp:function:: bool IsDialog( var menu )

    Returns ``true`` if the menu is a dialog.



Submenus
~~~~

Not recommended to use.

.. cpp:function:: CloseAllInGameMenus()

.. cpp:function:: OpenSubmenu( var menu, bool updateMenuPos = true )

.. cpp:function:: CloseSubmenu( bool openStackMenu = true )

.. cpp:function::

Other
~~~~

.. cpp:function:: void PrintMenuStack()

    Debugging

Footers
^^^^

To use footers, add this element to your menu:

.. code-block::

	FooterButtons
	{
		ControlName			CNestedPanel
		InheritProperties	FooterButtons
	}

.. cpp:function:: void function AddMenuFooterOption( var menu, int input, string gamepadLabel, string mouseLabel = "", void functionref( var ) activateFunc = null, bool functionref() conditionCheckFunc = null, void functionref( InputDef ) updateFunc = null )

    Adds a footer to a menu.

.. cpp:function:: void function AddPanelFooterOption( var panel, int input, string gamepadLabel, string mouseLabel = "", void functionref( var ) activateFunc = null, bool functionref() conditionCheckFunc = null, void functionref( InputDef ) updateFunc = null )

    Adds a footer to a panel

.. cpp:function:: void UpdateFooterOptions()

    Update the footers of the active menu.

.. cpp:function:: void SetFooterText( var menu, int index, string text )

    Change the text of a specific footer.
