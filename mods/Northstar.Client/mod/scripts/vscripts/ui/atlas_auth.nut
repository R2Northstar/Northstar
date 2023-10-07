global function AtlasAuthDialog

void function AtlasAuthDialog()
{
	thread AtlasAuthDialog_Threaded()
}

void function AtlasAuthDialog_Threaded()
{
	// wait at least 1 frame so that the main menu can be loaded first
	WaitFrame()

	while ( !NSIsMasterServerAuthenticated() || GetConVarBool( "ns_auth_allow_insecure" ) )
		WaitFrame()

	if ( GetConVarBool( "ns_auth_allow_insecure" ) )
		return

	MasterServerAuthResult res = NSGetMasterServerAuthResult()

	// do nothing on successful authentication
	if ( res.success )
	    return

	EmitUISound( "blackmarket_purchase_fail" )

	DialogData dialogData
	dialogData.image = $"ui/menu/common/dialog_error"
	dialogData.header = Localize( "#AUTHENTICATION_FAILED_HEADER" )

	// if we got a special error message from Atlas, display it
	if ( res.errorMessage != "" )
		dialogData.message = res.errorMessage
	else
		dialogData.message = Localize( "#AUTHENTICATION_FAILED_BODY" )

	if ( res.errorCode != "" )
		dialogData.message += format( "\n\n%s", Localize( "#AUTHENTICATION_FAILED_ERROR_CODE", res.errorCode ) )

	string link = "https://r2northstar.gitbook.io/r2northstar-wiki/installing-northstar/troubleshooting"
	// link to generic troubleshooting page if we don't have an error code from Atlas
	if ( res.errorCode != "" )
		link = format( "%s#%s", link, res.errorCode )

	CloseAllDialogs()
	AddDialogButton( dialogData, "#OK" )
	AddDialogButton( dialogData, Localize( "#AUTHENTICATION_FAILED_HELP" ), void function() : ( dialogData, link )
	{
		// todo: get MS to redirect, so i can use an MS link or something?
		LaunchExternalWebBrowser( link, WEBBROWSER_FLAG_FORCEEXTERNAL )
		// keep the dialog open
		OpenDialog( dialogData )
	} )

	OpenDialog( dialogData )
}
