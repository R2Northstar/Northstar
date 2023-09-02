#if SERVER
untyped
#endif

globalize_all_functions

global string INVALID_REF = "INVALID_REF"

void function InitDefaultLoadouts()
{
	PopulateDefaultPilotLoadouts( shGlobal.defaultPilotLoadouts )
	PopulateDefaultTitanLoadouts( shGlobal.defaultTitanLoadouts )
}

PilotLoadoutDef function GetDefaultPilotLoadout( int index )
{
	return shGlobal.defaultPilotLoadouts[ index ]
}

TitanLoadoutDef function GetDefaultTitanLoadout( int index )
{
	return shGlobal.defaultTitanLoadouts[ index ]
}

PilotLoadoutDef[NUM_PERSISTENT_PILOT_LOADOUTS] function GetDefaultPilotLoadouts()
{
	return shGlobal.defaultPilotLoadouts
}

TitanLoadoutDef[NUM_PERSISTENT_TITAN_LOADOUTS] function GetDefaultTitanLoadouts()
{
	return shGlobal.defaultTitanLoadouts
}

void function PopulateDefaultPilotLoadouts( PilotLoadoutDef[ NUM_PERSISTENT_PILOT_LOADOUTS ] loadouts )
{
	var dataTable = GetDataTable( $"datatable/default_pilot_loadouts.rpak" )

	for ( int i = 0; i < NUM_PERSISTENT_PILOT_LOADOUTS; i++ )
	{
		PilotLoadoutDef loadout = loadouts[i]
		loadout.name				= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "name" ) )
		loadout.suit				= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "suit" ) )
		loadout.race 				= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "race" ) )
		loadout.primary 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "primary" ) )
		loadout.primaryAttachment 	= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "primaryAttachment" ) )
		loadout.primaryMod1 		= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "primaryMod1" ) )
		loadout.primaryMod2 		= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "primaryMod2" ) )
		loadout.primaryMod3 		= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "primaryMod3" ) )
		loadout.secondary			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "secondary" ) )
		loadout.secondaryMod1 		= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "secondaryMod1" ) )
		loadout.secondaryMod2 		= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "secondaryMod2" ) )
		loadout.secondaryMod3 		= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "secondaryMod3" ) )
		loadout.weapon3				= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "weapon3" ) )
		loadout.weapon3Mod1 		= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "weapon3Mod1" ) )
		loadout.weapon3Mod2 		= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "weapon3Mod2" ) )
		loadout.weapon3Mod3 		= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "weapon3Mod3" ) )
		loadout.ordnance 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "ordnance" ) )
		loadout.passive1 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "passive1" ) )
		loadout.passive2 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "passive2" ) )

		//TODO: Why isn't execution initialized here?

		UpdateDerivedPilotLoadoutData( loadout, false )

		//loadout.race
		//ValidateDefaultLoadoutData( "pilot", loadout.primary )
		//ValidateWeaponSubitem( loadout.primary, loadout.primaryAttachment, eItemTypes.PILOT_PRIMARY_ATTACHMENT )
		//ValidateWeaponSubitem( loadout.primary, loadout.primaryMod1, eItemTypes.PILOT_PRIMARY_MOD )
		//ValidateWeaponSubitem( loadout.primary, loadout.primaryMod2, eItemTypes.PILOT_PRIMARY_MOD )
		Assert( ( loadout.primaryMod1 == "" && loadout.primaryMod2 == "" ) || ( loadout.primaryMod1 != loadout.primaryMod2 ), "!!! Primary mod1 and mod2 in default pilot loadout: " + loadout.name + " should be different but are both set to: " + loadout.primaryMod1 )

		//ValidateDefaultLoadoutData( "pilot", loadout.secondary )
		//ValidateWeaponSubitem( loadout.secondary, loadout.secondaryMod1, eItemTypes.PILOT_SECONDARY_MOD )
		//ValidateWeaponSubitem( loadout.secondary, loadout.secondaryMod2, eItemTypes.PILOT_SECONDARY_MOD )
		Assert( ( loadout.secondaryMod1 == "" && loadout.secondaryMod2 == "" ) || ( loadout.secondaryMod1 != loadout.secondaryMod2 ), "!!! Secondary mod1 and mod2 in default pilot loadout: " + loadout.name + " should be different but are both set to: " + loadout.secondaryMod1 )

		//ValidateDefaultLoadoutData( "pilot", loadout.weapon3 )
		//ValidateWeaponSubitem( loadout.weapon3, loadout.weapon3Mod1, eItemTypes.PILOT_SECONDARY_MOD )
		//ValidateWeaponSubitem( loadout.weapon3, loadout.weapon3Mod2, eItemTypes.PILOT_SECONDARY_MOD )
		Assert( ( loadout.weapon3Mod1 == "" && loadout.weapon3Mod2 == "" ) || ( loadout.weapon3Mod1 != loadout.weapon3Mod2 ), "!!! Weapon3 mod1 and mod2 in default pilot loadout: " + loadout.name + " should be different but are both set to: " + loadout.weapon3Mod1 )

		//ValidateDefaultLoadoutData( "pilot", loadout.ordnance )
		//ValidateDefaultLoadoutData( "pilot", loadout.special )
		//ValidateDefaultLoadoutData( "pilot", loadout.passive1 )
		//ValidateDefaultLoadoutData( "pilot", loadout.passive2 )
	}
}

void function PopulateDefaultTitanLoadouts( TitanLoadoutDef[ NUM_PERSISTENT_TITAN_LOADOUTS ] loadouts )
{
	var dataTable = GetDataTable( $"datatable/default_titan_loadouts.rpak" )

	for ( int i = 0; i < NUM_PERSISTENT_TITAN_LOADOUTS; i++ )
	{
		TitanLoadoutDef loadout = loadouts[i]
		loadout.name				= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "name" ) )
		loadout.titanClass			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "titanRef" ) )
		loadout.setFile 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "setFile" ) )
		loadout.primaryMod			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "primaryMod" ) )
		loadout.special				= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "special" ) )
		loadout.antirodeo			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "antirodeo" ) )
		loadout.passive1 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "passive1" ) )
		loadout.passive2 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "passive2" ) )
		loadout.passive3 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "passive3" ) )
		loadout.passive4 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "passive4" ) )
		loadout.passive5 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "passive5" ) )
		loadout.passive6 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "passive6" ) )
		loadout.titanExecution 		= GetLoadoutPropertyDefault( "titan", i, "titanExecution" )

		OverwriteLoadoutWithDefaultsForSetFile_ExceptSpecialAndAntiRodeo( loadout )

		//ValidateDefaultLoadoutData( "titan", loadout.setFile )
		////loadout.primaryMod
		//ValidateDefaultLoadoutData( "titan", loadout.special )
		//ValidateDefaultLoadoutData( "titan", loadout.antirodeo )
		//ValidateDefaultLoadoutData( "titan", loadout.passive1 )
		//ValidateDefaultLoadoutData( "titan", loadout.passive2 )
	}
}

void function ValidateDefaultLoadoutData( string loadoutType, string itemRef )
{
	if ( itemRef == "" )
		return

	Assert( loadoutType == "pilot" || loadoutType == "titan" )

	string tableFile = "default_" + loadoutType + "_loadouts.csv"

	Assert( ItemDefined( itemRef ), "Datatable \"" + tableFile + "\" contains an unknown item reference: " + itemRef )
	Assert( GetUnlockLevelReq( itemRef ) <= 1, "Datatable \"" + tableFile + "\" item: " + itemRef + " must be unlocked at level 1" )
}

void function ValidateWeaponSubitem( string weaponRef, string itemRef, int itemType )
{
	bool isPlayerLevelLocked = IsItemLockedForPlayerLevel( 1, weaponRef )
	bool isWeaponLevelLocked = IsItemLockedForWeaponLevel( 1, weaponRef, itemRef )

	if ( isPlayerLevelLocked || isWeaponLevelLocked )
	{
		//array<ItemData> subitems = GetAllSubitemsOfType( weaponRef, itemType )
		//foreach ( subitem in subitems )
		//{
		//	if ( !IsItemLockedForWeaponLevel( 1, weaponRef, subitem.ref ) )
		//		printt( "    ", subitem.ref )
		//}

		Assert( 0, "Subitem: " + itemRef + " for item: " + weaponRef + " should either be available by default, or changed to one of the values listed above." )
		CodeWarning( "Subitem: " + itemRef + " for item: " + weaponRef + " should either be available by default, or changed to one of the values listed above." )
	}
}

PilotLoadoutDef function GetPilotLoadoutFromPersistentData( entity player, int loadoutIndex )
{
	PilotLoadoutDef loadout
	PopulatePilotLoadoutFromPersistentData( player, loadout, loadoutIndex )

	return loadout
}

TitanLoadoutDef function GetTitanLoadoutFromPersistentData( entity player, int loadoutIndex )
{
	TitanLoadoutDef loadout
	PopulateTitanLoadoutFromPersistentData( player, loadout, loadoutIndex )

	return loadout
}

void function PopulatePilotLoadoutFromPersistentData( entity player, PilotLoadoutDef loadout, int loadoutIndex )
{
	loadout.name 				= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "name" )
	loadout.suit 				= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "suit" )
	loadout.race 				= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "race" )
	loadout.execution 			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "execution" )
	loadout.primary 			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "primary" )
	loadout.primaryAttachment	= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryAttachment" )
	loadout.primaryMod1			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod1" )
	loadout.primaryMod2			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod2" )
	loadout.primaryMod3			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod3" )
	loadout.secondary 			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondary" )
	loadout.secondaryMod1		= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod1" )
	loadout.secondaryMod2		= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod2" )
	loadout.secondaryMod3		= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod3" )
	loadout.weapon3 			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3" )
	loadout.weapon3Mod1			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3Mod1" )
	loadout.weapon3Mod2			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3Mod2" )
	loadout.weapon3Mod3			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3Mod3" )
	loadout.ordnance 			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "ordnance" )
	loadout.passive1 			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "passive1" )
	loadout.passive2 			= GetValidatedPersistentLoadoutValue( player, "pilot", loadoutIndex, "passive2" )
	loadout.camoIndex			= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "camoIndex" )
	loadout.skinIndex			= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "skinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.primaryCamoIndex	= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "primaryCamoIndex" )
	loadout.primarySkinIndex	= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "primarySkinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.secondaryCamoIndex	= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "secondaryCamoIndex" )
	loadout.secondarySkinIndex	= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "secondarySkinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.weapon3CamoIndex	= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "weapon3CamoIndex" )
	loadout.weapon3SkinIndex	= GetValidatedPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "weapon3SkinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes

	UpdateDerivedPilotLoadoutData( loadout )
}

void function PopulateTitanLoadoutFromPersistentData( entity player, TitanLoadoutDef loadout, int loadoutIndex )
{
	loadout.name 				= GetValidatedPersistentLoadoutValue( player, "titan", loadoutIndex, "name" )
	loadout.titanClass			= GetValidatedPersistentLoadoutValue( player, "titan", loadoutIndex, "titanClass" )
	loadout.primaryMod			= GetValidatedPersistentLoadoutValue( player, "titan", loadoutIndex, "primaryMod" )
	loadout.special 			= GetValidatedPersistentLoadoutValue( player, "titan", loadoutIndex, "special" )
	loadout.antirodeo 			= GetValidatedPersistentLoadoutValue( player, "titan", loadoutIndex, "antirodeo" )
	loadout.passive1 			= GetValidatedPersistentLoadoutValue( player, "titan", loadoutIndex, "passive1" )
	loadout.passive2 			= GetValidatedPersistentLoadoutValue( player, "titan", loadoutIndex, "passive2" )
	loadout.passive3 			= GetValidatedPersistentLoadoutValue( player, "titan", loadoutIndex, "passive3" )
	loadout.passive4 			= GetValidatedPersistentLoadoutValue( player, "titan", loadoutIndex, "passive4" )
	loadout.passive5 			= GetValidatedPersistentLoadoutValue( player, "titan", loadoutIndex, "passive5" )
	loadout.passive6 			= GetValidatedPersistentLoadoutValue( player, "titan", loadoutIndex, "passive6" )
	loadout.camoIndex			= GetValidatedPersistentLoadoutValueInt( player, "titan", loadoutIndex, "camoIndex" )
	loadout.skinIndex			= GetValidatedPersistentLoadoutValueInt( player, "titan", loadoutIndex, "skinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.decalIndex			= GetValidatedPersistentLoadoutValueInt( player, "titan", loadoutIndex, "decalIndex" )
	loadout.primaryCamoIndex	= GetValidatedPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primaryCamoIndex" )
	loadout.primarySkinIndex	= GetValidatedPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primarySkinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.titanExecution 		= GetValidatedPersistentLoadoutValue( player, "titan", loadoutIndex, "titanExecution" )
	loadout.showArmBadge		= GetValidatedPersistentLoadoutValueInt( player, "titan", loadoutIndex, "showArmBadge" )

	//Prime Titan related vars
	loadout.isPrime			= GetValidatedPersistentLoadoutValue( player, "titan", loadoutIndex, "isPrime" )
	loadout.primeCamoIndex	= GetValidatedPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primeCamoIndex" )
	loadout.primeSkinIndex	= GetValidatedPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primeSkinIndex" ) //Important: Skin index needs to be gotten after camoIndex for loadout validation purposes
	loadout.primeDecalIndex	= GetValidatedPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primeDecalIndex" )

	UpdateDerivedTitanLoadoutData( loadout )
	OverwriteLoadoutWithDefaultsForSetFile( loadout )
}

string function GetSetFileForTitanClassAndPrimeStatus( string titanClass, bool isPrimeTitan = false )
{
	string nonPrimeSetFile

	array<TitanLoadoutDef> legalLoadouts = GetAllowedTitanLoadouts()

	foreach ( loadout in legalLoadouts )
	{
		if ( GetTitanCharacterNameFromSetFile( loadout.setFile ) == titanClass )
		{
			nonPrimeSetFile = loadout.setFile
			break
		}
	}

	if ( !isPrimeTitan )
		return nonPrimeSetFile

	string primeSetFile = GetPrimeTitanSetFileFromNonPrimeSetFile( nonPrimeSetFile )
	Assert( primeSetFile != "" )
	return primeSetFile
}


string function GetPrimeTitanRefForTitanClass( string titanClass )
{
	array<TitanLoadoutDef> legalLoadouts = GetAllowedTitanLoadouts()

	foreach ( loadout in legalLoadouts )
	{
		if ( GetTitanCharacterNameFromSetFile( loadout.setFile ) == titanClass )
			return loadout.primeTitanRef
	}

	unreachable
}

string function GetPersistentLoadoutValue( entity player, string loadoutType, int loadoutIndex, string loadoutProperty )
{
	// printt( "=======================================================================================" )
	// printt( "loadoutType:", loadoutType, "loadoutIndex:", loadoutIndex, "loadoutProperty:" , loadoutProperty )
	// printl( "script GetPlayerArray()[0].SetPersistentVar( \"" + loadoutType + "Loadouts[" + loadoutIndex + "]." + loadoutProperty + "\", \"" + value + "\" )" )
	// printt( "=======================================================================================" )

	string getString = BuildPersistentVarAccessorString( loadoutType, loadoutIndex, loadoutProperty )
	var value = player.GetPersistentVar( getString )

	if ( value == null )
		return ""

	return string( value )
}


int function GetPersistentLoadoutValueInt( entity player, string loadoutType, int loadoutIndex, string loadoutProperty )
{
	return int( GetPersistentLoadoutValue( player, loadoutType, loadoutIndex, loadoutProperty ) )
}

string function GetPersistentLoadoutPropertyType( string loadoutProperty )
{
	switch ( loadoutProperty )
	{
		case "skinIndex":
		case "camoIndex":
		case "decalIndex":
		case "primeSkinIndex":
		case "primeCamoIndex":
		case "primeDecalIndex":
		case "primarySkinIndex":
		case "primaryCamoIndex":
		case "secondarySkinIndex":
		case "secondaryCamoIndex":
		case "weapon3SkinIndex":
		case "weapon3CamoIndex":
		case "showArmBadge":
			return "int"
	}

	return "string"
}


#if SERVER
// TODO: If we change a property that has a parent or child relationship, all related properties need updating if invalid
// 		A parent change should validate children and set invalid to defaults
// 		If a child change is invalid for the parent, it should be changed to a valid default based on the parent
// TODO: Return type. Currently getting passed to AddClientCommandCallback() which expects a bool return, but this isn't setup to return values.
function SetPersistentLoadoutValue( entity player, string loadoutType, int loadoutIndex, string loadoutProperty, string value )
{
	 //printt( "=======================================================================================" )
	 //printt( "SetPersistentLoadoutValue called with loadoutType:", loadoutType, "loadoutIndex:", loadoutIndex, "loadoutProperty:" , loadoutProperty, "value:", value )
	 //printl( "script GetPlayerArray()[0].SetPersistentVar( \"" + loadoutType + "Loadouts[" + loadoutIndex + "]." + loadoutProperty + "\", \"" + value + "\" )" )
	 //printt( "=======================================================================================" )

	bool loadoutIsPilot = ( loadoutType == "pilot" )
	bool loadoutIsTitan = ( loadoutType == "titan" )
	bool loadoutIsPilotOrTitan = ( loadoutIsPilot || loadoutIsTitan )

	//Assert( loadoutIsPilotOrTitan, "Invalid loadoutType that is not pilot or titan" )
	if ( !loadoutIsPilotOrTitan )
	{
		CodeWarning( "Loadout neither pilot or titan" )
		return
	}

	//Assert( ( loadoutIsPilot && IsValidPilotLoadoutIndex( loadoutIndex ) ) || ( loadoutIsTitan && !IsValidTitanLoadoutIndex( loadoutIndex ) ), "SetPersistentLoadoutValue() called with invalid loadoutIndex: " + loadoutIndex )

	if ( loadoutIsPilot && !IsValidPilotLoadoutIndex( loadoutIndex ) )
	{
		CodeWarning( "!IsValidPilotLoadoutIndex" )
		return
	}

	if ( loadoutIsTitan && !IsValidTitanLoadoutIndex( loadoutIndex ) )
	{
		CodeWarning( "!IsValidTitanLoadoutIndex" )
		return
	}

	if ( value == "none" )
		value = ""

	var loadoutPropertyEnum = null
	if ( loadoutIsPilot )
	{
		bool isValid = IsValidPilotLoadoutProperty( loadoutProperty )
		//Assert( IsValidPilotLoadoutProperty, "SetPersistentLoadoutValue() called with invalid pilot loadoutProperty: " + loadoutProperty )
		if ( !isValid )
		{
			CodeWarning( "!IsValidPilotLoadoutProperty" )
			return
		}

		loadoutPropertyEnum = GetPilotLoadoutPropertyEnum( loadoutProperty )
	}
	else
	{
		bool isValid = IsValidTitanLoadoutProperty( loadoutProperty )
		//Assert( isValidTitanLoadoutProperty, "SetPersistentLoadoutValue() called with invalid titan loadoutProperty: " + loadoutProperty )
		if ( !isValid )
		{
			CodeWarning( "!IsValidTitanLoadoutProperty" )
			return
		}

		loadoutPropertyEnum = GetTitanLoadoutPropertyEnum( loadoutProperty )
	}

	if ( loadoutPropertyEnum != null && !PersistenceEnumValueIsValid( loadoutPropertyEnum, value ) )
	{
		CodeWarning( loadoutType + " " + loadoutProperty + " value: " + value + " not valid in persistent data!" )
		return
	}

	if ( LoadoutPropertyRequiresItemValidation( loadoutProperty ) && value != "" )
	{
		if ( FailsLoadoutValidationCheck( player, loadoutType, loadoutIndex, loadoutProperty, value ) )
		{
			printt( "=======================================================================================" )
	 		printt( "SetPersistentLoadoutValue failed FailsLoadoutValidationCheck with loadoutType:", loadoutType, "loadoutIndex:", loadoutIndex, "loadoutProperty:" , loadoutProperty, "value:", value )
	 		printt( "=======================================================================================" )

			//Assert( false, "SetPersistentLoadoutValue() call " + loadoutType + " " + loadoutProperty + ", value: " + value + " failed FailsLoadoutValidationCheck() check!" )
			return
		}
	}

	// Only checks primary mods and attachments are valid in itemData and the parent isn't locked
	if ( !IsLoadoutSubitemValid( player, loadoutType, loadoutIndex, loadoutProperty, value ) )
	{
		CodeWarning( loadoutType + " " + loadoutProperty + " value: " + value + " failed IsLoadoutSubitemValid() check! It may not exist in itemData, or it's parent item is locked." )
		return
	}

	SetPlayerPersistentVarWithoutValidation( player, loadoutType, loadoutIndex, loadoutProperty, value )

	// Reset child properties when parent changes
	ResolveInvalidLoadoutChildValues( player, loadoutType, loadoutIndex, loadoutProperty, value )
	ValidateSkinAndCamoIndexesAsAPair( player, loadoutType, loadoutIndex, loadoutProperty, value ) //Skin and camo properties need to be set correctly as a pair

	#if HAS_THREAT_SCOPE_SLOT_LOCK
		if ( loadoutProperty.tolower() == "primaryattachment" && value == "threat_scope" )
		{
			SetPlayerPersistentVarWithoutValidation( player, loadoutType, loadoutIndex, "primaryMod2", "" )
		}
	#endif

	// TEMP client model update method
	bool updateModel = ( loadoutProperty == "suit" || loadoutProperty == "race" || loadoutProperty == "setFile" || loadoutProperty == "primary" || loadoutProperty == "isPrime" )

	if ( loadoutType == "pilot" )
	{
		player.p.pilotLoadoutChanged = true

		if ( updateModel )
			player.p.pilotModelNeedsUpdate = loadoutIndex
	}
	else
	{
		player.p.titanLoadoutChanged = true

		if ( updateModel )
			player.p.titanModelNeedsUpdate = loadoutIndex
	}

	thread UpdateCachedLoadouts()
}

string function GetRefFromLoadoutTypeIndexPropertyAndValue( entity player, string loadoutType, int index, string property, var value )
{
	bool isPilotLoadout = ( loadoutType == "pilot" )
	bool isTitanLoadout = ( loadoutType == "titan" )
	if ( !isPilotLoadout && !isTitanLoadout )
		return INVALID_REF

	switch ( property )
	{
		case "isPrime":
		{
			if ( !isTitanLoadout )
				return INVALID_REF

			if( PersistenceEnumValueIsValid( "titanIsPrimeTitan", value ) )
				return GetTitanRefFromPersistenceLoadoutIndexAndValueForIsPrime( index, expect string( value ) )
			else
				return INVALID_REF
		}

		case "camoIndex": //Camos work across all Titans, all pilots, and all weapons.
		case "primeCamoIndex":
		{
			int valueAsInt = ForceCastVarToInt( value )
			if ( !IsValidCamoIndex( valueAsInt ) ) //Note that we should have already checked for the case that we're setting a Titan's camo to -1 ( valid warpaint use case )  in FailsLoadoutValidationCheck()
			{
				return INVALID_REF
			}
			else
			{
				if ( isPilotLoadout )
					return CamoSkins_GetByIndex( valueAsInt ).pilotCamoRef
				else
					return CamoSkins_GetByIndex( valueAsInt ).titanCamoRef
			}
		}
		break

		case "primaryCamoIndex":
		case "secondaryCamoIndex":
		case "weapon3CamoIndex":
		{
			int valueAsInt = ForceCastVarToInt( value )
			if ( !IsValidCamoIndex( valueAsInt ) )
				return INVALID_REF
			else
				return CamoSkins_GetByIndex( valueAsInt ).ref
		}
		break

		case "primarySkinIndex":
		case "secondarySkinIndex":
		case "weapon3SkinIndex":
		{
			string parentProperty = GetParentLoadoutProperty( loadoutType, property )
			string weaponRef = GetPersistentLoadoutValue( player, loadoutType, index, parentProperty )
			int valueAsInt = ForceCastVarToInt( value )
			return GetSkinRefFromWeaponRefAndPersistenceValue( weaponRef, valueAsInt )
		}
		break

		case "decalIndex":
		case "primeDecalIndex": //Assume same nose arts work for both prime and non-prime titans
		{
			if ( !isTitanLoadout )
				return INVALID_REF

			string titanClass = GetDefaultTitanLoadout( index ).titanClass
			int valueAsInt = ForceCastVarToInt( value )
			return GetNoseArtRefFromTitanClassAndPersistenceValue( titanClass, valueAsInt )
		}
		break

		case "primeSkinIndex": //Primes don't have war paints, white listed skins for titans (0 and 2) should have already been handled earlier
		{
			return INVALID_REF
		}
		break

		case "skinIndex":
		{
			if ( !isTitanLoadout ) //Only titans have warpaints. White listed skins for pilots should already have been handled earlier
				return INVALID_REF

			string titanClass = GetDefaultTitanLoadout( index ).titanClass
			int valueAsInt = ForceCastVarToInt( value )
			return GetSkinRefFromTitanClassAndPersistenceValue( titanClass, valueAsInt )
		}
		break

		default:
			return string( value )
	}

	unreachable
}

bool function IsValidCamoIndex( int camoIndex )
{
	int numCamos = CamoSkins_GetCount() //Note that we should have already handled the case for a titan's camoIndex to be -1 (valid warpaint usecase) in FailsLoadoutValidationCheck
	return ((camoIndex >= 0) && (camoIndex < numCamos))
}

string function GetTitanRefFromPersistenceLoadoutIndexAndValueForIsPrime( int index, string value )
{
	bool isPrimeRef = (value == "titan_is_prime")
	string titanClass = GetDefaultTitanLoadout( index ).titanClass
	if ( isPrimeRef )
		return GetPrimeTitanRefForTitanClass( titanClass )

	return titanClass
}

bool function LoadoutPropertyRequiresItemValidation( string loadoutProperty )
{
	bool shouldSkipValidation = ( GetCurrentPlaylistVarInt( "skip_loadout_validation", 0 ) == 1 )
	if ( shouldSkipValidation )
	{
		//printt( "skip_loadout_validation" )
		return false
	}

	if ( loadoutProperty == "name" )
		return false

	if ( loadoutProperty == "showArmBadge" )
		return false

	if ( loadoutProperty == "primarySkinIndex" || loadoutProperty == "secondarySkinIndex" || loadoutProperty == "weapon3SkinIndex")
		return false

	return true
}

// Only checks primary mods and attachments are valid in itemData and the parent isn't locked
bool function IsLoadoutSubitemValid( entity player, string loadoutType, int loadoutIndex, string property, string ref )
{
	string childRef = ""

	switch ( property )
	{
		case "primaryAttachment":
		case "primaryMod1":
		case "primaryMod2":
		case "primaryMod3":
		case "secondaryMod1":
		case "secondaryMod2":
		case "secondaryMod3":
		case "weapon3Mod1":
		case "weapon3Mod2":
		case "weapon3Mod3":
			if ( loadoutType == "pilot" )
			{
				string parentProperty = GetParentLoadoutProperty( loadoutType, property )
				string loadoutString = BuildPersistentVarAccessorString( loadoutType, loadoutIndex, parentProperty )
				if ( ref != "" )
					childRef = ref
				ref = expect string( player.GetPersistentVar( loadoutString ) )
			}
			break
		case "skinIndex":
		case "camoIndex":
		case "decalIndex":
		case "primarySkinIndex":
		case "primaryCamoIndex":
		case "secondarySkinIndex":
		case "secondaryCamoIndex":
		case "weapon3SkinIndex":
		case "weapon3CamoIndex":
		case "primeSkinIndex":
		case "primeCamoIndex":
		case "primeDecalIndex":
			return true
			break
	}
	// TODO: Seems bad to pass null childRef on to some of the checks below if the property wasn't one of the above

	// invalid attachment
	if ( childRef != "" && !HasSubitem( ref, childRef ) )
		return false

	//if ( IsItemLocked( player, childRef, expect string( ref ) ) )
	//	return false

	return true
}

void function SetPlayerPersistentVarWithoutValidation( entity player, string loadoutType, int loadoutIndex, string propertyName, string value )
{
	string persistentLoadoutString = BuildPersistentVarAccessorString( loadoutType, loadoutIndex, propertyName )

	if ( GetPersistentLoadoutPropertyType( propertyName ) == "int" )
		player.SetPersistentVar( persistentLoadoutString, int( value ) )
	else
		player.SetPersistentVar( persistentLoadoutString, value )
}

string function ResetLoadoutPropertyToDefault( entity player, string loadoutType, int loadoutIndex, string propertyName )
{
	string defaultValue = GetLoadoutPropertyDefault( loadoutType, loadoutIndex, propertyName )
	SetPlayerPersistentVarWithoutValidation( player, loadoutType, loadoutIndex, propertyName, defaultValue )
	return defaultValue
}

bool function FailsLoadoutValidationCheck( entity player, string loadoutType, int loadoutIndex, string loadoutProperty, var value )
{
	//printt( "FailsLoadoutValidationCheck, player: " + player + ", loadoutType: " + loadoutType + ", loadoutIndex: " + loadoutIndex + ", loadoutProperty: " + loadoutProperty + ", value: " + value )

	int initializedVersion = player.GetPersistentVarAsInt( "initializedVersion" )
	bool previouslyInitialized = ( initializedVersion >= PERSISTENCE_INIT_VERSION )
	if ( !previouslyInitialized ) //Special case: if we're intializing from defaults/updating persistent data, don't try to reset to defaults
	{
		//printt( "!previouslyInitialized" )
		return false
	}

	if ( AllowCamoIndexToSkipValidation( loadoutType, loadoutProperty, value ) ) //Special case: Warpaints will set camoIndex
	{
//		printt( "AllowCamoIndexToSkipValidation" )
		return false
	}

	if ( AllowSkinIndexToSkipValidation( loadoutType, loadoutProperty, value ) ) //Skins need to be handled differently because they are only valid refs for warpaints, and we set values of 0, 1 and 2 for different cases
	{
//		printt( "AllowSkinIndexToSkipValidation" )
		return false
	}

	string ref = GetRefFromLoadoutTypeIndexPropertyAndValue( player, loadoutType, loadoutIndex, loadoutProperty, value )
	if ( !IsRefValid( ref ) )
	{
		printt( "!IsRefValid( " + ref + " ), generated from loadoutType: " + loadoutType + ", loadoutIndex: " + loadoutIndex + ". loadoutProperty: " + loadoutProperty + ", value: " + value )
		return true
	}

	if ( IsSettingPrimeTitanWithoutSetFile( player, loadoutType, loadoutProperty, loadoutIndex, value ) ) //Hack, working around fact that we allow setting Prime Titan value since it's entitlement based unlock.
	{
		//printt( "IsSettingPrimeTitanWithoutSetFile, player: " + player + ", ref: " + ref )
		return true
	}

	if ( FailsItemLockedValidationCheck( player, loadoutType, loadoutIndex, loadoutProperty, ref ) )
	{
		printt( "FailsItemLockedValidationCheck, player: " + player + ", ref: " + ref )
		return true
	}

	if ( !IsValueValidForLoadoutTypeIndexAndProperty( loadoutType, loadoutIndex, loadoutProperty, value, ref ) )
	{
		//printt( "!IsValueValidForLoadoutTypeIndexAndProperty, loadoutType: " + loadoutType + ", loadoutIndex: " + loadoutIndex + ", loadoutProperty: " + loadoutProperty + ", value: " + value + " ref: " + ref )
		return true
	}

	if ( ( loadoutProperty == "secondary" || loadoutProperty == "weapon3" ) && !IsValueValidForPropertyWithCategoryRestriction( player, loadoutIndex, loadoutProperty, string( value ) ) )
		return true

	//printt( "End FailsLoadoutValidationCheck" )
	return false
}

bool function IsValueValidForPropertyWithCategoryRestriction( entity player, int loadoutIndex, string targetProperty, string targetValue )
{
	Assert( targetProperty == "secondary" || targetProperty == "weapon3" )

	string otherProperty
	if ( targetProperty == "secondary" )
		otherProperty = "weapon3"
	else
		otherProperty = "secondary"

	string otherValue = GetPersistentLoadoutValue( player, "pilot", loadoutIndex, otherProperty )

	if ( ItemsInSameMenuCategory( targetValue, otherValue ) )
		return false

	return true
}

bool function FailsItemLockedValidationCheck( entity player, string loadoutType, int loadoutIndex, string loadoutProperty, string ref  )
{
	bool shouldSkipValidation = ( GetCurrentPlaylistVarInt( "skip_loadout_item_locked_validation", 0 ) == 1 )
	if ( shouldSkipValidation )
	{
		//printt( "skip_loadout_item_locked_validation" )
		return false
	}

	if ( LoadoutIsLocked( player, loadoutType, loadoutIndex ) )
	{
		//printt( "loadout of type " + loadoutType + " and index " + loadoutIndex + " is locked, skip checking if items under it are locked" )
		return false
	}

	if ( IsSubItemType( GetItemType( ref ) ) )
	{
		string parentRef = GetParentRefFromLoadoutInfoAndRef( player, loadoutType, loadoutIndex, loadoutProperty, ref )
		if ( parentRef == "" )
		{
			//printt( "parentRef == blankstring" )
			return true
		}

		if ( !SkipItemLockedCheck( player, ref, parentRef, loadoutProperty ) )
		{
			if ( IsSubItemLocked( player, ref, parentRef ) )
			{
				//printt( "IsSubItemLocked, player: " + player + ", ref: " + ref + ", parentRef: " + parentRef )
				return true
			}
		}
	}
	else
	{
		if ( !SkipItemLockedCheck( player, ref, "", loadoutProperty ) )
		{
			if ( IsItemLocked( player, ref ) ) //Somehow we are trying to get something that is locked. Might be rogue client sending bad values?
			{
				//printt( "IsItemLocked, player: " + player + ", ref: " + ref )
				return true
			}
		}
	}

	return false
}

bool function IsSettingPrimeTitanWithoutSetFile( entity player, string loadoutType, string loadoutProperty, int loadoutIndex, var value ) //Temp function, remove once all titans have prime Titans
{
	if ( loadoutType != "titan" )
		return false

	if ( loadoutProperty != "isPrime"  )
		return false

	if ( value != "titan_is_prime" )
		return false

	string titanClass = GetPersistentLoadoutValue( player, "titan", loadoutIndex, "titanClass" )

	return ( !TitanClassHasPrimeTitan( titanClass ) )
}

bool function SkipItemLockedCheck( entity player, string ref, string parentRef, string loadoutProperty ) //Hack: Skip entitlement related unlock checks for now. Can fail.
{
	if ( DevEverythingUnlocked( player ) )
		return true

	//if ( IsItemInEntitlementUnlock( ref ) && IsLobby()  ) //TODO: Look into restricting this to lobby only? But entitlement checks can fail randomly...
	if ( IsItemInEntitlementUnlock( ref, parentRef )  )
		return true

	if ( loadoutProperty == "isPrime" ) //Temp check to avoid weirdness where we can set titan_is_prime but not titan_is_not_prime because prime titan refs are not child refs of non prime titan refs. Should be able to remove this once all prime titans are in game.
		return true

	return false
}

bool function AllowCamoIndexToSkipValidation( string loadoutType, string loadoutProperty, var value ) //HACK: working around the fact that we do SetCamo( -1 ) when applying warpaints
{
	if ( loadoutProperty != "camoIndex" ) //Prime Titans currently don't have warpaints, so not supporting setting primeCamoIndex to be -1
		return false

	int valueAsInt  = ForceCastVarToInt( value )
	if ( valueAsInt == CAMO_INDEX_BASE )
		return true

	if ( loadoutType != "titan" )
		return false

	if ( valueAsInt != TITAN_WARPAINT_CAMO_INDEX )
		return false

	return true
}

bool function AllowSkinIndexToSkipValidation( string loadoutType, string loadoutProperty, var value ) //TODO: test weapon skin/camo combinations?
{
	int valueAsInt = ForceCastVarToInt( value ) //TODO: Awkward, getting around the fact that you can't do int( value )  if it's already an int.

	switch( loadoutProperty )
	{
		case "skinIndex":
		{
			if ( loadoutType == "pilot"  )
				return ( (valueAsInt == SKIN_INDEX_BASE) || (valueAsInt == PILOT_SKIN_INDEX_CAMO) )
			else
				return ( (valueAsInt == SKIN_INDEX_BASE) || (valueAsInt == TITAN_SKIN_INDEX_CAMO) ) //War paints will have different values, hence we must validate them
		}
		break

		case "primeSkinIndex": //Prime Titans don't support war paints, so should only support values of 0 and 2
		{
			return ( (valueAsInt == SKIN_INDEX_BASE) || (valueAsInt == TITAN_SKIN_INDEX_CAMO) )
		}
		break

		case "primarySkinIndex":
		case "secondarySkinIndex":
		case "weapon3SkinIndex":
		{
			return ( (valueAsInt == SKIN_INDEX_BASE) || (valueAsInt == WEAPON_SKIN_INDEX_CAMO) )
		}
		break

		default:
			return false
	}

	unreachable
}

bool function IsValueValidForLoadoutTypeIndexAndProperty( string loadoutType, int loadoutIndex, string loadoutProperty, var value, string ref )
{
	bool isTitanLoadout = (loadoutType == "titan")
	bool isPilotLoadout = (loadoutType == "pilot")
	if ( !isTitanLoadout && !isPilotLoadout )
		return false

	//Should have run IsRefValid( ref already, so should be fine just doing GetItemType( ref ) )
	int itemType = GetItemType( ref )

	//printt( "itemType : " + itemType )
	switch ( loadoutProperty )
	{
		case "suit":
			return ( (itemType == eItemTypes.PILOT_SUIT) && isPilotLoadout )

		case "race":
			return ( (itemType == eItemTypes.RACE) && isPilotLoadout )

		case "execution":
			return ( (itemType == eItemTypes.PILOT_EXECUTION) && isPilotLoadout )

		case "titanExecution":
			return ( isTitanLoadout && IsValidTitanExecution( loadoutIndex, loadoutProperty, value, ref ) )

		case "primary": //Only Pilots store their primary in persistence
			return ( (itemType == eItemTypes.PILOT_PRIMARY) && isPilotLoadout )

		case "primaryAttachment": //Only Pilots their primary in persistence
			return ( (itemType == eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT || itemType == eItemTypes.PILOT_PRIMARY_ATTACHMENT) && isPilotLoadout )

		case "primaryMod1": //Only Pilots have primary mods in persistence
		case "primaryMod2":
		case "primaryMod3":
			return ( (itemType == eItemTypes.SUB_PILOT_WEAPON_MOD || itemType == eItemTypes.PILOT_PRIMARY_MOD) && isPilotLoadout )

		case "secondary": //Only Pilots store their secondary in persistence
		case "weapon3":
			return ( (itemType == eItemTypes.PILOT_SECONDARY) && isPilotLoadout )

		case "secondaryMod1": //Only Pilots store their secondary in persistence
		case "secondaryMod2": //Only Pilots store their secondary in persistence
		case "secondaryMod3": //Only Pilots store their secondary in persistence
		case "weapon3Mod1":
		case "weapon3Mod2":
		case "weapon3Mod3":
			return ( (itemType == eItemTypes.SUB_PILOT_WEAPON_MOD || itemType == eItemTypes.PILOT_SECONDARY_MOD) && isPilotLoadout )

		case "ordnance":
			return ( (itemType == eItemTypes.PILOT_ORDNANCE) && isPilotLoadout )

		case "passive1":
			if ( isPilotLoadout )
			{
				return ( itemType == eItemTypes.PILOT_PASSIVE1 )
			}
			else
			{
				return IsValidTitanPassive( loadoutIndex, loadoutProperty, value, ref )
			}

		case "passive2":
			if ( isPilotLoadout )
				return ( itemType == eItemTypes.PILOT_PASSIVE2 )
			else
				return IsValidTitanPassive( loadoutIndex, loadoutProperty, value, ref )

		case "passive3":
		case "passive4":
		case "passive5":
		case "passive6":
			return ( isTitanLoadout && IsValidTitanPassive( loadoutIndex, loadoutProperty, value, ref ) )

		case "isPrime":
			return ( isTitanLoadout && PersistenceEnumValueIsValid( "titanIsPrimeTitan", value ) ) //Technically will be covered by enumValue checks before LoadoutValidation checks, but included here for completeness

		//TODO: Need to get ref for these correctly!
		case "skinIndex":
		case "camoIndex":
		case "primarySkinIndex":
		case "primaryCamoIndex":
		case "secondarySkinIndex":
		case "secondaryCamoIndex":
		case "weapon3SkinIndex":
		case "weapon3CamoIndex":
		case "decalIndex":
		case "primeSkinIndex":
		case "primeCamoIndex":
		case "primeDecalIndex":
			return true		// assume already validated

		case "titanClass": //Should never be able to set these things normally!
		case "primaryMod":
		case "special":
		case "antirodeo":
			string defaultValue = GetLoadoutPropertyDefault( loadoutType, loadoutIndex, loadoutProperty )
			return ( value == defaultValue )

		default:
			Assert( false, "Unknown loadoutProperty " + loadoutProperty )
			return false
	}

	unreachable
}

bool function ValidateSkinAndCamoIndexesAsAPair( entity player, string loadoutType, int loadoutIndex, string loadoutProperty, var value )
{
	bool isSkinIndex = false
	switch( loadoutProperty  )
	{
		case "skinIndex":
		case "primeSkinIndex":
		case "primarySkinIndex":
		case "secondarySkinIndex":
		case "weapon3SkinIndex":
			isSkinIndex = true
			break
	}

	if ( !isSkinIndex )
		return false

	int valueAsInt = ForceCastVarToInt( value )

	string camoProperty = GetCorrectCamoProperty( loadoutProperty )
	int camoIndexValue = GetValidatedPersistentLoadoutValueInt( player, loadoutType, loadoutIndex, camoProperty )


	//printt( "ValidateSkinAndCamoIndexesAsAPair, player: " + player + " loadouType: " + loadoutType + ", loadoutIndex: " + loadoutIndex +  ", skinProperty: " + loadoutProperty +  ", skin Value: "  + string( value ) + ", camoProperty: " + camoProperty + ", camo Value: " + camoIndexValue )

	if ( valueAsInt == SKIN_INDEX_BASE ) //Just set to default of 0, 0.
		return SetCamoIndexToValue( player, loadoutType, loadoutIndex, camoProperty, CAMO_INDEX_BASE )

	switch ( loadoutProperty )
	{
		case "skinIndex":
		{
			if (loadoutType == "pilot" ) //1 is skin for camo, only other valid value is 0
			{
				if ( valueAsInt == PILOT_SKIN_INDEX_CAMO && camoIndexValue <= CAMO_INDEX_BASE )
				{
					ResetSkinAndCamoIndexesToZero( player, loadoutType, loadoutIndex, loadoutProperty, camoProperty )
					return true
				}
			}
			else if ( loadoutType == "titan" ) //2 is skin for camos, all other skin values other than 0 are warpaints that have camo index == -1
			{
				if ( valueAsInt == TITAN_SKIN_INDEX_CAMO ) //This is a camo skin
				{
					if ( camoIndexValue <= CAMO_INDEX_BASE )
					{
						ResetSkinAndCamoIndexesToZero( player, loadoutType, loadoutIndex, loadoutProperty, camoProperty )
						return true
					}
				}
				else //i.e. this is a warpaint
				{
					return SetCamoIndexToValue( player, loadoutType, loadoutIndex, camoProperty, TITAN_WARPAINT_CAMO_INDEX ) //Set to default of -1 for warpaint
				}
			}

			break
		}

		case "primeSkinIndex": //switching between prime and non-prime doesn't have problems where skin is unlocked on non-prime but is locked on prime, so no need to return false
		{
			if ( valueAsInt == TITAN_SKIN_INDEX_CAMO && camoIndexValue <= CAMO_INDEX_BASE )
			{
				ResetSkinAndCamoIndexesToZero( player, loadoutType, loadoutIndex, loadoutProperty, camoProperty )
				return true
			}

			break
		}
		case "primarySkinIndex":
		case "secondarySkinIndex":
		case "weapon3SkinIndex": //1 is skin for camo
		{
			if ( valueAsInt == WEAPON_SKIN_INDEX_CAMO )
			{
				if ( camoIndexValue <= CAMO_INDEX_BASE )
				{
					ResetSkinAndCamoIndexesToZero( player, loadoutType, loadoutIndex, loadoutProperty, camoProperty )
					return false // HACK: Work around fact that when we switch weapons we don't do a corresponding call to set camo and skin indexes
				}
			}
			else
			{
				return SetCamoIndexToValue( player, loadoutType, loadoutIndex, camoProperty, 0 ) //Set to default of 0 for weapon skins
			}

			break
		}
	}

	return false
}

bool function SetCamoIndexToValue( entity player, string loadoutType, int loadoutIndex, string camoProperty, int setValue ) //HACK HACK: should fix dependency between skin and camo index on UI side. Remove when done.
{
	int camoIndexValue = GetPersistentLoadoutValueInt( player, loadoutType, loadoutIndex, camoProperty )

	if ( camoIndexValue == setValue )
		return false

	//printt( "SetCamoIndexToValue, player: " + player + " loadouType: " + loadoutType + ", loadoutIndex: " + loadoutIndex + ", camoProperty: " + camoProperty + ", setValue: "  + string( setValue ))

	SetPlayerPersistentVarWithoutValidation( player, loadoutType, loadoutIndex, camoProperty, string( setValue ) )

	return true
}

void function ResetSkinAndCamoIndexesToZero( entity player, string loadoutType, int loadoutIndex, string skinProperty, string camoProperty )
{
	SetPlayerPersistentVarWithoutValidation( player, loadoutType, loadoutIndex, camoProperty, "0"  )
	SetPlayerPersistentVarWithoutValidation( player, loadoutType, loadoutIndex, skinProperty, "0"  )
}

string function GetCorrectCamoProperty( string loadoutProperty ) //HACK HACK: should fix dependency between skin and camo index on UI side. Remove when done.
{
	string returnValue
	switch( loadoutProperty )
	{
		case "skinIndex":
			returnValue = "camoIndex"
			break

		case "primeSkinIndex":
			returnValue = "primeCamoIndex"
			break

		case "primarySkinIndex":
			returnValue = "primaryCamoIndex"
			break

		case "secondarySkinIndex":
			returnValue = "secondaryCamoIndex"
			break

		case "weapon3SkinIndex":
			returnValue = "weapon3CamoIndex"
			break

		default:
			unreachable
	}

	return returnValue
}

bool function IsValidTitanPassive( int loadoutIndex, string loadoutProperty, var value, string ref ) //TODO: Not using all parameters in this function yet, might need them for full validation
{
	//Should have run IsRefValid(ref already, so fine to do GetItemType( ref ))
	int itemType = GetItemType( ref )
	//printt( "itemType: " + itemType )

	switch ( loadoutProperty )
	{
		case "passive1":
			return (itemType == eItemTypes.TITAN_GENERAL_PASSIVE)

		case "passive2":
		{
			switch( loadoutIndex ) //TODO: Hard coded, not great!
			{
				case 0:
					return itemType == eItemTypes.TITAN_ION_PASSIVE

				case 1:
					return itemType == eItemTypes.TITAN_SCORCH_PASSIVE

				case 2:
					return itemType == eItemTypes.TITAN_NORTHSTAR_PASSIVE

				case 3:
					return itemType == eItemTypes.TITAN_RONIN_PASSIVE

				case 4:
					return itemType == eItemTypes.TITAN_TONE_PASSIVE

				case 5:
					return itemType == eItemTypes.TITAN_LEGION_PASSIVE

				case 6:
					return itemType == eItemTypes.TITAN_VANGUARD_PASSIVE

				default:
					return false
			}
		}

		case "passive3":
			return (itemType == eItemTypes.TITAN_TITANFALL_PASSIVE)

		case "passive4":
			return (itemType == eItemTypes.TITAN_UPGRADE1_PASSIVE)
		case "passive5":
			return (itemType == eItemTypes.TITAN_UPGRADE2_PASSIVE)
		case "passive6":
			return (itemType == eItemTypes.TITAN_UPGRADE3_PASSIVE)

		default:
			unreachable
	}

	unreachable
}

bool function IsValidTitanExecution( int loadoutIndex, string loadoutProperty, var value, string ref ) //TODO: Not using all parameters in this function yet, might need them for full validation
{
	//Should have run IsRefValid(ref already, so fine to do GetItemType( ref ))
	int itemType = GetItemType( ref )
	//printt( "itemType: " + itemType )

	switch ( loadoutProperty )
	{
		case "titanExecution":
		{
			switch( loadoutIndex ) //TODO: Hard coded, not great!
			{
				case 0:
					return itemType == eItemTypes.TITAN_ION_EXECUTION

				case 1:
					return itemType == eItemTypes.TITAN_SCORCH_EXECUTION

				case 2:
					return itemType == eItemTypes.TITAN_NORTHSTAR_EXECUTION

				case 3:
					return itemType == eItemTypes.TITAN_RONIN_EXECUTION

				case 4:
					return itemType == eItemTypes.TITAN_TONE_EXECUTION

				case 5:
					return itemType == eItemTypes.TITAN_LEGION_EXECUTION

				case 6:
					return itemType == eItemTypes.TITAN_VANGUARD_EXECUTION

				default:
					return false
			}
		}

		default:
			unreachable
	}

	unreachable
}

string function GetParentRefFromLoadoutInfoAndRef( entity player, string loadoutType, int loadoutIndex, string property, string childRef  )
{
	bool isPilotLoadout = (loadoutType == "pilot")
	bool isTitanLoadout = (loadoutType == "titan")
	if ( !isPilotLoadout && !isTitanLoadout )
		return ""

	switch ( property )
	{
		case "primaryAttachment":
		case "primaryMod1":
		case "primaryMod2":
		case "primaryMod3":
		case "secondaryMod1":
		case "secondaryMod2":
		case "secondaryMod3":
		case "weapon3Mod1":
		case "weapon3Mod2":
		case "weapon3Mod3":
		{
			string parentProperty = GetParentLoadoutProperty( loadoutType, property )
			string loadoutString = BuildPersistentVarAccessorString( loadoutType, loadoutIndex, parentProperty )
			string resultString = string( player.GetPersistentVar( loadoutString ) ) //titanLoadouts[5].titanClass
			if ( HasSubitem( resultString, childRef ) )
				return resultString
			else
				return ""
		}

		case "passive1":
		case "passive2":
		case "passive3":
		case "passive4":
		case "passive5":
		case "passive6":
		{
			if ( isTitanLoadout && !IsValidTitanPassive( loadoutIndex, property, childRef, childRef ) )
				return ""

			string parentProperty = GetParentLoadoutProperty( loadoutType, property )
			string loadoutString = BuildPersistentVarAccessorString( loadoutType, loadoutIndex, parentProperty )
			string resultString = string( player.GetPersistentVar( loadoutString ) ) //titanLoadouts[5].titanClass
			if ( HasSubitem( resultString, childRef ) )
				return resultString
			else
				return ""
		}

		case "skinIndex": //These should all only be allowed to be changed on Titans
		case "decalIndex":
		case "primeCamoIndex":
		case "primeDecalIndex":
		case "camoIndex": //For pilots, this is not a subitem. For titans, it should be titanclass.
		{
			if ( !isTitanLoadout )
				return "" //Only Titans have war paints, which allow for arbitrary skin index. All others should have been taken care of earlier in AllowSkinIndexToSkipValidation()

			return GetDefaultTitanLoadout( loadoutIndex ).titanClass
		}

		case "primaryCamoIndex": //For Pilots, subitem is primary. For Titans, subitem is titanclass
		{
			if ( isPilotLoadout )
			{
				string loadoutString = BuildPersistentVarAccessorString( loadoutType, loadoutIndex, "primary" )
				return string( player.GetPersistentVar( loadoutString ) )
			}
			else
			{
				return GetDefaultTitanLoadout( loadoutIndex ).titanClass
			}
		}

		case "secondaryCamoIndex":
		{
			if ( !isPilotLoadout ) //Only Pilots have secondaries
				return ""

			string loadoutString = BuildPersistentVarAccessorString( loadoutType, loadoutIndex, "secondary" )
			return string( player.GetPersistentVar( loadoutString ) )
		}

		case "weapon3CamoIndex":
		{
			if ( !isPilotLoadout )
				return ""

			string loadoutString = BuildPersistentVarAccessorString( loadoutType, loadoutIndex, "weapon3" )
			return string( player.GetPersistentVar( loadoutString ) )
		}

		case "primarySkinIndex":
		{
			string loadoutString = BuildPersistentVarAccessorString( loadoutType, loadoutIndex, "primary" )
			return string( player.GetPersistentVar( loadoutString ) )
		}

		case "secondarySkinIndex":
		{
			if ( !isPilotLoadout ) //Only Pilots have secondaries
				return ""

			string loadoutString = BuildPersistentVarAccessorString( loadoutType, loadoutIndex, "secondary" )
			return string( player.GetPersistentVar( loadoutString ) )
		}

		case "weapon3SkinIndex":
		{
			if ( !isPilotLoadout )
				return ""

			string loadoutString = BuildPersistentVarAccessorString( loadoutType, loadoutIndex, "weapon3" )
			return string( player.GetPersistentVar( loadoutString ) )
		}

		case "primeSkinIndex": //Should be taken care of earlier in AllowSkinIndexToSkipValidation()
		default:
			return ""
	}

	unreachable
}

int function ForceCastVarToInt( var value ) //HACK: working around inability to cast an int to int. Reexamine when less busy!
{
	if ( typeof( value ) == "int" )
		return ( expect int( value ) )

	return int( value )
}
#endif //Server only

string function GetLoadoutPropertyDefault( string loadoutType, int loadoutIndex, string propertyName ) //Bad things go wrong if you give the wrong default!
{
	string resultString
	switch ( propertyName )
	{
		case "skinIndex":
		case "camoIndex":
		case "decalIndex":
		case "primarySkinIndex":
		case "primaryCamoIndex":
		case "secondarySkinIndex":
		case "secondaryCamoIndex":
		case "weapon3SkinIndex":
		case "weapon3CamoIndex":
		case "primeSkinIndex":
		case "primeCamoIndex":
		case "primeDecalIndex":
			resultString = "0"
			break

		case "isPrime":
			resultString = "titan_is_not_prime"
			break

		case "execution":
			resultString = "execution_neck_snap" //HACK, not sure where this is getting set otherwise.
			break

		case "titanExecution":
			resultString = "execution_random_" + loadoutIndex //Loadout Index for Titans is synced to a specific Titan.
			break

		default:
		{
			bool isTitanLoadout = (loadoutType == "titan")
			bool isPilotLoadout = (loadoutType == "pilot")
			if ( isPilotLoadout )
			{
				PilotLoadoutDef defaultPilotLoadout = GetDefaultPilotLoadout( loadoutIndex ) //HACK: note that this can give an invalid default for a child property, e.g. a sight that doesn't exist on this weapon. This is handled later in ResolveInvalidLoadoutChildValues
				resultString = GetPilotLoadoutValue( defaultPilotLoadout, propertyName )
			}
			else if ( isTitanLoadout )
			{
				TitanLoadoutDef defaultPilotLoadout = GetDefaultTitanLoadout( loadoutIndex ) //HACK: note that this can give an invalid default for a child property, e.g. a sight that doesn't exist on this weapon. This is handled later in ResolveInvalidLoadoutChildValues
				resultString = GetTitanLoadoutValue( defaultPilotLoadout, propertyName )
			}
			else
			{
				unreachable
			}
			break
		}
	}

	//printt( "GetLoadoutPropertyDefault, loadoutType: " + loadoutType + ", loadoutIndex: " + loadoutIndex + ", propertyName: " + propertyName + ", resultString: " + resultString )
	return resultString
}

string function GetCategoryRestrictedResetValue( entity player, int loadoutIndex, string targetProperty, string otherProperty )
{
	string loadoutType = "pilot"
	string otherPropertyValue = GetPersistentLoadoutValue( player, loadoutType, loadoutIndex, otherProperty )
	string potentialDefaultValue = GetLoadoutPropertyDefault( loadoutType, loadoutIndex, targetProperty )
	string resetValue = potentialDefaultValue

	if ( otherPropertyValue != "" )
	{
		int otherCategory = expect int( GetItemDisplayData( otherPropertyValue ).i.menuCategory )
		int potentialDefaultCategory = expect int( GetItemDisplayData( potentialDefaultValue ).i.menuCategory )

		if ( potentialDefaultCategory == otherCategory )
		{
			Assert( otherCategory == eSecondaryWeaponCategory.AT || otherCategory == eSecondaryWeaponCategory.PISTOL )
			if ( otherCategory == eSecondaryWeaponCategory.AT )
				resetValue = GetWeaponCategoryBasedDefault( eSecondaryWeaponCategory.PISTOL )
			else
				resetValue = GetWeaponCategoryBasedDefault( eSecondaryWeaponCategory.AT )
		}
	}

	return resetValue
}

string function GetWeaponCategoryBasedDefault( int category )
{
	string val

	switch ( category )
	{
		case eSecondaryWeaponCategory.AT:
			val = "mp_weapon_defender"
			break

		case eSecondaryWeaponCategory.PISTOL:
			val = "mp_weapon_autopistol"
			break

		default:
			Assert( 0, "category: " + DEV_GetEnumStringFromIndex( "eSecondaryWeaponCategory", category ) + " not handled in GetWeaponCategoryBasedDefault()" )
			break
	}

	return val
}

string function BuildPersistentVarAccessorString( string loadoutType, int loadoutIndex, string propertyName )
{
	return loadoutType + "Loadouts[" + loadoutIndex + "]." + propertyName
}

bool function LoadoutIsLocked( entity player, string loadoutType, int loadoutIndex )
{
	if ( loadoutType == "titan" )
	{
		string titanClass = GetLoadoutPropertyDefault( "titan", loadoutIndex, "titanClass" )
		return IsItemLocked( player, titanClass )

	}
	else if ( loadoutType == "pilot" )
	{
		string pilotLoadoutRef = "pilot_loadout_" + ( loadoutIndex + 1 )
		return IsItemLocked( player, pilotLoadoutRef )
	}

	unreachable

}

string function GetValidatedPersistentLoadoutValue( entity player, string loadoutType, int loadoutIndex, string loadoutProperty )
{
	#if SERVER
		Assert( loadoutType == "pilot" || loadoutType == "titan" )
		Assert( loadoutIndex < PersistenceGetArrayCount( loadoutType + "Loadouts" ), "Invalid loadoutIndex: " + loadoutIndex )

		var loadoutPropertyEnum = null
		if ( loadoutType == "pilot" )
		{
			bool isValidPilotLoadoutProperty = IsValidPilotLoadoutProperty( loadoutProperty )
			//Assert( isValidPilotLoadoutProperty, "Invalid pilot loadoutProperty: " + loadoutProperty )
			if( !isValidPilotLoadoutProperty )
			{
				CodeWarning( "Invalid pilot loadoutProperty: " + loadoutProperty )
				return ""
			}

			loadoutPropertyEnum = GetPilotLoadoutPropertyEnum( loadoutProperty )
		}
		else
		{
			bool isValidTitanLoadoutProperty = IsValidTitanLoadoutProperty( loadoutProperty )
			//Assert( isValidTitanLoadoutProperty, "Invalid titan loadoutProperty: " + loadoutProperty )
			if ( !isValidTitanLoadoutProperty )
			{
				CodeWarning( "Invalid titan loadoutProperty: " + loadoutProperty )
				return ""
			}
			loadoutPropertyEnum = GetTitanLoadoutPropertyEnum( loadoutProperty )
		}

		string getString = BuildPersistentVarAccessorString( loadoutType, loadoutIndex, loadoutProperty )
		var value = player.GetPersistentVar( getString )

		if ( value == null )
			value = ""

		if ( loadoutPropertyEnum != null )
		{
			if ( !PersistenceEnumValueIsValid( loadoutPropertyEnum, value ) )
			{
				printt( "Invalid Loadout Property: ", loadoutType, loadoutIndex, loadoutProperty, value )
				value = ResetLoadoutPropertyToDefault( player, loadoutType, loadoutIndex, loadoutProperty ) //TODO: This will call player.SetPersistentVar() directly. Awkward to do this in a getter function
				ClientCommand( player, "disconnect #RESETTING_LOADOUT", 0 ) //Kick player out with a "Resetting Invalid Loadout" message. Mainly necessary so UI/Client script don't crash out later with known, bad data from persistence
			}
		}

		if ( LoadoutPropertyRequiresItemValidation( loadoutProperty ) && value != "" )
		{
			if ( FailsLoadoutValidationCheck( player, loadoutType, loadoutIndex, loadoutProperty, value ) )
			{
				printt( "Invalid Loadout Property: ", loadoutType, loadoutIndex, loadoutProperty, value )
				value = ResetLoadoutPropertyToDefault( player, loadoutType, loadoutIndex, loadoutProperty ) //TODO: This will call player.SetPersistentVar() directly. Awkward to do this in a getter function
				ClientCommand( player, "disconnect #RESETTING_LOADOUT", 0 ) //Kick player out with a "Resetting Invalid Loadout" message. Mainly necessary so UI/Client script don't crash out later with known, bad data from persistence
			}

			ValidateSkinAndCamoIndexesAsAPair( player, loadoutType, loadoutIndex, loadoutProperty, value ) //TODO: This is awkward, has the potential to call a SetPersistentLoadoutValue() if skinIndex and camoIndex are not correct as a pair
		}

		return string( value )
	#else
		return GetPersistentLoadoutValue( player, loadoutType, loadoutIndex, loadoutProperty )
	#endif
}

int function GetValidatedPersistentLoadoutValueInt( entity player, string loadoutType, int loadoutIndex, string loadoutProperty )
{
	#if SERVER
		string returnValue = GetValidatedPersistentLoadoutValue( player, loadoutType, loadoutIndex, loadoutProperty )
		return int( returnValue )
	#else
		return GetPersistentLoadoutValueInt( player, loadoutType, loadoutIndex, loadoutProperty )
	#endif
}


// SERVER: Looks at and updates persistent loadout data
// CLIENT/UI: Looks at and updates cached loadout data
void function ResolveInvalidLoadoutChildValues( entity player, string loadoutType, int loadoutIndex, string loadoutProperty, string parentValue )
{
	array<string> childProperties = GetChildLoadoutProperties( loadoutType, loadoutProperty )

	//if ( childProperties.len() )
	//{
	//	printt( "====== loadoutProperty:", loadoutProperty, "childProperties are:" )
	//	foreach ( childProperty in childProperties )
	//		printt( "======     ", childProperty )
	//}

	if ( childProperties.len() )
	{
		Assert( parentValue != "" )

		foreach ( childProperty in childProperties )
		{
			string childValue

			if ( childProperty == "primaryCamoIndex" || childProperty == "secondaryCamoIndex" || childProperty == "weapon3CamoIndex" ) // TODO: Keep skin on weapon change if possible
			{
				//printt( "====== loadoutProperty:", loadoutProperty, "childProperty:", childProperty, "will blind RESET" )
			}
			else if ( childProperty == "primarySkinIndex" || childProperty == "secondarySkinIndex" || childProperty == "weapon3SkinIndex" )
			{
				//printt( "====== loadoutProperty:", loadoutProperty, "childProperty:", childProperty, "will blind RESET" )
			}
			else if ( (childProperty == "primaryMod2" || childProperty == "primaryMod3") && IsSubItemLocked( player, childProperty.tolower(), parentValue ) ) // check primarymod2 or primarymod3 feature locked
			{
				//printt( "====== loadoutProperty:", loadoutProperty, "childProperty:", childProperty, "will RESET due to feature lock" )
			}
			else if ( (childProperty == "secondaryMod2" || childProperty == "weapon3Mod2") && IsSubItemLocked( player, "secondarymod2", parentValue ) ) // check secondarymod2 feature locked
			{
				//printt( "====== loadoutProperty:", loadoutProperty, "childProperty:", childProperty, "will RESET due to feature lock" )
			}
			else if ( (childProperty == "secondaryMod3" || childProperty == "weapon3Mod3") && IsSubItemLocked( player, "secondarymod3", parentValue ) ) // check secondarymod3 feature locked
			{
				//printt( "====== loadoutProperty:", loadoutProperty, "childProperty:", childProperty, "will RESET due to feature lock" )
			}
			else // check subitem locked
			{
				#if SERVER
					// TODO: This call will actually check and change the persistent data if it's invalid. Doesn't break anything here, but this function really shouldn't change persistent data.
					childValue = GetPersistentLoadoutValue( player, loadoutType, loadoutIndex, childProperty )
				#else
					if ( loadoutType == "pilot" )
						childValue = GetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], childProperty )
					else if ( loadoutType == "titan" )
						childValue = GetTitanLoadoutValue( shGlobal.cachedTitanLoadouts[ loadoutIndex ], childProperty )
					else
						CodeWarning( "Unhandled loadoutType: " + loadoutType )
				#endif

				if ( childValue == "" || ( childValue != "" && HasSubitem( parentValue, childValue ) && !IsSubItemLocked( player, childValue, parentValue ) ) )
				{
					//printt( "====== loadoutProperty:", loadoutProperty, "childProperty:", childProperty, "will KEEP childValue: \"" + childValue + "\"" )
					continue
				}
				//else
				//{
				//	printt( "====== loadoutProperty:", loadoutProperty, "childProperty:", childProperty, "will RESET childValue: \"" + childValue + "\"" )
				//}
			}

			childValue = GetLoadoutChildPropertyDefault( loadoutType, childProperty, parentValue )

			#if SERVER
				SetPlayerPersistentVarWithoutValidation( player, loadoutType, loadoutIndex, childProperty, childValue )
			#else
				if ( loadoutType == "pilot" )
					SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], childProperty, childValue )
				else if ( loadoutType == "titan" )
					SetTitanLoadoutValue( shGlobal.cachedTitanLoadouts[ loadoutIndex ], childProperty, childValue )
				else
					CodeWarning( "Unhandled loadoutType: " + loadoutType )
			#endif
		}
	}
	//else
	//{
	//	printt( "====== loadoutProperty:", loadoutProperty, "childProperties is empty" )
	//}
}

#if UI || CLIENT
void function SetCachedPilotLoadoutValue( entity player, int loadoutIndex, string loadoutProperty, string value )
{
	if ( !IsValidPilotLoadoutProperty( loadoutProperty ) )
	{
		CodeWarning( "Tried to set pilot " + loadoutProperty + " to invalid value: " + value )
		return
	}

	// Reset child properties when parent changes
	ResolveInvalidLoadoutChildValues( player, "pilot", loadoutIndex, loadoutProperty, value )

	#if HAS_THREAT_SCOPE_SLOT_LOCK
	if ( loadoutProperty.tolower() == "primaryattachment" && value == "threat_scope" )
	{
		SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], "primaryMod2", "" )
	}
	#endif

	SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], loadoutProperty, value )
	UpdateDerivedPilotLoadoutData( shGlobal.cachedPilotLoadouts[ loadoutIndex ] )

	#if UI
		if ( value == "" )
			value = "null"
		ClientCommand( "SetPersistentLoadoutValue pilot " + loadoutIndex + " " + loadoutProperty + " " + value )
	#endif // UI
}


void function SetCachedTitanLoadoutValue( entity player, int loadoutIndex, string loadoutProperty, string value )
{
	if ( !IsValidTitanLoadoutProperty( loadoutProperty ) )
	{
		CodeWarning( "Tried to set titan " + loadoutProperty + " to invalid value: " + value )
		return
	}

	// Reset child properties when parent changes
	ResolveInvalidLoadoutChildValues( player, "titan", loadoutIndex, loadoutProperty, value )

	SetTitanLoadoutValue( shGlobal.cachedTitanLoadouts[ loadoutIndex ], loadoutProperty, value )
	UpdateDerivedTitanLoadoutData( shGlobal.cachedTitanLoadouts[ loadoutIndex ] )

	#if UI
		if ( value == "" )
			value = "null"
		ClientCommand( "SetPersistentLoadoutValue titan " + loadoutIndex + " " + loadoutProperty + " " + value )
	#endif // UI
}



// TODO: If we change a property that has a parent or child relationship, all related properties need updating if invalid
// 		A parent change should validate children and set invalid to defaults
// 		If a child change is invalid for the parent, it should be changed to a valid default based on the parent
void function SetCachedLoadoutValue( entity player, string loadoutType, int loadoutIndex, string loadoutProperty, string value )
{
	// Keep CLIENT matching UI
	#if UI
		RunClientScript( "SetCachedLoadoutValue", player, loadoutType, loadoutIndex, loadoutProperty, value )
	#endif // UI

	//printt( "=======================================================================================" )
	//printt( "SetPersistentLoadoutValue called with loadoutType:", loadoutType, "loadoutIndex:", loadoutIndex, "loadoutProperty:" , loadoutProperty, "value:", value )
	//printl( "script GetPlayerArray()[0].SetPersistentVar( \"" + loadoutType + "Loadouts[" + loadoutIndex + "]." + loadoutProperty + "\", \"" + value + "\" )" )
	//printt( "=======================================================================================" )

	if ( loadoutType == "pilot" )
		SetCachedPilotLoadoutValue( player, loadoutIndex, loadoutProperty, value )
	else if ( loadoutType == "titan" )
		SetCachedTitanLoadoutValue( player, loadoutIndex, loadoutProperty, value )
	else
		CodeWarning( "Unhandled loadoutType: " + loadoutType )

	/*
	Assert( loadoutType == "pilot" || loadoutType == "titan" )
	Assert( loadoutIndex < PersistenceGetArrayCount( loadoutType + "Loadouts" ), "Invalid loadoutIndex: " + loadoutIndex )

	if ( value == "null" || value == "" || value == null )
	{
		CodeWarning( "Tried to set " + loadoutType + " " + loadoutProperty + " to invalid value: " + value )
		return
	}

	var loadoutPropertyEnum = null
	if ( loadoutType == "pilot" )
	{
		if ( !IsValidPilotLoadoutProperty( loadoutProperty ) )
		{
			CodeWarning( "Invalid pilot loadoutProperty: " + loadoutProperty )
			return
		}

		loadoutPropertyEnum = GetPilotLoadoutPropertyEnum( loadoutProperty )
	}
	else
	{
		if ( !IsValidTitanLoadoutProperty( loadoutProperty ) )
		{
			CodeWarning( "Invalid titan loadoutProperty: " + loadoutProperty )
			return
		}

		loadoutPropertyEnum = GetTitanLoadoutPropertyEnum( loadoutProperty )
	}

	if ( loadoutPropertyEnum == null )
	{
		CodeWarning( "Couldn't find loadoutPropertyEnum for " + loadoutType + " " + loadoutProperty )
		return
	}

	if ( !PersistenceEnumValueIsValid( loadoutPropertyEnum, value ) )
	{
		CodeWarning( loadoutProperty + " value: " + value + " not valid in persistent data!" )
		return
	}

	// Only checks primary mods and attachments are valid in itemData and the parent isn't locked
	if ( !IsLoadoutSubitemValid( player, loadoutType, loadoutIndex, loadoutProperty, value ) )
	{
		CodeWarning( loadoutProperty + " value: " + value + " failed IsLoadoutSubitemValid() check! It may not exist in itemData, or it's parent item is locked." )
		return
	}

	// Reset child properties when parent changes
	array<string> childProperties = GetChildLoadoutProperties( loadoutType, loadoutProperty )
	if ( childProperties.len() )
	{
		foreach ( childProperty in childProperties )
		{
			Assert( value != "" )
			string childValue = GetLoadoutChildPropertyDefault( loadoutType, childProperty, value )

			if ( loadoutType == "pilot" )
				SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], childProperty, childValue )
			else
				SetTitanLoadoutValue( shGlobal.cachedTitanLoadouts[ loadoutIndex ], childProperty, childValue )
		}
	}

	if ( loadoutType == "pilot" )
	{
		SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], loadoutProperty, value )
		UpdateDerivedPilotLoadoutData( shGlobal.cachedPilotLoadouts[ loadoutIndex ] )
	}
	else
	{
		SetTitanLoadoutValue( shGlobal.cachedTitanLoadouts[ loadoutIndex ], loadoutProperty, value )
		OverwriteLoadoutWithDefaultsForSetFile_ExceptSpecialAndAntiRodeo( shGlobal.cachedTitanLoadouts[ loadoutIndex ] )
	}

	if ( value == "" || value == "null" )
		ClientCommand( "SetPersistentLoadoutValue " + loadoutType + " " + loadoutIndex + " " + loadoutProperty + " " + null )
	else
		ClientCommand( "SetPersistentLoadoutValue " + loadoutType + " " + loadoutIndex + " " + loadoutProperty + " " + value )
		*/
}
#endif // UI || CLIENT

// SERVER version waits till end of frame to reduce remote calls which can get high when loadouts are first initialized
// CLIENT and UI versions need to wait for persistent data to be ready
// Ideally, UI and CLIENT would have a callback that triggered when persistent loadout data changed.
void function UpdateCachedLoadouts()
{
	#if SERVER
		Signal( level, "EndUpdateCachedLoadouts" )
		EndSignal( level, "EndUpdateCachedLoadouts" )

		WaitEndFrame()

		array<entity> players = GetPlayerArray()

		foreach ( player in players )
		{
			if ( player.p.pilotLoadoutChanged )
			{
				Remote_CallFunction_NonReplay( player, "UpdateAllCachedPilotLoadouts" )
				player.p.pilotLoadoutChanged = false
			}

			if ( player.p.titanLoadoutChanged )
			{
				Remote_CallFunction_NonReplay( player, "UpdateAllCachedTitanLoadouts" )
				player.p.titanLoadoutChanged = false
			}

			// TEMP client model update method
			if ( player.p.pilotModelNeedsUpdate != -1 )
			{
				Remote_CallFunction_NonReplay( player, "ServerCallback_UpdatePilotModel", player.p.pilotModelNeedsUpdate )
				player.p.pilotModelNeedsUpdate = -1
			}

			if ( player.p.titanModelNeedsUpdate != -1 )
			{
				Remote_CallFunction_NonReplay( player, "ServerCallback_UpdateTitanModel", player.p.titanModelNeedsUpdate )
				player.p.titanModelNeedsUpdate = -1
			}
		}
	#elseif UI || CLIENT
		#if UI
			entity player = GetUIPlayer()
		#elseif CLIENT
			entity player = GetLocalClientPlayer()
		#endif

		if ( player == null )
			return

		#if UI
			EndSignal( uiGlobal.signalDummy, "LevelShutdown" )
		#endif // UI

		while ( player.GetPersistentVarAsInt( "initializedVersion" ) < PERSISTENCE_INIT_VERSION )
		{
			WaitFrame()
		}

		UpdateAllCachedPilotLoadouts()
		UpdateAllCachedTitanLoadouts()
		#if CLIENT
			Signal( level, "CachedLoadoutsReady" )
		#endif // CLIENT
	#endif
}

#if UI
	void function InitUISpawnLoadoutIndexes()
	{
		EndSignal( uiGlobal.signalDummy, "LevelShutdown" )

		entity player = GetUIPlayer()

		if ( player == null )
			return

		while ( player.GetPersistentVarAsInt( "initializedVersion" ) < PERSISTENCE_INIT_VERSION )
			WaitFrame()

		uiGlobal.pilotSpawnLoadoutIndex = GetPersistentSpawnLoadoutIndex( player, "pilot" )
		uiGlobal.titanSpawnLoadoutIndex = GetPersistentSpawnLoadoutIndex( player, "titan" )
	}
#endif // UI

// There's no good way to dynamically reference a struct variable
string function GetPilotLoadoutValue( PilotLoadoutDef loadout, string property )
{
	string value
	printt( "GetPilotLoadoutValue, property: " + property )

	switch ( property )
	{
		case "name":
			value = loadout.name
			break

		case "suit":
			value = loadout.suit
			break

		case "race":
			value = loadout.race
			break

		case "primary":
			value = loadout.primary
			break

		case "primaryAttachment":
			value = loadout.primaryAttachment
			break

		case "primaryMod1":
			value = loadout.primaryMod1
			break

		case "primaryMod2":
			value = loadout.primaryMod2
			break

		case "primaryMod3":
			value = loadout.primaryMod3
			break

		case "secondary":
			value = loadout.secondary
			break

		case "secondaryMod1":
			value = loadout.secondaryMod1
			break

		case "secondaryMod2":
			value = loadout.secondaryMod2
			break

		case "secondaryMod3":
			value = loadout.secondaryMod3
			break

		case "weapon3":
			value = loadout.weapon3
			break

		case "weapon3Mod1":
			value = loadout.weapon3Mod1
			break

		case "weapon3Mod2":
			value = loadout.weapon3Mod2
			break

		case "weapon3Mod3":
			value = loadout.weapon3Mod3
			break

		case "special":
			value = loadout.special
			break

		case "ordnance":
			value = loadout.ordnance
			break

		case "passive1":
			value = loadout.passive1
			break

		case "passive2":
			value = loadout.passive2
			break

		case "melee":
			value = loadout.melee
			break

		case "execution":
			value = loadout.execution
			break

		case "skinIndex":
			value = string( loadout.skinIndex )
			break

		case "camoIndex":
			value = string( loadout.camoIndex )
			break

		case "primarySkinIndex":
			value = string( loadout.primarySkinIndex )
			break

		case "primaryCamoIndex":
			value = string( loadout.primaryCamoIndex )
			break

		case "secondarySkinIndex":
			value = string( loadout.secondarySkinIndex )
			break

		case "secondaryCamoIndex":
			value = string ( loadout.secondaryCamoIndex )
			break

		case "weapon3SkinIndex":
			value = string( loadout.weapon3SkinIndex )
			break

		case "weapon3CamoIndex":
			value = string ( loadout.weapon3CamoIndex )
			break

		default:
			printt( "Returning blank for property: " + property ) //TODO: This should probably just be an error, but some existing calls depend on blank string being returned
			value = ""
	}

	return value
}

// There's no good way to dynamically reference a struct variable
// If this starts getting called outside of SetPersistentLoadoutValue(), it needs error checking
void function SetPilotLoadoutValue( PilotLoadoutDef loadout, string property, string value )
{
	switch ( property )
	{
		case "name":
			loadout.name = value
			break

		case "suit":
			loadout.suit = value
			break

		case "execution":
			loadout.execution = value
			break

		case "race":
			loadout.race = value
			break

		case "primary":
			loadout.primary = value
			break

		case "primaryAttachment":
			loadout.primaryAttachment = value
			break

		case "primaryMod1":
			loadout.primaryMod1 = value
			break

		case "primaryMod2":
			loadout.primaryMod2 = value
			break

		case "primaryMod3":
			loadout.primaryMod3 = value
			break

		case "secondary":
			loadout.secondary = value
			break

		case "secondaryMod1":
			loadout.secondaryMod1 = value
			break

		case "secondaryMod2":
			loadout.secondaryMod2 = value
			break

		case "secondaryMod3":
			loadout.secondaryMod3 = value
			break

		case "weapon3":
			loadout.weapon3 = value
			break

		case "weapon3Mod1":
			loadout.weapon3Mod1 = value
			break

		case "weapon3Mod2":
			loadout.weapon3Mod2 = value
			break

		case "weapon3Mod3":
			loadout.weapon3Mod3 = value
			break

		case "special":
			loadout.special = value
			break

		case "ordnance":
			loadout.ordnance = value
			break

		case "passive1":
			loadout.passive1 = value
			break

		case "passive2":
			loadout.passive2 = value
			break

		case "melee":
			loadout.melee = value
			break

		case "skinIndex":
			loadout.skinIndex = int( value )
			break

		case "camoIndex":
			loadout.camoIndex = int( value )
			break

		case "primarySkinIndex":
			loadout.primarySkinIndex = int( value )
			break

		case "primaryCamoIndex":
			loadout.primaryCamoIndex = int( value )
			break

		case "secondarySkinIndex":
			loadout.secondarySkinIndex = int( value )
			break

		case "secondaryCamoIndex":
			loadout.secondaryCamoIndex = int( value )
			break

		case "weapon3SkinIndex":
			loadout.weapon3SkinIndex = int( value )
			break

		case "weapon3CamoIndex":
			loadout.weapon3CamoIndex = int( value )
			break
	}
}

// There's no good way to dynamically reference a struct variable
string function GetTitanLoadoutValue( TitanLoadoutDef loadout, string property )
{
	string value

	switch ( property )
	{
		case "name":
			value = loadout.name
			break

		case "titanClass":
			value = loadout.titanClass
			break

		case "primeTitanRef":
			value = loadout.primeTitanRef
			break

		case "setFile":
			value = loadout.setFile
			break

		case "coreAbility":
			value = loadout.coreAbility
			break

		case "primary":
			value = loadout.primary
			break

		case "primaryMod":
			value = loadout.primaryMod
			break

		case "special":
			value = loadout.special
			break

		case "antirodeo":
			value = loadout.antirodeo
			break

		case "ordnance":
			value = loadout.ordnance
			break

		case "passive1":
			value = loadout.passive1
			break

		case "passive2":
			value = loadout.passive2
			break

		case "passive3":
			value = loadout.passive3
			break

		case "passive4":
			value = loadout.passive4
			break

		case "passive5":
			value = loadout.passive5
			break

		case "passive6":
			value = loadout.passive6
			break

		case "skinIndex":
			value = string( loadout.skinIndex )
			break

		case "camoIndex":
			value = string ( loadout.camoIndex )
			break

		case "decalIndex":
			value = string( loadout.decalIndex )
			break

		case "primarySkinIndex":
			value = string ( loadout.primarySkinIndex )
			break

		case "primaryCamoIndex":
			value = string ( loadout.primaryCamoIndex )
			break

		case "difficulty":
			value = string ( loadout.difficulty ) //TODO: Unused?
			break

		case "isPrime":
			value = loadout.isPrime
			break

		case "primeSkinIndex":
			value = string( loadout.primeSkinIndex )
			break

		case "primeCamoIndex":
			value = string( loadout.primeCamoIndex )
			break

		case "primeDecalIndex":
			value = string( loadout.primeDecalIndex )
			break

		case "titanExecution":
			value = loadout.titanExecution
			break

		default:
			printt( "Returning blank for property: " + property ) //TODO: This should probably just be an error, but some existing calls depend on blank string being returned
			value = ""
	}

	return value
}

// There's no good way to dynamically reference a struct variable
// If this starts getting called outside of SetPersistentLoadoutValue(), it needs error checking
void function SetTitanLoadoutValue( TitanLoadoutDef loadout, string property, string value )
{
	switch ( property )
	{
		case "name":
			loadout.name = value
			break

		case "setFile":
			loadout.setFile = value
			break

		case "primaryMod":
			loadout.primaryMod = value
			break

		case "special":
			loadout.special = value
			break

		case "antirodeo":
			loadout.antirodeo = value
			break

		case "passive1":
			loadout.passive1 = value
			break

		case "passive2":
			loadout.passive2 = value
			break

		case "passive3":
			loadout.passive3 = value
			break

		case "passive4":
			loadout.passive4 = value
			break

		case "passive5":
			loadout.passive5 = value
			break

		case "passive6":
			loadout.passive6 = value
			break

		case "skinIndex":
			loadout.skinIndex = int( value )
			break

		case "camoIndex":
			loadout.camoIndex = int( value )
			break

		case "decalIndex":
			loadout.decalIndex = int( value )
			break

		case "primarySkinIndex":
			loadout.primarySkinIndex = int( value )
			break

		case "primaryCamoIndex":
			loadout.primaryCamoIndex = int( value )
			break

		case "isPrime":
			loadout.isPrime =  value
			break

		case "primeSkinIndex":
			loadout.primeSkinIndex = int( value )
			break

		case "primeCamoIndex":
			loadout.primeCamoIndex = int( value )
			break

		case "primeDecalIndex":
			loadout.primeDecalIndex = int( value )
			break

		case "titanExecution":
			loadout.titanExecution = value
			break

		case "showArmBadge":
			loadout.showArmBadge = int( value )
			break
	}
}

bool function IsValidPilotLoadoutProperty( string propertyName )
{
	switch ( propertyName )
	{
		case "name":
		case "suit":
		case "race":
		case "execution":
		case "primary":
		case "primaryAttachment":
		case "primaryMod1":
		case "primaryMod2":
		case "primaryMod3":
		case "secondary":
		case "secondaryMod1":
		case "secondaryMod2":
		case "secondaryMod3":
		case "weapon3":
		case "weapon3Mod1":
		case "weapon3Mod2":
		case "weapon3Mod3":
		case "ordnance":
		case "passive1":
		case "passive2":
		case "skinIndex":
		case "camoIndex":
		case "primarySkinIndex":
		case "primaryCamoIndex":
		case "secondarySkinIndex":
		case "secondaryCamoIndex":
		case "weapon3SkinIndex":
		case "weapon3CamoIndex":
			return true
	}

	return false
}

bool function IsValidTitanLoadoutProperty( string propertyName )
{
	switch ( propertyName )
	{
		case "name":
		case "titanClass":
		case "primaryMod":
		case "special":
		case "antirodeo":
		case "passive1":
		case "passive2":
		case "passive3":
		case "passive4":
		case "passive5":
		case "passive6":
		case "skinIndex":
		case "camoIndex":
		case "decalIndex":
		case "primarySkinIndex":
		case "primaryCamoIndex":
		case "isPrime":
		case "primeSkinIndex":
		case "primeCamoIndex":
		case "primeDecalIndex":
		case "titanExecution":
		case "showArmBadge":
			return true
	}

	return false
}

var function GetPilotLoadoutPropertyEnum( string property )
{
	switch ( property )
	{
		case "suit":
			return "pilotSuit"

		case "race":
			return "pilotRace"

		case "primary":
		case "secondary":
		case "weapon3":
		case "special":
		case "ordnance":
		case "melee":
			return "loadoutWeaponsAndAbilities"

		case "primaryAttachment":
		case "primaryMod1":
		case "primaryMod2":
		case "primaryMod3":
		case "secondaryMod1":
		case "secondaryMod2":
		case "secondaryMod3":
		case "weapon3Mod1":
		case "weapon3Mod2":
		case "weapon3Mod3":
			return "pilotMod"

		case "passive1":
		case "passive2":
			return "pilotPassive"

		case "name":
		default:
			return null
	}
}

var function GetTitanLoadoutPropertyEnum( string property )
{
	switch ( property )
	{
		case "titanClass":
			return "titanClasses"
		case "primary":
		case "special":
		case "antirodeo":
		case "ordnance":
			return "loadoutWeaponsAndAbilities"
		case "primaryMod":
			return "titanMod"
		case "passive1":
		case "passive2":
		case "passive3":
		case "passive4":
		case "passive5":
		case "passive6":
			return "titanPassive"
		case "isPrime":
			return "titanIsPrimeTitan"
		case "name":
		default:
			return null
	}
}

int function GetItemTypeFromPilotLoadoutProperty( string loadoutProperty )
{
	int itemType

	switch ( loadoutProperty )
	{
		case "suit":
			itemType = eItemTypes.PILOT_SUIT
			break

		case "primary":
			itemType = eItemTypes.PILOT_PRIMARY
			break

		case "secondary":
		case "weapon3": // Most cases need to treat as secondary, so don't return eItemTypes.PILOT_WEAPON3 here
			itemType = eItemTypes.PILOT_SECONDARY
			break

		case "special":
			itemType = eItemTypes.PILOT_SPECIAL
			break

		case "ordnance":
			itemType = eItemTypes.PILOT_ORDNANCE
			break

		case "passive1":
			itemType = eItemTypes.PILOT_PASSIVE1
			break

		case "passive2":
			itemType = eItemTypes.PILOT_PASSIVE2
			break

		case "primaryAttachment":
			itemType = eItemTypes.PILOT_PRIMARY_ATTACHMENT
			break

		case "primaryMod1":
		case "primaryMod2":
			itemType = eItemTypes.PILOT_PRIMARY_MOD
			break

		case "secondaryMod1":
		case "secondaryMod2":
		case "weapon3Mod1":
		case "weapon3Mod2":
			itemType = eItemTypes.PILOT_SECONDARY_MOD
			break

		case "primaryMod3":
		case "secondaryMod3":
		case "weapon3Mod3":
			itemType = eItemTypes.PILOT_WEAPON_MOD3
			break

		case "race":
			itemType = eItemTypes.RACE
			break

		case "execution":
			itemType = eItemTypes.PILOT_EXECUTION
			break

		default:
			Assert( false, "Invalid pilot loadout property!" )
	}

	return itemType
}

int function GetItemTypeFromTitanLoadoutProperty( string loadoutProperty, string setFile = "" )
{
	int itemType

	switch ( loadoutProperty )
	{
		case "setFile":
			itemType = eItemTypes.TITAN
			break

		case "coreAbility":
			itemType = eItemTypes.TITAN_CORE_ABILITY
			break

		case "primary":
			itemType = eItemTypes.TITAN_PRIMARY
			break

		case "special":
			itemType = eItemTypes.TITAN_SPECIAL
			break

		case "ordnance":
			itemType = eItemTypes.TITAN_ORDNANCE
			break

		case "antirodeo":
			itemType = eItemTypes.TITAN_ANTIRODEO
			break

		case "passive1":
		case "passive2":
		case "passive3":
		case "passive4":
		case "passive5":
		case "passive6":
			Assert( setFile != "" )
			itemType = GetTitanLoadoutPropertyPassiveType( setFile, loadoutProperty )
			break

		case "titanExecution":
			Assert( setFile != "" )
			itemType = GetTitanLoadoutPropertyExecutionType( setFile, loadoutProperty )
			break

		case "voice":
			itemType = eItemTypes.TITAN_OS
			break

		case "primaryMod":
			itemType = eItemTypes.TITAN_PRIMARY_MOD
			break

		default:
			Assert( false, "Invalid titan loadout property!" )
	}

	return itemType
}

string function GetLoadoutChildPropertyDefault( string loadoutType, string propertyName, string parentValue )
{
	Assert( loadoutType == "pilot" || loadoutType == "titan" )

	string resetValue = ""

	if ( loadoutType == "pilot" )
	{
		switch ( propertyName )
		{
			case "primaryAttachment":
			case "primaryMod1":
			case "primaryMod2":
			case "primaryMod3":
			case "secondaryMod1":
			case "secondaryMod2":
			case "secondaryMod3":
			case "weapon3Mod1":
			case "weapon3Mod2":
			case "weapon3Mod3":
				resetValue = GetWeaponBasedDefaultMod( parentValue, propertyName )
				break

			case "primaryCamoIndex":
			case "primarySkinIndex":
			case "secondaryCamoIndex":
			case "secondarySkinIndex":
			case "weapon3CamoIndex":
			case "weapon3SkinIndex":
				resetValue = "0"
				break
		}
	}

	return resetValue
}

// There's no great way to know the dependency heirarchy of persistent loadout data
array<string> function GetChildLoadoutProperties( string loadoutType, string propertyName )
{
	Assert( loadoutType == "pilot" || loadoutType == "titan" )

	array<string> childProperties

	if ( loadoutType == "pilot" )
	{
		switch ( propertyName )
		{
			/*case "suit":
				childProperties.append( "passive1" )
				childProperties.append( "passive2" )
				break*/

			case "primary":
				childProperties.append( "primaryAttachment" )
				childProperties.append( "primaryMod1" )
				childProperties.append( "primaryMod2" )
				childProperties.append( "primaryMod3" )
				childProperties.append( "primaryCamoIndex" )
				childProperties.append( "primarySkinIndex" )
				break

			case "secondary":
				childProperties.append( "secondaryMod1" )
				childProperties.append( "secondaryMod2" )
				childProperties.append( "secondaryMod3" )
				childProperties.append( "secondaryCamoIndex" )
				childProperties.append( "secondarySkinIndex" )
				break

			case "weapon3":
				childProperties.append( "weapon3Mod1" )
				childProperties.append( "weapon3Mod2" )
				childProperties.append( "weapon3Mod3" )
				childProperties.append( "weapon3CamoIndex" )
				childProperties.append( "weapon3SkinIndex" )
				break

			/*case "melee":
				childProperties.append( "meleeMods" ) // not in persistent data
				break

			case "ordnance":
				childProperties.append( "ordnanceMods" ) // not in persistent data
				break*/
		}
	}
	else
	{
		switch ( propertyName )
		{
			/*case "setFile":
				childProperties.append( "setFileMods" ) // not in persistent data
				break

			case "primary":
				//childProperties.append( "primaryAttachment" ) // not in persistent data
				childProperties.append( "primaryMod" )
				break

			case "special":
				childProperties.append( "specialMods" ) // not in persistent data
				break

			case "ordnance":
				childProperties.append( "ordnanceMods" ) // not in persistent data
				break

			case "antirodeo":
				childProperties.append( "antirodeoMods" ) // not in persistent data
				break*/
		}
	}

	return childProperties
}

// There's no great way to know the dependency heirarchy of persistent loadout data
string function GetParentLoadoutProperty( string loadoutType, string propertyName )
{
	Assert( loadoutType == "pilot" || loadoutType == "titan" )

	string parentProperty

	if ( loadoutType == "pilot" )
	{
		switch ( propertyName )
		{
			case "primaryAttachment":
			case "primaryMod1":
			case "primaryMod2":
			case "primaryMod3":
			case "primaryCamoIndex":
			case "primarySkinIndex":
				parentProperty = "primary"
				break

			case "secondaryMod1":
			case "secondaryMod2":
			case "secondaryMod3":
			case "secondaryCamoIndex":
			case "secondarySkinIndex":
				parentProperty = "secondary"
				break

			case "weapon3Mod1":
			case "weapon3Mod2":
			case "weapon3Mod3":
			case "weapon3CamoIndex":
			case "weapon3SkinIndex":
				parentProperty = "weapon3"
				break

			case "passive1":
			case "passive2":
				parentProperty = "special"
				break

			default:
				Assert( 0, "Unknown loadout propertyName: " + propertyName )
		}
	}
	else
	{
		switch ( propertyName )
		{
			case "passive1":
			case "passive2":
			case "passive3":
			case "passive4":
			case "passive5":
			case "passive6":
				parentProperty = "titanClass"
				break

			default:
				Assert( 0, "Unknown loadout propertyName: " + propertyName )
		}
	}

	return parentProperty
}

int function GetPersistentSpawnLoadoutIndex( entity player, string loadoutType )
{
	int loadoutIndex = player.GetPersistentVarAsInt( loadoutType + "SpawnLoadout.index" )
	if ( loadoutType == "titan" && loadoutIndex >= NUM_PERSISTENT_TITAN_LOADOUTS )
		loadoutIndex = 0

	return loadoutIndex
}

#if SERVER
void function SetPersistentSpawnLoadoutIndex( entity player, string loadoutType, int loadoutIndex )
{
	Assert( loadoutIndex >= 0 )
	player.SetPersistentVar( loadoutType + "SpawnLoadout.index", loadoutIndex )
}
#endif // SERVER

#if UI
	void function SetEditLoadout( string loadoutType, int loadoutIndex )
	{
		uiGlobal.editingLoadoutType = loadoutType
		uiGlobal.editingLoadoutIndex = loadoutIndex
	}

	void function ClearEditLoadout()
	{
		uiGlobal.editingLoadoutType = ""
		uiGlobal.editingLoadoutIndex = -1
	}

	PilotLoadoutDef function GetPilotEditLoadout()
	{
		return GetCachedPilotLoadout( uiGlobal.editingLoadoutIndex )
	}

	TitanLoadoutDef function GetTitanEditLoadout()
	{
		return GetCachedTitanLoadout( uiGlobal.editingLoadoutIndex )
	}

	int function GetLoadoutIndexForTitanClass( string titanClass )
	{
		for ( int loadoutIndex = 0; loadoutIndex < NUM_PERSISTENT_TITAN_LOADOUTS; loadoutIndex++ )
		{
			TitanLoadoutDef loadout = GetCachedTitanLoadout( loadoutIndex )

			if ( loadout.titanClass == titanClass )
				return loadoutIndex
		}

		return -1
	}

	string function GetPilotLoadoutName( PilotLoadoutDef loadout )
	{
		if ( IsTokenLoadoutName( loadout.name ) )
			return Localize( loadout.name )

		return loadout.name
	}

	string function GetTitanLoadoutName( TitanLoadoutDef loadout )
	{
		if ( IsTokenLoadoutName( loadout.name ) )
			return Localize( loadout.name )

		return loadout.name
	}

	void function SetTextFromItemName( var element, string ref )
	{
		string text = ""

		if ( ref != "" )
			text = GetItemName( ref )

		Hud_SetText( element, text )
	}

	void function SetTextFromItemDescription( var element, string ref )
	{
		string text = ""

		if ( ref != "" )
			text = GetItemDescription( ref )

		Hud_SetText( element, text )
	}

	void function SetTextFromItemLongDescription( var element, string ref )
	{
		string text = ""

		if ( ref != "" )
			text = GetItemLongDescription( ref )

		Hud_SetText( element, text )
	}

	void function SetImageFromItemImage( var element, string ref )
	{
		if ( ref != "" )
		{
			Hud_SetImage( element, GetItemImage( ref ) )
			Hud_Show( element )
		}
		else
		{
			Hud_Hide( element )
		}
	}

	void function SetTextFromSubItemClipSize( var element, string ref, string modRef )
	{
		Hud_SetText( element, "" )
		if ( ref != "" && modRef != "" )
		{
			int clipDiff = GetSubItemClipSizeStat( ref, modRef )
			if ( clipDiff == 0 )
				return

			if ( clipDiff > 0 )
			{
				Hud_SetColor( element, 141, 197, 84, 255 )
				Hud_SetText( element, "#MOD_CLIP_AMMO_INCREASE", string( clipDiff ) )
			}
			else
			{
				Hud_SetColor( element, 211, 77, 61, 255 )
				Hud_SetText( element, "#MOD_CLIP_AMMO_DECREASE", string( abs( clipDiff ) ) )
			}
		}
	}

	void function SetTextFromSubitemName( var element, string parentRef, string childRef, string defaultText = "" )
	{
		string text = defaultText

		if ( parentRef != "" && childRef != "" && childRef != "none" )
			text = GetSubitemName( parentRef, childRef )

		Hud_SetText( element, text )
	}

	void function SetTextFromSubitemDescription( var element, string parentRef, string childRef, string defaultText = "" )
	{
		string text = defaultText

		if ( parentRef != "" && childRef != "" && childRef != "none" )
			text = GetSubitemDescription( parentRef, childRef )

		Hud_SetText( element, text )
	}

	void function SetTextFromSubitemLongDescription( var element, string parentRef, string childRef, string defaultText = "" )
	{
		string text = defaultText

		if ( parentRef != "" && childRef != "" && childRef != "none" )
			text = GetSubitemLongDescription( parentRef, childRef )

		Hud_SetText( element, text )
	}

	void function SetImageFromSubitemImage( var element, string parentRef, string childRef, asset defaultIcon = $"" )
	{
		if ( parentRef != "" && childRef != "" && childRef != "none" )
		{
			Hud_SetImage( element, GetSubitemImage( parentRef, childRef ) )
			Hud_Show( element )
		}
		else
		{
			if ( defaultIcon != $"" )
			{
				Hud_SetImage( element, defaultIcon )
				Hud_Show( element )
			}
			else
			{
				Hud_Hide( element )
			}
		}
	}

	void function SetTextFromSubitemUnlockReq( var element, string parentRef, string childRef, string defaultText = "" )
	{
		string text = defaultText

		if ( parentRef != "" && childRef != "" && childRef != "none" )
			text = GetItemUnlockReqText( childRef, parentRef )

		Hud_SetText( element, text )
	}
#endif //UI

#if UI || CLIENT
	void function UpdateAllCachedPilotLoadouts()
	{
		int numLoadouts = shGlobal.cachedPilotLoadouts.len()

		for ( int i = 0; i < numLoadouts; i++ )
			UpdateCachedPilotLoadout( i )
	}

	void function UpdateAllCachedTitanLoadouts()
	{
		int numLoadouts = shGlobal.cachedTitanLoadouts.len()

		for ( int i = 0; i < numLoadouts; i++ )
			UpdateCachedTitanLoadout( i )
	}

	void function UpdateCachedPilotLoadout( int loadoutIndex )
	{
		entity player
		#if UI
			player = GetUIPlayer()
		#elseif CLIENT
			player = GetLocalClientPlayer()
		#endif

		if ( player == null )
			return

		PopulatePilotLoadoutFromPersistentData( player, shGlobal.cachedPilotLoadouts[ loadoutIndex ], loadoutIndex )
	}

	void function UpdateCachedTitanLoadout( int loadoutIndex )
	{
		entity player
		#if UI
			player = GetUIPlayer()
		#elseif CLIENT
			player = GetLocalClientPlayer()
		#endif

		if ( player == null )
			return

		PopulateTitanLoadoutFromPersistentData( player, shGlobal.cachedTitanLoadouts[ loadoutIndex ], loadoutIndex )
	}

	PilotLoadoutDef function GetCachedPilotLoadout( int loadoutIndex )
	{
		Assert( loadoutIndex >= 0 && loadoutIndex < shGlobal.cachedPilotLoadouts.len() )

		return shGlobal.cachedPilotLoadouts[ loadoutIndex ]
	}

	TitanLoadoutDef function GetCachedTitanLoadout( int loadoutIndex )
	{
		Assert( loadoutIndex >= 0 && loadoutIndex < shGlobal.cachedTitanLoadouts.len() )

		return shGlobal.cachedTitanLoadouts[ loadoutIndex ]
	}

	PilotLoadoutDef[ NUM_PERSISTENT_PILOT_LOADOUTS ] function GetAllCachedPilotLoadouts()
	{
		return shGlobal.cachedPilotLoadouts
	}

	TitanLoadoutDef[ NUM_PERSISTENT_TITAN_LOADOUTS ] function GetAllCachedTitanLoadouts()
	{
		return shGlobal.cachedTitanLoadouts
	}

	int function GetCachedTitanLoadoutCamoIndex( int loadoutIndex )
	{
		TitanLoadoutDef cachedTitanLoadout = GetCachedTitanLoadout( loadoutIndex )
		return GetTitanCamoIndexFromLoadoutAndPrimeStatus( cachedTitanLoadout )
	}

	int function GetCachedTitanLoadoutSkinIndex( int loadoutIndex )
	{
		TitanLoadoutDef cachedTitanLoadout = GetCachedTitanLoadout( loadoutIndex )
		return GetTitanSkinIndexFromLoadoutAndPrimeStatus( cachedTitanLoadout  )
	}

	int function GetCachedTitanLoadoutDecalIndex( int loadoutIndex )
	{
		TitanLoadoutDef cachedTitanLoadout = GetCachedTitanLoadout( loadoutIndex )
		return GetTitanDecalIndexFromLoadoutAndPrimeStatus( cachedTitanLoadout )
	}

	asset function GetCachedTitanLoadoutArmBadge( int loadoutIndex )
	{
		TitanLoadoutDef cachedTitanLoadout = GetCachedTitanLoadout( loadoutIndex )
		return GetTitanArmBadgeFromLoadoutAndPrimeStatus( cachedTitanLoadout )
	}

	int function GetCachedTitanArmBadgeState( int loadoutIndex )
	{
		TitanLoadoutDef cachedTitanLoadout = GetCachedTitanLoadout( loadoutIndex )
		return cachedTitanLoadout.showArmBadge
	}

#endif // UI || CLIENT

#if UI
	bool function IsTokenLoadoutName( string name )
	{
		if ( name.find( "#DEFAULT_PILOT_" ) != null || name.find( "#DEFAULT_TITAN_" ) != null )
			return true

		return false
	}
#endif // UI

string function Loadouts_GetSetFileForRequestedClass( entity player )
{
	int loadoutIndex = GetPersistentSpawnLoadoutIndex( player, "pilot" )

	PilotLoadoutDef loadout
	PopulatePilotLoadoutFromPersistentData( player, loadout, loadoutIndex )

	return loadout.setFile
}

#if SERVER
	void function SetPersistentPilotLoadout( entity player, int loadoutIndex, PilotLoadoutDef loadout )
	{
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "name", 				loadout.name )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "suit",				loadout.suit )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "race",				loadout.race )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primary",			loadout.primary )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryAttachment",	loadout.primaryAttachment )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod1",		loadout.primaryMod1 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod2",		loadout.primaryMod2 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod3",		loadout.primaryMod3 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondary",			loadout.secondary )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod1",		loadout.secondaryMod1 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod2",		loadout.secondaryMod2 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod3",		loadout.secondaryMod3 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3",			loadout.weapon3 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3Mod1",		loadout.weapon3Mod1 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3Mod2",		loadout.weapon3Mod2 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "weapon3Mod3",		loadout.weapon3Mod3 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "ordnance",			loadout.ordnance )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "passive1",			loadout.passive1 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "passive2",			loadout.passive2 )
	}

	void function SetPersistentTitanLoadout( entity player, int loadoutIndex, TitanLoadoutDef loadout )
	{
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "name",				loadout.name )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "titanClass",			GetTitanCharacterNameFromSetFile( loadout.setFile ) )
		//SetPersistentLoadoutValue( player, "titan", loadoutIndex, "setFile",			loadout.setFile )
		//SetPersistentLoadoutValue( player, "titan", loadoutIndex, "primaryMod",		loadout.primaryMod )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "special",			loadout.special )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "antirodeo",			loadout.antirodeo )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive1",			loadout.passive1 )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive2",			loadout.passive2 )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive3",			loadout.passive3 )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive4",			loadout.passive4 )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive5",			loadout.passive5 )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive6",			loadout.passive6 )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "titanExecution",		loadout.titanExecution )
	}

	bool function PlayerIsInGracePeriod( entity player )
	{
		if ( svGlobal.isInPilotGracePeriod && !player.IsTitan() )
			return true

		if ( player.s.inGracePeriod )
			return true

		if ( player.p.usingLoadoutCrate )
			return true

		return false
	}

	bool function Loadouts_CanGivePilotLoadout( entity player )
	{
		if ( !IsAlive( player ) )
			return false

		if ( !PlayerIsInGracePeriod( player ) )
			return false

		// hack for bug 114632, 167264. Real fix would be to make dropship spawn script not end on anim reset from model change.
		if ( player.GetParent() != null )
		{
			if ( HasCinematicFlag( player, CE_FLAG_INTRO ) )
		 		return false

			if ( HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) )
		 		return false

		 	if ( HasCinematicFlag( player, CE_FLAG_WAVE_SPAWNING ) )
		 		return false
		}

		if ( player.IsTitan() )
			return false

		return true
	}

	bool function Loadouts_CanGiveTitanLoadout( entity player )
	{
		// if ( GetPlayerBurnCardOnDeckIndex( player ) != null )
		// 	return false

		if ( HasCinematicFlag( player, CE_FLAG_INTRO ) )
			return false

		if ( HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) )
			return false

		if ( !IsAlive( player ) )
			return false

		if ( !PlayerIsInGracePeriod( player ) )
			return false

		if ( player.isSpawningHotDroppingAsTitan )
			return false

		if ( !player.IsTitan() )
			return false

		// JFS: wargames round switch BS
		if ( !IsValid( player.GetTitanSoul() ) )
			return false

		return true
	}


	string function Loadouts_GetSetFileForActiveClass( entity player )
	{
		int loadoutIndex = GetActivePilotLoadoutIndex( player )

		PilotLoadoutDef loadout
		PopulatePilotLoadoutFromPersistentData( player, loadout, loadoutIndex )

		return loadout.setFile
	}


	string function Loadouts_GetPilotRaceForActiveClass( entity player )
	{
		int loadoutIndex = GetActivePilotLoadoutIndex( player )

		PilotLoadoutDef loadout
		PopulatePilotLoadoutFromPersistentData( player, loadout, loadoutIndex )

		return loadout.race
	}

	#if DEV	
	// these are #if DEV'd until they work as their function names describe they should
	// atm these only exist to allow the #if DEV'd calls to them for bot code in this file to compile on retail
	// bots don't work in retail at all, so this doesn't matter for us really, but these should be unDEV'd and api'd properly once they are functional
	
	PilotLoadoutDef function GetRandomPilotLoadout()
	{
		PilotLoadoutDef loadout
		return loadout
	}

	TitanLoadoutDef function GetRandomTitanLoadout( string setFile )
	{
		TitanLoadoutDef loadout
		return loadout
	}
	#endif

	bool function Loadouts_TryGivePilotLoadout( entity player )
	{
		if ( !Loadouts_CanGivePilotLoadout( player ) )
			return false

		PilotLoadoutDef loadout

		int loadoutIndex = GetPersistentSpawnLoadoutIndex( player, "pilot" )

		#if DEV
		if ( player.IsBot() && !player.IsPlayback() && GetConVarString( "bot_pilot_settings" ) == "random" )
			loadout = GetRandomPilotLoadout()
		else
		#endif
			loadout = GetPilotLoadoutFromPersistentData( player, loadoutIndex )

		UpdateDerivedPilotLoadoutData( loadout )

		if ( player.IsBot() && !player.IsPlayback() )
			OverrideBotPilotLoadout( loadout )

		GivePilotLoadout( player, loadout )
		SetActivePilotLoadout( player )
		SetActivePilotLoadoutIndex( player, loadoutIndex )

		//PROTO_DisplayPilotLoadouts( player, loadout )

		return true
	}

	bool function Loadouts_TryGiveTitanLoadout( entity player )
	{
		if ( !Loadouts_CanGiveTitanLoadout( player ) )
			return false

		Assert( IsMultiplayer(), "Spawning as a Titan is not supported in SP currently" )

		entity soul = player.GetTitanSoul()

		TakeAllWeapons( player )
		TakeAllPassives( player )

		soul.passives = arrayofsize( GetNumPassives(), false ) //Clear out passives on soul

		TitanLoadoutDef loadout
		int loadoutIndex = GetPersistentSpawnLoadoutIndex( player, "titan" )

		#if DEV
		if ( player.IsBot() && !player.IsPlayback() )
			{
				string botTitanSettings = GetConVarString( "bot_titan_settings" )
				loadout = GetRandomTitanLoadout( botTitanSettings )

				array<string> legalLoadouts = GetAllowedTitanSetFiles()
				if ( legalLoadouts.contains( botTitanSettings ) )
					loadout.setFile = botTitanSettings //Overwrite just the setfile, mods etc will be random
			}
			else
		#endif
			loadout = GetTitanLoadoutFromPersistentData( player, loadoutIndex )

		OverwriteLoadoutWithDefaultsForSetFile_ExceptSpecialAndAntiRodeo( loadout )

		if ( player.IsBot() && !player.IsPlayback() )
			OverrideBotTitanLoadout( loadout )

		ApplyTitanLoadoutModifiers( player, loadout )

		player.SetPlayerSettingsFromDataTable( { playerSetFile = loadout.setFile, playerSetFileMods = loadout.setFileMods } )
		GiveTitanLoadout( player, loadout )
		SetActiveTitanLoadoutIndex( player, loadoutIndex )
		SetActiveTitanLoadout( player )
		//PROTO_DisplayTitanLoadouts( player, player, loadout )

		string settings = GetSoulPlayerSettings( soul )
		var titanTint = Dev_GetPlayerSettingByKeyField_Global( settings, "titan_tint" )

		if ( titanTint != null )
		{
			expect string( titanTint )
			Highlight_SetEnemyHighlight( player, titanTint )
		}
		else
		{
			Highlight_ClearEnemyHighlight( player )
		}

		var title = GetPlayerSettingsFieldForClassName( settings, "printname" )
		if ( title != null )
		{
			player.SetTitle( expect string( title ) )
		}

		return true
	}

	void function OverrideBotPilotLoadout( PilotLoadoutDef loadout )
	{
		string bot_force_pilot_primary = GetConVarString( "bot_force_pilot_primary" )
		string bot_force_pilot_secondary = GetConVarString( "bot_force_pilot_secondary" )
		//string bot_force_pilot_weapon3 = GetConVarString( "bot_force_pilot_weapon3" ) // TODO: Convar needs to be added in code
		string bot_force_pilot_ordnance = GetConVarString( "bot_force_pilot_ordnance" )
		string bot_force_pilot_ability = GetConVarString( "bot_force_pilot_ability" )

		// Primary
		if ( DevFindItemByName( eItemTypes.PILOT_PRIMARY, bot_force_pilot_primary ) )
		{
			loadout.primary = bot_force_pilot_primary
			loadout.primaryAttachment = ""
			loadout.primaryAttachments = []
			loadout.primaryMod1 = ""
			loadout.primaryMod2 = ""
			loadout.primaryMod3 = ""
			loadout.primaryMods = []
		}

		// Secondary
		if ( DevFindItemByName( eItemTypes.PILOT_SECONDARY, bot_force_pilot_secondary ) )
		{
			loadout.secondary = bot_force_pilot_secondary
			loadout.secondaryMod1 = ""
			loadout.secondaryMod2 = ""
			loadout.secondaryMod3 = ""
			loadout.secondaryMods = []
		}

		// Weapon3
		//if ( DevFindItemByName( eItemTypes.PILOT_SECONDARY, bot_force_pilot_weapon3 ) )
		//{
		//	loadout.weapon3 = bot_force_pilot_weapon3
		//	loadout.weapon3Mod1 = ""
		//	loadout.weapon3Mod2 = ""
		//	loadout.weapon3Mod3 = ""
		//	loadout.weapon3Mods = []
		//}

		// Ordnance/Offhand
		if ( DevFindItemByName( eItemTypes.PILOT_ORDNANCE, bot_force_pilot_ordnance ) )
		{
			loadout.ordnance = bot_force_pilot_ordnance
			loadout.ordnanceMods = []
		}

		// Ability/Special
		if ( DevFindItemByName( eItemTypes.PILOT_SPECIAL, bot_force_pilot_ability ) )
		{
			loadout.special = bot_force_pilot_ability
			loadout.specialMods = []
		}
	}

	void function OverrideBotTitanLoadout( TitanLoadoutDef loadout )
	{
		string bot_force_titan_primary = GetConVarString( "bot_force_titan_primary" )
		string bot_force_titan_ordnance = GetConVarString( "bot_force_titan_ordnance" )
		string bot_force_titan_ability = GetConVarString( "bot_force_titan_ability" )

		// Primary
		if ( DevFindItemByName( eItemTypes.TITAN_PRIMARY, bot_force_titan_primary ) )
		{
			loadout.primary = bot_force_titan_primary
			loadout.primaryMod = ""
			loadout.primaryMods = []
		}

		// Ordnance/Offhand
		if ( DevFindItemByName( eItemTypes.TITAN_ORDNANCE, bot_force_titan_ordnance ) )
		{
			loadout.ordnance = bot_force_titan_ordnance
			loadout.ordnanceMods = []
		}

		// Ability/Special
		if ( DevFindItemByName( eItemTypes.TITAN_SPECIAL, bot_force_titan_ability ) )
		{
			loadout.special = bot_force_titan_ability
			loadout.specialMods = []
		}
	}

	TitanLoadoutDef function GetTitanSpawnLoadout( entity player )
	{
		int loadoutIndex = GetPersistentSpawnLoadoutIndex( player, "titan" )
		TitanLoadoutDef loadout = GetTitanLoadoutFromPersistentData( player, loadoutIndex )
		OverwriteLoadoutWithDefaultsForSetFile_ExceptSpecialAndAntiRodeo( loadout, player )

		return loadout
	}

	// TODO: make loadout crate stuff not update your requested loadout
	void function Loadouts_OnUsedLoadoutCrate( entity player )
	{
		int loadoutIndex = GetPersistentSpawnLoadoutIndex( player, "pilot" )

		PilotLoadoutDef loadout = GetPilotLoadoutFromPersistentData( player, loadoutIndex )

		GivePilotLoadout( player, loadout )
	}

	void function SetActivePilotLoadout( entity player )
	{
		PilotLoadoutDef loadout = GetPilotLoadoutFromPersistentData( player, GetPersistentSpawnLoadoutIndex( player, "pilot" ) )

		player.SetPersistentVar( "activePilotLoadout.name", 				loadout.name )
		player.SetPersistentVar( "activePilotLoadout.suit", 				loadout.suit )
		player.SetPersistentVar( "activePilotLoadout.race", 				loadout.race )
		player.SetPersistentVar( "activePilotLoadout.execution", 			loadout.execution )
		player.SetPersistentVar( "activePilotLoadout.primary", 				loadout.primary )
		player.SetPersistentVar( "activePilotLoadout.primaryAttachment", 	loadout.primaryAttachment )
		player.SetPersistentVar( "activePilotLoadout.primaryMod1", 			loadout.primaryMod1 )
		player.SetPersistentVar( "activePilotLoadout.primaryMod2", 			loadout.primaryMod2 )
		player.SetPersistentVar( "activePilotLoadout.primaryMod3", 			loadout.primaryMod3 )
		player.SetPersistentVar( "activePilotLoadout.secondary", 			loadout.secondary )
		player.SetPersistentVar( "activePilotLoadout.secondaryMod1",		loadout.secondaryMod1 )
		player.SetPersistentVar( "activePilotLoadout.secondaryMod2", 		loadout.secondaryMod2 )
		player.SetPersistentVar( "activePilotLoadout.secondaryMod3", 		loadout.secondaryMod3 )
		player.SetPersistentVar( "activePilotLoadout.weapon3", 				loadout.weapon3 )
		player.SetPersistentVar( "activePilotLoadout.weapon3Mod1",			loadout.weapon3Mod1 )
		player.SetPersistentVar( "activePilotLoadout.weapon3Mod2", 			loadout.weapon3Mod2 )
		player.SetPersistentVar( "activePilotLoadout.weapon3Mod3", 			loadout.weapon3Mod3 )
		player.SetPersistentVar( "activePilotLoadout.ordnance",				loadout.ordnance )
		player.SetPersistentVar( "activePilotLoadout.passive1",				loadout.passive1 )
		player.SetPersistentVar( "activePilotLoadout.passive2",				loadout.passive2 )
		player.SetPersistentVar( "activePilotLoadout.skinIndex",			loadout.skinIndex )
		player.SetPersistentVar( "activePilotLoadout.camoIndex",			loadout.camoIndex )
		player.SetPersistentVar( "activePilotLoadout.primarySkinIndex",		loadout.primarySkinIndex )
		player.SetPersistentVar( "activePilotLoadout.primaryCamoIndex",		loadout.primaryCamoIndex )
		player.SetPersistentVar( "activePilotLoadout.secondarySkinIndex", 	loadout.secondarySkinIndex )
		player.SetPersistentVar( "activePilotLoadout.secondaryCamoIndex",	loadout.secondaryCamoIndex )
		player.SetPersistentVar( "activePilotLoadout.weapon3SkinIndex", 	loadout.weapon3SkinIndex )
		player.SetPersistentVar( "activePilotLoadout.weapon3CamoIndex",		loadout.weapon3CamoIndex )
	}

	void function SetActivePilotLoadoutIndex( entity player, int loadoutIndex )
	{
		player.p.activePilotLoadoutIndex = loadoutIndex
		player.SetPlayerNetInt( "activePilotLoadoutIndex", loadoutIndex )
	}

	void function SetActiveTitanLoadout( entity player )
	{
		Assert( player.IsPlayer(), "Titan spawn loadout makes sense for players not NPCs")
		TitanLoadoutDef loadout = GetTitanSpawnLoadout( player )

		player.SetPersistentVar( "activeTitanLoadout.name", 				loadout.name )
		player.SetPersistentVar( "activeTitanLoadout.titanClass", 			loadout.titanClass )
		player.SetPersistentVar( "activeTitanLoadout.primaryMod", 			loadout.primaryMod )
		player.SetPersistentVar( "activeTitanLoadout.special", 				loadout.special )
		player.SetPersistentVar( "activeTitanLoadout.antirodeo", 			loadout.antirodeo )
		player.SetPersistentVar( "activeTitanLoadout.passive1", 			loadout.passive1 )
		player.SetPersistentVar( "activeTitanLoadout.passive2", 			loadout.passive2 )
		player.SetPersistentVar( "activeTitanLoadout.passive3", 			loadout.passive3 )
		player.SetPersistentVar( "activeTitanLoadout.passive4", 			loadout.passive4 )
		player.SetPersistentVar( "activeTitanLoadout.passive5", 			loadout.passive5 )
		player.SetPersistentVar( "activeTitanLoadout.passive6", 			loadout.passive6 )
		player.SetPersistentVar( "activeTitanLoadout.skinIndex", 			loadout.skinIndex )
		player.SetPersistentVar( "activeTitanLoadout.camoIndex", 			loadout.camoIndex )
		player.SetPersistentVar( "activeTitanLoadout.decalIndex", 			loadout.decalIndex )
		player.SetPersistentVar( "activeTitanLoadout.primarySkinIndex", 	loadout.primarySkinIndex )
		player.SetPersistentVar( "activeTitanLoadout.primaryCamoIndex", 	loadout.primaryCamoIndex )
		player.SetPersistentVar( "activeTitanLoadout.titanExecution", 		loadout.titanExecution )
		player.SetPersistentVar( "activeTitanLoadout.isPrime", 				loadout.isPrime )
		player.SetPersistentVar( "activeTitanLoadout.primeSkinIndex", 		loadout.primeSkinIndex )
		player.SetPersistentVar( "activeTitanLoadout.primeCamoIndex", 		loadout.primeCamoIndex )
		player.SetPersistentVar( "activeTitanLoadout.primeDecalIndex", 		loadout.primeDecalIndex )
		player.SetPersistentVar( "activeTitanLoadout.showArmBadge", 		loadout.showArmBadge )
	}

	void function SetActiveTitanLoadoutIndex( entity player, int loadoutIndex )
	{
		//printt( ">>>>>>>>>>>>> SetActiveTitanLoadoutIndex() with index:", loadoutIndex )
		player.p.activeTitanLoadoutIndex = loadoutIndex
		player.SetPlayerNetInt( "activeTitanLoadoutIndex", loadoutIndex )
	}

	void function PROTO_DisplayTitanLoadouts( entity player, entity titan, TitanLoadoutDef loadout )
	{
		entity soul = titan.GetTitanSoul()
		if ( soul.e.embarkCount > 0 )
			return

		if ( loadout.primary != "" )
			PROTO_PlayLoadoutNotification( loadout.primary, player )
		if ( loadout.ordnance != "" )
			PROTO_PlayLoadoutNotification( loadout.ordnance, player )
		if ( loadout.special != "" )
			PROTO_PlayLoadoutNotification( loadout.special, player )
		if ( loadout.passive1 != "" )
			PROTO_PlayLoadoutNotification( loadout.passive1, player )
		if ( loadout.passive2 != "" )
			PROTO_PlayLoadoutNotification( loadout.passive2, player )
		if ( loadout.passive3 != "" )
			PROTO_PlayLoadoutNotification( loadout.passive3, player )
		if ( loadout.passive4 != "" )
			PROTO_PlayLoadoutNotification( loadout.passive4, player )
		if ( loadout.passive5 != "" )
			PROTO_PlayLoadoutNotification( loadout.passive5, player )
		if ( loadout.passive6 != "" )
			PROTO_PlayLoadoutNotification( loadout.passive6, player )
	}

	void function PROTO_DisplayPilotLoadouts( entity player, PilotLoadoutDef loadout )
	{
		if ( loadout.primary != "" )
			PROTO_PlayLoadoutNotification( loadout.primary, player )
		if ( loadout.secondary != "" )
			PROTO_PlayLoadoutNotification( loadout.secondary, player )
		if ( loadout.ordnance != "" )
			PROTO_PlayLoadoutNotification( loadout.ordnance, player )
		if ( loadout.special != "" )
			PROTO_PlayLoadoutNotification( loadout.special, player )
		if ( loadout.passive1 != "" )
			PROTO_PlayLoadoutNotification( loadout.passive1, player )
		if ( loadout.passive2 != "" )
			PROTO_PlayLoadoutNotification( loadout.passive2, player )
	}
#endif //SERVER

#if !UI
	PilotLoadoutDef function GetActivePilotLoadout( entity player )
	{
		PilotLoadoutDef loadout
		loadout.name 				= string( player.GetPersistentVar( "activePilotLoadout.name" ) )
		loadout.suit 				= string( player.GetPersistentVar( "activePilotLoadout.suit" ) )
		loadout.race 				= string( player.GetPersistentVar( "activePilotLoadout.race" ) )
		loadout.execution 			= string( player.GetPersistentVar( "activePilotLoadout.execution" ) )
		loadout.primary 			= string( player.GetPersistentVar( "activePilotLoadout.primary" ) )
		loadout.primaryAttachment	= string( player.GetPersistentVar( "activePilotLoadout.primaryAttachment" ) )
		loadout.primaryMod1			= string( player.GetPersistentVar( "activePilotLoadout.primaryMod1" ) )
		loadout.primaryMod2			= string( player.GetPersistentVar( "activePilotLoadout.primaryMod2" ) )
		loadout.primaryMod3			= string( player.GetPersistentVar( "activePilotLoadout.primaryMod3" ) )
		loadout.secondary 			= string( player.GetPersistentVar( "activePilotLoadout.secondary" ) )
		loadout.secondaryMod1		= string( player.GetPersistentVar( "activePilotLoadout.secondaryMod1" ) )
		loadout.secondaryMod2		= string( player.GetPersistentVar( "activePilotLoadout.secondaryMod2" ) )
		loadout.secondaryMod3		= string( player.GetPersistentVar( "activePilotLoadout.secondaryMod3" ) )
		loadout.weapon3 			= string( player.GetPersistentVar( "activePilotLoadout.weapon3" ) )
		loadout.weapon3Mod1			= string( player.GetPersistentVar( "activePilotLoadout.weapon3Mod1" ) )
		loadout.weapon3Mod2			= string( player.GetPersistentVar( "activePilotLoadout.weapon3Mod2" ) )
		loadout.weapon3Mod3			= string( player.GetPersistentVar( "activePilotLoadout.weapon3Mod3" ) )
		loadout.ordnance 			= string( player.GetPersistentVar( "activePilotLoadout.ordnance" ) )
		loadout.passive1 			= string( player.GetPersistentVar( "activePilotLoadout.passive1" ) )
		loadout.passive2 			= string( player.GetPersistentVar( "activePilotLoadout.passive2" ) )
		loadout.skinIndex			= player.GetPersistentVarAsInt( "activePilotLoadout.skinIndex" )
		loadout.camoIndex			= player.GetPersistentVarAsInt( "activePilotLoadout.camoIndex" )
		loadout.primarySkinIndex	= player.GetPersistentVarAsInt( "activePilotLoadout.primarySkinIndex" )
		loadout.primaryCamoIndex	= player.GetPersistentVarAsInt( "activePilotLoadout.primaryCamoIndex" )
		loadout.secondarySkinIndex	= player.GetPersistentVarAsInt( "activePilotLoadout.secondarySkinIndex" )
		loadout.secondaryCamoIndex	= player.GetPersistentVarAsInt( "activePilotLoadout.secondaryCamoIndex" )
		loadout.weapon3SkinIndex	= player.GetPersistentVarAsInt( "activePilotLoadout.weapon3SkinIndex" )
		loadout.weapon3CamoIndex	= player.GetPersistentVarAsInt( "activePilotLoadout.weapon3CamoIndex" )

		UpdateDerivedPilotLoadoutData( loadout )

		return loadout
	}

	TitanLoadoutDef function GetActiveTitanLoadout( entity player )
	{
		TitanLoadoutDef loadout
		loadout.name 				= string( player.GetPersistentVar( "activeTitanLoadout.name" ) )
		loadout.titanClass 			= string( player.GetPersistentVar( "activeTitanLoadout.titanClass" ) )
		loadout.primaryMod 			= string( player.GetPersistentVar( "activeTitanLoadout.primaryMod" ) )
		loadout.special 			= string( player.GetPersistentVar( "activeTitanLoadout.special" ) )
		loadout.antirodeo 			= string( player.GetPersistentVar( "activeTitanLoadout.antirodeo" ) )
		loadout.passive1 			= string( player.GetPersistentVar( "activeTitanLoadout.passive1" ) )
		loadout.passive2 			= string( player.GetPersistentVar( "activeTitanLoadout.passive2" ) )
		loadout.passive3 			= string( player.GetPersistentVar( "activeTitanLoadout.passive3" ) )
		loadout.passive4 			= string( player.GetPersistentVar( "activeTitanLoadout.passive4" ) )
		loadout.passive5 			= string( player.GetPersistentVar( "activeTitanLoadout.passive5" ) )
		loadout.passive6 			= string( player.GetPersistentVar( "activeTitanLoadout.passive6" ) )
		loadout.titanExecution 		= string( player.GetPersistentVar( "activeTitanLoadout.titanExecution" ) )
		loadout.skinIndex			= player.GetPersistentVarAsInt( "activeTitanLoadout.skinIndex" )
		loadout.camoIndex			= player.GetPersistentVarAsInt( "activeTitanLoadout.camoIndex" )
		loadout.decalIndex			= player.GetPersistentVarAsInt( "activeTitanLoadout.decalIndex" )
		loadout.primarySkinIndex	= player.GetPersistentVarAsInt( "activeTitanLoadout.primarySkinIndex" )
		loadout.primaryCamoIndex	= player.GetPersistentVarAsInt( "activeTitanLoadout.primaryCamoIndex" )
		loadout.isPrime				= string( player.GetPersistentVar( "activeTitanLoadout.isPrime" ) )
		loadout.primeSkinIndex		= player.GetPersistentVarAsInt( "activeTitanLoadout.primeSkinIndex" )
		loadout.primeCamoIndex		= player.GetPersistentVarAsInt( "activeTitanLoadout.primeCamoIndex" )
		loadout.primeDecalIndex		= player.GetPersistentVarAsInt( "activeTitanLoadout.primeDecalIndex" )
		loadout.showArmBadge		= player.GetPersistentVarAsInt( "activeTitanLoadout.showArmBadge" )

		UpdateDerivedTitanLoadoutData( loadout )
		OverwriteLoadoutWithDefaultsForSetFile_ExceptSpecialAndAntiRodeo( loadout, player )

		//int loadoutIndex = GetActiveTitanLoadoutIndex( player )

		//TitanLoadoutDef loadout = GetTitanLoadoutFromPersistentData( player, loadoutIndex )
		//OverwriteLoadoutWithDefaultsForSetFile_ExceptSpecialAndAntiRodeo( loadout )

		return loadout
	}

	// When possible use GetActivePilotLoadout() instead
	int function GetActivePilotLoadoutIndex( entity player )
	{
		#if SERVER
			return player.p.activePilotLoadoutIndex
		#else
			return player.GetPlayerNetInt( "activePilotLoadoutIndex" )
		#endif
	}

	int function GetActiveTitanLoadoutIndex( entity player )
	{
		//printt( "<<<<<<<<<<<<< GetActiveTitanLoadoutIndex() with index:", player.p.activeTitanLoadoutIndex )
		#if SERVER
			return player.p.activeTitanLoadoutIndex
		#else
			return player.GetPlayerNetInt( "activeTitanLoadoutIndex" )
		#endif
	}
#endif

// Added doOverrideCallback as a temporary measure to work around an issue the callback override added here is causing
// This is called in PopulateDefaultPilotLoadouts() which sets the data GetDefaultPilotLoadout() returns
// GetDefaultPilotLoadout() should never be returning overridden loadouts because it is used in many places to correct or reset persistent loadout data
void function UpdateDerivedPilotLoadoutData( PilotLoadoutDef loadout, bool doOverrideCallback = true )
{
	loadout.setFile 			= GetSuitAndGenderBasedSetFile( loadout.suit, loadout.race )
	loadout.special				= GetSuitBasedTactical( loadout.suit )
	loadout.primaryAttachments	= [ loadout.primaryAttachment ]
	loadout.primaryMods			= [ loadout.primaryMod1, loadout.primaryMod2, loadout.primaryMod3 ]
	loadout.secondaryMods		= [ loadout.secondaryMod1, loadout.secondaryMod2, loadout.secondaryMod3 ]
	loadout.weapon3Mods			= [ loadout.weapon3Mod1, loadout.weapon3Mod2, loadout.weapon3Mod3 ]
	loadout.setFileMods 		= GetSetFileModsForSettingType( "pilot", [ loadout.passive1, loadout.passive2 ] )

	#if SERVER
		if ( doOverrideCallback )
		{
			foreach ( callbackFunc in svGlobal.onUpdateDerivedPilotLoadoutCallbacks )
				callbackFunc( loadout )
		}
	#endif
}

bool function TitanClassHasPrimeTitan( string titanClass )
{
	string nonPrimeSetFile = GetSetFileForTitanClassAndPrimeStatus( titanClass, false )
	string primeSetFile = GetPrimeTitanSetFileFromNonPrimeSetFile( nonPrimeSetFile )

	return primeSetFile != ""
}

bool function IsTitanLoadoutPrime( TitanLoadoutDef loadout )
{
	return loadout.isPrime == "titan_is_prime"
}

bool function IsTitanClassPrime( entity player, string titanClass )
{
	for ( int i = 0; i < NUM_PERSISTENT_TITAN_LOADOUTS; i++ )
	{
		TitanLoadoutDef loadout = GetTitanLoadoutFromPersistentData( player, i )
		if ( loadout.titanClass == titanClass )
		{
			if ( loadout.isPrime == "titan_is_prime" )
				return true
			else
				return false
		}
	}

	unreachable
}

void function UpdateDerivedTitanLoadoutData( TitanLoadoutDef loadout )
{
	bool isTitanLoadoutPrime = IsTitanLoadoutPrime( loadout )
	loadout.setFile = GetSetFileForTitanClassAndPrimeStatus( loadout.titanClass, IsTitanLoadoutPrime( loadout ) )
	loadout.primeTitanRef	= GetPrimeTitanRefForTitanClass( loadout.titanClass )
}

void function PrintPilotLoadoutIndex( entity player, int index )
{
	PrintPilotLoadout( GetPilotLoadoutFromPersistentData( player, index ) )
}

void function PrintTitanLoadoutIndex( entity player, int index )
{
	PrintTitanLoadout( GetTitanLoadoutFromPersistentData( player, index ) )
}

void function PrintPilotLoadouts( entity player )
{
	for ( int i = 0; i < NUM_PERSISTENT_PILOT_LOADOUTS; i++ )
		PrintPilotLoadoutIndex( player, i )
}

void function PrintTitanLoadouts( entity player )
{
	for ( int i = 0; i < NUM_PERSISTENT_TITAN_LOADOUTS; i++ )
		PrintTitanLoadoutIndex( player, i )
}

void function PrintPilotLoadout( PilotLoadoutDef loadout )
{
	printt( "PILOT LOADOUT:" )
	printt( "    PERSISTENT DATA:" )
	printt( "        name                     \"" + loadout.name + "\"" )
	printt( "        suit                     \"" + loadout.suit + "\"" )
	printt( "        race                     \"" + loadout.race + "\"" )
	printt( "        execution                \"" + loadout.execution + "\"" )
	printt( "        primary                  \"" + loadout.primary + "\"" )
	printt( "            primaryAttachment    \"" + loadout.primaryAttachment + "\"" )
	printt( "            primaryMod1          \"" + loadout.primaryMod1 + "\"" )
	printt( "            primaryMod2          \"" + loadout.primaryMod2 + "\"" )
	printt( "            primaryMod3          \"" + loadout.primaryMod3 + "\"" )
	printt( "            primarySkinIndex     "   + loadout.primarySkinIndex )
	printt( "            primaryCamoIndex     "   + loadout.primaryCamoIndex )
	printt( "        secondary                \"" + loadout.secondary + "\"" )
	printt( "            secondaryMod1        \"" + loadout.secondaryMod1 + "\"" )
	printt( "            secondaryMod2        \"" + loadout.secondaryMod2 + "\"" )
	printt( "            secondaryMod3        \"" + loadout.secondaryMod3 + "\"" )
	printt( "            secondarySkinIndex   "   + loadout.secondarySkinIndex )
	printt( "            secondaryCamoIndex   "   + loadout.secondaryCamoIndex )
	printt( "        weapon3                  \"" + loadout.weapon3 + "\"" )
	printt( "            weapon3Mod1          \"" + loadout.weapon3Mod1 + "\"" )
	printt( "            weapon3Mod2          \"" + loadout.weapon3Mod2 + "\"" )
	printt( "            weapon3Mod3          \"" + loadout.weapon3Mod3 + "\"" )
	printt( "            weapon3SkinIndex     "   + loadout.weapon3SkinIndex )
	printt( "            weapon3CamoIndex     "   + loadout.weapon3CamoIndex )
	printt( "        ordnance                 \"" + loadout.ordnance + "\"" )
	printt( "        special                  \"" + loadout.special + "\"" )
	printt( "        passive1                 \"" + loadout.passive1 + "\"" )
	printt( "        passive2                 \"" + loadout.passive2 + "\"" )
	printt( "        skinIndex                "   + loadout.skinIndex )
	printt( "        camoIndex                "   + loadout.camoIndex )
	printt( "    DERIVED DATA:" )
	printt( "        setFile                  \"" + loadout.setFile + "\"" )
	print(  "        setFileMods              " )
	PrintStringArray( loadout.setFileMods )
	printt( "        melee                    \"" + loadout.melee + "\"" )
	print(  "        meleeMods                " )
	PrintStringArray( loadout.meleeMods )
	print(  "        primaryAttachments       " )
	PrintStringArray( loadout.primaryAttachments )
	print(  "        primaryMods              " )
	PrintStringArray( loadout.primaryMods )
	print(  "        secondaryMods            " )
	PrintStringArray( loadout.secondaryMods )
	print(  "        weapon3Mods              " )
	PrintStringArray( loadout.weapon3Mods )
	print(  "        specialMods              " )
	PrintStringArray( loadout.specialMods )
	print(  "        ordnanceMods             " )
	PrintStringArray( loadout.ordnanceMods )
}

void function PrintTitanLoadout( TitanLoadoutDef loadout )
{
	printt( "TITAN LOADOUT:" )
	printt( "    PERSISTENT DATA:" )
	printt( "        name                 \"" + loadout.name + "\"" )
	printt( "        titanClass           \"" + loadout.titanClass + "\"" )
	printt( "        setFile              \"" + loadout.setFile + "\"" )
	printt( "        primeTitanRef        \"" + loadout.primeTitanRef + "\"" )
	printt( "        primaryMod           \"" + loadout.primaryMod + "\"" )
	printt( "        special              \"" + loadout.special + "\"" )
	printt( "        antirodeo            \"" + loadout.antirodeo + "\"" )
	printt( "        passive1             \"" + loadout.passive1 + "\"" )
	printt( "        passive2             \"" + loadout.passive2 + "\"" )
	printt( "        passive3             \"" + loadout.passive3 + "\"" )
	printt( "        passive4             \"" + loadout.passive4 + "\"" )
	printt( "        passive5             \"" + loadout.passive5 + "\"" )
	printt( "        passive6             \"" + loadout.passive6 + "\"" )
	printt( "        voice                \"" + loadout.voice + "\"" )
	printt( "        skinIndex            "   + loadout.skinIndex )
	printt( "        camoIndex            "   + loadout.camoIndex )
	printt( "        decalIndex           "   + loadout.decalIndex )
	printt( "        primarySkinIndex     "   + loadout.primarySkinIndex )
	printt( "        primaryCamoIndex     "   + loadout.primaryCamoIndex )
	printt( "        isPrime              \"" + loadout.isPrime + "\"" )
	printt( "        primeSkinIndex       "   + loadout.primeSkinIndex )
	printt( "        primeCamoIndex       "   + loadout.primeCamoIndex )
	printt( "        primeDecalIndex      "   + loadout.primeDecalIndex )
	printt( "    DERIVED DATA:" )
	print(  "        setFileMods          " )
	PrintStringArray( loadout.setFileMods )
	printt( "        melee                \"" + loadout.melee + "\"" )
	printt( "        coreAbility          \"" + loadout.coreAbility + "\"" )
	printt( "        primary              \"" + loadout.primary + "\"" )
	printt( "        primaryAttachment    \"" + loadout.primaryAttachment + "\"" )
	print(  "        primaryMods          " )
	PrintStringArray( loadout.primaryMods )
	printt( "        ordnance             \"" + loadout.ordnance + "\"" )
	print(  "        ordnanceMods         " )
	PrintStringArray( loadout.ordnanceMods )
	print(  "        specialMods          " )
	PrintStringArray( loadout.specialMods )
	print(  "        antirodeoMods        " )
	PrintStringArray( loadout.antirodeoMods )
}

void function PrintStringArray( array<string> stringArray )
{
	if ( stringArray.len() == 0 )
	{
		print( "[]" )
	}
	else
	{
		for ( int i = 0; i < stringArray.len(); i++ )
		{
			if ( i == 0 )
				print( "[ " )

			print( "\"" + stringArray[i] + "\"" )

			if ( i+1 < stringArray.len() )
				print( ", " )
			else
				print( " ]" )
		}
	}

	print( "\n" )
}

string function GetSkinPropertyName( string camoPropertyName )
{
	string skinPropertyName

	switch ( camoPropertyName )
	{
		case "camoIndex":
			skinPropertyName = "skinIndex"
			break

		case "primeCamoIndex":
			skinPropertyName = "primeSkinIndex"
			break

		case "primaryCamoIndex":
			skinPropertyName = "primarySkinIndex"
			break

		case "secondaryCamoIndex":
			skinPropertyName = "secondarySkinIndex"
			break

		case "weapon3CamoIndex":
			skinPropertyName = "weapon3SkinIndex"
			break

		default:
			Assert( false, "Unknown camoPropertyName: " + camoPropertyName )
			break
	}

	return skinPropertyName
}

int function GetSkinIndexForCamo( string modelType, string camoPropertyName, int camoIndex )
{
	Assert( modelType == "pilot" || modelType == "titan" )
	Assert( camoPropertyName == "camoIndex" || camoPropertyName == "primeCamoIndex" || camoPropertyName == "primaryCamoIndex" || camoPropertyName == "secondaryCamoIndex" || camoPropertyName == "weapon3CamoIndex" )

	int skinIndex = SKIN_INDEX_BASE

	if ( camoIndex > 0 )
	{
		if ( camoPropertyName == "camoIndex" || camoPropertyName == "primeCamoIndex" )
		{
			if ( modelType == "pilot" )
				skinIndex = PILOT_SKIN_INDEX_CAMO
			else
				skinIndex = TITAN_SKIN_INDEX_CAMO
		}
		else if ( camoPropertyName == "primaryCamoIndex" || camoPropertyName == "secondaryCamoIndex" || camoPropertyName == "weapon3CamoIndex" )
		{
			skinIndex = WEAPON_SKIN_INDEX_CAMO
		}
	}

	return skinIndex
}

#if SERVER
void function UpdateProScreen( entity player, entity weapon )
{
	int proScreenKills = WeaponGetProScreenKills( player, weapon.GetWeaponClassName() )
	int previousProScreenKills = WeaponGetPreviousProScreenKills( player, weapon.GetWeaponClassName() )
	weapon.SetProScreenIntValForIndex( PRO_SCREEN_INT_LIFETIME_KILLS, proScreenKills )
	weapon.SetProScreenIntValForIndex( PRO_SCREEN_INT_MATCH_KILLS, proScreenKills - previousProScreenKills )
}
#endif

bool function IsValidPilotLoadoutIndex( int loadoutIndex )
{
	if ( loadoutIndex < 0 )
		return false

	if( loadoutIndex >= NUM_PERSISTENT_PILOT_LOADOUTS )
		return false

	return true
}

bool function IsValidTitanLoadoutIndex( int loadoutIndex )
{
	if ( loadoutIndex < 0 )
		return false

	if( loadoutIndex >= NUM_PERSISTENT_TITAN_LOADOUTS )
		return false

	return true
}

bool function HasPrimeToMatchExecutionType( entity player, int itemType )
{
	if ( DevEverythingUnlocked( player ) )
		return true

	switch( itemType )
	{
		case eItemTypes.TITAN_RONIN_EXECUTION:
			return !IsItemLocked( player, "ronin_prime" )
		case eItemTypes.TITAN_NORTHSTAR_EXECUTION:
			return !IsItemLocked( player, "northstar_prime" )
		case eItemTypes.TITAN_ION_EXECUTION:
			return !IsItemLocked( player, "ion_prime" )
		case eItemTypes.TITAN_TONE_EXECUTION:
			return !IsItemLocked( player, "tone_prime" )
		case eItemTypes.TITAN_SCORCH_EXECUTION:
			return !IsItemLocked( player, "scorch_prime" )
		case eItemTypes.TITAN_LEGION_EXECUTION:
			return !IsItemLocked( player, "legion_prime" )
		case eItemTypes.TITAN_VANGUARD_EXECUTION:
			return false

		default:
			unreachable
	}
	unreachable
}

bool function IsTitanLoadoutAvailable( entity player, string titanClass )
{
	int titanClassLockState = player.GetPersistentVarAsInt( "titanClassLockState[" + titanClass + "]" )
	return (titanClassLockState == TITAN_CLASS_LOCK_STATE_AVAILABLE || titanClassLockState == TITAN_CLASS_LOCK_STATE_LEVELRECOMMENDED)
}

int function GetTitanLoadAvailableState(  entity player, string titanClass )
{
	return player.GetPersistentVarAsInt( "titanClassLockState[" + titanClass + "]" )
}

#if UI || CLIENT
void function SwapSecondaryAndWeapon3LoadoutData( entity player, int loadoutIndex )
{
	// Keep CLIENT matching UI
	#if UI
		RunClientScript( "SwapSecondaryAndWeapon3LoadoutData", player, loadoutIndex )
	#endif // UI

	string loadoutType = "pilot"

	PilotLoadoutDef loadout
	loadout.secondary = shGlobal.cachedPilotLoadouts[ loadoutIndex ].secondary
	loadout.secondaryMod1 = shGlobal.cachedPilotLoadouts[ loadoutIndex ].secondaryMod1
	loadout.secondaryMod2 = shGlobal.cachedPilotLoadouts[ loadoutIndex ].secondaryMod2
	loadout.secondaryMod3 = shGlobal.cachedPilotLoadouts[ loadoutIndex ].secondaryMod3
	loadout.secondarySkinIndex = shGlobal.cachedPilotLoadouts[ loadoutIndex ].secondarySkinIndex
	loadout.secondaryCamoIndex = shGlobal.cachedPilotLoadouts[ loadoutIndex ].secondaryCamoIndex

	loadout.weapon3 = shGlobal.cachedPilotLoadouts[ loadoutIndex ].weapon3
	loadout.weapon3Mod1 = shGlobal.cachedPilotLoadouts[ loadoutIndex ].weapon3Mod1
	loadout.weapon3Mod2 = shGlobal.cachedPilotLoadouts[ loadoutIndex ].weapon3Mod2
	loadout.weapon3Mod3 = shGlobal.cachedPilotLoadouts[ loadoutIndex ].weapon3Mod3
	loadout.weapon3SkinIndex = shGlobal.cachedPilotLoadouts[ loadoutIndex ].weapon3SkinIndex
	loadout.weapon3CamoIndex = shGlobal.cachedPilotLoadouts[ loadoutIndex ].weapon3CamoIndex

	SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], "secondary", loadout.weapon3 )
	SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], "secondaryMod1", loadout.weapon3Mod1 )
	SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], "secondaryMod2", loadout.weapon3Mod2 )
	SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], "secondaryMod3", loadout.weapon3Mod3 )
	SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], "secondarySkinIndex", string( loadout.weapon3SkinIndex ) )
	SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], "secondaryCamoIndex", string( loadout.weapon3CamoIndex ) )

	SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], "weapon3", loadout.secondary )
	SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], "weapon3Mod1", loadout.secondaryMod1 )
	SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], "weapon3Mod2", loadout.secondaryMod2 )
	SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], "weapon3Mod3", loadout.secondaryMod3 )
	SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], "weapon3SkinIndex", string( loadout.secondarySkinIndex ) )
	SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], "weapon3CamoIndex", string( loadout.secondaryCamoIndex ) )

	#if UI
		ClientCommand( "SwapSecondaryAndWeapon3PersistentLoadoutData " + loadoutIndex )
	#endif // UI
}
#endif // UI || CLIENT
