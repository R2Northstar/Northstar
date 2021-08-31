global function AddNorthstarConnectWithPasswordMenu

void function AddNorthstarConnectWithPasswordMenu()
{
	AddMenu( "ConnectWithPasswordMenu", $"resource/ui/menus/connect_password.menu", InitConnectWithPasswordMenu, "#MENU_CONNECT" )
}

void function InitConnectWithPasswordMenu()
{
	AddMenuEventHandler( GetMenu( "ConnectWithPasswordMenu" ), eUIEvent.MENU_OPEN, OnConnectWithPasswordMenuOpened )
	AddMenuFooterOption( GetMenu( "ConnectWithPasswordMenu" ), BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

	AddButtonEventHandler( Hud_GetChild( GetMenu( "ConnectWithPasswordMenu" ), "ConnectButton" ), UIE_CLICK, ConnectWithPassword )
	RegisterButtonPressedCallback( KEY_ENTER, ConnectWithPassword )
}

void function OnConnectWithPasswordMenuOpened()
{
	UI_SetPresentationType( ePresentationType.KNOWLEDGEBASE_SUB )

	Hud_SetText( Hud_GetChild( GetMenu( "ConnectWithPasswordMenu" ), "Title" ), "#MENU_TITLE_CONNECT_PASSWORD" )
	Hud_SetText( Hud_GetChild( GetMenu( "ConnectWithPasswordMenu" ), "ConnectButton" ), "#MENU_CONNECT_MENU_CONNECT" )
	Hud_SetText( Hud_GetChild( GetMenu( "ConnectWithPasswordMenu" ), "EnterPasswordBox" ), "" )
}

void function ConnectWithPassword( var button )
{
	if ( GetTopNonDialogMenu() == GetMenu( "ConnectWithPasswordMenu" ) )
		thread ThreadedAuthAndConnectToServer( Hud_GetUTF8Text( Hud_GetChild( GetMenu( "ConnectWithPasswordMenu" ), "EnterPasswordBox" ) ) )
}