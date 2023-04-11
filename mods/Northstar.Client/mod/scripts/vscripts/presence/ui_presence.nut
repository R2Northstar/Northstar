untyped
globalize_all_functions

void function NorthstarCodeCallback_GenerateUIPresence() {
	UIPresenceStruct uis

	uis.isLoading = uiGlobal.isLoading
	uis.isLobby = IsLobby()
	uis.loadingLevel = uiGlobal.loadingLevel
	uis.loadedLevel = uiGlobal.loadedLevel
	NSPushUIPresence(uis)
}