untyped
global function NS_SetVersionLabel

void function NS_SetVersionLabel()
{
	var mainMenu = GetMenu( "MainMenu" )
	var versionLabel = GetElementsByClassname( mainMenu, "nsVersionClass" )[0]
	// construct first version string from Northstar.Client version
	string modsVersionString = "v" + NSGetModInformation( "Northstar.Client" )[0].version
	// construct second version string from constants given by native
	string nativeVersionString = "v" + NS_VERSION_MAJOR + "." + NS_VERSION_MINOR + "." + NS_VERSION_PATCH
	if ( NS_VERSION_DEV > 0 )
		nativeVersionString += "." + NS_VERSION_DEV + "+dev"
	
	if ( nativeVersionString != modsVersionString )
		Hud_SetText( versionLabel, "Core: " + modsVersionString + "\nLauncher: " + nativeVersionString )
	else
		Hud_SetText( versionLabel, modsVersionString )

}

