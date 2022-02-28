"resource/ui/menus/panels/map_grid.res"
{
	GridInfo0x0
	{
		ControlName CNestedPanel
		wide 286
		tall 165
		
		Classname MapGridInfo
		scriptID 0
		
		controlSettingsFile "resource/ui/menus/panels/map_grid_button.res"
	}
	
	GridInfo1x0
	{
		ControlName CNestedPanel
		wide 286
		tall 165
		xpos 2
		
		Classname MapGridInfo
		scriptID 1
		
		controlSettingsFile "resource/ui/menus/panels/map_grid_button.res"
		

		pin_to_sibling GridInfo0x0
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
	}
	
	GridInfo2x0
	{
		ControlName CNestedPanel
		wide 286
		tall 165
		xpos 2

		Classname MapGridInfo
		scriptID 2
		
		controlSettingsFile "resource/ui/menus/panels/map_grid_button.res"
		
    
		pin_to_sibling GridInfo1x0
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
	}
	
	GridInfo0x1
	{
		ControlName CNestedPanel
		wide 286
		tall 165
		ypos 2
		
		Classname MapGridInfo
		scriptID 3
		
		controlSettingsFile "resource/ui/menus/panels/map_grid_button.res"
		
    
		pin_to_sibling GridInfo0x0
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT
	}
	
	GridInfo1x1
	{
		ControlName CNestedPanel
		wide 286
		tall 165
		xpos 2
		
		Classname MapGridInfo
		scriptID 4
		
		controlSettingsFile "resource/ui/menus/panels/map_grid_button.res"
		

		pin_to_sibling GridInfo0x1
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
	}
	
	GridInfo2x1
	{
		ControlName CNestedPanel
		wide 286
		tall 165
		xpos 2
		

		Classname MapGridInfo
		scriptID 5
		
		controlSettingsFile "resource/ui/menus/panels/map_grid_button.res"
		

		pin_to_sibling GridInfo1x1
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
	}
	
	GridInfo0x2
	{
		ControlName CNestedPanel
		wide 286
		tall 165
		ypos 2
		

		Classname MapGridInfo
		scriptID 6
		
		controlSettingsFile "resource/ui/menus/panels/map_grid_button.res"
		

		pin_to_sibling GridInfo0x1
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT
	}
	
	GridInfo1x2
	{
		ControlName CNestedPanel
		wide 286
		tall 165
		xpos 2
		

		Classname MapGridInfo
		scriptID 7
		
		controlSettingsFile "resource/ui/menus/panels/map_grid_button.res"
		

		pin_to_sibling GridInfo0x2
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
	}
	
	GridInfo2x2
	{
		ControlName CNestedPanel
		wide 286
		tall 165
		xpos 2
		

		Classname MapGridInfo
		scriptID 8
		
		controlSettingsFile "resource/ui/menus/panels/map_grid_button.res"
		

		pin_to_sibling GridInfo1x2
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
	}
	
	GridInfo0x3
	{
		ControlName CNestedPanel
		wide 286
		tall 165
		ypos 2
		

		Classname MapGridInfo
		scriptID 9
		
		controlSettingsFile "resource/ui/menus/panels/map_grid_button.res"
		

		pin_to_sibling GridInfo0x2
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT
	}
	
	GridInfo1x3
	{
		ControlName CNestedPanel
		wide 286
		tall 165
		xpos 2
		

		Classname MapGridInfo
		scriptID 10
		
		controlSettingsFile "resource/ui/menus/panels/map_grid_button.res"
		

		pin_to_sibling GridInfo0x3
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
	}
	
	GridInfo2x3
	{
		ControlName CNestedPanel
		wide 286
		tall 165
		xpos 2
		

		Classname MapGridInfo
		scriptID 11
		
		controlSettingsFile "resource/ui/menus/panels/map_grid_button.res"
		

		pin_to_sibling GridInfo1x3
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
	}
	
//--------------------------------------------------------------------
	
	GridButton0x0
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		wide 286
		tall 165
		
		Classname MapGridButtons
		scriptID 0
		
		navDown GridButton0x1
		navRight GridButton1x0
		navUp DummyTop
	}
	
	GridButton1x0
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		wide 286
		tall 165
		xpos 2
		
		Classname MapGridButtons
		scriptID 1
		
		pin_to_sibling GridButton0x0
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
		
		navDown GridButton1x1
		navRight GridButton2x0
		navLeft GridButton0x0
		navUp DummyTop
	}
	
	GridButton2x0
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		wide 286
		tall 165
		xpos 2
		
		Classname MapGridButtons
		scriptID 2
		
		pin_to_sibling GridButton1x0
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
		
		navDown GridButton2x1
		navLeft GridButton1x0
		navUp DummyTop
	}
	
	GridButton0x1
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		wide 286
		tall 165
		ypos 2
		
		Classname MapGridButtons
		scriptID 3
		
		pin_to_sibling GridInfo0x0
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT
		
		navUp GridButton0x0
		navRight GridButton1x1
		navDown GridButton0x2
	}
	
	GridButton1x1
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		wide 286
		tall 165
		xpos 2
		
		Classname MapGridButtons
		scriptID 4
		
		pin_to_sibling GridButton0x1
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
		
		navUp GridButton1x0
		navDown GridButton1x2
		navRight GridButton2x1
		navLeft GridButton0x1
	}
	
	GridButton2x1
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		wide 286
		tall 165
		xpos 2
		
		Classname MapGridButtons
		scriptID 5
		
		pin_to_sibling GridButton1x1
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
		
		navUp GridButton2x0
		navDown GridButton2x2
		navLeft GridButton1x1
	}
	
	GridButton0x2
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		wide 286
		tall 165
		ypos 2
		
		Classname MapGridButtons
		scriptID 6
		
		pin_to_sibling GridInfo0x1
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT
		
		navUp GridButton0x1
		navDown GridButton0x3
		navRight GridButton1x2
	}
	
	GridButton1x2
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		wide 286
		tall 165
		xpos 2
		
		Classname MapGridButtons
		scriptID 7
		
		pin_to_sibling GridButton0x2
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
		
		navUp GridButton1x1
		navDown GridButton1x3
		navRight GridButton2x2
		navLeft GridButton0x2
	}
	
	GridButton2x2
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		wide 286
		tall 165
		xpos 2
		
		Classname MapGridButtons
		scriptID 8
		
		pin_to_sibling GridButton1x2
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
		
		navUp GridButton2x1
		navDown GridButton2x3
		navLeft GridButton1x2
	}
	
	GridButton0x3
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		wide 286
		tall 165
		ypos 2
		
		Classname MapGridButtons
		scriptID 9
		
		pin_to_sibling GridInfo0x2
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT
		
		navUp GridButton0x2
		navRight GridButton1x3
		navDown DummyBottom
	}
	
	GridButton1x3
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		wide 286
		tall 165
		xpos 2
		
		Classname MapGridButtons
		scriptID 10
		
		pin_to_sibling GridButton0x3
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
		
		navUp GridButton1x2
		navRight GridButton2x3
		navLeft GridButton0x3
		navDown DummyBottom
	}
	
	GridButton2x3
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		wide 286
		tall 165
		xpos 2
		
		Classname MapGridButtons
		scriptID 11
		
		pin_to_sibling GridButton1x3
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
		
		navUp GridButton2x2
		navLeft GridButton1x3
		navDown DummyBottom
	}

//--------------------------------------------------------------------
	
	DummyTop
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		wide 0
		tall 0
	}
	
	DummyBottom
	{
		ControlName				   RuiButton
		InheritProperties		RuiSmallButton
		wide 0
		tall 0
	}
}
