global function Progression_Init
global function ProgressionEnabledForPlayer
#if CLIENT || UI
global function Progression_SetPreference
global function Progression_GetPreference
global function UpdateCachedLoadouts_Delayed
#endif

#if SP // literally just stub the global functions and call it a day

void function Progression_Init() {}
bool function ProgressionEnabledForPlayer( entity player ) { return false }
#if CLIENT || UI
void function Progression_SetPreference( bool enabled ) {}
bool function Progression_GetPreference() { return false }
void function UpdateCachedLoadouts_Delayed() {}
#endif // CLIENT || UI

#else // MP || UI basically

// SO FOR SOME GOD DAMN REASON, PUTTING THESE INTO ONE STRUCT
// AND PUTTING THE #if STUFF AROUND THE VARS CAUSES A COMPILE
// ERROR, SO I HAVE TO DO THIS AWFULNESS

#if SERVER
struct {
	table<entity, bool> progressionEnabled
} file
#else // UI || CLIENT
struct {
	bool isUpdatingCachedLoadouts = false
} file
#endif


void function Progression_Init()
{
	#if SERVER
	AddCallback_OnClientDisconnected( OnClientDisconnected )
	AddClientCommandCallback( "ns_progression", ClientCommand_SetProgression )
	AddClientCommandCallback( "ns_resettitanaegis", ClientCommand_ResetTitanAegis )
	AddCallback_GameStateEnter( eGameState.Playing, OnPlaying )
	#elseif CLIENT
	AddCallback_OnClientScriptInit( OnClientScriptInit )
	#endif
}

bool function ProgressionEnabledForPlayer( entity player )
{
	#if SERVER
	if ( player in file.progressionEnabled )
		return file.progressionEnabled[player]
	
	return false
	#else // CLIENT || UI
	return GetConVarBool( "ns_progression_enabled" )
	#endif
}

#if SERVER
void function OnPlaying()
{
	SetUIVar( level, "penalizeDisconnect", false ) // dont show the "you will lose merits thing"
}

void function OnClientDisconnected( entity player )
{
	// cleanup table when player leaves
	if ( player in file.progressionEnabled )
		delete file.progressionEnabled[player]
}

bool function ClientCommand_SetProgression( entity player, array<string> args )
{
	if ( args.len() != 1 )
		return false
	if ( args[0] != "0" && args[0] != "1" )
		return false
	
	file.progressionEnabled[player] <- args[0] == "1"

	// loadout validation when progression is turned on
	if ( file.progressionEnabled[player] )
		ValidateEquippedItems( player )

	return true
}

/// Resets a specific Titan's Aegis rank back to `0`
/// * `player` - The player entity to perform the action on
/// * `args` - The arguments passed from the client command. `args[0]` should be an integer corresponding to the index of the Titan to reset.
///
/// Returns `true` on success and `false` on missing args.
bool function ClientCommand_ResetTitanAegis( entity player, array<string> args )
{
	if ( !args.len() )
		return false
	
	int suitIndex = args[0].tointeger()
	player.SetPersistentVar( "titanFDUnlockPoints[" + suitIndex + "]", 0 )
	player.SetPersistentVar( "previousFDUnlockPoints[" + suitIndex + "]", 0 )
	player.SetPersistentVar( "fdTitanXP[" + suitIndex + "]", 0 )
	player.SetPersistentVar( "fdPreviousTitanXP[" + suitIndex + "]", 0 )
	
	// Refresh Highest Aegis Titan since we might get all of them back to 1 if players wants
	RecalculateHighestTitanFDLevel( player )
	
	return true
}
#endif

#if CLIENT
void function OnClientScriptInit( entity player )
{
	// unsure if this is needed, just being safe
	if ( player != GetLocalClientPlayer() )
		return

	Progression_SetPreference( GetConVarBool( "ns_progression_enabled" ) )
	UpdateCachedLoadouts_Delayed()
}
#endif

#if CLIENT || UI
void function Progression_SetPreference( bool enabled )
{
	SetConVarBool( "ns_progression_enabled", enabled )

	#if CLIENT
	GetLocalClientPlayer().ClientCommand( "ns_progression " + enabled.tointeger() )
	#else // UI
	ClientCommand( "ns_progression " + enabled.tointeger() )
	#endif
}

bool function Progression_GetPreference()
{
	return GetConVarBool( "ns_progression_enabled" )
}

void function UpdateCachedLoadouts_Delayed()
{
	if ( file.isUpdatingCachedLoadouts )
		return

	file.isUpdatingCachedLoadouts = true

	#if UI
	RunClientScript( "UpdateCachedLoadouts_Delayed" ) // keep client and UI synced
	#else // CLIENT
	RunUIScript( "UpdateCachedLoadouts_Delayed" ) // keep client and UI synced
	#endif

	thread UpdateCachedLoadouts_Threaded()
}

void function UpdateCachedLoadouts_Threaded()
{
	wait 1.0 // give the server time to network our new persistence

	UpdateCachedLoadouts()

	// below here is just making all the menu models update properly and such

	#if UI
	uiGlobal.pilotSpawnLoadoutIndex = GetPersistentSpawnLoadoutIndex( GetUIPlayer(), "pilot" )
	uiGlobal.titanSpawnLoadoutIndex = GetPersistentSpawnLoadoutIndex( GetUIPlayer(), "titan" )
	#endif

	#if CLIENT
	entity player = GetLocalClientPlayer()
	ClearAllTitanPreview( player )
	ClearAllPilotPreview( player )
	UpdateTitanModel( player, GetPersistentSpawnLoadoutIndex( player, "titan" ) )
	UpdatePilotModel( player, GetPersistentSpawnLoadoutIndex( player, "pilot" ) )
	#endif

	file.isUpdatingCachedLoadouts = false
}
#endif

#if SERVER
void function ValidateEquippedItems( entity player )
{
	printt( "VALIDATING EQUIPPED ITEMS FOR PLAYER: " + player.GetPlayerName() )

	// banner
	CallingCard card = PlayerCallingCard_GetActive( player )
	if ( IsItemLocked( player, card.ref ) )
	{
		printt( "- BANNER CARD IS LOCKED, RESETTING" )
		PlayerCallingCard_SetActiveByRef( player, "callsign_16_col" ) // copied from _persistentdata.gnut
	}

	// patch
	CallsignIcon icon = PlayerCallsignIcon_GetActive( player )
	if ( IsItemLocked( player, icon.ref ) )
	{
		printt( "- BANNER PATCH IS LOCKED, RESETTING" )
		PlayerCallsignIcon_SetActiveByRef( player, "gc_icon_titanfall" ) // copied from _persistentdata.gnut
	}

	// faction
	int factionIndex = player.GetPersistentVarAsInt( "factionChoice" )
	string factionRef = PersistenceGetEnumItemNameForIndex( "faction", factionIndex )
	if ( IsItemLocked( player, factionRef ) )
	{
		printt( "- FACTION IS LOCKED, RESETTING" )
		player.SetPersistentVar( "factionChoice", "faction_marauder" ) // im so sorry that i am setting you to use sarah, you don't deserve this
	}
	
	// boost
	BurnReward reward = BurnReward_GetById( player.GetPersistentVarAsInt( "burnmeterSlot" ) )
	if ( IsItemLocked( player, reward.ref ) )
	{
		printt( "- BOOST IS LOCKED, RESETTING" )
		player.SetPersistentVar( "burnmeterSlot", BurnReward_GetByRef( "burnmeter_amped_weapons" ).id )
	}

	// titan loadouts
	for ( int titanLoadoutIndex = 0; titanLoadoutIndex < NUM_PERSISTENT_TITAN_LOADOUTS; titanLoadoutIndex++ )
	{
		printt( "- VALIDATING TITAN LOADOUT: " + titanLoadoutIndex )

		bool isSelected = titanLoadoutIndex == player.GetPersistentVarAsInt( "titanSpawnLoadout.index" )
		TitanLoadoutDef loadout = GetTitanLoadout( player, titanLoadoutIndex )
		TitanLoadoutDef defaultLoadout = shGlobal.defaultTitanLoadouts[titanLoadoutIndex]

		printt( "  - CHASSIS: " + loadout.titanClass )

		// passive1 - "Titan Kit" (things like overcore)
		if ( loadout.passive1 != defaultLoadout.passive1 && IsSubItemLocked( player, loadout.passive1, loadout.titanClass ) )
		{
			printt( "  - TITAN KIT EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].passive1", defaultLoadout.passive1 )
		}

		// passive2 - "<chassis> Kit" (things like zero point tripwire)
		if ( loadout.passive2 != defaultLoadout.passive2 && IsSubItemLocked( player, loadout.passive2, loadout.titanClass ) )
		{
			printt( "  - CHASSIS KIT EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].passive2", defaultLoadout.passive2 )
		}

		// passive3 - "Titanfall Kit" (warpfall/dome shield)
		if ( loadout.passive3 != defaultLoadout.passive3 && IsSubItemLocked( player, loadout.passive3, loadout.titanClass ) )
		{
			printt( "  - TITANFALL KIT EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].passive3", defaultLoadout.passive3 )
		}

		// passive4 - monarch core 1
		if ( loadout.passive4 != defaultLoadout.passive4 && IsSubItemLocked( player, loadout.passive4, loadout.titanClass ) )
		{
			printt( "  - MONARCH CORE 1 KIT EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].passive4", defaultLoadout.passive4 )
		}

		// passive5 - monarch core 2
		if ( loadout.passive5 != defaultLoadout.passive5 && IsSubItemLocked( player, loadout.passive5, loadout.titanClass ) )
		{
			printt( "  - MONARCH CORE 2 KIT EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].passive5", defaultLoadout.passive5 )
		}

		// passive6 - monarch core 3
		if ( loadout.passive6 != defaultLoadout.passive6 && IsSubItemLocked( player, loadout.passive6, loadout.titanClass ) )
		{
			printt( "  - MONARCH CORE 3 KIT EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].passive6", defaultLoadout.passive6 )
		}

		// titanExecution
		if ( !IsRefValid( loadout.titanExecution ) || !IsValidTitanExecution( titanLoadoutIndex, "titanExecution", "", loadout.titanExecution ) )
		{
			printt( "  - TITAN EXECUTION IS INVALID FOR CHASSIS, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].titanExecution", defaultLoadout.titanExecution )
		}
		else if ( IsItemLocked( player, loadout.titanExecution ) )
		{
			printt( "  - TITAN EXECUTION EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].titanExecution", defaultLoadout.titanExecution )
		}
		else if ( GetItemData( loadout.titanExecution ).reqPrime && IsItemLocked( player, loadout.primeTitanRef ) )
		{
			printt( "  - PRIME TITAN EXECUTION EQUIPPED WHEN PRIME TITAN IS LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].titanExecution", defaultLoadout.titanExecution )
		}

		// skinIndex
		// camoIndex
		if ( loadout.skinIndex == TITAN_SKIN_INDEX_CAMO )
		{
			array<ItemData> camoSkins = GetAllItemsOfType( eItemTypes.CAMO_SKIN_TITAN )
			if ( loadout.camoIndex >= camoSkins.len() || loadout.camoIndex < 0 )
			{
				printt( "  - INVALID TITAN CAMO/SKIN, RESETTING" )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].skinIndex", defaultLoadout.skinIndex )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].camoIndex", defaultLoadout.camoIndex )
			}
			else
			{
				ItemData camoSkin = camoSkins[loadout.camoIndex]
				if ( IsSubItemLocked( player, camoSkin.ref, loadout.titanClass ) )
				{
					printt( "  - TITAN CAMO/SKIN EQUIPPED WHEN LOCKED, RESETTING" )
					player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].skinIndex", defaultLoadout.skinIndex )
					player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].camoIndex", defaultLoadout.camoIndex )
				}
			}
		}
		else if ( loadout.skinIndex == 0 )
		{
			if ( loadout.camoIndex != 0 )
			{
				printt( "  - INVALID TITAN CAMO/SKIN, RESETTING" )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].skinIndex", defaultLoadout.skinIndex )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].camoIndex", defaultLoadout.camoIndex )
			}
		}
		else
		{
			string ref = GetSkinRefFromTitanClassAndPersistenceValue( loadout.titanClass, loadout.skinIndex )
			if ( ref == INVALID_REF )
			{
				printt( "  - INVALID TITAN WARPAINT, RESETTING" )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].skinIndex", defaultLoadout.skinIndex )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].camoIndex", defaultLoadout.camoIndex )
			}
			else if ( IsSubItemLocked( player, ref, loadout.titanClass ) )
			{
				printt( "  - TITAN WARPAINT EQUIPPED WHEN LOCKED, RESETTING" )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].skinIndex", defaultLoadout.skinIndex )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].camoIndex", defaultLoadout.camoIndex )
			}
		}

		// decalIndex
		string noseArtRef = GetNoseArtRefFromTitanClassAndPersistenceValue( loadout.titanClass, loadout.decalIndex )
		if ( loadout.decalIndex != defaultLoadout.decalIndex && IsSubItemLocked( player, noseArtRef, loadout.titanClass ) )
		{
			printt( "  - NOSE ART EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].decalIndex", defaultLoadout.decalIndex )
		}

		// primarySkinIndex
		// primaryCamoIndex
		if ( loadout.primarySkinIndex == WEAPON_SKIN_INDEX_CAMO )
		{
			array<ItemData> camoSkins = GetAllItemsOfType( eItemTypes.CAMO_SKIN )
			if ( loadout.primaryCamoIndex >= camoSkins.len() || loadout.primaryCamoIndex < 0 )
			{
				printt( "  - INVALID WEAPON CAMO/SKIN, RESETTING" )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primarySkinIndex", defaultLoadout.primarySkinIndex )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primaryCamoIndex", defaultLoadout.primaryCamoIndex )
			}
			else
			{
				ItemData camoSkin = camoSkins[loadout.primaryCamoIndex]
				if ( IsSubItemLocked( player, camoSkin.ref, loadout.titanClass ) )
				{
					printt( "  - WEAPON CAMO/SKIN EQUIPPED WHEN LOCKED, RESETTING" )
					player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primarySkinIndex", defaultLoadout.primarySkinIndex )
					player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primaryCamoIndex", defaultLoadout.primaryCamoIndex )
				}
			}
		}
		else if ( loadout.primarySkinIndex == 0 && loadout.primaryCamoIndex != 0 )
		{
			// titan weapons do not have skins, if we ever do add them lots of stuff will 
			//need a refactor outside of here so with that being said, i cannot be bothered
			printt( "  - INVALID WEAPON CAMO/SKIN, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primarySkinIndex", defaultLoadout.primarySkinIndex )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primaryCamoIndex", defaultLoadout.primaryCamoIndex )
		}
		

		// isPrime
		if ( loadout.isPrime == "titan_is_prime" && IsItemLocked( player, loadout.primeTitanRef ) )
		{
			printt( "  - PRIME TITAN EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].isPrime", defaultLoadout.isPrime )
		}

		// primeSkinIndex
		// primeCamoIndex
		if ( loadout.primeSkinIndex == TITAN_SKIN_INDEX_CAMO )
		{
			array<ItemData> camoSkins = GetAllItemsOfType( eItemTypes.CAMO_SKIN_TITAN )
			if ( loadout.primeCamoIndex >= camoSkins.len() || loadout.primeCamoIndex < 0 )
			{
				printt( "  - INVALID TITAN CAMO/SKIN, RESETTING" )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeSkinIndex", defaultLoadout.primeSkinIndex )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeCamoIndex", defaultLoadout.primeCamoIndex )
			}
			else
			{
				ItemData camoSkin = camoSkins[loadout.primeCamoIndex]
				if ( IsSubItemLocked( player, camoSkin.ref, loadout.titanClass ) )
				{
					printt( "  - TITAN CAMO/SKIN EQUIPPED WHEN LOCKED, RESETTING" )
					player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeSkinIndex", defaultLoadout.primeSkinIndex )
					player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeCamoIndex", defaultLoadout.primeCamoIndex )
				}
			}
		}
		else if ( loadout.primeSkinIndex == 0 )
		{
			if ( loadout.primeCamoIndex != 0 )
			{
				printt( "  - INVALID TITAN CAMO/SKIN, RESETTING" )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeSkinIndex", defaultLoadout.primeSkinIndex )
				player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeCamoIndex", defaultLoadout.primeCamoIndex )
			}
		}
		else
		{
			printt( "  - INVALID PRIME TITAN SKIN, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeSkinIndex", defaultLoadout.primeSkinIndex )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeCamoIndex", defaultLoadout.primeCamoIndex )
		}

		// primeDecalIndex
		string primeNoseArtRef = GetNoseArtRefFromTitanClassAndPersistenceValue( loadout.titanClass, loadout.primeDecalIndex )
		if ( loadout.primeDecalIndex != defaultLoadout.primeDecalIndex && IsSubItemLocked( player, primeNoseArtRef, loadout.titanClass ) )
		{
			printt( "  - PRIME NOSE ART EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].primeDecalIndex", defaultLoadout.primeDecalIndex )
		}

		// showArmBadge - equipped and shouldnt be able to
		if ( loadout.showArmBadge && !CanEquipArmBadge( player, loadout.titanClass ) )
		{
			printt( "  - ARM BADGE EQUIPPED WHEN LOCKED, RESETTING" )
			player.SetPersistentVar( "titanLoadouts[" + titanLoadoutIndex + "].showArmBadge", defaultLoadout.showArmBadge )
		}

		// equipped titan loadout - equipped titan class is locked
		if ( isSelected && IsItemLocked( player, loadout.titanClass ) )
		{
			printt( "  - SELECTED TITAN CLASS IS LOCKED, RESETTING" )
			player.SetPersistentVar( "titanSpawnLoadout.index", 0 )
			Remote_CallFunction_NonReplay( player, "ServerCallback_UpdateTitanModel", 0 )
		}
	}

	Remote_CallFunction_NonReplay( player, "ServerCallback_UpdateTitanModel", player.GetPersistentVarAsInt( "titanSpawnLoadout.index" ) )

	// pilot loadouts
	for ( int pilotLoadoutIndex = 0; pilotLoadoutIndex < NUM_PERSISTENT_PILOT_LOADOUTS; pilotLoadoutIndex++ )
	{
		printt( "- VALIDATING PILOT LOADOUT: " + pilotLoadoutIndex )

		bool isSelected = pilotLoadoutIndex == player.GetPersistentVarAsInt( "pilotSpawnLoadout.index" )
		PilotLoadoutDef loadout = GetPilotLoadout( player, pilotLoadoutIndex )
		PilotLoadoutDef defaultLoadout = shGlobal.defaultPilotLoadouts[pilotLoadoutIndex]

		// note: for readability, I have added {} around the different items,
		// so that you can collapse them in visual studio code (and other good IDEs)

		// tactical
		{
			if ( !IsRefValid( loadout.suit ) )
			{
				printt( "  - TACTICAL IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].suit", defaultLoadout.suit )
			}
			else if ( IsItemLocked( player, loadout.suit ) )
			{
				printt( "  - TACTICAL IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].suit", defaultLoadout.suit )
			}
		}
		
		// ordnance
		{
			if ( !IsRefValid( loadout.ordnance ) )
			{
				printt( "  - ORDNANCE IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].ordnance", defaultLoadout.ordnance )
			}
			else if ( IsItemLocked( player, loadout.ordnance ) )
			{
				printt( "  - ORDNANCE IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].ordnance", defaultLoadout.ordnance )
			}
		}

		// race ( gender )
		{
			if ( !IsRefValid( loadout.race ) )
			{
				printt( "  - GENDER IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].race", defaultLoadout.race )
			}
			else if ( IsItemLocked( player, loadout.race ) )
			{
				printt( "  - GENDER IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].race", defaultLoadout.race )
			}
		}

		// camoIndex
		// skinIndex
		{
			if ( loadout.skinIndex == PILOT_SKIN_INDEX_CAMO )
			{
				array<ItemData> camoSkins = GetAllItemsOfType( eItemTypes.CAMO_SKIN_PILOT )
				if ( loadout.camoIndex >= camoSkins.len() || loadout.camoIndex < 0 )
				{
					printt( "  - INVALID PILOT CAMO/SKIN, RESETTING" )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].skinIndex", defaultLoadout.skinIndex )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].camoIndex", defaultLoadout.camoIndex )
				}
				else
				{
					ItemData camoSkin = camoSkins[loadout.camoIndex]
					if ( IsItemLocked( player, camoSkin.ref ) )
					{
						printt( "  - PILOT CAMO/SKIN EQUIPPED WHEN LOCKED, RESETTING" )
						player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].skinIndex", defaultLoadout.skinIndex )
						player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].camoIndex", defaultLoadout.camoIndex )
					}
				}
			}
			else if ( loadout.skinIndex == 0 )
			{
				if ( loadout.camoIndex != 0 )
				{
					printt( "  - INVALID PILOT CAMO/SKIN, RESETTING" )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].skinIndex", defaultLoadout.skinIndex )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].camoIndex", defaultLoadout.camoIndex )
				}
			}
			else
			{
				// pilots can't have skins other than 0 and 1 right?
				printt( "  - INVALID PILOT SKIN, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].skinIndex", defaultLoadout.skinIndex )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].camoIndex", defaultLoadout.camoIndex )
			}
		}

		// primary weapon
		{
			if ( !IsRefValid( loadout.primary ) || GetItemType( loadout.primary ) != eItemTypes.PILOT_PRIMARY )
			{
				printt( "  - PRIMARY WEAPON IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primary", defaultLoadout.primary )
			}
			else if ( IsItemLocked( player, loadout.primary ) )
			{
				printt( "  - PRIMARY WEAPON IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primary", defaultLoadout.primary )
			}
		}

		// primary weapon mods
		{
			// mod1
			if ( loadout.primaryMod1 == "" )
			{
				// do nothing
			}
			else if ( !HasSubitem( loadout.primary, loadout.primaryMod1 ) )
			{
				printt( "  - PRIMARY WEAPON MOD 1 IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primaryMod1", defaultLoadout.primaryMod1 )
			}
			else if ( IsSubItemLocked( player, loadout.primaryMod1, loadout.primary ) )
			{
				printt( "  - PRIMARY WEAPON MOD 1 IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primaryMod1", defaultLoadout.primaryMod1 )
			}
			// mod2
			if ( loadout.primaryMod2 == "" )
			{
				// do nothing
			}
			else if ( IsSubItemLocked( player, "primarymod2", loadout.primary ) )
			{
				printt( "  - PRIMARY WEAPON MOD 2 SLOT IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primaryMod2", defaultLoadout.primaryMod2 )
			}
			else if ( !HasSubitem( loadout.primary, loadout.primaryMod2 ) )
			{
				printt( "  - PRIMARY WEAPON MOD 2 IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primaryMod2", defaultLoadout.primaryMod2 )
			}
			else if ( IsSubItemLocked( player, loadout.primaryMod2, loadout.primary ) )
			{
				printt( "  - PRIMARY WEAPON MOD 2 IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primaryMod2", defaultLoadout.primaryMod2 )
			}
			else if ( loadout.primaryMod2 == loadout.primaryMod1 && loadout.primaryMod2 != "" )
			{
				printt( "  - PRIMARY WEAPON MOD 2 IS DUPLICATE, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primaryMod2", defaultLoadout.primaryMod2 )
			}
			else if ( loadout.primaryAttachment == "threat_scope" )
			{
				printt( "  - PRIMARY WEAPON MOD 2 IS SET WITH THREAT SCOPE, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primaryMod2", defaultLoadout.primaryMod2 )
			}
			// attachment
			if ( loadout.primaryAttachment == "" )
			{
				// do nothing
			}
			else if ( !HasSubitem( loadout.primary, loadout.primaryAttachment ) )
			{
				printt( "  - PRIMARY WEAPON ATTACHMENT IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primaryAttachment", defaultLoadout.primaryAttachment )
			}
			else if ( IsSubItemLocked( player, loadout.primaryAttachment, loadout.primary ) )
			{
				printt( "  - PRIMARY WEAPON ATTACHMENT IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primaryAttachment", defaultLoadout.primaryAttachment )
			}
			// mod3 (pro screen)
			if ( loadout.primaryMod3 == "" )
			{
				// do nothing
			}
			else if ( loadout.primaryMod3 == "pro_screen" )
			{
				// fuck you and your three mod slot stuff
				printt( "  - PRIMARY WEAPON PRO SCREEN IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primaryMod3", defaultLoadout.primaryMod3 )
			}
			else if ( IsSubItemLocked( player, loadout.primaryMod3, loadout.primary ) )
			{
				printt( "  - PRIMARY WEAPON PRO SCREEN IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primaryMod3", defaultLoadout.primaryMod3 )
			}
		}

		// primary weapon camoIndex
		// primary weapon skinIndex
		{
			if ( loadout.primarySkinIndex == WEAPON_SKIN_INDEX_CAMO )
			{
				array<ItemData> camoSkins = GetAllItemsOfType( eItemTypes.CAMO_SKIN )
				if ( loadout.primaryCamoIndex >= camoSkins.len() || loadout.primaryCamoIndex < 0 )
				{
					printt( "  - INVALID PRIMARY WEAPON CAMO/SKIN, RESETTING" )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primarySkinIndex", defaultLoadout.primarySkinIndex )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primaryCamoIndex", defaultLoadout.primaryCamoIndex )
				}
				else
				{
					ItemData camoSkin = camoSkins[loadout.primaryCamoIndex]
					if ( IsSubItemLocked( player, camoSkin.ref, loadout.primary ) )
					{
						printt( "  - PRIMARY WEAPON CAMO/SKIN EQUIPPED WHEN LOCKED, RESETTING" )
						player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primarySkinIndex", defaultLoadout.primarySkinIndex )
						player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primaryCamoIndex", defaultLoadout.primaryCamoIndex )
					}
				}
			}
			else if ( loadout.primarySkinIndex == 0 )
			{
				if ( loadout.primaryCamoIndex != 0 )
				{
					printt( "  - INVALID PRIMARY WEAPON CAMO/SKIN, RESETTING" )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primarySkinIndex", defaultLoadout.primarySkinIndex )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primaryCamoIndex", defaultLoadout.primaryCamoIndex )
				}
			}
			else
			{
				string warpaintRef = GetWeaponWarpaintRefByIndex( loadout.primarySkinIndex, loadout.primary )
				if ( warpaintRef == INVALID_REF || IsSubItemLocked( player, warpaintRef, loadout.primary ) )
				{
					printt( "  - PRIMARY WEAPON SKIN LOCKED/INVALID, RESETTING" )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primarySkinIndex", defaultLoadout.primarySkinIndex )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].primaryCamoIndex", defaultLoadout.primaryCamoIndex )
				}
			}
		}

		// secondary weapon
		{
			if ( !IsRefValid( loadout.secondary ) || GetItemType( loadout.secondary ) != eItemTypes.PILOT_SECONDARY )
			{
				printt( "  - SECONDARY WEAPON IS LOCKED, RESETTING" )
				string ref = defaultLoadout.secondary
				if ( loadout.secondary == ref ) // item dupes swap
				{
					ref = defaultLoadout.weapon3
				}
				else if ( ItemsInSameMenuCategory( loadout.secondary, ref ) ) // category dupes assign value to other slot and swap
				{
					ref = defaultLoadout.weapon3
				}
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondary", ref )
			}
			else if ( IsItemLocked( player, loadout.secondary ) )
			{
				printt( "  - SECONDARY WEAPON IS LOCKED, RESETTING" )
				string ref = defaultLoadout.secondary
				if ( loadout.weapon3 == ref ) // item dupes swap
				{
					ref = defaultLoadout.weapon3
				}
				else if ( ItemsInSameMenuCategory( loadout.weapon3, ref ) ) // category dupes assign value to other slot and swap
				{
					ref = defaultLoadout.weapon3
				}

				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondary", ref )
			}
		}

		// secondary weapon mods
		{
			// mod1
			if ( loadout.secondaryMod1 == "" )
			{
				// do nothing
			}
			else if ( !HasSubitem( loadout.secondary, loadout.secondaryMod1 ) )
			{
				printt( "  - SECONDARY WEAPON MOD 1 IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondaryMod1", defaultLoadout.secondaryMod1 )
			}
			else if ( IsSubItemLocked( player, loadout.secondaryMod1, loadout.secondary ) )
			{
				printt( "  - SECONDARY WEAPON MOD 1 IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondaryMod1", defaultLoadout.secondaryMod1 )
			}
			// mod2
			if ( loadout.secondaryMod2 == "" )
			{
				// do nothing
			}
			else if ( IsSubItemLocked( player, "secondarymod2", loadout.secondary ) )
			{
				printt( "  - SECONDARY WEAPON MOD 2 SLOT IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondaryMod2", defaultLoadout.secondaryMod2 )
			}
			else if ( !HasSubitem( loadout.secondary, loadout.secondaryMod2 ) )
			{
				printt( "  - SECONDARY WEAPON MOD 2 IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondaryMod2", defaultLoadout.secondaryMod2 )
			}
			else if ( IsSubItemLocked( player, loadout.secondaryMod2, loadout.secondary ) )
			{
				printt( "  - SECONDARY WEAPON MOD 2 IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondaryMod2", defaultLoadout.secondaryMod2 )
			}
			else if ( loadout.secondaryMod2 == loadout.secondaryMod1 && loadout.secondaryMod2 != "" )
			{
				printt( "  - SECONDARY WEAPON MOD 2 IS DUPLICATE, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondaryMod2", defaultLoadout.secondaryMod2 )
			}
			// mod3 (pro screen)
			if ( loadout.secondaryMod3 == "" )
			{
				// do nothing
			}
			else if ( loadout.secondaryMod3 == "pro_screen" )
			{
				// fuck you and your three mod slot stuff
				printt( "  - SECONDARY WEAPON PRO SCREEN IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondaryMod3", defaultLoadout.secondaryMod3 )
			}
			else if ( IsSubItemLocked( player, "secondarymod3", loadout.secondary ) )
			{
				printt( "  - SECONDARY WEAPON PRO SCREEN IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondaryMod3", defaultLoadout.secondaryMod3 )
			}
		}

		// secondary weapon camoIndex
		// secondary weapon skinIndex
		{
			if ( loadout.secondarySkinIndex == WEAPON_SKIN_INDEX_CAMO )
			{
				array<ItemData> camoSkins = GetAllItemsOfType( eItemTypes.CAMO_SKIN )
				if ( loadout.secondaryCamoIndex >= camoSkins.len() || loadout.secondaryCamoIndex < 0 )
				{
					printt( "  - INVALID SECONDARY WEAPON CAMO/SKIN, RESETTING" )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondarySkinIndex", defaultLoadout.secondarySkinIndex )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondaryCamoIndex", defaultLoadout.secondaryCamoIndex )
				}
				else
				{
					ItemData camoSkin = camoSkins[loadout.secondaryCamoIndex]
					if ( IsSubItemLocked( player, camoSkin.ref, loadout.secondary ) )
					{
						printt( "  - SECONDARY WEAPON CAMO/SKIN EQUIPPED WHEN LOCKED, RESETTING" )
						player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondarySkinIndex", defaultLoadout.secondarySkinIndex )
						player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondaryCamoIndex", defaultLoadout.secondaryCamoIndex )
					}
				}
			}
			else if ( loadout.secondarySkinIndex == 0 )
			{
				if ( loadout.secondaryCamoIndex != 0 )
				{
					printt( "  - INVALID SECONDARY WEAPON CAMO/SKIN, RESETTING" )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondarySkinIndex", defaultLoadout.secondarySkinIndex )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondaryCamoIndex", defaultLoadout.secondaryCamoIndex )
				}
			}
			else
			{
				string warpaintRef = GetWeaponWarpaintRefByIndex( loadout.secondarySkinIndex, loadout.secondary )
				if ( warpaintRef == INVALID_REF || IsSubItemLocked( player, warpaintRef, loadout.secondary ) )
				{
					printt( "  - SECONDARY WEAPON SKIN LOCKED/INVALID, RESETTING" )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondarySkinIndex", defaultLoadout.secondarySkinIndex )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].secondaryCamoIndex", defaultLoadout.secondaryCamoIndex )
				}
			}
		}

		// weapon3
		// note: these are always eItemTypes.PILOT_SECONDARY
		{
			if ( !IsRefValid( loadout.weapon3 ) || GetItemType( loadout.weapon3 ) != eItemTypes.PILOT_SECONDARY )
			{
				printt( "  - WEAPON3 WEAPON IS LOCKED, RESETTING" )
				string ref = defaultLoadout.weapon3
				if ( loadout.weapon3 == ref ) // item dupes swap
				{
					ref = defaultLoadout.secondary
				}
				else if ( ItemsInSameMenuCategory( loadout.weapon3, ref ) ) // category dupes assign value to other slot and swap
				{
					ref = defaultLoadout.secondary
				}
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3", ref )
			}
			else if ( IsItemLocked( player, loadout.weapon3 ) )
			{
				printt( "  - TERTIARY WEAPON IS LOCKED, RESETTING" )
				string ref = defaultLoadout.weapon3
				if ( loadout.secondary == ref ) // item dupes swap
				{
					ref = defaultLoadout.secondary
				}
				else if ( ItemsInSameMenuCategory( loadout.secondary, ref ) ) // category dupes assign value to other slot and swap
				{
					ref = defaultLoadout.secondary
				}
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3", ref )
			}
		}

		// weapon3 mods
		{
			// mod1
			if ( loadout.weapon3Mod1 == "" )
			{
				// do nothing
			}
			else if ( !HasSubitem( loadout.weapon3, loadout.weapon3Mod1 ) )
			{
				printt( "  - WEAPON3 MOD 1 IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3Mod1", defaultLoadout.weapon3Mod1 )
			}
			else if ( IsSubItemLocked( player, loadout.weapon3Mod1, loadout.weapon3 ) )
			{
				printt( "  - WEAPON3 MOD 1 IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3Mod1", defaultLoadout.weapon3Mod1 )
			}
			// mod2
			if ( loadout.weapon3Mod2 == "" )
			{
				// do nothing
			}
			else if ( IsSubItemLocked( player, "secondarymod2", loadout.weapon3 ) )
			{
				printt( "  - WEAPON3 MOD 2 SLOT IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3Mod2", defaultLoadout.weapon3Mod2 )
			}
			else if ( !HasSubitem( loadout.weapon3, loadout.weapon3Mod2 ) )
			{
				printt( "  - WEAPON3 MOD 2 IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3Mod2", defaultLoadout.weapon3Mod2 )
			}
			else if ( IsSubItemLocked( player, loadout.weapon3Mod2, loadout.weapon3 ) )
			{
				printt( "  - WEAPON3 MOD 2 IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3Mod2", defaultLoadout.weapon3Mod2 )
			}
			else if ( loadout.weapon3Mod2 == loadout.weapon3Mod1 && loadout.weapon3Mod2 != "" )
			{
				printt( "  - WEAPON3 MOD 2 IS DUPLICATE, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3Mod2", defaultLoadout.weapon3Mod2 )
			}
			// mod3 (pro screen)
			if ( loadout.weapon3Mod3 == "" )
			{
				// do nothing
			}
			else if ( loadout.weapon3Mod3 != "pro_screen" )
			{
				// fuck you and your three mod slot stuff
				printt( "  - WEAPON3 PRO SCREEN IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3Mod3", defaultLoadout.weapon3Mod3 )
			}
			else if ( IsSubItemLocked( player, "secondarymod3", loadout.weapon3 ) )
			{
				printt( "  - WEAPON3 PRO SCREEN IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3Mod3", defaultLoadout.weapon3Mod3 )
			}
		}

		// weapon3 camoIndex
		// weapon3 skinIndex
		{
			if ( loadout.weapon3SkinIndex == WEAPON_SKIN_INDEX_CAMO )
			{
				array<ItemData> camoSkins = GetAllItemsOfType( eItemTypes.CAMO_SKIN )
				if ( loadout.weapon3CamoIndex >= camoSkins.len() || loadout.weapon3CamoIndex < 0 )
				{
					printt( "  - INVALID TERTIARY WEAPON CAMO/SKIN, RESETTING" )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3SkinIndex", defaultLoadout.weapon3SkinIndex )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3CamoIndex", defaultLoadout.weapon3CamoIndex )
				}
				else
				{
					ItemData camoSkin = camoSkins[loadout.weapon3CamoIndex]
					if ( IsSubItemLocked( player, camoSkin.ref, loadout.weapon3 ) )
					{
						printt( "  - TERTIARY WEAPON CAMO/SKIN EQUIPPED WHEN LOCKED, RESETTING" )
						player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3SkinIndex", defaultLoadout.weapon3SkinIndex )
						player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3CamoIndex", defaultLoadout.weapon3CamoIndex )
					}
				}
			}
			else if ( loadout.weapon3SkinIndex == 0 )
			{
				if ( loadout.weapon3CamoIndex != 0 )
				{
					printt( "  - INVALID TERTIARY WEAPON CAMO/SKIN, RESETTING" )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3SkinIndex", defaultLoadout.weapon3SkinIndex )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3CamoIndex", defaultLoadout.weapon3CamoIndex )
				}
			}
			else
			{
				string warpaintRef = GetWeaponWarpaintRefByIndex( loadout.weapon3SkinIndex, loadout.weapon3 )
				if ( warpaintRef == INVALID_REF || IsSubItemLocked( player, warpaintRef, loadout.weapon3 ) )
				{
					printt( "  - TERTIARY WEAPON SKIN LOCKED/INVALID, RESETTING" )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3SkinIndex", defaultLoadout.weapon3SkinIndex )
					player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].weapon3CamoIndex", defaultLoadout.weapon3CamoIndex )
				}
			}
		}

		// kit 1
		{
			if ( !IsRefValid( loadout.passive1 ) || GetItemType( loadout.passive1 ) != eItemTypes.PILOT_PASSIVE1 )
			{
				printt( "  - KIT 1 IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].passive1", defaultLoadout.passive1 )
			}
			else if ( IsItemLocked( player, loadout.passive1 ) )
			{
				printt( "  - KIT 1 IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].passive1", defaultLoadout.passive1 )
			}
		}

		// kit 2
		{
			if ( !IsRefValid( loadout.passive2 ) || GetItemType( loadout.passive2 ) != eItemTypes.PILOT_PASSIVE2 )
			{
				printt( "  - KIT 2 IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].passive2", defaultLoadout.passive2 )
			}
			else if ( IsItemLocked( player, loadout.passive2 ) )
			{
				printt( "  - KIT 2 IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].passive2", defaultLoadout.passive2 )
			}
		}

		// execution
		// note: not sure why defaultLoadout has this set to "", but neck snap should be default
		{
			if ( !IsRefValid( loadout.execution ) || GetItemType( loadout.execution ) != eItemTypes.PILOT_EXECUTION )
			{
				printt( "  - EXECUTION IS INVALID, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].execution", "execution_neck_snap" )
			}
			else if ( IsItemLocked( player, loadout.execution ) )
			{
				printt( "  - EXECUTION IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotLoadouts[" + pilotLoadoutIndex + "].execution", "execution_neck_snap" )
			}
		}
		
		// equipped pilot loadout
		{
			if ( isSelected && IsItemLocked( player, "pilot_loadout_" + ( pilotLoadoutIndex + 1 ) ) )
			{
				printt( "  - SELECTED PILOT LOADOUT IS LOCKED, RESETTING" )
				player.SetPersistentVar( "pilotSpawnLoadout.index", 0 )
				Remote_CallFunction_NonReplay( player, "ServerCallback_UpdatePilotModel", 0 )
			}
		}
	}

	Remote_CallFunction_NonReplay( player, "ServerCallback_UpdatePilotModel", player.GetPersistentVarAsInt( "pilotSpawnLoadout.index" ) )

	printt( "ITEM VALIDATION COMPLETE FOR PLAYER: " + player.GetPlayerName() )
}

// basically just PopulateTitanLoadoutFromPersistentData but without validation, we are doing the validation in a better way
// that doesnt just kick the player and reset the entire loadout, since we want to only reset parts of the loadout that we need
TitanLoadoutDef function GetTitanLoadout( entity player, int loadoutIndex )
{
	TitanLoadoutDef loadout

	loadout.name 				= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "name" )
	loadout.titanClass			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "titanClass" )
	loadout.primaryMod			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "primaryMod" )
	loadout.special 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "special" )
	loadout.antirodeo 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "antirodeo" )
	loadout.passive1 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive1" )
	loadout.passive2 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive2" )
	loadout.passive3 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive3" )
	loadout.passive4 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive4" )
	loadout.passive5 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive5" )
	loadout.passive6 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive6" )
	loadout.camoIndex			= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "camoIndex" )
	loadout.skinIndex			= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "skinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.decalIndex			= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "decalIndex" )
	loadout.primaryCamoIndex	= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primaryCamoIndex" )
	loadout.primarySkinIndex	= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primarySkinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.titanExecution 		= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "titanExecution" )
	loadout.showArmBadge		= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "showArmBadge" )

	//Prime Titan related vars
	loadout.isPrime			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "isPrime" )
	loadout.primeCamoIndex	= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primeCamoIndex" )
	loadout.primeSkinIndex	= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primeSkinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.primeDecalIndex	= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primeDecalIndex" )

	UpdateDerivedTitanLoadoutData( loadout )
	OverwriteLoadoutWithDefaultsForSetFile( loadout )

	return loadout
}

// basically just PopulatePilotLoadoutFromPersistentData but without validation, we are doing the validation in a better way
// that doesnt just kick the player and reset the entire loadout, since we want to only reset parts of the loadout that we need
PilotLoadoutDef function GetPilotLoadout( entity player, int loadoutIndex )
{
	PilotLoadoutDef loadout

	loadout.name 				= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "name" )
	loadout.suit 				= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "suit" )
	loadout.race 				= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "race" )
	loadout.execution 			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "execution" )
	loadout.primary 			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primary" )
	loadout.primaryAttachment	= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryAttachment" )
	loadout.primaryMod1			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod1" )
	loadout.primaryMod2			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod2" )
	loadout.primaryMod3			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod3" )
	loadout.secondary 			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondary" )
	loadout.secondaryMod1		= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod1" )
	loadout.secondaryMod2		= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod2" )
	loadout.secondaryMod3		= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod3" )
	loadout.weapon3 			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3" )
	loadout.weapon3Mod1			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3Mod1" )
	loadout.weapon3Mod2			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3Mod2" )
	loadout.weapon3Mod3			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3Mod3" )
	loadout.ordnance 			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "ordnance" )
	loadout.passive1 			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "passive1" )
	loadout.passive2 			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "passive2" )
	loadout.camoIndex			= GetPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "camoIndex" )
	loadout.skinIndex			= GetPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "skinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.primaryCamoIndex	= GetPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "primaryCamoIndex" )
	loadout.primarySkinIndex	= GetPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "primarySkinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.secondaryCamoIndex	= GetPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "secondaryCamoIndex" )
	loadout.secondarySkinIndex	= GetPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "secondarySkinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.weapon3CamoIndex	= GetPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "weapon3CamoIndex" )
	loadout.weapon3SkinIndex	= GetPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "weapon3SkinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes

	UpdateDerivedPilotLoadoutData( loadout )

	return loadout
}

bool function CanEquipArmBadge( entity player, string titanClass )
{
	string skinRef
	switch ( titanClass )
	{
		case "ion":
			skinRef = "ion_skin_fd"
			break
		case "scorch":
			skinRef = "scorch_skin_fd"
			break
		case "northstar":
			skinRef = "northstar_skin_fd"
			break
		case "ronin":
			skinRef = "ronin_skin_fd"
			break
		case "tone":
			skinRef = "tone_skin_fd"
			break
		case "legion":
			skinRef = "legion_skin_fd"
			break
		case "vanguard":
			skinRef = "monarch_skin_fd"
			break
	}

	return !IsSubItemLocked( player, skinRef, titanClass )
}

string function GetWeaponWarpaintRefByIndex( int skinIndex, string parentRef )
{
	ItemData parentItem = GetItemData( parentRef )
	foreach ( subItem in parentItem.subitems )
	{
		if ( GetSubitemType( parentRef, subItem.ref ) != eItemTypes.WEAPON_SKIN )
			continue
		if ( subItem.i.skinIndex != skinIndex )
			continue

		return subItem.ref
	}

	return INVALID_REF
}
#endif // SERVER

#endif // MP
