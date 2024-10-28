# HUD elements in Scripts

Script methods to manipulate hud elements.

## Element Tree & Locating Elements

!!! cpp-function "string Hud_GetHudName( var menu )"

!!! cpp-function "var GetParentMenu( var elem )"

    Returns a reference to the menu the passed element is parented to

!!! cpp-function "var Hud_GetParent( var elem )"

    Returns the next higher parent of the element

!!! cpp-function "bool Hud_HasChild( var elem, string childName )"

    Returns `true` if the element has a child named like `childName`

!!! cpp-function "var Hud_GetChild( var elem, string childName )"

    Returns the child element of the passed element named like `childName`

!!! cpp-function "array<var> GetElementsByClassname( var elem, string className )"

    Returns all children that have the given class

!!! cpp-function "var GetElem( var menu, string elementName )"

!!! cpp-function "var Hud_GetScriptID( var elem )"

    Returns the script ID of the element declared in the .menu file

!!! cpp-function "var GetFocus()"

    Returns the currently focused element.

### Element Position

!!! cpp-function "void Hud_SetPos( var elem, int x, int y )"

    Set the position of the element **relative** to the base position.

!!! cpp-function "var Hud_GetPos( var elem )"

    Returns an array of type `int[2]` as a `var`. The position is **relative** to the element's base position.

!!! cpp-function "void Hud_SetX( var elem, int x )"

    Only change the x position relative to the base position.

!!! cpp-function "void Hud_SetY( var elem, int y )"

    Only change the y position relative to the base position.

!!! cpp-function "int Hud_GetX( var elem )"

    Returns the x position of the element relative to it's base position.

!!! cpp-function "int Hud_GetY( var elem )"

    Returns the y position of the element relative to it's base position.

!!! cpp-function "void Hud_ReturnToBasePos( var elem )"

    Set the position of this element to it's base position.

!!! cpp-function "var Hud_GetBasePos( var elem )"

    Returns an orray of type `int[2]` as a `var`. Base position is always `[0,0]`

!!! cpp-function "int Hud_GetBaseX( var elem )"

    Returns the base x of this element.

!!! cpp-function "var Hud_GetBaseY( var elem )"

    Returns the base y of this element.

!!! cpp-function "var Hud_GetAbsPos( var elem )"

    Returns an array of type `int[2]` as a `var`. Absolute coordinates on the screen of this element.

!!! cpp-function "int Hud_GetAbsX( var elem )"

    Returns the absolute x position on the screen of this element.

!!! cpp-function "int Hud_GetAbsY( var elem )"

    Returns the absolute y position of the screen of this element.

!!! cpp-function "void Hud_SetXOverTime( var elem, int x, float transitionTime, int interpolation_mode "= 0 )

    Move to relative x over time with interpolation.

    * `INTERPOLATOR_LINEAR`: linear interpolation

    * `INTERPOLATOR_ACCEL`: move with accelerating speed

    * `INTERPOLATOR_DEACCEL`: move with deaccelerating speed

    * `INTERPOLATOR_PULSE`: one time bounce

    * `INTERPOLATOR_FLICKER`: no transition

    * `INTERPOLATOR_SIMPLESPLINE`: ease in / out

    * `INTERPOLATOR_BOUNCE`: gravitational bounce

!!! cpp-function "void Hud_SetYOverTime( var elem, int y, float transitionTime, int interpolation_mode "= 0 )

    Move to relative y over time with interpolation

!!! cpp-function "void Hud_MoveOverTime( var elem, int x, int y, float transitionTime, int "interpolation_mode = 0 )

!!! cpp-function "float Hud_GetRotation( var elem )"

    Returns the angles of the element

!!! cpp-function "void Hud_SetRotation( var elem, float angles )"

    Set the angles of the element

!!! cpp-function "void Hud_SetPinSibling( var elem, string sibling_name )"

    Only change the sibling pinned to

## Visibility & Color

!!! cpp-function "void Hud_Show( var elem )"

    Make this element visible

!!! cpp-function "void Hud_Hide( var elem )"

    Make this element invisible

!!! cpp-function "bool Hud_IsVisible( var elem )"

    Returns `true` if the element is visible

!!! cpp-function "void Hud_SetVisible( var elem, bool visible )"

    Set if the element is visible

!!! cpp-function "void Hud_SetColor( var elem, int r, int g, int b, int alpha )"

    Set the color of the element

!!! cpp-function "void Hud_ColorOverTime( var elem, int r, int g, int b, int alpha, float time, int "accel )

    Change the color of the element over time

!!! cpp-function "void Hud_ColorOverTimeDelayed( var elem, int r, int g, int b, int alpha, float "time, ,float delay, int accel )

    Change the color of the element over time

!!! cpp-function "void Hud_SetAlpha( var elem, int alpha )"

    Change the opacity of the element

!!! cpp-function "var Hud_GetBaseColor( var elem )"

!!! cpp-function "var Hud_GetBaseAlpha( var elem )"

!!! cpp-function "void Hud_SetPanelAlpha( var elem )"

!!! cpp-function "void Hud_FadeOverTime( var elem, int fadeTarget, float fadeTime )"

    Change the opacity of the element over time

!!! cpp-function "void Hud_FadeOverTimeDelayed( var elem, int target, float delay, float accel )"

    Change the opacity of the element over time after a delay

## Element Dimensions

!!! cpp-function "int Hud_GetWidth( var elem )"

    Returns the current width of the element.

!!! cpp-function "void Hud_SetWidth( var elem, int width )"

    Set the width of an element.

!!! cpp-function "int Hud_GetBaseWidth( var elem )"

    Returns the width an element got initialized with.

!!! cpp-function "int Hud_GetHeight( var elem )"

    Returns the current height of an element.

!!! cpp-function "void Hud_SetHeight( var elem, int height )"

    Set the height of an element.

!!! cpp-function "int Hud_GetBaseHeight( var elem )"

    Returns the height an element got initialized with.

!!! cpp-function "var Hud_GetSize( var elem )"

    Returns an array of type `int[2]` as a `var`. The first index is width and the second height of the element.

!!! cpp-function "void Hud_SetSize( var elem, int x, int y )"

    Set width and height of the element.

!!! cpp-function "var Hud_GetBaseSize( var elem )"

    Returns the width and height values the element got initialized with as an array of type `int[2]` as `var`.

!!! cpp-function "void Hud_ScaleOverTime( var elem, float width_factor, float height_factor, float "time, int interpolation_mode )

    Set the width and height of the element over time.

    The final width and height is calculated like this: `width * width_factor`

!!! cpp-function "void Hud_SetScaleX( var elem, float xStretch )"

    Set the width of the element calculated with a factor.

!!! cpp-function "void Hud_SetScaleY( var elem, float yStretch )"

    Set the height of the element calculated with a factor.

!!! cpp-function "void Hud_ReturnToBaseSize( var elem )"

    Return to base width and height

## Text

!!! cpp-function "void Hud_SetText( var elem, string text )"

    Set the text content of this element

!!! cpp-function "string Hud_GetText( var elem )"

    Returns the current text of the element. Useful for text inputs

!!! cpp-function "void RHud_SetText( var elem, string text )"

    Set the text of an rui, if the element contains an rui that takes string input.

!!! cpp-function "void Hud_SetUTF8Text( var elem, string text )"

!!! cpp-function "string Hud_GetUTF8Text( var elem )"

## Element Status

!!! cpp-function "bool Hud_IsLocked( var elem )"

    Returns `true` if the element is locked.

    Locked elements are visible, can be focused and selected but don't trigger events and play a locked sound if they are selected

!!! cpp-function "void Hud_SetLocked( var elem, bool locked )"

    Set this element locked status

!!! cpp-function "bool Hud_IsEnabled( var elem )"

    Returns `true` if the element is enabled

    Disabled elements are visible but can't be focused or selected and don't trigger events.

!!! cpp-function "void Hud_SetEnabled( var elem, bool enabled )"

    Set this element to be enabled / disabled

!!! cpp-function "bool Hud_IsFocused( var elem )"

    Returns `true` if this element is focused

    Focused elements will be selected when pressing enter

!!! cpp-function "void Hud_SetFocused( var elem )"

    Set the element to be focused

!!! cpp-function "bool Hud_IsSelected( var elem )"

    Returns `true` if this element is selected

!!! cpp-function "void Hud_SetSelected( var elem, bool selected )"

    Set this element to be selected / not unselected

!!! cpp-function "void Hud_SelectAll( var elem )"

    Select this element and all children

!!! cpp-function "bool Hud_IsLabel( var elem )"

    Returns `true` if the element is a label

## Element RUI

!!! cpp-function "bool Hud_IsRuiPanel( var elem )"

    Returns `true` if this element can contain ruis

!!! cpp-function "var Hud_GetRui( var elem )"

    Returns the rui instance of this element.

## Navigation

!!! cpp-function "void Hud_SetNavUp( var elem, var navTo )"

    Set the element that will be selected when navigating up (arrow up) from this selected element.

!!! cpp-function "void Hud_SetNavDown( var elem, var navTo )"

    Set the element that will be selected when navigating up (arrow up) from this selected element.

!!! cpp-function "void Hud_SetNavLeft( var elem, var navTo )"

    Set the element that will be selected when navigating left (arrow left) from this selected element.

!!! cpp-function "void Hud_SetNavRight( var elem, var navTo )"

    Set the element that will be selected when navigating right (arrow right) from this selected element.

## Events

!!! cpp-function "void Hud_HandleEvent( var elem, int event )"

    Fire the specified event for the element

!!! cpp-function "var Hud_AddEventHandler( var elem, int event, var functionref( var button ) )"

    Handle an event for the element

    Accepted events:

    * `UIE_CLICK`

    * `UIE_GET_FOCUS`

    * `UIE_LOSE_FOCUS`

    * `UIE_CHANGE`

## Other Visuals

!!! cpp-function "void Hud_SetNew( var elem, bool isNew )"

!!! cpp-function "void Hud_SetImage( var elem, asset image )"

    Set the image displayed by the element, if the elements controlName allows for it.

!!! cpp-function "void Hud_EnableKeyBindingIcons( var elem )"

!!! cpp-function "void Hud_RunAnimationScript( var elem, string animation )"

## Slider

!!! cpp-function "void Hud_SliderControl_SetStepSize( var elem, float size )"

!!! cpp-function "void Hud_SliderControl_SetMin( var elem, float min )"

!!! cpp-function "void Hud_SliderControl_SetMax( var elem, float max )"

!!! cpp-function "float Hud_SliderControl_GetCurrentValue( var elem )"

## Graphs

!!! cpp-function "void Hud_SetBarProgress( var elem, float progress )"

## Client Settings

!!! cpp-function "void Hud_SetGamemodeIdx( var elem, int index )"

!!! cpp-function "void Hud_SetPlaylistVarName( var elem, string playlist )"

## Uncategorized

!!! cpp-function "void Hud_DialogList_AddListItem( var elem, string val, string enum_ )"

!!! cpp-function "string Hud_GetListPanelSelectedItem( var elem )"

