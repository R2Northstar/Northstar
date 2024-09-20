# Dialogs

Dialogs are a way for a client to open a text window with up to 4 buttons.

## Dialog structs

All the data in the struct that can be changed.

!!! cpp-struct "DialogData"


    !!! cpp-var "var menu"

         The instance of the menu
    !!! cpp-var "string header"

         The headline of the dialog
    !!! cpp-var "string message"

         The body of text under the headline, it supports newline with `\n`
    !!! cpp-var "DialogMessageRuiData &ruiMessage"

         Stores relevant RUI data
    !!! cpp-var "array<int> messageColor = [161, 161, 161, 255]"

        The colour of the message body, in the format of RGBA
    !!! cpp-var "string image"

         Path to the asset of the image displayed on the left of the text body
    !!! cpp-var "string rightImage = $"""

         Path to the asset of the image displayed on the right of the text body
    !!! cpp-var "bool forceChoice = false"

         unknown
    !!! cpp-var "bool noChoice = false"

         unknown
    !!! cpp-var "bool noChoiceWithNavigateBack = false"

         unknown
    !!! cpp-var "bool showSpinner = false"

         Sets the left image as an animated spinner
    !!! cpp-var "bool showPCBackButton = false"

         Shows an additional button below all other buttons that closes the dialog for the client when pressed, works the same as pressing the `esc` button
    !!! cpp-var "float inputDisableTime = 0"

         How long it takes before the client is able to press a button
    !!! cpp-var "table<int,bool> coloredButton"

         The int is the index of the Button
    !!! cpp-var "bool darkenBackground = false"

         Darkens the colour of the dialog window slightly
    !!! cpp-var "bool useFullMessageHeight = false"

         Creates a larger dialog window even if there is no text or buttons to fill that space
    !!! cpp-var "array<DialogButtonData> buttonData"

         Stores the information added by the `AddDialogButton` function
    !!! cpp-var "array<DialogFooterData> footerData"

         Stores the information added by the `AddDialogFooter` function

!!! cpp-struct "DialogMessageRuiData"

    !!! cpp-var "string message = """
    !!! cpp-var "vector style1Color = <1.0, 1.0, 1.0>"
    !!! cpp-var "vector style2Color = <0.5, 0.5, 0.5>"
    !!! cpp-var "vector style3Color = <0.5, 0.5, 0.5>"
    !!! cpp-var "float style1FontScale = 1.0"
    !!! cpp-var "float style2FontScale = 1.0"
    !!! cpp-var "float style3FontScale = 1.0"

!!! cpp-struct "DialogButtonData"

    !!! cpp-var "string label"
    !!! cpp-var "void functionref() activateFunc"
    !!! cpp-var "string focusMessage"
    !!! cpp-var "bool startFocused"

!!! cpp-struct "DialogFooterData"

    !!! cpp-var "string label"
    !!! cpp-var "void functionref() activateFunc"


## Functions

!!! cpp-function "void OpenDialog( DialogData dialog )"

    Shows the local player the dialog with the data from the struct.

    - `DialogData dialog` Instance of a DialogData struct

    **Example**

    ```squirrel
    DialogData dialog
    dialog.message = "Hello there"
    OpenDialog( dialog )
    ```

!!! cpp-function "void AddDialogButton( DialogData dialog, string text, void functionref() callback )"

    Add one button to the given struct

    - `DialogData dialog` Instance of a DialogData struct

    - `string text` The Text that is shown on the button, supports some assets with `%ASSET PATH%`

    - `void functionref() callback` Function that is executed when the button is pressed.

    **Example**

    ```squirrel
    void function SendDialogWithButton()
    {
        DialogData dialog
        dialog.message = "Hello there"
        AddDialogButton(dialog, "Button 1 %%$r2_ui/menus/loadout_icons/primary_weapon/primary_kraber%%", void function():() {
            printt( "pressed button 1" )
        })
        OpenDialog( dialog )
    }
    ```

!!! cpp-function "void AddDialogFooter( DialogData dialog, string text )"

    Adds a footer to the dialog struct

    - `DialogData dialog` Instance of a DialogData struct

    - `string text` The Text that is shown on the button, supports some assets with `%ASSET PATH%`


!!! cpp-function "bool IsDialogActive( DialogData dialogData )"

    - `DialogData dialog` Instance of a DialogData struct

    - Returns: `true` if the dialog with that struct is currently open, otherwise it returns `false`

!!! cpp-function "void OpenErrorDialog( string errorDetails )"

    - `string errorDetails` User facing information about the error
## Code example

the folowing code produces this output:

```squirrel
DialogData dialog
dialog.header = "This is the header"
dialog.message = "this is the body, it is green \n \n Hello There \n \n General Kenobi"
dialog.messageColor = [0,200,0,100]
dialog.showSpinner = true
dialog.showPCBackButton = true
AddDialogButton( dialog, "Button 1 %%$r2_ui/menus/loadout_icons/primary_weapon/primary_kraber%%", ButtonOnePressed )
OpenDialog( dialog )
```


<figure class="screenshotalign-center">
<img src="/_static/serverdialog/dialogexample.png" class="screenshot"
alt="/_static/serverdialog/dialogexample.png" />
</figure>
