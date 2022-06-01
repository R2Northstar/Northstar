untyped
global function NS_SetVersionLabel

void function NS_SetVersionLabel()
{
        var mainMenu = GetMenu( "MainMenu" ) //Gets main menu element
        var versionLabel = GetElementsByClassname( mainMenu, "nsVersionClass" )[0] //Gets the label from the mainMenu element.
        Hud_SetText( versionLabel, "v" + NSGetModVersionByModName("Northstar.Client")) //Sets the label text (Getting Northstar version from Northstar.Client)
}

