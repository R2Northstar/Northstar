# Element Notation


Elements are notated as [VDF](https://developer.valvesoftware.com/wiki/KeyValues)

UI elements are created when a menu is initialized. References to the elements will stay the same, regardless if the menu is open or not.

It is not possible to create elements at runtime so you have to define all elements a menu or panel contains beforehand in appropriate files.

An Element is declared in the following way:

```

    // please follow this structure
    ElementName
    {
        ControlName name
        // optional: classname, inheritance, ids ...

        // optional: other properties

        // optional: pinning
    }
```

If you're working on a **menu**, you need a `menu` object that contains all elements, for example like this:

```

    resource/ui/menus/profiles_menu.menu
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

            // elements
        }
    }
```
It usually doesn't matter if you use quotation marks to assign string values to parameters.

## HUD & Panel files

The first line of a `.menu` or `.res` file needs to be the resource path to itself, starting from the resource folder.

It's not possible to load other files as menus or panels. A `.menu` represents an independant menu of the game, while `.res` files are "Panels" that can be loaded from other elements.

The rest of the file needs to be wrapped in curly brackets.

```

    resource/ui/menus/more/folders/my_menu.menu
    {
        MyObject
        {
            // object properties go here
        }

        // more objects ...
    }
```

### Properties

Capitalization of the properties shouldn't matter.

!!! cpp-function "(ElementName)"

    This isn't a regular property and comes **before** the opening bracket

    Unique string identifier used in scripts to look up an element. Every element is required to have a name.

#### Inheritance / Parenting

!!! cpp-function "ControlName"

    Controls what type of Component the element is and what parameters have an effect. Every element is required to have control name.

!!! cpp-function "InheritProperties"

!!! cpp-function "controlSettingsFile"

    Load a `.res` file. All elements in the settings file are instantiated and set as children of the element.

    `Hud_GetChild` only works if the parent element is (has the `ControlName`) a **CNestedPanel**!

#### Identifying

!!! cpp-function "classname"

    Classname used for identifying groups of elements

!!! cpp-function "scriptID"

    Set an unique integer id for this element that's retrievable in script.

#### Position

!!! cpp-function "xpos"

    Set the base x position relative to the element's sibling position.

    inverted when attached to the left corner or smth

!!! cpp-function "ypos"

    Set the base y position relative to the element's sibling position.

    inverted when attached to the top corner or smth

!!! cpp-function "zpos"

    The layer this element sits in. Elements with a higher z will be prioritized to be selected / focused. They are also drawn on top of elements with a lower z position.

#### Dimensions

!!! cpp-function "wide"

    Set the base width of this element.

!!! cpp-function "tall"

    Set the base height of this element.

!!! cpp-function "scale"

    Float that scales the element.

#### Text

!!! cpp-function "labelText"

    Set the label text of this element, if it is a Label.

!!! cpp-function "textAlignment"

    Controls the element boundary point the element's text gets aligned with. `east` -> Left, `north` -> Top, `west` -> Right, `south` Bottom.

    You can also combine the directions like this: `north-west`.

!!! cpp-function "allcaps"

    Controls if the text of this element is rendered in all caps. Defaults to 0.

!!! cpp-function "font"

    Set the text font of this element.

!!! cpp-function "textinsetx"

!!! cpp-function "textinsety"

!!! cpp-function "dulltext"

!!! cpp-function "brighttext"

!!! cpp-function "textalign"

!!! cpp-function "NoWrap"

    don't wrape text

!!! cpp-function "wrap"

    wrap text from east

!!! cpp-function "centerwrap"

    wrap text from center

!!! cpp-function "keyboardTitle"

!!! cpp-function "keyboardDescription"

!!! cpp-function "selectedFont"

!!! cpp-function "text"

!!! cpp-function "multiline"

    Set if the text input supports multiline input.

!!! cpp-function "use_proportional_insets"


#### Pinning

!!! cpp-function "pin_to_sibling"

    Controls the sibling this element will be pinned to. Takes an element's name as a parameter.

!!! cpp-function "pin_corner_to_sibling"

    Sets which corner of this element is pinned to the sibling.

!!! cpp-function "pin_to_sibling_corner"

    Set to which corner of the sibling this element is pinned to.

!!! cpp-function "pinCorner"

#### Rui

!!! cpp-function "rui"

#### Images

!!! cpp-function "image"

    vgui asset to render

!!! cpp-function "scaleImage"

!!! cpp-function "fg_image"

!!! cpp-function "drawColor"

    apply this color on top. Format is "r g b a".

!!! cpp-function "fillcolor"

    Fill transparent pixels with this color. Format is "r g b a"

#### Navigation

!!! cpp-function "navUp"

!!! cpp-function "navDown"

!!! cpp-function "navLeft"

!!! cpp-function "navRight"

#### Slider

!!! cpp-function "stepSize"

!!! cpp-function "isValueClampedToStepSize"


#### Other

!!! cpp-function "visible"

    Controls if this element is rendered. Defaults to 1.

!!! cpp-function "enable"

    Controls if this element starts enabled. Defaults to 1.

!!! cpp-function "auto_wide_to_contents"

!!! cpp-function "auto_wide_tocontents"

!!! cpp-function "auto_tall_tocontents"

!!! cpp-function "enabled"

    Controls if this element is enabled. Only enabled elements can be focused / selected. Defaults to 1.

!!! cpp-function "destination"

!!! cpp-function "frame"

!!! cpp-function "fieldName"

!!! cpp-function "autoResize"

!!! cpp-function "barCount"

!!! cpp-function "barSpacing"

!!! cpp-function "dialogstyle"

!!! cpp-function "style"

!!! cpp-function "command"

!!! cpp-function "ActivationType"

!!! cpp-function "paintbackground"

!!! cpp-function "tabposition"

!!! cpp-function "activeInputExclusivePaint"

!!! cpp-function "paintborder"

!!! cpp-function "CircularEnabled"

!!! cpp-function "CircularClockwise"

!!! cpp-function "consoleStyle"

!!! cpp-function "unicode"

!!! cpp-function "Default"

!!! cpp-function "selected"

!!! cpp-function "maxchars"

!!! cpp-function "listName"

!!! cpp-function "arrowsVisible"

!!! cpp-function "verifiedColumnWidth"

!!! cpp-function "nameColumnWidth"

!!! cpp-function "totalMembersColumnWidth"

!!! cpp-function "chatBorderThickness"

!!! cpp-function "messageModeAlwaysOn"

!!! cpp-function "interactive"

!!! cpp-function "rowHeight"

!!! cpp-function "nameSpaceX"

!!! cpp-function "nameSpaceY"

!!! cpp-function "micWide"

!!! cpp-function "micTall"

!!! cpp-function "micSpaceX"

!!! cpp-function "micOffsetY"

!!! cpp-function "textHidden"

!!! cpp-function "editable"

!!! cpp-function "NumericInputOnly"

!!! cpp-function "allowRightClickMenu"

!!! cpp-function "allowSpecialCharacters"

!!! cpp-function "SelectedTextColor"

!!! cpp-function "SelectedBgColor"

!!! cpp-function "clip"

!!! cpp-function "teamRelationshipFilter"

!!! cpp-function "activeColumnWidth"

!!! cpp-function "happyHourColumnWidth"

!!! cpp-function "onlinePlayersColumnWidth"

!!! cpp-function "PaintBackgroundType"

    // 0 for normal(opaque), 1 for single texture from Texture1, and 2 for rounded box w/ four corner textures

!!! cpp-function "ConVar"

!!! cpp-function "alpha"

!!! cpp-function "conCommand"

!!! cpp-function "minValue"

!!! cpp-function "maxValue"

!!! cpp-function "inverseFill"

!!! cpp-function "syncedConVar"

!!! cpp-function "showConVarAsFloat"

!!! cpp-function "modal"

!!! cpp-function "headerHeight"

!!! cpp-function "panelBorder"

!!! cpp-function "linespacing"

!!! cpp-function "rightClickEvents"

!!! cpp-function "conCommandDefault"

### Conditional Properties

You can declare properties for specific conditions by adding `[CONDITION]` after the property value.

When putting a condition after an element's name, the element will only be created if the condition evaluates to true.

Usable conditions are:

!!! cpp-function "$WIN32"

    game is running on 32 bit windows

!!! cpp-function "$WINDOWS"

    game is running on windows

!!! cpp-function "$DURANGO"

    game is running on xbox

!!! cpp-function "$PS4"

    game is running on a PS4

!!! cpp-function "$GAMECONSOLE"

!!! cpp-function "$WIDESCREEN_16_9"

    game resolution is 16/9

!!! cpp-function "$LANGUAGE"

    the game's language.

    .. code-block:: text

            // use allcaps only in russian
            allCaps        0  [!$RUSSIAN]
            allCaps        1  [$RUSSIAN]



On top of that, logical operators like `!`, `&&` and `||` are available as well.

#### Example:

```text

    // This element only shows on pc
    IngameTextChat [$WINDOWS]
    {
        ControlName             CBaseHudChat
        InheritProperties       ChatBox

        destination             "match"

        visible                 0

        pin_to_sibling          Screen
        pin_corner_to_sibling   TOP_LEFT
        pin_to_sibling_corner   TOP_LEFT
        xpos                    -45
        ypos                    -616
    }

    // This element has different widths depending on the game resolution
    LoadingTip
    {
        ControlName             Label
        ypos                    10
        wide                    1630 [$WIDESCREEN_16_9]
        wide                    1441 [!$WIDESCREEN_16_9]
        auto_tall_tocontents    1
        labelText               ""
        textalign               "north-west"
        font                    Default_28
        wrap                    1
        fgcolor_override        "217 170 75 255"
        visible                 0

        pin_to_sibling          LoadingGameMode
        pin_corner_to_sibling   TOP_LEFT
        pin_to_sibling_corner   BOTTOM_LEFT
    }

```

### Pinning

!!! cpp-function "CENTER"

    The calculated center of the element

!!! cpp-function "TOP"

    Element's top y bounds, x axis center.

!!! cpp-function "BOTTOM"

    Element's lowest y bounds, x axis center.

!!! cpp-function "LEFT"

    Element's lowest x bounds, y axis center.

!!! cpp-function "RIGHT"

    Element's highest x bounds, y axis center.

!!! cpp-function "TOP_LEFT"

    Top left corner

!!! cpp-function "TOP_RIGHT"

    Top right corner

!!! cpp-function "BOTTOM_LEFT"

    Bottom left corner

!!! cpp-function "BOTTOM_RIGHT"

    Bottom right corner

### Units

You can calculate the position or dimensions etc. with different units. If you provide no extra unit, the game uses pixels.

!!! cpp-function "%x"

    x percent of the screen.

    .. code:block::

        // cover the entire screen
        width   %100
        height  %100

!!! cpp-function "fx"

    use 100%

!!! cpp-function "c+/-x"

    something with the screen edges not exactly sure how positions get calculated

### Including KeyValues

To include another KeyValue file, use `#base "filepath"` at the top of a VDF file.
