untyped
globalize_all_functions

UIPresenceStruct function DiscordRPC_GenerateUIPresence( UIPresenceStruct uis )
{
	if ( uiGlobal.isLoading )
		uis.gameState = eDiscordGameState.LOADING;
	else if ( uiGlobal.loadedLevel == "" )
		uis.gameState = eDiscordGameState.MAINMENU;
	else if ( IsLobby() || uiGlobal.loadedLevel == "mp_lobby" )
		uis.gameState = eDiscordGameState.LOBBY;
	else
		uis.gameState = eDiscordGameState.INGAME;

	return uis
}
