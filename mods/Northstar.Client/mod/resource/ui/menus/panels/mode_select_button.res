resource/ui/menus/panels/mode_select_button.res
{
	BtnMode
	{
		ControlName 			RuiButton
		InheritProperties 		RuiSmallButton
		classname 				ModButton
		labelText				"please show up"
		wide					600
		tall					45

		pin_to_sibling			ControlBox
		pin_corner_to_sibling 	LEFT
		pin_to_sibling_corner 	RIGHT
	}

	Header
	{
		ControlName	Label
		InheritProperties	RuiSmallButton
		wide				600
		labelText			"labelText"
		font				Default_41
		fgcolor_override 	"255 255 255 255"
		tall				45

		pin_to_sibling			ControlBox
		pin_corner_to_sibling 	LEFT
		pin_to_sibling_corner 	RIGHT
	}
}
