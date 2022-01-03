global function ClGamemodeHidden_Init
global function ServerCallback_YouAreHidden
global function ServerCallback_AnnounceHidden

void function ClGamemodeHidden_Init()
{
    // add ffa gamestate asset
	// ClGameState_RegisterGameStateAsset( $"ui/gamestate_info_ffa.rpak" )

	// add music for mode, this is copied directly from the ffa/fra music registered in cl_music.gnut
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "music_mp_freeagents_intro", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "music_mp_freeagents_intro", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "music_mp_freeagents_outro_win", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "music_mp_freeagents_outro_win", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "music_mp_freeagents_outro_lose", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "music_mp_freeagents_outro_lose", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "music_mp_freeagents_outro_lose", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "music_mp_freeagents_outro_lose", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_THREE_MINUTE, "music_mp_freeagents_almostdone", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_THREE_MINUTE, "music_mp_freeagents_almostdone", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LAST_MINUTE, "music_mp_freeagents_lastminute", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LAST_MINUTE, "music_mp_freeagents_lastminute", TEAM_MILITIA )
}

void function ServerCallback_YouAreHidden()
{
	// heavily based on mfd code
	entity localPlayer = GetLocalViewPlayer()

	StartParticleEffectOnEntity( localPlayer.GetCockpit(), GetParticleSystemIndex( $"P_MFD" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	EmitSoundOnEntity( localPlayer, "UI_InGame_MarkedForDeath_PlayerMarked"  )
	HideEventNotification()
	AnnouncementData announcement = Announcement_Create( "#HIDDEN_YOU_ARE_HIDDEN" )
	Announcement_SetSubText( announcement, "#HIDDEN_KILL_SURVIVORS" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( localPlayer, announcement )
}

void function ServerCallback_AnnounceHidden( int survivorEHandle )
{
	entity player = GetEntityFromEncodedEHandle( survivorEHandle )

	AnnouncementData announcement = Announcement_Create( Localize( "#HIDDEN_FIRST_HIDDEN", player.GetPlayerName() ) )
	//Announcement_SetSubText( announcement, "#INFECTION_KILL_LAST_SURVIVOR" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}