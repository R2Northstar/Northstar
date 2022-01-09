global function AddNorthstarConnectWithPasswordMenu

struct
{
	var menu
	var enterPasswordBox
	var enterPasswordDummy
	var connectButton
} file

void function AddNorthstarConnectWithPasswordMenu()
{
	AddMenu( "ConnectWithPasswordMenu", $"resource/ui/menus/connect_password.menu", InitConnectWithPasswordMenu, "#MENU_CONNECT" )
}

void function InitConnectWithPasswordMenu()
{
	file.menu = GetMenu( "ConnectWithPasswordMenu" )

	file.enterPasswordBox = Hud_GetChild( file.menu, "EnterPasswordBox")
	file.enterPasswordDummy = Hud_GetChild( file.menu, "EnterPasswordBoxDummy")
	file.connectButton = Hud_GetChild( file.menu, "ConnectButton")

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnConnectWithPasswordMenuOpened )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

	AddButtonEventHandler( file.connectButton, UIE_CLICK, ConnectWithPassword )

	AddButtonEventHandler( file.enterPasswordBox, UIE_CHANGE, UpdatePasswordLabel )

	RegisterButtonPressedCallback( KEY_ENTER, ConnectWithPassword )
}

void function UpdatePasswordLabel( var n )
{
	string hiddenPSWD
	for ( int i = 0; i < Hud_GetUTF8Text( file.enterPasswordBox ).len(); i++)
		hiddenPSWD += "*"
	Hud_SetText( file.enterPasswordDummy, hiddenPSWD )
}

void function OnConnectWithPasswordMenuOpened()
{
	UI_SetPresentationType( ePresentationType.KNOWLEDGEBASE_SUB )

	Hud_SetText( Hud_GetChild( file.menu, "Title" ), "#MENU_TITLE_CONNECT_PASSWORD" )
	Hud_SetText( file.connectButton, "#MENU_CONNECT_MENU_CONNECT" )
	Hud_SetText( file.enterPasswordBox, "" )
	Hud_SetText( file.enterPasswordDummy, "" )
}

void function ConnectWithPassword( var button )
{
	if ( GetTopNonDialogMenu() == file.menu )
		thread ThreadedAuthAndConnectToServer( Hud_GetUTF8Text( Hud_GetChild( file.menu, "EnterPasswordBox" ) ) )
}