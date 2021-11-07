global function InitOpenInvitesMenu
global function UICodeCallback_OpenInviteUpdated
global function InPendingOpenInvite
global function LeaveOpenInvite
global function JoinOpenInvite
global function JoinOpenInvite_OnClick
global function CanJoinOpenInvite
global function CanLeaveOpenInvite
global function CanDestroyOpenInvite
global function LeaveOpenInviteButton
global function IsOpenInviteVisible

struct
{
	bool openInviteJoinable
	bool openInviteVisible
} file

bool function InPendingOpenInvite()
{
	if ( !file.openInviteVisible )
		return false
	OpenInvite openInvite = GetOpenInvite()
	return openInvite.amIInThis
}

void function LeaveOpenInviteButton( var button )
{
	LeaveOpenInvite()
}

void function LeaveOpenInvite()
{
	EmitUISound( "UI_Networks_Invitation_Canceled" )
	ClientCommand( "leaveopeninvite" )

	// sort of HACK: revert lobby to non-FD mode when you cancel out of open invite
	Lobby_SetFDMode( false )
	Lobby_RefreshButtons()
}

void function JoinOpenInvite( var button )
{
	if ( CanJoinOpenInvite() )
	{
		EmitUISound( "UI_Networks_Invitation_Accepted" )
		ClientCommand( "joinopeninvite" )
	}
	else if ( CanLeaveOpenInvite() )
	{
		LeaveOpenInvite()
	}
}

void function JoinOpenInvite_OnClick( var button )
{
	// haaaack.  Either join it or leave it here, depending on context
	OpenInvite openInvite = GetOpenInvite()
	if ( openInvite.amIInThis )
		LeaveOpenInvite()
	else
		JoinOpenInvite( button )
}

bool function IsOpenInviteVisible()
{
	return file.openInviteVisible
}

bool function CanDestroyOpenInvite()
{
	OpenInvite openInvite = GetOpenInvite()
	return file.openInviteVisible && openInvite.amILeader
}

bool function CanJoinOpenInvite()
{
	OpenInvite openInvite = GetOpenInvite()
	int currentPartySize = GetPartySize()
	return currentPartySize <= 1 && file.openInviteVisible && file.openInviteJoinable && !openInvite.amIInThis
}

bool function CanLeaveOpenInvite()
{
	OpenInvite openInvite = GetOpenInvite()
	return file.openInviteVisible && file.openInviteJoinable && !openInvite.amILeader && openInvite.amIInThis
}

void function UpdateOpenInvite()
{
	OpenInvite openInvite = GetOpenInvite()

	if ( openInvite.timeLeft <= -1 || openInvite.numFreeSlots == 0 )
	{
		HideOpenInvite()
		if ( openInvite.amILeader )
			ClientCommand( "openinvitelaunch" )
		if ( openInvite.amIInThis )
		{
			CloseAllToTargetMenu( GetMenu( "LobbyMenu" ) )
			AdvanceMenu( GetMenu( "SearchMenu" ) )
		}
		else
		{
			Lobby_SetFDMode( false )
			Lobby_RefreshButtons()
		}
		file.openInviteVisible = false
		file.openInviteJoinable = false
		UpdateFooterOptions()
		return
	}

	array<string> playlists = split( openInvite.playlistName, "," )

	string message = ""
	string param1 = ""
	string ornull param2 = null
	switch( openInvite.inviteType )
	{
	case "party":
		if ( openInvite.amILeader )
			message = "#OPENINVITE_SENDER_PARTY";
		else
			message = "#OPENINVITE_PARTY";
		param1 = openInvite.originatorName
		break;
	case "playlist":
		if ( playlists.len() > 1 )
		{
			if ( openInvite.amILeader )
				message = "#OPENINVITE_SENDER_PLAYLIST_MANY"
			else
				message = "#OPENINVITE_PLAYLIST_MANY"
			param1 = openInvite.originatorName
			param2 = GetPlaylistDisplayName( openInvite.playlistName )
		}
		else
		{
			if ( openInvite.amILeader )
				message = "#OPENINVITE_SENDER_PLAYLIST"
			else
				message = "#OPENINVITE_PLAYLIST"
			param1 = openInvite.originatorName
			param2 = GetPlaylistDisplayName( openInvite.playlistName )
		}
		break;
	case "private_match":
		if ( openInvite.amILeader )
			message = "#OPENINVITE_SENDER_PRIVATEMATCH"
		else
			message = "#OPENINVITE_PRIVATEMATCH"
		param1 = openInvite.originatorName
		break;
	default:
		HideOpenInvite()
		file.openInviteVisible = false
		file.openInviteJoinable = false
		UpdateFooterOptions()
		return;
	}
	int timeLeft = int( openInvite.timeLeft ) + 1
	if ( openInvite.timeLeft <= 0 || openInvite.numFreeSlots == 0 )
	{
		if ( file.openInviteJoinable )
		{
			file.openInviteJoinable = false
			UpdateFooterOptions()
		}
		timeLeft = 0
	}
	else
	{
		if ( !file.openInviteJoinable )
		{
			file.openInviteJoinable = true
			UpdateFooterOptions()
			printt( "openinvite is joinable" )
		}
	}

	UpdateOpenInvites( openInvite, message, param1, param2, timeLeft )
}

void function UpdateOpenInvite_Thread()
{
	while ( file.openInviteVisible )
	{
		if ( !IsConnected() || !IsLobby() )
		{
			HideOpenInvite()
			file.openInviteVisible = false
			file.openInviteJoinable = false
			UpdateFooterOptions()
			return
		}

		UpdateOpenInvite()
		WaitFrame()
	}
}

void function UICodeCallback_OpenInviteUpdated()
{
	if ( file.openInviteVisible || IsNorthstarServer() )
		return

	int currentPartySize = GetPartySize()
	if ( currentPartySize > 1 )
	{
		HideOpenInvite()
		file.openInviteVisible = false
		return
	}

	if ( !IsConnected() )
	{
		HideOpenInvite()
		file.openInviteVisible = false
		return
	}

	entity player = GetUIPlayer()
	if ( IsValid( player ) && Player_NextAvailableMatchmakingTime( player ) > 0 )
	{
		HideOpenInvite()
		file.openInviteVisible = false
		return
	}

	OpenInvite openInvite = GetOpenInvite()
	ShowOpenInvite()
	file.openInviteVisible = true
	UpdateOpenInvite()
	thread UpdateOpenInvite_Thread()
}

void function InitOpenInvitesMenu()
{
	file.openInviteVisible = false
	file.openInviteJoinable = false
}
