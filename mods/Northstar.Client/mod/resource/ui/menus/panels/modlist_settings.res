resource/ui/menus/panels/modlist_setting.res
{
	BtnMod
	{
		ControlName 			RuiButton
		InheritProperties 		RuiSmallButton
		classname 				ModButton
		labelText				"please show up"
		
		pin_to_sibling			ControlBox
		pin_corner_to_sibling 	LEFT
		pin_to_sibling_corner 	RIGHT
	}

	Header
	{
		ControlName	Label
		wide		400
		labelText	"labelText"

		pin_to_sibling			ControlBox
		pin_corner_to_sibling 	LEFT
		pin_to_sibling_corner 	RIGHT
	}

	ControlBox
	{
		ControlName				RuiPanel
		classname 				ControlBox

		tall					30
		wide					5
		ypos					5
		rui 					"ui/basic_image.rpak"

		pin_corner_to_sibling	LEFT
		pin_to_sibling_corner	LEFT
	}

	BottomLine
	{
		ControlName 			ImagePanel
		InheritProperties		MenuTopBar
		ypos					0
		wide 					%50

		pin_to_sibling			BtnMod
		pin_corner_to_sibling 	TOP_LEFT
		pin_to_sibling_corner 	BOTTOM_LEFT
	}

	WarningImage
	{
		ControlName	RuiPanel

		rui		ui/basic_image.rpak
		wide	30
		tall	30
		visible	0

		pin_to_sibling			BtnMod
		pin_corner_to_sibling	LEFT
		pin_to_sibling_corner	RIGHT
	}

	EnabledImage
	{
		ControlName	RuiPanel

		rui		ui/basic_image.rpak
		wide	30
		tall	30
		visible	0

		pin_to_sibling			BtnMod
		pin_corner_to_sibling	RIGHT
		pin_to_sibling_corner	LEFT
	}
}
