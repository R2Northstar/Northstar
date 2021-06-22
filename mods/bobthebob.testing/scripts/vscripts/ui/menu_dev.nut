untyped

global function InitDevMenu
global function GetActionBlocks
global function SetDevMenu_SinglePlayer
global function SetupDevCommand // for dev
global function SetupDevFunc // for dev
global function SetDevMenu_SpawnNPCWithWeapon
global function RepeatLastDevCommand
global function SetDevMenu_ArmedNPC
global function UpdatePrecachedSPWeapons

struct DevCommand
{
	string label
	string command
	var opParm
	void functionref( var ) func
	bool storeAsLastCommand = true
}


struct
{
	void functionref() devMenuFunc
	void functionref( var ) devMenuFuncWithOpParm
	var devMenuOpParm
	array<var> buttons
	array actionBlocks
	array<DevCommand> devCommands
	DevCommand& lastDevCommand
	bool lastDevCommandAssigned
	bool precachedWeapons
} file

void function OnOpenDevMenu()
{
	file.devMenuFunc = null
	file.devMenuFuncWithOpParm = null
	file.devMenuOpParm = null
	if ( IsMultiplayer() )
		SetDevMenu_MP()
	else
		SetDevMenu_Default()
}

void function InitDevMenu()
{
	var menu = GetMenu( "DevMenu" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenDevMenu )


	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

	OnOpenDevMenu()
	
	file.buttons = GetElementsByClassname( menu, "DevButtonClass" )
	foreach ( button in file.buttons )
	{
		Hud_AddEventHandler( button, UIE_CLICK, OnDevButton_Activate )

		RuiSetString( Hud_GetRui( button ), "buttonText", "" )
		Hud_SetEnabled( button, false )
	}

}

function UpdateDevMenuButtons()
{
	file.devCommands.clear()
	if ( developer() == 0 )
		return

	if ( file.devMenuOpParm != null )
		file.devMenuFuncWithOpParm( file.devMenuOpParm )
	else
		file.devMenuFunc()

	foreach ( index, button in file.buttons )
	{
		int buttonID = int( Hud_GetScriptID( button ) )

		if ( buttonID < file.devCommands.len() )
		{
			RuiSetString( Hud_GetRui( button ), "buttonText", file.devCommands[buttonID].label )
			Hud_SetEnabled( button, true )
		}
		else
		{
			RuiSetString( Hud_GetRui( button ), "buttonText", "" )
			Hud_SetEnabled( button, false )
		}
	}
}

void function SetDevMenu_Default()
{
	file.devMenuFunc = SetupDefaultDevCommands
	UpdateDevMenuButtons()
}


void function SetDevMenu_MP()
{
	file.devMenuFunc = SetupDefaultDevCommandsMP
	UpdateDevMenuButtons()
}

void function ChangeToThisMenu( void functionref() menuFunc )
{
	file.devMenuFunc = menuFunc
	file.devMenuFuncWithOpParm = null
	file.devMenuOpParm = null
	UpdateDevMenuButtons()
}

void function ChangeToThisMenu_WithOpParm( void functionref( var ) menuFuncWithOpParm, opParm = null )
{
	file.devMenuFunc = null
	file.devMenuFuncWithOpParm = menuFuncWithOpParm
	file.devMenuOpParm = opParm
	UpdateDevMenuButtons()
}

void function SetDevMenu_SinglePlayer( var _ )
{
	CloseAllInGameMenus()
	AdvanceMenu( GetMenu( "SinglePlayerDevMenu" ), true )
}

void function SetupDefaultDevCommands()
{
	SetupDevFunc( "Frontier Defense", SetDevMenu_FrontierDefense )
	// SetupDevFunc( "Difficulty", SetDevMenu_Difficulty )
	SetupDevFunc( "Single Player", SetDevMenu_SinglePlayer )
	if ( GetStartPointsForMap( GetActiveLevel() ).len() )
	{
		SetupDevFunc( "Start Points", SetDevMenu_StartPoints )
	}
	SetupDevFunc( "Level Commands", SetDevMenu_LevelCommands )

	SetupRepeatLastDevCommand()
	SetupDevFunc( "Spawn IMC NPC", SetDevMenu_AISpawn, 2 )
	SetupDevFunc( "Spawn IMC Boss Titan", SetDevMenu_BossTitans )
	SetupDevFunc( "Spawn Militia NPC", SetDevMenu_AISpawn, 3 )
	SetupDevFunc( "Spawn Team 4 NPC", SetDevMenu_AISpawn, 4 )

	if ( IsSingleplayer() )
	{
		SetupDevCommand( "Spawn BT", "script thread DEV_SpawnBTAtCrosshair( false )" )
		SetupDevCommand( "Hotdrop BT", "script thread DEV_SpawnBTAtCrosshair( true )" )
	}

	SetupDevFunc( "Spawn Titan Weapon", SetDevMenu_TitanWeapons )
	SetupDevFunc( "Spawn Pilot Weapons", SetDevMenu_PilotWeapons )
	SetupDevFunc( "Spawn Pilot Offhands", SetDevMenu_PilotOffhands )

	SetupDevFunc( "AI Commands", SetDevMenu_AICommands )
	SetupDevCommand( "Toggle Model Viewer", "script thread ToggleModelViewer()" )
	SetupDevCommand( "AI Titan Duel", "script DEV_AITitanDuel()" )
	SetupDevCommand( "Free Titans for everybody", "script GiveAllTitans()" )

	if ( IsSingleplayer() )
	{
		SetupDevCommand( "Checkpoint", "script CheckPoint_Forced()" )
		SetupDevCommand( "Test Next Checkpoint Spawnpoint", "script TestDevSpawnPoint()" )
	}

	SetupDevCommand( "Disable NPCs", "script disable_npcs()" )
	// SetupDevCommand( "Disable New NPCs", "script disable_new_npcs()" )

	if ( IsMultiplayer() )
	{
		SetupDevCommand( "Swap the teams", "script teamswap()" )
		SetupDevCommand( "Force time limit", "script ForceTimeLimitDone()" )
		SetupDevCommand( "Force My Team Win", "script_client GetLocalClientPlayer().ClientCommand(\"ForceMyTeamWin\")" )
		SetupDevCommand( "Force My Team Lose", "script_client GetLocalClientPlayer().ClientCommand(\"ForceMyTeamLose\")" )
		SetupDevCommand( "Force Match End", "script ForceMatchEnd()" )
		SetupDevCommand( "Force Draw", "script ForceDraw()" )
	}

	SetupDevCommand( "Toggle Friendly Highlights", "script DEV_ToggleFriendlyHighlight()" )
	SetupDevCommand( "Export precache script", "script_ui Dev_CommandLineAddParm( \"-autoprecache\", \"\" ); script_ui Dev_CommandLineRemoveParm( \"" + STARTPOINT_DEV_STRING + "\" ); reload" )
	// SetupDevCommand( "Toggle Blood Spray Decals", "script_client BloodSprayDecals_Toggle()" )

	//SetupDevCommand( "PlaySpyglassVDU", "script ForcePlayConversationToAll(\"SpyglassVDU\")" )
	//SetupDevCommand( "PlayGravesVDU", "script ForcePlayConversationToAll(\"GravesVDU\")" )
	//SetupDevCommand( "PlayBliskVDU", "script ForcePlayConversationToAll(\"BliskVDU\")" )
	//SetupDevCommand( "PlaySarahVDU", "script ForcePlayConversationToAll(\"SarahVDU\")" )
	//SetupDevCommand( "PlayMacVDU", "script ForcePlayConversationToAll(\"MacVDU\")" )
	//SetupDevCommand( "PlayBishVDU", "script ForcePlayConversationToAll(\"BishVDU\")" )
	//SetupDevCommand( "PlayMCORGruntBattleRifleVDU", "script ForcePlayConversationToAll(\"MCORGruntBattleRifleVDU\")" )
	//SetupDevCommand( "PlayMCORGruntAntiTitanVDU", "script ForcePlayConversationToAll(\"MCORGruntAntiTitanVDU\")" )
	//SetupDevCommand( "PlayIMCSoldierBattleRifleVDU", "script ForcePlayConversationToAll(\"IMCSoldierBattleRifleVDU\")" )
	SetupDevCommand( "Doom my titan", "script_client GetLocalViewPlayer().ClientCommand( \"DoomTitan\" )" )
	SetupDevCommand( "DoF debug (ads)", "script_client ToggleDofDebug()" )

	SetupDevCommand( "ToggleTitanCallInEffects", "script FlagToggle( \"EnableIncomingTitanDropEffects\" )" )
	//SetupDevCommand( "TrailerTitanDrop", "script_client GetLocalViewPlayer().ClientCommand( \"TrailerTitanDrop\" )" )
	//SetupDevCommand( "AI Chatter: aichat_callout_pilot_dev", "script playconvtest(\"aichat_callout_pilot_dev\")" )
	SetupDevCommand( "Spawn IMC grunt", "SpawnViewGrunt " + TEAM_IMC )
	SetupDevCommand( "Spawn Militia grunt", "SpawnViewGrunt " + TEAM_MILITIA )
	SetupDevCommand( "Enable titan-always-executes-titan", "script FlagSet( \"ForceSyncedMelee\" )" )
	//SetupDevCommand( "Display Embark times", "script DebugEmbarkTimes()" )
	SetupDevCommand( "Kill All Titans", "script killtitans()" )
	SetupDevCommand( "Kill All Minions", "script killminions()" )
	if ( IsSingleplayer() )
		SetupDevCommand( "Kill All Enemies", "script KillAllBadguys()" )

	SetupDevCommand( "Export leveled_weapons.def / r2_weapons.fgd", "script thread LeveledWeaponDump()" )


	if ( IsMultiplayer() )
	{
		SetupDevCommand( "Summon Players to player 0", "script summonplayers()" )
		SetupDevCommand( "Display Titanfall spots", "script thread ShowAllTitanFallSpots()" )
		SetupDevCommand( "Toggle check inside Titanfall Blocker", "script thread DevCheckInTitanfallBlocker()" )
		SetupDevCommand( "Simulate Game Scoring", "script thread SimulateGameScore()" )
		SetupDevCommand( "Test Dropship Intro Spawns with Bots", "script thread DebugTestDropshipStartSpawnsForAll()" )
		SetupDevCommand( "Preview Dropship Spawn at this location", "script SetCustomPlayerDropshipSpawn()" )
		SetupDevCommand( "Test Dropship Spawn at this location", "script thread DebugTestCustomDropshipSpawn()" )
		SetupDevCommand( "Max Activity (Pilots)", "script SetMaxActivityMode(1)" )
		SetupDevCommand( "Max Activity (Titans)", "script SetMaxActivityMode(2)" )
		SetupDevCommand( "Max Activity (Conger Mode)", "script SetMaxActivityMode(4)" )
		SetupDevCommand( "Max Activity (Disabled)", "script SetMaxActivityMode(0)" )
	}
	else
	{
		SetupDevCommand( "Reset Collectibles Progress (level)", "script Dev_ResetCollectiblesProgress_Level()" )
		SetupDevCommand( "Reset Collectibles Progress (all)", "script ResetCollectiblesProgress_All()" )

		SetupDevCommand( "BT Loadouts - Reset", "script SetBTLoadoutsUnlockedBitfield( 1 )" )
		SetupDevCommand( "BT Loadouts - Unlock All", "script SetBTLoadoutsUnlockedBitfield( 65535 )" )
		SetupDevCommand( "BT Loadouts - Spawn Unlock Pickup", "script SPTitanLoadout_SpawnAtCrosshairDEV( -1 )" )
	}

	SetupDevCommand( "Toggle Skybox View", "script thread ToggleSkyboxView()" )
	//SetupDevCommand( "Toggle Bubble Shield", "ToggleBubbleShield" )
	//SetupDevCommand( "Toggle Grenade Indicators", "script_client ToggleGrenadeIndicators()" )
	SetupDevCommand( "Toggle HUD", "ToggleHUD" )
	SetupDevCommand( "Toggle Offhand Low Recharge", "ToggleOffhandLowRecharge" )
	SetupDevCommand( "Map Metrics Toggle", "script_client GetLocalClientPlayer().ClientCommand( \"toggle map_metrics 0 1 2 3\" )" )
	SetupDevCommand( "Toggle Pain Death sound debug", "script TogglePainDeathDebug()" )
	SetupDevCommand( "Jump Randomly Forever", "script_client thread JumpRandomlyForever()" )
}


void function SetupDefaultDevCommandsMP()
{
	SetupRepeatLastDevCommand()

	SetupDevFunc( "Frontier Defense", SetDevMenu_FrontierDefense )

	SetupDevFunc( "Spawn IMC NPC", SetDevMenu_AISpawn, 2 )
	SetupDevFunc( "Spawn IMC Boss Titan", SetDevMenu_BossTitans )
	SetupDevFunc( "Spawn Militia NPC", SetDevMenu_AISpawn, 3 )
	SetupDevFunc( "Spawn Team 4 NPC", SetDevMenu_AISpawn, 4 )

	SetupDevFunc( "Spawn Titan Weapon", SetDevMenu_TitanWeapons )
	SetupDevFunc( "Spawn Pilot Weapons", SetDevMenu_PilotWeapons )
	SetupDevFunc( "Spawn Pilot Offhands", SetDevMenu_PilotOffhands )

	SetupDevFunc( "AI Commands", SetDevMenu_AICommands )
	SetupDevCommand( "Toggle Model Viewer", "script thread ToggleModelViewer()" )
	SetupDevCommand( "AI Titan Duel", "script DEV_AITitanDuel()" )
	SetupDevCommand( "Free Titans for everybody", "script GiveAllTitans()" )

	SetupDevCommand( "Disable NPCs", "script disable_npcs()" )
	// SetupDevCommand( "Disable New NPCs", "script disable_new_npcs()" )

	SetupDevCommand( "Swap the teams", "script teamswap()" )
	SetupDevCommand( "Force time limit", "script ForceTimeLimitDone()" )
	SetupDevCommand( "Force My Team Win", "script_client GetLocalClientPlayer().ClientCommand(\"ForceMyTeamWin\")" )
	SetupDevCommand( "Force My Team Lose", "script_client GetLocalClientPlayer().ClientCommand(\"ForceMyTeamLose\")" )
	SetupDevCommand( "Force Match End", "script ForceMatchEnd()" )
	SetupDevCommand( "Force Draw", "script ForceDraw()" )

	SetupDevCommand( "Toggle Friendly Highlights", "script DEV_ToggleFriendlyHighlight()" )
	SetupDevCommand( "Export precache script", "script_ui Dev_CommandLineAddParm( \"-autoprecache\", \"\" ); script_ui Dev_CommandLineRemoveParm( \"" + STARTPOINT_DEV_STRING + "\" ); reload" )

	SetupDevCommand( "Doom my titan", "script_client GetLocalViewPlayer().ClientCommand( \"DoomTitan\" )" )
	SetupDevCommand( "DoF debug (ads)", "script_client ToggleDofDebug()" )

	SetupDevCommand( "ToggleTitanCallInEffects", "script FlagToggle( \"EnableIncomingTitanDropEffects\" )" )

	SetupDevCommand( "Spawn IMC grunt", "SpawnViewGrunt " + TEAM_IMC )
	SetupDevCommand( "Spawn Militia grunt", "SpawnViewGrunt " + TEAM_MILITIA )

	SetupDevCommand( "Enable titan-always-executes-titan", "script FlagSet( \"ForceSyncedMelee\" )" )

	SetupDevCommand( "Kill All Titans", "script killtitans()" )
	SetupDevCommand( "Kill All Minions", "script killminions()" )

	SetupDevCommand( "Export leveled_weapons.def / r2_weapons.fgd", "script thread LeveledWeaponDump()" )

	SetupDevCommand( "Summon Players to player 0", "script summonplayers()" )
	SetupDevCommand( "Display Titanfall spots", "script thread ShowAllTitanFallSpots()" )
	SetupDevCommand( "Toggle check inside Titanfall Blocker", "script thread DevCheckInTitanfallBlocker()" )
	SetupDevCommand( "Simulate Game Scoring", "script thread SimulateGameScore()" )
	SetupDevCommand( "Test Dropship Intro Spawns with Bots", "script thread DebugTestDropshipStartSpawnsForAll()" )
	SetupDevCommand( "Preview Dropship Spawn at this location", "script SetCustomPlayerDropshipSpawn()" )
	SetupDevCommand( "Test Dropship Spawn at this location", "script thread DebugTestCustomDropshipSpawn()" )
	SetupDevCommand( "Max Activity (Pilots)", "script SetMaxActivityMode(1)" )
	SetupDevCommand( "Max Activity (Titans)", "script SetMaxActivityMode(2)" )
	SetupDevCommand( "Max Activity (Conger Mode)", "script SetMaxActivityMode(4)" )
	SetupDevCommand( "Max Activity (Disabled)", "script SetMaxActivityMode(0)" )

	SetupDevCommand( "Toggle Skybox View", "script thread ToggleSkyboxView()" )
	SetupDevCommand( "Toggle HUD", "ToggleHUD" )
	SetupDevCommand( "Toggle Offhand Low Recharge", "ToggleOffhandLowRecharge" )
	SetupDevCommand( "Map Metrics Toggle", "script_client GetLocalClientPlayer().ClientCommand( \"toggle map_metrics 0 1 2 3\" )" )
	SetupDevCommand( "Toggle Pain Death sound debug", "script TogglePainDeathDebug()" )
	SetupDevCommand( "Jump Randomly Forever", "script_client thread JumpRandomlyForever()" )
}


void function SetupRepeatLastDevCommand()
{
	DevCommand cmd
	cmd.label = "Repeat Last Dev Command"
	cmd.func = RepeatLastDevCommand
	cmd.storeAsLastCommand = false

	file.devCommands.append( cmd )
}

void function SetDevMenu_LevelCommands( var _ )
{
	ChangeToThisMenu( SetupLevelDevCommands )
}

void function SetupLevelDevCommands()
{
	string activeLevel = GetActiveLevel()
	if ( activeLevel == "" )
		return

	switch ( activeLevel )
	{
		case "mp_titan_rodeo":
			SetupDevCommand( "Atlas titans", "script thread TitanTypes( \"titan_atlas_stickybomb\")" )
			SetupDevCommand( "Ogre titans", "script thread TitanTypes( \"titan_ogre_meteor\")" )
			SetupDevCommand( "Stryder titans", "script thread TitanTypes( \"titan_stryder_leadwall\")" )
			break

		case "model_viewer":
			SetupDevCommand( "Toggle Rebreather Masks", "script ToggleRebreatherMasks()" )
			break

		case "sp_grunt_arena":
			SetupDevCommand( "Toggle health pickups", "script ToggleHealthRegen(); reload" )
			break
	}
}

void function SetDevMenu_SpawnNPCWithWeapon( var parms )
{
	ChangeToThisMenu_WithOpParm( SetupMenu_SpawnNPCWithWeapons, parms )
}


void function SetDevMenu_StartPoints( var _ )
{
	string currentMap = GetActiveLevel()
	array<StartPointCSV> foundStartPoints = GetStartPointsForMap( currentMap )
//	foreach ( index, startPointEnum in foundStartPoints )
//	{
//		table parms = { currentMap = currentMap, startPointEnum = startPointEnum }
//		SetupDevCommand( "#" + startPointEnum, SetDevMenu_SelectStartPointDifficulty, parms )
//		//SetupDevCommand( "#" + startPointEnum, "script PickStartPoint( \"" + currentMap + "\", \"" + startPointEnum + "\" )" )
//	}

	CloseAllInGameMenus()
	AdvanceMenu( GetMenu( "SinglePlayerDevMenu" ), true )
	DisplayStartPointButtons( currentMap, foundStartPoints )
}


void function SetDevMenu_ActionBlocks()
{
	ChangeToThisMenu( SetupActionBlocks )
}

function DefineActionBlocks()
{
	file.actionBlocks = []

	/*				[Menu name]		[action block name]									[owner]		[description]														[load commands]															*/
	AddActionBlock( "Week 1", 		"Timed Switch Panel Run", 							"Sean", 	"Test your wallrunning abilities by jumping on timed platforms",	"playlist Load a map on the command line; map sp_platform_test01" )
	AddActionBlock( "Week 1", 		"Energon Room", 									"Mackey", 	"Combat test arena. Collect all Energon Spheres to win",			"playlist Load a map on the command line; map sp_abmac1" )
	AddActionBlock( "Week 1", 		"Titan Buddy + Turret Columns", 					"Carlos", 	null,																"playlist Load a map on the command line; map carlos_test" )
	AddActionBlock( "Week 1", 		"Titan Maze", 										"Soupy", 	null,																"playlist Load a map on the command line; map sp_act-block_maze" )
	AddActionBlock( "Week 1", 		"Catch me if you Can", 								"Chin", 	"Catch up to a moving pilot and kill him to win",					"launchplaylist catchmeifyoucan" )
	AddActionBlock( "Week 1", 		"Jumping Puzzles", 									"ChadG", 	"Various pilot jumping puzzles with moving platforms",				"playlist Load a map on the command line; mp_gamemode at; map mp_chad" )
	AddActionBlock( "Week 1", 		"FLANKER BOOST loadout basics", 					"Brent", 	"Non-wallrunning pilot jumping basics",								"playlist Load a map on the command line; mp_gamemode at; map mp_ab_test" )
	AddActionBlock( "Week 1", 		"Flee Titan Attack by wallrunning", 				"Roger", 	null,																"playlist Load a map on the command line; map sp_ab_flee" )
	AddActionBlock( "Week 1", 		"Protect Grunt squad from Mortar fire", 			"Roger", 	null,																"playlist Load a map on the command line; map sp_ab_vortex" )
	AddActionBlock( "Week 1", 		"Catch me if you Can Part 2", 						"Soupy",	null,																"playlist catchmeifyoucan;mp_gamemode ps; map mp_catchme" )
	AddActionBlock( "Week 2", 		"Environment Puzzles",								"ChadG", 	"Get your titan to the exit by solving some puzzles",				"playlist Load a map on the command line; mp_gamemode at; map mp_chad2" )
//	AddActionBlock( "Week 2", 		"Fun House - survive to the end",					"Mo",		null,																"playlist Load a map on the command line; map mp_ab_funhouse" )
	AddActionBlock( "Week 2", 		"Assassin Arena - boss fight with the Assassin", 	"Mo", 		null,																"playlist Load a map on the command line; map sp_ab_assassin" )
	AddActionBlock( "Week 2", 		"Creature Ship", 									"LumberJake", 	"Explore a crashed ship with mysterious cargo",					"playlist Load a map on the command line; mp_gamemode at; map mp_actionblockjake01" )
	AddActionBlock( "Week 2", 		"Titan/Pilot Puzzles", 								"RyanR",	"Get your titan to the green room",									"playlist Load a map on the command line; mp_gamemode at; map mp_ryanr_actionblock_01" )
	AddActionBlock( "Week 2", 		"Titan/Pilot Core Combat", 							"Carlos",	null,																"playlist Load a map on the command line; map sp_ammo_pickup" )
	AddActionBlock( "Week 2", 		"Titan Overwatch", 									"Roger",	"Your sniping titan will cover you as you advance to the bunker",	"playlist Load a map on the command line; map sp_ab_titanbuddy" )
	AddActionBlock( "Week 2", 		"Rodeo Express", 									"Chin",		"Use your titan to get you through a pilot hazard area",			"playlist lava; mp_gamemode at; map mp_chin_rodeo_express" )
	AddActionBlock( "Week 2", 		"Wallrun Gauntlet",									"McCord",	"Wallrun through the geo and don't fall to your death",				"playlist Load a map on the command line; map sp_zipline_action_block01" )
	AddActionBlock( "Week 2", 		"Titan Mortar Targeting Test", 						"Soupy",	null,																"playlist Load a map on the command line; map sp_mortar_targeting_test" )
	AddActionBlock( "Week 2", 		"Tremors", 											"David",	null,																"playlist Load a map on the command line; map sp_tremors" )
	AddActionBlock( "Week 2", 		"Titan Combat Blok", 								"Mackey",	"Combat arena. Kill all enemies.",									"playlist Load a map on the command line; map sp_abmac3" )
	AddActionBlock( "Week 2", 		"Smart Targeted Switch Panels", 					"Sean",		"Wallrun from wall to wall while activating switches",				"playlist Load a map on the command line; map sp_platform_test02" )
	AddActionBlock( "Week 3", 		"Combat Canyon", 									"Mo", 		"Kill enemies in the canyon and extract", 							"playlist Load a map on the command line; map sp_ab_ski" )
	AddActionBlock( "Week 3", 		"Titan v Titan", 									"Roger", 	"Test Titan vs Titan combat against various titan AI", 				"playlist Load a map on the command line; map sp_ab_tvt" )
	AddActionBlock( "Week 3", 		"Train Raid", 										"ChadG",	"Board a speeding train and hack the explosives on board", 			"playlist Load a map on the command line; map sp_ab_trainride01" )
	AddActionBlock( "Week 3", 		"Super Spectre Bros", 								"David", 	"Survive 6 waves against super spectres", 							"playlist Load a map on the command line; map mp_ab_super_spectre_bros" )
	AddActionBlock( "Week 4", 		"Nightshot", 										"David", 			"Help your titan buddy hunt in the dark.", 					"playlist Load a map on the command line; map sp_ab_nightshot" )
	//AddActionBlock( "Week 4", 		"Space Battle", 									"Mo", 				"Pilot a ship in space. \n -Play with Always run OFF. \n -Use low sensitivity. \n -Use bug_reproNum 1 to invert flight controls.\n -Use bug_reproNum 2 for PRO flight controls. (free look) \n -Use bug_reproNum 3 for inverted PRO flight controls.", 											"playlist Load a map on the command line; map sp_ab_week4" )
	AddActionBlock( "Week 4", 		"Buddy Fight", 										"Mackey",			"Arena fight with buddy Titan",												"playlist Load a map on the command line; map sp_buddy_fight" )
	AddActionBlock( "Week 4", 		"Fastball Special", 								"Slayback/McCord", 	"Use a new Titan ability to hurl yourself to new heights.", 				"playlist Load a map on the command line; map sp_fastball" )
	AddActionBlock( "Week 4", 		"Time Travel Mechanic", 							"LumberJake", 		"Travel back and forth through time to complete your mission.", 			"playlist Load a map on the command line; map sp_actionblockjake02" )
	AddActionBlock( "Week 5", 		"Titan Ability: Death Blossom", 					"Mo", 				"Use Up on D-Pad to use Death Blossom\n\nUse your new ability to defeat the enemies", 							"playlist Load a map on the command line; bug_reproNum 0; map sp_ab_blossom" )
	AddActionBlock( "Week 5", 		"Titan Ability: Arc Blast", 						"Mo", 				"Use Down on D-Pad to use Arc Blast\n\nUse your new ability to defeat the enemies", 							"playlist Load a map on the command line; bug_reproNum 1; map sp_ab_blossom" )
	AddActionBlock( "Week 5", 		"Titan Abilities: Death Blossom + Arc Blast", 		"Mo", 				"D-Pad Up = Death Blossom\nD-Pad Down = Arc Blast\n\nUse your new abilities to defeat the enemies", 			"playlist Load a map on the command line; bug_reproNum 2; map sp_ab_blossom" )
	AddActionBlock( "Week 5", 		"Time Stasis Gun", 									"LumberJake", 		"Titan freezes enemies allowing the Pilot \nto do a one-shot kill", 		"playlist Load a map on the command line; map sp_actionblockjake03" )
	AddActionBlock( "Week 5", 		"Fastball Mortar Battle", 							"McCord/Slayback", 	"Freeform Buddy Titan arena battle. \n - Fastball Special \n - Mortar Crews \n - Buddy Hibernation \n - Harvester Defense", 	"playlist Load a map on the command line; map sp_ab_mortar_battle01" )
	AddActionBlock( "Week 5", 		"Zipline Gun", 										"ChadG", 			"Create permanent ziplines in the map", 									"playlist Load a map on the command line; mp_gamemode tdm; bug_reproNum 1234; map mp_angel_city" )
	AddActionBlock( "Week 6", 		"Titan Hulk", 										"David", 			"Buddy Titan hulks out and throws things.", 								"playlist Load a map on the command line; map sp_ab_titan_thrower" )
	AddActionBlock( "Week 6", 		"Player & Titan vs Enemy Titan",					"Roger", 			"Bare bones Pilot & Auto Titan vs Enemy Titan", 							"playlist Load a map on the command line; map sp_ab_ptvt"  )
	AddActionBlock( "Week 6", 		"Pilot Stasis Gun", 								"Soupy", 			"Pilot has a Stasis gun to help a friendly Titan out", 						"playlist Load a map on the command line; map sp_ab_synergy" )
	AddActionBlock( "Week 6", 		"Acid Rain", 										"LumberJake", 		"- Destroy 3 harvesters in a poison rain storm\n- Avoid poison rain by staying in your Titan or indoors\n- Collect powerups to get rain immunity", 	"map sp_actionblockjake04" )
	AddActionBlock( "Week 6", 		"Freeform Hallway Fight", 							"McCord/Slayback", 	"Move through the tight hallways with your Titan Buddy.", 					"playlist Load a map on the command line; map sp_ab_hallway_fight01" )
	AddActionBlock( "Week 6", 		"Stealth Town",		 								"Carlos", 			"Stealth through a group of enemy titans", 									"playlist Load a map on the command line; map sp_titan_stealth" )
	AddActionBlock( "Week 6", 		"Titan Attack Command", 							"Mo", 				"Command your buddy titan to attack a position.", 							"playlist Load a map on the command line; map sp_ab_break" )
	AddActionBlock( "Week 7", 		"SP Shell", 										"Chad/McCord", 		"", 																		"playlist Load a map on the command line; map sp_shell1" )
	AddActionBlock( "Week 7", 		"Smart Pistol Progression", 						"Soupy", 			"Try different smart pistol mods in different combat situations", 			"playlist Load a map on the command line; map sp_ab_smart_pistol_ramp" )
}


function AddActionBlock( subMenu, actionBlockName, owner, description, command )
{
	local subMenuIndex = null
	foreach( i, Table in file.actionBlocks )
	{
		if ( Table.name == subMenu )
			subMenuIndex = i
	}
	if ( subMenuIndex == null )
	{
		file.actionBlocks.append( { name = subMenu, actionBlocks = [] } )
		subMenuIndex = file.actionBlocks.len() - 1
	}

	local Table = {}
	Table.name <- actionBlockName
	Table.owner <- owner
	Table.description <- description
	Table.command <- command

	file.actionBlocks[ subMenuIndex ].actionBlocks.append( Table )
}

function GetActionBlocks()
{
	DefineActionBlocks()
	return file.actionBlocks
}

void function SetupActionBlocks()
{
	DefineActionBlocks()

	// For the in-game dev menu we only add the current week of action blocks
	foreach ( week, actionBlock in file.actionBlocks )
	{
		SetupDevFunc( "Week " + ( week + 1 ), SetDevMenu_Week, week )
	}
}

void function SetDevMenu_Week( var week )
{
	ChangeToThisMenu_WithOpParm( SetupActionBlocksByWeek, week )
}

void function SetupActionBlocksByWeek( var week )
{
	foreach ( actionBlock in file.actionBlocks[ week ].actionBlocks )
	{
		SetupDevCommand( actionBlock.name + " - " + actionBlock.owner, expect string( actionBlock.command ) )
	}
}

void function SetDevMenu_AICommands( var _ )
{
	ChangeToThisMenu( SetupAIDevCommands )
}

void function SetDevMenu_AISpawn( var enemy )
{
#if DEV
	InitNpcSettingsFileNamesForDevMenu()
	ChangeToThisMenu_WithOpParm( SetupSpawnAIButtons, enemy )
#endif
}

void function SetDevMenu_BossTitans( var _ )
{
#if DEV
	InitNpcSettingsFileNamesForDevMenu()
	ChangeToThisMenu( SetupSpawnBossTitans )
#endif
}

void function SetDevMenu_FrontierDefense( var _ )
{
	#if DEV
		thread ChangeToThisMenu( SetupFrontierDefense )
	#endif
}

void function SetDevMenu_TitanWeapons( var _ )
{
#if DEV
	thread ChangeToThisMenu_PrecacheWeapons( SetupTitanWeapon )
#endif
}

void function SetDevMenu_ArmedNPC( var data )
{
#if DEV
	thread ChangeToThisMenu_PrecacheWeapons_WithOpParm( SetupSpawnArmedNPC, data )
#endif
}

void function SetDevMenu_PilotWeapons( var _ )
{
#if DEV
	thread ChangeToThisMenu_PrecacheWeapons_WithOpParm( SetupPilotWeaponsFromFields, "not_set" )
#endif
}

void function SetDevMenu_PilotOffhands( var _ )
{
#if DEV
	thread ChangeToThisMenu_PrecacheWeapons_WithOpParm( SetupPilotWeaponsFromFields, "offhand" )
#endif
}

void function ChangeToThisMenu_PrecacheWeapons( void functionref() menuFunc )
{
	waitthread PrecacheWeaponsIfNecessary()

	file.devMenuFunc = menuFunc
	file.devMenuFuncWithOpParm = null
	file.devMenuOpParm = null
	UpdateDevMenuButtons()
}

void function ChangeToThisMenu_PrecacheWeapons_WithOpParm( void functionref( var ) menuFuncWithOpParm, opParm = null )
{
	waitthread PrecacheWeaponsIfNecessary()

	file.devMenuFunc = null
	file.devMenuFuncWithOpParm = menuFuncWithOpParm
	file.devMenuOpParm = opParm
	UpdateDevMenuButtons()
}

void function PrecacheWeaponsIfNecessary()
{
	if ( file.precachedWeapons )
		return

	file.precachedWeapons = true
	CloseAllInGameMenus()

	DisablePrecacheErrors()
	wait 0.1
	ClientCommand( "script PrecacheSPWeapons()" )
	wait 0.1
	ClientCommand( "script_client PrecacheSPWeapons()" )
	wait 0.1
	RestorePrecacheErrors()

	AdvanceMenu( GetMenu( "DevMenu" ) )
}

void function UpdatePrecachedSPWeapons()
{
	file.precachedWeapons = IsMultiplayer()
}

void function SetupMenu_SpawnNPCWithWeapons( parms )
{
	string weaponCapacity 	= expect string( parms.weaponCapacity )
	string baseClass 		= expect string( parms.baseClass )
	string aiSettings 		= expect string( parms.aiSettings )
	int team				= expect int( parms.team )

	array<int> itemTypes
	switch ( weaponCapacity )
	{
		case "PilotMainWeapons":
			itemTypes = [ eItemTypes.PILOT_PRIMARY, eItemTypes.PILOT_SECONDARY ]
			break

		case "TitanMainWeapons":
			itemTypes = [ eItemTypes.TITAN_PRIMARY ]
			break

		default:
			Assert( 0, "Unknown weapon capacity " + weaponCapacity )
			break
	}

	array<string> itemNames
	foreach ( itemType in itemTypes )
	{
		array<string> items = GetAllItemRefsOfType( itemType )
		foreach ( item in items )
		{
			itemNames.append( item )
		}
	}

	foreach ( ref in itemNames )
	{
		string weaponName = expect string( GetWeaponInfoFileKeyField_GlobalNotNull( ref, "printname" ) )

		string cmd = "thread DEV_SpawnNPCWithWeaponAtCrosshair( \"" + baseClass + "\", \"" + aiSettings + "\", " + team + ", \"" + ref + "\" )"
		SetupDevCommand( weaponName, "script " + cmd )
	}
}

void function SetupAIDevCommands()
{
}

void function SetDevMenu_titanSelection( var _ )
{
	ChangeToThisMenu( SetupTitanSelection )
}

void function SetupTitanSelection()
{
}

void function SetupDevCommand( string label, string command )
{
	DevCommand cmd
	cmd.label = label
	cmd.command = command

	file.devCommands.append( cmd )
}

void function SetupDevFunc( string label, void functionref( var ) func, var opParm = null )
{
	DevCommand cmd
	cmd.label = label
	cmd.func = func
	cmd.opParm = opParm

	file.devCommands.append( cmd )
}

function OnDevButton_Activate( button )
{
	//if ( level.ui.disableDev )
	//{
	//	CodeWarning( "Dev commands disabled on matchmaking servers." )
	//	return
	//}

	int buttonID = int( Hud_GetScriptID( button ) )
	DevCommand cmd = file.devCommands[buttonID]

	RunDevCommand( cmd )
}

void function RunDevCommand( DevCommand cmd )
{
	if ( cmd.storeAsLastCommand )
	{
		file.lastDevCommand = cmd
		file.lastDevCommandAssigned = true
	}

	if ( cmd.command != "" )
	{
		ClientCommand( cmd.command )
		CloseAllInGameMenus()
	}
	else
	{
		cmd.func( cmd.opParm )
	}
}

void function RepeatLastDevCommand( var _ )
{
	if ( !file.lastDevCommandAssigned )
		return

	RunDevCommand( file.lastDevCommand )
}