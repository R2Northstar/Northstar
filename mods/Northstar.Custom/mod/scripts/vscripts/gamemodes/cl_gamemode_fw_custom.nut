// cl_gamemode_fw already exists in vanilla game file
// this file is to register more network vars or remote functions
global function ServerCallback_FW_NotifyNeedsEnterEnemyArea

void function ServerCallback_FW_NotifyNeedsEnterEnemyArea()
{
	AnnouncementData announcement = Announcement_Create( "#FW_ENTER_ENEMY_AREA" )
	Announcement_SetSoundAlias( announcement,  "UI_InGame_LevelUp" )
	Announcement_SetSubText( announcement, "#FW_TITAN_REQUIRED_SUB" )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}
