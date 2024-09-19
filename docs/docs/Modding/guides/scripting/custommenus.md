# Creating a custom Menu

This tutorial will explain how to create a mod that adds a new menu that's viewable by a footer in the main menu.

## Setup

First, create a new folder with this `mod.json`:

```json

    {
        "Name": "CustomMenuTutorial",
        "Description": "Custom menu tutorial",
        "LoadPriority": 1,
        "Scripts": [
            {
                "Path": "ui/custom_menu.nut",
                "RunOn": "UI",
                "UICallback": {
                    "Before": "AddCustomMenu"
                }
            }
        ]
    }
```

Then create `custom_menu.nut` in `./mod/scripts/vscripts/ui`.

## Minimal Example

Create `AddCustomMenu` in `custom_menu.nut` like this and make it global:

```squirrel

    global function AddCustomMenu

    void function AddCustomMenu()
    {
        AddMenu( "CustomMenu", $"resource/ui/menus/custommenu.menu", CustomMenu_Init )
    }
```

`AddCustomMenu` will get called when the UI vm is initializing and instantiate your menu. You can access your menu with `GetMenu( "CustomMenu" )` after it has been initialized.

Next, create the file that defines the layout of your menu. It's already referenced in the above code at `$"resource/ui/menus/custommenu.menu"`. Create the file `./mod/resource/ui/menus/custommenu.menu` and paste this code in it.

??? ".menu configuration"

    ```

        resource/ui/menus/custommenu.menu
        {
            menu
            {
                ControlName Frame
                xpos 0
                ypos 0
                zpos 3
                wide f0
                tall f0
                autoResize 0
                visible 1
                enabled 1
                pinCorner 0
                PaintBackgroundType 0
                infocus_bgcolor_override "0 0 0 0"
                outoffocus_bgcolor_override "0 0 0 0"

                Vignette // Darkened frame edges
                {
                    ControlName ImagePanel
                    InheritProperties MenuVignette
                }

                Title // The title of this menu
                {
                    ControlName Label
                    InheritProperties MenuTitle
                    labelText "#CUSTOM_MENU_TITLE"
                }


        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        /// Content
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                SomeLabel // A label that is placed in the middle of the screen
                {
                    ControlName Label

                    labelText "Some Label"

                    auto_wide_tocontents 1 // Set width automatically relative to the label content

                    xpos %50
                    ypos %50
                }

                SomeButton // A button that is placed directly beneath the label
                {
                    ControlName RuiButton
                    InheritProperties RuiSmallButton

                    tall 50
                    wide 250

                    labelText "Some Button"
                    textAlignment center

                    pin_to_sibling SomeLabel
                    pin_corner_to_sibling TOP
                    pin_to_sibling_corner BOTTOM
                }

        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        /// Footer
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                FooterButtons // Allow adding footers to this menu
                {
                    ControlName   CNestedPanel
                    InheritProperties FooterButtons
                }
            }
        }
    ```

Now you'll need to define `CustomMenu_Init`. This is the function previously defined that contains all initializations needed for this menu.

First, create an instantiated struct for variables that should be available in the scope of your custom menu script.

```squirrel

    struct {
        var menu
    } file
```

At the moment, this struct can only contain your menu. To set it, edit `AddCustomMenu` like this:

```diff

     void function AddCustomMenu()
     {
        AddMenu( "CustomMenu", $"resource/ui/menus/custommenu.menu", CustomMenu_Init )
+       file.menu = GetMenu( "CustomMenu" )
     }
```

Now, define `CustomMenu_Init`. It doesn't need to be global.

```squirrel

    void function CustomMenu_Init()
    {
        AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
    }
```

This adds a footer to your menu, that allows the user to navigate back.

## Adding a footer to the Main menu

Currently, there is no way to access your menu. You can open your (or any other menu) with `AdvanceMenu`.

```squirrel

    AdvanceMenu( GetMenu( "CustomMenu" ) )
```

This is useful for callbacks triggered by button presses like from footers. To add a footer to the Main menu, first edit your `mod.json` code callbacks:

```diff

     "Scripts": [
        {
            "Path": "ui/custom_menu.nut",
            "RunOn": "UI",
            "UICallback": {
+               "Before": "AddCustomMenu", // <- Notice the added comma
+               "After": "AddCustomMenuFooter"
            }
        }
     ]
```

We need a new callback that's run after all menus are initialized to add any footers to them. Create the global function `AddCustomMenuFooter` in `custom_menu.nut` like this:

```squirrel

    void function AddCustomMenuFooter()
    {
        AddMenuFooterOption(
            GetMenu( "MainMenu" ), // Get the main menu. We want to add a footer to this one. Change this if you want to add a footer to another menu
            BUTTON_X, // This sets the gamepad button that will trigger the click callback defined later
            PrependControllerPrompts( BUTTON_X, " Custom Menu" ), // This is the text that will show as the label of the footer if a gamepad is used
            "Custom Menu", // This is the label text of the footer if no gamepad is used
            void function( var button ) // This is the click callback.
            {
                /*
                    This is an anonymous function.
                    It will be run every time the footer is pressed.
                */
                AdvanceMenu( file.menu )
            }
        )
    }
```

## Scripting Menu Logic

### Adding a Counter

We'll use the button we defined earlier in the `.menu` file to increase a number of clicks and the label to show how often the user has clicked that button.

first, add `someLabel` and `clicks` to the `file` struct. Then define the label in the `AddCustomMenu` and add a callback to the button.

```diff

     struct {
        var menu
+           var someLabel
+           int clicks
     } file

     void function AddCustomMenu()
     {
        AddMenu( "CustomMenu", $"resource/ui/menus/custommenu.menu", CustomMenu_Init )
        file.menu = GetMenu( "CustomMenu" )
+       file.someLabel = Hud_GetChild( file.menu, "SomeLabel" )

+       var someButton = Hud_GetChild( file.menu, "SomeButton" )
+       Hud_AddEventHandler( someButton, UIE_CLICK, OnSomeButtonClick )
     }
```

Now you need to define the `OnSomeButtonClick` callback that's triggered when the button is activated.

```squirrel

    void function OnSomeButtonClick( var button )
    {
        file.clicks++
        Hud_SetText( file.someLabel, format( "clicked the button %i times", file.clicks ) )
    }
```

### Adding a Reset Button

First you need to add a definition in your `custommenu.menu` file:

```

    ResetButton
    {
        ControlName RuiButton
        InheritProperties RuiSmallButton

        tall 50
        wide 250

        labelText "Reset Counter"
        textAlignment center

        pin_to_sibling SomeButton
        pin_corner_to_sibling TOP
        pin_to_sibling_corner BOTTOM
    }
```

Then add a `UIE_CLICK` callback for the button. It also makes sense to move the code that updates the label text to it's own function so it can be reused by the reset button.

```diff

     void function AddCustomMenu()
     {
        AddMenu( "CustomMenu", $"resource/ui/menus/custommenu.menu", CustomMenu_Init )
        file.menu = GetMenu( "CustomMenu" )
        file.someLabel = Hud_GetChild( file.menu, "SomeLabel" )

        var someButton = Hud_GetChild( file.menu, "SomeButton" )
+       var resetButton = Hud_GetChild( file.menu, "ResetButton" )

        Hud_AddEventHandler( someButton, UIE_CLICK, OnSomeButtonClick )
+       Hud_AddEventHandler( resetButton, UIE_CLICK, OnResetButtonClick )
     }

     void function OnSomeButtonClick( var button )
     {
        file.clicks++
    -   Hud_SetText( file.someLabel, format( "clicked the button %i times", file.clicks ) )
+       UpdateClickLabel()
     }

     void function OnResetButtonClick( var button )
     {
        file.clicks = 0
+       UpdateClickLabel()
     }

+   void function UpdateClickLabel()
+   {
+       Hud_SetText( file.someLabel, format( "clicked the button %i times", file.clicks ) )
+   }
```

### Resetting the Counter when the Menu is closed

You can add callbacks for menu events, for example when a menu is closed or opened.

If you want to reset the counter if the menu is closed, edit `AddCustomMenu` like this:

```diff

     void function AddCustomMenu()
     {
        AddMenu( "CustomMenu", $"resource/ui/menus/custommenu.menu", CustomMenu_Init )
        file.menu = GetMenu( "CustomMenu" )
        file.someLabel = Hud_GetChild( file.menu, "SomeLabel" )

        var someButton = Hud_GetChild( file.menu, "SomeButton" )
        var resetButton = Hud_GetChild( file.menu, "ResetButton" )

        Hud_AddEventHandler( someButton, UIE_CLICK, OnSomeButtonClick )
        Hud_AddEventHandler( resetButton, UIE_CLICK, OnResetButtonClick )

+       AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnCloseCustomMenu )
     }
```

And define the callback `OnCloseCustomMenu` to simply call `OnResetButtonClick`.

```squirrel

    void function OnCloseCustomMenu()
    {
        OnResetButtonClick( null )
    }
```
