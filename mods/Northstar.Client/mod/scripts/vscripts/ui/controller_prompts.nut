global function PrependControllerPrompts

// Returns the string that gets turned into a controller prompt image in the front-end
string function ControllerButtonToStr( int buttonID )
{
	switch (buttonID)
	{
		case BUTTON_Y:
			return "%[Y_BUTTON|]%"
		case BUTTON_X:
			return "%[X_BUTTON|]%"
	}
	unreachable
}

string function PrependControllerPrompts( int buttonID, string localizationKey )
{
	return ControllerButtonToStr( buttonID ) + " " + Localize(localizationKey)
}
