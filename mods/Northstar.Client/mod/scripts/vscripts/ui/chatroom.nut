untyped

global function Chatroom_GlobalInit
global function InitChatroom
global function UpdateChatroomUI
global function UICodeCallback_ShowUserInfo
global function UICodeCallback_RemoteMatchInfoUpdated
global function UICodeCallback_SetChatroomMode
global function UpdateOpenInvites
global function HideOpenInvite
global function ShowOpenInvite
global function FillInUserInfoPanel
global function UpdateChatroomThread
global function IsVoiceChatPushToTalk

global function bsupdate

global const LOBBY_MATERIAL_OWNER = $"rui/menu/common/lobby_icon_owner"
global const LOBBY_MATERIAL_ADMIN = $"rui/menu/common/lobby_icon_admin"

struct RemoteMatchPlayerInfoRow
{
	var playerPanel
	var name
	var score
	var kills
	var deaths
}

struct RemoteMatchInfoPanel
{
	var panel
	var PlaylistName
	var MapName
	var ModeName
	var TimeLeft
	var ScoreLimit
	var Team1Score
	var Team2Score
	array<RemoteMatchPlayerInfoRow> team1Players
	array<RemoteMatchPlayerInfoRow> team2Players
}

struct OpenInviteUI
{
	var openInviteJoinButton
	var openInvitePanel
	var openInviteMessage
	var openInviteCountdownText
	array openInvitePlayerSlots
	array openInvitePlaylistSlots
}

global struct UserInfoPanel
{
	var Panel
	var Name
	var Kills
	var Wins
	var Losses
	var Deaths
	var XP
	var callsignCard
	array communityLabels
	array communityNames
}

struct ChatroomWidget
{
	var chatroomPanel
	var chatroomWidget
	var chatroomTextChat

	var chatroomBackground
	var chatroomDivider
	var chatroomHappyHour
	var chatroomMode

	UserInfoPanel userInfoPanel

	RemoteMatchInfoPanel remoteMatchInfoPanelWidgets

	var communityChatroomModeButton
	var chatroomHintText
	var happyHourTimeLeft

	OpenInviteUI openInviteUI
}

struct
{
	string userInfoPanel_hardware = ""
	string userInfoPanel_userId = "0"
	var communityChatroomMode
	bool currentUserIsStreaming = false
	array<ChatroomWidget> chatroomUIs
	bool hasFocus
} file

bool function IsVoiceChatPushToTalk()
{
	if ( GetPartySize() > 1 )
		return true
	return DoesCurrentCommunitySupportChat()
}

void function UICodeCallback_SetChatroomMode( string mode )
{
	file.communityChatroomMode = mode
	UpdateChatroomUI()
}

void function UpdateChatroomUI()
{
	foreach ( chatroomUI in file.chatroomUIs )
	{
		if ( file.communityChatroomMode == "chatroom" )
		{
			int communityId = GetCurrentCommunityId()
			CommunitySettings ornull communitySettings = GetCommunitySettings( communityId )

			string communityName
			if ( communitySettings != null )
			{
				expect CommunitySettings( communitySettings )
				communityName = GetCurrentCommunityName() + " [" +  communitySettings.clanTag + "]"
			}
			else
			{
				communityName = expect string( GetCurrentCommunityName() )
			}

			if ( IsChatroomMuted() )
				SetLabelRuiText( chatroomUI.communityChatroomModeButton, Localize( "#COMMUNITY_CHATROOM_MUTED", communityName ) )
			else
				SetLabelRuiText( chatroomUI.communityChatroomModeButton, Localize( "#COMMUNITY_CHATROOM", communityName ) )
		}
		else if ( file.communityChatroomMode == "party" )
		{
			SetLabelRuiText( chatroomUI.communityChatroomModeButton, Localize( "#COMMUNITY_PARTY", GetPartyLeaderName() ) )
		}
		else
		{
			SetLabelRuiText( chatroomUI.communityChatroomModeButton, Localize( file.communityChatroomMode ) )
		}

		int meritsLeft = GetHappyHourMeritsLeft()
		if ( meritsLeft == 0 )
		{
			SetLabelRuiText( chatroomUI.happyHourTimeLeft, Localize( "#HAPPYHOUR_NOMERITSLEFT", meritsLeft ) )
			SetNamedRuiText( chatroomUI.happyHourTimeLeft, "happyHourHintString", "" )
			//SetNamedRuiText( chatroomUI.happyHourTimeLeft, "happyHourHintString", Localize( "#HAPPYHOUR_HINT_ACTIVE_01" ) )
		}
		else if ( meritsLeft >= 1 )
		{
			SetLabelRuiText( chatroomUI.happyHourTimeLeft, Localize( GetHappyHourStatus() ) )
			SetNamedRuiText( chatroomUI.happyHourTimeLeft, "happyHourHintString", Localize( "#HAPPYHOUR_HINT_MERITS", 5 ) )
		}
		UICodeCallback_ShowUserInfo( file.userInfoPanel_hardware, file.userInfoPanel_userId )
	}

	UpdateFooterOptions()
}

bool function FillInCommunityMembership( UserInfoPanel userInfoPanel, CommunityMembership membershipData, int communityIndex )
{
	if ( userInfoPanel.communityNames.len() <= communityIndex )
		return false;

	string title
	title = "[" + membershipData.communityClantag + "] " + Localize( membershipData.communityName );

	if ( membershipData.membershipLevel == "owner" )
		Hud_SetText( userInfoPanel.communityLabels[communityIndex], "#COMMUNITY_MEMBERSHIP_OWNER" )
	else if ( membershipData.membershipLevel == "admin" )
		Hud_SetText( userInfoPanel.communityLabels[communityIndex], "#COMMUNITY_MEMBERSHIP_ADMIN" )
	else if ( membershipData.membershipLevel == "member" )
		Hud_SetText( userInfoPanel.communityLabels[communityIndex], "#COMMUNITY_MEMBERSHIP_MEMBER" )
	else
		Assert( false, "Unknown membership level " + membershipData.membershipLevel + " in FillInCommunityMembership" )

	Hud_SetText( userInfoPanel.communityNames[communityIndex], title )
	Hud_Show( userInfoPanel.communityLabels[communityIndex] );
	Hud_Show( userInfoPanel.communityNames[communityIndex] );

	return true
}

void function FillInUserInfoPanel( UserInfoPanel userInfoPanel, CommunityUserInfo userInfo )
{
	file.currentUserIsStreaming = userInfo.isLivestreaming

	Hud_SetText( userInfoPanel.Name, userInfo.name )
	string killsText = "" + userInfo.kills
	Hud_SetText( userInfoPanel.Kills, killsText )
	string winsText = "" + userInfo.wins
	Hud_SetText( userInfoPanel.Wins, winsText )
	string lossesText = "" + userInfo.losses
	Hud_SetText( userInfoPanel.Losses, lossesText )
	string deathsText = "" + userInfo.deaths
	Hud_SetText( userInfoPanel.Deaths, deathsText )
	string xpText = ShortenNumber( userInfo.xp )
	Hud_EnableKeyBindingIcons( userInfoPanel.XP )
	Hud_SetText( userInfoPanel.XP, Localize( "#CREDITSIGN_N", xpText ) )

	CallingCard callingCard = CallingCard_GetByIndex( userInfo.callingCardIdx )
	CallsignIcon callsignIcon = CallsignIcon_GetByIndex( userInfo.callSignIdx )

	var card = userInfoPanel.callsignCard
	var rui = Hud_GetRui( userInfoPanel.callsignCard )
	RuiSetImage( rui, "cardImage", callingCard.image )
	RuiSetImage( rui, "iconImage", callsignIcon.image )
	RuiSetInt( rui, "layoutType", callingCard.layoutType )
	RuiSetImage( rui, "cardGenImage", GetGenIcon( userInfo.gen, userInfo.lvl ) )
	RuiSetString( rui, "playerLevel", PlayerXPDisplayGenAndLevel( userInfo.gen, userInfo.lvl ) )
	RuiSetString( rui, "playerName", userInfo.name )

	array<CommunityMembership> ownerCommunities
	array<CommunityMembership> adminCommunities
	array<CommunityMembership> memberCommunities

	for ( int i = 0; i < userInfo.numCommunities; i++ )
	{
		CommunityMembership ornull communityInfo = GetCommunityUserMembershipInfo( userInfo.hardware, userInfo.uid, i )
		if ( !communityInfo )
			continue;
		expect CommunityMembership( communityInfo )
		string membershipLevel = communityInfo.membershipLevel
		if ( membershipLevel == "owner" )
		{
			ownerCommunities.append( communityInfo )
		}
		else if ( membershipLevel == "admin" )
		{
			adminCommunities.append( communityInfo )
		}
		else if ( membershipLevel == "member" )
		{
			memberCommunities.append( communityInfo )
		}
		else
		{
			printt( "Unknown membershipLevel " + membershipLevel )
			Assert( false, "Unknown membershipLevel" )
		}
	}

	array<CommunityMembership> allCommunities
	for ( int i = 0; i < ownerCommunities.len(); i++ )
		allCommunities.append( ownerCommunities[i] )
	for ( int i = 0; i < adminCommunities.len(); i++ )
		allCommunities.append( adminCommunities[i] )
	for ( int i = 0; i < memberCommunities.len(); i++ )
		allCommunities.append( memberCommunities[i] )

	int currentCommunityIndex = 0
	for ( ; currentCommunityIndex < allCommunities.len(); currentCommunityIndex++ )
	{
		if ( !FillInCommunityMembership( userInfoPanel, allCommunities[currentCommunityIndex], currentCommunityIndex ) )
			break;
	}

	for ( ; currentCommunityIndex < userInfoPanel.communityNames.len(); currentCommunityIndex++ )
	{
		Hud_Hide( userInfoPanel.communityLabels[currentCommunityIndex] );
		Hud_Hide( userInfoPanel.communityNames[currentCommunityIndex] );
	}

	UpdateFooterOptions()
}

void function GetUserInfoThread( string hardware, string userId )
{
	EndSignal( uiGlobal.signalDummy, "StopUserInfoLookups" )

	printt( "getting userinfo for user " + userId )

	CommunityUserInfo fakeSettings
	fakeSettings.name = Localize( "#COMMUNITY_FETCHING" )
	foreach ( chatroomUI in file.chatroomUIs )
		FillInUserInfoPanel( chatroomUI.userInfoPanel, fakeSettings )

	while ( true )
	{
		printt( "asking for userinfo for " + hardware + "=" + userId )

		CommunityUserInfo ornull userInfo = GetCommunityUserInfo( hardware, userId )
		if ( !userInfo )
		{
			wait 0.05
		}
		else
		{
			printt( "Got user info for user " + userId + " on hardware " + hardware )
			expect CommunityUserInfo( userInfo )

			printt( "User " + userId + " is in " + userInfo.numCommunities + " communities" )

			foreach ( chatroomUI in file.chatroomUIs )
				FillInUserInfoPanel( chatroomUI.userInfoPanel, userInfo )
			break
		}
	}
}


void function UICodeCallback_ShowUserInfo( string hardware, string userId )
{
	Signal( uiGlobal.signalDummy, "StopUserInfoLookups" )

	// printt( "Showing user info for UID " + userId + " on hardware " + hardware )

	file.userInfoPanel_userId = userId
	file.userInfoPanel_hardware = hardware

	if ( hardware == "" && userId == "0" )
	{
		foreach ( chatroomUI in file.chatroomUIs )
			Hud_Hide( chatroomUI.userInfoPanel.Panel )

		foreach ( chatroomUI in file.chatroomUIs )
		{
		//	Hud_SetWidth( chatrooUI.chatroomWidget, Hud_GetBaseWidth( chatrooUI.chatroomWidget ) )
			Hud_SetWidth( chatroomUI.chatroomBackground, Hud_GetBaseWidth( chatroomUI.chatroomBackground ) )
			Hud_Show( chatroomUI.chatroomDivider )
			//	Hud_SetWidth( chatrooUI.chatroomHeader, Hud_GetBaseWidth( chatrooUI.chatroomHeader ) )
		//	Hud_SetWidth( chatrooUI.chatroomMode, Hud_GetBaseWidth( chatrooUI.chatroomBackground ) )
			#if CONSOLE_PROG
				Hud_Show( chatroomUI.chatroomHintText )
			#else
				Hud_Show( chatroomUI.chatroomTextChat )
			#endif
		}
	}
	else
	{
		foreach ( chatroomUI in file.chatroomUIs )
			Hud_Show( chatroomUI.userInfoPanel.Panel )

		foreach ( chatroomUI in file.chatroomUIs )
		{
		//	Hud_SetWidth( chatroomUI.chatroomWidget, Hud_GetBaseWidth( chatroomUI.chatroomWidget ) - Hud_GetBaseWidth( chatroomUI.userInfoPanel.Panel ) - 24 )
			Hud_SetWidth( chatroomUI.chatroomBackground, Hud_GetBaseWidth( chatroomUI.chatroomBackground ) - Hud_GetBaseWidth( chatroomUI.userInfoPanel.Panel ) - 12 )
			Hud_Hide( chatroomUI.chatroomDivider )
		//	Hud_SetWidth( chatroomUI.chatroomHeader, Hud_GetBaseWidth( chatroomUI.chatroomHeader ) - Hud_GetBaseWidth( chatroomUI.userInfoPanel.Panel ) - 12 )
		//	Hud_SetWidth( chatroomUI.chatroomMode, Hud_GetBaseWidth( chatroomUI.chatroomBackground ) - Hud_GetBaseWidth( chatroomUI.userInfoPanel.Panel ) - 24 )
			#if CONSOLE_PROG
				Hud_Hide( chatroomUI.chatroomHintText )
			#else
				Hud_Hide( chatroomUI.chatroomTextChat )
			#endif
		}

		thread GetUserInfoThread( hardware, userId )
	}
}

void function FindRemoteMatchInfoWidgetsInPanel( RemoteMatchInfoPanel infostruct, var panel )
{
	infostruct.PlaylistName = Hud_GetChild( panel, "PlaylistName" )
	infostruct.MapName = Hud_GetChild( panel, "MapName" )
	infostruct.ModeName = Hud_GetChild( panel, "ModeName" )
	infostruct.TimeLeft = Hud_GetChild( panel, "TimeLeft" )
	infostruct.ScoreLimit = Hud_GetChild( panel, "ScoreLimit" )
	infostruct.Team1Score = Hud_GetChild( panel, "Team1Score" )
	infostruct.Team2Score = Hud_GetChild( panel, "Team2Score" )
	for ( int i = 1; i <= 2; i++ )
	{
		array<RemoteMatchPlayerInfoRow> teamPlayers
		if ( i == 1 )
			teamPlayers = infostruct.team1Players
		else
			teamPlayers = infostruct.team2Players

		for ( int j = 1; j <= 8; j++ )
		{
			RemoteMatchPlayerInfoRow teamPlayer
			string key = "Team" + i + "Player" + j
			teamPlayer.playerPanel = Hud_GetChild( panel, key )
			teamPlayer.name = Hud_GetChild( teamPlayer.playerPanel, "Name" )
			teamPlayer.score = Hud_GetChild( teamPlayer.playerPanel, "Score" )
			teamPlayer.kills = Hud_GetChild( teamPlayer.playerPanel, "Kills" )
			teamPlayer.deaths = Hud_GetChild( teamPlayer.playerPanel, "Deaths" )
			teamPlayers.append( teamPlayer )
		}
	}
}

int function RemoteMatchInfoPlayerSort( RemoteClientInfoFromMatchInfo a, RemoteClientInfoFromMatchInfo b )
{
	return ( b.score - a.score )
}

void function FillInRemoteMatchInfoPanel( RemoteMatchInfo info, RemoteMatchInfoPanel panel )
{
	Hud_Show( panel.panel )

	Hud_SetText( panel.PlaylistName, GetPlaylistDisplayName( info.playlist ) )
	Hud_SetText( panel.MapName, Localize( "#" + info.map ) )

	string modeName

	if ( IsFDMode( info.gamemode ) )
	{
		modeName = "#GAMEMODE_COOP"
		// HACK because fd has multiple gamemodes in playlists
	}
	else
	{
		modeName = GAMETYPE_TEXT[ info.gamemode ]
	}

	if ( IsFullyConnected() )
		modeName = GetGameModeDisplayName( info.gamemode )

	Hud_SetText( panel.ModeName, modeName )
	int minsLeft = info.timeLeftSecs / 60
	int secsLeft = info.timeLeftSecs % 60
	string timeLeft = "" + minsLeft
	if ( secsLeft < 10 )
		timeLeft = timeLeft + ":0" + secsLeft
	else
		timeLeft = timeLeft + ":" + secsLeft
	Hud_SetText( panel.TimeLeft, timeLeft )
	string scoreLimit = "" + info.maxScore
	Hud_SetText( panel.ScoreLimit, scoreLimit )
	string imcScore = "" + info.teamScores[TEAM_IMC]
	string milScore = "" + info.teamScores[TEAM_MILITIA]
	Hud_SetText( panel.Team1Score, imcScore )
	Hud_SetText( panel.Team2Score, milScore )

	int team1PlayerCount = 0
	int team2PlayerCount = 0

	info.clients.sort( RemoteMatchInfoPlayerSort )

	for ( int i = 0; i < info.clients.len(); i++ )
	{
		RemoteMatchPlayerInfoRow teamPlayer
		if ( info.clients[i].teamNum == TEAM_IMC )
		{
			if ( team1PlayerCount >= panel.team1Players.len() )
			{
				printt( "too many team players" )
				continue
			}

			teamPlayer = panel.team1Players[team1PlayerCount]
			team1PlayerCount++
		}
		else if ( info.clients[i].teamNum == TEAM_MILITIA )
		{
			if ( team2PlayerCount >= panel.team2Players.len() )
			{
				printt( "too many team players" )
				continue
			}

			teamPlayer = panel.team2Players[team2PlayerCount]
			team2PlayerCount++
		}
		else
		{
			printt( "Unhandled player team " + info.clients[i].teamNum )
			continue
		}
		string score = "" + info.clients[i].score
		string kills = "" + info.clients[i].kills
		string deaths = "" + info.clients[i].deaths

		Hud_Hide( teamPlayer.playerPanel ) // not enough room for these
		Hud_SetText( teamPlayer.name, info.clients[i].name )
		Hud_SetText( teamPlayer.score, score )
		Hud_SetText( teamPlayer.kills, kills )
		Hud_SetText( teamPlayer.deaths, deaths )
	}
	for ( int i = team1PlayerCount; i < panel.team1Players.len(); i++ )
		Hud_Hide( panel.team1Players[i].playerPanel )
	for ( int i = team2PlayerCount; i < panel.team2Players.len(); i++ )
		Hud_Hide( panel.team2Players[i].playerPanel )

}

void function RemoteMatchInfoVisibilityThread()
{
	EndSignal( uiGlobal.signalDummy, "StopRemoteMatchInfoThread" )
	wait 2
	foreach ( chatroomUI in file.chatroomUIs )
		Hud_Hide( chatroomUI.remoteMatchInfoPanelWidgets.panel )
}

void function UICodeCallback_RemoteMatchInfoUpdated()
{
	printt( "Remote Match Info Updated!" )

	RemoteMatchInfo info = GetRemoteMatchInfo()
	foreach ( chatroomUI in file.chatroomUIs )
		FillInRemoteMatchInfoPanel( info, chatroomUI.remoteMatchInfoPanelWidgets )

	Signal( uiGlobal.signalDummy, "StopRemoteMatchInfoThread" )
	thread RemoteMatchInfoVisibilityThread()
}

void function Chatroom_GlobalInit()
{
	RegisterSignal( "StopRemoteMatchInfoThread" )
}

bool function IsSelectedUserStreaming()
{
	if ( !ChatroomHasFocus() )
		return false
	return file.currentUserIsStreaming
}

void function InitChatroom( var parentMenu )
{
	RegisterSignal( "StopUserInfoLookups" )

	file.communityChatroomMode = "chatroom"

	var menu = Hud_GetChild( parentMenu, "ChatroomPanel" )

	ChatroomWidget chatroomUI
	file.chatroomUIs.append( chatroomUI )

	chatroomUI.chatroomPanel = menu
	chatroomUI.chatroomWidget = Hud_GetChild( menu, "ChatRoom" )
	chatroomUI.chatroomTextChat = Hud_GetChild( menu, "ChatRoomTextChat" )
	chatroomUI.chatroomBackground = Hud_GetChild( menu, "ChatbarBackground" )
	chatroomUI.chatroomDivider = Hud_GetChild( menu, "ChatroomHeaderBackground" )
	chatroomUI.chatroomHappyHour = Hud_GetChild( menu, "HappyHourTimeLeft" )
	chatroomUI.chatroomMode = Hud_GetChild( menu, "CommunityChatRoomMode" )

	var remoteMatchInfoPanel = Hud_GetChild( parentMenu, "MatchDetails" )
	chatroomUI.remoteMatchInfoPanelWidgets.panel = remoteMatchInfoPanel
	FindRemoteMatchInfoWidgetsInPanel( chatroomUI.remoteMatchInfoPanelWidgets, remoteMatchInfoPanel )

	chatroomUI.userInfoPanel.Panel = Hud_GetChild( parentMenu, "UserInfo" )
	chatroomUI.userInfoPanel.Name = Hud_GetChild( chatroomUI.userInfoPanel.Panel, "Name" )
	chatroomUI.userInfoPanel.Kills = Hud_GetChild( chatroomUI.userInfoPanel.Panel, "Kills" )
	chatroomUI.userInfoPanel.Wins = Hud_GetChild( chatroomUI.userInfoPanel.Panel, "Wins" )
	chatroomUI.userInfoPanel.Losses = Hud_GetChild( chatroomUI.userInfoPanel.Panel, "Losses" )
	chatroomUI.userInfoPanel.Deaths = Hud_GetChild( chatroomUI.userInfoPanel.Panel, "Deaths" )
	chatroomUI.userInfoPanel.XP = Hud_GetChild( chatroomUI.userInfoPanel.Panel, "XP" )
	chatroomUI.userInfoPanel.callsignCard = Hud_GetChild( chatroomUI.userInfoPanel.Panel, "CallsignCard" )

	// chatroomUI.userInfoPanel.ViewUserCardButton = Hud_GetChild( chatroomUI.userInfoPanel.Panel, "ViewUserCard" )

	for ( int i = 0; i < 6; i++ )
	{
		if ( !Hud_HasChild( chatroomUI.userInfoPanel.Panel, "Community" + i + "Label" ) )
			break;
		var communityLabel = Hud_GetChild( chatroomUI.userInfoPanel.Panel, "Community" + i + "Label" )
		var communityName = Hud_GetChild( chatroomUI.userInfoPanel.Panel, "Community" + i )
		Assert( communityName, "found Community" + i + "Label, but no Community" + i + " in userInfo panel" );
		chatroomUI.userInfoPanel.communityLabels.append( communityLabel )
		chatroomUI.userInfoPanel.communityNames.append( communityName )
	}

	chatroomUI.communityChatroomModeButton = Hud_GetChild( menu, "CommunityChatRoomMode" )
#if CONSOLE_PROG
	chatroomUI.chatroomHintText = Hud_GetChild( menu, "TextChatHintForConsole" )
#endif
	chatroomUI.happyHourTimeLeft = Hud_GetChild( menu, "HappyHourTimeLeft" )
	// Hud_EnableKeyBindingIcons( chatroomUI.communityChatroomModeButton )

	OpenInviteUI openInviteUI = chatroomUI.openInviteUI
	openInviteUI.openInvitePanel = Hud_GetChild( parentMenu, "OpenInvitePanel" )
	openInviteUI.openInviteMessage = Hud_GetChild( openInviteUI.openInvitePanel, "OpenInviteMessage" )
	openInviteUI.openInviteCountdownText = Hud_GetChild( openInviteUI.openInvitePanel, "OpenInviteCountdownText" )

	var openInviteBackground = Hud_GetChild( openInviteUI.openInvitePanel, "OpenInviteBox" )
	RuiSetColorAlpha( Hud_GetRui( openInviteBackground ), "backgroundColor", <0, 0, 0>, 0.9 )

	int i = 0;
	while ( i < 8 )
	{
		int count = i + 1
		var widget = Hud_GetChild( openInviteUI.openInvitePanel, "OpenInvitePlayer" + count )
		if ( !widget )
			break
		openInviteUI.openInvitePlayerSlots.append( widget )
		i++
	}
	for ( int idx = 0; idx < 9; ++idx )
	{
		string widgetName = ("OpenInvitePlaylist" + format( "%02d", idx ))
		var widget = Hud_GetChild( openInviteUI.openInvitePanel, widgetName )
		openInviteUI.openInvitePlaylistSlots.append( widget )
		i++
	}

	openInviteUI.openInviteJoinButton = Hud_GetChild( openInviteUI.openInvitePanel, "JoinOpenInviteButton" )
	Hud_EnableKeyBindingIcons( openInviteUI.openInviteJoinButton )

	AddEventHandlerToButton( openInviteUI.openInvitePanel, "JoinOpenInviteButton", UIE_CLICK, JoinOpenInvite_OnClick )
	AddEventHandlerToButton( openInviteUI.openInvitePanel, "OpenInviteCountdownText", UIE_CLICK, JoinOpenInvite_OnClick )
	AddEventHandlerToButton( openInviteUI.openInvitePanel, "OpenInviteMessageButtonOverlay", UIE_CLICK, JoinOpenInvite_OnClick )

	AddMenuFooterOption( parentMenu, BUTTON_SHOULDER_LEFT, "#LB_MUTEROOM", "#MUTEROOM", MuteRoom, ChatroomIsNotMuted )
	AddMenuFooterOption( parentMenu, BUTTON_SHOULDER_LEFT, "#LB_UNMUTEROOM", "#UNMUTEROOM", UnmuteRoom, ChatroomIsMuted )
	AddMenuFooterOption( parentMenu, BUTTON_Y, "#Y_BUTTON_OPENINVITE_DESTROY_FOOTER", "#OPENINVITE_DESTROY", LeaveOpenInviteButton, CanDestroyOpenInvite )
	AddMenuFooterOption( parentMenu, BUTTON_Y, "#Y_BUTTON_OPENINVITE_JOIN_FOOTER", "#OPENINVITE_JOIN", JoinOpenInvite, CanJoinOpenInvite )
	AddMenuFooterOption( parentMenu, BUTTON_Y, "#Y_BUTTON_OPENINVITE_LEAVE_FOOTER", "#OPENINVITE_LEAVE", LeaveOpenInviteButton, CanLeaveOpenInvite )
	AddMenuFooterOption( parentMenu, BUTTON_A, "#BUTTON_VIEW_PLAYER_PROFILE", "#MOUSE1_VIEW_PROFILE", null, IsChatroomViewProfileValid )
	AddMenuFooterOption( parentMenu, BUTTON_SHOULDER_RIGHT, "#COMMUNITY_RB_CHATROOM_VIEWSTREAM", "#COMMUNITY_CHATROOM_VIEWSTREAM", null, IsSelectedUserStreaming )
	AddMenuFooterOption( parentMenu, BUTTON_X, "#BUTTON_MUTE", "#MOUSE2_MUTE", null, ChatroomHasFocus )

	UpdateChatroomUI()

	Hud_AddEventHandler( chatroomUI.chatroomWidget, UIE_LOSE_FOCUS, LostFocus )
	Hud_AddEventHandler( chatroomUI.chatroomWidget, UIE_GET_FOCUS, GotFocus )
}

void function bsupdate()
{
	ShowOpenInvite()

	OpenInvite openInvite
	openInvite.amILeader = false
	openInvite.amIInThis = false
	openInvite.numSlots = 5
	openInvite.numClaimedSlots = 1

	string inviteString = openInvite.amILeader ? "#OPENINVITE_SENDER_PLAYLIST" : "#OPENINVITE_PLAYLIST"

	float endTime = Time() + 10.0
	while ( Time() < endTime )
	{
		openInvite.timeLeft = endTime - Time()

		int remainingTime = int( ceil( endTime - Time() ) )
		UpdateOpenInvites( openInvite, inviteString, "scriptacus", "Bounty Hunt", remainingTime )

		if ( remainingTime == 8 )
			openInvite.numClaimedSlots = 2

		if ( remainingTime == 6 )
			openInvite.numClaimedSlots = 4

		//if ( remainingTime == 5 )
		//	openInvite.numClaimedSlots = 5
		//
		//if ( remainingTime == 4 )
		//	openInvite.numClaimedSlots = 6

		WaitFrame()
	}
}

void function UpdateOpenInvites( OpenInvite openInvite, string message, string param1, string ornull param2, int countdown )
{
	foreach ( chatroomUI in file.chatroomUIs )
	{
		if ( param2 )
			Hud_SetText( chatroomUI.openInviteUI.openInviteMessage, message, param1, param2 );
		else
			Hud_SetText( chatroomUI.openInviteUI.openInviteMessage, message, param1 );

		string countdownText = "" + countdown
//		Hud_SetText( chatroomUI.openInviteUI.openInviteCountdownText, "#OPENINVITE_COUNTDOWN", countdownText )
		var countdownRui = Hud_GetRui( chatroomUI.openInviteUI.openInviteCountdownText )
		RuiSetFloat( countdownRui, "timeLeft", openInvite.timeLeft )
		RuiSetFloat( countdownRui, "maxTime", GetConVarFloat( "openinvite_duration_default" ) )

		bool started = openInvite.timeLeft <= 0 || openInvite.numFreeSlots == 0

		if ( started )
		{
			Hud_Hide( chatroomUI.openInviteUI.openInviteJoinButton )
		}
		else if ( CanDestroyOpenInvite() )
		{
			Hud_Show( chatroomUI.openInviteUI.openInviteJoinButton )
			if ( IsControllerModeActive() )
				SetNamedRuiText( chatroomUI.openInviteUI.openInviteJoinButton, "buttonText", "#Y_BUTTON_OPENINVITE_DESTROY" )
			else
				SetNamedRuiText( chatroomUI.openInviteUI.openInviteJoinButton, "buttonText", "#OPENINVITE_DESTROY" )
		}
		else if ( CanLeaveOpenInvite() )
		{
			Hud_Show( chatroomUI.openInviteUI.openInviteJoinButton )
			if ( IsControllerModeActive() )
				SetNamedRuiText( chatroomUI.openInviteUI.openInviteJoinButton, "buttonText", "#Y_BUTTON_OPENINVITE_LEAVE" )
			else
				SetNamedRuiText( chatroomUI.openInviteUI.openInviteJoinButton, "buttonText", "#OPENINVITE_LEAVE" )
		}
		else if ( CanJoinOpenInvite() )
		{
			Hud_Show( chatroomUI.openInviteUI.openInviteJoinButton )
			if ( IsControllerModeActive() )
				SetNamedRuiText( chatroomUI.openInviteUI.openInviteJoinButton, "buttonText", "#Y_BUTTON_OPENINVITE_JOIN" )
			else
				SetNamedRuiText( chatroomUI.openInviteUI.openInviteJoinButton, "buttonText", "#OPENINVITE_JOIN" )
		}

		string myUID = GetPlayerUID()
		int i = 0
		foreach ( player in chatroomUI.openInviteUI.openInvitePlayerSlots )
		{
			var rui = Hud_GetRui( player )
			Hud_Show( player )

			if ( i >= openInvite.numSlots )
			{
				//Hud_Hide( player )
				RuiSetBool( rui, "isEnabled", false )
				RuiSetBool( rui, "hasPlayer", false )
			}
			else
			{
				CallsignIcon callsignIcon
				bool isMe = false
				// asset playerImage

				if ( i < openInvite.numClaimedSlots )
				{
					PartyMember member = openInvite.members[i]
					isMe = ( member.uid == myUID )
					if ( isMe )
					{
						if ( GetUIPlayer() != null ) // this can happen sometimes after a resolution/windowed mode change
							callsignIcon = PlayerCallsignIcon_GetActive( GetUIPlayer() )
						else
							callsignIcon = CallsignIcon_GetByRef( "gc_icon_happyface" )
					}
					else
					{
						callsignIcon = CallsignIcon_GetByIndex( member.callsignIdx )
					}
				}
				else
				{
					callsignIcon = CallsignIcon_GetByRef( "gc_icon_happyface" )
				}

				Hud_Show( player )
				RuiSetBool( rui, "isEnabled", true )

				RuiSetBool( rui, "hasPlayer", i < openInvite.numClaimedSlots )
				RuiSetBool( rui, "isViewPlayer", isMe )
				RuiSetImage( rui, "playerImage", callsignIcon.image )

				//if ( i < openInvite.numClaimedSlots )
				//	Hud_SetImage( player, $"ui/menu/main_menu/openinvite_occupiedslot" )
				//else
				//	Hud_SetImage( player, $"ui/menu/main_menu/openinvite_emptyslot" )
			}
			i++
		}

		array<string> checklistPlaylists = GetChecklistPlaylistsArray()

		if ( Lobby_IsFDMode() )
			checklistPlaylists = GetFDDifficultyArray()

		array<string> invitePlaylists = split( openInvite.playlistName, "," )
		bool shouldShowCheckboxPlaylists = true
		if ( !MixtapeMatchmakingIsEnabled() )
			shouldShowCheckboxPlaylists = false
		else if ( invitePlaylists.len() == 0 )
			shouldShowCheckboxPlaylists = false
		else if ( (invitePlaylists.len() == 1) && (!checklistPlaylists.contains( invitePlaylists[0] )) )
			shouldShowCheckboxPlaylists = false

		int playlistSlotCount = chatroomUI.openInviteUI.openInvitePlaylistSlots.len()
		for( int idx = 0; idx < playlistSlotCount; ++idx )
		{
			var slot = chatroomUI.openInviteUI.openInvitePlaylistSlots[idx]

			string thisPlaylistName = idx < checklistPlaylists.len() ? checklistPlaylists[idx] : ""
			if ( (thisPlaylistName == "") || !shouldShowCheckboxPlaylists )
			{
				Hud_Hide( slot )
				continue
			}

			Hud_Show( slot )
			var slotRui = Hud_GetRui( slot )
			asset playlistThumbnail = GetPlaylistThumbnailImage( thisPlaylistName )
			RuiSetImage( slotRui, "checkImage", playlistThumbnail )

			bool isChecked = invitePlaylists.contains( thisPlaylistName )
			RuiSetBool( slotRui, "isChecked", isChecked )

			string abbr = GetPlaylistVarOrUseValue( thisPlaylistName, "abbreviation", "" )
			RuiSetString( slotRui, "abbreviation", Localize( abbr ) )
		}
	}
}


void function HideOpenInvite()
{
	foreach ( chatroomUI in file.chatroomUIs )
	{
		Hud_Hide( chatroomUI.openInviteUI.openInvitePanel )
	}
}

void function ShowOpenInvite()
{
	foreach ( chatroomUI in file.chatroomUIs )
	{
		Hud_Show( chatroomUI.openInviteUI.openInvitePanel )
	}
}


void function LostFocus( panel )
{
	Signal( uiGlobal.signalDummy, "StopUserInfoLookups" )
	printt( "Chatroom lost focus" )
	foreach ( chatroomUI in file.chatroomUIs )
		Hud_Hide( chatroomUI.userInfoPanel.Panel )
	file.hasFocus = false

	foreach ( chatroomUI in file.chatroomUIs )
	{
	//	Hud_SetWidth( chatrooUI.chatroomWidget, Hud_GetBaseWidth( chatrooUI.chatroomWidget ) )
		Hud_SetWidth( chatroomUI.chatroomBackground, Hud_GetBaseWidth( chatroomUI.chatroomBackground ) )
		Hud_Show( chatroomUI.chatroomDivider )
	//	Hud_SetWidth( chatrooUI.chatroomMode, Hud_GetBaseWidth( chatrooUI.chatroomBackground ) )
		Hud_Show( chatroomUI.chatroomTextChat )
	}
}


void function OnChatroomWidgetGetFocus( var widget )
{
}

void function OnChatroomWidgetLoseFocus( var widget )
{
}

void function GotFocus( panel )
{
	printt( "Chatroom got focus" )
	file.hasFocus = true

	foreach ( chatroomUI in file.chatroomUIs )
	{
	//	Hud_SetWidth( chatroomUI.chatroomWidget, Hud_GetBaseWidth( chatroomUI.chatroomWidget ) - Hud_GetBaseWidth( chatroomUI.userInfoPanel.Panel ) - 24 )
		Hud_SetWidth( chatroomUI.chatroomBackground, Hud_GetBaseWidth( chatroomUI.chatroomBackground ) - Hud_GetBaseWidth( chatroomUI.userInfoPanel.Panel ) - 12 )
		Hud_Hide( chatroomUI.chatroomDivider )
	//	Hud_SetWidth( chatroomUI.chatroomMode, Hud_GetBaseWidth( chatroomUI.chatroomBackground ) - Hud_GetBaseWidth( chatroomUI.userInfoPanel.Panel ) - 24 )
		Hud_Hide( chatroomUI.chatroomTextChat )
	}
}

bool function IsChatroomViewProfileValid()
{
	#if PC_PROG
		if ( !Origin_IsOverlayAvailable() )
			return false
	#endif // PC_PROG

	return ChatroomHasFocus()
}

bool function ChatroomHasFocus()
{
	return file.hasFocus
}

bool function ChatroomIsMuted()
{
	if ( IsControllerModeActive() )
		return ChatroomHasFocus() && IsChatroomMuted()
	return IsChatroomMuted()
}

bool function ChatroomIsNotMuted()
{
	if ( IsControllerModeActive() )
		return ChatroomHasFocus() && !IsChatroomMuted()
	return !IsChatroomMuted()
}

void function MuteRoom( var button )
{
	printt( "muting the room" )
	ClientCommand( "muteroom" )
}

void function UnmuteRoom( var button )
{
	printt( "unmuting the room" )
	ClientCommand( "unmuteroom" )
}

void function UpdateChatroomThread()
{
	EndSignal( uiGlobal.signalDummy, "OnCloseLobbyMenu" )
	while ( true )
	{
		UpdateChatroomUI()
		wait 30
	}
}
