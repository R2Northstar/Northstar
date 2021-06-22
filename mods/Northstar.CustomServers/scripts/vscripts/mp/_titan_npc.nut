untyped

global function TitanNPC_Init

global function CodeCallback_PlayerRequestClimbInNPCTitan
global function ResetTitanLoadoutFromPrimary

global function NPCTitanNextMode
global function NPCTitanInitModeOnPlayerRespawn
global function SetupAutoTitan
global function SetupNPC_TitanTitle
global function SetPlayerPetTitan
global function AutoTitanChangedEnemy
global function PlayAutoTitanConversation
global function CreateTitanModelAndSkinSetup
global function SetWeaponCooldowns

global function ResetTitanBuildTime

global function CreateNPCTitanFromSettings

global function FreeAutoTitan

global function GetRandomTitanWeapon

global function SpawnTitanBatteryOnDeath
global function CreateTitanBattery

global function WaitForHotdropToEnd
global function ResetCoreKillCounter

const TITAN_USE_HOLD_PROMPT = "Hold [USE] to Pilot||Hold [USE] to Rodeo"
const TITAN_USE_PRESS_PROMPT = "Press [USE] to Pilot||Press [USE] to Rodeo"

const int BATTERY_DROP_BOSS = 4

const float BATTERY_DROP_HEALTH_FRAC_SURE = 0.2
const float BATTERY_DROP_HEALTH_FRAC_MID = 0.5

const int BATTERY_DROP_MID_CHANCE = 70
const int BATTERY_DROP_LOW_CHANCE = 40

struct
{
	int coreKillCounter = 0
} file

function TitanNPC_Init()
{
	RegisterSignal( "ChangedTitanMode" )
	RegisterSignal( "PROTO_WeaponPickup" )

	AddSoulDeathCallback( AutoTitanDestroyedCheck )

	#if R1_VGUI_MINIMAP
	Minimap_PrecacheMaterial( $"vgui/HUD/threathud_titan_friendlyself" )
	Minimap_PrecacheMaterial( $"vgui/HUD/threathud_titan_friendlyself_guard" )
	#endif

	if ( IsSingleplayer() )
	{
		AddSpawnCallbackEditorClass( "script_ref", "script_titan_battery", SpawnTitanBattery )
		AddDeathCallback( "npc_titan", SpawnTitanBatteryOnDeath )
		AddDeathCallback( "npc_titan", TitanAchievementTracking_SP )
	}
}

void function AutoTitanDestroyedCheck( entity soul, var damageInfo )
{
	entity titan = soul.GetTitan()
	if ( !IsValid( titan ) )
		return

	entity player = soul.GetBossPlayer()
	if ( !IsValid( player ) )
		return

	SetActiveTitanLoadoutIndex( player, -1 )

	if ( player.GetPetTitan() == titan )
		player.SetPetTitan( null )

	if ( soul.IsEjecting() )
		return

	// has another titan?
	if ( GetPlayerTitanInMap( player ) )
		return

	switch ( Riff_TitanAvailability() )
	{
		case eTitanAvailability.Default:
			break

		default:
			if ( !Riff_IsTitanAvailable( player ) )
				return
	}

	if ( GAMETYPE == SST )
		return

	if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.round_end )
		return

	thread PlayConversationToPlayer( "AutoTitanDestroyed", player )
}



//////////////////////////////////////////////////////////
function SetupNPC_TitanTitle( npcTitan, player )
{
	npcTitan.SetBossPlayer( player )

	#if R1_VGUI_MINIMAP
	switch ( player.GetPetTitanMode() )
	{
		case eNPCTitanMode.FOLLOW:
			npcTitan.Minimap_SetBossPlayerMaterial( $"vgui/HUD/threathud_titan_friendlyself" )
			break;

		//case eNPCTitanMode.ROAM:
		//	break;

		case eNPCTitanMode.STAY:
			npcTitan.Minimap_SetBossPlayerMaterial( $"vgui/HUD/threathud_titan_friendlyself_guard" )
			break;
	}
	#endif
}

//////////////////////////////////////////////////////////
void function NPCTitanNextMode( entity npcTitan, entity player )
{
	entity soul = npcTitan.GetTitanSoul()
	if ( !SoulHasPassive( soul, ePassives.PAS_ENHANCED_TITAN_AI ) && PROTO_AutoTitansDisabled() )
		return

	NPCTitanDisableCurrentMode( npcTitan, player )

	local mode = player.GetPetTitanMode() + 1
	if ( mode == eNPCTitanMode.MODE_COUNT )
		mode = eNPCTitanMode.FOLLOW

	player.SetPetTitanMode( mode )
	npcTitan.Signal( "ChangedTitanMode" )

	SetupNPC_TitanTitle( npcTitan, player )
	NPCTitanEnableCurrentMode( npcTitan, player )
}

//////////////////////////////////////////////////////////
function NPCTitanSetBehaviorForMode( entity npcTitan, entity player )
{
	entity soul = npcTitan.GetTitanSoul()
	if ( soul == null)
		soul = player.GetTitanSoul()

	switch ( player.GetPetTitanMode() )
	{
		case eNPCTitanMode.FOLLOW:
			if ( soul && SoulHasPassive( soul, ePassives.PAS_ENHANCED_TITAN_AI ) )
				npcTitan.SetBehaviorSelector( "behavior_mp_auto_titan_enhanced" )
			else
				npcTitan.SetBehaviorSelector( "behavior_mp_auto_titan" )
			break;

		//case eNPCTitanMode.ROAM:
		//	break;

		case eNPCTitanMode.STAY:
			if ( soul && SoulHasPassive( soul, ePassives.PAS_ENHANCED_TITAN_AI ) )
				npcTitan.SetBehaviorSelector( "behavior_mp_auto_titan_enhanced_guard" )
			else
				npcTitan.SetBehaviorSelector( "behavior_mp_auto_titan_guard" )
			break;
	}
}

//////////////////////////////////////////////////////////
function NPCTitanDisableCurrentMode( entity npcTitan, entity player )
{
	switch ( player.GetPetTitanMode() )
	{
		case eNPCTitanMode.FOLLOW:
			npcTitan.DisableBehavior( "Follow" )
			break;

		//case eNPCTitanMode.ROAM:
		//	break;

		case eNPCTitanMode.STAY:
			npcTitan.DisableBehavior( "Assault" )
			break;
	}
}


//////////////////////////////////////////////////////////
function NPCTitanEnableCurrentMode( entity npcTitan, entity player )
{
	switch ( player.GetPetTitanMode() )
	{
		case eNPCTitanMode.FOLLOW:
			NPCTitanFollowPilotInit( npcTitan, player )
			break;

		//case eNPCTitanMode.ROAM:
		//	break;

		case eNPCTitanMode.STAY:
		{

			local traceStart = player.EyePosition()
			local forward = AnglesToForward( player.EyeAngles() )
			local traceEnd	= traceStart + ( forward * 12000 )

			TraceResults result = TraceLine( traceStart, traceEnd, player, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_NONE )

			local dir = result.endPos - npcTitan.EyePosition()

			// DebugDrawLine( result.endPos, npcTitan.EyePosition(), 255, 0, 0, true, 5 )

			local titanAngles;
			if ( LengthSqr( dir ) > 100 )
				titanAngles = VectorToAngles( dir )
			else
				titanAngles = player.GetAngles()

			titanAngles.z = 0;

			npcTitan.AssaultPointClamped( npcTitan.GetOrigin() )
			npcTitan.AssaultSetAngles( titanAngles, true )
			break;
		}
	}

	NPCTitanSetBehaviorForMode( npcTitan, player )
}


void function AutoTitanChangedEnemy( entity titan )
{
	if ( !IsAlive( titan ) )
		return

	entity enemy = titan.GetEnemy()

	if ( !IsAlive( enemy ) )
		return

	if ( !titan.CanSee( enemy ) )
		return

	string aliasSuffix
	if ( enemy.IsTitan() )
		aliasSuffix = "autoEngageTitan"
	else if ( IsGrunt( enemy ) )
		aliasSuffix = "autoEngageGrunt"
	else if ( enemy.IsHuman() && enemy.IsPlayer() )
		aliasSuffix = "autoEngagePilot"

	if ( aliasSuffix == "" )
		return

	PlayAutoTitanConversation( titan, aliasSuffix )
}

function AutoTitanShouldSpeak( entity titan, entity owner, aliasSuffix )
{
	if ( IsForcedDialogueOnly( owner ) )
		return false

	if ( "disableAutoTitanConversation" in titan.s )
	{
		return false
	}
	//Shut Auto Titans up when game isn't active anymore
	if ( GetGameState() >= eGameState.Postmatch )
	{
		return false
	}

	entity owner

	if ( titan.IsPlayer() )
	{
		owner = titan
	}
	else
	{
		owner = GetPetTitanOwner( titan )
		if ( !IsValid( owner ) )
			return
	}

	if ( owner.s.autoTitanLastEngageCallout == aliasSuffix )
	{
		// just did this line, so significant time has to pass before we will use it again
		return Time() > owner.s.autoTitanLastEngageCalloutTime + 28
	}

	// this is a new line, so just make sure we haven't spoken too recently
	return Time() > owner.s.autoTitanLastEngageCalloutTime + 7
}

void function PlayAutoTitanConversation( entity titan, string aliasSuffix )
{
	entity owner

	if ( titan.IsPlayer() )
	{
		owner = titan
	}
	else
	{
		owner = GetPetTitanOwner( titan )
		if ( !IsValid( owner ) )
			return
	}

	if ( !AutoTitanShouldSpeak( titan, owner, aliasSuffix ) ) //Only use the suffix since that's the distinguishing part of the alias, i.e. "engage_titans"
		return

	owner.s.autoTitanLastEngageCalloutTime = Time()
	owner.s.autoTitanLastEngageCallout = aliasSuffix //Only use the suffix since that's the distinguishing part of the alias, i.e. "engage_titans"

	int conversationID = GetConversationIndex( aliasSuffix )
	Remote_CallFunction_Replay( owner, "ServerCallback_PlayTitanConversation", conversationID )
}


void function FreeAutoTitan( entity npcTitan )
{
	//npcTitan.SetEnemyChangeCallback( "" )

	local bossPlayer = npcTitan.GetBossPlayer()

	if ( !IsValid( bossPlayer ) )
		return

	bossPlayer.SetPetTitan( null )

	local soul = npcTitan.GetTitanSoul()

	npcTitan.ClearBossPlayer()
	soul.ClearBossPlayer()

	npcTitan.SetTitle( "" )

	npcTitan.Signal( "TitanStopsThinking" )
	npcTitan.UnsetUsable()

	thread TitanKneel( npcTitan )
}


//////////////////////////////////////////////////////////
function SetupAutoTitan( entity npcTitan, entity player )
{
	#if SP
	npcTitan.SetUsePrompts( "#HOLD_TO_EMBARK_SP", "#PRESS_TO_EMBARK_SP" )
	#endif

	#if MP
	npcTitan.SetUsePrompts( "#HOLD_TO_EMBARK", "#PRESS_TO_EMBARK" )
	#endif

	npcTitan.SetUsableByGroup( "owner pilot" )

	NPCTitanFollowPilotInit( npcTitan, player )

	NPCTitanGuardModeInit( npcTitan )

	npcTitan.SetEnemyChangeCallback( AutoTitanChangedEnemy )

	NPCTitanEnableCurrentMode( npcTitan, player )

	npcTitan.DisableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE )
	npcTitan.EnableNPCFlag( NPC_NEW_ENEMY_FROM_SOUND )
	UpdateEnemyMemoryFromTeammates( npcTitan )

	SetPlayerPetTitan( player, npcTitan )

	SetupNPC_TitanTitle( npcTitan, player )

	ShowName( npcTitan )

	SPMP_UpdateNPCProficiency( npcTitan )
}

function SetPlayerPetTitan( entity player, entity npcTitan )
{
	if ( npcTitan == player.GetPetTitan() )
		return

	entity previousOwner = GetPetTitanOwner( npcTitan )
	if ( IsValid( previousOwner ) )
	{
		previousOwner.SetPetTitan( null )
	}

	if ( IsAlive( player.GetPetTitan() ) )
	{
		Assert( !player.s.replacementDropInProgress, "Tried to give us a titan when we were executing a Titanfall" )
		// kill old pet titan
		player.GetPetTitan().Die( null, null, { scriptType = DF_INSTANT, damageSourceId = damagedef_suicide } )
	}

	// HACK: not really a hack, but this could be optimized to only render always for a given client
	npcTitan.EnableRenderAlways()
	player.SetPetTitan( npcTitan )
	#if HAS_TITAN_EARNING
		ClearTitanAvailable( player )
	#endif
	SetTeam( npcTitan, player.GetTeam() )
	entity soul = npcTitan.GetTitanSoul()
	if ( soul == null )
		soul = player.GetTitanSoul()

	string settings = GetSoulPlayerSettings( soul )
	var maintainTitle = Dev_GetPlayerSettingByKeyField_Global( settings, "keep_title_on_autotitan" )
	if ( maintainTitle != null && maintainTitle == 1 )
	{
		string title = expect string( GetPlayerSettingsFieldForClassName( settings, "printname" ) )
		npcTitan.SetTitle( title )
	}
	else if ( SoulHasPassive( soul, ePassives.PAS_ENHANCED_TITAN_AI ) )
	{
		npcTitan.SetTitle( "#NPC_AUTO_TITAN_ENHANCED" )
	}
	else
	{
		npcTitan.SetTitle( "#NPC_AUTO_TITAN" )
	}

	npcTitan.DisableHibernation()
}


//////////////////////////////////////////////////////////
function NPCTitanFollowPilotInit( npcTitan, player )
{
	int followBehavior = GetDefaultNPCFollowBehavior( npcTitan )
	npcTitan.InitFollowBehavior( player, followBehavior )

	if ( IsMultiplayer() )
	{
		npcTitan.SetFollowGoalTolerance( 700 )
		npcTitan.SetFollowGoalCombatTolerance( 700 )
		npcTitan.SetFollowTargetMoveTolerance( 200 )
	}
	else
	{
		npcTitan.SetFollowGoalTolerance( 500 )
		npcTitan.SetFollowGoalCombatTolerance( 1200 )
		npcTitan.SetFollowTargetMoveTolerance( 150 )
	}

	npcTitan.EnableBehavior( "Follow" )
	npcTitan.DisableBehavior( "Assault" )
}

//////////////////////////////////////////////////////////
function NPCTitanGuardModeInit( npcTitan )
{
#if DEV // Bug 110047
	Assert( IsValid( npcTitan ) )
	if ( !npcTitan.IsTitan() && !npcTitan.IsNPC() )
		printl( "npcTitan is " + npcTitan.GetClassName() )
#endif

	npcTitan.AssaultSetFightRadius( 0 )

	if ( IsSingleplayer() )
	{
		npcTitan.AssaultSetGoalRadius( 512 )
		npcTitan.AssaultSetArrivalTolerance( 300 )
	}
	else
	{
		npcTitan.AssaultSetGoalRadius( 400 )
		npcTitan.AssaultSetArrivalTolerance( 200 )
	}
}

//////////////////////////////////////////////////////////
function NPCTitanInitModeOnPlayerRespawn( player )
{
	if ( IsValid( player.GetPetTitan() ) )
	{
		local titan = player.GetPetTitan()

		switch ( player.GetPetTitanMode() )
		{
			case eNPCTitanMode.FOLLOW:
				NPCTitanFollowPilotInit( titan, player )
				break;

			default:
				// nothing to do for other modes
				break;
		}
	}
}

//////////////////////////////////////////////////////////
function CodeCallback_PlayerRequestClimbInNPCTitan( npcTitan, player )
{
}




//////////////////////////////////////////////////////////
entity function CreateNPCTitanFromSettings( string settings, int team, vector origin, vector angles )
{
	entity npc = CreateNPCTitan( settings, team, origin, angles )
	DispatchSpawn( npc )
	return npc
}

function CreateTitanModelAndSkinSetup( entity npc )
{
	asset currentModel = npc.GetModelName()

	if ( IsSingleplayer() )
	{
		switch ( currentModel )
		{
			case $"":
			case $"models/titans/buddy/titan_buddy.mdl":
			case $"models/titans/light/sp_titan_light_locust.mdl":
			case $"models/titans/light/sp_titan_light_raptor.mdl":
			case $"models/titans/heavy/sp_titan_heavy_deadbolt.mdl":
			case $"models/titans/heavy/sp_titan_heavy_ogre.mdl":
			case $"models/titans/medium/sp_titan_medium_ajax.mdl":
			case $"models/titans/medium/sp_titan_medium_wraith.mdl":
				break

			default:
				CodeWarning( "NPC titan at " + npc.GetOrigin() + " had non-sp titan model " + currentModel )
				break
		}
	}

	string settings = npc.ai.titanSettings.titanSetFile
	asset model = GetPlayerSettingsAssetForClassName( settings, "bodymodel" )
	npc.SetValueForModelKey( model )
}

// NEW TITAN STUFF BROUGHT OVER FROM TOWER DEFENSE R1
string function GetRandomTitanWeapon()
{
	TitanLoadoutDef loadout = GetAllowedTitanLoadouts().getrandom()
	return loadout.primary
}

void function ResetTitanBuildTime( entity player )
{
	if ( player.IsTitan() )
	{
		player.SetTitanBuildTime( GetCoreBuildTime( player ) )
		return
	}

	player.SetTitanBuildTime( GetTitanBuildTime( player ) )
}


/* SP */

void function SpawnTitanBattery( entity batteryRef )
{
	vector origin = batteryRef.GetOrigin()
	entity battery = CreateTitanBattery( origin )
	batteryRef.Destroy()
}

void function SpawnTitanBatteryOnDeath( entity titan, var damageInfo )
{
	if ( !titan.ai.shouldDropBattery || titan.GetTeam() == TEAM_MILITIA )
		return
	// if ( RandomFloatRange( 0, 100 ) < 50 )
	// 	return
	int attachID = titan.LookupAttachment( "CHESTFOCUS" )
	vector origin = titan.GetAttachmentOrigin( attachID )

	int numBatt = 0

	if ( titan.IsTitan() && titan.ai.bossTitanType == TITAN_MERC )
	{
		numBatt = BATTERY_DROP_BOSS
	}
	else
	{
		if ( Flag( "PlayerDidSpawn" ) )
		{
			entity player = GetPlayerArray()[0]
			entity playerTitan = GetTitanFromPlayer( player )

			if ( IsValid( playerTitan ) &&
					(
						GetDoomedState( playerTitan ) ||
				 		RandomDropBatteryBasedOnHealth( playerTitan )
				 	)
				)
			{
				numBatt = 1
			}
		}
	}

	for ( int i=0; i<numBatt; i++ )
	{
		vector vec = RandomVec( 150 )
		if ( numBatt == 1 )
			vec = < 0,0,0 >
		entity battery = CreateTitanBattery( origin )
		battery.SetVelocity( < vec.x, vec.y, 400 > )
	}
}

entity function CreateTitanBattery( vector origin )
{
	entity battery = Rodeo_CreateBatteryPack()
	battery.SetOrigin( origin )
	//Highlight_SetNeutralHighlight( battery, "power_up" )
	// if ( IsValid( battery ) )
	// {
	// 	PickupGlow glow = CreatePickupGlow( battery, 0, 255, 0 )
	// 	glow.glowFX.SetParent( battery, "", true, 0 )
	// }
	return battery
}

void function SetWeaponCooldowns( entity player, array<entity> weapons, float cooldown )
{
	foreach ( weapon in weapons )
	{
		int max = weapon.GetWeaponPrimaryClipCountMax()
		if ( max <= 0 )
			continue
		int current = int( max * cooldown )
		weapon.SetWeaponPrimaryClipCountAbsolute( current )

		if ( weapon.IsChargeWeapon() )
		{
			float chargeCooldownTime = weapon.GetWeaponSettingFloat( eWeaponVar.charge_cooldown_time )
			if ( chargeCooldownTime > 1.0 )
			{
				weapon.SetWeaponPrimaryClipCountAbsolute( max )
				weapon.SetWeaponChargeFractionForced( 1.0 - cooldown )
			}
		}
	}
}

void function ResetTitanLoadoutFromPrimary( entity titan )
{
	Assert( titan.IsTitan() )
	Assert( IsAlive( titan ) )

//	EmitSoundOnEntity( player, "Coop_AmmoBox_AmmoRefill" )
	entity soul = titan.GetTitanSoul()
	// not a real titan, swapping in/out of titan etc
	if ( soul == null )
		return

	array<entity> weapons = GetPrimaryWeapons( titan )

	foreach ( weapon in weapons )
	{
		TitanLoadoutDef ornull titanLoadout = GetTitanLoadoutForPrimary( weapon.GetWeaponClassName() )
		if ( titanLoadout == null )
			continue
		expect TitanLoadoutDef( titanLoadout )

		float coreValue = SoulTitanCore_GetNextAvailableTime( soul )

		ReplaceTitanLoadoutWhereDifferent( titan, titanLoadout )

		SoulTitanCore_SetNextAvailableTime( soul, coreValue )

		if ( titan.IsPlayer() )
		{
//			Remote_CallFunction_Replay( titan, "ServerCallback_NotifyLoadout", titan.GetEncodedEHandle() )
			Remote_CallFunction_Replay( titan, "ServerCallback_UpdateTitanModeHUD" )
		}
		break
	}
}

void function WaitForHotdropToEnd( entity titan )
{
	// Wait until player sees the boss titan
	while ( titan.e.isHotDropping )
	{
		WaitFrame()
	}
}

bool function RandomDropBatteryBasedOnHealth( entity playerTitan )
{
	float healthFrac = GetHealthFrac( playerTitan )
	int randomPercent = RandomIntRange( 0, 100 )

	if ( healthFrac <= BATTERY_DROP_HEALTH_FRAC_SURE )
	{
		return true
	}
	else if ( healthFrac <= BATTERY_DROP_HEALTH_FRAC_MID )
	{
		return randomPercent <= BATTERY_DROP_MID_CHANCE
	}
	else
	{
		return randomPercent <= BATTERY_DROP_LOW_CHANCE
	}

	return false
}

void function TitanAchievementTracking_SP( entity titan, var damageInfo )
{
	entity player = DamageInfo_GetAttacker( damageInfo )

	if ( !titan.IsTitan() )
		return

	if ( !IsValid( player ) )
		return

	if ( !player.IsPlayer() )
		return

	int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )

	switch ( damageSourceId )
	{
		case eDamageSourceId.mp_titancore_salvo_core:
		case eDamageSourceId.mp_titancore_laser_cannon:
		case eDamageSourceId.mp_titancore_flame_wave:
		case eDamageSourceId.mp_titancore_flame_wave_secondary:
		case eDamageSourceId.mp_titancore_shift_core:
		case eDamageSourceId.mp_titanweapon_flightcore_rockets:
		case eDamageSourceId.mp_titancore_amp_core:
			file.coreKillCounter++
			break
		case eDamageSourceId.mp_titanweapon_predator_cannon:
			array<string> weaponMods = GetWeaponModsFromDamageInfo( damageInfo )
			if ( weaponMods.contains( "Smart_Core" ) )
			{
				file.coreKillCounter++
			}
			break
		#if HAS_BOSS_AI
		case eDamageSourceId.titan_execution:
			if ( IsMercTitan( titan ) )
			{
				UnlockAchievement( player, achievements.EXECUTE_BOSS )
			}
			break
		#endif
	}

	if ( file.coreKillCounter >= 3 )
	{
		UnlockAchievement( player, achievements.CORE_MULTIKILL )
	}

	if ( !player.IsTitan() )
	{
		UnlockAchievement( player, achievements.PILOT_TITANKILL )
	}

	// don't count vortex refire for core kills
	int scriptDamageType = DamageInfo_GetCustomDamageType( damageInfo )
	if ( scriptDamageType & DF_VORTEX_REFIRE )
		return

	switch ( damageSourceId )
	{
		case eDamageSourceId.mp_titancore_salvo_core:
			UnlockAchievement( player, achievements.CORE_SALVO )
			break
		case eDamageSourceId.mp_titancore_laser_cannon:
			UnlockAchievement( player, achievements.CORE_LASER )
			break
		case eDamageSourceId.mp_titancore_flame_wave:
		case eDamageSourceId.mp_titancore_flame_wave_secondary:
			UnlockAchievement( player, achievements.CORE_FLAME )
			break
		case eDamageSourceId.mp_titancore_shift_core:
			UnlockAchievement( player, achievements.CORE_SWORD )
			break
		case eDamageSourceId.mp_titanweapon_flightcore_rockets:
			UnlockAchievement( player, achievements.CORE_FLIGHT )
			break
		case eDamageSourceId.mp_titancore_amp_core:
			UnlockAchievement( player, achievements.CORE_BURST )
			break
		case eDamageSourceId.mp_titanweapon_predator_cannon:
			array<string> weaponMods = GetWeaponModsFromDamageInfo( damageInfo )
			if ( weaponMods.contains( "Smart_Core" ) )
			{
				UnlockAchievement( player, achievements.CORE_SMART )
			}
			break
	}
}

// this gets called whenever a core is started
void function ResetCoreKillCounter()
{
	file.coreKillCounter = 0
}