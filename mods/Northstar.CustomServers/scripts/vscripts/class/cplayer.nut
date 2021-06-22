untyped


global function CodeCallback_RegisterClass_CPlayer
global function PlayerDropsScriptedItems
global function IsDemigod
global function EnableDemigod
global function DisableDemigod

int __nextInputHandle = 0


global struct PlayerSlowDownEffect
{
	float slowEndTime
	float speedCap // max speed multiplier if this slow effect is active
}

function CodeCallback_RegisterClass_CPlayer()
{
	//printl( "Class Script: CPlayer" )

	CPlayer.ClassName <- "CPlayer"
	CPlayer.hasSpawned <- null
	CPlayer.hasConnected <- null
	CPlayer.isSpawning <- null
	CPlayer.isSpawningHotDroppingAsTitan <- false
	CPlayer.disableWeaponSlots <- false
	CPlayer.supportsXRay <- null

	CPlayer.lastTitanTime <- 0

	CPlayer.globalHint <- null
	CPlayer.playerClassData <- null
	CPlayer.escalation <- null
	CPlayer.pilotAbility <- null
	CPlayer.titansBuilt <- 0
	CPlayer.spawnTime <- 0
	CPlayer.serverFlags <- 0
	CPlayer.watchingKillreplayEndTime <- 0.0
	CPlayer.cloakedForever <- false
	CPlayer.stimmedForever <- false

	RegisterSignal( "OnRespawnPlayer" )
	RegisterSignal( "NewViewAnimEntity" )
	RegisterSignal( "PlayerDisconnected" )

	function CPlayer::constructor()
	{
		CBaseEntity.constructor()
	}

	function CPlayer::RespawnPlayer( ent )
	{
		this.Signal( "OnRespawnPlayer", { ent = ent } )

		// hack. Players should clear all these on spawn.
		this.ViewOffsetEntity_Clear()
		ClearPlayerAnimViewEntity( expect entity( this ) )
		this.spawnTime = Time()

		this.ClearReplayDelay()
		this.ClearViewEntity()

		// titan melee can set these vars, and they need to clear on respawn:
		this.SetOwner( null )
		this.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE


		Assert( !this.GetParent(), this + " should not have a parent yet! - Parent: " + this.GetParent() )
		Assert( this.s.respawnCount <= 1 || IsMultiplayer(), "Tried to respawn in single player, see callstack" )
		this.Code_RespawnPlayer( ent )
	}

	/*
	CPlayer.__SetTrackEntity <- CPlayer.SetTrackEntity
	function CPlayer::SetTrackEntity( ent )
	{
		printl( "\nTime " + Time() + " Ent " + ent )

		DumpStack()
		this.__SetTrackEntity( ent )
	}
	*/

	function CPlayer::GetDropEntForPoint( origin )
	{
		return null
	}


	function CPlayer::GetPlayerClassData( myClass )
	{
		Assert( myClass in this.playerClassData, myClass + " not in playerClassData" )
		return this.playerClassData[ myClass ]
	}


	function CPlayer::InitMPClasses()
	{
		this.playerClassData = {}

		Titan_AddPlayer( this )
		Wallrun_AddPlayer( this )
	}


	function CPlayer::InitSPClasses()
	{
		this.playerClassData = {}
		SetTargetName( expect entity( this ), expect string( this.GetTargetName() + this.entindex() ) )

		Titan_AddPlayer( this )
	}


	// function SpawnAsClass()
	function CPlayer::SpawnAsClass( className = null )
	{
		if ( !className )
		{
			className = this.GetPlayerClass()
		}

		switch ( className )
		{
			case level.pilotClass:
				Wallrun_OnPlayerSpawn( this )
				break

			default:
				Assert( 0, "Tried to spawn as unsupported " + className )
		}
	}


	function CPlayer::GiveScriptWeapon( weaponName, equipSlot = null )
	{
		this.scope().GiveScriptWeapon( weaponName, equipSlot )
	}

	function CPlayer::OnDeathAsClass( damageInfo )
	{
		switch ( this.GetPlayerClass() )
		{
			case "titan":
				Titan_OnPlayerDeath( expect entity( this ), damageInfo )
				break

			case level.pilotClass:
				Wallrun_OnPlayerDeath( expect entity( this ), damageInfo )
				break
		}
	}

	function CPlayer::Disconnected()
	{
		this.Signal( "_disconnectedInternal" )
		svGlobal.levelEnt.Signal( "PlayerDisconnected" )

		if ( HasSoul( expect entity( this ) ) )
		{
			thread SoulDies( expect entity( this ).GetTitanSoul(), null )
		}

		entity titan = GetPlayerTitanInMap( expect entity( this ) )
		if ( IsAlive( titan ) && titan.IsNPC() )
		{
			local soul = titan.GetTitanSoul()
			if ( IsValid( soul ) && soul.followOnly )
				FreeAutoTitan( titan )
			else
				titan.Die( null, null, { damageSourceId = eDamageSourceId.damagedef_suicide } )
			//				titan.Die()
		}

		PROTO_CleanupTrackedProjectiles( expect entity( this ) )

		if ( this.globalHint != null )
		{
			this.globalHint.Kill_Deprecated_UseDestroyInstead()
			this.globalHint = null
		}
	}


	function CPlayer::GetClassDataEnts()
	{
		local ents = []
		local added

		if ( this.playerClassData == null )
			return ents;

		foreach ( ent in this.playerClassData )
		{
			added = false

			foreach ( newent in ents )
			{
				if ( newent == ent )
				{
					added = true
					break
				}
			}

			if ( !added )
				ents.append( ent )
		}

		return ents
	}


	function CPlayer::CleanupMPClasses()
	{
	}

	function CPlayer::HasXRaySupport()
	{
		return ( this.supportsXRay != null )
	}

	function CPlayer::GiveExtraWeaponMod( mod )
	{
		if ( this.HasExtraWeaponMod( mod ) )
			return

		local mods = this.GetExtraWeaponMods()
		mods.append( mod )

		this.SetExtraWeaponMods( mods )
	}


	function CPlayer::HasExtraWeaponMod( mod )
	{
		local mods = this.GetExtraWeaponMods()
		foreach( _mod in mods )
		{
			if ( _mod == mod )
				return true
		}
		return false
	}


	function CPlayer::TakeExtraWeaponMod( mod )
	{
		if ( !this.HasExtraWeaponMod( mod ) )
			return

		local mods = this.GetExtraWeaponMods()
		mods.fastremovebyvalue( mod )

		this.SetExtraWeaponMods( mods )
	}

	function CPlayer::ClearExtraWeaponMods()
	{
		this.SetExtraWeaponMods( [] )
	}


	function CPlayer::SetPlayerPilotSettings( settingsName )
	{
		this.SetPlayerRequestedSettings( settingsName )
	}

	function CPlayer::RecordLastMatchContribution( contribution )
	{
		// replace with code function
	}

	function CPlayer::RecordLastMatchPerformance( matchPerformance )
	{
		// replace with code function
	}

	function CPlayer::RecordSkill( skill )
	{
		// replace with code function
		this.SetPersistentVar( "ranked.recordedSkill", skill )
	}

	function CPlayer::SetPlayerSettings( settings )
	{
		local oldPlayerClass = CPlayer.GetPlayerClass()

		CPlayer.SetPlayerSettingsWithMods( settings, [] )

		this.RunSettingsChangedFuncs( settings, oldPlayerClass )
	}

	function CPlayer::SetPlayerSettingsFromDataTable( pilotDataTable )
	{
		local oldPlayerClass = CPlayer.GetPlayerClass()

		local settings = pilotDataTable.playerSetFile

		local mods = pilotDataTable.playerSetFileMods

		this.SetPlayerSettingsWithMods( settings, mods )

		this.RunSettingsChangedFuncs( settings, oldPlayerClass )
	}

	function CPlayer::RunSettingsChangedFuncs( settings, oldPlayerClass )
	{
		if ( IsAlive( expect entity( this ) ) && !this.IsTitan() && GetCurrentPlaylistVarFloat( "pilot_health_multiplier", 0.0 ) != 0.0 )
		{
			float pilotHealthMultiplier = GetCurrentPlaylistVarFloat( "pilot_health_multiplier", 1.0 )
			int pilotMaxHealth = int( this.GetMaxHealth() * pilotHealthMultiplier )
			this.SetMaxHealth( pilotMaxHealth )
			this.SetHealth( pilotMaxHealth )
		}

		if ( this.IsTitan() )
		{
			entity soul = expect entity ( this.GetTitanSoul() )
			local index = PlayerSettingsNameToIndex( settings )
			soul.SetPlayerSettingsNum( index )

			foreach ( func in svGlobal.soulSettingsChangeFuncs )
			{
				func( soul )
			}
		}
	}
}

void function PlayerDropsScriptedItems( entity player )
{
	foreach ( callbackFunc in svGlobal.onPlayerDropsScriptedItemsCallbacks )
		callbackFunc( player )
}

bool function IsDemigod( entity player )
{
	return player.p.demigod
}

void function EnableDemigod( entity player )
{
	Assert( player.IsPlayer() )
	player.p.demigod = true
}

void function DisableDemigod( entity player )
{
	Assert( player.IsPlayer() )
	player.p.demigod = false
}

