"resource/ui/menus/panels/mod_setting.res"
{
	"FULL"
	{
		"ControlName"			"Label"
		"classname"				"ConnectingHUD"
		"xpos"					"0"
		"ypos"					"0"
		"zpos"					"99"
		"wide"					"1200"
		"tall"					"45"
		"labelText"				""
		"bgcolor_override"		"0 0 0 0"
		"visible"				"0"
		"paintbackground"		"1"
	}
	"BtnMod"
	{
		"ControlName" "Label"
		"InheritProperties" "RuiSmallButton"
		"labelText" "Mod"
		//"auto_wide_tocontents" "1"
		"navRight" "EnumSelectButton"
		"navLeft" "TextEntrySetting"
		"wide" "390"
		"tall" "45"
	}
	// we're getting to the top of this :)
	"TopLine"
	{
		"ControlName" "ImagePanel"
		"InheritProperties" "MenuTopBar"
		"ypos" "0"
		"wide" "%100"
		"pin_to_sibling" "BtnMod"
		"pin_corner_to_sibling" "TOP_LEFT"
		"pin_to_sibling_corner" "TOP_LEFT"
	}
	"ModTitle"
	{
		"ControlName" "Label"
		"InheritProperties" "RuiSmallButton"
		"labelText" "Mod"
		"font"		"DefaultBold_43"
		//"auto_wide_tocontents" "1"
		"zpos"	"-999"
		"textAlignment"				"center"
		"navRight" "EnumSelectButton"
		"navLeft" "TextEntrySetting"
		"wide" "1200"
		"tall" "45"

	}
	"Slider"
	{
		"ControlName"			"SliderControl"
		//"InheritProperties"	"RuiSmallButton"
		minValue				0.0
		maxValue				2.0
		stepSize				0.05
		"pin_to_sibling" "BtnMod"
		"pin_corner_to_sibling" "TOP_LEFT"
		"pin_to_sibling_corner" "TOP_RIGHT"
		"navRight" "ResetModToDefault"
		"navLeft" "TextEntrySetting"
		//isValueClampedToStepSize 1
		BtnDropButton
		{
			ControlName				RuiButton
			//InheritProperties		WideButton
			style					SliderButton
			"wide"		"320"
			"tall"		"45"
			"labelText"		""
			"auto_wide_tocontents"		"0"
		}
		"wide"		"320"
		"tall"		"45"
	}
	"EnumSelectButton"
	{
		"ControlName" "RuiButton"
		"InheritProperties" "RuiSmallButton"
		"style" "DialogListButton"
		"labelText" ""
		"zpos" "4"
		"wide" "225"
		"tall" "45"
		//"xpos"		"10"
		"scriptID" "0"
		"pin_to_sibling" "FULL"
		"pin_corner_to_sibling" "RIGHT"
		"pin_to_sibling_corner" "RIGHT"
		"navLeft" "ResetModToDefault"
		"navRight" "TextEntrySetting"
	}
	"ResetModToDefault"
	{
		"ControlName" "RuiButton"
		"InheritProperties" "RuiSmallButton"
		"labelText" ""
		"zpos" "0"
		"xpos" "10"
		"wide" "45"
		"tall" "45"
		"scriptID" "0"
		"pin_to_sibling" "EnumSelectButton"
		"pin_corner_to_sibling" "RIGHT"
		"pin_to_sibling_corner" "LEFT"
		"navLeft" "Slider"
		"navRight" "TextEntrySetting"
	}
	"ResetModImage"
	{
		"ControlName" "ImagePanel"
		"image" "vgui/reset"
		"scaleImage" "1"
		"drawColor" "180 180 180 255" // vanilla label color
		"visible" "0"
		"wide" "30"
		"tall" "30"
		"enabled"	"0"
		
		"pin_to_sibling" "ResetModToDefault"
		"pin_corner_to_sibling" "CENTER"
		"pin_to_sibling_corner" "CENTER"
	}
	"OpenCustomMenu"
	{
		"ControlName" "RuiButton"
		"InheritProperties" "RuiSmallButton"
		"labelText" "Open"
		//"auto_wide_tocontents"	"1"
		"zpos" "4"
		"wide" "1200"
		"textAlignment"	"center"
		//"font"		"Default_41"
		//"xpos"		"10"
		"tall" "40"
		"scriptID" "0"
		"visible"	"0"
		"pin_to_sibling" "FULL"
		"pin_corner_to_sibling" "RIGHT"
		"pin_to_sibling_corner" "RIGHT"
		"navLeft" "TextEntrySetting"
		"navRight" "TextEntrySetting"
	}
	"TextEntrySetting"
	{
		"ControlName" "TextEntry"
		"classname" "MatchSettingTextEntry"
		//"xpos" "-35"
		//"ypos" "-5"
		"zpos" "100"	// This works around input weirdness when the control is constructed by code instead of VGUI blackbox.
		"wide" "160"
		"tall" "30"
		"scriptID" "0"
		"textHidden" "0"
		"editable" "1"
		// NumericInputOnly 1
		"font" "Default_21"
		"allowRightClickMenu" "0"
		"allowSpecialCharacters" "1"
		"unicode" "0"
		"pin_to_sibling" "EnumSelectButton"
		"pin_corner_to_sibling" "CENTER"
		"pin_to_sibling_corner" "CENTER"
		"navLeft" "EnumSelectButton"
		"navRight" "EnumSelectButton"
	}
	// we're getting to the bottom of this :)
	"BottomLine"
	{
		"ControlName" "ImagePanel"
		"InheritProperties" "MenuTopBar"
		"ypos" "5"
		"wide" "%100"
		//"tall"	"0"
		"pin_to_sibling" "FULL"
		"pin_corner_to_sibling" "BOTTOM_LEFT"
		"pin_to_sibling_corner" "BOTTOM_LEFT"
	}
}
