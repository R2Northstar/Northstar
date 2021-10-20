untyped

global function InitItems
global function InitUnlock

global function ItemDefined
global function IsRefValid
global function IsUnlockValid
global function SubitemDefined

global function IsDisabledRef

global function GetIconForTitanClass

global function GetItemData
global function GetItemType
global function GetItemMenuAnimClass
global function GetItemId
global function GetItemName
global function GetItemLongName
global function GetItemDescription
global function GetItemLongDescription
global function GetItemPersistenceId
global function GetItemDisplayDataFromGuid
#if UI
global function GetItemUnlockReqText
global function GetUnlockProgressText
global function GetUnlockProgressFrac
global function Player_GetRecentUnlock
global function Player_GetRecentUnlockCount
global function IsItemPurchasableEntitlement
global function GetPurchasableEntitlementMenu
#endif
global function GetItemImage
global function GetItemCost
global function GetSubItemClipSizeStat
global function GetPlayerDecalUnlockData
global function GetItemStat
global function GetModdedItemStat
global function GetSubitemStat
global function GetTitanStat
global function GetImage
global function GetAllWeaponsByType
global function GetItemTypeName
global function GetItemRefTypeName
global function GetItemRequiresPrime

global function IsItemInEntitlementUnlock
global function GetEntitlementIds

global function GetItemImageAspect

global function GetItemUnlockType
global function GetSubItemUnlockType

global function GetItemDisplayData

global function GetRefFromItem

global function GetUnlockLevelReq
global function GetUnlockLevelReqWithParent

global function GetSubitemDisplayData
global function GetSubitemType
global function GetSubitemId
global function GetSubitemName
global function GetSubitemDescription
global function GetSubitemLongDescription
global function GetSubitemImage
global function GetSubitemCost

global function HasSubitem

global function GetAllItemsOfType
global function GetAllItemRefsOfType
global function GetVisibleItemsOfType
global function GetVisibleItemsOfTypeForCategory
global function GetVisibleItemsOfTypeWithoutEntitlements
global function GetVisibleItemsOfTypeMatchingEntitlementID
global function GetIndexForUnlockItem
global function GetAllItemRefs
global function GetAllSubitemRefs
global function GetDisplaySubItemsOfType

global function GetAllRefsOfType
global function GetRandomItemRefOfType

global function GetItemRefOfTypeByIndex
global function GetItemIndexOfTypeByRef

global function ItemSupportsAttachments
global function ItemSupportsAttachment
global function ItemSupportsMods

global function ItemTypeSupportsAttachments
global function ItemTypeSupportsMods

global function IsItemTypeMod
global function IsItemTypeAttachment

global function IsSubItemType

global function IsItemLocked
global function IsSubItemLocked

global function IsItemOwned
global function IsSubItemOwned

global function IsItemLockedForPlayer
global function IsItemLockedForWeapon
global function IsItemLockedForTitan

global function IsItemLockedForPlayerLevel
global function IsItemLockedForWeaponLevel
global function IsItemLockedForTitanLevel
global function IsItemLockedForFDTitanLevel

global function GetItemPersistenceStruct
global function IsItemNew

global function GetOwnedEliteWeaponSkins
global function GetStatUnlockStatVal
#if UI
global function UpdateCachedNewItems
global function GetCachedNewItemsVar
global function ClearNewStatus
global function HasAnyNewPilotItems
global function HasAnyNewTitanItems
global function HasAnyNewBoosts
global function HasAnyNewDpadCommsIcons
global function HasAnyNewFactions
global function HasAnyNewCallsignBanners
global function HasAnyNewCallsignPatches
global function HasAnyNewArmoryItems
global function ButtonShouldShowNew
global function RefHasAnyNewSubitem
global function HasAnyNewItemOfCategory
global function GetStatUnlockProgress
global function GetStatUnlockProgressFrac
#endif
#if UI || CLIENT
global function GetStatUnlockReq
#endif
#if SERVER
global function SetItemNewStatus
global function SetItemOwned
global function ClearItemOwned
global function CodeCallback_GivePersistentItem
global function Player_AddRecentUnlock
global function PersistenceCleanup
global function GetNoseArtRefFromTitanClassAndPersistenceValue
global function GetSkinRefFromTitanClassAndPersistenceValue
global function UnlockUltimateEdition
#endif
global function GetSkinRefFromWeaponRefAndPersistenceValue
global function GetUnlockItemsForPlayerLevels
global function GetUnlockItemsForTitanLevels
global function GetNextUnlockForTitanLevel
global function GetUnlockItemsForWeaponLevels
global function GetNextUnlockForWeaponLevel
global function GetUnlockItemsForFactionLevels
global function GetUnlockItemsForPlayerLevel
global function GetUnlockItemsForTitanLevel
global function GetUnlockItemsForWeaponLevel
global function GetUnlockItemsForFactionLevel

global function GetUnlockItemsForFDTitanLevel
global function GetUnlockItemsForFDTitanLevels
global function GetNextUnlockForFDTitanLevel
global function FD_GetUpgradesForTitanClass

global function GetUnlockItemsForPlayerRawLevel

global function GetTitanCoreIcon

global function DidPlayerBuyItemFromBlackMarket

global function GetDisplayNameFromItemType
global function PrintItemData
global function PrintItems

global function CheckItemUnlockType

global function CreateWeaponData

global function GetSuitAndGenderBasedSetFile
global function GetSuitBasedTactical
//global function GetSuitBasedDefaultPassive
global function GetWeaponBasedDefaultMod

global function GetTitanLoadoutPropertyPassiveType
global function GetTitanLoadoutPropertyExecutionType
global function GetPrimeTitanSetFileFromNonPrimeSetFile

global function CheckEverythingUnlockedAchievement

global function DevFindItemByName
global function DEV_GetEnumStringFromIndex

global function ItemReport
global function UnlockReport
global function UnlockDump

#if SERVER
global function Player_SetDoubleXPCount
global function Player_SetColiseumTicketCount

global function Player_GiveColiseumTickets
global function Player_GiveDoubleXP
global function Player_GiveCredits
global function Player_ActivateDoubleXP
global function Player_GiveFDUnlockPoints

global function AwardCredits
#endif

global function Player_GetColiseumTicketCount
global function Player_GetDoubleXPCount

global function GetWeaponForTitan
global function GetTitanForWeapon

global function StringHash

global function RefreshSortedElems
global function GetSortedIndex

global function SortItemsAlphabetically
global function ItemsInSameMenuCategory
global function GetTitanLoadoutIconFD

global function GetTitanPrimeBg

global function GetItemRefsForEntitlements

global function WeaponWarpaint_GetByIndex

#if DEV
global function GenerateValidateDataTableCRCText
global function GenerateAllValidateDataTableCRCCheckText
#endif

// northstar additional global funcs, some of these are new, some are preexisting ones i'm making global for modularity reasons
global function AddCallback_OnRegisterCustomItems

global function CreateGenericSubItemData
global function CreateGenericItem
global function CreateModData
global function CreatePassiveData
global function CreatePilotSuitData
global function CreateTitanExecutionData
global function CreateTitanData
global function CreatePrimeTitanData
global function CreateNoseArtData
global function CreateSkinData
global function CreateFDTitanUpgradeData
global function CreateBaseItemData
global function CreateWeaponSkinData

global const MOD_ICON_NONE = $"ui/menu/items/mod_icons/none"

global enum eUnlockType
{
	DISABLED,
	PLAYER_LEVEL,
	TITAN_LEVEL,
	WEAPON_LEVEL,
	FACTION_LEVEL,
	ENTITLEMENT,
	PERSISTENT_ITEM,
	STAT,
	RANDOM,
	FD_UNLOCK_POINTS,
}


global struct PurchaseData
{
	string purchaseMenu
}

global struct ChildUnlock
{
	int unlockType = eUnlockType.DISABLED
	int unlockLevel = 1
	float unlockFloatVal = 0
	int unlockIntVal = 0
	array<int> entitlementIds
	int cost
	string additionalRef
	table additionalData
	PurchaseData purchaseData
}

global struct Unlock
{
	int unlockType = eUnlockType.DISABLED
	int unlockLevel = 1
	float unlockFloatVal = 0
	int unlockIntVal = 0
	array<int> entitlementIds
	table<string, ChildUnlock> child
	int cost
	string parentRef
	string additionalRef
	table additionalData
	PurchaseData purchaseData
}


global struct GlobalItemRef
{
	int guid
	string ref
	int itemType

	bool hidden // TODO: remove
}


struct modCommonDef
{
	string modType
	string name
	string description
	asset image
	int dataTableIndex
	int cost
	int costSniper
	int costPistol
	int costAT
}


global struct ItemDisplayData
{
	int itemType
	string ref
	string parentRef

	string name
	string desc
	string longdesc
	asset image
	int imageAtlas
	int persistenceId

	bool hidden
	bool reqPrime
	int slot

	table< var, var > i
}

global struct SubItemData
{
	int itemType // TODO: temp until PRIMARY_MOD/ATTACHEMENT/SECONDARY are gone
	string ref
	string parentRef
	int cost
	int slot

	table< var, var > i
}


global struct ItemData
{
//	GlobalItemRef& globalItemRef if we do this, we should remove itemType and ref.

	int itemType
	string ref
	string parentRef

	string name
	string longname
	string desc
	string longdesc
	asset image
	int imageAtlas

	int cost

	bool hidden
	bool reqPrime
	int slot

	string persistenceStruct
	int persistenceId

	table< string, SubItemData > subitems

	table< var, var > i
}

struct
{
	array<GlobalItemRef> allItems
	table< string, int > itemRefToGuid
	table< int, string > guidToItemRef

	table<string, ItemData> itemData
	table< int, array<string> > itemsOfType
	table<string, ItemData> itemsWithPersistenceStruct

	array<GlobalItemRef>[eItemTypes.COUNT] globalItemRefsOfType

	table < string, ItemDisplayData > displayDataCache

	table <string, int> cachedNewItems

	table<string, Unlock> unlocks
	table<string, Unlock> entitlementUnlocks

	table<string, array<int> > sortedElems

	table<string, table<int, string> > titanClassAndPersistenceValueToNoseArtRefTable //Primarily used to speed up validation of persistence data
	table<string, table<int, string> > titanClassAndPersistenceValueToSkinRefTable //Primarily used to speed up validation of persistence data
	table<string, table<int, string> > weaponRefAndPersistenceValueToSkinRefTable //Primarily used to speed up validation of persistence data
	
	// northstar custom hooks
	array<void functionref()> itemRegistrationCallbacks
} file

void function InitItems()
{
	file.unlocks = {}
	file.entitlementUnlocks = {}

	file.allItems = []
	file.itemRefToGuid = {}
	file.guidToItemRef = {}
	file.guidToItemRef[0] <- "reserved"

	file.itemData = {}
	file.itemsOfType = {}

	file.displayDataCache = {}

	for ( int i = 0; i < eItemTypes.COUNT; i++ )
	{
		file.itemsOfType[ i ] <- []
		file.globalItemRefsOfType[ i ] = []
	}

	#if SERVER
		AddClientCommandCallback( "BuyItem", ClientCommand_BuyItem )
		AddClientCommandCallback( "BuyTicket", ClientCommand_BuyTicket )
		AddClientCommandCallback( "ClearNewStatus", ClientCommand_ClearNewStatus )
		AddClientCommandCallback( "UseDoubleXP", ClientCommand_UseDoubleXP )
		AddClientCommandCallback( "DEV_GiveFDUnlockPoint", ClientCommand_DEV_GiveFDUnlockPoint )
		AddClientCommandCallback( "DEV_ResetTitanProgression", ClientCommand_DEV_ResetTitanProgression )
	#endif

	#if UI
		uiGlobal.itemsInitialized = true
	#endif

	#if CLIENT
		ClearItemTypes();
	#endif

	if ( IsSingleplayer() )
	{
		InitTitanWeaponDataSP()
		return
	}

	#if DEV
	//Updated with DLC 4
	ValidateDataTableCRC( $"datatable/burn_meter_rewards.rpak", 13, -195196861 )
	ValidateDataTableCRC( $"datatable/calling_cards.rpak", 379, -93927632 )
	ValidateDataTableCRC( $"datatable/callsign_icons.rpak", 167, 2015621078 )
	ValidateDataTableCRC( $"datatable/camo_skins.rpak", 140, -320502469 )
	ValidateDataTableCRC( $"datatable/faction_leaders.rpak", 7, -686839648 )
	ValidateDataTableCRC( $"datatable/features_mp.rpak", 18, 1879135085 )
	ValidateDataTableCRC( $"datatable/pilot_abilities.rpak", 15, 2112045689 )
	ValidateDataTableCRC( $"datatable/pilot_executions.rpak", 10, 1341275658 )
	ValidateDataTableCRC( $"datatable/pilot_passives.rpak", 8, 981112716 )
	ValidateDataTableCRC( $"datatable/pilot_properties.rpak", 7, -1114320894 )
	ValidateDataTableCRC( $"datatable/pilot_weapon_features.rpak", 4, 439636371 )
	ValidateDataTableCRC( $"datatable/pilot_weapon_mods.rpak", 249, 2010060417 )
	ValidateDataTableCRC( $"datatable/pilot_weapon_mods_common.rpak", 25, -761470088 )
	ValidateDataTableCRC( $"datatable/pilot_weapons.rpak", 32, 1625188373 )
	ValidateDataTableCRC( $"datatable/playlist_items.rpak", 19, -1360623070 )
	ValidateDataTableCRC( $"datatable/titan_nose_art.rpak", 150, 1922555441 )
	ValidateDataTableCRC( $"datatable/titan_passives.rpak", 51, 1139205682 )
	ValidateDataTableCRC( $"datatable/titan_primary_mods.rpak", 0, 0 )
	ValidateDataTableCRC( $"datatable/titan_primary_mods_common.rpak", 0, 0 )
	ValidateDataTableCRC( $"datatable/titan_properties.rpak", 8, -1270130815 )
	ValidateDataTableCRC( $"datatable/titan_skins.rpak", 42, 1057626784 )
	ValidateDataTableCRC( $"datatable/titan_voices.rpak", 8, -1605184394 )
	ValidateDataTableCRC( $"datatable/titans_mp.rpak", 7, 420442720 )
	#endif

	var dataTable
	int numRows

	////////////////////
	//CAMO SKINS DATA
	////////////////////
	//CreateBaseItemData( eItemTypes.FEATURE, "no_item", true )

	dataTable = GetDataTable( $"datatable/camo_skins.rpak" )
	table<int, int> categoryCounts = {}
	for ( int row = 0; row < GetDatatableRowCount( dataTable ); row++ )
	{
		string camoRef = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, CAMO_REF_COLUMN_NAME ) )
		string pilotCamoRef = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, CAMO_PILOT_REF_COLUMN_NAME ) )
		string titanCamoRef = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, CAMO_TITAN_REF_COLUMN_NAME ) )
		asset image = GetDataTableAsset( dataTable, row, GetDataTableColumnByName( dataTable, CAMO_IMAGE_COLUMN_NAME ) )
		string name = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, CAMO_NAME_COLUMN_NAME ) )
		string desc = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, CAMO_DESCRIPTION_COLUMN_NAME ) )
		int pilotCost = GetDataTableInt( dataTable, row, GetDataTableColumnByName( dataTable, CAMO_PILOT_COST_COLUMN_NAME ) )
		int categoryId = GetDataTableInt( dataTable, row, GetDataTableColumnByName( dataTable, CAMO_CATEGORY_COLUMN_NAME ) )

		if ( !(categoryId in categoryCounts) )
			categoryCounts[categoryId] <- 0

		categoryCounts[categoryId]++

		int datatableIndex = row

		const bool IS_HIDDEN_ARG = false

		ItemData item
		item = CreateGenericItem( datatableIndex, eItemTypes.CAMO_SKIN_PILOT, pilotCamoRef, name, desc, desc, image, pilotCost, IS_HIDDEN_ARG )
		item.imageAtlas = IMAGE_ATLAS_CAMO
		item.i.categoryId <- categoryId

		item = CreateGenericItem( datatableIndex, eItemTypes.CAMO_SKIN_TITAN, titanCamoRef, name, desc, desc, image, 0, IS_HIDDEN_ARG )
		item.imageAtlas = IMAGE_ATLAS_CAMO
		item.i.categoryId <- categoryId

		item = CreateGenericItem( datatableIndex, eItemTypes.CAMO_SKIN, camoRef, name, desc, desc, image, 0, IS_HIDDEN_ARG )
		item.imageAtlas = IMAGE_ATLAS_CAMO
		item.i.categoryId <- categoryId
	}

	InitTitanWeaponDataMP()

	////////////////////
	//PILOT WEAPON DATA
	////////////////////

	dataTable = GetDataTable( $"datatable/pilot_weapons.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string itemRef			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "itemRef" ) )
		int itemType			= eItemTypes[ GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "type" ) ) ]
		bool hidden				= GetDataTableBool( dataTable, i, GetDataTableColumnByName( dataTable, "hidden" ) )
		string xpPerLevelType	= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "xpPerLevelType" ) )
		int cost				= GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "cost" ) )
		WeaponSetXPPerLevelType( itemRef, xpPerLevelType )

		CreateWeaponData( i, itemType, hidden, itemRef, true, cost )

		var camoSkinsDataTable = GetDataTable( $"datatable/camo_skins.rpak" )
		for ( int camoRow = 0; camoRow < GetDatatableRowCount( camoSkinsDataTable ); camoRow++ )
		{
			string camoRef = GetDataTableString( camoSkinsDataTable, camoRow, GetDataTableColumnByName( camoSkinsDataTable, CAMO_REF_COLUMN_NAME ) )
			int weaponCamoCost = GetDataTableInt( camoSkinsDataTable, camoRow, GetDataTableColumnByName( camoSkinsDataTable, CAMO_PILOT_WEAPON_COST_COLUMN_NAME ) )
			int categoryId = GetDataTableInt( camoSkinsDataTable, camoRow, GetDataTableColumnByName( camoSkinsDataTable, CAMO_CATEGORY_COLUMN_NAME ) )

			CreateGenericSubItemData( eItemTypes.CAMO_SKIN, itemRef, camoRef, weaponCamoCost, { categoryId = categoryId } )
		}
	}

	SetupWeaponSkinData()

	dataTable = GetDataTable( $"datatable/pilot_abilities.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string itemRef			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "itemRef" ) )
		int itemType			= eItemTypes[ GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "type" ) ) ]
		bool isDamageSource		= GetDataTableBool( dataTable, i, GetDataTableColumnByName( dataTable, "damageSource" ) )
		bool hidden				= GetDataTableBool( dataTable, i, GetDataTableColumnByName( dataTable, "hidden" ) )
		int cost				= GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "cost" ) )

		CreateWeaponData( i, itemType, hidden, itemRef, isDamageSource, cost )
	}

	////////////////////////
	//PILOT MODS/ATTACHMENTS
	////////////////////////

	dataTable = GetDataTable( $"datatable/pilot_weapon_mods_common.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	table<string, modCommonDef> modCommonTable

	for ( int i = 0; i < numRows; i++ )
	{
		modCommonDef modCommon
		modCommon.modType        	= GetDataTableString( dataTable, i, PILOT_WEAPON_MOD_COMMON_TYPE_COLUMN )
		Assert( modCommon.modType == "attachment" || modCommon.modType == "mod" || modCommon.modType == "mod3" )

		modCommon.name            	= GetDataTableString( dataTable, i, PILOT_WEAPON_MOD_COMMON_NAME_COLUMN )
		modCommon.description    	= GetDataTableString( dataTable, i, PILOT_WEAPON_MOD_COMMON_DESCRIPTION_COLUMN )
		modCommon.image        		= GetDataTableAsset( dataTable, i, PILOT_WEAPON_MOD_COMMON_IMAGE_COLUMN )
		modCommon.cost				= GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "cost" ) )
		modCommon.costSniper		= GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "costSniper" ) )
		modCommon.costPistol		= GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "costPistol" ) )
		modCommon.costAT			= GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "costAT" ) )

		modCommon.dataTableIndex = i

		string itemRef            = GetDataTableString( dataTable, i, PILOT_WEAPON_MOD_COMMON_COLUMN )
		modCommonTable[ itemRef ] <- modCommon

		ItemData modCommonData
		if ( modCommon.modType == "attachment" )
			modCommonData = CreateBaseItemData( eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT, itemRef, false )
		else
			modCommonData = CreateBaseItemData( eItemTypes.SUB_PILOT_WEAPON_MOD, itemRef, false )

		modCommonData.name = modCommon.name
		modCommonData.longname = modCommon.name
		modCommonData.desc = modCommon.description
		modCommonData.image = modCommon.image
		modCommonData.persistenceId = modCommon.dataTableIndex
		modCommonData.imageAtlas = IMAGE_ATLAS_MENU
	}

	dataTable = GetDataTable( $"datatable/pilot_weapon_mods.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	var weaponTable    = GetDataTable( $"datatable/pilot_weapons.rpak" )
	for ( int i = 0; i < numRows; i++ )
	{
		string mod				= GetDataTableString( dataTable, i, PILOT_WEAPON_MOD_COLUMN )
		string weapon        	= GetDataTableString( dataTable, i, PILOT_WEAPON_MOD_WEAPON_COLUMN )
		bool hidden            	= GetDataTableBool( dataTable, i, PILOT_WEAPON_MOD_HIDDEN_COLUMN )

		int typeRow            	= GetDataTableRowMatchingStringValue( weaponTable, GetDataTableColumnByName( weaponTable, "itemRef" ), weapon )
		int weaponType        	= eItemTypes[ GetDataTableString( weaponTable, typeRow, GetDataTableColumnByName( weaponTable, "type" ) ) ]

		int cost
		string xpPerLevelType	= GetDataTableString( weaponTable, typeRow, GetDataTableColumnByName( weaponTable, "xpPerLevelType" ) )
		switch ( xpPerLevelType )
		{
			case "sniper":
				cost = modCommonTable[ mod ].costSniper
				break

			case "pistol":
				cost = modCommonTable[ mod ].costPistol
				break

			case "antititan":
				cost = modCommonTable[ mod ].costAT
				break

			default:
				cost = modCommonTable[ mod ].cost
		}

		if ( modCommonTable[ mod ].modType == "attachment" )
		{
			Assert( weaponType == eItemTypes.PILOT_PRIMARY )

			CreateModData( eItemTypes.PILOT_PRIMARY_ATTACHMENT, weapon, mod, cost )
		}
		else if ( modCommonTable[ mod ].modType == "mod" )
		{
			Assert( weaponType == eItemTypes.PILOT_PRIMARY || weaponType == eItemTypes.PILOT_SECONDARY )
			int itemType = weaponType == eItemTypes.PILOT_PRIMARY ? eItemTypes.PILOT_PRIMARY_MOD : eItemTypes.PILOT_SECONDARY_MOD

			int damageDisplay    = GetDataTableInt( dataTable, i, PILOT_WEAPON_MOD_DAMAGEDISPLAY_COLUMN )
			int accuracyDisplay    = GetDataTableInt( dataTable, i, PILOT_WEAPON_MOD_ACCURACYDISPLAY_COLUMN )
			int rangeDisplay    = GetDataTableInt( dataTable, i, PILOT_WEAPON_MOD_RANGEDISPLAY_COLUMN )
			int fireRateDisplay    = GetDataTableInt( dataTable, i, PILOT_WEAPON_MOD_FIRERATEDISPLAY_COLUMN )
			int clipSizeDisplay    = GetDataTableInt( dataTable, i, PILOT_WEAPON_MOD_CLIPSIZEDISPLAY_COLUMN )

			CreateModData( itemType, weapon, mod, cost, damageDisplay, accuracyDisplay, rangeDisplay, fireRateDisplay, clipSizeDisplay )
		}
		else
		{
			Assert( modCommonTable[ mod ].modType == "mod3" )
			CreateModData( eItemTypes.PILOT_WEAPON_MOD3, weapon, mod, cost )
		}
	}

	/////////////////////
	//PILOT PASSIVE DATA
	/////////////////////

	dataTable = GetDataTable( $"datatable/pilot_passives.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string itemRef      = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "passive" ) )
		int itemType        = eItemTypes[ GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "type" ) ) ]
		string name			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "name" ) )
		string description	= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "description" ) )
		asset image			= GetDataTableAsset( dataTable, i, GetDataTableColumnByName( dataTable, "image" ) )
		bool hidden			= GetDataTableBool( dataTable, i, GetDataTableColumnByName( dataTable, "hidden" ) )
		int cost			= GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "cost" ) )

		CreatePassiveData( i, itemType, hidden, itemRef, name, description, description, image, cost )
	}

	/////////////////////
	//SUIT DATA
	/////////////////////

	dataTable = GetDataTable( $"datatable/pilot_properties.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string itemRef	= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "type" ) )
		asset image		= GetDataTableAsset( dataTable, i, GetDataTableColumnByName( dataTable, "image" ) )
		int cost		= GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "cost" ) )

		CreatePilotSuitData( i, eItemTypes.PILOT_SUIT, itemRef, image, cost )
	}

	CreateBaseItemData( eItemTypes.RACE, "race_human_male", false )
	CreateBaseItemData( eItemTypes.RACE, "race_human_female", false )

	/////////////////////
	//PILOT EXECUTION DATA
	/////////////////////

	dataTable = GetDataTable( $"datatable/pilot_executions.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string ref			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "ref" ) )
		string name			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "name" ) )
		string description	= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "description" ) )
		asset image			= GetDataTableAsset( dataTable, i, GetDataTableColumnByName( dataTable, "image" ) )
		bool hidden			= GetDataTableBool( dataTable, i, GetDataTableColumnByName( dataTable, "hidden" ) )
		int cost			= GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "cost" ) )

		if ( IsDisabledRef( ref ) )
			continue

		CreatePassiveData( i, eItemTypes.PILOT_EXECUTION, hidden, ref, name, description, description, image, cost )
	}
	/////////////////////
	//TITAN EXECUTION DATA
	/////////////////////

	dataTable = GetDataTable( $"datatable/titan_executions.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		bool hidden			= GetDataTableBool( dataTable, i, GetDataTableColumnByName( dataTable, "hidden" ) )
		if ( hidden == true )
			continue

		string ref			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "ref" ) )
		int itemType		= eItemTypes[ GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "type" ) ) ]
		string name			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "name" ) )
		string description	= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "description" ) )
		asset image			= GetDataTableAsset( dataTable, i, GetDataTableColumnByName( dataTable, "image" ) )
		int cost			= GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "cost" ) )
		bool reqPrime		= GetDataTableBool( dataTable, i, GetDataTableColumnByName( dataTable, "reqPrime" ) )

		if ( IsDisabledRef( ref ) )
			continue

		CreateTitanExecutionData( i, itemType, hidden, ref, name, description, description, image, cost, reqPrime )
	}
	/////////////////////

	dataTable = GetDataTable( $"datatable/features_mp.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	int featureIndex = 0
	for ( int i = 0; i < numRows; i++ )
	{
		string featureRef = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "featureRef" ) )
		string name			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "featureName" ) )
		string desc			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "featureDesc" ) )
		asset image			= GetDataTableAsset( dataTable, i, GetDataTableColumnByName( dataTable, "featureIcon" ) )
		int cost			= GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "cost" ) )
		string specificType = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "specificType" ) )

		const bool IS_HIDDEN_ARG = false
		ItemData featureItem = CreateGenericItem( featureIndex, eItemTypes.FEATURE, featureRef, name, desc, "", image, cost, IS_HIDDEN_ARG )
		featureItem.i.specificType <- specificType

		featureIndex++
	}

	dataTable = GetDataTable( $"datatable/playlist_items.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string playlistRef = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "playlist" ) )
		string name			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "name" ) )
		asset image			= GetDataTableAsset( dataTable, i, GetDataTableColumnByName( dataTable, "image" ) )
		int cost			= GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "cost" ) )

		const bool IS_HIDDEN_ARG = false
		ItemData featureItem = CreateGenericItem( featureIndex, eItemTypes.FEATURE, playlistRef, name, "", "", image, cost, IS_HIDDEN_ARG )
		featureItem.i.specificType <- "#ITEM_TYPE_PLAYLIST"
		featureItem.i.isPlaylist <- true

		featureIndex++
	}

	//{
	//	int featureIndex = 0
	//	int gameModeCount = PersistenceGetEnumCount( "gameModes" )
	//	for ( int modeIndex = 0; modeIndex < gameModeCount; modeIndex++ )
	//	{
	//		string gameModeRef = PersistenceGetEnumItemNameForIndex( "gameModes", modeIndex )
	//		if ( !IsRefValid( gameModeRef ) )
	//		{
	//			string name = GameMode_GetName( gameModeRef )
	//			string desc = GameMode_GetDesc( gameModeRef )
	//			asset image = GameMode_GetIcon( gameModeRef )
	//			int cost = 0
	//
	//			CreateGenericItem( featureIndex, eItemTypes.GAME_MODE, gameModeRef, name, desc, "", image, cost )
	//			featureIndex++
	//		}
	//	}
	//}

	dataTable = GetDataTable( $"datatable/pilot_weapon_features.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string featureRef = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "featureRef" ) )
		string name			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "featureName" ) )
		string desc			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "featureDesc" ) )
		asset image			= GetDataTableAsset( dataTable, i, GetDataTableColumnByName( dataTable, "featureIcon" ) )
		int cost			= GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "cost" ) )
		int dataTableIndex = i
		const bool IS_HIDDEN_ARG = false
		CreateGenericItem( dataTableIndex, eItemTypes.WEAPON_FEATURE, featureRef, name, desc, "", image, cost, IS_HIDDEN_ARG )
	}

	/////////////////////
	//PILOT SECONDARY MOD SLOTS
	/////////////////////
	dataTable = GetDataTable( $"datatable/pilot_weapons.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string weaponRef = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "itemRef" ) )
		int weaponType = eItemTypes[ GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "type" ) ) ]
		if ( weaponType == eItemTypes.PILOT_PRIMARY )
		{
			CreateGenericSubItemData( eItemTypes.WEAPON_FEATURE, weaponRef, "primarymod2", file.itemData["primarymod2"].cost )
			CreateGenericSubItemData( eItemTypes.WEAPON_FEATURE, weaponRef, "primarymod3", file.itemData["primarymod3"].cost )
		}
		else
		{
			CreateGenericSubItemData( eItemTypes.WEAPON_FEATURE, weaponRef, "secondarymod2", file.itemData["secondarymod2"].cost )
			CreateGenericSubItemData( eItemTypes.WEAPON_FEATURE, weaponRef, "secondarymod3", file.itemData["secondarymod3"].cost )
		}
	}

	/////////////////////
	//FACTION DATA
	/////////////////////
	dataTable = GetDataTable( $"datatable/faction_leaders.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string factionRef = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "persistenceRef" ) )
		asset logo = GetDataTableAsset( dataTable, i, GetDataTableColumnByName( dataTable, "logo" ) )
		string name = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "factionName" ) )
		int cost = GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "cost" ) )

		ItemData item = CreateBaseItemData( eItemTypes.FACTION, factionRef, false )
		item.image = logo
		item.name = name
		item.cost = cost
		item.imageAtlas = IMAGE_ATLAS_FACTION_LOGO
		item.persistenceId = i
	}

	/////////////////
	//TITAN MOD DATA
	/////////////////
	dataTable = GetDataTable( $"datatable/titan_primary_mods_common.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	modCommonTable.clear()

	for ( int i = 0; i < numRows; i++ )
	{
		modCommonDef modCommon
		modCommon.name            = GetDataTableString( dataTable, i, TITAN_PRIMARY_MOD_COMMON_NAME_COLUMN )
		modCommon.description    = GetDataTableString( dataTable, i, TITAN_PRIMARY_MOD_COMMON_DESCRIPTION_COLUMN )
		modCommon.image        = GetDataTableAsset( dataTable, i, TITAN_PRIMARY_MOD_COMMON_IMAGE_COLUMN )

		modCommon.dataTableIndex = i

		string itemRef            = GetDataTableString( dataTable, i, TITAN_PRIMARY_MOD_COMMON_COLUMN )
		modCommonTable[ itemRef ] <- modCommon
	}

	dataTable = GetDataTable( $"datatable/titan_primary_mods.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string mod          = GetDataTableString( dataTable, i, TITAN_PRIMARY_MOD_COLUMN )
		string weapon       = GetDataTableString( dataTable, i, TITAN_PRIMARY_MOD_WEAPON_COLUMN )

		string name        	= modCommonTable[ mod ].name
		string description  = modCommonTable[ mod ].description
		asset image        	= modCommonTable[ mod ].image
		int dataTableIndex  = modCommonTable[ mod ].dataTableIndex

		int damageDisplay   = GetDataTableInt( dataTable, i, TITAN_PRIMARY_MOD_DAMAGEDISPLAY_COLUMN )
		int accuracyDisplay = GetDataTableInt( dataTable, i, TITAN_PRIMARY_MOD_ACCURACYDISPLAY_COLUMN )
		int rangeDisplay   	= GetDataTableInt( dataTable, i, TITAN_PRIMARY_MOD_RANGEDISPLAY_COLUMN )
		int fireRateDisplay = GetDataTableInt( dataTable, i, TITAN_PRIMARY_MOD_FIRERATEDISPLAY_COLUMN )
		int clipSizeDisplay = GetDataTableInt( dataTable, i, TITAN_PRIMARY_MOD_CLIPSIZEDISPLAY_COLUMN )

		bool hidden         = GetDataTableBool( dataTable, i, TITAN_PRIMARY_MOD_HIDDEN_COLUMN )

//		CreateModData( dataTableIndex, eItemTypes.TITAN_PRIMARY_MOD, weapon, mod, name, description, description, image, damageDisplay, accuracyDisplay, rangeDisplay, fireRateDisplay, clipSizeDisplay )
	}

	/////////////////////
	//TITAN PASSIVE DATA
	/////////////////////

	dataTable = GetDataTable( $"datatable/titan_passives.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string itemRef      = GetDataTableString( dataTable, i, TITAN_PASSIVE_COLUMN )
		int itemType		= eItemTypes[ GetDataTableString( dataTable, i, TITAN_PASSIVE_TYPE_COLUMN ) ]
		string name        	= GetDataTableString( dataTable, i, TITAN_PASSIVE_NAME_COLUMN )
		string description  = GetDataTableString( dataTable, i, TITAN_PASSIVE_DESCRIPTION_COLUMN )
		string longDescription  = GetDataTableString( dataTable, i, TITAN_PASSIVE_LONGDESCRIPTION_COLUMN )
		asset image        	= GetDataTableAsset( dataTable, i, TITAN_PASSIVE_IMAGE_COLUMN )
		bool hidden         = GetDataTableBool( dataTable, i, TITAN_PASSIVE_HIDDEN_COLUMN )
		int cost	        = GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "cost" ) )

		CreatePassiveData( i, itemType, hidden, itemRef, name, description, longDescription, image, cost )
	}

	/////////////////////
	//TITAN OS DATA
	/////////////////////

	dataTable = GetDataTable( $"datatable/titan_voices.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string itemRef     = GetDataTableString( dataTable, i, TITAN_VOICE_COLUMN )
		string name        = GetDataTableString( dataTable, i, TITAN_VOICE_NAME_COLUMN )
		string description = GetDataTableString( dataTable, i, TITAN_VOICE_DESCRIPTION_COLUMN )
		asset image        = GetDataTableAsset( dataTable, i, TITAN_VOICE_IMAGE_COLUMN )
		bool hidden        = GetDataTableBool( dataTable, i, TITAN_VOICE_HIDDEN_COLUMN )

		const bool IS_HIDDEN_ARG = false
		CreateGenericItem( i, eItemTypes.TITAN_OS, itemRef, name, description, description, image, 0, IS_HIDDEN_ARG )
	}


	var titanPropertiesDataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	var titansMpDataTable = GetDataTable( $"datatable/titans_mp.rpak" )
	numRows = GetDatatableRowCount( titansMpDataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string titanRef		= GetDataTableString( titansMpDataTable, i, GetDataTableColumnByName( titansMpDataTable, "titanRef" ) )
		int cost			= GetDataTableInt( titansMpDataTable, i, GetDataTableColumnByName( titansMpDataTable, "cost" ) )
		asset image			= GetDataTableAsset( titansMpDataTable, i, GetDataTableColumnByName( titansMpDataTable, "image" ) )
		asset coreIcon		= GetDataTableAsset( titansMpDataTable, i, GetDataTableColumnByName( titansMpDataTable, "coreIcon" ) )

		if ( IsDisabledRef( titanRef ) )
		    continue

		CreateTitanData( i, titanRef, cost, image, coreIcon )

		ItemData itemData = GetItemData( titanRef )
		int passive1Type = expect int( itemData.i.passive1Type )
		int passive2Type = expect int( itemData.i.passive2Type )
		int passive3Type = expect int( itemData.i.passive3Type )
		int passive4Type = expect int( itemData.i.passive4Type )
		int passive5Type = expect int( itemData.i.passive5Type )
		int passive6Type = expect int( itemData.i.passive6Type )

		{
			array<ItemData> items = GetAllItemsOfType( passive1Type )
			foreach ( item in items )
			{
				CreateGenericSubItemData( passive1Type, titanRef, item.ref, GetItemCost( item.ref ) )
			}
		}

		if ( passive1Type != passive2Type )
		{
			array<ItemData> items = GetAllItemsOfType( passive2Type )
			foreach ( item in items )
			{
				CreateGenericSubItemData( passive2Type, titanRef, item.ref, GetItemCost( item.ref ) )
			}
		}

		if ( passive3Type != passive1Type && passive3Type != passive2Type  )
		{
			array<ItemData> items = GetAllItemsOfType( passive3Type )
			foreach ( item in items )
			{
				CreateGenericSubItemData( passive3Type, titanRef, item.ref, GetItemCost( item.ref ) )
			}
		}

		array<ItemData> passive4items = GetAllItemsOfType( passive4Type )
		foreach ( item in passive4items )
		{
			CreateGenericSubItemData( passive4Type, titanRef, item.ref, GetItemCost( item.ref ) )
		}

		array<ItemData> passive5items = GetAllItemsOfType( passive5Type )
		foreach ( item in passive5items )
		{
			CreateGenericSubItemData( passive5Type, titanRef, item.ref, GetItemCost( item.ref ) )
		}

		array<ItemData> passive6items = GetAllItemsOfType( passive6Type )
		foreach ( item in passive6items )
		{
			CreateGenericSubItemData( passive6Type, titanRef, item.ref, GetItemCost( item.ref ) )
		}

		{
			var camoSkinsDataTable = GetDataTable( $"datatable/camo_skins.rpak" )
			for ( int camoRow = 0; camoRow < GetDatatableRowCount( camoSkinsDataTable ); camoRow++ )
			{
				string camoRef = GetDataTableString( camoSkinsDataTable, camoRow, GetDataTableColumnByName( camoSkinsDataTable, CAMO_REF_COLUMN_NAME ) )
				string titanCamoRef = GetDataTableString( camoSkinsDataTable, camoRow, GetDataTableColumnByName( camoSkinsDataTable, CAMO_TITAN_REF_COLUMN_NAME ) )
				int titanWeaponCost = GetDataTableInt( camoSkinsDataTable, camoRow, GetDataTableColumnByName( camoSkinsDataTable, CAMO_TITAN_WEAPON_COST_COLUMN_NAME ) )
				int titanCost = GetDataTableInt( camoSkinsDataTable, camoRow, GetDataTableColumnByName( camoSkinsDataTable, CAMO_TITAN_COST_COLUMN_NAME ) )
				int categoryId = GetDataTableInt( camoSkinsDataTable, camoRow, GetDataTableColumnByName( camoSkinsDataTable, CAMO_CATEGORY_COLUMN_NAME ) )

				CreateGenericSubItemData( eItemTypes.CAMO_SKIN, titanRef, camoRef, titanWeaponCost, { categoryId = categoryId } )
				CreateGenericSubItemData( eItemTypes.CAMO_SKIN_TITAN, titanRef, titanCamoRef, titanCost, { categoryId = categoryId } )
			}
		}

		#if SERVER || CLIENT
		int propertyRow = GetDataTableRowMatchingStringValue( titanPropertiesDataTable, GetDataTableColumnByName( titanPropertiesDataTable, "titanRef" ), titanRef )
		string setFile = GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "setFile" ) )
		PrecacheModel( GetPlayerSettingsAssetForClassName( setFile, "bodymodel" ) )
		PrecacheModel( GetPlayerSettingsAssetForClassName( setFile, "armsmodel" ) )
		string primeSetFile = GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "primeSetFile" ) )
		if ( primeSetFile != "" )
		{
			PrecacheModel( GetPlayerSettingsAssetForClassName( primeSetFile, "bodymodel" ) )
			PrecacheModel( GetPlayerSettingsAssetForClassName( primeSetFile, "armsmodel" ) )
		}
		#endif

		//string primary = GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "primary" ) )
		//string melee = GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "melee" ) )
		//string ordnance = GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "ordnance" ) )
		//string special = GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "special" ) )
		//string antirodeo = GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "antirodeo" ) )
		//string coreAbility = GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "coreAbility" ) )
	}

	//////////////////////////
	// DLC1
	//////////////////////////
	//Need to be moved up here for prime_titan_nose_art to work
	CreatePrimeTitanData( eItemTypes.PRIME_TITAN, "ion_prime", "ion", true )
	CreatePrimeTitanData( eItemTypes.PRIME_TITAN, "tone_prime", "tone", true )
	CreatePrimeTitanData( eItemTypes.PRIME_TITAN, "scorch_prime", "scorch", true )
	CreatePrimeTitanData( eItemTypes.PRIME_TITAN, "legion_prime", "legion", true )
	CreatePrimeTitanData( eItemTypes.PRIME_TITAN, "ronin_prime", "ronin", true )
	CreatePrimeTitanData( eItemTypes.PRIME_TITAN, "northstar_prime", "northstar", true )
	CreatePrimeTitanData( eItemTypes.PRIME_TITAN, "vanguard_prime", "vanguard", true )

	dataTable = GetDataTable( $"datatable/titan_nose_art.rpak" )
	table<string, int> decalIndexTable
	for ( int row = 0; row < GetDatatableRowCount( dataTable ); row++ )
	{
		string titanRef = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "titanRef" ) )
		string ref = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "ref" ) )
		asset image = GetDataTableAsset( dataTable, row, GetDataTableColumnByName( dataTable, "image" ) )
		string name = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "name" ) )
		int cost = GetDataTableInt( dataTable, row, GetDataTableColumnByName( dataTable, "cost" ) )

		if ( IsDisabledRef( titanRef ) )
		    continue

		if ( !( titanRef in decalIndexTable ) )
			decalIndexTable[titanRef] <- 0
		else
			decalIndexTable[titanRef]++

		//CreateGenericItem( datatableIndex, eItemTypes.TITAN_NOSE_ART, ref, name, "", "", image )
		//CreateBaseItemData( eItemTypes.TITAN_NOSE_ART, ref, false )
		CreateNoseArtData( decalIndexTable[titanRef], eItemTypes.TITAN_NOSE_ART, false, ref, name, image, decalIndexTable[titanRef] )
		CreateGenericSubItemData( eItemTypes.TITAN_NOSE_ART, titanRef, ref, cost )


		if ( !( titanRef in file.titanClassAndPersistenceValueToNoseArtRefTable ) )
			file.titanClassAndPersistenceValueToNoseArtRefTable[ titanRef ] <- {}

		file.titanClassAndPersistenceValueToNoseArtRefTable[ titanRef ][ decalIndexTable[titanRef] ] <- ref

	}

	dataTable = GetDataTable( $"datatable/titan_skins.rpak" )
	for ( int row = 0; row < GetDatatableRowCount( dataTable ); row++ )
	{
		string titanRef = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "titanRef" ) )
		string ref = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "ref" ) )
		asset image = GetDataTableAsset( dataTable, row, GetDataTableColumnByName( dataTable, "image" ) )
		string name = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "name" ) )
		int cost = GetDataTableInt( dataTable, row, GetDataTableColumnByName( dataTable, "cost" ) )
		int skinIndex = GetDataTableInt( dataTable, row, GetDataTableColumnByName( dataTable, "skinIndex" ) )
		int datatableIndex = row

		if ( IsDisabledRef( titanRef ) || IsDisabledRef( ref ) )
		    continue

		CreateSkinData( datatableIndex, eItemTypes.TITAN_WARPAINT, false, ref, name, image, skinIndex )
		CreateGenericSubItemData( eItemTypes.TITAN_WARPAINT, titanRef, ref, cost, { skinIndex = skinIndex } )

		if ( !( titanRef in file.titanClassAndPersistenceValueToSkinRefTable ) )
			file.titanClassAndPersistenceValueToSkinRefTable[ titanRef ] <- {}

		file.titanClassAndPersistenceValueToSkinRefTable[ titanRef ][ skinIndex ] <- ref
	}

	{
		var dataTable = GetDataTable( $"datatable/calling_cards.rpak" )
		for ( int row = 0; row < GetDatatableRowCount( dataTable ); row++ )
		{
			string cardRef = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, CALLING_CARD_REF_COLUMN_NAME ) )
			string name = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, CALLING_CARD_NAME_COLUMN_NAME ) )
			asset image = GetDataTableAsset( dataTable, row, GetDataTableColumnByName( dataTable, CALLING_CARD_IMAGE_COLUMN_NAME ) )
			int cost = GetDataTableInt( dataTable, row, GetDataTableColumnByName( dataTable, "cost" ) )
			bool isHidden = false
			if ( cost < 0 )
			{
				isHidden = true
				cost = 0
			}

			string desc = "Undefined"
			string longdesc = "Undefined"

			int datatableIndex = row

			CreateGenericItem( datatableIndex, eItemTypes.CALLING_CARD, cardRef, name, desc, longdesc, image, cost, isHidden )
			GetItemData( cardRef ).imageAtlas = IMAGE_ATLAS_CALLINGCARD
		}
	}

	{
		var dataTable = GetDataTable( $"datatable/callsign_icons.rpak" )
		for ( int row = 0; row < GetDatatableRowCount( dataTable ); row++ )
		{
			string iconRef = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, CALLSIGN_ICON_REF_COLUMN_NAME ) )
			string name = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, CALLSIGN_ICON_NAME_COLUMN_NAME ) )
			asset image = GetDataTableAsset( dataTable, row, GetDataTableColumnByName( dataTable, CALLSIGN_ICON_IMAGE_COLUMN_NAME ) )
			int cost = GetDataTableInt( dataTable, row, GetDataTableColumnByName( dataTable, "cost" ) )
			bool isHidden = false
			if ( cost < 0 )
			{
				isHidden = true
				cost = 0
			}

			string desc = "Undefined"
			string longdesc = "Undefined"

			int datatableIndex = row

			if ( IsDisabledRef( iconRef ) )
				continue

			CreateGenericItem( datatableIndex, eItemTypes.CALLSIGN_ICON, iconRef, name, desc, longdesc, image, cost, isHidden )
			GetItemData( iconRef ).imageAtlas = IMAGE_ATLAS_CALLINGCARD
		}
	}

	/////////////////////
	// NON-LOADOUT WEAPONS
	/////////////////////

	dataTable = GetDataTable( $"datatable/non_loadout_weapons.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string weapon = GetDataTableString( dataTable, i, NON_LOADOUT_WEAPON_COLUMN )

		#if SERVER || CLIENT
			if ( !IsDisabledRef( weapon ) )
				PrecacheWeapon( weapon )
		#endif
		//CreateWeaponData( i, eItemTypes.NOT_LOADOUT, true, weapon, true )
	}

	/////////////////////
	// NON-LOADOUT MODS
	/////////////////////

	//dataTable = GetDataTable( $"datatable/non_loadout_mods.rpak" )
	//numRows = GetDatatableRowCount( dataTable )
	//for ( int i = 0; i < numRows; i++ )
	//{
	//	string mod = GetDataTableString( dataTable, i, NON_LOADOUT_MOD_COLUMN )
	//	string parentItem = GetDataTableString( dataTable, i, NON_LOADOUT_MOD_PARENT_COLUMN )
	//	string name = GetDataTableString( dataTable, i, NON_LOADOUT_MOD_NAME_COLUMN )
	//	string description = GetDataTableString( dataTable, i, NON_LOADOUT_MOD_DESCRIPTION_COLUMN )
	//	asset image = GetDataTableAsset( dataTable, i, NON_LOADOUT_MOD_IMAGE_COLUMN )
	//
	//	CreateModData( -1, eItemTypes.NOT_LOADOUT, parentItem, mod, name, description, description, image )
	//}

	/////////////////////
	//BURN METER REWARD DATA
	/////////////////////

	dataTable = GetDataTable( $"datatable/burn_meter_rewards.rpak" )
	for ( int row = 0; row < GetDatatableRowCount( dataTable ); row++ )
	{
		string itemRef		= GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, BURN_REF_COLUMN_NAME ) )
		string name			= GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, BURN_NAME_COLUMN_NAME ) )
		string description	= GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, BURN_NAME_COLUMN_NAME ) )
		int cost			= GetDataTableInt( dataTable, row, GetDataTableColumnByName( dataTable, "cost" ) )
		asset image			= GetDataTableAsset( dataTable, row, GetDataTableColumnByName( dataTable, "image" ) )

		if ( IsDisabledRef( itemRef ) )
			continue

		// Why does the server need this? Client script error happens otherwise.
		#if SERVER || CLIENT
			asset model		= GetDataTableAsset( dataTable, row, GetDataTableColumnByName( dataTable, "model" ) )
			PrecacheModel( model )
		#endif // SERVER || CLIENT

		bool hidden 		= !GetDataTableBool( dataTable, row, GetDataTableColumnByName( dataTable, "selectable" ) )
		CreateGenericItem( row, eItemTypes.BURN_METER_REWARD, itemRef, name, description, description, image, cost, hidden )
	}

	InitRandomUnlocks()

	SetupFrontierDefenseItems()

	InitUnlocks()

	foreach ( item in file.itemData )
	{
		if ( item.persistenceStruct != "" )
			file.itemsWithPersistenceStruct[ item.persistenceStruct ] <- item
	}
	
	// northstar hook: custom item registrations
	foreach ( void functionref() callback in file.itemRegistrationCallbacks )
		callback()

	// Sort some items based on unlock level
	file.globalItemRefsOfType[eItemTypes.PILOT_PRIMARY].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.PILOT_SECONDARY].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.PILOT_SPECIAL].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.PILOT_ORDNANCE].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.PILOT_PASSIVE1].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.PILOT_PASSIVE2].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.PILOT_SUIT].sort( SortByUnlockLevel )

	file.globalItemRefsOfType[eItemTypes.TITAN_PRIMARY].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.TITAN_ORDNANCE].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.TITAN_SPECIAL].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.TITAN_GENERAL_PASSIVE].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.TITAN_TITANFALL_PASSIVE].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.TITAN_RONIN_PASSIVE].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.TITAN_NORTHSTAR_PASSIVE].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.TITAN_ION_PASSIVE].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.TITAN_TONE_PASSIVE].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.TITAN_SCORCH_PASSIVE].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.TITAN_LEGION_PASSIVE].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.TITAN_VANGUARD_PASSIVE].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.TITAN_UPGRADE1_PASSIVE].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.TITAN_UPGRADE2_PASSIVE].sort( SortByUnlockLevel )
	file.globalItemRefsOfType[eItemTypes.TITAN_UPGRADE3_PASSIVE].sort( SortByUnlockLevel )

	#if !UI
		// Non-player weapons
		#if SERVER || CLIENT
			PrecacheWeapon( "mp_weapon_yh803" )
			PrecacheWeapon( "mp_weapon_yh803_bullet" )
			PrecacheWeapon( "mp_weapon_yh803_bullet_overcharged" )
			PrecacheWeapon( "mp_weapon_super_spectre" )
			PrecacheWeapon( "mp_weapon_dronebeam" )
			PrecacheWeapon( "mp_weapon_dronerocket" )
			PrecacheWeapon( "mp_weapon_droneplasma" )
			PrecacheWeapon( "mp_weapon_turretplasma" )
			PrecacheWeapon( "mp_weapon_turretplasma_mega" )
			PrecacheWeapon( "mp_weapon_turretlaser_mega_fort_war" )
			PrecacheWeapon( "mp_weapon_turretlaser_mega" )
			PrecacheWeapon( "mp_weapon_gunship_launcher" )
			PrecacheWeapon( "mp_weapon_gunship_turret" )
			PrecacheWeapon( "mp_weapon_gunship_missile" )

			// NPC weapons
			PrecacheWeapon( "mp_weapon_mega_turret" )
			PrecacheWeapon( "mp_weapon_spectre_spawner" )

			PrecacheWeapon( "mp_weapon_engineer_turret" )
			PrecacheWeapon( "mp_weapon_engineer_combat_drone" )
		#endif

		#if DEV && ( SERVER || CLIENT )
			PrecacheWeapon( "weapon_cubemap" )
		#endif

		#if CLIENT
			PrecacheHUDMaterial( MOD_ICON_NONE )
		#endif
	#endif
}

void function AddCallback_OnRegisterCustomItems( void functionref() callback )
{
	file.itemRegistrationCallbacks.append( callback )
}

void function InitUnlocks()
{
	InitUnlock( "race_human_male", "", eUnlockType.PLAYER_LEVEL, 1 )
	InitUnlock( "race_human_female", "", eUnlockType.PLAYER_LEVEL, 1 )

	InitUnlock( "speedball", "", eUnlockType.PLAYER_LEVEL, 1 )

	var dataTable = GetDataTable( $"datatable/unlocks_player_level.rpak" )
	int numRows = GetDatatableRowCount( dataTable )
	for ( int column = 1; column <= 13; column++ )
	{
		for ( int row = 0; row < numRows; row++ )
		{
			string unlockField = GetDataTableString( dataTable, row, column )
			array<string> unlockArray = SplitAndStripUnlockField( unlockField )

			foreach ( unlock in unlockArray )
			{
				if ( unlock != "" )
				{
					if ( unlock != "random" && !ItemDefined( unlock ) )
					{
                        #if DEV && DEVSCRIPTS
						CodeWarning( unlock + " does not appear to be a valid eItemType" )
						#else
						continue
						#endif
					}

					InitUnlock( unlock, "", eUnlockType.PLAYER_LEVEL, row + 1 )
				}
			}
		}
	}

	dataTable = GetDataTable( $"datatable/unlocks_titan_level.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	int column = 1
	while ( true )
	{
		string titanRef = GetDataTableString( dataTable, 0, column )
		if ( titanRef == "END" )
			break

		if ( IsDisabledRef( titanRef ) )
		{
		    column++
		    continue
        }

		for ( int row = 1; row < numRows; row++ )
		{
			string unlockField = GetDataTableString( dataTable, row, column )
			array<string> unlockArray = SplitAndStripUnlockField( unlockField )

			foreach ( unlock in unlockArray )
			{
				if ( unlock != "" )
					InitUnlock( unlock, titanRef, eUnlockType.TITAN_LEVEL, row )
			}
		}

		column++
	}

	dataTable = GetDataTable( $"datatable/unlocks_faction_level.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	int NUM_FACTIONS = GetAllItemRefsOfType( eItemTypes.FACTION ).len()
	for ( int column = 1; column <= NUM_FACTIONS; column++ )
	{
		string additionalRef = GetDataTableString( dataTable, 0, column )

		for ( int row = 1; row < numRows; row++ )
		{
			string unlockField = GetDataTableString( dataTable, row, column )
			array<string> unlockArray = SplitAndStripUnlockField( unlockField )

			foreach ( unlock in unlockArray )
			{
				if ( unlock != "" )
				{
					string parentRef
					var periodPos = unlock.find( "." )
					if ( periodPos != null )
					{
						parentRef = unlock.slice( 0, periodPos )
						unlock = unlock.slice( periodPos + 1 )
					}

					InitUnlock( unlock, parentRef, eUnlockType.FACTION_LEVEL, row, 0, additionalRef )
				}
			}
		}
	}

	var titanLoadoutsDataTable = GetDataTable( $"datatable/default_titan_loadouts.rpak" )
	var titanPropertiesDataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	var titansMpDataTable = GetDataTable( $"datatable/titans_mp.rpak" )
	numRows = GetDatatableRowCount( titansMpDataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string titanRef        = GetDataTableString( titansMpDataTable, i, GetDataTableColumnByName( titansMpDataTable, "titanRef" ) )

		if ( IsDisabledRef( titanRef ) )
		    continue

		int propertyRow = GetDataTableRowMatchingStringValue( titanPropertiesDataTable, GetDataTableColumnByName( titanPropertiesDataTable, "titanRef" ), titanRef )

		string primary = GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "primary" ) )
		InitUnlock( primary, titanRef, eUnlockType.TITAN_LEVEL, 1 )

		//string melee = GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "melee" ) )
		//InitUnlock( melee, titanRef, eUnlockType.TITAN_LEVEL, 1 )

		string ordnance = GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "ordnance" ) )
		InitUnlock( ordnance, titanRef, eUnlockType.TITAN_LEVEL, 1 )

		string special = GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "special" ) )
		InitUnlock( special, titanRef, eUnlockType.TITAN_LEVEL, 1 )

		string antirodeo = GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "antirodeo" ) )
		InitUnlock( antirodeo, titanRef, eUnlockType.TITAN_LEVEL, 1 )

		string coreAbility = GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "coreAbility" ) )
		InitUnlock( coreAbility, titanRef, eUnlockType.TITAN_LEVEL, 1 )

		InitUnlock( "mp_titanweapon_vortex_shield", titanRef, eUnlockType.TITAN_LEVEL, 1 )
		InitUnlock( "mp_titanweapon_rocketeer_rocketstream", titanRef, eUnlockType.TITAN_LEVEL, 1 )
		InitUnlock( "mp_titanweapon_shoulder_rockets", titanRef, eUnlockType.TITAN_LEVEL, 1 )
		InitUnlock( "mp_titanweapon_salvo_rockets", titanRef, eUnlockType.TITAN_LEVEL, 1 )
		InitUnlock( "mp_titanweapon_homing_rockets", titanRef, eUnlockType.TITAN_LEVEL, 1 )
		InitUnlock( "mp_titanweapon_xo16_shorty", titanRef, eUnlockType.TITAN_LEVEL, 1 )
		//
		//{
		//	int passive1Type = GetTitanProperty_Passive1Type( titanRef )
		//	array<ItemData> items = GetAllItemsOfType( passive1Type )
		//	foreach ( item in items )
		//	{
		//		InitUnlock( item.ref, titanRef, eUnlockType.TITAN_LEVEL, 1 )
		//	}
		//}
		//
		//{
		//	int passive2Type = GetTitanProperty_Passive2Type( titanRef )
		//	array<ItemData> items = GetAllItemsOfType( passive1Type )
		//	foreach ( item in items )
		//	{
		//		InitUnlock( item.ref, titanRef, eUnlockType.TITAN_LEVEL, 1 )
		//	}
		//}
		//{
		//	int passive3Type = GetTitanProperty_Passive3Type( titanRef )
		//	array<ItemData> items = GetAllItemsOfType( passive1Type )
		//	foreach ( item in items )
		//	{
		//		InitUnlock( item.ref, titanRef, eUnlockType.TITAN_LEVEL, 1 )
		//	}
		//}
		//int loadoutRow = GetDataTableRowMatchingStringValue( titanLoadoutsDataTable, GetDataTableColumnByName( titanLoadoutsDataTable, "titanRef" ), titanRef )
		//InitUnlock( GetDataTableString( titanLoadoutsDataTable, i, GetDataTableColumnByName( titanLoadoutsDataTable, "passive1" ) ), titanRef, eUnlockType.TITAN_LEVEL, 1 )
		//InitUnlock( GetDataTableString( titanLoadoutsDataTable, i, GetDataTableColumnByName( titanLoadoutsDataTable, "passive2" ) ), titanRef, eUnlockType.TITAN_LEVEL, 1 )
		//InitUnlock( GetDataTableString( titanLoadoutsDataTable, i, GetDataTableColumnByName( titanLoadoutsDataTable, "passive3" ) ), titanRef, eUnlockType.TITAN_LEVEL, 1 )
	}

	dataTable = GetDataTable( $"datatable/default_pilot_loadouts.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < NUM_PERSISTENT_PILOT_LOADOUTS; i++ )
	{
		PilotLoadoutDef loadout
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

		UpdateDerivedPilotLoadoutData( loadout )

		if ( !(loadout.suit in file.unlocks) )
			InitUnlock( loadout.suit, "", eUnlockType.PLAYER_LEVEL, 1 )

		if ( !(loadout.primary in file.unlocks) )
		{
			InitUnlock( loadout.primary, "", eUnlockType.PLAYER_LEVEL, 1 )
			if ( loadout.primaryAttachment != "" )
				InitUnlock( loadout.primaryAttachment, loadout.primary, eUnlockType.WEAPON_LEVEL, 1 )
			if ( loadout.primaryMod1 != "" )
				InitUnlock( loadout.primaryMod1, loadout.primary, eUnlockType.WEAPON_LEVEL, 1 )
			if ( loadout.primaryMod2 != "" )
				InitUnlock( loadout.primaryMod2, loadout.primary, eUnlockType.WEAPON_LEVEL, 1 )
			if ( loadout.primaryMod3 != "" )
				InitUnlock( loadout.primaryMod3, loadout.primary, eUnlockType.WEAPON_LEVEL, 1 )
		}

		if ( !(loadout.secondary in file.unlocks) )
		{
			InitUnlock( loadout.secondary, "", eUnlockType.PLAYER_LEVEL, 1 )

			if ( loadout.secondaryMod1 != "" )
				InitUnlock( loadout.secondaryMod1, loadout.secondary, eUnlockType.WEAPON_LEVEL, 1 )
			if ( loadout.secondaryMod2 != "" )
				InitUnlock( loadout.secondaryMod2, loadout.secondary, eUnlockType.WEAPON_LEVEL, 1 )
			if ( loadout.secondaryMod3 != "" )
				InitUnlock( loadout.secondaryMod3, loadout.secondary, eUnlockType.WEAPON_LEVEL, 1 )
		}

		if ( !(loadout.special in file.unlocks) )
			InitUnlock( loadout.special, "", eUnlockType.PLAYER_LEVEL, 1 )

		if ( !(loadout.ordnance in file.unlocks) )
			InitUnlock( loadout.ordnance, "", eUnlockType.PLAYER_LEVEL, 1 )

		if ( !(loadout.passive1 in file.unlocks) )
			InitUnlock( loadout.passive1, "", eUnlockType.PLAYER_LEVEL, 1 )

		if ( !(loadout.passive2 in file.unlocks) )
			InitUnlock( loadout.passive2, "", eUnlockType.PLAYER_LEVEL, 1 )
	}

	dataTable = GetDataTable( $"datatable/pilot_weapons.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string itemRef        = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "itemRef" ) )

		string defaultAttachment = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "defaultAttachment" ) )
		string defaultMod1        = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "defaultMod1" ) )
		string defaultMod2        = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "defaultMod2" ) )
		string defaultMod3        = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "defaultMod3" ) )

		if ( defaultAttachment != "" )
			InitUnlock( defaultAttachment, itemRef, eUnlockType.WEAPON_LEVEL, 1 )
		if ( defaultMod1 != "" )
			InitUnlock( defaultMod1, itemRef, eUnlockType.WEAPON_LEVEL, 1 )
		if ( defaultMod2 != "" )
			InitUnlock( defaultMod2, itemRef, eUnlockType.WEAPON_LEVEL, 1 )
		if ( defaultMod3 != "" )
			InitUnlock( defaultMod3, itemRef, eUnlockType.WEAPON_LEVEL, 1 )
	}

	dataTable = GetDataTable( $"datatable/unlocks_weapon_level_pilot.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	column = 1
	while ( true )
	{
		string weaponRef = GetDataTableString( dataTable, 0, column )
		if ( weaponRef == "END" )
			break

		for ( int row = 1; row < numRows; row++ )
		{
			string unlockField = GetDataTableString( dataTable, row, column )
			array<string> unlockArray = SplitAndStripUnlockField( unlockField )

			foreach ( unlock in unlockArray )
			{
				if ( unlock != "" )
					InitUnlock( unlock, weaponRef, eUnlockType.WEAPON_LEVEL, row )
			}
		}

		column++
	}

	dataTable = GetDataTable( $"datatable/pilot_weapon_mods.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	var weaponTable = GetDataTable( $"datatable/pilot_weapons.rpak" )
	for ( int i = 0; i < numRows; i++ )
	{
		string mod				= GetDataTableString( dataTable, i, PILOT_WEAPON_MOD_COLUMN )
		string weapon        	= GetDataTableString( dataTable, i, PILOT_WEAPON_MOD_WEAPON_COLUMN )
		Assert( weapon in file.unlocks, "Weapon " + weapon + " does not exist in the unlock datatables." )
		Assert( mod in file.unlocks[ weapon ].child, "Mod " + mod + " for weapon " + weapon + " does not exist in the unlock datatables." )
	}

	int titanClassEnumCount = PersistenceGetEnumCount( "titanClasses" )
	array<string> pilotWeaponRefs = GetAllItemRefsOfType( eItemTypes.PILOT_PRIMARY )
	pilotWeaponRefs.extend( GetAllItemRefsOfType( eItemTypes.PILOT_SECONDARY ) )


	//////////////////////////
	// DEV
	//////////////////////////
	InitUnlock( "gc_icon_respawn_dev", "", eUnlockType.PERSISTENT_ITEM, 0 )

	//////////////////////////
	// SP
	//////////////////////////
	InitUnlock( "callsign_103_col", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_103_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_103_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )

	//////////////////////////
	// Tech Test
	//////////////////////////
	InitUnlock( "callsign_105_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )

	//////////////////////////
	// Email Signup
	//////////////////////////
	InitUnlock( "callsign_104_col", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_104_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_104_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )

	InitUnlock( "callsign_goodboy", "", eUnlockType.PLAYER_LEVEL, 1 )


	InitUnlock( "callsign_contest_01", "", eUnlockType.PLAYER_LEVEL, 1 )
	InitUnlock( "callsign_contest_02", "", eUnlockType.PLAYER_LEVEL, 1 )
	InitUnlock( "callsign_contest_03", "", eUnlockType.PLAYER_LEVEL, 1 )
	InitUnlock( "callsign_contest_04", "", eUnlockType.PLAYER_LEVEL, 1 )
	InitUnlock( "callsign_contest_05", "", eUnlockType.PLAYER_LEVEL, 1 )
	InitUnlock( "callsign_contest_06", "", eUnlockType.PLAYER_LEVEL, 1 )
	InitUnlock( "callsign_contest_07", "", eUnlockType.PLAYER_LEVEL, 1 )
	InitUnlock( "callsign_contest_08", "", eUnlockType.PLAYER_LEVEL, 1 )
	InitUnlock( "callsign_contest_09", "", eUnlockType.PLAYER_LEVEL, 1 )
	InitUnlock( "callsign_contest_10", "", eUnlockType.PLAYER_LEVEL, 1 )

	//////////////////////////
	// Holidays
	//////////////////////////
	InitUnlock( "callsign_126_col", "", eUnlockType.PLAYER_LEVEL, 1 )
	InitUnlock( "callsign_127_col", "", eUnlockType.PLAYER_LEVEL, 1 )
	InitUnlock( "callsign_130_col", "", eUnlockType.PLAYER_LEVEL, 1 )
	InitUnlock( "callsign_131_col", "", eUnlockType.PLAYER_LEVEL, 1 )
	//InitUnlock( "callsign_126_col_prism", "", eUnlockType.PERSISTENT_ITEM, 0 ) //Unlocked in-game or via advocate gifts
	//InitUnlock( "callsign_127_col_prism", "", eUnlockType.PERSISTENT_ITEM, 0 ) //Unlocked in-game or via advocate gifts

	//////////////////////////
	// Reserved for future use
	//////////////////////////
	InitUnlock( "callsign_65_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_14_col", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_14_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )

	InitUnlock( "callsign_129_col", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_132_col", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_133_col", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_134_col", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_135_col", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_136_col", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_137_col", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_125_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_126_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_127_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_129_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_130_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_131_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_132_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_133_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_134_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_135_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_136_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_137_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_125_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_126_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_127_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_129_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_130_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_131_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_132_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_133_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_134_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_135_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_136_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_137_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_125_col_prism", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_128_col_prism", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_129_col_prism", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_130_col_prism", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_131_col_prism", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_132_col_prism", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_133_col_prism", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_134_col_prism", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_135_col_prism", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_136_col_prism", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_137_col_prism", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_138_col_prism", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_140_col", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_140_col_fire", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_140_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )

//	InitUnlock( "callsign_14_col_gold", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_38_col_gold", "", eUnlockType.PLAYER_LEVEL, 2500 )
	InitUnlock( "callsign_33_col_gold", "", eUnlockType.PLAYER_LEVEL, 5000 )

	InitUnlock( "gc_icon_blank", "", eUnlockType.PLAYER_LEVEL, 451 )

	InitUnlock( "callsign_regen_10_col", "", eUnlockType.PLAYER_LEVEL, 451 )
	InitUnlock( "callsign_regen_10_col_prism", "", eUnlockType.PLAYER_LEVEL, 950 )
	InitUnlock( "callsign_regen_20_col", "", eUnlockType.PLAYER_LEVEL, 951 )
	InitUnlock( "callsign_regen_20_col_prism", "", eUnlockType.PLAYER_LEVEL, 1450 )
	InitUnlock( "callsign_regen_30_col", "", eUnlockType.PLAYER_LEVEL, 1451 )
	InitUnlock( "callsign_regen_30_col_prism", "", eUnlockType.PLAYER_LEVEL, 1950 )
	InitUnlock( "callsign_regen_40_col", "", eUnlockType.PLAYER_LEVEL, 1951 )
	InitUnlock( "callsign_regen_40_col_prism", "", eUnlockType.PLAYER_LEVEL, 2450 )
	InitUnlock( "callsign_regen_50_col", "", eUnlockType.PLAYER_LEVEL, 2451 )
	InitUnlock( "callsign_regen_50_col_prism", "", eUnlockType.PLAYER_LEVEL, 2950 )
	InitUnlock( "callsign_regen_60_col", "", eUnlockType.PLAYER_LEVEL, 2951 )
	InitUnlock( "callsign_regen_60_col_prism", "", eUnlockType.PLAYER_LEVEL, 3450 )
	InitUnlock( "callsign_regen_70_col", "", eUnlockType.PLAYER_LEVEL, 3451 )
	InitUnlock( "callsign_regen_70_col_prism", "", eUnlockType.PLAYER_LEVEL, 3950 )
	InitUnlock( "callsign_regen_80_col", "", eUnlockType.PLAYER_LEVEL, 3951 )
	InitUnlock( "callsign_regen_80_col_prism", "", eUnlockType.PLAYER_LEVEL, 4450 )
	InitUnlock( "callsign_regen_90_col", "", eUnlockType.PLAYER_LEVEL, 4451 )
	InitUnlock( "callsign_regen_90_col_prism", "", eUnlockType.PLAYER_LEVEL, 4950 )
	InitUnlock( "callsign_regen_100_col", "", eUnlockType.PLAYER_LEVEL, 4951 )
	InitUnlock( "callsign_regen_100_col_prism", "", eUnlockType.PLAYER_LEVEL, 5000 )


	InitUnlock( "gc_icon_deuce", "", eUnlockType.PERSISTENT_ITEM, 0 )

	for ( int i = 0; i < titanClassEnumCount; i++ )
	{
		string titanClass = PersistenceGetEnumItemNameForIndex( "titanClasses", i )

		if ( IsDisabledRef( titanClass ) )
		    continue

		if ( titanClass != "" )
		{
			InitUnlock( "titan_camo_skin09", titanClass, eUnlockType.PERSISTENT_ITEM, 0 )
			InitUnlock( "camo_skin09", titanClass, eUnlockType.PERSISTENT_ITEM, 0 )
		}
	}

	InitUnlock( "pilot_camo_skin09", "", eUnlockType.PERSISTENT_ITEM, 0 )

	foreach ( weaponClassName in pilotWeaponRefs )
	{
		InitUnlock( "camo_skin09", weaponClassName, eUnlockType.PERSISTENT_ITEM, 0 )
	}
	//////////////////////////
	// CHALLENGES
	//////////////////////////
//	InitUnlockForStatInt( "titan_camo_skin67", "ion", 100, "misc_stats", "titanFalls" )

////////////////// CALLSIGN CHALLENGES //////////////////////////////////////////////////////////////////

	//Live Fire Wins
	InitUnlockForStatInt( "callsign_142_col", "", 5, "game_stats", "mode_won", "speedball" )
	InitUnlockForStatInt( "callsign_142_col_fire", "", 10, "game_stats", "mode_won", "speedball" )
	InitUnlockForStatInt( "callsign_142_col_gold", "", 20, "game_stats", "mode_won", "speedball" )
	InitUnlockForStatInt( "callsign_138_col", "", 35, "game_stats", "mode_won", "speedball" )
	InitUnlockForStatInt( "callsign_138_col_fire", "", 50, "game_stats", "mode_won", "speedball" )
	InitUnlockForStatInt( "callsign_138_col_gold", "", 100, "game_stats", "mode_won", "speedball" )
	//Live Fire Played
	InitUnlockForStatInt( "callsign_141_col", "", 2, "game_stats", "mode_played", "speedball" )
	InitUnlockForStatInt( "callsign_141_col_fire", "", 5, "game_stats", "mode_played", "speedball" )
	InitUnlockForStatInt( "callsign_141_col_gold", "", 15, "game_stats", "mode_played", "speedball" )
	//Live Fire Kills
	InitUnlockForStatInt( "gc_icon_threebullets", "", 3, "game_stats", "pvp_kills_by_mode", "speedball" )
	InitUnlockForStatInt( "gc_icon_prowlerhead", "", 10, "game_stats", "pvp_kills_by_mode", "speedball" )
	InitUnlockForStatInt( "gc_icon_shuriken", "", 25, "game_stats", "pvp_kills_by_mode", "speedball" )
	InitUnlockForStatInt( "gc_icon_squid", "", 50, "game_stats", "pvp_kills_by_mode", "speedball" )
	InitUnlockForStatInt( "gc_icon_tick", "", 100, "game_stats", "pvp_kills_by_mode", "speedball" )
	InitUnlockForStatInt( "gc_icon_scythe", "", 250, "game_stats", "pvp_kills_by_mode", "speedball" )

	InitUnlockForStatInt( "gc_icon_fd_normal", "", 10, "fd_stats", "normalWins" )
	InitUnlockForStatInt( "gc_icon_fd_hard", "", 10, "fd_stats", "hardWins" )
	InitUnlockForStatInt( "gc_icon_fd_master", "", 10, "fd_stats", "masterWins" )
	InitUnlockForStatInt( "gc_icon_fd_insane", "", 10, "fd_stats", "insaneWins" )

	InitUnlockForStatInt( "fd_hard", "", 5, "fd_stats", "highestTitanFDLevel" )
	InitUnlockForStatInt( "fd_master", "", 11, "fd_stats", "highestTitanFDLevel" )
	InitUnlockForStatInt( "fd_insane", "", 14, "fd_stats", "highestTitanFDLevel" )

	//Distance
	InitUnlockForStatFloat( "callsign_97_col", "", 40.0, "distance_stats", "total" )
	InitUnlockForStatFloat( "callsign_97_col_fire", "", 400.0, "distance_stats", "total" )
	InitUnlockForStatFloat( "callsign_97_col_gold", "", 4000.0, "distance_stats", "total" )
	//Wallrun Distance
	InitUnlockForStatFloat( "callsign_99_col", "", 5.0, "distance_stats", "asPilot" )
	InitUnlockForStatFloat( "callsign_99_col_fire", "", 10.0, "distance_stats", "asPilot" )
	InitUnlockForStatFloat( "callsign_99_col_gold", "", 25.0, "distance_stats", "asPilot" )
	//Headshots
	InitUnlockForStatInt( "callsign_04_col", "", 50, "kills_stats", "pilot_headshots_total" )
	InitUnlockForStatInt( "callsign_04_col_fire", "", 100, "kills_stats", "pilot_headshots_total" )
	InitUnlockForStatInt( "callsign_04_col_gold", "", 250, "kills_stats", "pilot_headshots_total" )
	//MVP
	InitUnlockForStatInt( "gc_icon_pro", "", 10, "game_stats", "mvp_total" )
	//Evac
	InitUnlockForStatInt( "gc_icon_balloon", "", 5, "misc_stats", "evacsSurvived" )
	//First Strike
	InitUnlockForStatInt( "gc_icon_vip", "", 5, "kills_stats", "firstStrikes" )
	//Eject
	InitUnlockForStatInt( "gc_icon_bat", "", 3, "kills_stats", "ejectingPilots" )
	//Titanfall Kills
	InitUnlockForStatInt( "gc_icon_apostrophe", "", 3, "kills_stats", "titanFallKill" )
	//Rodeo Kills
	InitUnlockForStatInt( "gc_icon_cowboy_hat", "", 3, "kills_stats", "rodeo_total" )
	//First to Fall
	InitUnlockForStatInt( "gc_icon_striketwice", "", 3, "misc_stats", "titanFallsFirst" )
	//Titanfalls
	InitUnlockForStatInt( "callsign_23_col", "", 15, "misc_stats", "titanFalls" )
	InitUnlockForStatInt( "callsign_23_col_fire", "", 50, "misc_stats", "titanFalls" )
	InitUnlockForStatInt( "callsign_23_col_gold", "", 150, "misc_stats", "titanFalls" )
// ////////////////// PILOT CHALLENGES	//////////////////

	//Pilot Kills
	InitUnlockForStatInt( "pilot_camo_skin67", "", 100, "kills_stats", "pilots" )
	InitUnlockForStatInt( "pilot_camo_skin65", "", 500, "kills_stats", "pilots" )
	InitUnlockForStatInt( "pilot_camo_skin66", "", 1000, "kills_stats", "pilots" )
	InitUnlockForStatInt( "pilot_camo_skin64", "", 2500, "kills_stats", "pilots" )
	InitUnlockForStatInt( "pilot_camo_skin63", "", 5000, "kills_stats", "pilots" )
	//Kill Spree 3
	InitUnlockForStatInt( "pilot_camo_skin13", "", 10, "misc_stats", "killingSprees" )
	InitUnlockForStatInt( "pilot_camo_skin07", "", 25, "misc_stats", "killingSprees" )
	InitUnlockForStatInt( "pilot_camo_skin87", "", 100, "misc_stats", "killingSprees" )
	//Pilot Executions
	InitUnlockForStatInt( "pilot_camo_skin60", "", 3, "kills_stats", "pilotExecutePilot" )
	InitUnlockForStatInt( "pilot_camo_skin61", "", 5, "kills_stats", "pilotExecutePilot" )
	InitUnlockForStatInt( "pilot_camo_skin62", "", 10, "kills_stats", "pilotExecutePilot" )
	InitUnlockForStatInt( "pilot_camo_skin59", "", 25, "kills_stats", "pilotExecutePilot" )
	InitUnlockForStatInt( "execution_telefrag", "", 50, "kills_stats", "pilotExecutePilot" )
	InitUnlockForStatInt( "execution_stim", "", 10, "kills_stats", "pilotExecutePilotUsing_execution_telefrag" )
	InitUnlockForStatInt( "execution_grapple", "", 75, "kills_stats", "pilotExecutePilot" )
	InitUnlockForStatInt( "execution_pulseblade", "", 10, "weapon_kill_stats", "pilots" , "mp_weapon_grenade_sonar" )
	InitUnlockForStatInt( "execution_random", "", 0, "kills_stats", "pilotExecutePilot" )
	InitUnlockForStatInt( "execution_cloak", "", 10, "kills_stats", "pilotExecutePilotWhileCloaked" )
	InitUnlockForStatInt( "execution_holopilot", "", 20, "kills_stats", "pilotKillsWithHoloPilotActive" )
	InitUnlockForStatInt( "execution_ampedwall", "", 5, "kills_stats", "pilotKillsWithAmpedWallActive" )

	//Distance
	InitUnlockForStatFloat( "pilot_camo_skin56", "", 100.0, "distance_stats", "asPilot" )
	InitUnlockForStatFloat( "pilot_camo_skin58", "", 250.0, "distance_stats", "asPilot" )
	InitUnlockForStatFloat( "pilot_camo_skin55", "", 500.0, "distance_stats", "asPilot" )
	InitUnlockForStatFloat( "pilot_camo_skin57", "", 1000.0, "distance_stats", "asPilot" )
	InitUnlockForStatFloat( "pilot_camo_skin91", "", 2500.0, "distance_stats", "asPilot" )
	//Wallrun Distance
	InitUnlockForStatFloat( "pilot_camo_skin93", "", 2.0, "distance_stats", "wallrunning" )
	InitUnlockForStatFloat( "pilot_camo_skin94", "", 20.0, "distance_stats", "wallrunning" )
	InitUnlockForStatFloat( "pilot_camo_skin85", "", 200.0, "distance_stats", "wallrunning" )
	//Pilot Headshot Kills
//	InitUnlockForStatInt( "pilot_camo_skin56", "", 25, "kills_stats", "pilot_headshots_total" )
//	InitUnlockForStatInt( "pilot_camo_skin57", "", 100, "kills_stats", "pilot_headshots_total" )
//	InitUnlockForStatInt( "pilot_camo_skin85", "", 250, "kills_stats", "pilot_headshots_total" )
//	//Assists
//	InitUnlockForStatInt( "pilot_camo_skin93", "", 5, "misc_stats", "killingSprees" )
//	InitUnlockForStatInt( "pilot_camo_skin94", "", 15, "misc_stats", "killingSprees" )
//	InitUnlockForStatInt( "pilot_camo_skin85", "", 30, "misc_stats", "killingSprees" )


// ////////////////// PILOT WEAPON CHALLENGES	//////////////////

	//Pilot Weapon Kills
	InitUnlockForStatInt( "camo_skin67", "mp_weapon_rspn101", 100, "weapon_kill_stats", "pilots" , "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_rspn101", 250, "weapon_kill_stats", "pilots" , "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_rspn101", 500, "weapon_kill_stats", "pilots" , "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_rspn101", 1000, "weapon_kill_stats", "pilots" , "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_rspn101", 2500, "weapon_kill_stats", "pilots" , "mp_weapon_rspn101" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_rspn101_og", 100, "weapon_kill_stats", "pilots" , "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_rspn101_og", 250, "weapon_kill_stats", "pilots" , "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_rspn101_og", 500, "weapon_kill_stats", "pilots" , "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_rspn101_og", 1000, "weapon_kill_stats", "pilots" , "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_rspn101_og", 2500, "weapon_kill_stats", "pilots" , "mp_weapon_rspn101_og" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_hemlok", 100, "weapon_kill_stats", "pilots" , "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_hemlok", 250,  "weapon_kill_stats", "pilots" , "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_hemlok", 500, "weapon_kill_stats", "pilots" , "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_hemlok", 1000, "weapon_kill_stats", "pilots" , "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_hemlok", 2500, "weapon_kill_stats", "pilots" , "mp_weapon_hemlok" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_g2", 100, "weapon_kill_stats", "pilots" , "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_g2", 250,  "weapon_kill_stats", "pilots" , "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_g2", 500, "weapon_kill_stats", "pilots" , "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_g2", 1000, "weapon_kill_stats", "pilots" , "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_g2", 2500, "weapon_kill_stats", "pilots" , "mp_weapon_g2" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_vinson", 100, "weapon_kill_stats", "pilots" , "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_vinson", 250,  "weapon_kill_stats", "pilots" , "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_vinson", 500, "weapon_kill_stats", "pilots" , "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_vinson", 1000, "weapon_kill_stats", "pilots" , "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_vinson", 2500, "weapon_kill_stats", "pilots" , "mp_weapon_vinson" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_car", 100, "weapon_kill_stats", "pilots" , "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_car", 250,  "weapon_kill_stats", "pilots" , "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_car", 500, "weapon_kill_stats", "pilots" , "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_car", 1000, "weapon_kill_stats", "pilots" , "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_car", 2500, "weapon_kill_stats", "pilots" , "mp_weapon_car" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_r97", 100, "weapon_kill_stats", "pilots" , "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_r97", 250,  "weapon_kill_stats", "pilots" , "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_r97", 500, "weapon_kill_stats", "pilots" , "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_r97", 1000, "weapon_kill_stats", "pilots" , "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_r97", 2500, "weapon_kill_stats", "pilots" , "mp_weapon_r97" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_alternator_smg", 100, "weapon_kill_stats", "pilots" , "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_alternator_smg", 250,  "weapon_kill_stats", "pilots" , "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_alternator_smg", 500, "weapon_kill_stats", "pilots" , "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_alternator_smg", 1000, "weapon_kill_stats", "pilots" , "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_alternator_smg", 2500, "weapon_kill_stats", "pilots" , "mp_weapon_alternator_smg" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_hemlok_smg", 100, "weapon_kill_stats", "pilots" , "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_hemlok_smg", 250,  "weapon_kill_stats", "pilots" , "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_hemlok_smg", 500, "weapon_kill_stats", "pilots" , "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_hemlok_smg", 1000, "weapon_kill_stats", "pilots" , "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_hemlok_smg", 2500, "weapon_kill_stats", "pilots" , "mp_weapon_hemlok_smg" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_lmg", 100, "weapon_kill_stats", "pilots", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_lmg", 250,  "weapon_kill_stats", "pilots", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_lmg", 500, "weapon_kill_stats", "pilots", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_lmg", 1000, "weapon_kill_stats", "pilots", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_lmg", 2500, "weapon_kill_stats", "pilots", "mp_weapon_lmg" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_lstar", 100, "weapon_kill_stats", "pilots", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_lstar", 250,  "weapon_kill_stats", "pilots", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_lstar", 500, "weapon_kill_stats", "pilots", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_lstar", 1000, "weapon_kill_stats", "pilots", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_lstar", 2500, "weapon_kill_stats", "pilots", "mp_weapon_lstar" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_esaw", 100, "weapon_kill_stats", "pilots", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_esaw", 250,  "weapon_kill_stats", "pilots", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_esaw", 500, "weapon_kill_stats", "pilots", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_esaw", 1000, "weapon_kill_stats", "pilots", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_esaw", 2500, "weapon_kill_stats", "pilots", "mp_weapon_esaw" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_shotgun", 100, "weapon_kill_stats", "pilots", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_shotgun", 250,  "weapon_kill_stats", "pilots", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_shotgun", 500, "weapon_kill_stats", "pilots", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_shotgun", 1000, "weapon_kill_stats", "pilots", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_shotgun", 2500, "weapon_kill_stats", "pilots", "mp_weapon_shotgun" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_mastiff", 100, "weapon_kill_stats", "pilots", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_mastiff", 250,  "weapon_kill_stats", "pilots", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_mastiff", 500, "weapon_kill_stats", "pilots", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_mastiff", 1000, "weapon_kill_stats", "pilots", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_mastiff", 2500, "weapon_kill_stats", "pilots", "mp_weapon_mastiff" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_doubletake", 100, "weapon_kill_stats", "pilots", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_doubletake", 250,  "weapon_kill_stats", "pilots", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_doubletake", 500, "weapon_kill_stats", "pilots", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_doubletake", 1000, "weapon_kill_stats", "pilots", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_doubletake", 2500, "weapon_kill_stats", "pilots", "mp_weapon_doubletake" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_sniper", 100, "weapon_kill_stats", "pilots", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_sniper", 250,  "weapon_kill_stats", "pilots", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_sniper", 500, "weapon_kill_stats", "pilots", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_sniper", 1000, "weapon_kill_stats", "pilots", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_sniper", 2500, "weapon_kill_stats", "pilots", "mp_weapon_sniper" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_dmr", 100, "weapon_kill_stats", "pilots", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_dmr", 250,  "weapon_kill_stats", "pilots", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_dmr", 500, "weapon_kill_stats", "pilots", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_dmr", 1000, "weapon_kill_stats", "pilots", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_dmr", 2500, "weapon_kill_stats", "pilots", "mp_weapon_dmr" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_epg", 100, "weapon_kill_stats", "pilots", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_epg", 250,  "weapon_kill_stats", "pilots", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_epg", 500, "weapon_kill_stats", "pilots", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_epg", 1000, "weapon_kill_stats", "pilots", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_epg", 2500, "weapon_kill_stats", "pilots", "mp_weapon_epg" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_softball", 100, "weapon_kill_stats", "pilots", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_softball", 250,  "weapon_kill_stats", "pilots", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_softball", 500, "weapon_kill_stats", "pilots", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_softball", 1000, "weapon_kill_stats", "pilots", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_softball", 2500, "weapon_kill_stats", "pilots", "mp_weapon_softball" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_smr", 100, "weapon_kill_stats", "pilots", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_smr", 250,  "weapon_kill_stats", "pilots", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_smr", 500, "weapon_kill_stats", "pilots", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_smr", 1000, "weapon_kill_stats", "pilots", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_smr", 2500, "weapon_kill_stats", "pilots", "mp_weapon_smr" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_pulse_lmg", 100, "weapon_kill_stats", "pilots", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_pulse_lmg", 250,  "weapon_kill_stats", "pilots", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_pulse_lmg", 500, "weapon_kill_stats", "pilots", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_pulse_lmg", 1000, "weapon_kill_stats", "pilots", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_pulse_lmg", 2500, "weapon_kill_stats", "pilots", "mp_weapon_pulse_lmg" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_autopistol", 100, "weapon_kill_stats", "pilots", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_autopistol", 250,  "weapon_kill_stats", "pilots", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_autopistol", 500, "weapon_kill_stats", "pilots", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_autopistol", 1000, "weapon_kill_stats", "pilots", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_autopistol", 2500, "weapon_kill_stats", "pilots", "mp_weapon_autopistol" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_semipistol", 100, "weapon_kill_stats", "pilots", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_semipistol", 250,  "weapon_kill_stats", "pilots", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_semipistol", 500, "weapon_kill_stats", "pilots", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_semipistol", 1000, "weapon_kill_stats", "pilots", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_semipistol", 2500, "weapon_kill_stats", "pilots", "mp_weapon_semipistol" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_shotgun_pistol", 100, "weapon_kill_stats", "pilots", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_shotgun_pistol", 250,  "weapon_kill_stats", "pilots", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_shotgun_pistol", 500, "weapon_kill_stats", "pilots", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_shotgun_pistol", 1000, "weapon_kill_stats", "pilots", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_shotgun_pistol", 2500, "weapon_kill_stats", "pilots", "mp_weapon_shotgun_pistol" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_wingman", 100, "weapon_kill_stats", "pilots", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_wingman", 250,  "weapon_kill_stats", "pilots", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_wingman", 500, "weapon_kill_stats", "pilots", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_wingman", 1000, "weapon_kill_stats", "pilots", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_wingman", 2500, "weapon_kill_stats", "pilots", "mp_weapon_wingman" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_wingman_n", 100, "weapon_kill_stats", "pilots", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_wingman_n", 250,  "weapon_kill_stats", "pilots", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_wingman_n", 500, "weapon_kill_stats", "pilots", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_wingman_n", 1000, "weapon_kill_stats", "pilots", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_wingman_n", 2500, "weapon_kill_stats", "pilots", "mp_weapon_wingman_n" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_defender", 2, "weapon_kill_stats", "titansTotal", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_defender", 20, "weapon_kill_stats", "titansTotal", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_defender", 100, "weapon_kill_stats", "titansTotal", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_defender", 200, "weapon_kill_stats", "titansTotal", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_defender", 500, "weapon_kill_stats", "titansTotal", "mp_weapon_defender" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_mgl", 2, "weapon_kill_stats", "titansTotal", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_mgl", 20, "weapon_kill_stats", "titansTotal", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_mgl", 100,"weapon_kill_stats", "titansTotal", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_mgl", 200, "weapon_kill_stats", "titansTotal", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_mgl", 500, "weapon_kill_stats", "titansTotal", "mp_weapon_mgl" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_arc_launcher", 2, "weapon_kill_stats", "titansTotal", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_arc_launcher", 20, "weapon_kill_stats", "titansTotal", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_arc_launcher", 100,"weapon_kill_stats", "titansTotal", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_arc_launcher", 200, "weapon_kill_stats", "titansTotal", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_arc_launcher", 500, "weapon_kill_stats", "titansTotal", "mp_weapon_arc_launcher" )

	InitUnlockForStatInt( "camo_skin67", "mp_weapon_rocket_launcher", 2, "weapon_kill_stats", "titansTotal", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin65", "mp_weapon_rocket_launcher", 20, "weapon_kill_stats", "titansTotal", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin66", "mp_weapon_rocket_launcher", 100,"weapon_kill_stats", "titansTotal", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin64", "mp_weapon_rocket_launcher", 200, "weapon_kill_stats", "titansTotal", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin63", "mp_weapon_rocket_launcher", 500, "weapon_kill_stats", "titansTotal", "mp_weapon_rocket_launcher" )
	//Pilot Weapon Assists
	InitUnlockForStatInt( "camo_skin56", "mp_weapon_rspn101", 10, "weapon_kill_stats", "assistsTotal" , "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_rspn101", 100, "weapon_kill_stats", "assistsTotal" , "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_rspn101", 500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_rspn101", 1000, "weapon_kill_stats", "assistsTotal" , "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_rspn101", 2500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_rspn101" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_rspn101_og", 10, "weapon_kill_stats", "assistsTotal" , "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_rspn101_og", 100, "weapon_kill_stats", "assistsTotal" , "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_rspn101_og", 500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_rspn101_og", 1000, "weapon_kill_stats", "assistsTotal" , "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_rspn101_og", 2500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_rspn101_og" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_hemlok", 10, "weapon_kill_stats", "assistsTotal" , "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_hemlok", 100, "weapon_kill_stats", "assistsTotal" , "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_hemlok", 500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_hemlok", 1000, "weapon_kill_stats", "assistsTotal" , "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_hemlok", 2500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_hemlok" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_g2", 10, "weapon_kill_stats", "assistsTotal" , "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_g2", 100, "weapon_kill_stats", "assistsTotal" , "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_g2", 500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_g2", 1000, "weapon_kill_stats", "assistsTotal" , "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_g2", 2500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_g2" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_vinson", 10, "weapon_kill_stats", "assistsTotal" , "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_vinson", 100, "weapon_kill_stats", "assistsTotal" , "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_vinson", 500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_vinson", 1000, "weapon_kill_stats", "assistsTotal" , "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_vinson", 2500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_vinson" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_car", 10, "weapon_kill_stats", "assistsTotal" , "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_car", 100, "weapon_kill_stats", "assistsTotal" , "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_car", 500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_car", 1000, "weapon_kill_stats", "assistsTotal" , "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_car", 2500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_car" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_r97", 10, "weapon_kill_stats", "assistsTotal" , "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_r97", 100, "weapon_kill_stats", "assistsTotal" , "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_r97", 500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_r97", 1000, "weapon_kill_stats", "assistsTotal" , "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_r97", 2500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_r97" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_alternator_smg", 10, "weapon_kill_stats", "assistsTotal" , "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_alternator_smg", 100, "weapon_kill_stats", "assistsTotal" , "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_alternator_smg", 500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_alternator_smg", 1000, "weapon_kill_stats", "assistsTotal" , "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_alternator_smg", 2500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_alternator_smg" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_hemlok_smg", 10, "weapon_kill_stats", "assistsTotal" , "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_hemlok_smg", 100, "weapon_kill_stats", "assistsTotal" , "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_hemlok_smg", 500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_hemlok_smg", 1000, "weapon_kill_stats", "assistsTotal" , "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_hemlok_smg", 2500, "weapon_kill_stats", "assistsTotal" , "mp_weapon_hemlok_smg" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_lmg", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_lmg", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_lmg", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_lmg", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_lmg", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_lmg" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_lstar", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_lstar", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_lstar", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_lstar", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_lstar", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_lstar" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_esaw", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_esaw", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_esaw", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_esaw", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_esaw", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_esaw" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_shotgun", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_shotgun", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_shotgun", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_shotgun", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_shotgun", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_shotgun" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_mastiff", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_mastiff", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_mastiff", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_mastiff", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_mastiff", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_mastiff" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_doubletake", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_doubletake", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_doubletake", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_doubletake", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_doubletake", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_doubletake" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_sniper", 10, "weapon_stats", "shotsHit", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_sniper", 100, "weapon_stats", "shotsHit", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_sniper", 500, "weapon_stats", "shotsHit", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_sniper", 1000, "weapon_stats", "shotsHit", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_sniper", 2500, "weapon_stats", "shotsHit", "mp_weapon_sniper" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_dmr", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_dmr", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_dmr", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_dmr", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_dmr", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_dmr" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_epg", 5, "weapon_kill_stats", "assistsTotal", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_epg", 50, "weapon_kill_stats", "assistsTotal", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_epg", 250, "weapon_kill_stats", "assistsTotal", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_epg", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_epg", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_epg" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_softball", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_softball", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_softball", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_softball", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_softball", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_softball" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_smr", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_smr", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_smr", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_smr", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_smr", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_smr" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_pulse_lmg", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_pulse_lmg", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_pulse_lmg", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_pulse_lmg", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_pulse_lmg", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_pulse_lmg" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_autopistol", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_autopistol", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_autopistol", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_autopistol", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_autopistol", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_autopistol" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_semipistol", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_semipistol", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_semipistol", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_semipistol", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_semipistol", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_semipistol" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_shotgun_pistol", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_shotgun_pistol", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_shotgun_pistol", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_shotgun_pistol", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_shotgun_pistol", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_shotgun_pistol" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_wingman", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_wingman", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_wingman", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_wingman", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_wingman", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_wingman" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_wingman_n", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_wingman_n", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_wingman_n", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_wingman_n", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_wingman_n", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_wingman_n" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_defender", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_defender", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_defender", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_defender", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_defender", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_defender" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_mgl", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_mgl", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_mgl", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_mgl", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_mgl", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_mgl" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_arc_launcher", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_arc_launcher", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_arc_launcher", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_arc_launcher", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_arc_launcher", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_arc_launcher" )

	InitUnlockForStatInt( "camo_skin56", "mp_weapon_rocket_launcher", 10, "weapon_kill_stats", "assistsTotal", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin58", "mp_weapon_rocket_launcher", 100, "weapon_kill_stats", "assistsTotal", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin55", "mp_weapon_rocket_launcher", 500, "weapon_kill_stats", "assistsTotal", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin57", "mp_weapon_rocket_launcher", 1000, "weapon_kill_stats", "assistsTotal", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin91", "mp_weapon_rocket_launcher", 2500, "weapon_kill_stats", "assistsTotal", "mp_weapon_rocket_launcher" )
	//Pilot Weapon SPREE
	InitUnlockForStatInt( "camo_skin93", "mp_weapon_rspn101", 2, "weapon_kill_stats", "killingSprees" , "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_rspn101", 5, "weapon_kill_stats", "killingSprees" , "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_rspn101", 10, "weapon_kill_stats", "killingSprees" , "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_rspn101", 25, "weapon_kill_stats", "killingSprees" , "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_rspn101", 50, "weapon_kill_stats", "killingSprees" , "mp_weapon_rspn101" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_rspn101_og", 2, "weapon_kill_stats", "killingSprees" , "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_rspn101_og", 5, "weapon_kill_stats", "killingSprees" , "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_rspn101_og", 10, "weapon_kill_stats", "killingSprees" , "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_rspn101_og", 25, "weapon_kill_stats", "killingSprees" , "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_rspn101_og", 50, "weapon_kill_stats", "killingSprees" , "mp_weapon_rspn101_og" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_hemlok", 2, "weapon_kill_stats", "killingSprees" , "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_hemlok", 5, "weapon_kill_stats", "killingSprees" , "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_hemlok", 10, "weapon_kill_stats", "killingSprees" , "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_hemlok", 25, "weapon_kill_stats", "killingSprees" , "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_hemlok", 50, "weapon_kill_stats", "killingSprees" , "mp_weapon_hemlok" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_g2", 2, "weapon_kill_stats", "killingSprees" , "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_g2", 5, "weapon_kill_stats", "killingSprees" , "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_g2", 10, "weapon_kill_stats", "killingSprees" , "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_g2", 25, "weapon_kill_stats", "killingSprees" , "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_g2", 50, "weapon_kill_stats", "killingSprees" , "mp_weapon_g2" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_vinson", 2, "weapon_kill_stats", "killingSprees" , "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_vinson", 5, "weapon_kill_stats", "killingSprees" , "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_vinson", 10, "weapon_kill_stats", "killingSprees" , "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_vinson", 25, "weapon_kill_stats", "killingSprees" , "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_vinson", 50, "weapon_kill_stats", "killingSprees" , "mp_weapon_vinson" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_car", 2, "weapon_kill_stats", "killingSprees" , "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_car", 5, "weapon_kill_stats", "killingSprees" , "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_car", 10, "weapon_kill_stats", "killingSprees" , "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_car", 25, "weapon_kill_stats", "killingSprees" , "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_car", 50, "weapon_kill_stats", "killingSprees" , "mp_weapon_car" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_r97", 2, "weapon_kill_stats", "killingSprees" , "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_r97", 5, "weapon_kill_stats", "killingSprees" , "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_r97", 10, "weapon_kill_stats", "killingSprees" , "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_r97", 25, "weapon_kill_stats", "killingSprees" , "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_r97", 50, "weapon_kill_stats", "killingSprees" , "mp_weapon_r97" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_alternator_smg", 2, "weapon_kill_stats", "killingSprees" , "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_alternator_smg", 5, "weapon_kill_stats", "killingSprees" , "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_alternator_smg", 10, "weapon_kill_stats", "killingSprees" , "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_alternator_smg", 25, "weapon_kill_stats", "killingSprees" , "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_alternator_smg", 50, "weapon_kill_stats", "killingSprees" , "mp_weapon_alternator_smg" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_hemlok_smg", 2, "weapon_kill_stats", "killingSprees" , "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_hemlok_smg", 5, "weapon_kill_stats", "killingSprees" , "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_hemlok_smg", 10, "weapon_kill_stats", "killingSprees" , "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_hemlok_smg", 25, "weapon_kill_stats", "killingSprees" , "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_hemlok_smg", 50, "weapon_kill_stats", "killingSprees" , "mp_weapon_hemlok_smg" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_lmg", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_lmg", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_lmg", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_lmg", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_lmg", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_lmg" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_lstar", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_lstar", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_lstar", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_lstar", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_lstar", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_lstar" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_esaw", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_esaw", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_esaw", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_esaw", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_esaw", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_esaw" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_shotgun", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_shotgun", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_shotgun", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_shotgun", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_shotgun", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_shotgun" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_mastiff", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_mastiff", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_mastiff", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_mastiff", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_mastiff", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_mastiff" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_doubletake", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_doubletake", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_doubletake", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_doubletake", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_doubletake", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_doubletake" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_sniper", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_sniper", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_sniper", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_sniper", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_sniper", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_sniper" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_dmr", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_dmr", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_dmr", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_dmr", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_dmr", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_dmr" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_epg", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_epg", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_epg", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_epg", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_epg", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_epg" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_softball", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_softball", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_softball", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_softball", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_softball", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_softball" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_smr", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_smr", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_smr", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_smr", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_smr", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_smr" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_pulse_lmg", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_pulse_lmg", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_pulse_lmg", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_pulse_lmg", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_pulse_lmg", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_pulse_lmg" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_autopistol", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_autopistol", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_autopistol", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_autopistol", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_autopistol", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_autopistol" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_semipistol", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_semipistol", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_semipistol", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_semipistol", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_semipistol", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_semipistol" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_shotgun_pistol", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_shotgun_pistol", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_shotgun_pistol", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_shotgun_pistol", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_shotgun_pistol", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_shotgun_pistol" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_wingman", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_wingman", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_wingman", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_wingman", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_wingman", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_wingman" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_wingman_n", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_wingman_n", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_wingman_n", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_wingman_n", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_wingman_n", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_wingman_n" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_defender", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_defender", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_defender", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_defender", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_defender", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_defender" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_mgl", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_mgl", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_mgl", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_mgl", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_mgl", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_mgl" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_arc_launcher", 2, "weapon_kill_stats", "killingSprees", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_arc_launcher", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_arc_launcher", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_arc_launcher", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_arc_launcher", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_arc_launcher" )

	InitUnlockForStatInt( "camo_skin93", "mp_weapon_rocket_launcher", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin94", "mp_weapon_rocket_launcher", 5, "weapon_kill_stats", "killingSprees", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin13", "mp_weapon_rocket_launcher", 10, "weapon_kill_stats", "killingSprees", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin07", "mp_weapon_rocket_launcher", 25, "weapon_kill_stats", "killingSprees", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin85", "mp_weapon_rocket_launcher", 50, "weapon_kill_stats", "killingSprees", "mp_weapon_rocket_launcher" )
	//Pilot Weapon Headshot
	InitUnlockForStatInt( "camo_skin60", "mp_weapon_rspn101", 10, "weapon_stats", "headshots", "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_rspn101", 25, "weapon_stats", "headshots", "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_rspn101", 50, "weapon_stats", "headshots", "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_rspn101", 100, "weapon_stats", "headshots", "mp_weapon_rspn101" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_rspn101", 250, "weapon_stats", "headshots", "mp_weapon_rspn101" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_rspn101_og", 10, "weapon_stats", "headshots", "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_rspn101_og", 25, "weapon_stats", "headshots", "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_rspn101_og", 50, "weapon_stats", "headshots", "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_rspn101_og", 100, "weapon_stats", "headshots", "mp_weapon_rspn101_og" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_rspn101_og", 250, "weapon_stats", "headshots", "mp_weapon_rspn101_og" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_hemlok", 10, "weapon_stats", "headshots", "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_hemlok", 25, "weapon_stats", "headshots", "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_hemlok", 50, "weapon_stats", "headshots", "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_hemlok", 100, "weapon_stats", "headshots", "mp_weapon_hemlok" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_hemlok", 250, "weapon_stats", "headshots", "mp_weapon_hemlok" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_g2", 10, "weapon_stats", "headshots", "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_g2", 25, "weapon_stats", "headshots", "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_g2", 50, "weapon_stats", "headshots", "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_g2", 100, "weapon_stats", "headshots", "mp_weapon_g2" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_g2", 250, "weapon_stats", "headshots", "mp_weapon_g2" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_vinson", 10, "weapon_stats", "headshots", "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_vinson", 25, "weapon_stats", "headshots", "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_vinson", 50, "weapon_stats", "headshots", "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_vinson", 100, "weapon_stats", "headshots", "mp_weapon_vinson" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_vinson", 250, "weapon_stats", "headshots", "mp_weapon_vinson" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_car", 10, "weapon_stats", "headshots", "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_car", 25, "weapon_stats", "headshots", "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_car", 50, "weapon_stats", "headshots", "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_car", 100, "weapon_stats", "headshots", "mp_weapon_car" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_car", 250, "weapon_stats", "headshots", "mp_weapon_car" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_r97", 10, "weapon_stats", "headshots", "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_r97", 25, "weapon_stats", "headshots", "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_r97", 50, "weapon_stats", "headshots", "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_r97", 100, "weapon_stats", "headshots", "mp_weapon_r97" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_r97", 250, "weapon_stats", "headshots", "mp_weapon_r97" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_alternator_smg", 10, "weapon_stats", "headshots", "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_alternator_smg", 25, "weapon_stats", "headshots", "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_alternator_smg", 50, "weapon_stats", "headshots", "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_alternator_smg", 100, "weapon_stats", "headshots", "mp_weapon_alternator_smg" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_alternator_smg", 250, "weapon_stats", "headshots", "mp_weapon_alternator_smg" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_hemlok_smg", 10, "weapon_stats", "headshots", "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_hemlok_smg", 25, "weapon_stats", "headshots", "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_hemlok_smg", 50, "weapon_stats", "headshots", "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_hemlok_smg", 100, "weapon_stats", "headshots", "mp_weapon_hemlok_smg" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_hemlok_smg", 250, "weapon_stats", "headshots", "mp_weapon_hemlok_smg" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_lmg", 10, "weapon_stats", "headshots", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_lmg", 25, "weapon_stats", "headshots", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_lmg", 50, "weapon_stats", "headshots", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_lmg", 100, "weapon_stats", "headshots", "mp_weapon_lmg" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_lmg", 250, "weapon_stats", "headshots", "mp_weapon_lmg" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_lstar", 10, "weapon_stats", "headshots", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_lstar", 25, "weapon_stats", "headshots", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_lstar", 50, "weapon_stats", "headshots", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_lstar", 100, "weapon_stats", "headshots", "mp_weapon_lstar" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_lstar", 250, "weapon_stats", "headshots", "mp_weapon_lstar" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_esaw", 10, "weapon_stats", "headshots", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_esaw", 25, "weapon_stats", "headshots", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_esaw", 50, "weapon_stats", "headshots", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_esaw", 100, "weapon_stats", "headshots", "mp_weapon_esaw" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_esaw", 250, "weapon_stats", "headshots", "mp_weapon_esaw" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_shotgun", 10, "weapon_stats", "headshots", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_shotgun", 25, "weapon_stats", "headshots", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_shotgun", 50, "weapon_stats", "headshots", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_shotgun", 100, "weapon_stats", "headshots", "mp_weapon_shotgun" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_shotgun", 250, "weapon_stats", "headshots", "mp_weapon_shotgun" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_mastiff", 10, "weapon_stats", "headshots", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_mastiff", 25, "weapon_stats", "headshots", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_mastiff", 50, "weapon_stats", "headshots", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_mastiff", 100, "weapon_stats", "headshots", "mp_weapon_mastiff" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_mastiff", 250, "weapon_stats", "headshots", "mp_weapon_mastiff" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_sniper", 10, "weapon_stats", "headshots", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_sniper", 25, "weapon_stats", "headshots", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_sniper", 50, "weapon_stats", "headshots", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_sniper", 100, "weapon_stats", "headshots", "mp_weapon_sniper" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_sniper", 250, "weapon_stats", "headshots", "mp_weapon_sniper" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_doubletake", 10, "weapon_stats", "headshots", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_doubletake", 25, "weapon_stats", "headshots", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_doubletake", 50, "weapon_stats", "headshots", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_doubletake", 100, "weapon_stats", "headshots", "mp_weapon_doubletake" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_doubletake", 250, "weapon_stats", "headshots", "mp_weapon_doubletake" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_dmr", 10, "weapon_stats", "headshots", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_dmr", 25, "weapon_stats", "headshots", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_dmr", 50, "weapon_stats", "headshots", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_dmr", 100, "weapon_stats", "headshots", "mp_weapon_dmr" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_dmr", 250, "weapon_stats", "headshots", "mp_weapon_dmr" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_autopistol", 5, "weapon_stats", "headshots", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_autopistol", 10, "weapon_stats", "headshots", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_autopistol", 25, "weapon_stats", "headshots", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_autopistol", 50, "weapon_stats", "headshots", "mp_weapon_autopistol" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_autopistol", 100, "weapon_stats", "headshots", "mp_weapon_autopistol" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_semipistol", 5, "weapon_stats", "headshots", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_semipistol", 10, "weapon_stats", "headshots", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_semipistol", 25, "weapon_stats", "headshots", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_semipistol", 50, "weapon_stats", "headshots", "mp_weapon_semipistol" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_semipistol", 100, "weapon_stats", "headshots", "mp_weapon_semipistol" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_shotgun_pistol", 5, "weapon_stats", "headshots", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_shotgun_pistol", 10, "weapon_stats", "headshots", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_shotgun_pistol", 25, "weapon_stats", "headshots", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_shotgun_pistol", 50, "weapon_stats", "headshots", "mp_weapon_shotgun_pistol" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_shotgun_pistol", 100, "weapon_stats", "headshots", "mp_weapon_shotgun_pistol" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_wingman", 5, "weapon_stats", "headshots", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_wingman", 10, "weapon_stats", "headshots", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_wingman", 25, "weapon_stats", "headshots", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_wingman", 50, "weapon_stats", "headshots", "mp_weapon_wingman" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_wingman", 100, "weapon_stats", "headshots", "mp_weapon_wingman" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_wingman_n", 5, "weapon_stats", "headshots", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_wingman_n", 10, "weapon_stats", "headshots", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_wingman_n", 25, "weapon_stats", "headshots", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_wingman_n", 50, "weapon_stats", "headshots", "mp_weapon_wingman_n" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_wingman_n", 100, "weapon_stats", "headshots", "mp_weapon_wingman_n" )

	//Shots hit for Grenadier and AT rather than headshots
	InitUnlockForStatInt( "camo_skin60", "mp_weapon_epg", 25, "weapon_stats", "shotsHit", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_epg", 100, "weapon_stats", "shotsHit", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_epg", 250, "weapon_stats", "shotsHit", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_epg", 500, "weapon_stats", "shotsHit", "mp_weapon_epg" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_epg", 1000, "weapon_stats", "shotsHit", "mp_weapon_epg" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_softball", 20, "weapon_stats", "shotsHit", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_softball", 50, "weapon_stats", "shotsHit", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_softball", 100, "weapon_stats", "shotsHit", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_softball", 250, "weapon_stats", "shotsHit", "mp_weapon_softball" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_softball", 500, "weapon_stats", "shotsHit", "mp_weapon_softball" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_smr", 50, "weapon_stats", "shotsHit", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_smr", 250, "weapon_stats", "shotsHit", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_smr", 500, "weapon_stats", "shotsHit", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_smr", 1000, "weapon_stats", "shotsHit", "mp_weapon_smr" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_smr", 2500, "weapon_stats", "shotsHit", "mp_weapon_smr" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_pulse_lmg", 100, "weapon_stats", "shotsHit", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_pulse_lmg", 500, "weapon_stats", "shotsHit", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_pulse_lmg", 1000, "weapon_stats", "shotsHit", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_pulse_lmg", 2500, "weapon_stats", "shotsHit", "mp_weapon_pulse_lmg" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_pulse_lmg", 5000, "weapon_stats", "shotsHit", "mp_weapon_pulse_lmg" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_defender", 20, "weapon_stats", "shotsHit", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_defender", 50, "weapon_stats", "shotsHit", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_defender", 100, "weapon_stats", "shotsHit", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_defender", 250, "weapon_stats", "shotsHit", "mp_weapon_defender" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_defender", 500, "weapon_stats", "shotsHit", "mp_weapon_defender" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_mgl", 50, "weapon_stats", "shotsHit", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_mgl", 250, "weapon_stats", "shotsHit", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_mgl", 500, "weapon_stats", "shotsHit", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_mgl", 1000, "weapon_stats", "shotsHit", "mp_weapon_mgl" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_mgl", 2500, "weapon_stats", "shotsHit", "mp_weapon_mgl" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_arc_launcher", 20, "weapon_stats", "shotsHit", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_arc_launcher", 50, "weapon_stats", "shotsHit", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_arc_launcher", 100, "weapon_stats", "shotsHit", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_arc_launcher", 250, "weapon_stats", "shotsHit", "mp_weapon_arc_launcher" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_arc_launcher", 500, "weapon_stats", "shotsHit", "mp_weapon_arc_launcher" )

	InitUnlockForStatInt( "camo_skin60", "mp_weapon_rocket_launcher", 10, "weapon_stats", "shotsHit", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin61", "mp_weapon_rocket_launcher", 25, "weapon_stats", "shotsHit", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin62", "mp_weapon_rocket_launcher", 50, "weapon_stats", "shotsHit", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin59", "mp_weapon_rocket_launcher", 100, "weapon_stats", "shotsHit", "mp_weapon_rocket_launcher" )
	InitUnlockForStatInt( "camo_skin87", "mp_weapon_rocket_launcher", 250, "weapon_stats", "shotsHit", "mp_weapon_rocket_launcher" )

// //////////////////	Titan CHALLENGES	//////////////////

	//Titan killing Titans
	InitUnlockForStatInt( "titan_camo_skin67", "ion", 10, "titan_stats", "titansTotal", "ion" )
	InitUnlockForStatInt( "titan_camo_skin65", "ion", 50, "titan_stats", "titansTotal", "ion" )
	InitUnlockForStatInt( "titan_camo_skin66", "ion", 100, "titan_stats", "titansTotal", "ion" )
	InitUnlockForStatInt( "titan_camo_skin64", "ion", 250, "titan_stats", "titansTotal", "ion" )
	InitUnlockForStatInt( "titan_camo_skin63", "ion", 500, "titan_stats", "titansTotal", "ion" )

	InitUnlockForStatInt( "titan_camo_skin67", "scorch", 10, "titan_stats", "titansTotal", "scorch" )
	InitUnlockForStatInt( "titan_camo_skin65", "scorch", 50, "titan_stats", "titansTotal", "scorch" )
	InitUnlockForStatInt( "titan_camo_skin66", "scorch", 100, "titan_stats", "titansTotal", "scorch" )
	InitUnlockForStatInt( "titan_camo_skin64", "scorch", 250, "titan_stats", "titansTotal", "scorch" )
	InitUnlockForStatInt( "titan_camo_skin63", "scorch", 500, "titan_stats", "titansTotal", "scorch" )

	InitUnlockForStatInt( "titan_camo_skin67", "vanguard", 10, "titan_stats", "titansTotal", "vanguard" )
	InitUnlockForStatInt( "titan_camo_skin65", "vanguard", 50, "titan_stats", "titansTotal", "vanguard" )
	InitUnlockForStatInt( "titan_camo_skin66", "vanguard", 100, "titan_stats", "titansTotal", "vanguard" )
	InitUnlockForStatInt( "titan_camo_skin64", "vanguard", 250, "titan_stats", "titansTotal", "vanguard" )
	InitUnlockForStatInt( "titan_camo_skin63", "vanguard", 500, "titan_stats", "titansTotal", "vanguard" )

	InitUnlockForStatInt( "titan_camo_skin67", "northstar", 10, "titan_stats", "titansTotal", "northstar" )
	InitUnlockForStatInt( "titan_camo_skin65", "northstar", 50, "titan_stats", "titansTotal", "northstar" )
	InitUnlockForStatInt( "titan_camo_skin66", "northstar", 100, "titan_stats", "titansTotal", "northstar" )
	InitUnlockForStatInt( "titan_camo_skin64", "northstar", 250, "titan_stats", "titansTotal", "northstar" )
	InitUnlockForStatInt( "titan_camo_skin63", "northstar", 500, "titan_stats", "titansTotal", "northstar" )

	InitUnlockForStatInt( "titan_camo_skin67", "ronin", 10, "titan_stats", "titansTotal", "ronin" )
	InitUnlockForStatInt( "titan_camo_skin65", "ronin", 50, "titan_stats", "titansTotal", "ronin" )
	InitUnlockForStatInt( "titan_camo_skin66", "ronin", 100, "titan_stats", "titansTotal", "ronin" )
	InitUnlockForStatInt( "titan_camo_skin64", "ronin", 250, "titan_stats", "titansTotal", "ronin" )
	InitUnlockForStatInt( "titan_camo_skin63", "ronin", 500, "titan_stats", "titansTotal", "ronin" )

	InitUnlockForStatInt( "titan_camo_skin67", "tone", 10, "titan_stats", "titansTotal", "tone" )
	InitUnlockForStatInt( "titan_camo_skin65", "tone", 50, "titan_stats", "titansTotal", "tone" )
	InitUnlockForStatInt( "titan_camo_skin66", "tone", 100, "titan_stats", "titansTotal", "tone" )
	InitUnlockForStatInt( "titan_camo_skin64", "tone", 250, "titan_stats", "titansTotal", "tone" )
	InitUnlockForStatInt( "titan_camo_skin63", "tone", 500, "titan_stats", "titansTotal", "tone" )

	InitUnlockForStatInt( "titan_camo_skin67", "legion", 10, "titan_stats", "titansTotal", "legion" )
	InitUnlockForStatInt( "titan_camo_skin65", "legion", 50, "titan_stats", "titansTotal", "legion" )
	InitUnlockForStatInt( "titan_camo_skin66", "legion", 100, "titan_stats", "titansTotal", "legion" )
	InitUnlockForStatInt( "titan_camo_skin64", "legion", 250, "titan_stats", "titansTotal", "legion" )
	InitUnlockForStatInt( "titan_camo_skin63", "legion", 500, "titan_stats", "titansTotal", "legion" )

	//Titan killing Pilots
	InitUnlockForStatInt( "titan_camo_skin60", "ion", 20, "titan_stats", "pilots", "ion" )
	InitUnlockForStatInt( "titan_camo_skin61", "ion", 100, "titan_stats", "pilots", "ion" )
	InitUnlockForStatInt( "titan_camo_skin62", "ion", 200, "titan_stats", "pilots", "ion" )
	InitUnlockForStatInt( "titan_camo_skin59", "ion", 500, "titan_stats", "pilots", "ion" )

	InitUnlockForStatInt( "titan_camo_skin60", "scorch", 20, "titan_stats", "pilots", "scorch" )
	InitUnlockForStatInt( "titan_camo_skin61", "scorch", 100,"titan_stats", "pilots", "scorch" )
	InitUnlockForStatInt( "titan_camo_skin62", "scorch", 200, "titan_stats", "pilots", "scorch"  )
	InitUnlockForStatInt( "titan_camo_skin59", "scorch", 500, "titan_stats", "pilots", "scorch"  )

	InitUnlockForStatInt( "titan_camo_skin60", "vanguard", 20, "titan_stats", "pilots", "vanguard" )
	InitUnlockForStatInt( "titan_camo_skin61", "vanguard", 100,"titan_stats", "pilots", "vanguard" )
	InitUnlockForStatInt( "titan_camo_skin62", "vanguard", 200, "titan_stats", "pilots", "vanguard"  )
	InitUnlockForStatInt( "titan_camo_skin59", "vanguard", 500, "titan_stats", "pilots", "vanguard"  )

	InitUnlockForStatInt( "titan_camo_skin60", "northstar", 20, "titan_stats", "pilots", "northstar" )
	InitUnlockForStatInt( "titan_camo_skin61", "northstar", 100,"titan_stats", "pilots", "northstar" )
	InitUnlockForStatInt( "titan_camo_skin62", "northstar", 200, "titan_stats", "pilots", "northstar" )
	InitUnlockForStatInt( "titan_camo_skin59", "northstar", 500, "titan_stats", "pilots", "northstar" )

	InitUnlockForStatInt( "titan_camo_skin60", "ronin", 20, "titan_stats", "pilots", "ronin" )
	InitUnlockForStatInt( "titan_camo_skin61", "ronin", 100,"titan_stats", "pilots", "ronin" )
	InitUnlockForStatInt( "titan_camo_skin62", "ronin", 200, "titan_stats", "pilots", "ronin" )
	InitUnlockForStatInt( "titan_camo_skin59", "ronin", 500, "titan_stats", "pilots", "ronin" )

	InitUnlockForStatInt( "titan_camo_skin60", "tone", 20, "titan_stats", "pilots", "tone" )
	InitUnlockForStatInt( "titan_camo_skin61", "tone", 100,"titan_stats", "pilots", "tone" )
	InitUnlockForStatInt( "titan_camo_skin62", "tone", 200, "titan_stats", "pilots", "tone" )
	InitUnlockForStatInt( "titan_camo_skin59", "tone", 500, "titan_stats", "pilots", "tone" )

	InitUnlockForStatInt( "titan_camo_skin60", "legion", 20, "titan_stats", "pilots", "legion" )
	InitUnlockForStatInt( "titan_camo_skin61", "legion", 100,"titan_stats", "pilots", "legion" )
	InitUnlockForStatInt( "titan_camo_skin62", "legion", 200, "titan_stats", "pilots", "legion" )
	InitUnlockForStatInt( "titan_camo_skin59", "legion", 500, "titan_stats", "pilots", "legion" )
	//TITAN DMG
	InitUnlockForStatInt( "titan_camo_skin56", "ion", 300000, "titan_stats", "titanDamage", "ion" )
	InitUnlockForStatInt( "titan_camo_skin58", "ion", 600000, "titan_stats", "titanDamage", "ion" )
	InitUnlockForStatInt( "titan_camo_skin55", "ion", 1500000, "titan_stats", "titanDamage", "ion" )
	InitUnlockForStatInt( "titan_camo_skin57", "ion", 3000000, "titan_stats", "titanDamage", "ion" )
	InitUnlockForStatInt( "titan_camo_skin91", "ion", 5000000, "titan_stats", "titanDamage", "ion" )

	InitUnlockForStatInt( "titan_camo_skin56", "scorch", 300000, "titan_stats", "titanDamage", "scorch" )
	InitUnlockForStatInt( "titan_camo_skin58", "scorch", 600000, "titan_stats", "titanDamage", "scorch" )
	InitUnlockForStatInt( "titan_camo_skin55", "scorch", 1500000, "titan_stats", "titanDamage", "scorch" )
	InitUnlockForStatInt( "titan_camo_skin57", "scorch", 3000000, "titan_stats", "titanDamage", "scorch" )
	InitUnlockForStatInt( "titan_camo_skin91", "scorch", 5000000, "titan_stats", "titanDamage", "scorch" )

	InitUnlockForStatInt( "titan_camo_skin56", "vanguard", 300000, "titan_stats", "titanDamage", "vanguard" )
	InitUnlockForStatInt( "titan_camo_skin58", "vanguard", 600000, "titan_stats", "titanDamage", "vanguard" )
	InitUnlockForStatInt( "titan_camo_skin55", "vanguard", 1500000, "titan_stats", "titanDamage", "vanguard" )
	InitUnlockForStatInt( "titan_camo_skin57", "vanguard", 3000000, "titan_stats", "titanDamage", "vanguard" )
	InitUnlockForStatInt( "titan_camo_skin91", "vanguard", 5000000, "titan_stats", "titanDamage", "vanguard" )

	InitUnlockForStatInt( "titan_camo_skin56", "northstar", 300000, "titan_stats", "titanDamage", "northstar" )
	InitUnlockForStatInt( "titan_camo_skin58", "northstar", 600000, "titan_stats", "titanDamage", "northstar" )
	InitUnlockForStatInt( "titan_camo_skin55", "northstar", 1500000, "titan_stats", "titanDamage", "northstar" )
	InitUnlockForStatInt( "titan_camo_skin57", "northstar", 3000000, "titan_stats", "titanDamage", "northstar" )
	InitUnlockForStatInt( "titan_camo_skin91", "northstar", 5000000, "titan_stats", "titanDamage", "northstar" )

	InitUnlockForStatInt( "titan_camo_skin56", "ronin", 300000, "titan_stats", "titanDamage", "ronin" )
	InitUnlockForStatInt( "titan_camo_skin58", "ronin", 600000, "titan_stats", "titanDamage", "ronin" )
	InitUnlockForStatInt( "titan_camo_skin55", "ronin", 1500000, "titan_stats", "titanDamage", "ronin" )
	InitUnlockForStatInt( "titan_camo_skin57", "ronin", 3000000, "titan_stats", "titanDamage", "ronin" )
	InitUnlockForStatInt( "titan_camo_skin91", "ronin", 5000000, "titan_stats", "titanDamage", "ronin" )

	InitUnlockForStatInt( "titan_camo_skin56", "tone", 300000, "titan_stats", "titanDamage", "tone" )
	InitUnlockForStatInt( "titan_camo_skin58", "tone", 600000, "titan_stats", "titanDamage", "tone" )
	InitUnlockForStatInt( "titan_camo_skin55", "tone", 1500000, "titan_stats", "titanDamage", "tone" )
	InitUnlockForStatInt( "titan_camo_skin57", "tone", 3000000, "titan_stats", "titanDamage", "tone" )
	InitUnlockForStatInt( "titan_camo_skin91", "tone", 5000000, "titan_stats", "titanDamage", "tone" )

	InitUnlockForStatInt( "titan_camo_skin56", "legion", 600000, "titan_stats", "titanDamage", "legion" )
	InitUnlockForStatInt( "titan_camo_skin58", "legion", 1500000,"titan_stats", "titanDamage", "legion" )
	InitUnlockForStatInt( "titan_camo_skin55", "legion", 3000000, "titan_stats", "titanDamage", "legion" )
	InitUnlockForStatInt( "titan_camo_skin57", "legion", 5000000, "titan_stats", "titanDamage", "legion" )
	InitUnlockForStatInt( "titan_camo_skin91", "legion", 7500000, "titan_stats", "titanDamage", "legion" )
	//Titan DISTANCE
	InitUnlockForStatFloat( "titan_camo_skin13", "ion", 15, "distance_stats", "asTitan_ion" )
	InitUnlockForStatFloat( "titan_camo_skin07", "ion", 50, "distance_stats", "asTitan_ion" )
	InitUnlockForStatFloat( "titan_camo_skin87", "ion", 150, "distance_stats", "asTitan_ion" )

	InitUnlockForStatFloat( "titan_camo_skin13", "scorch", 15, "distance_stats", "asTitan_scorch" )
	InitUnlockForStatFloat( "titan_camo_skin07", "scorch", 50,  "distance_stats", "asTitan_scorch" )
	InitUnlockForStatFloat( "titan_camo_skin87", "scorch", 150, "distance_stats", "asTitan_scorch" )

	InitUnlockForStatFloat( "titan_camo_skin13", "vanguard", 15, "distance_stats", "asTitan_vanguard" )
	InitUnlockForStatFloat( "titan_camo_skin07", "vanguard", 50,  "distance_stats", "asTitan_vanguard" )
	InitUnlockForStatFloat( "titan_camo_skin87", "vanguard", 150, "distance_stats", "asTitan_vanguard" )

	InitUnlockForStatFloat( "titan_camo_skin13", "northstar", 15, "distance_stats", "asTitan_northstar" )
	InitUnlockForStatFloat( "titan_camo_skin07", "northstar", 50,  "distance_stats", "asTitan_northstar" )
	InitUnlockForStatFloat( "titan_camo_skin87", "northstar", 150, "distance_stats", "asTitan_northstar" )

	InitUnlockForStatFloat( "titan_camo_skin13", "ronin", 15, "distance_stats", "asTitan_ronin" )
	InitUnlockForStatFloat( "titan_camo_skin07", "ronin", 50,  "distance_stats", "asTitan_ronin" )
	InitUnlockForStatFloat( "titan_camo_skin87", "ronin", 150, "distance_stats", "asTitan_ronin" )

	InitUnlockForStatFloat( "titan_camo_skin13", "tone", 15, "distance_stats", "asTitan_tone" )
	InitUnlockForStatFloat( "titan_camo_skin07", "tone", 50,  "distance_stats", "asTitan_tone" )
	InitUnlockForStatFloat( "titan_camo_skin87", "tone", 150, "distance_stats", "asTitan_tone" )

	InitUnlockForStatFloat( "titan_camo_skin13", "legion", 15, "distance_stats", "asTitan_legion" )
	InitUnlockForStatFloat( "titan_camo_skin07", "legion", 50,  "distance_stats", "asTitan_legion" )
	InitUnlockForStatFloat( "titan_camo_skin87", "legion", 150, "distance_stats", "asTitan_legion" )

	//Titan Executions
	InitUnlockForStatInt( "titan_camo_skin93", "ion", 3, "kills_stats", "titanExocutionIon" )
	InitUnlockForStatInt( "titan_camo_skin94", "ion", 10, "kills_stats", "titanExocutionIon" )
	InitUnlockForStatInt( "titan_camo_skin85", "ion", 25, "kills_stats", "titanExocutionIon" )

	InitUnlockForStatInt( "titan_camo_skin93", "scorch", 3, "kills_stats", "titanExocutionScorch" )
	InitUnlockForStatInt( "titan_camo_skin94", "scorch", 10, "kills_stats", "titanExocutionScorch" )
	InitUnlockForStatInt( "titan_camo_skin85", "scorch", 25, "kills_stats", "titanExocutionScorch" )

	InitUnlockForStatInt( "titan_camo_skin93", "vanguard", 3, "kills_stats", "titanExocutionVanguard" )
	InitUnlockForStatInt( "titan_camo_skin94", "vanguard", 10, "kills_stats", "titanExocutionVanguard" )
	InitUnlockForStatInt( "titan_camo_skin85", "vanguard", 25, "kills_stats", "titanExocutionVanguard" )

	InitUnlockForStatInt( "titan_camo_skin93", "northstar", 3, "kills_stats", "titanExocutionNorthstar" )
	InitUnlockForStatInt( "titan_camo_skin94", "northstar", 10, "kills_stats", "titanExocutionNorthstar" )
	InitUnlockForStatInt( "titan_camo_skin85", "northstar", 25, "kills_stats", "titanExocutionNorthstar" )

	InitUnlockForStatInt( "titan_camo_skin93", "ronin", 3, "kills_stats", "titanExocutionRonin" )
	InitUnlockForStatInt( "titan_camo_skin94", "ronin", 10, "kills_stats", "titanExocutionRonin" )
	InitUnlockForStatInt( "titan_camo_skin85", "ronin", 25, "kills_stats", "titanExocutionRonin" )

	InitUnlockForStatInt( "titan_camo_skin93", "tone", 3, "kills_stats", "titanExocutionTone" )
	InitUnlockForStatInt( "titan_camo_skin94", "tone", 10, "kills_stats", "titanExocutionTone" )
	InitUnlockForStatInt( "titan_camo_skin85", "tone", 25, "kills_stats", "titanExocutionTone" )

	InitUnlockForStatInt( "titan_camo_skin93", "legion", 3, "kills_stats", "titanExocutionLegion" )
	InitUnlockForStatInt( "titan_camo_skin94", "legion", 10, "kills_stats", "titanExocutionLegion" )
	InitUnlockForStatInt( "titan_camo_skin85", "legion", 25, "kills_stats", "titanExocutionLegion" )

	//Titan Sprees for Warpaint
	InitUnlockForStatInt( "ion_skin_01", "ion", 30, "kills_stats", "killingSpressAs_ion" )
	InitUnlockForStatInt( "ion_skin_02", "ion", 100, "kills_stats", "killingSpressAs_ion" )

	InitUnlockForStatInt( "scorch_skin_01", "scorch", 30, "kills_stats", "killingSpressAs_scorch" )
	InitUnlockForStatInt( "scorch_skin_02", "scorch", 100, "kills_stats", "killingSpressAs_scorch" )

	//InitUnlockForStatInt( "vanguard_skin_01", "vanguard", 30, "kills_stats", "killingSpressAs_vanguard" )
	//InitUnlockForStatInt( "vanguard_skin_02", "vanguard", 100, "kills_stats", "killingSpressAs_vanguard" )
	//InitUnlockForStatInt( "vanguard_skin_03", "vanguard", 100, "kills_stats", "killingSpressAs_vanguard" )

	InitUnlockForStatInt( "northstar_skin_01", "northstar", 30, "kills_stats", "killingSpressAs_northstar" )
	InitUnlockForStatInt( "northstar_skin_02", "northstar", 65, "kills_stats", "killingSpressAs_northstar" )
	InitUnlockForStatInt( "northstar_skin_03", "northstar", 100, "kills_stats", "killingSpressAs_northstar" )

	InitUnlockForStatInt( "ronin_skin_01", "ronin", 30, "kills_stats", "killingSpressAs_ronin" )
	InitUnlockForStatInt( "ronin_skin_02", "ronin", 65,  "kills_stats", "killingSpressAs_ronin" )
	InitUnlockForStatInt( "ronin_skin_03", "ronin", 100, "kills_stats", "killingSpressAs_ronin" )

	InitUnlockForStatInt( "tone_skin_01", "tone", 30, "kills_stats", "killingSpressAs_tone" )
	InitUnlockForStatInt( "tone_skin_02", "tone", 65,  "kills_stats", "killingSpressAs_tone" )
	InitUnlockForStatInt( "tone_skin_03", "tone", 100, "kills_stats", "killingSpressAs_tone" )

	InitUnlockForStatInt( "legion_skin_01", "legion", 30, "kills_stats", "killingSpressAs_legion" )
	InitUnlockForStatInt( "legion_skin_02", "legion", 65,  "kills_stats", "killingSpressAs_legion" )
	InitUnlockForStatInt( "legion_skin_03", "legion", 100, "kills_stats", "killingSpressAs_legion" )


// //////////////////	Titan Weapon CHALLENGES	//////////////////

	//Titan killing Titans for Weapon
	InitUnlockForStatInt( "camo_skin67", "ion", 5, "weapon_kill_stats", "titansTotal", "mp_titanweapon_particle_accelerator" )
	InitUnlockForStatInt( "camo_skin65", "ion", 15, "weapon_kill_stats", "titansTotal", "mp_titanweapon_particle_accelerator" )
	InitUnlockForStatInt( "camo_skin66", "ion", 30, "weapon_kill_stats", "titansTotal", "mp_titanweapon_particle_accelerator" )
	InitUnlockForStatInt( "camo_skin64", "ion", 75, "weapon_kill_stats", "titansTotal", "mp_titanweapon_particle_accelerator" )
	InitUnlockForStatInt( "camo_skin63", "ion", 150, "weapon_kill_stats", "titansTotal", "mp_titanweapon_particle_accelerator" )

	InitUnlockForStatInt( "camo_skin67", "scorch", 5, "weapon_kill_stats", "titansTotal", "mp_titanweapon_meteor" )
	InitUnlockForStatInt( "camo_skin65", "scorch", 15, "weapon_kill_stats", "titansTotal", "mp_titanweapon_meteor" )
	InitUnlockForStatInt( "camo_skin66", "scorch", 30, "weapon_kill_stats", "titansTotal", "mp_titanweapon_meteor" )
	InitUnlockForStatInt( "camo_skin64", "scorch", 75, "weapon_kill_stats", "titansTotal", "mp_titanweapon_meteor" )
	InitUnlockForStatInt( "camo_skin63", "scorch", 150, "weapon_kill_stats", "titansTotal", "mp_titanweapon_meteor" )

	InitUnlockForStatInt( "camo_skin67", "vanguard", 5, "weapon_kill_stats", "titansTotal", "mp_titanweapon_xo16_vanguard" )
	InitUnlockForStatInt( "camo_skin65", "vanguard", 15, "weapon_kill_stats", "titansTotal", "mp_titanweapon_xo16_vanguard" )
	InitUnlockForStatInt( "camo_skin66", "vanguard", 30, "weapon_kill_stats", "titansTotal", "mp_titanweapon_xo16_vanguard" )
	InitUnlockForStatInt( "camo_skin64", "vanguard", 75, "weapon_kill_stats", "titansTotal", "mp_titanweapon_xo16_vanguard" )
	InitUnlockForStatInt( "camo_skin63", "vanguard", 150, "weapon_kill_stats", "titansTotal", "mp_titanweapon_xo16_vanguard" )

	InitUnlockForStatInt( "camo_skin67", "northstar", 5, "weapon_kill_stats", "titansTotal", "mp_titanweapon_sniper" )
	InitUnlockForStatInt( "camo_skin65", "northstar", 15, "weapon_kill_stats", "titansTotal", "mp_titanweapon_sniper" )
	InitUnlockForStatInt( "camo_skin66", "northstar", 30, "weapon_kill_stats", "titansTotal", "mp_titanweapon_sniper" )
	InitUnlockForStatInt( "camo_skin64", "northstar", 75, "weapon_kill_stats", "titansTotal", "mp_titanweapon_sniper" )
	InitUnlockForStatInt( "camo_skin63", "northstar", 150, "weapon_kill_stats", "titansTotal", "mp_titanweapon_sniper" )

	InitUnlockForStatInt( "camo_skin67", "ronin", 5, "weapon_kill_stats", "titansTotal", "mp_titanweapon_leadwall" )
	InitUnlockForStatInt( "camo_skin65", "ronin", 15, "weapon_kill_stats", "titansTotal", "mp_titanweapon_leadwall"  )
	InitUnlockForStatInt( "camo_skin66", "ronin", 30, "weapon_kill_stats", "titansTotal", "mp_titanweapon_leadwall"  )
	InitUnlockForStatInt( "camo_skin64", "ronin", 75, "weapon_kill_stats", "titansTotal", "mp_titanweapon_leadwall"  )
	InitUnlockForStatInt( "camo_skin63", "ronin", 150, "weapon_kill_stats", "titansTotal", "mp_titanweapon_leadwall"  )

	InitUnlockForStatInt( "camo_skin67", "tone", 5, "weapon_kill_stats", "titansTotal", "mp_titanweapon_sticky_40mm"  )
	InitUnlockForStatInt( "camo_skin65", "tone", 15, "weapon_kill_stats", "titansTotal", "mp_titanweapon_sticky_40mm" )
	InitUnlockForStatInt( "camo_skin66", "tone", 30, "weapon_kill_stats", "titansTotal", "mp_titanweapon_sticky_40mm" )
	InitUnlockForStatInt( "camo_skin64", "tone", 75, "weapon_kill_stats", "titansTotal", "mp_titanweapon_sticky_40mm" )
	InitUnlockForStatInt( "camo_skin63", "tone", 150, "weapon_kill_stats", "titansTotal", "mp_titanweapon_sticky_40mm" )

	InitUnlockForStatInt( "camo_skin67", "legion", 5, "weapon_kill_stats", "titansTotal", "mp_titanweapon_predator_cannon" )
	InitUnlockForStatInt( "camo_skin65", "legion", 15, "weapon_kill_stats", "titansTotal", "mp_titanweapon_predator_cannon" )
	InitUnlockForStatInt( "camo_skin66", "legion", 30, "weapon_kill_stats", "titansTotal", "mp_titanweapon_predator_cannon" )
	InitUnlockForStatInt( "camo_skin64", "legion", 75, "weapon_kill_stats", "titansTotal", "mp_titanweapon_predator_cannon" )
	InitUnlockForStatInt( "camo_skin63", "legion", 150, "weapon_kill_stats", "titansTotal", "mp_titanweapon_predator_cannon" )
	//Titan Weapon killing Pilots
	InitUnlockForStatInt( "camo_skin60", "ion", 10, "weapon_kill_stats", "pilots", "mp_titanweapon_particle_accelerator")
	InitUnlockForStatInt( "camo_skin61", "ion", 25, "weapon_kill_stats", "pilots", "mp_titanweapon_particle_accelerator")
	InitUnlockForStatInt( "camo_skin62", "ion", 50, "weapon_kill_stats", "pilots", "mp_titanweapon_particle_accelerator" )
	InitUnlockForStatInt( "camo_skin59", "ion", 100, "weapon_kill_stats", "pilots", "mp_titanweapon_particle_accelerator" )
	InitUnlockForStatInt( "camo_skin87", "ion", 250, "weapon_kill_stats", "pilots", "mp_titanweapon_particle_accelerator" )

	InitUnlockForStatInt( "camo_skin60", "scorch", 10, "weapon_kill_stats", "pilots", "mp_titanweapon_meteor")
	InitUnlockForStatInt( "camo_skin61", "scorch", 25, "weapon_kill_stats", "pilots", "mp_titanweapon_meteor")
	InitUnlockForStatInt( "camo_skin62", "scorch", 50, "weapon_kill_stats", "pilots", "mp_titanweapon_meteor" )
	InitUnlockForStatInt( "camo_skin59", "scorch", 100,  "weapon_kill_stats", "pilots", "mp_titanweapon_meteor" )
	InitUnlockForStatInt( "camo_skin87", "scorch", 250, "weapon_kill_stats", "pilots", "mp_titanweapon_meteor" )

	InitUnlockForStatInt( "camo_skin60", "vanguard", 10, "weapon_kill_stats", "pilots", "mp_titanweapon_xo16_vanguard")
	InitUnlockForStatInt( "camo_skin61", "vanguard", 25, "weapon_kill_stats", "pilots", "mp_titanweapon_xo16_vanguard")
	InitUnlockForStatInt( "camo_skin62", "vanguard", 50, "weapon_kill_stats", "pilots", "mp_titanweapon_xo16_vanguard" )
	InitUnlockForStatInt( "camo_skin59", "vanguard", 100,  "weapon_kill_stats", "pilots", "mp_titanweapon_xo16_vanguard" )
	InitUnlockForStatInt( "camo_skin87", "vanguard", 250, "weapon_kill_stats", "pilots", "mp_titanweapon_xo16_vanguard" )

	InitUnlockForStatInt( "camo_skin60", "northstar", 10,  "weapon_kill_stats", "pilots", "mp_titanweapon_sniper")
	InitUnlockForStatInt( "camo_skin61", "northstar", 25, "weapon_kill_stats", "pilots", "mp_titanweapon_sniper")
	InitUnlockForStatInt( "camo_skin62", "northstar", 50, "weapon_kill_stats", "pilots", "mp_titanweapon_sniper" )
	InitUnlockForStatInt( "camo_skin59", "northstar", 100, "weapon_kill_stats", "pilots", "mp_titanweapon_sniper" )
	InitUnlockForStatInt( "camo_skin87", "northstar", 250, "weapon_kill_stats", "pilots", "mp_titanweapon_sniper" )

	InitUnlockForStatInt( "camo_skin60", "ronin", 10,  "weapon_kill_stats", "pilots", "mp_titanweapon_leadwall")
	InitUnlockForStatInt( "camo_skin61", "ronin", 25, "weapon_kill_stats", "pilots", "mp_titanweapon_leadwall")
	InitUnlockForStatInt( "camo_skin62", "ronin", 50, "weapon_kill_stats", "pilots", "mp_titanweapon_leadwall" )
	InitUnlockForStatInt( "camo_skin59", "ronin", 100, "weapon_kill_stats", "pilots", "mp_titanweapon_leadwall" )
	InitUnlockForStatInt( "camo_skin87", "ronin", 250, "weapon_kill_stats", "pilots", "mp_titanweapon_leadwall" )

	InitUnlockForStatInt( "camo_skin60", "tone", 10,  "weapon_kill_stats", "pilots", "mp_titanweapon_sticky_40mm")
	InitUnlockForStatInt( "camo_skin61", "tone", 25, "weapon_kill_stats", "pilots", "mp_titanweapon_sticky_40mm")
	InitUnlockForStatInt( "camo_skin62", "tone", 50, "weapon_kill_stats", "pilots", "mp_titanweapon_sticky_40mm" )
	InitUnlockForStatInt( "camo_skin59", "tone", 100, "weapon_kill_stats", "pilots", "mp_titanweapon_sticky_40mm" )
	InitUnlockForStatInt( "camo_skin87", "tone", 250, "weapon_kill_stats", "pilots", "mp_titanweapon_sticky_40mm" )

	InitUnlockForStatInt( "camo_skin60", "legion", 10,  "weapon_kill_stats", "pilots", "mp_titanweapon_predator_cannon")
	InitUnlockForStatInt( "camo_skin61", "legion", 25, "weapon_kill_stats", "pilots", "mp_titanweapon_predator_cannon")
	InitUnlockForStatInt( "camo_skin62", "legion", 50, "weapon_kill_stats", "pilots", "mp_titanweapon_predator_cannon" )
	InitUnlockForStatInt( "camo_skin59", "legion", 100, "weapon_kill_stats", "pilots", "mp_titanweapon_predator_cannon" )
	InitUnlockForStatInt( "camo_skin87", "legion", 250, "weapon_kill_stats", "pilots", "mp_titanweapon_predator_cannon" )
	//Titan assists Titans for Weapon
	InitUnlockForStatInt( "camo_skin56", "ion", 5, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_particle_accelerator" )
	InitUnlockForStatInt( "camo_skin58", "ion", 15, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_particle_accelerator" )
	InitUnlockForStatInt( "camo_skin55", "ion", 30, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_particle_accelerator" )
	InitUnlockForStatInt( "camo_skin57", "ion", 75, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_particle_accelerator" )
	InitUnlockForStatInt( "camo_skin91", "ion", 150, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_particle_accelerator" )

	InitUnlockForStatInt( "camo_skin56", "scorch", 5, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_meteor" )
	InitUnlockForStatInt( "camo_skin58", "scorch", 15, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_meteor" )
	InitUnlockForStatInt( "camo_skin55", "scorch", 30, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_meteor" )
	InitUnlockForStatInt( "camo_skin57", "scorch", 75, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_meteor" )
	InitUnlockForStatInt( "camo_skin91", "scorch", 150, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_meteor" )

	InitUnlockForStatInt( "camo_skin56", "vanguard", 5, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_xo16_vanguard" )
	InitUnlockForStatInt( "camo_skin58", "vanguard", 15, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_xo16_vanguard" )
	InitUnlockForStatInt( "camo_skin55", "vanguard", 30, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_xo16_vanguard" )
	InitUnlockForStatInt( "camo_skin57", "vanguard", 75, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_xo16_vanguard" )
	InitUnlockForStatInt( "camo_skin91", "vanguard", 150, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_xo16_vanguard" )

	InitUnlockForStatInt( "camo_skin56", "northstar", 5, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_sniper" )
	InitUnlockForStatInt( "camo_skin58", "northstar", 15, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_sniper" )
	InitUnlockForStatInt( "camo_skin55", "northstar", 30, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_sniper" )
	InitUnlockForStatInt( "camo_skin57", "northstar", 75, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_sniper" )
	InitUnlockForStatInt( "camo_skin91", "northstar", 150, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_sniper" )

	InitUnlockForStatInt( "camo_skin56", "ronin", 5, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_leadwall" )
	InitUnlockForStatInt( "camo_skin58", "ronin", 15, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_leadwall"  )
	InitUnlockForStatInt( "camo_skin55", "ronin", 30, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_leadwall"  )
	InitUnlockForStatInt( "camo_skin57", "ronin", 75, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_leadwall"  )
	InitUnlockForStatInt( "camo_skin91", "ronin", 150, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_leadwall"  )

	InitUnlockForStatInt( "camo_skin56", "tone", 5, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_sticky_40mm"  )
	InitUnlockForStatInt( "camo_skin58", "tone", 15, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_sticky_40mm" )
	InitUnlockForStatInt( "camo_skin55", "tone", 30, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_sticky_40mm" )
	InitUnlockForStatInt( "camo_skin57", "tone", 75, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_sticky_40mm" )
	InitUnlockForStatInt( "camo_skin91", "tone", 150, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_sticky_40mm" )

	InitUnlockForStatInt( "camo_skin56", "legion", 5, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_predator_cannon" )
	InitUnlockForStatInt( "camo_skin58", "legion", 15, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_predator_cannon" )
	InitUnlockForStatInt( "camo_skin55", "legion", 30, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_predator_cannon" )
	InitUnlockForStatInt( "camo_skin57", "legion", 75, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_predator_cannon" )
	InitUnlockForStatInt( "camo_skin91", "legion", 150, "weapon_kill_stats", "assistsTotal", "mp_titanweapon_predator_cannon" )

	//Titan damage for weapon
	InitUnlockForStatInt( "camo_skin93", "ion", 50000, "weapon_stats", "titanDamage", "mp_titanweapon_particle_accelerator" )
	InitUnlockForStatInt( "camo_skin94", "ion", 100000, "weapon_stats", "titanDamage", "mp_titanweapon_particle_accelerator" )
	InitUnlockForStatInt( "camo_skin13", "ion", 250000, "weapon_stats", "titanDamage", "mp_titanweapon_particle_accelerator" )
	InitUnlockForStatInt( "camo_skin07", "ion", 500000, "weapon_stats", "titanDamage", "mp_titanweapon_particle_accelerator" )
	InitUnlockForStatInt( "camo_skin85", "ion", 1000000, "weapon_stats", "titanDamage", "mp_titanweapon_particle_accelerator" )

	InitUnlockForStatInt( "camo_skin93", "scorch", 50000,  "weapon_stats", "titanDamage", "mp_titanweapon_meteor" )
	InitUnlockForStatInt( "camo_skin94", "scorch", 100000,"weapon_stats", "titanDamage", "mp_titanweapon_meteor" )
	InitUnlockForStatInt( "camo_skin13", "scorch", 250000, "weapon_stats", "titanDamage", "mp_titanweapon_meteor" )
	InitUnlockForStatInt( "camo_skin07", "scorch", 500000, "weapon_stats", "titanDamage", "mp_titanweapon_meteor" )
	InitUnlockForStatInt( "camo_skin85", "scorch", 1000000, "weapon_stats", "titanDamage", "mp_titanweapon_meteor" )

	InitUnlockForStatInt( "camo_skin93", "vanguard", 50000,  "weapon_stats", "titanDamage", "mp_titanweapon_xo16_vanguard" )
	InitUnlockForStatInt( "camo_skin94", "vanguard", 100000,"weapon_stats", "titanDamage", "mp_titanweapon_xo16_vanguard" )
	InitUnlockForStatInt( "camo_skin13", "vanguard", 250000, "weapon_stats", "titanDamage", "mp_titanweapon_xo16_vanguard" )
	InitUnlockForStatInt( "camo_skin07", "vanguard", 500000, "weapon_stats", "titanDamage", "mp_titanweapon_xo16_vanguard" )
	InitUnlockForStatInt( "camo_skin85", "vanguard", 1000000, "weapon_stats", "titanDamage", "mp_titanweapon_xo16_vanguard" )

	InitUnlockForStatInt( "camo_skin93", "northstar", 50000,  "weapon_stats", "titanDamage", "mp_titanweapon_sniper" )
	InitUnlockForStatInt( "camo_skin94", "northstar", 100000,"weapon_stats", "titanDamage", "mp_titanweapon_sniper" )
	InitUnlockForStatInt( "camo_skin13", "northstar", 250000, "weapon_stats", "titanDamage", "mp_titanweapon_sniper" )
	InitUnlockForStatInt( "camo_skin07", "northstar", 500000, "weapon_stats", "titanDamage", "mp_titanweapon_sniper" )
	InitUnlockForStatInt( "camo_skin85", "northstar", 1000000, "weapon_stats", "titanDamage", "mp_titanweapon_sniper" )

	InitUnlockForStatInt( "camo_skin93", "ronin", 50000,  "weapon_stats", "titanDamage", "mp_titanweapon_leadwall" )
	InitUnlockForStatInt( "camo_skin94", "ronin", 100000,"weapon_stats", "titanDamage", "mp_titanweapon_leadwall" )
	InitUnlockForStatInt( "camo_skin13", "ronin", 250000, "weapon_stats", "titanDamage", "mp_titanweapon_leadwall" )
	InitUnlockForStatInt( "camo_skin07", "ronin", 500000, "weapon_stats", "titanDamage", "mp_titanweapon_leadwall" )
	InitUnlockForStatInt( "camo_skin85", "ronin", 1000000, "weapon_stats", "titanDamage", "mp_titanweapon_leadwall" )

	InitUnlockForStatInt( "camo_skin93", "tone", 50000,  "weapon_stats", "titanDamage", "mp_titanweapon_sticky_40mm" )
	InitUnlockForStatInt( "camo_skin94", "tone", 100000,"weapon_stats", "titanDamage", "mp_titanweapon_sticky_40mm" )
	InitUnlockForStatInt( "camo_skin13", "tone", 250000, "weapon_stats", "titanDamage", "mp_titanweapon_sticky_40mm" )
	InitUnlockForStatInt( "camo_skin07", "tone", 500000, "weapon_stats", "titanDamage", "mp_titanweapon_sticky_40mm" )
	InitUnlockForStatInt( "camo_skin85", "tone", 1000000, "weapon_stats", "titanDamage", "mp_titanweapon_sticky_40mm" )

	InitUnlockForStatInt( "camo_skin93", "legion", 100000,  "weapon_stats", "titanDamage", "mp_titanweapon_predator_cannon" )
	InitUnlockForStatInt( "camo_skin94", "legion", 200000,"weapon_stats", "titanDamage", "mp_titanweapon_predator_cannon" )
	InitUnlockForStatInt( "camo_skin13", "legion", 500000, "weapon_stats", "titanDamage", "mp_titanweapon_predator_cannon" )
	InitUnlockForStatInt( "camo_skin07", "legion", 1000000, "weapon_stats", "titanDamage", "mp_titanweapon_predator_cannon" )
	InitUnlockForStatInt( "camo_skin85", "legion", 2000000, "weapon_stats", "titanDamage", "mp_titanweapon_predator_cannon" )

	//////////////////////////
	// DELUXE ENTITLEMENTS
	//////////////////////////
	InitUnlockAsEntitlement( "ion_skin_04", "ion", ET_DELUXE_EDITION )
	InitUnlockAsEntitlement( "scorch_skin_04", "scorch", ET_DELUXE_EDITION )
	InitUnlockAsEntitlement( "northstar_skin_04", "northstar", ET_DELUXE_EDITION )
	InitUnlockAsEntitlement( "tone_skin_04", "tone", ET_DELUXE_EDITION )
	InitUnlockAsEntitlement( "ronin_skin_04", "ronin", ET_DELUXE_EDITION )
	InitUnlockAsEntitlement( "legion_skin_04", "legion", ET_DELUXE_EDITION )

	InitUnlockAsEntitlement( "ion_prime", "", ET_DELUXE_EDITION )
	InitUnlockAsEntitlement( "scorch_prime", "", ET_DELUXE_EDITION )

	InitUnlockAsEntitlement( "ion_nose_art_07", "ion", ET_DELUXE_EDITION )
	InitUnlockAsEntitlement( "scorch_nose_art_07", "scorch", ET_DELUXE_EDITION )
	InitUnlockAsEntitlement( "northstar_nose_art_07", "northstar", ET_DELUXE_EDITION )
	InitUnlockAsEntitlement( "tone_nose_art_10", "tone", ET_DELUXE_EDITION )
	InitUnlockAsEntitlement( "ronin_nose_art_07", "ronin", ET_DELUXE_EDITION )
	InitUnlockAsEntitlement( "legion_nose_art_07", "legion", ET_DELUXE_EDITION )

	for ( int i = 0; i < titanClassEnumCount; i++ )
	{
		string titanClass = PersistenceGetEnumItemNameForIndex( "titanClasses", i )
		if ( titanClass != "" )
		{
			InitUnlockAsEntitlement( "titan_camo_skin10", titanClass, ET_DELUXE_EDITION )
			InitUnlockAsEntitlement( "camo_skin10", titanClass, ET_DELUXE_EDITION )
			InitUnlockAsEntitlement( "titan_camo_skin92", titanClass, ET_DELUXE_EDITION )
			InitUnlockAsEntitlement( "camo_skin92", titanClass, ET_DELUXE_EDITION )
		}
	}

	InitUnlockAsEntitlement( "pilot_camo_skin10", "", ET_DELUXE_EDITION )
	InitUnlockAsEntitlement( "pilot_camo_skin92", "", ET_DELUXE_EDITION )

	foreach ( weaponClassName in pilotWeaponRefs )
	{
		InitUnlockAsEntitlement( "camo_skin10", weaponClassName, ET_DELUXE_EDITION )
		InitUnlockAsEntitlement( "camo_skin92", weaponClassName, ET_DELUXE_EDITION )
	}

	InitUnlockAsEntitlement( "callsign_14_col_gold", "", ET_DELUXE_EDITION )

	//////////////////////////
	// PREORDER ENTITLEMENTS
	//////////////////////////
	InitUnlockAsEntitlement( "mp_angel_city", "", ET_PREORDER )
	InitUnlockAsEntitlement( "angel_city_247", "", ET_PREORDER )
	InitUnlockAsEntitlement( "scorch_skin_03", "scorch", ET_PREORDER )
	InitUnlockAsEntitlement( "scorch_nose_art_06", "scorch", ET_PREORDER )
	InitUnlockAsEntitlement( "callsign_71_col_gold", "", ET_PREORDER )

	//////////////////////////
	// BF1
	//////////////////////////
	InitUnlockAsEntitlement( "ion_skin_06", "ion", ET_BF1 )

	//////////////////////////
	// DLC1
	//////////////////////////
	InitUnlockAsEntitlement( "ion_prime", "", ET_DLC1_PRIME_ION )
	InitUnlockAsEntitlement( "scorch_prime", "", ET_DLC1_PRIME_SCORCH )
	InitUnlockAsEntitlement( "vanguard_prime", "", ET_DLC5_PRIME_TONE ) // TODO: Entitlement is incorrect here

	InitUnlockAsEntitlement( "ion_nose_art_17", "ion", ET_DLC1_ION )
	InitUnlockAsEntitlement( "ion_nose_art_18", "ion", ET_DLC1_ION )
	InitUnlockAsEntitlement( "ion_nose_art_19", "ion", ET_DLC1_ION )
	InitUnlockAsEntitlement( "ion_nose_art_20", "ion", ET_DLC1_ION )
	InitUnlockAsEntitlement( "ion_nose_art_21", "ion", ET_DLC1_ION )
	InitUnlockAsEntitlement( "ion_skin_10", "ion", ET_DLC1_ION, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "scorch_nose_art_15", "scorch", ET_DLC1_SCORCH )
	InitUnlockAsEntitlement( "scorch_nose_art_16", "scorch", ET_DLC1_SCORCH )
	InitUnlockAsEntitlement( "scorch_nose_art_17", "scorch", ET_DLC1_SCORCH )
	InitUnlockAsEntitlement( "scorch_nose_art_18", "scorch", ET_DLC1_SCORCH )
	InitUnlockAsEntitlement( "scorch_nose_art_19", "scorch", ET_DLC1_SCORCH )
	InitUnlockAsEntitlement( "scorch_skin_07", "scorch", ET_DLC1_SCORCH, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "ronin_nose_art_16", "ronin", ET_DLC1_RONIN )
	InitUnlockAsEntitlement( "ronin_nose_art_17", "ronin", ET_DLC1_RONIN )
	InitUnlockAsEntitlement( "ronin_nose_art_18", "ronin", ET_DLC1_RONIN )
	InitUnlockAsEntitlement( "ronin_nose_art_19", "ronin", ET_DLC1_RONIN )
	InitUnlockAsEntitlement( "ronin_nose_art_20", "ronin", ET_DLC1_RONIN )
	InitUnlockAsEntitlement( "ronin_skin_10", "ronin", ET_DLC1_RONIN, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "tone_nose_art_17", "tone", ET_DLC1_TONE )
	InitUnlockAsEntitlement( "tone_nose_art_18", "tone", ET_DLC1_TONE )
	InitUnlockAsEntitlement( "tone_nose_art_19", "tone", ET_DLC1_TONE )
	InitUnlockAsEntitlement( "tone_nose_art_20", "tone", ET_DLC1_TONE )
	InitUnlockAsEntitlement( "tone_nose_art_21", "tone", ET_DLC1_TONE )
	InitUnlockAsEntitlement( "tone_skin_06", "tone", ET_DLC1_TONE, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "northstar_nose_art_18", "northstar", ET_DLC1_NORTHSTAR )
	InitUnlockAsEntitlement( "northstar_nose_art_19", "northstar", ET_DLC1_NORTHSTAR )
	InitUnlockAsEntitlement( "northstar_nose_art_20", "northstar", ET_DLC1_NORTHSTAR )
	InitUnlockAsEntitlement( "northstar_nose_art_21", "northstar", ET_DLC1_NORTHSTAR )
	InitUnlockAsEntitlement( "northstar_nose_art_22", "northstar", ET_DLC1_NORTHSTAR )
	InitUnlockAsEntitlement( "northstar_skin_10", "northstar", ET_DLC1_NORTHSTAR, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "legion_nose_art_17", "legion", ET_DLC1_LEGION )
	InitUnlockAsEntitlement( "legion_nose_art_18", "legion", ET_DLC1_LEGION )
	InitUnlockAsEntitlement( "legion_nose_art_19", "legion", ET_DLC1_LEGION )
	InitUnlockAsEntitlement( "legion_nose_art_20", "legion", ET_DLC1_LEGION )
	InitUnlockAsEntitlement( "legion_nose_art_21", "legion", ET_DLC1_LEGION )
	InitUnlockAsEntitlement( "legion_skin_07", "legion", ET_DLC1_LEGION, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "callsign_106_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_107_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_108_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_109_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_110_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_111_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_112_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_113_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_114_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_115_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_116_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_117_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_118_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_119_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_120_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_121_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_122_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_123_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_124_col", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_125_col", "", ET_DLC1_CALLSIGN )

	InitUnlockAsEntitlement( "gc_icon_64", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_aces", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_alien", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_apex", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_ares", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_controller", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_drone", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_heartbreaker", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_hexes", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_kodai", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_lastimosa", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_lawai", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_mcor", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_phoenix", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_pilot", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_robot", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_sentry", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_super_spectre", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_vinson", "", ET_DLC1_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_wonyeon", "", ET_DLC1_CALLSIGN )


	for ( int i = 101; i <= 120; i++ )
	{
		for ( int j = 0; j < titanClassEnumCount; j++ )
		{
			string titanClass = PersistenceGetEnumItemNameForIndex( "titanClasses", j )
			if ( titanClass != "" )
			{
				InitUnlockAsEntitlement( "titan_camo_skin" + i, titanClass, ET_DLC1_CAMO )
				InitUnlockAsEntitlement( "camo_skin" + i, titanClass, ET_DLC1_CAMO )
			}
		}

		InitUnlockAsEntitlement( "pilot_camo_skin" + i, "", ET_DLC1_CAMO )

		foreach ( weaponClassName in pilotWeaponRefs )
		{
			InitUnlockAsEntitlement( "camo_skin" + i, weaponClassName, ET_DLC1_CAMO )
		}
	}

	InitFrontierDefenseUnlocks()

	//////////////////////////
	// DLC3
	//////////////////////////
	InitUnlockAsEntitlement( "legion_prime", "", ET_DLC3_PRIME_LEGION )
	InitUnlockAsEntitlement( "northstar_prime", "", ET_DLC3_PRIME_NORTHSTAR )

	InitUnlockAsEntitlement( "ion_nose_art_22", "ion", ET_DLC3_ION )
	InitUnlockAsEntitlement( "ion_nose_art_23", "ion", ET_DLC3_ION )
	InitUnlockAsEntitlement( "ion_nose_art_24", "ion", ET_DLC3_ION )
	InitUnlockAsEntitlement( "ion_nose_art_25", "ion", ET_DLC3_ION )
	InitUnlockAsEntitlement( "ion_nose_art_26", "ion", ET_DLC3_ION )
	InitUnlockAsEntitlement( "ion_skin_11", "ion", ET_DLC3_ION, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "scorch_nose_art_20", "scorch", ET_DLC3_SCORCH )
	InitUnlockAsEntitlement( "scorch_nose_art_21", "scorch", ET_DLC3_SCORCH )
	InitUnlockAsEntitlement( "scorch_nose_art_22", "scorch", ET_DLC3_SCORCH )
	InitUnlockAsEntitlement( "scorch_nose_art_23", "scorch", ET_DLC3_SCORCH )
	InitUnlockAsEntitlement( "scorch_nose_art_24", "scorch", ET_DLC3_SCORCH )
	InitUnlockAsEntitlement( "scorch_skin_08", "scorch", ET_DLC3_SCORCH, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "ronin_nose_art_21", "ronin", ET_DLC3_RONIN )
	InitUnlockAsEntitlement( "ronin_nose_art_22", "ronin", ET_DLC3_RONIN )
	InitUnlockAsEntitlement( "ronin_nose_art_23", "ronin", ET_DLC3_RONIN )
	InitUnlockAsEntitlement( "ronin_nose_art_24", "ronin", ET_DLC3_RONIN )
	InitUnlockAsEntitlement( "ronin_nose_art_25", "ronin", ET_DLC3_RONIN )
	InitUnlockAsEntitlement( "ronin_skin_11", "ronin", ET_DLC3_RONIN, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "tone_nose_art_22", "tone", ET_DLC3_TONE )
	InitUnlockAsEntitlement( "tone_nose_art_23", "tone", ET_DLC3_TONE )
	InitUnlockAsEntitlement( "tone_nose_art_24", "tone", ET_DLC3_TONE )
	InitUnlockAsEntitlement( "tone_nose_art_25", "tone", ET_DLC3_TONE )
	InitUnlockAsEntitlement( "tone_nose_art_26", "tone", ET_DLC3_TONE )
	InitUnlockAsEntitlement( "tone_skin_07", "tone", ET_DLC3_TONE, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "northstar_nose_art_23", "northstar", ET_DLC3_NORTHSTAR )
	InitUnlockAsEntitlement( "northstar_nose_art_24", "northstar", ET_DLC3_NORTHSTAR )
	InitUnlockAsEntitlement( "northstar_nose_art_25", "northstar", ET_DLC3_NORTHSTAR )
	InitUnlockAsEntitlement( "northstar_nose_art_26", "northstar", ET_DLC3_NORTHSTAR )
	InitUnlockAsEntitlement( "northstar_nose_art_27", "northstar", ET_DLC3_NORTHSTAR )
	InitUnlockAsEntitlement( "northstar_skin_11", "northstar", ET_DLC3_NORTHSTAR, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "legion_nose_art_22", "legion", ET_DLC3_LEGION )
	InitUnlockAsEntitlement( "legion_nose_art_23", "legion", ET_DLC3_LEGION )
	InitUnlockAsEntitlement( "legion_nose_art_24", "legion", ET_DLC3_LEGION )
	InitUnlockAsEntitlement( "legion_nose_art_25", "legion", ET_DLC3_LEGION )
	InitUnlockAsEntitlement( "legion_nose_art_26", "legion", ET_DLC3_LEGION )
	InitUnlockAsEntitlement( "legion_skin_08", "legion", ET_DLC3_LEGION, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "gc_icon_balance", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_boot", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_bt_eye", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_buzzsaw", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_crossed_lighting", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_flying_bullet", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_hammer2", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_keyboard", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_lightbulb", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_narwhal", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_peace", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_pilot2", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_robot_eye", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_srs", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_starline", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_taco", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_thumbdown", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_thumbup", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_treble", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_vanguard", "", ET_DLC3_CALLSIGN )

	for ( int i = 121; i <= 140; i++ )
	{
		for ( int j = 0; j < titanClassEnumCount; j++ )
		{
			string titanClass = PersistenceGetEnumItemNameForIndex( "titanClasses", j )
			if ( titanClass != "" )
			{
				InitUnlockAsEntitlement( "titan_camo_skin" + i, titanClass, ET_DLC3_CAMO )
				InitUnlockAsEntitlement( "camo_skin" + i, titanClass, ET_DLC3_CAMO )
			}
		}

		InitUnlockAsEntitlement( "pilot_camo_skin" + i, "", ET_DLC3_CAMO )

		foreach ( weaponClassName in pilotWeaponRefs )
		{
			InitUnlockAsEntitlement( "camo_skin" + i, weaponClassName, ET_DLC3_CAMO )
		}
	}

	InitUnlockAsEntitlement( "callsign_143_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_144_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_145_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_146_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_147_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_148_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_149_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_150_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_151_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_152_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_153_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_154_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_155_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_156_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_157_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_158_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_159_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_160_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_161_col", "", ET_DLC3_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_162_col", "", ET_DLC3_CALLSIGN )

	//////////////////////////
	// DLC5
	//////////////////////////
	InitUnlockAsEntitlement( "tone_prime", "", ET_DLC5_PRIME_TONE )
	InitUnlockAsEntitlement( "ronin_prime", "", ET_DLC5_PRIME_RONIN )

	InitUnlockAsEntitlement( "ion_nose_art_27", "ion", ET_DLC5_ION )
	InitUnlockAsEntitlement( "ion_nose_art_28", "ion", ET_DLC5_ION )
	InitUnlockAsEntitlement( "ion_nose_art_29", "ion", ET_DLC5_ION )
	InitUnlockAsEntitlement( "ion_nose_art_30", "ion", ET_DLC5_ION )
	InitUnlockAsEntitlement( "ion_nose_art_31", "ion", ET_DLC5_ION )
	InitUnlockAsEntitlement( "ion_skin_07", "ion", ET_DLC5_ION, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "scorch_nose_art_25", "scorch", ET_DLC5_SCORCH )
	InitUnlockAsEntitlement( "scorch_nose_art_26", "scorch", ET_DLC5_SCORCH )
	InitUnlockAsEntitlement( "scorch_nose_art_27", "scorch", ET_DLC5_SCORCH )
	InitUnlockAsEntitlement( "scorch_nose_art_28", "scorch", ET_DLC5_SCORCH )
	InitUnlockAsEntitlement( "scorch_nose_art_29", "scorch", ET_DLC5_SCORCH )
	InitUnlockAsEntitlement( "scorch_skin_06", "scorch", ET_DLC5_SCORCH, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "ronin_nose_art_26", "ronin", ET_DLC5_RONIN )
	InitUnlockAsEntitlement( "ronin_nose_art_27", "ronin", ET_DLC5_RONIN )
	InitUnlockAsEntitlement( "ronin_nose_art_28", "ronin", ET_DLC5_RONIN )
	InitUnlockAsEntitlement( "ronin_nose_art_29", "ronin", ET_DLC5_RONIN )
	InitUnlockAsEntitlement( "ronin_nose_art_30", "ronin", ET_DLC5_RONIN )
	InitUnlockAsEntitlement( "ronin_skin_07", "ronin", ET_DLC5_RONIN, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "tone_nose_art_27", "tone", ET_DLC5_TONE )
	InitUnlockAsEntitlement( "tone_nose_art_28", "tone", ET_DLC5_TONE )
	InitUnlockAsEntitlement( "tone_nose_art_29", "tone", ET_DLC5_TONE )
	InitUnlockAsEntitlement( "tone_nose_art_30", "tone", ET_DLC5_TONE )
	InitUnlockAsEntitlement( "tone_nose_art_31", "tone", ET_DLC5_TONE )
	InitUnlockAsEntitlement( "tone_skin_08", "tone", ET_DLC5_TONE, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "northstar_nose_art_28", "northstar", ET_DLC5_NORTHSTAR )
	InitUnlockAsEntitlement( "northstar_nose_art_29", "northstar", ET_DLC5_NORTHSTAR )
	InitUnlockAsEntitlement( "northstar_nose_art_30", "northstar", ET_DLC5_NORTHSTAR )
	InitUnlockAsEntitlement( "northstar_nose_art_31", "northstar", ET_DLC5_NORTHSTAR )
	InitUnlockAsEntitlement( "northstar_nose_art_32", "northstar", ET_DLC5_NORTHSTAR )
	InitUnlockAsEntitlement( "northstar_skin_06", "northstar", ET_DLC5_NORTHSTAR, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "legion_nose_art_27", "legion", ET_DLC5_LEGION )
	InitUnlockAsEntitlement( "legion_nose_art_28", "legion", ET_DLC5_LEGION )
	InitUnlockAsEntitlement( "legion_nose_art_29", "legion", ET_DLC5_LEGION )
	InitUnlockAsEntitlement( "legion_nose_art_30", "legion", ET_DLC5_LEGION )
	InitUnlockAsEntitlement( "legion_nose_art_31", "legion", ET_DLC5_LEGION )
	InitUnlockAsEntitlement( "legion_skin_09", "legion", ET_DLC5_LEGION, "StoreMenu_Customization" )

	InitUnlockAsEntitlement( "gc_icon_monarch_dlc5", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_militia", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_militia_alt", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_imc", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_hammond", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_tri_chevron", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_pilot_circle", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_x", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_nessie", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_spicy", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_crown", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_pawn", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_excite", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_duck", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_sock", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_rabbit", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_peanut", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_clock", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_shamrock", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "gc_icon_trident", "", ET_DLC5_CALLSIGN )

	for ( int i = 141; i <= 160; i++ )
	{
		for ( int j = 0; j < titanClassEnumCount; j++ )
		{
			string titanClass = PersistenceGetEnumItemNameForIndex( "titanClasses", j )
			if ( titanClass != "" )
			{
				InitUnlockAsEntitlement( "titan_camo_skin" + i, titanClass, ET_DLC5_CAMO )
				InitUnlockAsEntitlement( "camo_skin" + i, titanClass, ET_DLC5_CAMO )
			}
		}

		InitUnlockAsEntitlement( "pilot_camo_skin" + i, "", ET_DLC5_CAMO )

		foreach ( weaponClassName in pilotWeaponRefs )
		{
			InitUnlockAsEntitlement( "camo_skin" + i, weaponClassName, ET_DLC5_CAMO )
		}
	}

	InitUnlockAsEntitlement( "callsign_166_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_167_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_168_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_169_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_170_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_171_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_172_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_173_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_174_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_175_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_176_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_177_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_178_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_179_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_180_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_181_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_182_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_183_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_184_col", "", ET_DLC5_CALLSIGN )
	InitUnlockAsEntitlement( "callsign_185_col", "", ET_DLC5_CALLSIGN )

	InitUnlockAsEntitlement( "skin_rspn101_wasteland", "mp_weapon_rspn101", ET_DLC7_R201_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_g2_masterwork", "mp_weapon_g2", ET_DLC7_G2A5_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_vinson_blue_fade", "mp_weapon_vinson", ET_DLC7_FLATLINE_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_car_crimson_fury", "mp_weapon_car", ET_DLC7_CAR_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_alternator_patriot", "mp_weapon_alternator_smg", ET_DLC7_ALTERNATOR_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_shotgun_badlands", "mp_weapon_shotgun", ET_DLC7_EVA8_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_wingman_aqua_fade", "mp_weapon_wingman", ET_DLC7_WINGMAN_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_rocket_launcher_psych_spectre", "mp_weapon_rocket_launcher", ET_DLC7_ARCHER_WARPAINT, "StoreMenu_WeaponSkins" )

	InitUnlockAsEntitlement( "ion_skin_fd", "ion", ET_DLC7_ION_WARPAINT )
	InitUnlockAsEntitlement( "scorch_skin_fd", "scorch", ET_DLC7_SCORCH_WARPAINT )
	InitUnlockAsEntitlement( "northstar_skin_fd", "northstar", ET_DLC7_NORTHSTAR_WARPAINT )
	InitUnlockAsEntitlement( "ronin_skin_fd", "ronin", ET_DLC7_RONIN_WARPAINT )
	InitUnlockAsEntitlement( "tone_skin_fd", "tone", ET_DLC7_TONE_WARPAINT )
	InitUnlockAsEntitlement( "legion_skin_fd", "legion", ET_DLC7_LEGION_WARPAINT )
	InitUnlockAsEntitlement( "monarch_skin_fd", "vanguard", ET_DLC7_MONARCH_WARPAINT )

	InitUnlockAsEntitlement( "callsign_fd_ion_dynamic", "", ET_DLC7_ION_WARPAINT )
	InitUnlockAsEntitlement( "callsign_fd_scorch_dynamic", "", ET_DLC7_SCORCH_WARPAINT )
	InitUnlockAsEntitlement( "callsign_fd_northstar_dynamic", "", ET_DLC7_NORTHSTAR_WARPAINT )
	InitUnlockAsEntitlement( "callsign_fd_ronin_dynamic", "", ET_DLC7_RONIN_WARPAINT )
	InitUnlockAsEntitlement( "callsign_fd_tone_dynamic", "", ET_DLC7_TONE_WARPAINT )
	InitUnlockAsEntitlement( "callsign_fd_legion_dynamic", "", ET_DLC7_LEGION_WARPAINT )
	InitUnlockAsEntitlement( "callsign_fd_monarch_dynamic", "", ET_DLC7_MONARCH_WARPAINT )

	InitUnlock( "callsign_fd_ion_hard", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_ion_master", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_ion_insane", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_tone_hard", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_tone_master", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_tone_insane", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_scorch_hard", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_scorch_master", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_scorch_insane", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_legion_hard", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_legion_master", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_legion_insane", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_ronin_hard", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_ronin_master", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_ronin_insane", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_northstar_hard", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_northstar_master", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_northstar_insane", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_monarch_hard", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_monarch_master", "", eUnlockType.PERSISTENT_ITEM, 0 )
	InitUnlock( "callsign_fd_monarch_insane", "", eUnlockType.PERSISTENT_ITEM, 0 )

	InitUnlockForStatInt( "classic_music", "", 10, "game_stats", "mode_won", "fd" )

	InitUnlockForStatInt( "burnmeter_at_turret_weapon_infinite", "", 2, "fd_stats", "arcMinesPlaced" )
	InitUnlockForStatInt( "burnmeter_ap_turret_weapon_infinite", "", 2, "fd_stats", "arcMinesPlaced" )
	InitUnlockForStatInt( "burnmeter_rodeo_grenade", "", 3, "fd_stats", "rodeos" )
	InitUnlockForStatInt( "burnmeter_harvester_shield", "", 3, "fd_stats", "wavesComplete" )

	InitUnlockAsEntitlement( "skin_rspn101_patriot", "mp_weapon_rspn101", ET_DLC8_R201_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_hemlok_mochi", "mp_weapon_hemlok", ET_DLC8_HEMLOK_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_r97_purple_fade", "mp_weapon_r97", ET_DLC8_R97_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_kraber_masterwork", "mp_weapon_sniper", ET_DLC8_KRABER_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_spitfire_lead_farmer", "mp_weapon_lmg", ET_DLC8_SPITFIRE_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_devotion_rspn_customs", "mp_weapon_esaw", ET_DLC8_DEVOTION_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_mozambique_crimson_fury", "mp_weapon_shotgun_pistol", ET_DLC8_MOZAMBIQUE_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_thunderbolt_8bit", "mp_weapon_arc_launcher", ET_DLC8_THUNDERBOLT_WARPAINT, "StoreMenu_WeaponSkins" )

	InitUnlockAsEntitlement( "skin_lstar_heatsink", "mp_weapon_lstar", ET_DLC9_LSTAR_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_mastiff_crimson_fury", "mp_weapon_mastiff", ET_DLC9_MASTIFF_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_sidewinder_masterwork", "mp_weapon_smr", ET_DLC9_SIDEWINDER_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_rspn101_halloween", "mp_weapon_rspn101", ET_DLC9_R201_WARPAINT )
	InitUnlockAsEntitlement( "skin_car_halloween", "mp_weapon_car", ET_DLC9_CAR_WARPAINT )
	InitUnlockAsEntitlement( "skin_spitfire_halloween", "mp_weapon_lmg", ET_DLC9_SPITFIRE_WARPAINT )

	InitUnlockAsEntitlement( "skin_rspn101_og_blue_fade", "mp_weapon_rspn101_og", ET_DLC10_R101_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_vinson_badlands", "mp_weapon_vinson", ET_DLC10_FLATLINE_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_volt_heatsink", "mp_weapon_hemlok_smg", ET_DLC10_VOLT_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_alternator_headhunter", "mp_weapon_alternator_smg", ET_DLC10_ALTERNATOR_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_softball_masterwork", "mp_weapon_softball", ET_DLC10_SOFTBALL_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_epg_mrvn", "mp_weapon_epg", ET_DLC10_EPG1_WARPAINT, "StoreMenu_WeaponSkins" )

	InitUnlockAsEntitlement( "skin_dmr_phantom", "mp_weapon_dmr", ET_DLC11_DMR_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_doubletake_masterwork", "mp_weapon_doubletake", ET_DLC11_DOUBLETAKE_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_g2_purple_fade", "mp_weapon_g2", ET_DLC11_G2A5_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_coldwar_heatsink", "mp_weapon_pulse_lmg", ET_DLC11_COLDWAR_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_r97_sky", "mp_weapon_r97", ET_DLC11_R97_WARPAINT, "StoreMenu_WeaponSkins" )
	InitUnlockAsEntitlement( "skin_rspn101_crimson_fury", "mp_weapon_rspn101", ET_DLC11_R101_WARPAINT, "StoreMenu_WeaponSkins" )

	array<ItemData> burnMeterRewards = GetAllItemsOfType( eItemTypes.BURN_METER_REWARD )
	foreach ( ItemData item in burnMeterRewards )
	{
		if ( !IsUnlockValid( item.ref ) )
			InitUnlock( item.ref, "", eUnlockType.PLAYER_LEVEL, 1 )
	}

	#if DEV && SERVER && DEVSCRIPTS
		array<string> ignoreList = [ "titanos_ronin",
									 "mp_titanweapon_vortex_shield",
									 "mp_titanweapon_rocketeer_rocketstream",
									 "melee_pilot_arena",
									 "mp_titanweapon_shoulder_rockets",
									 "mp_titancore_dash_core",
									 "mp_titanability_smoke",
									 "melee_pilot_sword",
									 "mp_titanweapon_salvo_rockets",
									 "mp_titancore_amp_core",
									 "advocate_gift",
			                         "random",
									 "default",
									 "mp_titanability_rocketeer_ammo_swap",
									 "titanos_scorch",
									 "double_xp",
									 "titanos_ion",
									 "fnf",
									 "melee_pilot_emptyhanded",
									 "mp_titanweapon_homing_rockets",
									 "private_match",
									 "credit_award_5x",
									 "titanos_bt",
									 "mp_titanweapon_xo16_shorty",
									 "titanos_northstar",
									 "titanos_tone",
									 "titanos_legion",
									 "titanos_vanguard",
									 "varietypack",
									 "mp_titanweapon_stun_laser",
									 "mp_titanability_rearm",
									 "mp_titancore_upgrade",
			"ronin.pas_vanguard_core8",
			"ronin.pas_vanguard_core9",
			"ronin.pas_vanguard_core2",
			"ronin.pas_vanguard_core5",
			"ronin.pas_vanguard_core3",
			"ronin.pas_vanguard_core6",
			"ion.pas_vanguard_core8",
			"ion.pas_vanguard_core6",
			"ion.pas_vanguard_core9",
			"ion.pas_vanguard_core2",
			"ion.pas_vanguard_core5",
			"ion.pas_vanguard_core3",
			"legion.pas_vanguard_core8",
			"legion.pas_vanguard_core9",
			"legion.pas_vanguard_core2",
			"legion.pas_vanguard_core5",
			"legion.pas_vanguard_core6",
			"legion.pas_vanguard_core3",
			"scorch.pas_vanguard_core8",
			"scorch.pas_vanguard_core6",
			"scorch.pas_vanguard_core9",
			"scorch.pas_vanguard_core2",
			"scorch.pas_vanguard_core5",
			"scorch.pas_vanguard_core3",
			"tone.pas_vanguard_core8",
			"tone.pas_vanguard_core9",
			"tone.pas_vanguard_core2",
			"tone.pas_vanguard_core5",
			"tone.pas_vanguard_core6",
			"tone.pas_vanguard_core3",
			"northstar.pas_vanguard_core8",
			"northstar.pas_vanguard_core9",
			"northstar.pas_vanguard_core2",
			"northstar.pas_vanguard_core5",
			"northstar.pas_vanguard_core3",
			"northstar.pas_vanguard_core6",		]

		foreach ( item in file.itemData )
		{
			if ( ignoreList.contains( item.ref ) )
				continue

			if ( IsSubItemType( GetItemType( item.ref ) ) )
				continue

			if ( item.ref in file.entitlementUnlocks )
				continue

			if ( IsDisabledRef( item.ref  ) )
				continue

			if ( ( item.ref in file.unlocks ) || IsItemInRandomUnlocks( item.ref ) )
			{
				foreach ( subItem in item.subitems )
				{
					if ( subItem.ref in file.unlocks[ item.ref ].child || IsItemInRandomUnlocks( subItem.ref, item.ref ) || IsItemInEntitlementUnlock( subItem.ref, item.ref ) )
						continue

					if ( ignoreList.contains( item.ref + "." + subItem.ref ) )
						continue

					CodeWarning( "Not in unlocks " + item.ref + "." + subItem.ref )
				}
			}
			else
			{
				CodeWarning( "Not in unlocks " + item.ref )
			}
		}
	#endif
}

#if SERVER
void function UnlockTarget( entity player )
{
	int titanClassEnumCount = PersistenceGetEnumCount( "titanClasses" )
	array<string> pilotWeaponRefs = GetAllItemRefsOfType( eItemTypes.PILOT_PRIMARY )
	pilotWeaponRefs.extend( GetAllItemRefsOfType( eItemTypes.PILOT_SECONDARY ) )

	//////////////////////////
	// TARGET
	//////////////////////////
	for ( int i = 0; i < titanClassEnumCount; i++ )
	{
		string titanClass = PersistenceGetEnumItemNameForIndex( "titanClasses", i )
		if ( titanClass != "" )
		{
			SetItemOwned( player, "titan_camo_skin08", titanClass, true )
			SetItemOwned( player, "camo_skin08", titanClass, true )
		}
	}

	SetItemOwned( player, "pilot_camo_skin08", "", true )

	foreach ( weaponClassName in pilotWeaponRefs )
	{
		SetItemOwned( player, "camo_skin08", weaponClassName, true )
	}
}

void function ClearTargetNew( entity player )
{
	// early out if we don't own target skins
	if ( !IsItemOwned( player, "pilot_camo_skin08" ) )
		return

	int titanClassEnumCount = PersistenceGetEnumCount( "titanClasses" )
	array<string> pilotWeaponRefs = GetAllItemRefsOfType( eItemTypes.PILOT_PRIMARY )
	pilotWeaponRefs.extend( GetAllItemRefsOfType( eItemTypes.PILOT_SECONDARY ) )

	for ( int i = 0; i < titanClassEnumCount; i++ )
	{
		string titanClass = PersistenceGetEnumItemNameForIndex( "titanClasses", i )
		if ( titanClass != "" )
		{
			if ( IsItemLocked( player, titanClass ) )
			{
				SetItemNewStatus( player, "titan_camo_skin08", titanClass, false  )
				SetItemNewStatus( player, "camo_skin08", titanClass, false  )
			}
		}
	}

	foreach ( weaponClassName in pilotWeaponRefs )
	{
		if ( IsItemLocked( player, weaponClassName ) )
			SetItemNewStatus( player, "camo_skin08", weaponClassName, false )
	}
}

void function FixupLevelCamosForRegen( entity player )
{
	if ( player.GetGen() <= 1 )
		return

	int maxPlayerLevel = GetMaxPlayerLevel()

	array<ItemData> camoSkins = GetAllItemsOfType( eItemTypes.CAMO_SKIN_PILOT )
	foreach ( ItemData camoData in camoSkins )
	{
		if ( IsItemInEntitlementUnlock( camoData.ref ) )
			continue

		if ( IsItemInRandomUnlocks( camoData.ref ) )
			continue

		if ( GetItemUnlockType( camoData.ref ) != eUnlockType.PLAYER_LEVEL )
			continue

		if ( GetUnlockLevelReq( camoData.ref ) > maxPlayerLevel )
			continue

		SetItemOwned( player, camoData.ref, "", false )
	}
}

void function UnlockBWW( entity player )
{
	//////////////////////////
	// BWW
	//////////////////////////
	SetItemOwned( player, "ion_nose_art_05", "ion", true )
}

void function UnlockDEW( entity player )
{
	int titanClassEnumCount = PersistenceGetEnumCount( "titanClasses" )
	array<string> pilotWeaponRefs = GetAllItemRefsOfType( eItemTypes.PILOT_PRIMARY )
	pilotWeaponRefs.extend( GetAllItemRefsOfType( eItemTypes.PILOT_SECONDARY ) )

	//////////////////////////
	// Mountain Dew
	//////////////////////////
	SetItemOwned( player, "execution_face_stab", "", true )
	SetItemOwned( player, "ion_skin_03", "ion", true )
	SetItemOwned( player, "callsign_70_col_gold", "", true )

	for ( int i = 0; i < titanClassEnumCount; i++ )
	{
		string titanClass = PersistenceGetEnumItemNameForIndex( "titanClasses", i )
		if ( titanClass != "" )
		{
			SetItemOwned( player, "titan_camo_skin09", titanClass, true )
			SetItemOwned( player, "camo_skin09", titanClass, true )
		}
	}

	SetItemOwned( player, "pilot_camo_skin09", "", true )

	foreach ( weaponClassName in pilotWeaponRefs )
	{
		SetItemOwned( player, "camo_skin09", weaponClassName, true )
	}
}
#endif

void function InitTitanWeaponDataMP()
{
	////////////////////
	//TITAN WEAPON DATA
	////////////////////

	var dataTable = GetDataTable( $"datatable/titan_primary_weapons.rpak" )
	int numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string itemRef        = GetDataTableString( dataTable, i, TITAN_PRIMARY_COLUMN )
		bool hidden            = GetDataTableBool( dataTable, i, TITAN_PRIMARY_HIDDEN_COLUMN )

		if ( IsDisabledRef( itemRef ) )
		    continue

		CreateWeaponData( i, eItemTypes.TITAN_PRIMARY, hidden, itemRef, true, 0 )
	}

	dataTable = GetDataTable( $"datatable/titan_abilities.rpak" )
	numRows = GetDatatableRowCount( dataTable )
	for ( int i = 0; i < numRows; i++ )
	{
		string itemRef        = GetDataTableString( dataTable, i, TITAN_ABILITY_COLUMN )
		int itemType        = eItemTypes[ GetDataTableString( dataTable, i, TITAN_ABILITY_TYPE_COLUMN ) ]
		bool isDamageSource    = GetDataTableBool( dataTable, i, TITAN_ABILITY_DAMAGESOURCE_COLUMN )
		bool hidden            = GetDataTableBool( dataTable, i, TITAN_ABILITY_HIDDEN_COLUMN )

		if ( IsDisabledRef( itemRef ) )
		    continue

		CreateWeaponData( i, itemType, hidden, itemRef, isDamageSource, 0 )
	}
}


void function InitTitanWeaponDataSP()
{
	////////////////////
	//TITAN WEAPON DATA
	////////////////////

	array<TitanLoadoutDef> loadouts = GetAllowedTitanLoadouts()

	var dataTable                            = GetDataTable( $"datatable/titan_abilities.rpak" )
	int abilityColumn                        = GetDataTableColumnByName( dataTable, "itemRef" )
	int abilityTypeColumn                    = GetDataTableColumnByName( dataTable, "type" )
	int isDamageSourceColumn                = GetDataTableColumnByName( dataTable, "damageSource" )

	table<string, bool> loaded

	foreach ( loadoutIndex, loadout in loadouts )
	{
		string itemRef        = loadout.primary
		if ( !(itemRef in loaded) )
		{
			loaded[ itemRef ] <- true
			CreateWeaponData( loadoutIndex, eItemTypes.TITAN_PRIMARY, false, itemRef, true )
		}

		string ability
		int row
		int itemType
		bool isDamageSource

		ability = loadout.coreAbility
		if ( !(ability in loaded) )
		{
			loaded[ ability ] <- true
			row            = GetDataTableRowMatchingStringValue( dataTable, abilityColumn, ability )
			itemType        = eItemTypes[ GetDataTableString( dataTable, row, abilityTypeColumn ) ]
			isDamageSource    = GetDataTableBool( dataTable, row, isDamageSourceColumn )
			CreateWeaponData( row, itemType, false, ability, isDamageSource )
		}

		ability = loadout.special
		if ( !(ability in loaded) )
		{
			loaded[ ability ] <- true
			row            = GetDataTableRowMatchingStringValue( dataTable, abilityColumn, ability )
			itemType        = eItemTypes[ GetDataTableString( dataTable, row, abilityTypeColumn ) ]
			isDamageSource    = GetDataTableBool( dataTable, row, isDamageSourceColumn )
			CreateWeaponData( row, itemType, false, ability, isDamageSource )
		}

		ability = loadout.antirodeo
		if ( !(ability in loaded) )
		{
			loaded[ ability ] <- true
			row            = GetDataTableRowMatchingStringValue( dataTable, abilityColumn, ability )
			itemType        = eItemTypes[ GetDataTableString( dataTable, row, abilityTypeColumn ) ]
			isDamageSource    = GetDataTableBool( dataTable, row, isDamageSourceColumn )
			CreateWeaponData( row, itemType, false, ability, isDamageSource )
		}

		ability = loadout.ordnance
		if ( !(ability in loaded) )
		{
			loaded[ ability ] <- true
			row            = GetDataTableRowMatchingStringValue( dataTable, abilityColumn, ability )
			itemType        = eItemTypes[ GetDataTableString( dataTable, row, abilityTypeColumn ) ]
			isDamageSource    = GetDataTableBool( dataTable, row, isDamageSourceColumn )
			CreateWeaponData( row, itemType, false, ability, isDamageSource )
		}
	}
}

array<string> function SplitAndStripUnlockField( string unlockField )
{
	array<string> unlockArray = split( unlockField, "," )

	foreach ( i, unlock in unlockArray )
	{
		unlockArray[ i ] = strip( unlock )
	}

	return unlockArray
}

void function InitUnlock( string ref, string parentRef, int unlockType, int unlockLevel, int cost = 0, string additionalRef = "" )
{
	if ( ref == "random" )
	{
		if ( unlockType == eUnlockType.FACTION_LEVEL )
			AppendRandomUnlock( unlockType, unlockLevel, additionalRef )
		else
			AppendRandomUnlock( unlockType, unlockLevel, parentRef )
		return
	}

    if ( IsDisabledRef( ref ) || IsDisabledRef( parentRef ) )
        return

	ItemData itemData = GetItemData( ref )

	if ( parentRef == "" )
	{
		Assert( !(ref in file.unlocks), "Duplicate unlock entry " + ref )
		Assert( unlockType == eUnlockType.PLAYER_LEVEL || unlockType == eUnlockType.DISABLED || unlockType == eUnlockType.ENTITLEMENT || unlockType == eUnlockType.PERSISTENT_ITEM || unlockType == eUnlockType.FACTION_LEVEL || unlockType == eUnlockType.FD_UNLOCK_POINTS, "Cannot specify a parentRef for an item that unlocks with player level" )

		Unlock unlock
		unlock.unlockType = unlockType
		unlock.unlockLevel = unlockLevel
		unlock.cost = cost
		unlock.additionalRef = additionalRef

		file.unlocks[ ref ] <- unlock
	}
	else if ( IsSubItemType( itemData.itemType ) )
	{
		Assert( HasSubitem( parentRef, ref ), "Item " + parentRef + " does not have a " + ref + " subitem" )
		ChildUnlock childUnlock
		childUnlock.unlockType = unlockType
		childUnlock.unlockLevel = unlockLevel
		childUnlock.cost = cost
		childUnlock.additionalRef = additionalRef

		//		Assert( !(ref in file.unlocks[parentRef].child) )
		if ( !(parentRef in file.unlocks) )
		{
			//CodeWarning( "Unassigned parent reference: " + parentRef + " for child " + ref )
			Unlock unlock
			unlock.unlockType = eUnlockType.PLAYER_LEVEL
			unlock.unlockLevel = 1

			file.unlocks[ parentRef ] <- unlock
		}

		#if DEV
			if ( ref in file.unlocks[ parentRef ].child )
				CodeWarning( "Duplicate unlock entry " + parentRef + "." + ref )
			//Assert( !(ref in file.unlocks[ parentRef ].child), "Duplicate unlock entry " + ref )
		#endif

		file.unlocks[ parentRef ].child[ ref ] <- childUnlock
	}
	else
	{
		Assert( !HasSubitem( parentRef, ref ), "Item " + parentRef + " uses " + ref + " as a subitem" )

		Unlock unlock
		unlock.unlockType = unlockType
		unlock.unlockLevel = unlockLevel
		unlock.cost = cost
		unlock.parentRef = parentRef
		unlock.additionalRef = additionalRef

		file.unlocks[ ref ] <- unlock
	}
}

//int function GetPlayerStatInt( entity player, string category, string alias, string subAlias = "" )

void function InitUnlockForStatInt( string ref, string parentRef, int statValue, string statCategory, string statAlias, string statSubAlias = "" )
{
	Assert ( GetStatVarType( statCategory, statAlias, statSubAlias ) == ePlayerStatType.INT )

    if ( IsDisabledRef( ref ) || IsDisabledRef( parentRef ) )
        return

	if ( parentRef != "" )
	{
		Assert( HasSubitem( parentRef, ref ), "Item " + parentRef + " does not have a " + ref + " subitem" )

		ChildUnlock childUnlock
		childUnlock.unlockType = eUnlockType.STAT
		childUnlock.unlockLevel = 0
		childUnlock.cost = 0
		childUnlock.unlockIntVal = statValue
		childUnlock.unlockFloatVal = -1
		childUnlock.additionalRef = GetStatVar( statCategory, statAlias, statSubAlias )
		childUnlock.additionalData.statCategory <- statCategory
		childUnlock.additionalData.statAlias <- statAlias
		childUnlock.additionalData.statSubAlias <- statSubAlias
		childUnlock.additionalData.statVar <- GetStatVar( statCategory, statAlias, statSubAlias )
		childUnlock.additionalData.statType <- GetStatVarType( statCategory, statAlias, statSubAlias )
		childUnlock.additionalData.statUnlockValue <- statValue

		Assert( parentRef in file.unlocks )

		#if DEV
			if ( ref in file.unlocks[ parentRef ].child )
				CodeWarning( "Duplicate unlock entry " + parentRef + "." + ref )
		#endif

		#if SERVER
			AddStatCallback( statCategory, statAlias, statSubAlias, StatsCallback_SubItemUnlockUpdate, ref + "," + parentRef )
		#endif

		file.unlocks[ parentRef ].child[ ref ] <- childUnlock
	}
	else
	{
		Unlock unlock
		unlock.unlockType = eUnlockType.STAT
		unlock.parentRef = parentRef
		unlock.unlockLevel = 0
		unlock.cost = 0
		unlock.unlockIntVal = statValue
		unlock.unlockFloatVal = -1
		unlock.additionalRef = GetStatVar( statCategory, statAlias, statSubAlias )
		unlock.additionalData.statCategory <- statCategory
		unlock.additionalData.statAlias <- statAlias
		unlock.additionalData.statSubAlias <- statSubAlias
		unlock.additionalData.statVar <- GetStatVar( statCategory, statAlias, statSubAlias )
		unlock.additionalData.statType <- GetStatVarType( statCategory, statAlias, statSubAlias )
		unlock.additionalData.statUnlockValue <- statValue

		#if SERVER
			AddStatCallback( statCategory, statAlias, statSubAlias, StatsCallback_ItemUnlockUpdate, ref )
		#endif

		file.unlocks[ ref ] <- unlock
	}
}

void function InitUnlockForStatFloat( string ref, string parentRef, float statValue, string statCategory, string statAlias, string statSubAlias = "" )
{
	Assert ( GetStatVarType( statCategory, statAlias, statSubAlias ) == ePlayerStatType.FLOAT )

    if ( IsDisabledRef( ref ) || IsDisabledRef( parentRef ) )
        return

	if ( parentRef != "" )
	{
		Assert( HasSubitem( parentRef, ref ), "Item " + parentRef + " does not have a " + ref + " subitem" )

		ChildUnlock childUnlock
		childUnlock.unlockType = eUnlockType.STAT
		childUnlock.unlockLevel = 0
		childUnlock.cost = 0
		childUnlock.unlockIntVal = -1
		childUnlock.unlockFloatVal = statValue
		childUnlock.additionalRef = GetStatVar( statCategory, statAlias, statSubAlias )
		childUnlock.additionalData.statCategory <- statCategory
		childUnlock.additionalData.statAlias <- statAlias
		childUnlock.additionalData.statSubAlias <- statSubAlias
		childUnlock.additionalData.statVar <- GetStatVar( statCategory, statAlias, statSubAlias )
		childUnlock.additionalData.statType <- GetStatVarType( statCategory, statAlias, statSubAlias )
		childUnlock.additionalData.statUnlockValue <- statValue

		Assert( parentRef in file.unlocks )

		#if DEV
			if ( ref in file.unlocks[ parentRef ].child )
				CodeWarning( "Duplicate unlock entry " + parentRef + "." + ref )
		#endif

		#if SERVER
			AddStatCallback( statCategory, statAlias, statSubAlias, StatsCallback_SubItemUnlockUpdate, ref + "," + parentRef )
		#endif

		file.unlocks[ parentRef ].child[ ref ] <- childUnlock
	}
	else
	{
		Unlock unlock
		unlock.unlockType = eUnlockType.STAT
		unlock.parentRef = parentRef
		unlock.unlockLevel = 0
		unlock.cost = 0
		unlock.unlockIntVal = -1
		unlock.unlockFloatVal = statValue
		unlock.additionalRef = GetStatVar( statCategory, statAlias, statSubAlias )
		unlock.additionalData.statCategory <- statCategory
		unlock.additionalData.statAlias <- statAlias
		unlock.additionalData.statSubAlias <- statSubAlias
		unlock.additionalData.statVar <- GetStatVar( statCategory, statAlias, statSubAlias )
		unlock.additionalData.statType <- GetStatVarType( statCategory, statAlias, statSubAlias )
		unlock.additionalData.statUnlockValue <- statValue

		#if SERVER
			AddStatCallback( statCategory, statAlias, statSubAlias, StatsCallback_ItemUnlockUpdate, ref )
		#endif

		file.unlocks[ ref ] <- unlock
	}
}

ItemData function CreateBaseItemData( int itemType, string ref, bool hidden )
{
	Assert( ref == ref.tolower() )
	Assert( !(ref in file.itemData), "Already defined item ref " + ref )

	GlobalItemRef globalItemRef
	globalItemRef.ref = ref
	globalItemRef.itemType = itemType
	globalItemRef.hidden = hidden
	globalItemRef.guid = StringHash( ref )
	file.allItems.append( globalItemRef )
	file.itemRefToGuid[ref] <- globalItemRef.guid
	Assert( !(globalItemRef.guid in file.guidToItemRef), "duplicate hash for refs " + file.guidToItemRef[globalItemRef.guid] + " and " + ref )
	file.guidToItemRef[globalItemRef.guid] <- ref

	ItemData item
	item.itemType = itemType
	item.ref = ref
	item.hidden = hidden

	file.itemData[ref] <- item
	file.itemsOfType[ itemType ].append( ref )

	file.globalItemRefsOfType[ itemType ].append( globalItemRef )

	return item
}

void function CreatePrimeTitanData( int itemType, string ref, string nonPrimeRef, bool hidden )
{
	ItemData item = CreateBaseItemData( itemType, ref, hidden )
	item.persistenceStruct		= GetItemPersistenceStruct( nonPrimeRef )
	item.persistenceId          = GetItemPersistenceId( nonPrimeRef )
}

void function CreateWeaponData( int dataTableIndex, int itemType, bool hidden, string ref, bool isDamageSource, int cost = 0 )
{
	#if !UI
		#if SERVER || CLIENT
			PrecacheWeapon( ref )
		#endif
		PROTO_PrecacheTrapFX( ref )
	#endif

	ItemData item = CreateBaseItemData( itemType, ref, hidden )
	item.name                = expect string( GetWeaponInfoFileKeyField_GlobalNotNull( ref, "shortprintname" ) )
	item.longname			 = expect string( GetWeaponInfoFileKeyField_GlobalNotNull( ref, "printname" ) )
	item.desc                = expect string( GetWeaponInfoFileKeyField_GlobalNotNull( ref, "description" ) )
	item.longdesc            = expect string( GetWeaponInfoFileKeyField_GlobalNotNull( ref, "longdesc" ) )
	item.cost				 = cost

	asset image = GetWeaponInfoFileKeyFieldAsset_Global( ref, "menu_icon" )
	if ( image == $"" )
		image = $"ui/temp"

	item.image = image

	switch ( item.itemType )
	{
		case eItemTypes.PILOT_PRIMARY:
		case eItemTypes.PILOT_SECONDARY:
			string stringVal = GetWeaponInfoFileKeyField_GlobalString( ref, "menu_category" )
			item.i.menuCategory <- MenuCategoryStringToEnumValue( stringVal )

			stringVal = GetWeaponInfoFileKeyField_GlobalString( ref, "menu_anim_class" )
			item.i.menuAnimClass <- MenuAnimClassStringToEnumValue( stringVal )

			item.persistenceStruct = "pilotWeapons[" + dataTableIndex + "]"
			break

		case eItemTypes.PILOT_ORDNANCE:
			item.persistenceStruct = "pilotOffhands[" + dataTableIndex + "]"
			break
		case eItemTypes.PILOT_SPECIAL:
			item.imageAtlas = IMAGE_ATLAS_HUD
			item.persistenceStruct = "pilotOffhands[" + dataTableIndex + "]"
			break

		case eItemTypes.TITAN_PRIMARY:
			item.persistenceStruct = "titanWeapons[" + dataTableIndex + "]"
			break

		case eItemTypes.TITAN_SPECIAL:
		case eItemTypes.TITAN_ANTIRODEO:
		case eItemTypes.TITAN_ORDNANCE:
		case eItemTypes.TITAN_CORE_ABILITY:
			item.imageAtlas = IMAGE_ATLAS_HUD
			item.persistenceStruct = "titanOffhands[" + dataTableIndex + "]"
			break
	}

	item.persistenceId = dataTableIndex

	// some weapons are really abilities and don't have these values
	item.i.statDamage        <- int( GetWeaponInfoFileKeyField_GlobalFloat( ref, "stat_damage" ) ) // TODO: Code makes these float though everywhere expects int
	item.i.statRange            <- int( GetWeaponInfoFileKeyField_GlobalFloat( ref, "stat_range" ) )
	item.i.statAccuracy        <- int( GetWeaponInfoFileKeyField_GlobalFloat( ref, "stat_accuracy" ) )
	item.i.statFireRate        <- int( GetWeaponInfoFileKeyField_GlobalFloat( ref, "stat_rof" ) )
	item.i.statClipSize        <- GetWeaponInfoFileKeyField_GlobalInt( ref, "ammo_clip_size" )

	if ( itemType != eItemTypes.NOT_LOADOUT )
	{
		//UpdateChallengeRewardItems( ref, null, itemType, challengeReq, challengeTier )

		// Register the item itemType so the "bot_loadout" console command auto-complete
		// knows about it. Client only. If this auto-complete breaks then the item
		// itemType enum may be desynced between .nut and C++ source code. See Glenn.
		//#if CLIENT
		//	RegisterItemType( itemType, ref )
		//#endif

		#if SERVER || CLIENT
			if ( isDamageSource )
				RegisterWeaponDamageSourceName( ref, expect string( GetWeaponInfoFileKeyField_GlobalNotNull( ref, "shortprintname" ) ) )
		#endif
	}
}

void function CreatePilotSuitData( int datatableIndex, int itemType, string ref, asset image, int cost = 0 )
{
	ItemData item	= CreateBaseItemData( itemType, ref, false )
	item.image		= image
	item.persistenceId = datatableIndex
	item.cost		= cost

	#if SERVER || CLIENT
	string setFile
	setFile = GetSuitAndGenderBasedSetFile( ref, "race_human_male" )
	PrecacheModel( GetPlayerSettingsAssetForClassName( setFile, "bodymodel" ) )
	PrecacheModel( GetPlayerSettingsAssetForClassName( setFile, "armsmodel" ) )
	PrecacheModel( GetPlayerSettingsAssetForClassName( setFile, "cockpitmodel" ) )

	setFile = GetSuitAndGenderBasedSetFile( ref, "race_human_female" )
	PrecacheModel( GetPlayerSettingsAssetForClassName( setFile, "bodymodel" ) )
	PrecacheModel( GetPlayerSettingsAssetForClassName( setFile, "armsmodel" ) )
	PrecacheModel( GetPlayerSettingsAssetForClassName( setFile, "cockpitmodel" ) )
	#endif
}


#if !UI
void function PROTO_PrecacheTrapFX( ref )
{
	asset trapWarningFriendlyFX = GetWeaponInfoFileKeyFieldAsset_Global( ref, "trap_warning_friendly_fx" )
	if ( trapWarningFriendlyFX != $"" )
		PrecacheParticleSystem( trapWarningFriendlyFX )

	asset trapWarningEnemyFX = GetWeaponInfoFileKeyFieldAsset_Global( ref, "trap_warning_enemy_fx" )
	if ( trapWarningEnemyFX != $"" )
		PrecacheParticleSystem( trapWarningEnemyFX )

	var trapWarningOwnerFX = GetWeaponInfoFileKeyFieldAsset_Global( ref, "trap_warning_owner_fx" )
	if ( trapWarningOwnerFX != $"" )
		PrecacheParticleSystem( trapWarningOwnerFX )
}
#endif

int function GetUnlockLevelReq( string ref )
{
	if ( ref in file.unlocks )
		return file.unlocks[ ref ].unlockLevel

	return 0
}

int function GetUnlockLevelReqWithParent( string ref, string parentRef = "" )
{
	if ( parentRef in file.unlocks )
	{
		if ( ref in file.unlocks[ parentRef ].child )
		return file.unlocks[ parentRef ].child[ ref ].unlockLevel
	}

	return 0
}

bool function ItemDefined( string ref )
{
	return ref in file.itemData
}

ItemData function GetItemData( string ref )
{
	return file.itemData[ref]
}

int function GetItemType( string ref )
{
	return file.itemData[ref].itemType
}

int function GetItemMenuAnimClass( string ref )
{
	return expect int ( file.itemData[ref].i.menuAnimClass )
}

int function GetItemId( string ref )
{
	return file.itemRefToGuid[ref]
}

string function GetItemName( string ref )
{
	return file.itemData[ref].name
}

string function GetItemLongName( string ref )
{
	return file.itemData[ref].longname
}

string function GetItemDescription( string ref )
{
	return file.itemData[ref].desc
}

string function GetItemLongDescription( string ref )
{
	return file.itemData[ref].longdesc
}

bool function IsItemPurchasableEntitlement( string ref, string parentRef = "" )
{
	if ( !IsItemInEntitlementUnlock( ref, parentRef ) )
		return false

	string fullRef = GetFullRef( ref, parentRef )
	Assert( fullRef in file.entitlementUnlocks )

	if ( file.entitlementUnlocks[fullRef].purchaseData.purchaseMenu != "" )
		return true

	return false
}

float function GetStatUnlockStatVal( string ref, string parentRef = "" )
{
	int statType
	string statVar
	string statCategory
	string statAlias
	string statSubAlias
	float statVal

	if ( parentRef != "" )
	{
		ChildUnlock unlock = file.unlocks[ parentRef ].child[ref]
		statType = expect int( unlock.additionalData.statType )
		statVar = expect string( unlock.additionalData.statVar )
		statCategory = expect string( unlock.additionalData.statCategory )
		statAlias = expect string( unlock.additionalData.statAlias )
		statSubAlias = expect string( unlock.additionalData.statSubAlias )

		if ( statType == ePlayerStatType.INT )
			statVal = float( unlock.unlockIntVal )
		else
			statVal = unlock.unlockFloatVal
	}
	else
	{
		Unlock unlock = file.unlocks[ ref ]
		statType = expect int( unlock.additionalData.statType )
		statVar = expect string( unlock.additionalData.statVar )
		statCategory = expect string( unlock.additionalData.statCategory )
		statAlias = expect string( unlock.additionalData.statAlias )
		statSubAlias = expect string( unlock.additionalData.statSubAlias )

		if ( statType == ePlayerStatType.INT )
			statVal = float( unlock.unlockIntVal )
		else
			statVal = unlock.unlockFloatVal
	}

	return statVal
}

#if UI

string function GetPurchasableEntitlementMenu( string ref, string parentRef )
{
	Assert ( IsItemInEntitlementUnlock( ref, parentRef ) )

	string fullRef = GetFullRef( ref, parentRef )
	Assert( fullRef in file.entitlementUnlocks )

	return file.entitlementUnlocks[fullRef].purchaseData.purchaseMenu
}

string function GetItemUnlockReqText( string ref, string parentRef = "", bool alwaysShow = false )
{
	entity player = GetUIPlayer()
	if ( !IsValid( player ) )
		return ""

	if ( IsItemInRandomUnlocks( ref, parentRef ) )
		return "#UNLOCK_RANDOM"

	string unlockReq = ""

	int itemType = GetItemType( ref )
	int unlockType
	int unlockLevel
	bool isUnlocked

	if ( IsSubItemType( itemType ) )
	{
		isUnlocked = !IsSubItemLocked( player, ref, parentRef )
		if ( !IsSubItemLocked( player, ref, parentRef ) && !alwaysShow )
			return ""

		if ( IsItemInEntitlementUnlock( ref, parentRef ) )
		{
			//if ( !isUnlocked && !DevEverythingUnlocked() )
			//	CodeWarning( ref + " needs to be hidden since it's an entitlement unlock" )
			if ( IsItemPurchasableEntitlement( ref, parentRef ) )
				return "#ITEM_TYPE_STORE_PURCHASE"
			else
				return ""
		}

		unlockType = GetSubItemUnlockType( ref, parentRef )
		unlockLevel = GetUnlockLevelReqWithParent( ref, parentRef )
	}
	else
	{
		isUnlocked = !IsItemLocked( player, ref )
		if ( !IsItemLocked( player, ref ) && !alwaysShow )
			return ""

		if ( IsItemInEntitlementUnlock( ref ) )
		{
			//if ( !isUnlocked && !DevEverythingUnlocked() )
			//CodeWarning( ref + " needs to be hidden since it's an entitlement unlock" )
			if ( IsItemPurchasableEntitlement( ref ) )
				return "#ITEM_TYPE_STORE_PURCHASE"
			else
				return ""
		}

		unlockType = GetItemUnlockType( ref )
		unlockLevel = GetUnlockLevelReq( ref )
	}

	switch ( unlockType )
	{
		case eUnlockType.PLAYER_LEVEL:
			int gen = player.GetGen()
			string level = PlayerXPDisplayGenAndLevelForRawLevel( unlockLevel )
			if ( gen <= 1 && unlockLevel > GetMaxPlayerLevel() )
			{
				unlockReq = Localize( "#UNLOCK_PLAYER_LEVEL_REGEN" )
			}
			else
			{
				if ( isUnlocked )
					unlockReq = Localize( "#UNLOCKED_PLAYER_LEVEL", level )
				else
					unlockReq = Localize( "#UNLOCK_PLAYER_LEVEL", level )
			}
			break

		case eUnlockType.TITAN_LEVEL:
			if ( parentRef == "" )
			{
				Assert( ref in file.unlocks )
				Assert( file.unlocks[ ref ].parentRef != "" )
				parentRef = file.unlocks[ ref ].parentRef
			}

			string level = TitanGetDisplayGenAndLevelForRawLevel( unlockLevel )
			if ( TitanGetGen( player, parentRef ) <= 1 && unlockLevel > TitanGetMaxLevel( parentRef ) )
			{
				unlockReq = Localize( "#UNLOCK_TITAN_LEVEL_REGEN", Localize( GetItemName( parentRef ) ) )
			}
			else
			{
				if ( isUnlocked )
					unlockReq = Localize( "#UNLOCKED_TITAN_LEVEL", Localize( GetItemName( parentRef ) ), level )
				else
					unlockReq = Localize( "#UNLOCK_TITAN_LEVEL", Localize( GetItemName( parentRef ) ), level )
			}

			break

		case eUnlockType.FD_UNLOCK_POINTS:
			if ( parentRef == "" )
			{
				Assert( ref in file.unlocks )
				Assert( file.unlocks[ ref ].parentRef != "" )
				parentRef = file.unlocks[ ref ].parentRef
			}

			if ( isUnlocked )
				unlockReq = Localize( "#UNLOCKED_FD_LEVEL", Localize( GetItemName( parentRef ) ), unlockLevel )
			else
				unlockReq = Localize( "#UNLOCK_FD_LEVEL", Localize( GetItemName( parentRef ) ), unlockLevel )
			break


		case eUnlockType.WEAPON_LEVEL:
			if ( parentRef == "" )
			{
				Assert( ref in file.unlocks )
				Assert( file.unlocks[ ref ].parentRef != "" )
				parentRef = file.unlocks[ ref ].parentRef
			}

			string level = WeaponGetDisplayGenAndLevelForRawLevel( unlockLevel )
			if ( WeaponGetGen( player, parentRef ) <= 1 && unlockLevel > WeaponGetMaxLevel( parentRef ) )
			{
				unlockReq = Localize( "#UNLOCK_WEAPON_LEVEL_REGEN", Localize( GetItemName( parentRef ) ) )
			}
			else
			{
				if ( isUnlocked )
					unlockReq = Localize( "#UNLOCKED_WEAPON_LEVEL", Localize( GetItemName( parentRef ) ), level )
				else
					unlockReq = Localize( "#UNLOCK_WEAPON_LEVEL", Localize( GetItemName( parentRef ) ), level )
			}
			break

		case eUnlockType.FACTION_LEVEL:
			string level = FactionGetDisplayGenAndLevelForRawLevel( unlockLevel )

			string factionRef
			string factionName
			if ( IsSubItemType( itemType ) )
				factionRef = file.unlocks[ parentRef ].child[ ref ].additionalRef
			else
				factionRef = file.unlocks[ ref ].additionalRef

			factionName = Localize( file.itemData[factionRef].name )
			if ( FactionGetGen( player, factionRef ) <= 1 && unlockLevel > FactionGetMaxLevel( factionRef ) )
			{
				unlockReq = Localize( "#UNLOCK_FACTION_LEVEL_REGEN", factionName )
			}
			else
			{
				if ( isUnlocked )
					unlockReq = Localize( "#UNLOCKED_FACTION_LEVEL", factionName, level )
				else
					unlockReq = Localize( "#UNLOCK_FACTION_LEVEL", factionName, level )
			}
			break

		case eUnlockType.STAT:
			unlockReq = GetStatUnlockReq( ref, parentRef )
			break
	}

	return unlockReq
}

string function GetUnlockProgressText( string ref, string parentRef = "" )
{
	entity player = GetUIPlayer()
	if ( !IsValid( player ) )
		return ""

	if ( IsItemInRandomUnlocks( ref, parentRef ) )
		return ""

	int itemType = GetItemType( ref )
	int unlockType
	int unlockLevel

	if ( IsSubItemType( itemType ) )
	{
		if ( !IsSubItemLocked( player, ref, parentRef ) )
			return ""

		if ( IsItemInEntitlementUnlock( ref, parentRef ) )
			return ""

		unlockType = GetSubItemUnlockType( ref, parentRef )
		unlockLevel = GetUnlockLevelReqWithParent( ref, parentRef )
	}
	else
	{
		if ( !IsItemLocked( player, ref ) )
			return ""

		if ( IsItemInEntitlementUnlock( ref ) )
			return ""

		unlockType = GetItemUnlockType( ref )
		unlockLevel = GetUnlockLevelReq( ref )
	}

	switch ( unlockType )
	{
		case eUnlockType.PLAYER_LEVEL:
		case eUnlockType.TITAN_LEVEL:
		case eUnlockType.WEAPON_LEVEL:
		case eUnlockType.FACTION_LEVEL:
			return ""

		case eUnlockType.STAT:
			return GetStatUnlockProgress( ref, parentRef )
	}

	return ""
}

float function GetUnlockProgressFrac( string ref, string parentRef = "" )
{
	entity player = GetUIPlayer()
	if ( !IsValid( player ) )
		return 0.0

	if ( IsItemInRandomUnlocks( ref, parentRef ) )
		return 0.0

	int itemType = GetItemType( ref )
	int unlockType
	int unlockLevel

	if ( IsSubItemType( itemType ) )
	{
		if ( !IsSubItemLocked( player, ref, parentRef ) )
			return 0.0

		if ( IsItemInEntitlementUnlock( ref, parentRef ) )
			return 0.0

		unlockType = GetSubItemUnlockType( ref, parentRef )
		unlockLevel = GetUnlockLevelReqWithParent( ref, parentRef )
	}
	else
	{
		if ( !IsItemLocked( player, ref ) )
			return 0.0

		if ( IsItemInEntitlementUnlock( ref ) )
			return 0.0

		unlockType = GetItemUnlockType( ref )
		unlockLevel = GetUnlockLevelReq( ref )
	}

	switch ( unlockType )
	{
		case eUnlockType.PLAYER_LEVEL:
		case eUnlockType.TITAN_LEVEL:
		case eUnlockType.WEAPON_LEVEL:
		case eUnlockType.FACTION_LEVEL:
			return 0.0

		case eUnlockType.STAT:
			return GetStatUnlockProgressFrac( ref, parentRef )
	}

	return 0.0
}

string function GetStatUnlockProgress( string ref, string parentRef = "" )
{
	int statType
	string statVar
	string statCategory
	string statAlias
	string statSubAlias
	string statValString
	string statCurString

	entity player = GetUIPlayer()
	if ( !player )
		return ""

	if ( parentRef != "" )
	{
		ChildUnlock unlock = file.unlocks[ parentRef ].child[ref]
		statType = expect int( unlock.additionalData.statType )
		statVar = expect string( unlock.additionalData.statVar )
		statCategory = expect string( unlock.additionalData.statCategory )
		statAlias = expect string( unlock.additionalData.statAlias )
		statSubAlias = expect string( unlock.additionalData.statSubAlias )

		if ( statType == ePlayerStatType.INT )
		{
			statCurString = string( GetPlayerStatInt( player, statCategory, statAlias, statSubAlias ) )
			statValString = string( unlock.unlockIntVal )
		}
		else
		{
			statCurString = format( "%.2f", GetPlayerStatFloat( player, statCategory, statAlias, statSubAlias ) )
			statValString = string( unlock.unlockFloatVal )
		}
	}
	else
	{
		Unlock unlock = file.unlocks[ ref ]
		statType = expect int( unlock.additionalData.statType )
		statVar = expect string( unlock.additionalData.statVar )
		statCategory = expect string( unlock.additionalData.statCategory )
		statAlias = expect string( unlock.additionalData.statAlias )
		statSubAlias = expect string( unlock.additionalData.statSubAlias )

		if ( statType == ePlayerStatType.INT )
		{
			statCurString = string( GetPlayerStatInt( player, statCategory, statAlias, statSubAlias ) )
			statValString = string( unlock.unlockIntVal )
		}
		else
		{
			statCurString = format( "%.2f", GetPlayerStatFloat( player, statCategory, statAlias, statSubAlias ) )
			statValString = string( unlock.unlockFloatVal )
		}
	}

	return statCurString + " / " + statValString
}

float function GetStatUnlockProgressFrac( string ref, string parentRef = "" )
{
	int statType
	string statVar
	string statCategory
	string statAlias
	string statSubAlias

	float statVal
	float statCur

	entity player = GetUIPlayer()
	if ( !player )
		return 0.0

	if ( parentRef != "" )
	{
		ChildUnlock unlock = file.unlocks[ parentRef ].child[ref]
		statType = expect int( unlock.additionalData.statType )
		statVar = expect string( unlock.additionalData.statVar )
		statCategory = expect string( unlock.additionalData.statCategory )
		statAlias = expect string( unlock.additionalData.statAlias )
		statSubAlias = expect string( unlock.additionalData.statSubAlias )

		if ( statType == ePlayerStatType.INT )
		{
			statCur = float( GetPlayerStatInt( player, statCategory, statAlias, statSubAlias ) )
			statVal = float( unlock.unlockIntVal )
		}
		else
		{
			statCur = GetPlayerStatFloat( player, statCategory, statAlias, statSubAlias )
			statVal = unlock.unlockFloatVal
		}
	}
	else
	{
		Unlock unlock = file.unlocks[ ref ]
		statType = expect int( unlock.additionalData.statType )
		statVar = expect string( unlock.additionalData.statVar )
		statCategory = expect string( unlock.additionalData.statCategory )
		statAlias = expect string( unlock.additionalData.statAlias )
		statSubAlias = expect string( unlock.additionalData.statSubAlias )

		if ( statType == ePlayerStatType.INT )
		{
			statCur = float( GetPlayerStatInt( player, statCategory, statAlias, statSubAlias ) )
			statVal = float( unlock.unlockIntVal )
		}
		else
		{
			statCur = GetPlayerStatFloat( player, statCategory, statAlias, statSubAlias )
			statVal = unlock.unlockFloatVal
		}
	}

	return statCur / statVal
}

#endif

#if UI || CLIENT
string function GetStatUnlockReq( string ref, string parentRef = "" )
{
	int statType
	string statVar
	string statCategory
	string statAlias
	string statSubAlias
	string statValString

	if ( parentRef != "" )
	{
		ChildUnlock unlock = file.unlocks[ parentRef ].child[ref]
		statType = expect int( unlock.additionalData.statType )
		statVar = expect string( unlock.additionalData.statVar )
		statCategory = expect string( unlock.additionalData.statCategory )
		statAlias = expect string( unlock.additionalData.statAlias )
		statSubAlias = expect string( unlock.additionalData.statSubAlias )

		if ( statType == ePlayerStatType.INT )
			statValString = string( unlock.unlockIntVal )
		else
			statValString = string( unlock.unlockFloatVal )
	}
	else
	{
		Unlock unlock = file.unlocks[ ref ]
		statType = expect int( unlock.additionalData.statType )
		statVar = expect string( unlock.additionalData.statVar )
		statCategory = expect string( unlock.additionalData.statCategory )
		statAlias = expect string( unlock.additionalData.statAlias )
		statSubAlias = expect string( unlock.additionalData.statSubAlias )

		if ( statType == ePlayerStatType.INT )
			statValString = string( unlock.unlockIntVal )
		else
			statValString = string( unlock.unlockFloatVal )
	}

	string localizedUnlockBase = GetStatVarLocalizedUnlock( statCategory, statAlias, statSubAlias )

	string unlockReq
	if ( statSubAlias != "" )
	{
		ItemData itemData = GetItemData( statSubAlias )
		unlockReq = Localize( localizedUnlockBase, statValString, Localize( itemData.name ) )
	}
	else
	{
		string subString
		if ( parentRef != "" )
		{
			ItemData itemData = GetItemData( parentRef )
			subString = Localize( itemData.name )
		}

		unlockReq = Localize( localizedUnlockBase, statValString, subString )
	}

	return unlockReq
}
#endif

asset function GetItemImage( string ref )
{
	return file.itemData[ref].image
}

vector function GetItemImageAspect( string ref )
{
	vector aspectRatio = <1, 1, 0>

	switch ( GetItemType( ref ) )
	{
		case eItemTypes.PILOT_PRIMARY:
		case eItemTypes.PILOT_SECONDARY:
		case eItemTypes.PILOT_SUIT:
		case eItemTypes.TITAN_PRIMARY:
		case eItemTypes.BURN_METER_REWARD:
			aspectRatio = <2, 1, 0>
			break
		case eItemTypes.CALLSIGN_ICON:
			aspectRatio = <0.64, 1, 0>
			break
		case eItemTypes.CALLING_CARD:
			aspectRatio = <2.25, 1, 0>
			break
		case eItemTypes.FEATURE:
			if ( ref == "coliseum" ) // JFS
				aspectRatio = <2, 1, 0>
			else if ( "isPlaylist" in GetItemData( ref ).i ) // JFS
				aspectRatio = <2, 1, 0>

			break
	}

	return aspectRatio
}

int function GetItemCost( string ref )
{
	return file.itemData[ref].cost
}

int function GetItemStat( string ref, int statType )
{
	Assert( ref in file.itemData )

	int statValue = 0

	switch ( statType )
	{
		case eWeaponStatType.DAMAGE:
			statValue = expect int( file.itemData[ref].i.statDamage )
			break

		case eWeaponStatType.ACCURACY:
			statValue = expect int( file.itemData[ref].i.statAccuracy )
			break

		case eWeaponStatType.RANGE:
			statValue = expect int( file.itemData[ref].i.statRange )
			break

		case eWeaponStatType.FIRE_RATE:
			statValue = expect int( file.itemData[ref].i.statFireRate )
			break

		case eWeaponStatType.CAPACITY:
			statValue = expect int( file.itemData[ref].i.statClipSize )
			break
	}

	return statValue
}

int function GetModdedItemStat( string parentRef, string childRef, int statType )
{
	int defaultValue = GetItemStat( parentRef, statType )
	if ( childRef == "none" )
		return defaultValue

	int modValue = GetSubitemStat( parentRef, childRef, statType )
	return defaultValue + modValue
}

int function GetSubitemStat( string parentRef, string childRef, int statType )
{
	Assert( parentRef in file.itemData )

	int statValue = 0

	Assert( childRef == "none" || childRef in file.itemData[parentRef].subitems )
	if ( !(childRef in file.itemData[parentRef].subitems) )
		return statValue

	SubItemData subItem = file.itemData[parentRef].subitems[childRef]

	switch ( statType )
	{
		case eWeaponStatType.DAMAGE:
			statValue = expect int( subItem.i.statDamage )
			break

		case eWeaponStatType.ACCURACY:
			statValue = expect int( subItem.i.statAccuracy )
			break

		case eWeaponStatType.RANGE:
			statValue = expect int( subItem.i.statRange )
			break

		case eWeaponStatType.FIRE_RATE:
			statValue = expect int( subItem.i.statFireRate )
			break

		case eWeaponStatType.CAPACITY:
			statValue = expect int( subItem.i.statClipSize )
			break
	}

	return statValue
}

int function GetTitanStat( string ref, int statType )
{
	int statValue = 0

	switch ( statType )
	{
		case eTitanStatType.SPEED:
			statValue = expect int( file.itemData[ref].i.statSpeed )
			break

		case eTitanStatType.DAMAGE:
			statValue = expect int( file.itemData[ref].i.statDamage )
			break

		case eTitanStatType.HEALTH:
			statValue = expect int( file.itemData[ref].i.statHealth )
			break

		case eTitanStatType.DASHES:
			statValue = expect int( file.itemData[ref].i.statDash )
			break
	}

	return statValue
}

int function GetSubItemClipSizeStat( string parentRef, string childRef )
{
	Assert( parentRef in file.itemData )

	if ( !(childRef in file.itemData[parentRef].subitems) )
		return 0

	SubItemData subItem = file.itemData[parentRef].subitems[childRef]

	return expect int ( subItem.i.statClipSize )
}

string function GetRefFromItem( item )
{
	return expect string( item.ref )
}

function SubitemDefined( string parentRef, string childRef )
{
	Assert( parentRef in file.itemData )
	return (childRef in file.itemData[parentRef].subitems)
}

ItemDisplayData function GetSubitemDisplayData( string parentRef, string childRef )
{
	Assert( parentRef in file.itemData )

	return GetItemDisplayData( childRef, parentRef )
}

int function GetSubitemType( string parentRef, string childRef )
{
	Assert( parentRef in file.itemData )

	return GetItemData( parentRef ).subitems[childRef].itemType
}

int function GetSubitemId( string parentRef, string childRef )
{
	Assert( parentRef in file.itemData )

	return file.itemRefToGuid[childRef]
}

string function GetSubitemName( string parentRef, string childRef )
{
	Assert( parentRef in file.itemData )

	return GetItemData( childRef ).name
}

bool function HasSubitem( string parentRef, string childRef )
{
	return (childRef in file.itemData[parentRef].subitems)
}

string function GetSubitemDescription( string parentRef, string childRef )
{
	Assert( parentRef in file.itemData )

	return GetItemData( childRef ).desc
}

string function GetSubitemLongDescription( string parentRef, string childRef )
{
	Assert( parentRef in file.itemData )

	return GetItemData( childRef ).longdesc
}

asset function GetSubitemImage( string parentRef, string childRef )
{
	Assert( parentRef in file.itemData )

	return GetItemData( childRef ).image
}

int function GetSubitemCost( string parentRef, string childRef )
{
	Assert( parentRef in file.itemData )

	if ( childRef == "none" )
		return GetItemCost( parentRef )

	return GetItemData( parentRef ).subitems[childRef].cost
}

array<ItemData> function GetAllItemsOfType( int itemType )
{
	Assert( itemType >= 0 && itemType < eItemTypes.COUNT, "Unknown item itemType " + itemType )

	array<ItemData> items = []

	if ( file.globalItemRefsOfType[ itemType ].len() )
	{
		array<GlobalItemRef> genericItemData = file.globalItemRefsOfType[ itemType ]
		foreach ( itemData in genericItemData )
			items.append( file.itemData[ itemData.ref ] )

		return items
	}

	foreach ( ref in file.itemsOfType[ itemType ] )
		items.append( file.itemData[ ref ] )

	return items
}

array<SubItemData> function GetAllSubItemsOfType( string parentRef, int itemType )
{
	Assert( itemType >= 0 && itemType < eItemTypes.COUNT, "Unknown item itemType " + itemType )

	array<SubItemData> items = []

	ItemData parentItem = GetItemData( parentRef )

	foreach ( subitem in parentItem.subitems )
	{
		if ( GetSubitemType( parentRef, subitem.ref ) != itemType )
			continue

		items.append( subitem )
	}

	return items
}


array<string> function GetAllItemRefsOfType( int itemType )
{
	Assert( itemType >= 0 && itemType < eItemTypes.COUNT, "Unknown item itemType " + itemType )
	//Assert( !(itemType == eItemTypes.PILOT_PRIMARY_MOD) )
	//Assert( !(itemType == eItemTypes.PILOT_SECONDARY_MOD) )
	//Assert( !(itemType == eItemTypes.PILOT_PRIMARY_ATTACHMENT) )

	array<string> refs = []

	if ( file.globalItemRefsOfType[ itemType ].len() )
	{
		array<GlobalItemRef> genericItemData = file.globalItemRefsOfType[ itemType ]
		foreach ( itemData in genericItemData )
			refs.append( itemData.ref )

		return refs
	}

	foreach ( ref in file.itemsOfType[ itemType ] )
		refs.append( ref )

	return refs
}

array<ItemDisplayData> function GetVisibleItemsOfType( int itemType, string parentRef = "", bool doSort = true )
{
	Assert( itemType >= 0 && itemType < eItemTypes.COUNT, "Unknown item itemType " + itemType )
	Assert( !IsSubItemType( itemType ) || parentRef != "" )

	array<ItemDisplayData> items = []

	if ( file.globalItemRefsOfType[ itemType ].len() )
	{
		array<GlobalItemRef> genericItemData = file.globalItemRefsOfType[ itemType ]
		foreach ( itemData in genericItemData )
		{
			if ( itemData.hidden )
				continue

			if ( IsSubItemType( itemType ) && !HasSubitem( parentRef, itemData.ref ) )
				continue

			items.append( GetItemDisplayData( itemData.ref, parentRef ) )
		}
	}

	if ( doSort )
		items.sort( SortByUnlockLevelUntyped )

	return items
}

array<ItemDisplayData> function GetVisibleItemsOfTypeWithoutEntitlements( entity player, int itemType, string parentRef = "" )
{
	array<ItemDisplayData> items = GetVisibleItemsOfType( itemType, parentRef )
	array<ItemDisplayData> finalItems = []

	// in case the player is gone (disconnected)
	if ( player == null )
	{
		return items
	}

	foreach ( item in items )
	{
		bool isEntitlement = IsItemInEntitlementUnlock( item.ref, item.parentRef )
		bool locked
		int unlockType

		if ( IsItemInRandomUnlocks( item.ref, item.parentRef ) )
		{
			finalItems.append( item )
			continue
		}

		if ( IsSubItemType( itemType ) )
		{
			locked = IsSubItemLocked( player, item.ref, item.parentRef )

			if ( isEntitlement && locked && !IsItemPurchasableEntitlement( item.ref, item.parentRef ) )
				continue
			else if ( isEntitlement )
				unlockType = 0 // just a whatever number
			else
				unlockType = GetSubItemUnlockType( item.ref, item.parentRef )
		}
		else
		{
			locked = IsItemLocked( player, item.ref )

			if ( isEntitlement && locked && !IsItemPurchasableEntitlement( item.ref ) )
				continue
			else if ( isEntitlement )
				unlockType = 0 // just a whatever number
			else
				unlockType = GetItemUnlockType( item.ref )
		}

		if ( unlockType == eUnlockType.PERSISTENT_ITEM && locked )
			continue

		finalItems.append( item )
	}

	return finalItems
}

array<ItemDisplayData> function GetVisibleItemsOfTypeForCategory( int itemType, int category )
{
	array<ItemDisplayData> items = GetVisibleItemsOfType( itemType )
	array<ItemDisplayData> filteredItems

	foreach ( item in items )
	{
		if ( item.i.menuCategory == category )
			filteredItems.append( item )
	}

	return filteredItems
}

array<ItemDisplayData> function GetVisibleItemsOfTypeMatchingEntitlementID( int itemType, int entitlementID, string parentRef = "" )
{
	array<ItemDisplayData> items = GetVisibleItemsOfType( itemType, parentRef )
	array<ItemDisplayData> filteredItems

	foreach ( item in items )
	{
		array<int> ids = GetEntitlementIds( item.ref, parentRef )

		foreach ( id in ids )
		{
			if ( id == entitlementID )
				filteredItems.append( item )
		}
	}

	return filteredItems
}

int function GetIndexForUnlockItem( int itemType, string ref )
{
	Assert( itemType >= 0 && itemType < eItemTypes.COUNT, "Unknown item itemType " + itemType )

	array<ItemDisplayData> items = GetVisibleItemsOfType( itemType )
	for ( int i = 0; i < items.len(); i++ )
	{
		if ( items[i].ref == ref )
			return i
	}

	Assert( 0, "GetIndexForUnlockItem() failed to find ref " + ref )
	unreachable
}

array<string> function GetAllRefsOfType( int itemType )
{
	return file.itemsOfType[itemType]
}

array<GlobalItemRef> function GetAllItemRefs()
{
	return file.allItems
}

array<string> function GetAllSubitemRefs( string parentRef )
{
	array<string> childRefs = []

	foreach ( childRef, subItem in file.itemData[ parentRef ].subitems )
	{
		childRefs.append( childRef )
	}

	return childRefs
}

string function GetItemRefOfTypeByIndex( int itemType, int index )
{
	array<string> typeArray = file.itemsOfType[itemType]

	Assert( index >= 0 && index < typeArray.len() )

	return typeArray[index]
}

string function GetRandomItemRefOfType( int itemType )
{
	Assert( itemType >= 0 && itemType < eItemTypes.COUNT, "Unknown item itemType " + itemType )

	array<string> items = GetAllRefsOfType( itemType )

	return items[ rand() % items.len() ]
}

int function GetItemIndexOfTypeByRef( int itemType, string itemRef )
{
	int count = 0
	foreach ( ref in file.itemsOfType[ itemType ] )
	{
		if ( ref == itemRef )
			return count
		else
			count++
	}
	Assert( false, "itemRef not found in ItemType" )
	return 0
}


void function CreateModData( int itemType, string parentRef, string modRef, int cost = 0, int statDamage = 0, int statAccuracy = 0, int statRange = 0, int statFireRate = 0, int statClipSize = 0 )
{
	Assert( parentRef in file.itemData )
	Assert( modRef in file.itemData )

	if ( itemType == eItemTypes.PILOT_PRIMARY_ATTACHMENT )
		Assert( ItemTypeSupportsAttachments( GetItemType( parentRef ) ), "Item type was " + GetItemType( parentRef ) )
	else
		Assert( ItemTypeSupportsMods( GetItemType( parentRef ) ), "Item type was " + GetItemType( parentRef ) )
	Assert( !(modRef in file.itemData[parentRef].subitems), "childRef " + modRef + " being redefined!" )

	ItemData modData = GetItemData( modRef )

	SubItemData subItemRef
	subItemRef.itemType = itemType
	subItemRef.ref = modRef
	subItemRef.parentRef = parentRef
	subItemRef.cost	= cost

	subItemRef.i.statDamage <- statDamage
	subItemRef.i.statRange <- statRange
	subItemRef.i.statAccuracy <- statAccuracy
	subItemRef.i.statFireRate <- statFireRate
	subItemRef.i.statClipSize <- statClipSize

	ItemData parentItem = GetItemData( parentRef )
	Assert( !(modRef in parentItem.subitems) )
	parentItem.subitems[modRef] <- subItemRef
}



void function CreateGenericSubItemData( int itemType, string parentRef, string itemRef, int cost = 0, table t = {} )
{
	Assert( IsSubItemType( itemType ) )
	Assert( parentRef in file.itemData )
	Assert( itemRef in file.itemData )

	ItemData baseData = GetItemData( itemRef )

	SubItemData subItemRef
	subItemRef.itemType = itemType
	subItemRef.ref = itemRef
	subItemRef.parentRef = parentRef
	subItemRef.cost = cost
	subItemRef.i = clone t

	ItemData parentItem = GetItemData( parentRef )
	Assert( !(itemRef in parentItem.subitems), "childRef " + itemRef + " being redefined!" )
	parentItem.subitems[itemRef] <- subItemRef
}


ItemData function CreateGenericItem( int dataTableIndex, int itemType, string ref, string name, string desc, string longdesc, asset image, int cost, bool isHidden )
{
	ItemData item 			= CreateBaseItemData( itemType, ref, isHidden )
	item.name               = name
	item.desc               = desc
	item.longdesc           = longdesc
	item.image              = image
	item.imageAtlas			= IMAGE_ATLAS_MENU
	item.persistenceId      = dataTableIndex
	item.cost				= cost

	return item
}


array<ItemDisplayData> function GetDisplaySubItemsOfType( string parentRef, int itemType )
{
	array<ItemDisplayData> subitems = []

	foreach ( subItemRef, subItemData in file.itemData[ parentRef ].subitems )
	{
		if ( subItemData.itemType == itemType )
			subitems.append( GetItemDisplayData( subItemRef, parentRef ) )
	}

	subitems.sort( SortByUnlockLevelUntyped ) // TODO

	return subitems
}

bool function ItemSupportsAttachments( string ref )
{
	return (GetItemType( ref ) == eItemTypes.PILOT_PRIMARY)
}

bool function ItemSupportsAttachment( string itemRef, string childRef )
{
	ItemData item = GetItemData( itemRef )
	if ( !(childRef in item.subitems ) )
		return false

	ItemData childItem = GetItemData( childRef )
	return childItem.itemType == eItemTypes.PILOT_PRIMARY_ATTACHMENT
}

bool function ItemSupportsMods( string ref )
{
	local itemType = GetItemType( ref )

	return (itemType == eItemTypes.PILOT_PRIMARY || itemType == eItemTypes.PILOT_SECONDARY || itemType == eItemTypes.TITAN_PRIMARY)
}

void function CreateTitanData( int dataTableIndex, string titanRef, int cost, asset image, asset coreIcon )
{
	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "titanRef" ), titanRef )
	string setFile = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "setFile" ) )

	string name = expect string( GetPlayerSettingsFieldForClassName( setFile, "printname" ) )
	string desc = expect string( GetPlayerSettingsFieldForClassName( setFile, "description" ) )

	ItemData item = CreateBaseItemData( eItemTypes.TITAN, titanRef, false )
	item.name                   = name
	item.desc                   = desc
	item.longdesc               = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "desc" ) )
	item.image 					= image
	item.imageAtlas				= IMAGE_ATLAS_HUD
	item.cost					= cost

	item.i.coreIcon				<- coreIcon

	item.i.statSpeed            <- GetDataTableInt( dataTable, row, GetDataTableColumnByName( dataTable, "speedDisplay" ) )
	item.i.statHealth           <- GetDataTableInt( dataTable, row, GetDataTableColumnByName( dataTable, "healthDisplay" ) )
	item.i.statDamage           <- GetDataTableInt( dataTable, row, GetDataTableColumnByName( dataTable, "damageDisplay" ) )
	item.i.statDash 	          <- GetDataTableInt( dataTable, row, GetDataTableColumnByName( dataTable, "dashDisplay" ) )

	item.i.passive1Type			<- GetTitanLoadoutPropertyPassiveType( setFile, "passive1" )
	item.i.passive2Type			<- GetTitanLoadoutPropertyPassiveType( setFile, "passive2" )
	item.i.passive3Type			<- GetTitanLoadoutPropertyPassiveType( setFile, "passive3" )
	item.i.passive4Type			<- GetTitanLoadoutPropertyPassiveType( setFile, "passive4" )
	item.i.passive5Type			<- GetTitanLoadoutPropertyPassiveType( setFile, "passive5" )
	item.i.passive6Type			<- GetTitanLoadoutPropertyPassiveType( setFile, "passive6" )
	item.i.titanExecution 		<- GetTitanLoadoutPropertyExecutionType( setFile, "titanExecution" )

	item.persistenceStruct		= "titanChassis[" + dataTableIndex + "]"
	item.persistenceId          = dataTableIndex
}

asset function GetIconForTitanClass( string titanClass )
{
	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int loadoutIconCol = GetDataTableColumnByName( dataTable, "loadoutIcon" )
	int titanCol = GetDataTableColumnByName( dataTable, "titanRef" )

	int row = GetDataTableRowMatchingStringValue( dataTable, titanCol,  titanClass )
	asset icon = GetDataTableAsset( dataTable, row, loadoutIconCol )

	return icon
}


array<ItemDisplayData> function FD_GetUpgradesForTitanClass( string titanClass )
{
	array<ItemData> allUpgradeItems = GetAllItemsOfType( eItemTypes.TITAN_FD_UPGRADE )

	array<ItemData> titanUpgrades
	foreach ( ItemData item in allUpgradeItems )
	{
		if ( item.parentRef != titanClass )
			continue

		titanUpgrades.append( item )
	}

	titanUpgrades.sort( SortItemDataByUnlockLevel )

	array<ItemDisplayData> displayUpgrades
	foreach ( ItemData item in titanUpgrades )
	{
		displayUpgrades.append( GetItemDisplayData( item.ref, item.parentRef ) )
	}

	return displayUpgrades
}


int function SortItemDataByUnlockLevel( ItemData a, ItemData b )
{
	const int SORT_SAME = 0
	const int SORT_AFTER = 1
	const int SORT_BEFORE = -1

	int aLevel = GetUnlockLevelReqWithParent( a.ref, a.parentRef )
	int bLevel = GetUnlockLevelReqWithParent( b.ref, b.parentRef )

	if ( aLevel > bLevel )
		return SORT_AFTER
	else if ( aLevel < bLevel )
		return SORT_BEFORE
	else
		return SORT_SAME

	unreachable
}


void function SetupFrontierDefenseItems()
{
	{
		var dataTable = GetDataTable( $"datatable/titan_fd_upgrades.rpak" )
		var numRows = GetDatatableRowCount( dataTable )
		for ( int i = 0; i < numRows; i++ )
		{
			bool hidden	= false

			string ref			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "ref" ) )
			string parentRef	= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "parentref" ) )
			//int itemType		= eItemTypes[ GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "type" ) ) ]
			string upgradeType	= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "upgradeType" ) )
			string name			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "name" ) )
			string description	= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "description" ) )
			asset image			= GetDataTableAsset( dataTable, i, GetDataTableColumnByName( dataTable, "image" ) )
			asset lockedImage	= GetDataTableAsset( dataTable, i, GetDataTableColumnByName( dataTable, "lockedImage" ) )
			int slot			= GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "slot" ) )
			int cost			= GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "cost" ) )

			if ( IsDisabledRef( ref ) )
				continue

			CreateFDTitanUpgradeData( i, upgradeType, hidden, ref, parentRef, name, description, image, lockedImage, slot, cost )
			//InitUnlock( ref, parentRef, eUnlockType.FD_UNLOCK_POINTS, unlockLevel )
		}
	}
}

void function InitFrontierDefenseUnlocks()
{
	{
		var dataTable = GetDataTable( $"datatable/unlocks_fd_titan_level.rpak" )
		int numRows = GetDatatableRowCount( dataTable )
		int column = 1
		while ( true )
		{
			string titanRef = GetDataTableString( dataTable, 0, column )
			if ( titanRef == "END" )
				break

			if ( IsDisabledRef( titanRef ) )
			{
				column++
				continue
			}

			for ( int row = 1; row < numRows; row++ )
			{
				string unlockField = GetDataTableString( dataTable, row, column )

				array<string> unlockArray = SplitAndStripUnlockField( unlockField )

				foreach ( unlock in unlockArray )
				{
					if ( unlock != "" )
						InitUnlock( unlock, titanRef, eUnlockType.FD_UNLOCK_POINTS, row )
				}
			}

			column++
		}
	}
}


void function CreateFDTitanUpgradeData( int dataTableIndex, string upgradeType, bool hidden, string ref, string parentRef, string name, string desc, asset image, asset lockedImage, int slot, int cost = 0 )
{
	Assert( parentRef in file.itemData )

	ItemData item		= CreateBaseItemData( eItemTypes.TITAN_FD_UPGRADE, ref, hidden )
	item.name			= name
	item.longname		= name
	item.desc			= desc
	item.image			= image
	item.persistenceId	= dataTableIndex
	item.cost			= cost
	item.slot 			= slot
	item.parentRef      = parentRef
	item.imageAtlas		= IMAGE_ATLAS_MENU

	string upgradeTypeCategory
	if ( upgradeType == "weapon" )
		upgradeTypeCategory = "#FD_UPGRADE_ITEM_TYPE_WEAPON"
	else if ( upgradeType == "utility" )
		upgradeTypeCategory = "#FD_UPGRADE_ITEM_TYPE_UTILITY"
	else if ( upgradeType == "defensive" )
		upgradeTypeCategory = "#FD_UPGRADE_ITEM_TYPE_DEFENSE"
	else if ( upgradeType == "ultimate" )
		upgradeTypeCategory = "#FD_UPGRADE_ITEM_TYPE_ULTIMATE"
	else
		upgradeTypeCategory = "!!FD_UPGRADE_ITEM_TYPE UNKNOWN!!"

	item.i.upgradeType	<- upgradeType
	item.i.upgradeTypeCategory	<- upgradeTypeCategory
	item.i.lockedImage <- lockedImage

	SubItemData subItemRef
	subItemRef.itemType 		= eItemTypes.TITAN_FD_UPGRADE
	subItemRef.ref 				= ref
	subItemRef.parentRef 		= parentRef
	subItemRef.cost 			= cost
	subItemRef.slot 			= slot
	subItemRef.i 				= {}
	subItemRef.i.upgradeType 	<- upgradeType
	subItemRef.i.upgradeTypeCategory 	<- upgradeTypeCategory
	subItemRef.i.lockedImage <- lockedImage

	ItemData parentItem = GetItemData( parentRef )
	Assert( !(ref in parentItem.subitems), "childRef " + ref + " being redefined!" )
	parentItem.subitems[ref] <- subItemRef
}

void function CreateTitanExecutionData( int dataTableIndex, int itemType, bool hidden, string ref, string name, string desc, string longdesc, asset image, int cost = 0, bool reqPrime = false )
{
	ItemData item		= CreateBaseItemData( itemType, ref, hidden )
	item.name			= name
	item.longname		= name
	item.desc			= desc
	item.longdesc		= longdesc
	item.image			= image
	item.persistenceId	= dataTableIndex
	item.cost			= cost
	item.imageAtlas		= IMAGE_ATLAS_MENU
	item.reqPrime		= reqPrime
}

void function CreatePassiveData( int dataTableIndex, int itemType, bool hidden, string ref, string name, string desc, string longdesc, asset image, int cost = 0 )
{
	ItemData item		= CreateBaseItemData( itemType, ref, hidden )
	item.name			= name
	item.longname		= name
	item.desc			= desc
	item.longdesc		= longdesc
	item.image			= image
	item.persistenceId	= dataTableIndex
	item.cost			= cost
	item.imageAtlas		= IMAGE_ATLAS_MENU
}

void function CreateNoseArtData( int dataTableIndex, int itemType, bool hidden, string ref, string name, asset image, int decalIndex )
{
	ItemData item		= CreateBaseItemData( itemType, ref, hidden )
	item.name			= name
	item.image			= image
	item.imageAtlas		= IMAGE_ATLAS_CAMO

	item.i.decalIndex	<- decalIndex

	item.persistenceId	= dataTableIndex
}

void function CreateSkinData( int dataTableIndex, int itemType, bool hidden, string ref, string name, asset image, int skinIndex )
{
	ItemData item		= CreateBaseItemData( itemType, ref, hidden )
	item.name			= name
	item.image			= image
	item.imageAtlas		= IMAGE_ATLAS_CAMO

	item.i.skinIndex	<- skinIndex

	item.persistenceId	= dataTableIndex
}


void function CreateWeaponSkinData( int dataTableIndex, int itemType, bool hidden, string ref, string weaponRef, string name, asset image, int skinIndex, int skinType )
{
	ItemData item		= CreateBaseItemData( itemType, ref, hidden )
	item.name			= name
	item.image			= image
	item.imageAtlas		= IMAGE_ATLAS_MENU
	item.parentRef		= weaponRef

	item.i.skinIndex	<- skinIndex
	item.i.skinType	<- skinType

	item.persistenceId	= dataTableIndex
}

function ItemTypeSupportsMods( iType )
{
	if ( iType == eItemTypes.PILOT_PRIMARY ||
					iType == eItemTypes.PILOT_SECONDARY ||
					iType == eItemTypes.TITAN_PRIMARY )
		return true

	return false
}

function ItemTypeSupportsAttachments( itemType )
{
	if ( itemType == eItemTypes.PILOT_PRIMARY )
		return true

	return false
}

bool function IsItemTypeMod( int itemType )
{
	if ( itemType == eItemTypes.PILOT_PRIMARY_MOD ||
					itemType == eItemTypes.PILOT_SECONDARY_MOD ||
					itemType == eItemTypes.TITAN_PRIMARY_MOD )
		return true

	return false
}

bool function IsItemTypeAttachment( int itemType )
{
	if ( itemType == eItemTypes.PILOT_PRIMARY_ATTACHMENT )
		return true

	return false
}

bool function IsRefValid( string ref )
{
	if ( ItemDefined( ref ) )
		return true

	if ( ref in file.unlocks )
		return true

	if ( ref in shGlobalMP.challengeData )
		return true

	foreach ( itemType in file.itemsOfType )
	{
		foreach ( itemRef in itemType )
		{
			if ( itemRef == ref )
				return true
		}
	}

	return false
}

bool function IsUnlockValid( string ref, string parentRef = "" )
{
	if ( !IsRefValid( ref ) )
		return false

	if ( parentRef == "" )
	{
		if ( !( ref in file.unlocks ) )
			return false
	}
	else
	{
		if ( !IsRefValid( parentRef ) )
			return false

		if ( !(parentRef in file.unlocks ) )
			return false

		if ( !(ref in file.unlocks[parentRef].child ) )
			return false
	}

	return true
}


bool function IsSubItemLocked( entity player, string ref, string parentRef )
{
	if ( DevEverythingUnlocked() )
		return false

	if ( IsItemInEntitlementUnlock( ref, parentRef ) )
	{
		if (!IsItemLockedForEntitlement( player, ref, parentRef ) )
			return false

		return !IsSubItemOwned( player, ref, parentRef )
	}

	if ( IsItemInRandomUnlocks( ref, parentRef ) )
		return !IsSubItemOwned( player, ref, parentRef )

	Assert( IsValid( player ) )
	Assert( !(ref in file.unlocks) )
	Assert( parentRef in file.unlocks )

	int parentRefType = GetItemType( parentRef )
	int refType = GetSubitemType( parentRef, ref )

	Assert( !IsSubItemType( parentRefType ) )
	Assert( IsSubItemType( refType ) )

	if ( IsItemLocked( player, parentRef ) )
		return true

	if ( GetSubItemUnlockType( ref, parentRef ) == eUnlockType.STAT )
	{
		if ( !IsSubItemLockedForStat( player, ref, parentRef) )
			return false

		return !IsSubItemOwned( player, ref, parentRef )
	}

	switch ( refType )
	{
		case eItemTypes.PILOT_PRIMARY_ATTACHMENT:
		case eItemTypes.PILOT_PRIMARY_MOD:
		case eItemTypes.PILOT_SECONDARY_MOD:
		case eItemTypes.PILOT_WEAPON_MOD3:
		case eItemTypes.SUB_PILOT_WEAPON_MOD:
		case eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT:
		case eItemTypes.WEAPON_FEATURE:
			if ( !IsItemLockedForWeapon( player, ref, parentRef ) )
				return false

			return !IsSubItemOwned( player, ref, parentRef )

		case eItemTypes.TITAN_GENERAL_PASSIVE:
		case eItemTypes.TITAN_TITANFALL_PASSIVE:
		case eItemTypes.TITAN_RONIN_PASSIVE:
		case eItemTypes.TITAN_NORTHSTAR_PASSIVE:
		case eItemTypes.TITAN_ION_PASSIVE:
		case eItemTypes.TITAN_TONE_PASSIVE:
		case eItemTypes.TITAN_SCORCH_PASSIVE:
		case eItemTypes.TITAN_LEGION_PASSIVE:
		case eItemTypes.TITAN_VANGUARD_PASSIVE:
		case eItemTypes.TITAN_UPGRADE1_PASSIVE:
		case eItemTypes.TITAN_UPGRADE2_PASSIVE:
		case eItemTypes.TITAN_UPGRADE3_PASSIVE:
			if ( !IsItemLockedForTitan( player, ref, parentRef ) )
				return false

			return !IsSubItemOwned( player, ref, parentRef )

		case eItemTypes.CAMO_SKIN_TITAN:
		case eItemTypes.TITAN_WARPAINT:
		case eItemTypes.CAMO_SKIN:
			switch ( parentRefType )
			{
				case eItemTypes.TITAN:
					if ( GetSubItemUnlockType( ref, parentRef ) == eUnlockType.TITAN_LEVEL && !IsItemLockedForTitan( player, ref, parentRef ) )
						return false

					if ( GetSubItemUnlockType( ref, parentRef ) == eUnlockType.FACTION_LEVEL && !IsItemLockedForFaction( player, ref, parentRef ) )
						return false

					return !IsSubItemOwned( player, ref, parentRef )

				case eItemTypes.PILOT_PRIMARY:
				case eItemTypes.PILOT_SECONDARY:
					if ( GetSubItemUnlockType( ref, parentRef ) == eUnlockType.WEAPON_LEVEL && !IsItemLockedForWeapon( player, ref, parentRef ) )
						return false

					if ( GetSubItemUnlockType( ref, parentRef ) == eUnlockType.FACTION_LEVEL && !IsItemLockedForFaction( player, ref, parentRef ) )
						return false

					return !IsSubItemOwned( player, ref, parentRef )
			}

		case eItemTypes.TITAN_NOSE_ART:
			if ( GetSubItemUnlockType( ref, parentRef ) == eUnlockType.TITAN_LEVEL && !IsItemLockedForTitan( player, ref, parentRef ) )
				return false

			if ( GetSubItemUnlockType( ref, parentRef ) == eUnlockType.FACTION_LEVEL && !IsItemLockedForFaction( player, ref, parentRef ) )
				return false

			return !IsSubItemOwned( player, ref, parentRef )

		case eItemTypes.TITAN_FD_UPGRADE:
			if ( GetSubItemUnlockType( ref, parentRef ) == eUnlockType.FD_UNLOCK_POINTS && !IsItemLockedForFrontierDefense( player, ref, parentRef ) )
				return false

			return !IsSubItemOwned( player, ref, parentRef )

		case eItemTypes.PRIME_TITAN_NOSE_ART:
			unreachable //Show have been caught IsItemInEntitlementUnlock() check earlier

		default:
			CodeWarning( "Unhandled unlock type (subitem): " + DEV_GetEnumStringFromIndex( "eItemTypes", refType ) + " " + ref + " " + parentRef )
	}

	return false
}


bool function IsItemLocked( entity player, string ref )
{
	if ( DevEverythingUnlocked() )
		return false

	if ( IsItemInEntitlementUnlock( ref ) )
	{
		if ( !IsItemLockedForEntitlement( player, ref ) )
			return false

		return !IsItemOwned( player, ref )
	}

	if ( IsItemInRandomUnlocks( ref  ) )
		return !IsItemOwned( player, ref )

	Assert( IsValid( player ) )
	Assert( ref in file.unlocks, "ref not found: " + ref )

	if ( !ItemDefined( ref ) )
	{
		CodeWarning( "undefined item? " + ref )
		return false
	}

	ItemData itemData = GetItemData( ref )
	Assert( !IsSubItemType( itemData.itemType ) )

	switch ( file.unlocks[ref].unlockType )
	{
		case eUnlockType.PLAYER_LEVEL:
			if ( !IsItemLockedForPlayer( player, ref ) )
				return false
			break

		case eUnlockType.WEAPON_LEVEL:
			Assert( file.unlocks[ref].parentRef != "" )
			if ( !IsItemLockedForWeapon( player, ref, file.unlocks[ref].parentRef ) )
				return false
			break

		case eUnlockType.TITAN_LEVEL:
			if ( !IsItemLockedForTitan( player, ref, file.unlocks[ref].parentRef ) )
				return false
			break

		case eUnlockType.FACTION_LEVEL:
			if ( !IsItemLockedForFaction( player, ref, file.unlocks[ref].parentRef ) )
				return false
			break

		case eUnlockType.STAT:
			if ( !IsItemLockedForStat( player, ref ) )
				return false
			break

		case eUnlockType.FD_UNLOCK_POINTS:
			if ( !IsItemLockedForFrontierDefense( player, ref, file.unlocks[ref].parentRef ) )
				return false
			break
	}
	//Assert( file.unlocks[ref].unlockType == eUnlockType.PLAYER_LEVEL, "Non subitem types must be unlocked via player level." )


	return !IsItemOwned( player, ref )
}


bool function IsItemLockedForEntitlement( entity player, string ref, string parentRef = "" )
{
	string fullRef = GetFullRef( ref, parentRef )

	foreach ( int entitlementId in file.entitlementUnlocks[fullRef].entitlementIds )
	{
		//printt( "entitlement check", fullRef, entitlementId )
		#if SERVER
			if ( player.HasEntitlement( entitlementId ) )
				return false
		#else
			if ( LocalPlayerHasEntitlement( entitlementId ) )
				return false
		#endif
	}

	return true
}



bool function IsSubItemOwned( entity player, string ref, string parentRef )
{
	if ( DevEverythingUnlocked() )
		return false

	Assert( IsValid( player ) )

	if ( !ItemDefined( ref ) )
	{
		CodeWarning( "undefined item? " + ref )
		return false
	}

	int parentRefType = GetItemType( parentRef )
	int refType = GetSubitemType( parentRef, ref )

	Assert( !IsSubItemType( parentRefType ) )
	Assert( IsSubItemType( refType ) )

	int bitIndex = GetItemPersistenceId( ref, parentRef )
	switch ( refType )
	{
		case eItemTypes.PILOT_PRIMARY_ATTACHMENT:
		case eItemTypes.PILOT_PRIMARY_MOD:
		case eItemTypes.PILOT_SECONDARY_MOD:
		case eItemTypes.PILOT_WEAPON_MOD3:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsPersistenceBitSet( player, parentStruct + ".unlockedMods", bitIndex )

		case eItemTypes.WEAPON_FEATURE:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsPersistenceBitSet( player, parentStruct + ".unlockedFeatures", bitIndex )

		case eItemTypes.WEAPON_SKIN:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsPersistenceBitSet( player, parentStruct + ".unlockedPrimeWeaponSkins", bitIndex )

		case eItemTypes.TITAN_GENERAL_PASSIVE:
		case eItemTypes.TITAN_TITANFALL_PASSIVE:
		case eItemTypes.TITAN_RONIN_PASSIVE:
		case eItemTypes.TITAN_NORTHSTAR_PASSIVE:
		case eItemTypes.TITAN_ION_PASSIVE:
		case eItemTypes.TITAN_TONE_PASSIVE:
		case eItemTypes.TITAN_SCORCH_PASSIVE:
		case eItemTypes.TITAN_LEGION_PASSIVE:
		case eItemTypes.TITAN_VANGUARD_PASSIVE:
		case eItemTypes.TITAN_UPGRADE1_PASSIVE:
		case eItemTypes.TITAN_UPGRADE2_PASSIVE:
		case eItemTypes.TITAN_UPGRADE3_PASSIVE:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsPersistenceBitSet( player, parentStruct + ".unlockedPassives", bitIndex )

		case eItemTypes.CAMO_SKIN_TITAN:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsPersistenceBitSet( player, parentStruct + ".unlockedSkins", bitIndex )

		case eItemTypes.TITAN_WARPAINT:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsPersistenceBitSet( player, parentStruct + ".unlockedPrimeSkins", bitIndex )

		case eItemTypes.CAMO_SKIN:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsPersistenceBitSet( player, parentStruct + ".unlockedWeaponSkins", bitIndex )

		case eItemTypes.TITAN_NOSE_ART:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsPersistenceBitSet( player, parentStruct + ".unlockedTitanDecals", bitIndex )

		case eItemTypes.PRIME_TITAN_NOSE_ART:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsPersistenceBitSet( player, parentStruct + ".unlockedPrimeTitanDecals", bitIndex )

		case eItemTypes.TITAN_FD_UPGRADE:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsPersistenceBitSet( player, parentStruct + ".unlockedFDUpgrades", bitIndex )

		default:
			CodeWarning( "Unhandled owned type (subitem): " + DEV_GetEnumStringFromIndex( "eItemTypes", refType ) + " " + ref + " " + parentRef )
	}

	return false
}


bool function IsItemOwned( entity player, string ref )
{
	if ( DevEverythingUnlocked() )
		return false

	Assert( IsValid( player ) )

	if ( !ItemDefined( ref ) )
	{
		CodeWarning( "undefined item? " + ref )
		return false
	}

	ItemData itemData = GetItemData( ref )
	Assert( !IsSubItemType( itemData.itemType ) )

	int refType = GetItemType( ref )
	int bitIndex = GetItemPersistenceId( ref )
	switch ( refType )
	{
		case eItemTypes.PILOT_PRIMARY:
		case eItemTypes.PILOT_SECONDARY:
			return IsPersistenceBitSet( player, "unlockedPilotWeapons", bitIndex )

		case eItemTypes.PILOT_SPECIAL:
		case eItemTypes.PILOT_ORDNANCE:
			return IsPersistenceBitSet( player, "unlockedPilotOffhands", bitIndex )

		case eItemTypes.PILOT_PASSIVE1:
		case eItemTypes.PILOT_PASSIVE2:
			return IsPersistenceBitSet( player, "unlockedPilotPassives", bitIndex )

		case eItemTypes.PILOT_SUIT:
			return IsPersistenceBitSet( player, "unlockedPilotSuits", bitIndex )

		case eItemTypes.PILOT_EXECUTION:
			return IsPersistenceBitSet( player, "unlockedPilotExecutions", bitIndex )

		case eItemTypes.TITAN_RONIN_EXECUTION:
		case eItemTypes.TITAN_NORTHSTAR_EXECUTION:
		case eItemTypes.TITAN_ION_EXECUTION:
		case eItemTypes.TITAN_TONE_EXECUTION:
		case eItemTypes.TITAN_SCORCH_EXECUTION:
		case eItemTypes.TITAN_LEGION_EXECUTION:
		case eItemTypes.TITAN_VANGUARD_EXECUTION:
			return IsPersistenceBitSet( player, "unlockedTitanExecutions", bitIndex )

		case eItemTypes.TITAN_PRIMARY:
			return IsPersistenceBitSet( player, "unlockedTitanWeapons", bitIndex )

		case eItemTypes.TITAN_SPECIAL:
		case eItemTypes.TITAN_ORDNANCE:
		case eItemTypes.TITAN_ANTIRODEO:
			return IsPersistenceBitSet( player, "unlockedTitanOffhands", bitIndex )

		case eItemTypes.TITAN:
			return IsPersistenceBitSet( player, "unlockedTitanChassis", bitIndex )

		case eItemTypes.PRIME_TITAN:
			return IsPersistenceBitSet( player, "unlockedPrimeTitans", bitIndex )

		case eItemTypes.FEATURE:
			return IsPersistenceBitSet( player, "unlockedFeatures", bitIndex )

		case eItemTypes.CAMO_SKIN_PILOT:
			return IsPersistenceBitSet( player, "unlockedPilotSkins", bitIndex )

		case eItemTypes.BURN_METER_REWARD:
			return IsPersistenceBitSet( player, "unlockedBoosts", bitIndex )

		case eItemTypes.FACTION:
			return IsPersistenceBitSet( player, "unlockedFactions", bitIndex )

		case eItemTypes.CALLING_CARD:
			return IsPersistenceBitSet( player, "unlockedCallingCards", bitIndex )

		case eItemTypes.CALLSIGN_ICON:
			return IsPersistenceBitSet( player, "unlockedCallsignIcons", bitIndex )

		case eItemTypes.COMMS_ICON:
			return IsPersistenceBitSet( player, "unlockedCommsIcons", bitIndex )

		default:
			CodeWarning( "Unhandled owned type: " + DEV_GetEnumStringFromIndex( "eItemTypes", refType ) + " " + ref )
	}

	return false
}

int function GetItemUnlockType( string ref )
{
	Assert( ref in file.unlocks )

	return file.unlocks[ ref ].unlockType
}

int function GetSubItemUnlockType( string ref, string parentRef )
{
	Assert( parentRef in file.unlocks )
	Assert( ref in file.unlocks[ parentRef ].child )

	return file.unlocks[ parentRef ].child[ ref ].unlockType
}

bool function IsItemLockedForTitanLevel( int titanLevel, string ref, string parentRef = "" )
{
	Assert( parentRef in file.unlocks )

	if ( IsSubItemType( GetItemType( ref ) ) )
	{
		Assert( ref in file.unlocks[ parentRef ].child )
		Assert( file.unlocks[ parentRef ].child[ ref ].unlockType == eUnlockType.TITAN_LEVEL )

		return titanLevel < file.unlocks[ parentRef ].child[ ref ].unlockLevel
	}
	else
	{
		Assert( ref in file.unlocks )
		Assert( file.unlocks[ref].parentRef == parentRef )
		Assert( file.unlocks[ ref ].unlockType == eUnlockType.TITAN_LEVEL )

		return titanLevel < file.unlocks[ ref ].unlockLevel
	}

	unreachable
}


bool function IsItemLockedForWeaponLevel( int weaponLevel, string ref, string parentRef = "" )
{
	Assert( parentRef in file.unlocks )

	if ( IsSubItemType( GetItemType( ref ) ) )
	{
		Assert( ref in file.unlocks[ parentRef ].child )
		Assert( file.unlocks[ parentRef ].child[ ref ].unlockType == eUnlockType.WEAPON_LEVEL )

		return weaponLevel < file.unlocks[ parentRef ].child[ ref ].unlockLevel
	}
	else
	{
		Assert( ref in file.unlocks )
		Assert( file.unlocks[ref].parentRef == parentRef )
		Assert( file.unlocks[ ref ].unlockType == eUnlockType.WEAPON_LEVEL )

		return weaponLevel < file.unlocks[ ref ].unlockLevel
	}

	unreachable
}

bool function IsItemLockedForFDTitanLevel( int titanLevel, string ref, string parentRef = "" )
{
	Assert( parentRef in file.unlocks )

	if ( IsSubItemType( GetItemType( ref ) ) )
	{
		Assert( ref in file.unlocks[ parentRef ].child )
		Assert( file.unlocks[ parentRef ].child[ ref ].unlockType == eUnlockType.FD_UNLOCK_POINTS )

		return titanLevel < file.unlocks[ parentRef ].child[ ref ].unlockLevel
	}
	else
	{
		Assert( ref in file.unlocks )
		Assert( file.unlocks[ref].parentRef == parentRef )
		Assert( file.unlocks[ ref ].unlockType == eUnlockType.FD_UNLOCK_POINTS )

		return titanLevel < file.unlocks[ ref ].unlockLevel
	}

	unreachable
}


bool function IsItemLockedForFactionLevel( int factionLevel, string faction, string ref, string parentRef = "" )
{
	if ( IsSubItemType( GetItemType( ref ) ) )
	{
		Assert( ref in file.unlocks[ parentRef ].child )
		Assert( file.unlocks[ parentRef ].child[ ref ].unlockType == eUnlockType.FACTION_LEVEL )

		if ( file.unlocks[ parentRef ].child[ ref ].additionalRef != faction )
			return false

		return factionLevel < file.unlocks[ parentRef ].child[ ref ].unlockLevel
	}
	else
	{
		Assert( ref in file.unlocks )
		Assert( file.unlocks[ref].parentRef == parentRef )
		Assert( file.unlocks[ ref ].unlockType == eUnlockType.FACTION_LEVEL )

		if ( file.unlocks[ ref ].additionalRef != faction )
			return false

		return factionLevel < file.unlocks[ ref ].unlockLevel
	}

	unreachable
}

bool function IsItemLockedForPlayerLevel( int playerLevel, string ref )
{
	Assert( ref in file.unlocks )
	Assert( file.unlocks[ ref ].unlockType == eUnlockType.PLAYER_LEVEL )

	return (playerLevel < file.unlocks[ ref ].unlockLevel)
}

bool function IsItemLockedForFrontierDefense( entity player, string ref, string parentRef )
{
	return IsItemLockedForFDTitanLevel( FD_TitanGetRawLevel( player, parentRef ), ref, parentRef )
}

bool function IsItemLockedForTitan( entity player, string ref, string parentRef )
{
	return IsItemLockedForTitanLevel( TitanGetRawLevel( player, parentRef ), ref, parentRef )
}


bool function IsItemLockedForWeapon( entity player, string ref, string parentRef )
{
	return IsItemLockedForWeaponLevel( WeaponGetRawLevel( player, parentRef ), ref, parentRef )
}

bool function IsItemLockedForFaction( entity player, string ref, string parentRef )
{
	int enumCount =	PersistenceGetEnumCount( "faction" )
	for ( int i = 0; i < enumCount; i++ )
	{
		string faction = PersistenceGetEnumItemNameForIndex( "faction", i )
		if ( faction == "" )
			continue

		if ( IsItemLockedForFactionLevel( FactionGetRawLevel( player, faction ), faction, ref, parentRef ) )
			return true
	}

	return false
}

bool function IsItemLockedForPlayer( entity player, string ref )
{
	int rawLevel = GetUnlockLevelReq( ref )

	if ( rawLevel > GetMaxPlayerLevel() || ItemLockedShouldUseRawLevel( ref ) )
	{
		int playerGen = player.GetGen()
		int rawPlayerLevel = (playerGen - 1) * GetMaxPlayerLevel() + player.GetLevel()
		return IsItemLockedForPlayerLevel( rawPlayerLevel, ref )
	}
	else
	{
		return IsItemLockedForPlayerLevel( player.GetLevel(), ref )
	}

	unreachable
}

bool function ItemLockedShouldUseRawLevel( string ref )
{
	int refType = GetItemType( ref )

	bool shouldUseRawLevel = true

	switch ( refType )
	{
		case eItemTypes.PILOT_PRIMARY:
		case eItemTypes.PILOT_SECONDARY:
		case eItemTypes.PILOT_SPECIAL:
		case eItemTypes.PILOT_ORDNANCE:
		case eItemTypes.PILOT_PRIMARY_ATTACHMENT:
		case eItemTypes.PILOT_PRIMARY_MOD:
		case eItemTypes.PILOT_SECONDARY_MOD:
		case eItemTypes.PILOT_WEAPON_MOD3:
		case eItemTypes.PILOT_PASSIVE1:
		case eItemTypes.PILOT_PASSIVE2:
		case eItemTypes.TITAN_PRIMARY:
		case eItemTypes.TITAN_SPECIAL:
		case eItemTypes.TITAN_ANTIRODEO:
		case eItemTypes.TITAN_ORDNANCE:
		case eItemTypes.TITAN_PRIMARY_MOD:
		case eItemTypes.TITAN_OS:
		case eItemTypes.RACE:
		case eItemTypes.NOT_LOADOUT:
		case eItemTypes.PILOT_SUIT:
		case eItemTypes.TITAN_CORE_ABILITY:
		case eItemTypes.BURN_METER_REWARD:
		case eItemTypes.PILOT_MELEE:
		case eItemTypes.TITAN:
		case eItemTypes.PRIME_TITAN:
		case eItemTypes.FEATURE:
		case eItemTypes.WEAPON_FEATURE:
		case eItemTypes.SUB_PILOT_WEAPON_MOD:
		case eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT:
		case eItemTypes.FACTION:
		case eItemTypes.PILOT_EXECUTION:
		case eItemTypes.TITAN_FD_UPGRADE:
			shouldUseRawLevel = false
	}

	return shouldUseRawLevel
}

bool function IsItemLockedForStat( entity player, string ref )
{
	Assert( ref in file.unlocks )
	Assert( file.unlocks[ ref ].unlockType == eUnlockType.STAT )

	Unlock unlock = file.unlocks[ ref ]
	int statType = expect int( unlock.additionalData.statType )
	string statCategory = expect string( unlock.additionalData.statCategory )
	string statAlias = expect string( unlock.additionalData.statAlias )
	string statSubAlias = expect string( unlock.additionalData.statSubAlias )

	if ( statType == ePlayerStatType.INT )
		return ( GetPlayerStatInt( player, statCategory, statAlias, statSubAlias ) < unlock.unlockIntVal )
	else
		return ( GetPlayerStatFloat( player, statCategory, statAlias, statSubAlias ) < unlock.unlockFloatVal )

	unreachable
}


bool function IsSubItemLockedForStat( entity player, string ref, string parentRef )
{
	Assert( parentRef in file.unlocks )
	Assert( ref in file.unlocks[parentRef].child )
	Assert( file.unlocks[ parentRef ].child[ref].unlockType == eUnlockType.STAT )

	ChildUnlock unlock = file.unlocks[ parentRef ].child[ref]
	int statType = expect int( unlock.additionalData.statType )
	string statCategory = expect string( unlock.additionalData.statCategory )
	string statAlias = expect string( unlock.additionalData.statAlias )
	string statSubAlias = expect string( unlock.additionalData.statSubAlias )

	if ( statType == ePlayerStatType.INT )
		return ( GetPlayerStatInt( player, statCategory, statAlias, statSubAlias ) < unlock.unlockIntVal )
	else
		return ( GetPlayerStatFloat( player, statCategory, statAlias, statSubAlias ) < unlock.unlockFloatVal )

	unreachable
}



int function GetItemPersistenceId( string ref, string parentRef = "" )
{
	Assert( ref in file.itemData )
	return file.itemData[ref].persistenceId
}


string function GetItemPersistenceStruct( string ref )
{
	Assert( ref in file.itemData )
	return file.itemData[ref].persistenceStruct
}

ItemData ornull function GetItemFromPersistenceStruct( string persistenceStruct )
{
	if ( !( persistenceStruct in file.itemsWithPersistenceStruct ) )
		return null // arrays in persistence may be bigger than the data loaded so persistenceStruct may not exist

	return file.itemsWithPersistenceStruct[ persistenceStruct ]
}

bool function IsItemNew( entity player, string ref, string parentRef = "" )
{
	Assert( IsValid( player ) )

	ItemData itemData = GetItemData( ref )
	int refType = itemData.itemType

	if ( !IsSubItemType( refType ) )
	{
		int bitIndex = GetItemPersistenceId( ref )
		string persistenceVar

		switch ( refType )
		{
			case eItemTypes.PILOT_PRIMARY:
			case eItemTypes.PILOT_SECONDARY:
				persistenceVar = "newPilotWeapons"
				break

			case eItemTypes.PILOT_SPECIAL:
			case eItemTypes.PILOT_ORDNANCE:
				persistenceVar = "newPilotOffhands"
				break

			case eItemTypes.PILOT_PASSIVE1:
			case eItemTypes.PILOT_PASSIVE2:
				persistenceVar = "newPilotPassives"
				break

			case eItemTypes.PILOT_SUIT:
				persistenceVar = "newPilotSuits"
				break

			case eItemTypes.PILOT_EXECUTION:
				persistenceVar = "newPilotExecutions"
				break

			case eItemTypes.TITAN_ION_EXECUTION:
			case eItemTypes.TITAN_TONE_EXECUTION:
			case eItemTypes.TITAN_SCORCH_EXECUTION:
			case eItemTypes.TITAN_LEGION_EXECUTION:
			case eItemTypes.TITAN_RONIN_EXECUTION:
			case eItemTypes.TITAN_NORTHSTAR_EXECUTION:
			case eItemTypes.TITAN_VANGUARD_EXECUTION:
				persistenceVar = "newTitanExecutions"
				break

			case eItemTypes.TITAN_SPECIAL:
			case eItemTypes.TITAN_ORDNANCE:
			case eItemTypes.TITAN_ANTIRODEO:
				persistenceVar = "newTitanOffhands"
				break

			case eItemTypes.TITAN:
				persistenceVar = "newTitanChassis"
				break

			case eItemTypes.PRIME_TITAN:
				persistenceVar = "newPrimeTitans"
				break

			case eItemTypes.FEATURE:
				persistenceVar = "newFeatures"
				break

			case eItemTypes.CAMO_SKIN_PILOT:
				persistenceVar = "newPilotSkins"
				break

			case eItemTypes.BURN_METER_REWARD:
				persistenceVar = "newBoosts"
				break

			case eItemTypes.FACTION:
				persistenceVar = "newFactions"
				break

			case eItemTypes.CALLING_CARD:
				persistenceVar = "newCallingCards"
				break

			case eItemTypes.CALLSIGN_ICON:
				persistenceVar = "newCallsignIcons"
				break

			case eItemTypes.COMMS_ICON:
				persistenceVar = "newCommsIcons"
				break

			default:
				CodeWarning( "Unhandled new type: " + DEV_GetEnumStringFromIndex( "eItemTypes", refType ) + " " + ref )
		}

		if ( persistenceVar != "" )
		{
			#if UI
				return IsCachedPersistenceBitSet( persistenceVar, bitIndex )
			#endif
			return IsPersistenceBitSet( player, persistenceVar, bitIndex )
		}
	}
	else
	{
		if ( IsItemLocked( player, parentRef ) )
			return false

		int bitIndex = GetItemPersistenceId( ref, parentRef )
		string persistenceVar

		switch ( refType )
		{
			case eItemTypes.PILOT_PRIMARY_ATTACHMENT:
			case eItemTypes.PILOT_PRIMARY_MOD:
			case eItemTypes.PILOT_SECONDARY_MOD:
			case eItemTypes.PILOT_WEAPON_MOD3:
			case eItemTypes.SUB_PILOT_WEAPON_MOD:
			case eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT:
				persistenceVar = GetItemPersistenceStruct( parentRef ) + ".newMods"
				break

			case eItemTypes.WEAPON_FEATURE:
				persistenceVar = GetItemPersistenceStruct( parentRef ) + ".newFeatures"
				break

			case eItemTypes.WEAPON_SKIN:
				persistenceVar = GetItemPersistenceStruct( parentRef ) + ".newPrimeWeaponSkins"
				break

			case eItemTypes.TITAN_GENERAL_PASSIVE:
			case eItemTypes.TITAN_TITANFALL_PASSIVE:
			case eItemTypes.TITAN_RONIN_PASSIVE:
			case eItemTypes.TITAN_NORTHSTAR_PASSIVE:
			case eItemTypes.TITAN_ION_PASSIVE:
			case eItemTypes.TITAN_TONE_PASSIVE:
			case eItemTypes.TITAN_SCORCH_PASSIVE:
			case eItemTypes.TITAN_LEGION_PASSIVE:
			case eItemTypes.TITAN_VANGUARD_PASSIVE:
			case eItemTypes.TITAN_UPGRADE1_PASSIVE:
			case eItemTypes.TITAN_UPGRADE2_PASSIVE:
			case eItemTypes.TITAN_UPGRADE3_PASSIVE:
				persistenceVar = GetItemPersistenceStruct( parentRef ) + ".newPassives"
				break

			case eItemTypes.CAMO_SKIN_TITAN:
				persistenceVar = GetItemPersistenceStruct( parentRef ) + ".newSkins"
				break

			case eItemTypes.TITAN_WARPAINT:
				persistenceVar = GetItemPersistenceStruct( parentRef ) + ".newPrimeSkins" //TODO: This is actually warpaints. Rename next game
				break

			case eItemTypes.CAMO_SKIN:
				persistenceVar = GetItemPersistenceStruct( parentRef ) + ".newWeaponSkins"
				break

			case eItemTypes.TITAN_NOSE_ART:
					persistenceVar = GetItemPersistenceStruct( parentRef ) + ".newTitanDecals"
				break

			case eItemTypes.PRIME_TITAN_NOSE_ART:
					persistenceVar = GetItemPersistenceStruct( parentRef ) + ".newPrimeTitanDecals"
				break

			case eItemTypes.TITAN_FD_UPGRADE:
					persistenceVar = GetItemPersistenceStruct( parentRef ) + ".newFDUpgrades"
				break

			default:
				CodeWarning( "Unhandled new type (subitem) 1: " + DEV_GetEnumStringFromIndex( "eItemTypes", refType ) + " " + ref + " " + parentRef )
		}

		#if UI
			return IsCachedPersistenceBitSet( persistenceVar, bitIndex )
		#endif
		return IsPersistenceBitSet( player, persistenceVar, bitIndex )
	}

	unreachable
}

#if UI
void function UpdateCachedNewItems()
{
	if ( !uiGlobal.updateCachedNewItems )
	{
		uiGlobal.updateCachedNewItems = true
		return
	}

	file.cachedNewItems.clear()

	UpdateCachedNewItemsStruct( "pilotWeapons", "newMods" )
	UpdateCachedNewItemsStruct( "pilotWeapons", "newWeaponSkins" )
	UpdateCachedNewItemsStruct( "pilotWeapons", "newPrimeWeaponSkins" )
	UpdateCachedNewItemsStruct( "pilotWeapons", "newFeatures" )
	UpdateCachedNewItemsStruct( "titanChassis", "newPassives" )
	UpdateCachedNewItemsStruct( "titanChassis", "newSkins" )
	UpdateCachedNewItemsStruct( "titanChassis", "newPrimeSkins" ) //TODO: This is actually WarPaint, rename next game.
	UpdateCachedNewItemsStruct( "titanChassis", "newWeaponSkins" )
	UpdateCachedNewItemsStruct( "titanChassis", "newTitanDecals" )
	UpdateCachedNewItemsStruct( "titanChassis", "newPrimeTitanDecals" )
	UpdateCachedNewItemsStruct( "titanChassis", "newFDUpgrades" )
	UpdateCachedNewItemsArray( "newPilotSkins" )
	UpdateCachedNewItemsArray( "newPilotWeapons" )
	UpdateCachedNewItemsArray( "newPilotOffhands" )
	UpdateCachedNewItemsArray( "newPilotPassives" )
	UpdateCachedNewItemsArray( "newTitanOffhands" )
	UpdateCachedNewItemsArray( "newTitanPassives" )
	UpdateCachedNewItemsArray( "newTitanChassis" )
	UpdateCachedNewItemsArray( "newPrimeTitans" )
	UpdateCachedNewItemsArray( "newPilotSuits" )
	UpdateCachedNewItemsArray( "newPilotExecutions" )
	UpdateCachedNewItemsArray( "newTitanExecutions" )
	UpdateCachedNewItemsArray( "newFeatures" )
	UpdateCachedNewItemsArray( "newBoosts" )
	UpdateCachedNewItemsArray( "newFactions" )
	UpdateCachedNewItemsArray( "newCallingCards" )
	UpdateCachedNewItemsArray( "newCallsignIcons" )
	UpdateCachedNewItemsArray( "newCommsIcons" )
}

int function GetCachedNewItemsVar( string persistenceVar )
{
	return file.cachedNewItems[ persistenceVar ]
}

void function SetCachedPersistenceBitfield( string persistenceVar, int bitIndex, int value )
{
	Assert( value == 0 || value == 1 )

	int arrayIndex = bitIndex / 32;
	int bitOffset = bitIndex % 32;

	int decimalValue = 1 << bitOffset

	persistenceVar = persistenceVar + "[" + arrayIndex + "]"

	int currentVal = file.cachedNewItems[ persistenceVar ]
	if ( value == 0 )
		file.cachedNewItems[ persistenceVar ] = currentVal & ~decimalValue
	else
		file.cachedNewItems[ persistenceVar ] = currentVal | decimalValue

	//printt( "file.cachedNewItems[  " + persistenceVar + " ] bitIndex:" + bitIndex + " val:" + value )
}

bool function IsCachedPersistenceBitSet( string persistenceVar, int bitIndex )
{
	int arrayIndex = bitIndex / 32;
	int bitOffset = bitIndex % 32;

	int decimalValue = 1 << bitOffset

	persistenceVar = persistenceVar + "[" + arrayIndex + "]"

	//printt( "IsCachedPersistenceBitSet( " + persistenceVar + ", " + bitIndex + " ) " + ( ( file.cachedNewItems[ persistenceVar ] & decimalValue ) != 0 ) )

	Assert( arrayIndex < PersistenceGetArrayCount( persistenceVar ), "Need to increase the array size of the persistenceVar " + persistenceVar )

	return ( ( file.cachedNewItems[ persistenceVar ] & decimalValue ) != 0 )
}

void function UpdateCachedNewItemsArray( string arrayVar )
{
	int arrayCount = PersistenceGetArrayCount( arrayVar )
	for ( int i = 0; i < arrayCount; i++ )
	{
		string persistenceVar = arrayVar + "[" + i + "]"
		file.cachedNewItems[ persistenceVar ] <- GetPersistentVarAsInt( persistenceVar )
	}
}

void function UpdateCachedNewItemsStruct( string newStruct, string structVar )
{
	int newStructArrayCount = PersistenceGetArrayCount( newStruct )
	for ( int i = 0; i < newStructArrayCount; i++ )
	{
		string arrayVar = newStruct + "[" + i + "]." + structVar

		int structVarArrayCount = PersistenceGetArrayCount( arrayVar )
		for ( int j = 0; j < structVarArrayCount; j++ )
		{
			string persistenceVar = arrayVar + "[" + j + "]"
			file.cachedNewItems[ persistenceVar ] <- GetPersistentVarAsInt( persistenceVar )
		}
	}
}

void function ClearNewStatus( var button, string ref, string parentRef = "" )
{
	if ( ref == "" || ref == "none" )
		return

	Assert( parentRef == "" || ( parentRef != "" && IsSubItemType( GetItemType( ref ) ) ) )

	if ( button != null )
		Hud_SetNew( button, false )

	ItemData itemData = GetItemData( ref )
	int refType = itemData.itemType

	if ( !IsSubItemType( refType ) )
	{
		int bitIndex = GetItemPersistenceId( ref )

		switch ( refType )
		{
			case eItemTypes.PILOT_PRIMARY:
			case eItemTypes.PILOT_SECONDARY:
				SetCachedPersistenceBitfield( "newPilotWeapons", bitIndex, 0 )
				break

			case eItemTypes.PILOT_SPECIAL:
			case eItemTypes.PILOT_ORDNANCE:
				SetCachedPersistenceBitfield( "newPilotOffhands", bitIndex, 0 )
				break

			case eItemTypes.PILOT_PASSIVE1:
			case eItemTypes.PILOT_PASSIVE2:
				SetCachedPersistenceBitfield( "newPilotPassives", bitIndex, 0 )
				break

			case eItemTypes.PILOT_SUIT:
				SetCachedPersistenceBitfield( "newPilotSuits", bitIndex, 0 )
				break

			case eItemTypes.PILOT_EXECUTION:
				SetCachedPersistenceBitfield( "newPilotExecutions", bitIndex, 0 )
				break

			case eItemTypes.TITAN_RONIN_EXECUTION:
			case eItemTypes.TITAN_NORTHSTAR_EXECUTION:
			case eItemTypes.TITAN_ION_EXECUTION:
			case eItemTypes.TITAN_TONE_EXECUTION:
			case eItemTypes.TITAN_SCORCH_EXECUTION:
			case eItemTypes.TITAN_LEGION_EXECUTION:
			case eItemTypes.TITAN_VANGUARD_EXECUTION:
				SetCachedPersistenceBitfield( "newTitanExecutions", bitIndex, 0 )
				break


			case eItemTypes.TITAN_SPECIAL:
			case eItemTypes.TITAN_ORDNANCE:
				SetCachedPersistenceBitfield( "newTitanOffhands", bitIndex, 0 )
				break

			case eItemTypes.TITAN:
				SetCachedPersistenceBitfield( "newTitanChassis", bitIndex, 0 )
				break

			case eItemTypes.PRIME_TITAN:
				SetCachedPersistenceBitfield( "newPrimeTitans", bitIndex, 0 )
				break

			case eItemTypes.FEATURE:
				SetCachedPersistenceBitfield( "newFeatures", bitIndex, 0 )
				break

			case eItemTypes.CAMO_SKIN_PILOT:
				SetCachedPersistenceBitfield( "newPilotSkins", bitIndex, 0 )
				break

			case eItemTypes.BURN_METER_REWARD:
				SetCachedPersistenceBitfield( "newBoosts", bitIndex, 0 )
				break

			case eItemTypes.FACTION:
				SetCachedPersistenceBitfield( "newFactions", bitIndex, 0 )
				break

			case eItemTypes.CALLING_CARD:
				SetCachedPersistenceBitfield( "newCallingCards", bitIndex, 0 )
				break

			case eItemTypes.CALLSIGN_ICON:
				SetCachedPersistenceBitfield( "newCallsignIcons", bitIndex, 0 )
				break

			case eItemTypes.COMMS_ICON:
				SetCachedPersistenceBitfield( "newCommsIcons", bitIndex, 0 )
				break

			default:
				CodeWarning( "Unhandled ClearNewStatus type: " + DEV_GetEnumStringFromIndex( "eItemTypes", refType ) + " " + ref )
		}
	}
	else
	{
		int bitIndex = GetItemPersistenceId( ref, parentRef )
		switch ( refType )
		{
			case eItemTypes.PILOT_PRIMARY_ATTACHMENT:
			case eItemTypes.PILOT_PRIMARY_MOD:
			case eItemTypes.PILOT_SECONDARY_MOD:
			case eItemTypes.PILOT_WEAPON_MOD3:
			case eItemTypes.SUB_PILOT_WEAPON_MOD:
			case eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetCachedPersistenceBitfield( parentStruct + ".newMods", bitIndex, 0 )
				break

			case eItemTypes.WEAPON_FEATURE:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetCachedPersistenceBitfield( parentStruct + ".newFeatures", bitIndex, 0 )
				break

			case eItemTypes.WEAPON_SKIN:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetCachedPersistenceBitfield( parentStruct + ".newPrimeWeaponSkins", bitIndex, 0 )
				break

			case eItemTypes.TITAN_GENERAL_PASSIVE:
			case eItemTypes.TITAN_TITANFALL_PASSIVE:
			case eItemTypes.TITAN_RONIN_PASSIVE:
			case eItemTypes.TITAN_NORTHSTAR_PASSIVE:
			case eItemTypes.TITAN_ION_PASSIVE:
			case eItemTypes.TITAN_TONE_PASSIVE:
			case eItemTypes.TITAN_SCORCH_PASSIVE:
			case eItemTypes.TITAN_LEGION_PASSIVE:
			case eItemTypes.TITAN_VANGUARD_PASSIVE:
			case eItemTypes.TITAN_UPGRADE1_PASSIVE:
			case eItemTypes.TITAN_UPGRADE2_PASSIVE:
			case eItemTypes.TITAN_UPGRADE3_PASSIVE:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetCachedPersistenceBitfield( parentStruct + ".newPassives", bitIndex, 0 )
				break

			case eItemTypes.CAMO_SKIN_TITAN:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetCachedPersistenceBitfield( parentStruct + ".newSkins", bitIndex, 0 )
				break

			case eItemTypes.TITAN_WARPAINT:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetCachedPersistenceBitfield( parentStruct + ".newPrimeSkins", bitIndex, 0 ) //TODO: This is actually WarPaint, rename next game.
				break

			case eItemTypes.CAMO_SKIN:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetCachedPersistenceBitfield( parentStruct + ".newWeaponSkins", bitIndex, 0 )
				break

			case eItemTypes.TITAN_NOSE_ART:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetCachedPersistenceBitfield( parentStruct + ".newTitanDecals", bitIndex, 0 )
				break

			case eItemTypes.PRIME_TITAN_NOSE_ART:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetCachedPersistenceBitfield( parentStruct + ".newPrimeTitanDecals", bitIndex, 0 )
				break

			case eItemTypes.TITAN_FD_UPGRADE:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetCachedPersistenceBitfield( parentStruct + ".newFDUpgrades", bitIndex, 0 )
				break

			default:
				CodeWarning( "Unhandled ClearNewStatus type (subitem): " + DEV_GetEnumStringFromIndex( "eItemTypes", refType ) + " " + ref + " " + parentRef )
		}
	}

	ClientCommand( "ClearNewStatus " + ref + " " + parentRef )
}

bool function HasAnyNewPilotLoadout( entity player )
{
	for ( int i = 1; i <= 10; i++ )
	{
		if ( IsItemNew( player, "pilot_loadout_" + i ) )
			return true

		PilotLoadoutDef loadout = GetCachedPilotLoadout( i - 1 )
		if ( loadout.primary != "" && RefHasAnyNewSubitem( player, loadout.primary ) )
			return true

		if ( loadout.secondary != "" && RefHasAnyNewSubitem( player, loadout.secondary ) )
			return true

		if ( loadout.weapon3 != "" && RefHasAnyNewSubitem( player, loadout.weapon3 ) )
			return true
	}

	return false
}

bool function HasAnyNewPilotItems( entity player )
{
	if ( HasAnyNewItemOfType( player, eItemTypes.PILOT_PRIMARY ) ||
		 HasAnyNewItemOfType( player, eItemTypes.PILOT_SECONDARY ) ||
		 HasAnyNewItemOfType( player, eItemTypes.PILOT_ORDNANCE ) ||
		 HasAnyNewItemOfType( player, eItemTypes.PILOT_PASSIVE1 ) ||
		 HasAnyNewItemOfType( player, eItemTypes.PILOT_PASSIVE2 ) ||
		 HasAnyNewItemOfType( player, eItemTypes.PILOT_SUIT ) ||
		 HasAnyNewItemOfType( player, eItemTypes.PILOT_EXECUTION ) ||
		 HasAnyNewItemOfType( player, eItemTypes.CAMO_SKIN_PILOT ) ||
		 HasAnyNewPilotLoadout( player ) )
		return true

	return false
}

bool function HasAnyNewTitanItems( entity player )
{
	if ( HasAnyNewItemOfType( player, eItemTypes.TITAN ) ||
		 HasAnyNewItemOfType( player, eItemTypes.PRIME_TITAN ) )
		return true

	return false
}

bool function HasAnyNewDpadCommsIcons( entity player )
{
	return HasAnyNewItemOfType( player, eItemTypes.COMMS_ICON )
}

bool function HasAnyNewBoosts( entity player )
{
	return HasAnyNewItemOfType( player, eItemTypes.BURN_METER_REWARD )
}

bool function HasAnyNewFactions( entity player )
{
	return HasAnyNewItemOfType( player, eItemTypes.FACTION )
}

bool function HasAnyNewCallsignBanners( entity player )
{
	return HasAnyNewItemOfType( player, eItemTypes.CALLING_CARD )
}

bool function HasAnyNewCallsignPatches( entity player )
{
	return HasAnyNewItemOfType( player, eItemTypes.CALLSIGN_ICON )
}

bool function HasAnyNewArmoryItems( entity player )
{
	if ( HasAnyNewItemOfType( player, eItemTypes.BURN_METER_REWARD ) ||
		 HasAnyNewItemOfType( player, eItemTypes.FACTION ) ||
		 HasAnyNewItemOfType( player, eItemTypes.CALLING_CARD ) ||
		 HasAnyNewItemOfType( player, eItemTypes.CALLSIGN_ICON ) )
		return true

	return false
}

bool function ButtonShouldShowNew( int itemType, string ref = "", string parentRef = "" )
{
	entity player = GetUIPlayer()
	if ( !IsValid( player ) )
		return false

	string menu = expect string( uiGlobal.activeMenu._name )

	switch ( itemType )
	{
		case eItemTypes.PILOT_PRIMARY:
		case eItemTypes.PILOT_SECONDARY:
			if ( menu == "EditPilotLoadoutsMenu" )
				return HasAnyNewItemOfType( player, itemType, -1, ref ) || RefHasAnyNewSubitem( player, ref, eItemTypes.CAMO_SKIN ) || RefHasAnyNewSubitem( player, ref, eItemTypes.WEAPON_SKIN )
			else if ( menu == "EditPilotLoadoutMenu" ||
					  menu == "EditTitanLoadoutsMenu" || menu == "EditTitanLoadoutMenu" ||
					  menu == "PilotLoadoutsMenu" || menu == "TitanLoadoutsMenu" )
				return HasAnyNewItemOfType( player, itemType, -1, ref )
			else
				return ( IsItemNew( player, ref ) ||
						RefHasAnyNewSubitem( player, ref, eItemTypes.PILOT_PRIMARY_ATTACHMENT ) ||
						RefHasAnyNewSubitem( player, ref, eItemTypes.PILOT_PRIMARY_MOD ) ||
						RefHasAnyNewSubitem( player, ref, eItemTypes.PILOT_SECONDARY_MOD ) ||
						RefHasAnyNewSubitem( player, ref, eItemTypes.PILOT_WEAPON_MOD3 ) ||
						RefHasAnyNewSubitem( player, ref, eItemTypes.SUB_PILOT_WEAPON_MOD ) ||
						RefHasAnyNewSubitem( player, ref, eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT ) )

		case eItemTypes.PILOT_SPECIAL:
		case eItemTypes.PILOT_ORDNANCE:
		case eItemTypes.PILOT_PASSIVE1:
		case eItemTypes.PILOT_PASSIVE2:
		case eItemTypes.PILOT_SUIT:
		case eItemTypes.PILOT_EXECUTION:
		case eItemTypes.CAMO_SKIN_PILOT:
		case eItemTypes.TITAN_SPECIAL:
		case eItemTypes.TITAN_ORDNANCE:
		case eItemTypes.TITAN_ANTIRODEO:
		case eItemTypes.BURN_METER_REWARD:
		case eItemTypes.FACTION:
		case eItemTypes.CALLING_CARD:
		case eItemTypes.CALLSIGN_ICON:
		case eItemTypes.TITAN_ION_EXECUTION:
		case eItemTypes.TITAN_TONE_EXECUTION:
		case eItemTypes.TITAN_SCORCH_EXECUTION:
		case eItemTypes.TITAN_LEGION_EXECUTION:
		case eItemTypes.TITAN_RONIN_EXECUTION:
		case eItemTypes.TITAN_NORTHSTAR_EXECUTION:
		case eItemTypes.TITAN_VANGUARD_EXECUTION:
			if ( menu == "EditPilotLoadoutsMenu" || menu == "EditPilotLoadoutMenu" ||
				 menu == "EditTitanLoadoutsMenu" || menu == "EditTitanLoadoutMenu" ||
				 menu == "PilotLoadoutsMenu" || menu == "TitanLoadoutsMenu" ||
				 menu == "ArmoryMenu" )
				return HasAnyNewItemOfType( player, itemType )
			else
				return IsItemNew( player, ref )

		case eItemTypes.FEATURE:
		case eItemTypes.COMMS_ICON:
			return IsItemNew( player, ref )

		case eItemTypes.TITAN:
		case eItemTypes.PRIME_TITAN:
			return IsItemNew( player, ref ) || RefHasAnyNewSubitem( player, ref )

		case eItemTypes.CAMO_SKIN:
		case eItemTypes.WEAPON_SKIN:
		case eItemTypes.PILOT_PRIMARY_ATTACHMENT:
		case eItemTypes.PILOT_PRIMARY_MOD:
		case eItemTypes.PILOT_SECONDARY_MOD:
		case eItemTypes.PILOT_WEAPON_MOD3:
		case eItemTypes.SUB_PILOT_WEAPON_MOD:
		case eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT:
		case eItemTypes.TITAN_GENERAL_PASSIVE:
		case eItemTypes.TITAN_TITANFALL_PASSIVE:
		case eItemTypes.TITAN_RONIN_PASSIVE:
		case eItemTypes.TITAN_NORTHSTAR_PASSIVE:
		case eItemTypes.TITAN_ION_PASSIVE:
		case eItemTypes.TITAN_TONE_PASSIVE:
		case eItemTypes.TITAN_SCORCH_PASSIVE:
		case eItemTypes.TITAN_LEGION_PASSIVE:
		case eItemTypes.TITAN_VANGUARD_PASSIVE:
		case eItemTypes.TITAN_UPGRADE1_PASSIVE:
		case eItemTypes.TITAN_UPGRADE2_PASSIVE:
		case eItemTypes.TITAN_UPGRADE3_PASSIVE:
		case eItemTypes.CAMO_SKIN_TITAN:
		case eItemTypes.TITAN_WARPAINT:
		case eItemTypes.TITAN_NOSE_ART:
		case eItemTypes.PRIME_TITAN_NOSE_ART:
			Assert( parentRef != "" )
			if ( menu == "EditPilotLoadoutsMenu" || menu == "EditPilotLoadoutMenu" ||
				 menu == "EditTitanLoadoutsMenu" || menu == "EditTitanLoadoutMenu" ||
				 menu == "PilotLoadoutsMenu" || menu == "TitanLoadoutsMenu" )
				return RefHasAnyNewSubitem( player, parentRef, itemType )
			else
				return IsItemNew( player, ref, parentRef )

		case eItemTypes.WEAPON_FEATURE:
			return IsItemNew( player, ref, parentRef )

		case eItemTypes.RACE:
		case eItemTypes.PILOT_MELEE:
		case eItemTypes.TITAN_FD_UPGRADE:
			return false
	}

	unreachable
}

bool function RefHasAnyNewSubitem( entity player, string ref, int subitemType = -1 )
{
	if ( IsItemLocked( player, ref ) )
		return false

	int refType = GetItemType( ref )
	bool isPrimeTitanRef = ( refType == eItemTypes.TITAN && IsTitanClassPrime( player, ref ) )

	ItemData itemData = GetItemData( ref )
	foreach ( subitem in itemData.subitems )
	{
		if ( subitemType != -1 && GetSubitemType( ref, subitem.ref ) != subitemType )
			continue

		if ( isPrimeTitanRef && subitem.itemType == eItemTypes.TITAN_WARPAINT )
			continue

		if ( IsItemNew( player, subitem.ref, ref ) )
			return true
	}

	return false
}

bool function HasAnyNewItemOfCategory( entity player, int refType, int categoryIndex )
{
	array<ItemData> items = GetAllItemsOfType( refType )
	foreach ( item in items )
	{
		if ( item.i.menuCategory != categoryIndex )
			continue

		if ( IsItemNew( player, item.ref ) )
			return true

		//if ( RefHasAnyNewSubitem( player, item.ref ) )
		//	return true
	}

	return false
}

bool function HasAnyNewSubItemOfType( entity player, string parentRef, int refType )
{
	switch ( refType )
	{
		case eItemTypes.PILOT_PRIMARY_ATTACHMENT:
		case eItemTypes.PILOT_PRIMARY_MOD:
		case eItemTypes.PILOT_SECONDARY_MOD:
		case eItemTypes.PILOT_WEAPON_MOD3:
		case eItemTypes.SUB_PILOT_WEAPON_MOD:
		case eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsAnyPersistenceBitSet( player, parentStruct + ".newMods" )

		case eItemTypes.WEAPON_FEATURE:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsAnyPersistenceBitSet( player, parentStruct + ".newFeatures" )

		case eItemTypes.WEAPON_SKIN:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsAnyPersistenceBitSet( player, parentStruct + ".newPrimeWeaponSkins" )

		case eItemTypes.TITAN_GENERAL_PASSIVE:
		case eItemTypes.TITAN_TITANFALL_PASSIVE:
		case eItemTypes.TITAN_RONIN_PASSIVE:
		case eItemTypes.TITAN_NORTHSTAR_PASSIVE:
		case eItemTypes.TITAN_ION_PASSIVE:
		case eItemTypes.TITAN_TONE_PASSIVE:
		case eItemTypes.TITAN_SCORCH_PASSIVE:
		case eItemTypes.TITAN_LEGION_PASSIVE:
		case eItemTypes.TITAN_VANGUARD_PASSIVE:
		case eItemTypes.TITAN_UPGRADE1_PASSIVE:
		case eItemTypes.TITAN_UPGRADE2_PASSIVE:
		case eItemTypes.TITAN_UPGRADE3_PASSIVE:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsAnyPersistenceBitSet( player, parentStruct + ".newPassives" )

		case eItemTypes.CAMO_SKIN_TITAN:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsAnyPersistenceBitSet( player, parentStruct + ".newSkins" )

		case eItemTypes.TITAN_WARPAINT:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsAnyPersistenceBitSet( player, parentStruct + ".newPrimeSkins" ) //TODO: This is actually WarPaint, rename next game.

		case eItemTypes.CAMO_SKIN:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsAnyPersistenceBitSet( player, parentStruct + ".newWeaponSkins" )

		case eItemTypes.TITAN_NOSE_ART:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsAnyPersistenceBitSet( player, parentStruct + ".newTitanDecals" )

		case eItemTypes.PRIME_TITAN_NOSE_ART:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsAnyPersistenceBitSet( player, parentStruct + ".newPrimeTitanDecals" )

		case eItemTypes.TITAN_FD_UPGRADE:
			string parentStruct = GetItemPersistenceStruct( parentRef )
			return IsAnyPersistenceBitSet( player, parentStruct + ".newFDUpgrades" )

		default:
			CodeWarning( "Unhandled HasAnyNewSubItemOfType type (subitem): " + DEV_GetEnumStringFromIndex( "eItemTypes", refType ) + " " + parentRef )
	}

	return false
}

bool function HasAnyNewItemOfType( entity player, int refType, int parentRefType = -1, string refToExclude = "" )
{
	if ( !IsSubItemType( refType ) )
	{
		array<ItemData> items = GetAllItemsOfType( refType )
		foreach ( item in items )
		{
			if ( item.ref == refToExclude )
				continue

			if ( IsItemLocked( player, item.ref ) )
				continue

			if ( IsItemNew( player, item.ref ) )
				return true

			table<int, bool> checkedSubItemTypes = {}

			if ( refType == eItemTypes.PILOT_PRIMARY || refType == eItemTypes.PILOT_SECONDARY )
				continue

			bool isPrimeTitanRef = ( refType == eItemTypes.TITAN && IsTitanClassPrime( player, item.ref ) )

			foreach ( subItem in item.subitems )
			{
				if ( isPrimeTitanRef && subItem.itemType == eItemTypes.TITAN_WARPAINT )
					continue

				if ( subItem.itemType in checkedSubItemTypes )
					continue

				if ( HasAnyNewSubItemOfType( player, item.ref, subItem.itemType ) )
					return true

				checkedSubItemTypes[subItem.itemType] <- true
			}
		}
	}
	else
	{
		string persistenceArray
		string persistenceVar

		switch ( refType )
		{
			case eItemTypes.PILOT_PRIMARY_ATTACHMENT:
			case eItemTypes.PILOT_PRIMARY_MOD:
			case eItemTypes.PILOT_SECONDARY_MOD:
			case eItemTypes.PILOT_WEAPON_MOD3:
			case eItemTypes.SUB_PILOT_WEAPON_MOD:
			case eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT:
				persistenceArray = "pilotWeapons"
				persistenceVar = "newMods"
				break

			case eItemTypes.WEAPON_FEATURE:
				persistenceArray = "pilotWeapons"
				persistenceVar = "newFeatures"
				break

			case eItemTypes.WEAPON_SKIN:
				persistenceArray = "pilotWeapons"
				persistenceVar = "newPrimeWeaponSkins"
				break

			case eItemTypes.TITAN_GENERAL_PASSIVE:
			case eItemTypes.TITAN_TITANFALL_PASSIVE:
			case eItemTypes.TITAN_RONIN_PASSIVE:
			case eItemTypes.TITAN_NORTHSTAR_PASSIVE:
			case eItemTypes.TITAN_ION_PASSIVE:
			case eItemTypes.TITAN_TONE_PASSIVE:
			case eItemTypes.TITAN_SCORCH_PASSIVE:
			case eItemTypes.TITAN_LEGION_PASSIVE:
			case eItemTypes.TITAN_VANGUARD_PASSIVE:
			case eItemTypes.TITAN_UPGRADE1_PASSIVE:
			case eItemTypes.TITAN_UPGRADE2_PASSIVE:
			case eItemTypes.TITAN_UPGRADE3_PASSIVE:
				persistenceArray = "titanChassis"
				persistenceVar = "newPassives"
				break

			case eItemTypes.CAMO_SKIN_TITAN:
				persistenceArray = "titanChassis"
				persistenceVar = "newSkins"
				break

			case eItemTypes.TITAN_WARPAINT:
				persistenceArray = "titanChassis"
				persistenceVar = "newPrimeSkins" //TODO: This is actually WarPaint, rename next game.
				break

			case eItemTypes.CAMO_SKIN:
				if ( parentRefType == eItemTypes.PILOT_PRIMARY || parentRefType == eItemTypes.PILOT_SECONDARY )
					persistenceArray = "pilotWeapons"
				else
					persistenceArray = "titanChassis"

				persistenceVar = "newWeaponSkins"
				break

			case eItemTypes.TITAN_NOSE_ART:
				persistenceArray = "titanChassis"
				persistenceVar = "newTitanDecals"
				break

			case eItemTypes.PRIME_TITAN_NOSE_ART:
				persistenceArray = "titanChassis"
				persistenceVar = "newPrimeTitanDecals"
				break

			case eItemTypes.TITAN_FD_UPGRADE:
				persistenceArray = "titanChassis"
				persistenceVar = "newFDUpgrades"
				break

			default:
				CodeWarning( "Unhandled new type (subitem): " + DEV_GetEnumStringFromIndex( "eItemTypes", refType ) )
		}

		int arrayCount = PersistenceGetArrayCount( persistenceArray )
		for ( int i = 0; i < arrayCount; i++ )
		{
			string persistenceStruct = persistenceArray + "[" + i + "]"

			ItemData ornull parentItem = GetItemFromPersistenceStruct( persistenceStruct )
			if ( parentItem == null )
				continue
			expect ItemData( parentItem )

			if ( IsItemLocked( player, parentItem.ref ) )
				continue

			if ( parentRefType == -1 || GetItemType( parentItem.ref ) == parentRefType )
			{
				if ( IsAnyPersistenceBitSet( player, persistenceStruct + "." + persistenceVar ) )
					return true
			}
		}
	}

	return false
}

#endif //UI

#if SERVER
void function UnlockUltimateEdition( entity player )
{
	printt( "!!!!!!!!!!! UnlockUltimateEdition() running" )

	if ( player.GetPersistentVarAsInt( "ultimateEdition" ) > 0 )
	{
		printt( "!!!!!!!!!!! Returned because player.GetPersistentVarAsInt( \"ultimateEdition\" ) > 0" )
		return
	}

	if ( !player.HasEntitlement( ET_JUMPSTARTERKIT ) )
	{
		printt( "!!!!!!!!!!! Returned because !player.HasEntitlement( ET_JUMPSTARTERKIT )" )
		return
	}

	Player_GiveCredits( player, 500 )
	Player_GiveDoubleXP( player, 10 )

	array<ItemDisplayData> suits = GetVisibleItemsOfType( eItemTypes.PILOT_SUIT )
	foreach ( suitData in suits )
	{
		string tacticalRef = GetSuitBasedTactical( suitData.ref )
		SetItemOwned( player, suitData.ref, "", IsItemLocked( player, suitData.ref ) )
		SetItemOwned( player, tacticalRef, "", false )
	}

	array<ItemDisplayData> titans = GetVisibleItemsOfType( eItemTypes.TITAN )
	foreach ( titanData in titans )
	{
		SetItemOwned( player, titanData.ref, "", IsItemLocked( player, titanData.ref ) )
	}

	player.SetPersistentVar( "ultimateEdition", true )
}


void function SetItemOwnedStatus( entity player, string ref, string parentRef, bool unlocked )
{
	int unlockBitVal = unlocked ? 1 : 0

	ItemData itemData = GetItemData( ref )
	int refType = itemData.itemType

	if ( !IsSubItemType( refType ) )
	{
		int bitIndex = GetItemPersistenceId( ref )

		switch ( refType )
		{
			case eItemTypes.PILOT_PRIMARY:
			case eItemTypes.PILOT_SECONDARY:
				SetPersistenceBitfield( player, "unlockedPilotWeapons", bitIndex, unlockBitVal )
				return

			case eItemTypes.PILOT_SPECIAL:
			case eItemTypes.PILOT_ORDNANCE:
				SetPersistenceBitfield( player, "unlockedPilotOffhands", bitIndex, unlockBitVal )
				return

			case eItemTypes.PILOT_PASSIVE1:
			case eItemTypes.PILOT_PASSIVE2:
				SetPersistenceBitfield( player, "unlockedPilotPassives", bitIndex, unlockBitVal )
				return

			case eItemTypes.PILOT_SUIT:
				SetPersistenceBitfield( player, "unlockedPilotSuits", bitIndex, unlockBitVal )
				return

			case eItemTypes.PILOT_EXECUTION:
				SetPersistenceBitfield( player, "unlockedPilotExecutions", bitIndex, unlockBitVal )
				return

			case eItemTypes.TITAN_RONIN_EXECUTION:
			case eItemTypes.TITAN_NORTHSTAR_EXECUTION:
			case eItemTypes.TITAN_ION_EXECUTION:
			case eItemTypes.TITAN_TONE_EXECUTION:
			case eItemTypes.TITAN_SCORCH_EXECUTION:
			case eItemTypes.TITAN_LEGION_EXECUTION:
			case eItemTypes.TITAN_VANGUARD_EXECUTION:
				SetPersistenceBitfield( player, "unlockedTitanExecutions", bitIndex, unlockBitVal )
				return

			case eItemTypes.TITAN_SPECIAL:
			case eItemTypes.TITAN_ORDNANCE:
				SetPersistenceBitfield( player, "unlockedTitanOffhands", bitIndex, unlockBitVal )
				return

			case eItemTypes.TITAN:
				SetPersistenceBitfield( player, "unlockedTitanChassis", bitIndex, unlockBitVal )
				return

			case eItemTypes.PRIME_TITAN:
				SetPersistenceBitfield( player, "unlockedPrimeTitans", bitIndex, unlockBitVal )
				return

			case eItemTypes.FEATURE:
				SetPersistenceBitfield( player, "unlockedFeatures", bitIndex, unlockBitVal )
				return

			case eItemTypes.CAMO_SKIN_PILOT:
				SetPersistenceBitfield( player, "unlockedPilotSkins", bitIndex, unlockBitVal )
				return

			case eItemTypes.BURN_METER_REWARD:
				SetPersistenceBitfield( player, "unlockedBoosts", bitIndex, unlockBitVal )
				return

			case eItemTypes.FACTION:
				SetPersistenceBitfield( player, "unlockedFactions", bitIndex, unlockBitVal )
				return

			case eItemTypes.CALLING_CARD:
				SetPersistenceBitfield( player, "unlockedCallingCards", bitIndex, unlockBitVal )
				return

			case eItemTypes.CALLSIGN_ICON:
				SetPersistenceBitfield( player, "unlockedCallsignIcons", bitIndex, unlockBitVal )
				return

			case eItemTypes.COMMS_ICON:
				SetPersistenceBitfield( player, "unlockedCommsIcons", bitIndex, unlockBitVal )
				return

			default:
				CodeWarning( "Unhandled unlock type: " + DEV_GetEnumStringFromIndex( "eItemTypes", refType ) + " " + ref )
		}
	}
	else
	{
		int bitIndex = GetItemPersistenceId( ref, parentRef )
		switch ( refType )
		{
			case eItemTypes.PILOT_PRIMARY_ATTACHMENT:
			case eItemTypes.PILOT_PRIMARY_MOD:
			case eItemTypes.PILOT_SECONDARY_MOD:
			case eItemTypes.SUB_PILOT_WEAPON_MOD:
			case eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".unlockedMods", bitIndex, unlockBitVal )
				return

			case eItemTypes.WEAPON_FEATURE:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".unlockedFeatures", bitIndex, unlockBitVal )
				return

			case eItemTypes.WEAPON_SKIN:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".unlockedPrimeWeaponSkins", bitIndex, unlockBitVal )
				return

			case eItemTypes.TITAN_GENERAL_PASSIVE:
			case eItemTypes.TITAN_TITANFALL_PASSIVE:
			case eItemTypes.TITAN_RONIN_PASSIVE:
			case eItemTypes.TITAN_NORTHSTAR_PASSIVE:
			case eItemTypes.TITAN_ION_PASSIVE:
			case eItemTypes.TITAN_TONE_PASSIVE:
			case eItemTypes.TITAN_SCORCH_PASSIVE:
			case eItemTypes.TITAN_LEGION_PASSIVE:
			case eItemTypes.TITAN_VANGUARD_PASSIVE:
			case eItemTypes.TITAN_UPGRADE1_PASSIVE:
			case eItemTypes.TITAN_UPGRADE2_PASSIVE:
			case eItemTypes.TITAN_UPGRADE3_PASSIVE:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".unlockedPassives", bitIndex, unlockBitVal )
				return

			case eItemTypes.CAMO_SKIN_TITAN:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".unlockedSkins", bitIndex, unlockBitVal )
				return

			case eItemTypes.TITAN_WARPAINT:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".unlockedPrimeSkins", bitIndex, unlockBitVal )
				return

			case eItemTypes.CAMO_SKIN:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".unlockedWeaponSkins", bitIndex, unlockBitVal )
				return

			case eItemTypes.TITAN_NOSE_ART:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".unlockedTitanDecals", bitIndex, unlockBitVal )
				return

			case eItemTypes.PRIME_TITAN_NOSE_ART:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".unlockedPrimeTitanDecals", bitIndex, unlockBitVal )
				return

			case eItemTypes.TITAN_FD_UPGRADE:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".unlockedFDUpgrades", bitIndex, unlockBitVal )
				return

			default:
				CodeWarning( "Unhandled unlock type (subitem): " + DEV_GetEnumStringFromIndex( "eItemTypes", refType ) + " " + ref + " " + parentRef )
		}
	}
}

void function SetItemNewStatus( entity player, string ref, string parentRef, bool setNew )
{
	int newBitVal = setNew ? 1 : 0

	ItemData itemData = GetItemData( ref )
	int refType = itemData.itemType

	if ( !IsSubItemType( refType ) )
	{
		int bitIndex = GetItemPersistenceId( ref )

		switch ( refType )
		{
			case eItemTypes.PILOT_PRIMARY:
			case eItemTypes.PILOT_SECONDARY:
				SetPersistenceBitfield( player, "newPilotWeapons", bitIndex, newBitVal )
				return

			case eItemTypes.PILOT_SPECIAL:
			case eItemTypes.PILOT_ORDNANCE:
				SetPersistenceBitfield( player, "newPilotOffhands", bitIndex, newBitVal )
				return

			case eItemTypes.PILOT_PASSIVE1:
			case eItemTypes.PILOT_PASSIVE2:
				SetPersistenceBitfield( player, "newPilotPassives", bitIndex, newBitVal )
				return

			case eItemTypes.PILOT_SUIT:
				SetPersistenceBitfield( player, "newPilotSuits", bitIndex, newBitVal )
				return

			case eItemTypes.PILOT_EXECUTION:
				SetPersistenceBitfield( player, "newPilotExecutions", bitIndex, newBitVal )
				return

			case eItemTypes.TITAN_RONIN_EXECUTION:
			case eItemTypes.TITAN_NORTHSTAR_EXECUTION:
			case eItemTypes.TITAN_ION_EXECUTION:
			case eItemTypes.TITAN_TONE_EXECUTION:
			case eItemTypes.TITAN_SCORCH_EXECUTION:
			case eItemTypes.TITAN_LEGION_EXECUTION:
			case eItemTypes.TITAN_VANGUARD_EXECUTION:
				SetPersistenceBitfield( player, "newTitanExecutions", bitIndex, newBitVal )
				return

			case eItemTypes.TITAN_SPECIAL:
			case eItemTypes.TITAN_ORDNANCE:
				SetPersistenceBitfield( player, "newTitanOffhands", bitIndex, newBitVal )
				return

			case eItemTypes.TITAN:
				SetPersistenceBitfield( player, "newTitanChassis", bitIndex, newBitVal )
				return

			case eItemTypes.PRIME_TITAN:
				SetPersistenceBitfield( player, "newPrimeTitans", bitIndex, newBitVal )
				return

			case eItemTypes.FEATURE:
				SetPersistenceBitfield( player, "newFeatures", bitIndex, newBitVal )
				return

			case eItemTypes.CAMO_SKIN_PILOT:
				SetPersistenceBitfield( player, "newPilotSkins", bitIndex, newBitVal )
				return

			case eItemTypes.WEAPON_SKIN:
				SetPersistenceBitfield( player, "newPrimeWeaponSkins", bitIndex, newBitVal )
				return

			case eItemTypes.BURN_METER_REWARD:
				SetPersistenceBitfield( player, "newBoosts", bitIndex, newBitVal )
				return

			case eItemTypes.FACTION:
				SetPersistenceBitfield( player, "newFactions", bitIndex, newBitVal )
				return

			case eItemTypes.CALLING_CARD:
				SetPersistenceBitfield( player, "newCallingCards", bitIndex, newBitVal )
				return

			case eItemTypes.CALLSIGN_ICON:
				SetPersistenceBitfield( player, "newCallsignIcons", bitIndex, newBitVal )
				return

			case eItemTypes.COMMS_ICON:
				SetPersistenceBitfield( player, "newCommsIcons", bitIndex, newBitVal )
				return

			default:
				CodeWarning( "Unhandled unlock type: " + DEV_GetEnumStringFromIndex( "eItemTypes", refType ) + " " + ref )
		}
	}
	else
	{
		int bitIndex = GetItemPersistenceId( ref, parentRef )
		switch ( refType )
		{
			case eItemTypes.PILOT_PRIMARY_ATTACHMENT:
			case eItemTypes.PILOT_PRIMARY_MOD:
			case eItemTypes.PILOT_SECONDARY_MOD:
			case eItemTypes.PILOT_WEAPON_MOD3:
			case eItemTypes.SUB_PILOT_WEAPON_MOD:
			case eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newMods", bitIndex, newBitVal )
				return

			case eItemTypes.WEAPON_FEATURE:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newFeatures", bitIndex, newBitVal )
				return

			case eItemTypes.WEAPON_SKIN:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newPrimeWeaponSkins", bitIndex, newBitVal )
				return

			case eItemTypes.TITAN_GENERAL_PASSIVE:
			case eItemTypes.TITAN_TITANFALL_PASSIVE:
			case eItemTypes.TITAN_RONIN_PASSIVE:
			case eItemTypes.TITAN_NORTHSTAR_PASSIVE:
			case eItemTypes.TITAN_ION_PASSIVE:
			case eItemTypes.TITAN_TONE_PASSIVE:
			case eItemTypes.TITAN_SCORCH_PASSIVE:
			case eItemTypes.TITAN_LEGION_PASSIVE:
			case eItemTypes.TITAN_VANGUARD_PASSIVE:
			case eItemTypes.TITAN_UPGRADE1_PASSIVE:
			case eItemTypes.TITAN_UPGRADE2_PASSIVE:
			case eItemTypes.TITAN_UPGRADE3_PASSIVE:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newPassives", bitIndex, newBitVal )
				return

			case eItemTypes.CAMO_SKIN_TITAN:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newSkins", bitIndex, newBitVal )
				return

			case eItemTypes.TITAN_WARPAINT:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newPrimeSkins", bitIndex, newBitVal ) //TODO: This is actually WarPaint, rename next game.
				return

			case eItemTypes.CAMO_SKIN:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newWeaponSkins", bitIndex, newBitVal )
				return

			case eItemTypes.TITAN_NOSE_ART:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newTitanDecals", bitIndex, newBitVal )
				return

			case eItemTypes.PRIME_TITAN_NOSE_ART:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newPrimeTitanDecals", bitIndex, newBitVal )
				return

			case eItemTypes.TITAN_FD_UPGRADE:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newFDUpgrades", bitIndex, newBitVal )
				return

			default:
				CodeWarning( "Unhandled unlock type (subitem): " + DEV_GetEnumStringFromIndex( "eItemTypes", refType ) + " " + ref + " " + parentRef )
		}
	}
}

bool function ClientCommand_ClearNewStatus( entity player, array<string> args )
{
	if ( args.len() == 0 )
		return false

	string ref = args[0]

	if ( !ItemDefined( ref ) )
	{
		if ( args.len() != 2 )
			return false

		string parentRef = args[1]

		if ( !SubitemDefined( parentRef, ref ) )
			return false
	}

	ItemData itemData = GetItemData( ref )
	int refType = itemData.itemType

	if ( !IsSubItemType( refType ) )
	{
		int bitIndex = GetItemPersistenceId( ref )

		switch ( refType )
		{
			case eItemTypes.PILOT_PRIMARY:
			case eItemTypes.PILOT_SECONDARY:
				SetPersistenceBitfield( player, "newPilotWeapons", bitIndex, 0 )
				return true

			case eItemTypes.PILOT_SPECIAL:
			case eItemTypes.PILOT_ORDNANCE:
				SetPersistenceBitfield( player, "newPilotOffhands", bitIndex, 0 )
				return true

			case eItemTypes.PILOT_PASSIVE1:
			case eItemTypes.PILOT_PASSIVE2:
				SetPersistenceBitfield( player, "newPilotPassives", bitIndex, 0 )
				return true

			case eItemTypes.PILOT_SUIT:
				SetPersistenceBitfield( player, "newPilotSuits", bitIndex, 0 )
				return true

			case eItemTypes.PILOT_EXECUTION:
				SetPersistenceBitfield( player, "newPilotExecutions", bitIndex, 0 )
				return true

			case eItemTypes.TITAN_RONIN_EXECUTION:
			case eItemTypes.TITAN_NORTHSTAR_EXECUTION:
			case eItemTypes.TITAN_ION_EXECUTION:
			case eItemTypes.TITAN_TONE_EXECUTION:
			case eItemTypes.TITAN_SCORCH_EXECUTION:
			case eItemTypes.TITAN_LEGION_EXECUTION:
			case eItemTypes.TITAN_VANGUARD_EXECUTION:
				SetPersistenceBitfield( player, "newTitanExecutions", bitIndex, 0 )
				return true

			case eItemTypes.TITAN_SPECIAL:
			case eItemTypes.TITAN_ORDNANCE:
				SetPersistenceBitfield( player, "newTitanOffhands", bitIndex, 0 )
				return true

			case eItemTypes.TITAN:
				SetPersistenceBitfield( player, "newTitanChassis", bitIndex, 0 )
				return true

			case eItemTypes.PRIME_TITAN:
				SetPersistenceBitfield( player, "newPrimeTitans", bitIndex, 0 )
				return true

			case eItemTypes.FEATURE:
				SetPersistenceBitfield( player, "newFeatures", bitIndex, 0 )
				return true

			case eItemTypes.CAMO_SKIN_PILOT:
				SetPersistenceBitfield( player, "newPilotSkins", bitIndex, 0 )
				return true

			case eItemTypes.BURN_METER_REWARD:
				SetPersistenceBitfield( player, "newBoosts", bitIndex, 0 )
				return true

			case eItemTypes.FACTION:
				SetPersistenceBitfield( player, "newFactions", bitIndex, 0 )
				return true

			case eItemTypes.CALLING_CARD:
				SetPersistenceBitfield( player, "newCallingCards", bitIndex, 0 )
				return true

			case eItemTypes.CALLSIGN_ICON:
				SetPersistenceBitfield( player, "newCallsignIcons", bitIndex, 0 )
				return true

			case eItemTypes.COMMS_ICON:
				SetPersistenceBitfield( player, "newCommsIcons", bitIndex, 0 )
				return true

			default:
				CodeWarning( "Unhandled ClearNewStatus type: " + DEV_GetEnumStringFromIndex( "eItemTypes", refType ) + " " + ref )
		}
	}
	else
	{
		string parentRef = args[1]

		int bitIndex = GetItemPersistenceId( ref, parentRef )
		switch ( refType )
		{
			case eItemTypes.PILOT_PRIMARY_ATTACHMENT:
			case eItemTypes.PILOT_PRIMARY_MOD:
			case eItemTypes.PILOT_SECONDARY_MOD:
			case eItemTypes.PILOT_WEAPON_MOD3:
			case eItemTypes.SUB_PILOT_WEAPON_MOD:
			case eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newMods", bitIndex, 0 )
				return true

			case eItemTypes.WEAPON_FEATURE:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newFeatures", bitIndex, 0 )
				return true

			case eItemTypes.WEAPON_SKIN:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newPrimeWeaponSkins", bitIndex, 0 )
				return true

			case eItemTypes.TITAN_GENERAL_PASSIVE:
			case eItemTypes.TITAN_TITANFALL_PASSIVE:
			case eItemTypes.TITAN_RONIN_PASSIVE:
			case eItemTypes.TITAN_NORTHSTAR_PASSIVE:
			case eItemTypes.TITAN_ION_PASSIVE:
			case eItemTypes.TITAN_TONE_PASSIVE:
			case eItemTypes.TITAN_SCORCH_PASSIVE:
			case eItemTypes.TITAN_LEGION_PASSIVE:
			case eItemTypes.TITAN_VANGUARD_PASSIVE:
			case eItemTypes.TITAN_UPGRADE1_PASSIVE:
			case eItemTypes.TITAN_UPGRADE2_PASSIVE:
			case eItemTypes.TITAN_UPGRADE3_PASSIVE:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newPassives", bitIndex, 0 )
				return true

			case eItemTypes.CAMO_SKIN_TITAN:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newSkins", bitIndex, 0 )
				return true

			case eItemTypes.TITAN_WARPAINT:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newPrimeSkins", bitIndex, 0 ) //TODO: This is actually WarPaint, rename next game.
				return true

			case eItemTypes.CAMO_SKIN:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newWeaponSkins", bitIndex, 0 )
				return true

			case eItemTypes.TITAN_NOSE_ART:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newTitanDecals", bitIndex, 0 )
				return true

			case eItemTypes.PRIME_TITAN_NOSE_ART:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newPrimeTitanDecals", bitIndex, 0 )
				return true

			case eItemTypes.TITAN_FD_UPGRADE:
				string parentStruct = GetItemPersistenceStruct( parentRef )
				SetPersistenceBitfield( player, parentStruct + ".newFDUpgrades", bitIndex, 0 )
				return true

			default:
				CodeWarning( "Unhandled ClearNewStatus type (subitem): " + DEV_GetEnumStringFromIndex( "eItemTypes", refType ) + " " + ref + " " + parentRef )
		}
	}

	return true
}

void function SetItemOwned( entity player, string ref, string parentRef = "", bool setNew = true )
{
	SetItemOwnedStatus( player, ref, parentRef, true )
	SetItemNewStatus( player, ref, parentRef, setNew )
}

void function ClearItemOwned( entity player, string ref, string parentRef = "" )
{
	SetItemOwnedStatus( player, ref, parentRef, false )
}

bool function ClientCommand_DEV_GiveFDUnlockPoint( entity player, array<string> args )
{
	if ( args.len() == 0 )
		return false

	if ( !IsValid( player ) )
		return false

	string parentRef = args[0]
	printt( "GIVE PLAYER UNLOCK POINT ", parentRef  )
	Player_GiveFDUnlockPoints( player, 1 )
	return true
}

bool function ClientCommand_DEV_ResetTitanProgression( entity player, array<string> args )
{
	if ( args.len() == 0 )
		return false

	if ( !IsValid( player ) )
		return false

	string titanRef = args[0]
	printt( "RESET PLAYER TITAN PROGRESSION ", titanRef  )
	SetAvailableFDUnlockPoints( player, titanRef, 0 )

	array<ItemData> fdUpgrades = GetAllItemsOfType( eItemTypes.TITAN_FD_UPGRADE )
	foreach ( upgrade in fdUpgrades )
	{
		if ( upgrade.parentRef == titanRef )
		{
			ClearItemOwned( player, upgrade.ref, upgrade.parentRef )
		}
	}
	return true
}

bool function ClientCommand_BuyItem( entity player, array<string> args )
{
	if ( args.len() == 0 )
		return false

	string ref = args[0]

	if ( !ItemDefined( ref ) )
	{
		if ( args.len() != 2 )
			return false

		string parentRef = args[1]

		if ( !SubitemDefined( parentRef, ref ) )
			return false
	}

	if ( !IsValid( player ) )
		return false

	string parentRef

	int cost

	string fullItemName = ref

	if ( args.len() > 1 )
	{
		parentRef = args[ 1 ]
		cost = GetSubitemCost( parentRef, ref )

		for ( int i = 1; i < args.len(); i++ )
			fullItemName += " " + args[i]
	}
	else
	{
		cost = GetItemCost( ref )
	}

	if ( cost <= 0 )
		return false

	int creditsAvailable
	bool isFDUpgrade = GetItemType( ref ) == eItemTypes.TITAN_FD_UPGRADE
	if ( isFDUpgrade )
	{
		creditsAvailable = GetAvailableFDUnlockPoints( player, parentRef )
	}
	else
	{
		creditsAvailable = GetAvailableCredits( player )
	}

	if ( cost > creditsAvailable )
		return false

	SetItemOwned( player, ref, parentRef, false )

	if ( isFDUpgrade )
	{
		SetAvailableFDUnlockPoints( player, parentRef, creditsAvailable - cost )
	}
	else
	{
		SetAvailableCredits( player, creditsAvailable - cost )
		PIN_BuyItem( player, false, fullItemName, cost )
	}

	return true
}

bool function ClientCommand_BuyTicket( entity player, array<string> args )
{
	if ( !IsValid( player ) )
		return true

	ItemDisplayData displayData = GetItemDisplayData( "coliseum_ticket" )
	string itemName = GetItemName( "coliseum_ticket" )
	string ref = displayData.ref


	int numTickets = 1
	if ( args.len() > 0 )
		numTickets = int( args[0] )

	int cost = GetItemCost( ref ) * numTickets

	int creditsAvailable = GetAvailableCredits( player )

	if ( cost > creditsAvailable )
		return true

	Player_GiveColiseumTickets( player, numTickets )
	SetAvailableCredits( player, creditsAvailable - cost )

	PIN_BuyItem( player, true, ref, cost )

	return true
}

void function CodeCallback_GivePersistentItem( entity player, string itemName, int count )
{
	printt( "CodeCallback_GivePersistentItem", player, itemName, count )
	bool consumable = false
	switch ( itemName )
	{
		case "double_xp":
		case "burncard_doublexp":
			if ( count )
			{
				Player_GiveDoubleXP( player, count )
				ItemDisplayData displayData = GetItemDisplayData( "double_xp" )
				Player_AddRecentUnlock( player, displayData, count )
				PIN_GiveItem( player, true, itemName, count )
			}
			break

		case "coliseum_ticket":
			if ( count )
			{
				Player_GiveColiseumTickets( player, count )
				ItemDisplayData displayData = GetItemDisplayData( "coliseum_ticket" )
				Player_AddRecentUnlock( player, displayData, count )
				PIN_GiveItem( player, true, itemName, count )
			}
			break

		case "credit_award":
			if ( count )
			{
				Player_GiveCredits( player, count )
				ItemDisplayData displayData = GetItemDisplayData( "credit_award" )
				Player_AddRecentUnlock( player, displayData, count )
			}
			break

		case "unlock_dew":
			UnlockDEW( player )
			PIN_GiveItem( player, false, itemName, count )
			break

		case "unlock_target":
			UnlockTarget( player )
			PIN_GiveItem( player, false, itemName, count )
			break

		case "unlock_bww":
			UnlockBWW( player )
			PIN_GiveItem( player, false, itemName, count )
			break

		default:
			array<string> tokens = split( itemName, " " )
			if ( tokens.len() == 1 )
			{
				if ( !GivePersistentItem( player, tokens[0] ) )
					CodeWarning( itemName )
			}
			else if ( tokens.len() == 2 )
			{
				if ( !GivePersistentSubItem( player, tokens[0], tokens[1] ) )
					CodeWarning( itemName )
			}
			PIN_GiveItem( player, false, itemName, count )
			//
			//
			//string itemRef = itemName
			//if ( ItemDefined( itemRef ) )
			//{
			//	ItemData itemData = GetItemData( itemRef )
			//	int refType = itemData.itemType
			//
			//	if ( !IsSubItemType( refType ) )
			//	{
			//
			//	}
			//
			//}
			//break
	}
}

bool function GivePersistentItem( entity player, string itemRef )
{
	if ( !ItemDefined( itemRef ) )
	{
		CodeWarning( "Tried to give undefined item: " + itemRef )
		return false
	}

	ItemData itemData = GetItemData( itemRef )
	int refType = itemData.itemType

	if ( IsSubItemType( refType ) )
	{
		CodeWarning( "Tried to give sub-item " + itemRef + " without specifying a parent" )
		return false
	}

	SetItemOwned( player, itemRef, "", true )
	Player_AddRecentUnlock( player, GetItemDisplayData( itemRef ) )

	return true
}

bool function GivePersistentSubItem( entity player, string itemRef, string parentRef )
{
	if ( !ItemDefined( itemRef ) )
	{
		CodeWarning( "Tried to give undefined item: " + itemRef )
		return false
	}

	if ( !ItemDefined( parentRef ) )
	{
		CodeWarning( "Tried to give item " + itemRef + " to undefined parent: " + parentRef )
		return false
	}

	ItemData itemData = GetItemData( itemRef )
	int itemRefType = itemData.itemType

	if ( !IsSubItemType( itemRefType ) )
	{
		CodeWarning( "Tried to give item " + itemRef + " to parent " + parentRef + ", but it isn't a sub-item type" )
		return false
	}

	ItemData parentData = GetItemData( parentRef )
	int parentRefType = parentData.itemType

	if ( !HasSubitem( parentRef, itemRef ) )
	{
		CodeWarning( "Tried to give item " + itemRef + " to a parent " + parentRef + " it is not a child of" )
		return false
	}

	SetItemOwned( player, itemRef, parentRef, true )
	Player_AddRecentUnlock( player, GetItemDisplayData( itemRef, parentRef ) )

	return true
}

#endif //SERVER

array<string> function GetUnlockItemsForPlayerLevels( int startLevel, int endLevel )
{
	array<string> unlockedItems

	for ( int currentLevel = startLevel; currentLevel <= endLevel; currentLevel++ )
	{
		unlockedItems.extend( GetUnlockItemsForPlayerLevel( currentLevel ) )
	}

	return unlockedItems
}

array<string> function GetUnlockItemsForPlayerLevel( int newLevel )
{
	array<string> unlockedItems
	array<string> genUnlockItems
	if ( newLevel > GetMaxPlayerLevel() )
	{
		foreach ( ref, ul in file.unlocks )
		{
			if ( ul.unlockType == eUnlockType.PLAYER_LEVEL )
			{
				if ( ul.unlockLevel == newLevel )
					genUnlockItems.append( ref )
			}
		}

		genUnlockItems.sort( UnlockItemSort )
	}

	array<string> levelUnlockItems
	foreach ( ref, ul in file.unlocks )
	{
		if ( ul.unlockType == eUnlockType.PLAYER_LEVEL )
		{
			if ( ItemLockedShouldUseRawLevel( ref ) )
			{
				if ( ul.unlockLevel == newLevel && !genUnlockItems.contains( ref ) )
					levelUnlockItems.append( ref )
			}
			else
			{
				if ( ul.unlockLevel == ((newLevel - 1) % GetMaxPlayerLevel() + 1) )
					levelUnlockItems.append( ref )
			}
		}
	}

	levelUnlockItems.sort( UnlockItemSort )

	unlockedItems.extend( genUnlockItems )
	unlockedItems.extend( levelUnlockItems )

	if ( unlockedItems.len() == 0 )
		unlockedItems.append( "credit_award_5x" )

	return unlockedItems
}



array<string> function GetUnlockItemsForPlayerRawLevel( int newLevel )
{
	array<string> unlockedItems
	foreach ( ref, ul in file.unlocks )
	{
		if ( ul.unlockType == eUnlockType.PLAYER_LEVEL )
		{
			if ( ul.unlockLevel == newLevel )
				unlockedItems.append( ref )
		}
	}

	unlockedItems.sort( UnlockItemSort )

	return unlockedItems
}


string function GetWeaponForTitan( string titanClass )
{
	var titanPropertiesDataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int propertyRow = GetDataTableRowMatchingStringValue( titanPropertiesDataTable, GetDataTableColumnByName( titanPropertiesDataTable, "titanRef" ), titanClass )
	return GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "primary" ) )
}

string function GetTitanForWeapon( string weaponRef )
{
	var titanPropertiesDataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int propertyRow = GetDataTableRowMatchingStringValue( titanPropertiesDataTable, GetDataTableColumnByName( titanPropertiesDataTable, "primary" ), weaponRef )
	return GetDataTableString( titanPropertiesDataTable, propertyRow, GetDataTableColumnByName( titanPropertiesDataTable, "titanRef" ) )
}

#if SERVER
void function AwardCredits( entity player, string award )
{
	switch ( award )
	{
		case "credit_award":
			Player_GiveCredits( player, 1 )
			break

		case "credit_award_5x":
			Player_GiveCredits( player, 5 )
			break
	}
}

void function Player_GiveCredits( entity player, int count )
{
	int currentCredits = GetAvailableCredits( player )
	SetAvailableCredits( player, currentCredits + count )
	PIN_GiveCredits( player, count )
}

void function Player_GiveColiseumTickets( entity player, int count )
{
	int currentTickets = Player_GetColiseumTicketCount( player )
	int newTicketCount = maxint( 0, (currentTickets + count) )
	Player_SetColiseumTicketCount( player, newTicketCount )
}

void function Player_GiveFDUnlockPoints( entity player, int count )
{
	TitanLoadoutDef loadout = GetTitanLoadoutForPlayer( player )

	int currentPoints = GetAvailableFDUnlockPoints( player, loadout.titanClass )
	SetAvailableFDUnlockPoints( player, loadout.titanClass, currentPoints + count )
}
#endif

int function Player_GetColiseumTicketCount( entity player )
{
	return player.GetPersistentVarAsInt( "coliseumTickets" )
}

void function Player_SetColiseumTicketCount( entity player, int newCount )
{
	player.SetPersistentVar( "coliseumTickets", newCount )
}

#if SERVER
void function Player_GiveDoubleXP( entity player, int count )
{
	int currentDoubleXP = Player_GetDoubleXPCount( player )
	Player_SetDoubleXPCount( player, currentDoubleXP + count )
}

bool function ClientCommand_UseDoubleXP( entity player, array<string> args )
{
	if ( IsPrivateMatch() )
		return true

	if ( GetGameState() > eGameState.Prematch )
		return true

	if ( Player_GetDoubleXPCount( player ) < 1 )
		return true

	if ( player.GetPlayerNetInt( "xpMultiplier" ) )
		return true

	int currentDoubleXP = Player_GetDoubleXPCount( player )
	Player_SetDoubleXPCount( player, currentDoubleXP - 1 )
	Player_ActivateDoubleXP( player )

	PIN_ConsumeItem( player, "double_xp" )

	// ?

	return true
}

void function Player_ActivateDoubleXP( entity player )
{
	player.SetPlayerNetInt( "xpMultiplier", 2 )

	Remote_CallFunction_UI( player, "SCB_SetDoubleXPStatus", 2 )
}
#endif

int function Player_GetDoubleXPCount( entity player )
{
	return player.GetPersistentVarAsInt( "doubleXP" )
}

#if SERVER
void function Player_SetDoubleXPCount( entity player, int newCount )
{
	player.SetPersistentVar( "doubleXP", newCount )
}
#endif

ItemDisplayData ornull function Player_GetRecentUnlock( entity player, int index )
{
	int refGuid  = player.GetPersistentVarAsInt( "recentUnlocks[" + index + "].refGuid" )
	int parentRefGuid  = player.GetPersistentVarAsInt( "recentUnlocks[" + index + "].parentRefGuid" )

	if ( refGuid == 0 )
		return null

	return GetItemDisplayDataFromGuid( refGuid, parentRefGuid )
}

int function Player_GetRecentUnlockCount( entity player, int index )
{
	return player.GetPersistentVarAsInt( "recentUnlocks[" + index + "].count" )
}

#if SERVER
void function Player_AddRecentUnlock( entity player, ItemDisplayData itemData, int count = 1 )
{
	array<RecentUnlock> recentUnlocks

	RecentUnlock mostRecentUnlock
	mostRecentUnlock.refGuid = file.itemRefToGuid[itemData.ref]
	mostRecentUnlock.count = count
	if ( itemData.parentRef != "" )
		mostRecentUnlock.parentRefGuid = file.itemRefToGuid[itemData.parentRef]

	recentUnlocks.append( mostRecentUnlock )

	int maxRecentUnlockCount = PersistenceGetArrayCount( "recentUnlocks" )
	for ( int index = 0; index < maxRecentUnlockCount; index++ )
	{
		RecentUnlock recentUnlock
		recentUnlock.refGuid  = player.GetPersistentVarAsInt( "recentUnlocks[" + index + "].refGuid" )
		recentUnlock.parentRefGuid  = player.GetPersistentVarAsInt( "recentUnlocks[" + index + "].parentRefGuid" )
		recentUnlock.count  = player.GetPersistentVarAsInt( "recentUnlocks[" + index + "].count" )

		recentUnlocks.append( recentUnlock )
	}

	for ( int index = 0; index < maxRecentUnlockCount; index++ )
	{
		player.SetPersistentVar( "recentUnlocks[" + index + "].refGuid", recentUnlocks[index].refGuid )
		player.SetPersistentVar( "recentUnlocks[" + index + "].parentRefGuid", recentUnlocks[index].parentRefGuid )
		player.SetPersistentVar( "recentUnlocks[" + index + "].count", recentUnlocks[index].count )
	}
}

#endif

int function UnlockItemSort( string itemRefA, string itemRefB )
{
	int priority = 0
	table<int, int> itemPriority
	itemPriority[eItemTypes.PILOT_PRIMARY] <- priority++
	itemPriority[eItemTypes.PILOT_SECONDARY] <- priority++
	itemPriority[eItemTypes.PILOT_SPECIAL] <- priority++
	itemPriority[eItemTypes.PILOT_ORDNANCE] <- priority++
	itemPriority[eItemTypes.PILOT_PRIMARY_ATTACHMENT] <- priority++
	itemPriority[eItemTypes.PILOT_PRIMARY_MOD] <- priority++
	itemPriority[eItemTypes.PILOT_SECONDARY_MOD] <- priority++
	itemPriority[eItemTypes.PILOT_PASSIVE1] <- priority++
	itemPriority[eItemTypes.PILOT_PASSIVE2] <- priority++
	itemPriority[eItemTypes.TITAN_PRIMARY] <- priority++
	itemPriority[eItemTypes.PILOT_SUIT] <- priority++
	itemPriority[eItemTypes.TITAN_SPECIAL] <- priority++
	itemPriority[eItemTypes.TITAN_ANTIRODEO] <- priority++
	itemPriority[eItemTypes.TITAN_ORDNANCE] <- priority++
	itemPriority[eItemTypes.TITAN_PRIMARY_MOD] <- priority++
	itemPriority[eItemTypes.TITAN_OS] <- priority++
	itemPriority[eItemTypes.TITAN_NOSE_ART] <- priority++
	itemPriority[eItemTypes.PRIME_TITAN_NOSE_ART] <- priority++
	itemPriority[eItemTypes.TITAN_CORE_ABILITY] <- priority++
	itemPriority[eItemTypes.BURN_METER_REWARD] <- priority++
	itemPriority[eItemTypes.PILOT_MELEE] <- priority++
	itemPriority[eItemTypes.TITAN] <- priority++
	itemPriority[eItemTypes.PILOT_EXECUTION] <- priority++
	itemPriority[eItemTypes.TITAN_RONIN_EXECUTION] <- priority++
	itemPriority[eItemTypes.TITAN_NORTHSTAR_EXECUTION] <- priority++
	itemPriority[eItemTypes.TITAN_ION_EXECUTION] <- priority++
	itemPriority[eItemTypes.TITAN_TONE_EXECUTION] <- priority++
	itemPriority[eItemTypes.TITAN_SCORCH_EXECUTION] <- priority++
	itemPriority[eItemTypes.TITAN_LEGION_EXECUTION] <- priority++
	itemPriority[eItemTypes.TITAN_VANGUARD_EXECUTION] <- priority++
	itemPriority[eItemTypes.FACTION] <- priority++
	itemPriority[eItemTypes.CALLING_CARD] <- priority++
	itemPriority[eItemTypes.CALLSIGN_ICON] <- priority++
	itemPriority[eItemTypes.CAMO_SKIN] <- priority++
	itemPriority[eItemTypes.CAMO_SKIN_PILOT] <- priority++
	itemPriority[eItemTypes.CAMO_SKIN_TITAN] <- priority++
	itemPriority[eItemTypes.TITAN_WARPAINT] <- priority++
	itemPriority[eItemTypes.TITAN_GENERAL_PASSIVE] <- priority++
	itemPriority[eItemTypes.TITAN_TITANFALL_PASSIVE] <- priority++
	itemPriority[eItemTypes.TITAN_RONIN_PASSIVE] <- priority++
	itemPriority[eItemTypes.TITAN_NORTHSTAR_PASSIVE] <- priority++
	itemPriority[eItemTypes.TITAN_ION_PASSIVE] <- priority++
	itemPriority[eItemTypes.TITAN_TONE_PASSIVE] <- priority++
	itemPriority[eItemTypes.TITAN_SCORCH_PASSIVE] <- priority++
	itemPriority[eItemTypes.TITAN_LEGION_PASSIVE] <- priority++
	itemPriority[eItemTypes.TITAN_VANGUARD_PASSIVE] <- priority++
	itemPriority[eItemTypes.TITAN_UPGRADE1_PASSIVE] <- priority++
	itemPriority[eItemTypes.TITAN_UPGRADE2_PASSIVE] <- priority++
	itemPriority[eItemTypes.TITAN_UPGRADE3_PASSIVE] <- priority++
	itemPriority[eItemTypes.FEATURE] <- priority++
	itemPriority[eItemTypes.RACE] <- priority++
	itemPriority[eItemTypes.NOT_LOADOUT] <- priority++
	itemPriority[eItemTypes.SUB_PILOT_WEAPON_MOD] <- priority++
	itemPriority[eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT] <- priority++
	itemPriority[eItemTypes.GAME_MODE] <- priority++
	itemPriority[eItemTypes.COMMS_ICON] <- priority++

	int itemRefAType = GetItemType( itemRefA )
	int itemRefBType = GetItemType( itemRefB )

	if ( itemPriority[itemRefAType] < itemPriority[itemRefBType] )
		return -1

	if ( itemPriority[itemRefAType] > itemPriority[itemRefBType] )
		return 1

	return 0
}


array<string> function GetUnlockItemsForTitanLevels( string titanRef, int startLevel, int endLevel )
{
	array<string> unlockedItems

	for ( int currentLevel = startLevel; currentLevel <= endLevel; currentLevel++ )
	{
		unlockedItems.extend( GetUnlockItemsForTitanLevel( titanRef, currentLevel ) )
	}

	return unlockedItems
}

string function GetNextUnlockForTitanLevel( entity player, string titanRef, int startLevel )
{
	array<string> unlockedItems

	int endLevel = TitanGetMaxRawLevel( titanRef )

	for ( int currentLevel = startLevel; currentLevel <= endLevel; currentLevel++ )
	{
		unlockedItems = GetUnlockItemsForTitanLevel( titanRef, currentLevel )

		if ( unlockedItems.len() == 0 )
		{
			if ( TitanLevelHasRandomUnlock( currentLevel, titanRef ) )
				return "random"
		}

		if ( unlockedItems.len() > 0 )
		{
			for ( int i = 0; i < unlockedItems.len(); i++ )
			{
				if ( IsSubItemType( GetItemType( unlockedItems[ i ] ) ) )
				{
					if ( IsSubItemLocked( player, unlockedItems[ i ], titanRef ) )
						return unlockedItems[ i ]
				}
				else
				{
					if ( IsItemLocked( player, unlockedItems[ i ] ) )
						return unlockedItems[ i ]
				}
			}
		}
	}

	return ""
}

array<string> function GetUnlockItemsForTitanLevel( string titanRef, int newLevel )
{
	array<string> unlockedItems
	Assert( titanRef in file.unlocks )

	foreach ( ref, ul in file.unlocks )
	{
		if ( ul.unlockType == eUnlockType.TITAN_LEVEL && ul.unlockLevel == newLevel && ul.parentRef == titanRef )
		{
			unlockedItems.append( ref )
		}
	}

	foreach ( childRef, ul in file.unlocks[ titanRef ].child )
	{
		if ( ul.unlockType == eUnlockType.TITAN_LEVEL && ul.unlockLevel == newLevel )
		{
			unlockedItems.append( childRef )
		}
	}

	return unlockedItems
}

array<string> function GetUnlockItemsForWeaponLevels( string weaponRef, int startLevel, int endLevel )
{
	array<string> unlockedItems

	for ( int currentLevel = startLevel; currentLevel <= endLevel; currentLevel++ )
	{
		unlockedItems.extend( GetUnlockItemsForWeaponLevel( weaponRef, currentLevel ) )
	}

	return unlockedItems
}

string function GetNextUnlockForWeaponLevel( entity player, string weaponRef, int startLevel )
{
	array<string> unlockedItems

	int endLevel = WeaponGetMaxRawLevel( weaponRef )

	for ( int currentLevel = startLevel; currentLevel <= endLevel; currentLevel++ )
	{
		unlockedItems.extend( GetUnlockItemsForWeaponLevel( weaponRef, currentLevel ) )

		if ( unlockedItems.len() == 0 )
		{
			if ( WeaponLevelHasRandomUnlock( currentLevel, weaponRef ) )
				return "random"
		}

		if ( unlockedItems.len() > 0 )
		{
			for ( int i = 0; i < unlockedItems.len(); i++ )
			{
				if ( IsSubItemType( GetItemType( unlockedItems[ i ] ) ) )
				{
					if ( IsSubItemLocked( player, unlockedItems[ i ], weaponRef ) )
						return unlockedItems[ i ]
				}
				else
				{
					if ( !IsItemLocked( player, unlockedItems[ i ] ) )
						return unlockedItems[ i ]
				}
			}
		}
	}

	return ""
}

array<string> function GetUnlockItemsForWeaponLevel( string weaponRef, int newLevel )
{
	array<string> unlockedItems

	foreach ( ref, ul in file.unlocks )
	{
		if ( ul.unlockType == eUnlockType.WEAPON_LEVEL && ul.unlockLevel == newLevel && ul.parentRef == weaponRef )
		{
			unlockedItems.append( ref )
		}
	}

	foreach ( childRef, ul in file.unlocks[ weaponRef ].child )
	{
		if ( ul.unlockType == eUnlockType.WEAPON_LEVEL && ul.unlockLevel == newLevel )
		{
			unlockedItems.append( childRef )
		}
	}

	return unlockedItems
}

array<ItemDisplayData> function GetUnlockItemsForFactionLevels( string factionRef, int startLevel, int endLevel )
{
	array<ItemDisplayData> unlockedItems

	for ( int currentLevel = startLevel; currentLevel <= endLevel; currentLevel++ )
	{
		unlockedItems.extend( GetUnlockItemsForFactionLevel( factionRef, currentLevel ) )
	}

	return unlockedItems
}

array<ItemDisplayData> function GetUnlockItemsForFactionLevel( string factionRef, int newLevel )
{
	array<ItemDisplayData> unlockedItems

	foreach ( ref, ul in file.unlocks )
	{
		if ( ul.unlockType == eUnlockType.FACTION_LEVEL && ul.unlockLevel == newLevel )
		{
			if ( ul.additionalRef == factionRef )
				unlockedItems.append( GetItemDisplayData( ref ) )
		}

		foreach ( childRef, cul in ul.child )
		{
			if ( cul.unlockType == eUnlockType.FACTION_LEVEL && cul.unlockLevel == newLevel )
			{
				if ( cul.additionalRef == factionRef )
					unlockedItems.append( GetItemDisplayData( childRef, ref ) )
			}
		}
	}

	return unlockedItems
}


array<string> function GetUnlockItemsForFDTitanLevels( string titanRef, int startLevel, int endLevel )
{
	array<string> unlockedItems

	for ( int currentLevel = startLevel; currentLevel <= endLevel; currentLevel++ )
	{
		unlockedItems.extend( GetUnlockItemsForFDTitanLevel( titanRef, currentLevel ) )
	}

	return unlockedItems
}

string function GetNextUnlockForFDTitanLevel( entity player, string titanRef, int startLevel )
{
	array<string> unlockedItems

	int endLevel = FD_TitanGetMaxRawLevel( titanRef )

	for ( int currentLevel = startLevel; currentLevel <= endLevel; currentLevel++ )
	{
		unlockedItems = GetUnlockItemsForFDTitanLevel( titanRef, currentLevel )

		//if ( unlockedItems.len() == 0 )
		//{
		//	if ( FDTitanLevelHasRandomUnlock( currentLevel, titanRef ) )
		//		return "random"
		//}

		if ( unlockedItems.len() > 0 )
		{
			for ( int i = 0; i < unlockedItems.len(); i++ )
			{
				if ( IsSubItemType( GetItemType( unlockedItems[ i ] ) ) )
				{
					if ( IsSubItemLocked( player, unlockedItems[ i ], titanRef ) )
						return unlockedItems[ i ]
				}
				else
				{
					if ( IsItemLocked( player, unlockedItems[ i ] ) )
						return unlockedItems[ i ]
				}
			}
		}
	}

	return ""
}

array<string> function GetUnlockItemsForFDTitanLevel( string titanRef, int newLevel )
{
	array<string> unlockedItems
	Assert( titanRef in file.unlocks )

	foreach ( ref, ul in file.unlocks )
	{
		if ( ul.unlockType == eUnlockType.FD_UNLOCK_POINTS && ul.unlockLevel == newLevel && ul.parentRef == titanRef )
		{
			unlockedItems.append( ref )
		}
	}

	foreach ( childRef, ul in file.unlocks[ titanRef ].child )
	{
		if ( ul.unlockType == eUnlockType.FD_UNLOCK_POINTS && ul.unlockLevel == newLevel )
		{
			unlockedItems.append( childRef )
		}
	}

	//if ( unlockedItems.len() == 0 )
	{
		if ( FDTitanLevelHasRandomUnlock( newLevel, titanRef ) )
			unlockedItems.append( "random" )
	}

	return unlockedItems
}

bool function DidPlayerBuyItemFromBlackMarket( player, ref )
{
	bool doesRefExist =  PersistenceEnumValueIsValid( "BlackMarketUnlocks", ref )
	if ( doesRefExist == false )
		return false

	return expect bool( player.GetPersistentVar( "bm.blackMarketItemUnlocks[" + ref + "]" ) )
}

void function PrintItem( ItemData item, int indentLevel = 0 )
{
	print( TableIndent( indentLevel ) )

	printt( "itemType =", item.itemType )
	printt( "ref =", item.ref )

	printt( "name =", item.name )
	printt( "desc =", item.desc )
	printt( "longdesc =", item.longdesc )
	printt( "image =", item.image )

	printt( "hidden =", item.hidden )

	printt( "persistenceStruct =", item.persistenceStruct )
	printt( "persistenceId =", item.persistenceId )

	foreach ( itemRef, _ in item.subitems )
	{
		PrintItem( GetItemData( itemRef ), indentLevel + 1 )
	}

	PrintTable( item.i )
}

void function PrintItemData()
{
	foreach ( ItemData item in file.itemData )
	{
		PrintItem( item, 0 )
	}
}

void function PrintItems()
{
	foreach ( itemType, refList in file.itemsOfType )
	{
		printt( itemType )
		foreach ( ref in refList )
		{
			printt( "    " + ref )
		}
	}
}

string function GetDisplayNameFromItemType( int itemType )
{
	string displayName

	switch ( itemType )
	{
		case eItemTypes.PILOT_PRIMARY:
		case eItemTypes.TITAN_PRIMARY:
			displayName = "#PILOT_PRIMARY"
			break

		case eItemTypes.PILOT_SECONDARY:
			displayName = "#PILOT_SECONDARY"
			break

		case eItemTypes.PILOT_WEAPON3:
			displayName = "#PILOT_WEAPON3"
			break

		case eItemTypes.PILOT_SPECIAL:
			displayName = "#TACTICAL_ABILITY"
			break

		case eItemTypes.TITAN_SPECIAL:
			displayName = "#DEFENSIVE_ABILITY"
			break

		case eItemTypes.TITAN_ANTIRODEO:
			displayName = "#TACTICAL_ABILITY"
			break

		case eItemTypes.PILOT_ORDNANCE:
		case eItemTypes.TITAN_ORDNANCE:
			displayName = "#ORDNANCE"
			break

		case eItemTypes.PILOT_PASSIVE1:
			displayName = "#PILOT_KIT1"
			break

		case eItemTypes.PILOT_PASSIVE2:
			displayName = "#PILOT_KIT2"
			break

		case eItemTypes.TITAN_GENERAL_PASSIVE:
			displayName = "#TITAN_GENERAL_PASSIVE_TITLE"
			break

		case eItemTypes.TITAN_TITANFALL_PASSIVE:
			displayName = "#TITAN_TITANFALL_PASSIVE_TITLE"
			break

		case eItemTypes.TITAN_RONIN_PASSIVE:
			displayName = "#TITAN_RONIN_PASSIVE_TITLE"
			break

		case eItemTypes.TITAN_NORTHSTAR_PASSIVE:
			displayName = "#TITAN_NORTHSTAR_PASSIVE_TITLE"
			break

		case eItemTypes.TITAN_ION_PASSIVE:
			displayName = "#TITAN_ION_PASSIVE_TITLE"
			break

		case eItemTypes.TITAN_TONE_PASSIVE:
			displayName = "#TITAN_TONE_PASSIVE_TITLE"
			break

		case eItemTypes.TITAN_SCORCH_PASSIVE:
			displayName = "#TITAN_SCORCH_PASSIVE_TITLE"
			break

		case eItemTypes.TITAN_LEGION_PASSIVE:
			displayName = "#TITAN_LEGION_PASSIVE_TITLE"
			break

		case eItemTypes.TITAN_VANGUARD_PASSIVE:
			displayName = "#TITAN_VANGUARD_PASSIVE_TITLE"
			break

		case eItemTypes.TITAN_UPGRADE1_PASSIVE:
			displayName = "#TITAN_UPGRADE1_PASSIVE_TITLE"
			break

		case eItemTypes.TITAN_UPGRADE2_PASSIVE:
			displayName = "#TITAN_UPGRADE2_PASSIVE_TITLE"
			break

		case eItemTypes.TITAN_UPGRADE3_PASSIVE:
			displayName = "#TITAN_UPGRADE3_PASSIVE_TITLE"
			break

		case eItemTypes.TITAN_OS:
			displayName = "#VOICE"
			break

		case eItemTypes.TITAN_NOSE_ART:
		case eItemTypes.PRIME_TITAN_NOSE_ART:
			displayName = "#NOSE_ART"
			break

		case eItemTypes.PILOT_PRIMARY_ATTACHMENT:
			displayName = "#ITEM_TYPE_WEAPON_ATTACHMENT"
			break

		case eItemTypes.PILOT_PRIMARY_MOD:
		case eItemTypes.TITAN_PRIMARY_MOD:
		case eItemTypes.PILOT_SECONDARY_MOD:
			displayName = "#ITEM_TYPE_WEAPON_MOD"
			break

		case eItemTypes.TITAN:
			displayName = "#CHASSIS"
			break

		case eItemTypes.RACE:
			displayName = "#GENDER"
			break

		case eItemTypes.PILOT_MELEE:
			displayName = "#MELEE"
			break

		case eItemTypes.PILOT_EXECUTION:
			displayName = "#ITEM_TYPE_PILOT_EXECUTION"
			break

		case eItemTypes.TITAN_RONIN_EXECUTION:
		case eItemTypes.TITAN_NORTHSTAR_EXECUTION:
		case eItemTypes.TITAN_ION_EXECUTION:
		case eItemTypes.TITAN_TONE_EXECUTION:
		case eItemTypes.TITAN_SCORCH_EXECUTION:
		case eItemTypes.TITAN_LEGION_EXECUTION:
		case eItemTypes.TITAN_VANGUARD_EXECUTION:
			displayName = "#ITEM_TYPE_TITAN_EXECUTION"
			break

		default:
			Assert( false, "Invalid item itemType!" )
	}

	return displayName
}

int function GetStatUnlockSort( ItemDisplayData a, ItemDisplayData b )
{
	table aAdditionalData
	table bAdditionalData

	int itemType = GetItemType( a.ref )
	if ( IsSubItemType( itemType ) )
	{
		aAdditionalData = file.unlocks[ a.parentRef ].child[ a.ref ].additionalData
		bAdditionalData = file.unlocks[ b.parentRef ].child[ b.ref ].additionalData
	}
	else
	{
		aAdditionalData = file.unlocks[ a.ref ].additionalData
		bAdditionalData = file.unlocks[ b.ref ].additionalData
	}

	string aStatCategory = expect string( aAdditionalData.statCategory )
	string aStatAlias = expect string( aAdditionalData.statAlias )
	string aStatSubAlias = expect string( aAdditionalData.statSubAlias )
	var aUnlockValue = aAdditionalData.statUnlockValue

	string bStatCategory = expect string( bAdditionalData.statCategory )
	string bStatAlias = expect string( bAdditionalData.statAlias )
	string bStatSubAlias = expect string( bAdditionalData.statSubAlias )
	var bUnlockValue = bAdditionalData.statUnlockValue

	if ( aStatCategory > bStatCategory )
		return 1
	else if ( aStatCategory < bStatCategory )
		return -1

	if ( aStatAlias > bStatAlias )
		return 1
	else if ( aStatAlias < bStatAlias )
		return -1

	if ( aUnlockValue > bUnlockValue )
		return 1
	else if ( aUnlockValue < bUnlockValue )
		return -1

	return 0
}

int function SortItemsAlphabetically( ItemDisplayData a, ItemDisplayData b )
{
	if ( a.name > b.name )
		return 1

	if ( a.name < b.name )
		return -1

	return 0
}

int function SortByUnlockLevelUntyped( ItemDisplayData a, ItemDisplayData b )
{
	if ( a.ref == b.ref )
		return 0

	int aUnlockLevel
	int bUnlockLevel
	int itemType = GetItemType( a.ref )
	if ( IsSubItemType( itemType ) )
	{
		aUnlockLevel = GetUnlockLevelReqWithParent( a.ref, a.parentRef )
		bUnlockLevel = GetUnlockLevelReqWithParent( b.ref, b.parentRef )
	}
	else
	{
		aUnlockLevel = GetUnlockLevelReq( a.ref )
		bUnlockLevel = GetUnlockLevelReq( b.ref )
	}

	if ( aUnlockLevel == 0 && bUnlockLevel > 0 )
		return 1
	else if ( aUnlockLevel > 0 && bUnlockLevel == 0 )
		return -1

	if ( aUnlockLevel > bUnlockLevel )
		return 1
	else if ( aUnlockLevel < bUnlockLevel )
		return -1

	int aUnlockType = CheckItemUnlockType( a.ref, a.parentRef )
	int bUnlockType = CheckItemUnlockType( b.ref, b.parentRef )

	if ( aUnlockType > bUnlockType )
		return 1
	else if ( aUnlockType < bUnlockType )
		return -1

	if ( aUnlockType == bUnlockType && aUnlockType == eUnlockType.STAT )
		return GetStatUnlockSort( a, b )

	if ( a.persistenceId > b.persistenceId )
		return 1
	else
		return -1

	unreachable
}

int function SortByUnlockLevel( GlobalItemRef a, GlobalItemRef b )
{
	if ( a.ref == b.ref )
		return 0

	int aUnlockLevel = GetUnlockLevelReq( a.ref )
	int bUnlockLevel = GetUnlockLevelReq( b.ref )

	if ( aUnlockLevel > bUnlockLevel )
		return 1
	else if ( aUnlockLevel < bUnlockLevel )
		return -1

	if ( a.guid > b.guid )
		return 1
	else
		return -1

	unreachable
}

bool function IsTitanOSUnlocked( ref, player )
{
	return true
}

bool function IsDecalUnlocked( ref, player = null )
{
	Assert( ref == ref.tolower() )

	local decalUnlockData = GetPlayerDecalUnlockData( player, ref )
	return expect bool( decalUnlockData.unlocked )
}

function GetPlayerDecalUnlockData( player, ref )
{
	Assert( IsUI() || IsValid( player ) )

	local data = {}
	data.unlocked <- true
	data.goal <- 0
	data.progress <- 0
	data.dlcGroup <- 0
	data.unlockText <- ""

	return data
}

// TODO: Default "pretend" attachments shouldn't be baked into weapons.
// Because of this, we don't have real items for everything in order to make this work the right way.
// Should be a real attachment as all others and we can flag it as default in some way.
asset function GetStockAttachmentImage( string itemRef )
{
	Assert( GetItemType( itemRef ) == eItemTypes.PILOT_PRIMARY )

	switch ( itemRef )
	{
		case "mp_weapon_dmr":
		case "mp_weapon_sniper":
			return $"r2_ui/menus/loadout_icons/attachments/stock_scope"

		case "mp_weapon_doubletake":
			return $"r2_ui/menus/loadout_icons/attachments/stock_doubletake_sight"

		case "mp_weapon_rspn101_og":
			return $"r2_ui/menus/loadout_icons/attachments/aog"
	}

	return $"r2_ui/menus/loadout_icons/attachments/iron_sights"
}

string function GetSuitAndGenderBasedSetFile( string suit, string gender )
{
	Assert( gender == "race_human_male" ||
					gender == "race_human_female" )

	bool isFemale = gender == RACE_HUMAN_FEMALE

	string genderString
	if ( isFemale )
		genderString = "female"
	else
		genderString = "male"

	// pilot_medium_male
	// pilot_geist_male
	// pilot_stalker_male
	// pilot_light_male
	// pilot_heavy_male
	// pilot_grapple_male
	// pilot_nomad_male
	// pilot_medium_female
	// pilot_geist_female
	// pilot_stalker_female
	// pilot_light_female
	// pilot_heavy_female
	// pilot_grapple_female
	// pilot_nomad_female
	return "pilot_" + suit + "_" + genderString
}

string function GetSuitBasedTactical( string suit )
{
	return GetTableValueForSuit( suit, "tactical" )
}

//string function GetSuitBasedDefaultPassive( string suit, string propertyName )
//{
//	Assert( propertyName == "passive1" || propertyName == "passive2" )
//
//	string value
//	if ( propertyName == "passive1" )
//		value = GetTableValueForSuit( suit, "defaultPassive1" )
//	else
//		value = GetTableValueForSuit( suit, "defaultPassive2" )
//
//	return value
//}

string function GetTableValueForSuit( string suit, string columnName )
{
	var dataTable = GetDataTable( $"datatable/pilot_properties.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "type" ), suit )
	int column = GetDataTableColumnByName( dataTable, columnName )
	string value = GetDataTableString( dataTable, row, column )

	return value
}

int function GetTitanLoadoutPropertyPassiveType( string setFile, string loadoutProperty )
{
	Assert( loadoutProperty == "passive1" || loadoutProperty == "passive2" || loadoutProperty == "passive3" || loadoutProperty == "passive4" || loadoutProperty == "passive5" || loadoutProperty == "passive6")

	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "setFile" ), setFile )
	int column = GetDataTableColumnByName( dataTable, loadoutProperty )
	int itemType = eItemTypes[ GetDataTableString( dataTable, row, column ) ]

	return itemType
}

int function GetTitanLoadoutPropertyExecutionType( string setFile, string loadoutProperty )
{
	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "setFile" ), setFile )
	int column = GetDataTableColumnByName( dataTable, loadoutProperty )
	int itemType = eItemTypes[ GetDataTableString( dataTable, row, column ) ]

	return itemType
}

string function GetPrimeTitanSetFileFromNonPrimeSetFile( string nonPrimeSetFile ) //TODO: should just load titan_properties into memory instead of run-time lookup
{
	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "setFile" ), nonPrimeSetFile )
	int column = GetDataTableColumnByName( dataTable, "primeSetFile" )
	return GetDataTableString( dataTable, row, column )
}

string function GetTitanProperty_SetFile( string titanRef )
{
	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "titanRef" ), titanRef )

	return GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "setFile" ) )
}

int function GetTitanProperty_Passive1Type( string titanRef )
{
	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "titanRef" ), titanRef )

	return eItemTypes[ GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "passive1" ) ) ]
}

int function GetTitanProperty_Passive2Type( string titanRef )
{
	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "titanRef" ), titanRef )

	return eItemTypes[ GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "passive2" ) ) ]
}

int function GetTitanProperty_Passive3Type( string titanRef )
{
	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "titanRef" ), titanRef )

	return eItemTypes[ GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "passive3" ) ) ]
}

int function GetTitanProperty_Passive4Type( string titanRef )
{
	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "titanRef" ), titanRef )

	return eItemTypes[ GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "passive4" ) ) ]
}

int function GetTitanProperty_Passive5Type( string titanRef )
{
	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "titanRef" ), titanRef )

	return eItemTypes[ GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "passive5" ) ) ]
}

int function GetTitanProperty_Passive6Type( string titanRef )
{
	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "titanRef" ), titanRef )

	return eItemTypes[ GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "passive6" ) ) ]
}

asset function GetTitanCoreIcon( string titanRef )
{
	Assert( GetItemType( titanRef ) == eItemTypes.TITAN )
	ItemData itemData = GetItemData( titanRef )

	return expect asset( itemData.i.coreIcon )
}


string function GetWeaponBasedDefaultMod( string weapon, string propertyName )
{
	Assert( propertyName == "primaryAttachment" ||
					propertyName == "primaryMod1" ||
					propertyName == "primaryMod2" ||
					propertyName == "primaryMod3" ||
					propertyName == "secondaryMod1" ||
					propertyName == "secondaryMod2" ||
					propertyName == "secondaryMod3" ||
					propertyName == "weapon3Mod1" ||
					propertyName == "weapon3Mod2" ||
					propertyName == "weapon3Mod3" )

	string columnName
	if ( propertyName == "primaryAttachment" )
		columnName = "defaultAttachment"
	else if ( propertyName == "primaryMod1" || propertyName == "secondaryMod1" || propertyName == "weapon3Mod1" )
		columnName = "defaultMod1"
	else if ( propertyName == "primaryMod2" || propertyName == "secondaryMod2" || propertyName == "weapon3Mod2" )
		columnName = "defaultMod2"
	else
		columnName = "defaultMod3"

	string value = GetTableValueForWeapon( weapon, columnName )

	return value
}

string function GetTableValueForWeapon( string weapon, string columnName )
{
	var dataTable = GetDataTable( $"datatable/pilot_weapons.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "itemRef" ), weapon )
	int column = GetDataTableColumnByName( dataTable, columnName )
	string value = GetDataTableString( dataTable, row, column )

	return value
}

void function CheckEverythingUnlockedAchievement( entity player )
{
	Assert( IsServer() )

	//if ( !IsValid( player ) || !player.IsPlayer() )
	//	return
	//if ( player.IsBot() )
	//	return
	//
	//if ( player.GetPersistentVar( "ach_unlockEverything" ) )
	//	return
	//
	//foreach ( item in file.allItems )
	//{
	//	if ( item.Type == eItemTypes.TITAN_NOSE_ART )
	//		continue
	//
	//	if ( IsParentItemLocked( item.ref, item.childRef, player ) )
	//		return
	//}
	//
	//player.SetPersistentVar( "ach_unlockEverything", true )
}

ItemData ornull function DevFindItemByName( int itemType, string itemName )
{
	array<ItemData> items = GetAllItemsOfType( itemType )
	foreach ( item in items )
	{
		if ( item.ref == itemName )
		{
			return item
		}
	}

	return null
}

int function MenuCategoryStringToEnumValue( string stringVal )
{
	int enumVal = -1

	switch ( stringVal )
	{
		case "ar":
			enumVal = ePrimaryWeaponCategory.AR
			break

		case "smg":
			enumVal = ePrimaryWeaponCategory.SMG
			break

		case "lmg":
			enumVal = ePrimaryWeaponCategory.LMG
			break

		case "sniper":
			enumVal = ePrimaryWeaponCategory.SNIPER
			break

		case "shotgun":
			enumVal = ePrimaryWeaponCategory.SHOTGUN
			break

		case "handgun":
			enumVal = ePrimaryWeaponCategory.HANDGUN
			break

		case "special":
			enumVal = ePrimaryWeaponCategory.SPECIAL
			break

		case "at":
			enumVal = eSecondaryWeaponCategory.AT
			break

		case "pistol":
			enumVal = eSecondaryWeaponCategory.PISTOL
			break

		default:
			Assert( 0, "Unknown stringVal: " + stringVal )
	}

	return enumVal
}

int function MenuAnimClassStringToEnumValue( string stringVal )
{
	int enumVal = -1

	switch ( stringVal )
	{
		case "small":
			enumVal = eMenuAnimClass.SMALL
			break

		case "medium":
			enumVal = eMenuAnimClass.MEDIUM
			break

		case "large":
			enumVal = eMenuAnimClass.LARGE
			break

		case "custom":
			enumVal = eMenuAnimClass.CUSTOM
			break

		default:
			Assert( 0, "Unknown stringVal: " + stringVal )
	}

	return enumVal
}

asset function GetImage( int itemType, string itemRef, string childRef = "" )
{
	asset image

	if ( itemRef == "" )
		return image

	switch ( itemType )
	{
		case eItemTypes.PILOT_PRIMARY_ATTACHMENT:
		case eItemTypes.PILOT_PRIMARY_MOD:
		case eItemTypes.PILOT_SECONDARY_MOD:
		case eItemTypes.PILOT_WEAPON_MOD3:
			if ( childRef == "none" || childRef == "" )
			{
				if ( itemType == eItemTypes.PILOT_PRIMARY_ATTACHMENT )
					image = GetStockAttachmentImage( itemRef )
				else
					image = MOD_ICON_NONE
			}
			else
			{
				image = GetSubitemImage( itemRef, childRef )
			}
			break

		case eItemTypes.RACE:
			Assert( itemRef == "race_human_male" || itemRef == "race_human_female" )
			if ( itemRef == "race_human_male" )
				image = $"rui/menu/common/gender_button_male"
			else
				image = $"rui/menu/common/gender_button_female"
			break

		default:
			image = GetItemImage( itemRef )
	}

	return image
}

array<string> function GetAllWeaponsByType( array<int> weaponTypes )
{
	array<string> weapons
	foreach ( weaponType in weaponTypes )
	{
		foreach ( weapon in GetAllItemRefsOfType( weaponType ) )
		{
			// mp puts weapons into its list multiple times
			if ( weapons.contains( weapon ) )
				continue
			weapons.append( weapon )
		}
	}
	return weapons
}

string function GetItemRefTypeName( string itemRef, string parentItemRef = "" )
{
	int itemType = GetItemType( itemRef )
	int parentItemType = parentItemRef != "" ? GetItemType( parentItemRef ) : -1

	if ( itemType == eItemTypes.FEATURE )
	{
		ItemData featureItem = GetItemData( itemRef )
		return expect string( featureItem.i.specificType )
	}
	else if ( itemType == eItemTypes.TITAN_FD_UPGRADE )
	{
		ItemData item = GetItemData( itemRef )
		return expect string( item.i.upgradeTypeCategory )
	}

	return GetItemTypeName( itemType, parentItemType )
}

string function GetItemTypeName( int itemType, int parentItemType = -1 )
{
	switch ( itemType )
	{
		case eItemTypes.PILOT_PRIMARY:
			return "#ITEM_TYPE_PILOT_PRIMARY"

		case eItemTypes.TITAN_PRIMARY:
			return "#ITEM_TYPE_TITAN_PRIMARY"

		case eItemTypes.PILOT_SECONDARY:
			return "#ITEM_TYPE_PILOT_SECONDARY"

		case eItemTypes.PILOT_SPECIAL:
			return "#ITEM_TYPE_PILOT_SPECIAL"

		case eItemTypes.TITAN_SPECIAL:
			return "#ITEM_TYPE_TITAN_SPECIAL"

		case eItemTypes.PILOT_ORDNANCE:
			return "#ITEM_TYPE_PILOT_ORDNANCE"

		case eItemTypes.TITAN_ORDNANCE:
			return "#ITEM_TYPE_TITAN_ORDNANCE"

		case eItemTypes.TITAN_ANTIRODEO:
			return "#ITEM_TYPE_TITAN_ANTIRODEO"

		case eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT:
		case eItemTypes.PILOT_PRIMARY_ATTACHMENT:
			if ( parentItemType != -1 )
				return "#ITEM_TYPE_WEAPON_SPECIFIC_ATTACHMENT"
			else
				return "#ITEM_TYPE_WEAPON_GENERIC_ATTACHMENT"

		case eItemTypes.SUB_PILOT_WEAPON_MOD:
		case eItemTypes.PILOT_PRIMARY_MOD:
		case eItemTypes.TITAN_PRIMARY_MOD:
			if ( parentItemType != -1 )
				return "#ITEM_TYPE_WEAPON_SPECIFIC_MOD"
			else
				return "#ITEM_TYPE_WEAPON_GENERIC_MOD"

		case eItemTypes.CALLING_CARD:
			return "#ITEM_TYPE_CALLING_CARD"

		case eItemTypes.CAMO_SKIN_PILOT:
			return "#ITEM_TYPE_CAMO_SKIN_PILOT"

		case eItemTypes.CAMO_SKIN_TITAN:
			if ( parentItemType != -1 )
				return "#ITEM_TYPE_SPECIFIC_CAMO"
			else
				return "#ITEM_TYPE_CAMO_SKIN_TITAN"

		case eItemTypes.TITAN_WARPAINT:
			return "#ITEM_TYPE_TITAN_WARPAINT"

		case eItemTypes.CAMO_SKIN:
			if ( parentItemType != -1 )
			{
				if ( parentItemType == eItemTypes.TITAN )
					return "#ITEM_TYPE_SPECIFIC_WEAPON_CAMO"
				else
					return "#ITEM_TYPE_SPECIFIC_CAMO"
			}
			else
				return "#ITEM_TYPE_CAMO_SKIN"

		case eItemTypes.CALLSIGN_ICON:
			return "#ITEM_TYPE_CALLSIGN_ICON"

		case eItemTypes.BURN_METER_REWARD:
			return "#ITEM_TYPE_BURN_METER_REWARD"

		case eItemTypes.TITAN_ION_PASSIVE:
		case eItemTypes.TITAN_SCORCH_PASSIVE:
		case eItemTypes.TITAN_RONIN_PASSIVE:
		case eItemTypes.TITAN_LEGION_PASSIVE:
		case eItemTypes.TITAN_VANGUARD_PASSIVE:
		case eItemTypes.TITAN_TONE_PASSIVE:
		case eItemTypes.TITAN_NORTHSTAR_PASSIVE:
			if ( parentItemType != -1 )
				return "#ITEM_TYPE_TITAN_SPECIFIC_KIT"
			else
				return "#ITEM_TYPE_TITAN_GENERIC_KIT"

		case eItemTypes.TITAN_UPGRADE1_PASSIVE:
			return "#ITEM_TYPE_UPGRADE1"
		case eItemTypes.TITAN_UPGRADE2_PASSIVE:
			return "#ITEM_TYPE_UPGRADE2"
		case eItemTypes.TITAN_UPGRADE3_PASSIVE:
			return "#ITEM_TYPE_UPGRADE3"

		case eItemTypes.TITAN_GENERAL_PASSIVE:
			return "#ITEM_TYPE_TITAN_GENERAL_PASSIVE"

		case eItemTypes.TITAN_TITANFALL_PASSIVE:
			return "#ITEM_TYPE_TITAN_TITANFALL_PASSIVE"

		case eItemTypes.TITAN:
			return "#ITEM_TYPE_TITAN"

		case eItemTypes.RACE:
			return "#GENDER"

		case eItemTypes.TITAN_NOSE_ART:
		case eItemTypes.PRIME_TITAN_NOSE_ART:
			return "#ITEM_TYPE_TITAN_NOSE_ART"

		case eItemTypes.PILOT_EXECUTION:
			return "#ITEM_TYPE_PILOT_EXECUTION"

		case eItemTypes.TITAN_ION_EXECUTION:
		case eItemTypes.TITAN_SCORCH_EXECUTION:
		case eItemTypes.TITAN_RONIN_EXECUTION:
		case eItemTypes.TITAN_LEGION_EXECUTION:
		case eItemTypes.TITAN_VANGUARD_EXECUTION:
		case eItemTypes.TITAN_TONE_EXECUTION:
		case eItemTypes.TITAN_NORTHSTAR_EXECUTION:
			if ( parentItemType != -1 )
				return "#ITEM_TYPE_TITAN_SPECIFIC_EXECUTION"
							else
				return "#ITEM_TYPE_TITAN_EXECUTION"

		case eItemTypes.PILOT_PASSIVE1:
		case eItemTypes.PILOT_PASSIVE2:
			return "#ITEM_TYPE_PILOT_PASSIVE"

		case eItemTypes.FACTION:
			return "#ITEM_TYPE_FACTION"

		case eItemTypes.FEATURE:
			return "#ITEM_TYPE_FEATURE"

		case eItemTypes.WEAPON_FEATURE:
			return "#ITEM_TYPE_WEAPON_FEATURE"

		case eItemTypes.PILOT_SUIT:
			return "#ITEM_TYPE_PILOT_SPECIAL"

		case eItemTypes.COMMS_ICON:
			return "#ITEM_TYPE_COMMS_ICON"

		case eItemTypes.TITAN_FD_UPGRADE:
			return "#ITEM_TYPE_FD_UPGRADES"

		default:
		#if DEV
			Assert( false, "Invalid item type: " + DEV_GetEnumStringFromIndex( "eItemTypes", itemType) )
		#endif
	}

	return "UNDEFINED"
}

/*
	PILOT_PRIMARY,
	PILOT_SECONDARY,
	PILOT_SPECIAL,
	PILOT_ORDNANCE,
	PILOT_PRIMARY_ATTACHMENT,
	PILOT_PRIMARY_MOD,
	PILOT_SECONDARY_MOD,
	PILOT_PASSIVE1,
	PILOT_PASSIVE2,
	TITAN_PRIMARY,
	TITAN_SPECIAL,
	TITAN_ANTIRODEO,
	TITAN_ORDNANCE,
	TITAN_PRIMARY_MOD,
	TITAN_OS,
	RACE,
	NOT_LOADOUT,
	TITAN_NOSE_ART,
	PILOT_SUIT,
	TITAN_CORE_ABILITY,
	BURN_METER_REWARD,
	PILOT_MELEE,
	TITAN,
	FEATURE,
	CALLING_CARD,
	CALLSIGN_ICON,
	CAMO_SKIN,
	CAMO_SKIN_PILOT,
	CAMO_SKIN_TITAN,
	SUB_PILOT_WEAPON_MOD,
	SUB_PILOT_WEAPON_ATTACHMENT,
	FACTION,
	PILOT_EXECUTION,
	TITAN_GENERAL_PASSIVE,
	TITAN_TITANFALL_PASSIVE,
	TITAN_RONIN_PASSIVE,
	TITAN_NORTHSTAR_PASSIVE,
	TITAN_ION_PASSIVE,
	TITAN_TONE_PASSIVE,
	TITAN_SCORCH_PASSIVE,
	TITAN_LEGION_PASSIVE,
*/

void function ItemReport()
{
	table itemTypesEnum = expect table( getconsttable().eItemTypes )

	array<string> itemTypeIndexToName
	itemTypeIndexToName.resize( itemTypesEnum.len(), "UNDEFINED" )
	foreach ( name, index in itemTypesEnum )
	{
		expect int( index )
		itemTypeIndexToName[index] = string( name )
	}

	array<GlobalItemRef> allItemsRefData = GetAllItemRefs()

	table<string, int> subItemRefs

	printt( "ITEM REPORT:" )
	foreach ( typeIndex, typeName in itemTypeIndexToName )
	{
		if ( typeName == "COUNT" )
			continue

		printt( typeName )
		array<string> itemRefs = GetAllItemRefsOfType( typeIndex )
		foreach ( itemRef in itemRefs )
		{
			ItemData itemData = GetItemData( itemRef )
			if ( itemRef in subItemRefs )
			{
				printt( itemRef, itemData.persistenceId, "use count: ", subItemRefs[itemRef] )
				Assert( !(itemRef in file.unlocks) )
			}
			else
				printt( itemRef, itemData.persistenceId, itemData.persistenceStruct )

			foreach ( subItemRef, subItemData in itemData.subitems )
			{
				printt( "\t", subItemRef )
				if ( !(subItemRef in subItemRefs) )
				{
					subItemRefs[subItemRef] <- 0
				}

				subItemRefs[subItemRef]++
			}
		}

		printt( "\n" )
	}
}


void function UnlockReport()
{
	table itemTypesEnum = expect table( getconsttable().eItemTypes )
	table unlockTypesEnum = expect table( getconsttable().eUnlockType )

	array<string> unlockIndexToName
	unlockIndexToName.resize( unlockTypesEnum.len(), "UNDEFINED" )
	foreach ( name, index in unlockTypesEnum )
	{
		expect int( index )
		unlockIndexToName[index] = string( name )
	}

	array<string> itemTypeIndexToName
	itemTypeIndexToName.resize( itemTypesEnum.len(), "UNDEFINED" )
	foreach ( name, index in itemTypesEnum )
	{
		expect int( index )
		itemTypeIndexToName[index] = string( name )
	}

	array<GlobalItemRef> allItemsRefData = GetAllItemRefs()

	foreach ( typeIndex, typeName in itemTypeIndexToName )
	{
		if ( typeName == "COUNT" )
			continue

		printt( typeName )

		switch ( typeIndex )
		{
			case eItemTypes.TITAN_SPECIAL:
			case eItemTypes.TITAN_ANTIRODEO:
			case eItemTypes.TITAN_ORDNANCE:
				continue
		}

		array<string> itemRefs = GetAllItemRefsOfType( typeIndex )
		foreach ( itemRef in itemRefs )
		{
			ItemData itemData = GetItemData( itemRef )
			if ( itemRef in file.unlocks )
			{
				printt( "\t", itemRef, unlockIndexToName[file.unlocks[itemRef].unlockType] )

				foreach ( subItemRef, subItemData in itemData.subitems )
				{
					if ( !(subItemRef in file.unlocks[itemRef].child ) )
					{
						CodeWarning( typeName + " " + itemRef + " contains subitem " + subItemRef + " but does not unlock it." )
					}
				}
			}
			else
			{
				bool found = false
				foreach ( ref, unlockData in file.unlocks )
				{
					if ( !ItemDefined( ref ) )
						continue

					if ( itemRef in unlockData.child )
					{
						found = true
						printt( "\t", itemRef, ref, unlockIndexToName[unlockData.child[itemRef].unlockType] )
						break
					}
				}

				if ( !found )
					printt( "\t", itemRef, "***" )
			}
		}
		printt( "\n" )
	}
/*
	foreach ( ref, unlockData in file.unlocks )
	{
		if ( !ItemDefined( ref ) )
		{
			printt( "bogus unlock ref:", ref )
			continue
		}

		ItemData itemData = GetItemData( ref )
	}

	foreach ( ref, unlockData in file.unlocks )
	{
		if ( !ItemDefined( ref ) )
		{
			printt( "bogus unlock ref:", ref )
			printt( "\t", itemRef, unlockIndexToName[file.unlocks[itemRef].unlockType] )
		}
	}
	*/
}



void function UnlockDump()
{
	table itemTypesEnum = expect table( getconsttable().eItemTypes )
	table unlockTypesEnum = expect table( getconsttable().eUnlockType )

	array<string> unlockIndexToName
	unlockIndexToName.resize( unlockTypesEnum.len(), "UNDEFINED" )
	foreach ( name, index in unlockTypesEnum )
	{
		expect int( index )
		unlockIndexToName[index] = string( name )
	}

	array<string> itemTypeIndexToName
	itemTypeIndexToName.resize( itemTypesEnum.len(), "UNDEFINED" )
	foreach ( name, index in itemTypesEnum )
	{
		expect int( index )
		itemTypeIndexToName[index] = string( name )
	}

	foreach ( ref, unlock in file.unlocks )
	{
		printt( ref, DEV_GetEnumStringFromIndex( "eUnlockType", unlock.unlockType ), unlock.unlockLevel )

		foreach ( childRef, child in unlock.child )
		{
			printt( "\t", childRef, DEV_GetEnumStringFromIndex( "eUnlockType", child.unlockType ), child.unlockLevel )
		}
	}
/*

		switch ( typeIndex )
		{
			case eItemTypes.TITAN_SPECIAL:
			case eItemTypes.TITAN_ANTIRODEO:
			case eItemTypes.TITAN_ORDNANCE:
				continue
		}

		array<string> itemRefs = GetAllItemRefsOfType( typeIndex )
		foreach ( itemRef in itemRefs )
		{
			ItemData itemData = GetItemData( itemRef )
			if ( itemRef in file.unlocks )
			{
				printt( "\t", itemRef, unlockIndexToName[file.unlocks[itemRef].unlockType] )
			}
			else
			{
				bool found = false
				foreach ( ref, unlockData in file.unlocks )
				{
					if ( !ItemDefined( ref ) )
						continue

					if ( itemRef in unlockData.child )
					{
						found = true
						printt( "\t", itemRef, ref, unlockIndexToName[unlockData.child[itemRef].unlockType] )
						break
					}
				}

				if ( !found )
					printt( "\t", itemRef, "***" )
			}
		}
		printt( "\n" )
	}
	*/
}

bool function IsSubItemType( int itemType )
{
	switch ( itemType )
	{
		case eItemTypes.PILOT_PRIMARY_ATTACHMENT:
		case eItemTypes.PILOT_PRIMARY_MOD:
		case eItemTypes.PILOT_SECONDARY_MOD:
		case eItemTypes.PILOT_WEAPON_MOD3:
		case eItemTypes.TITAN_GENERAL_PASSIVE:
		case eItemTypes.TITAN_TITANFALL_PASSIVE:
		case eItemTypes.TITAN_RONIN_PASSIVE:
		case eItemTypes.TITAN_NORTHSTAR_PASSIVE:
		case eItemTypes.TITAN_ION_PASSIVE:
		case eItemTypes.TITAN_TONE_PASSIVE:
		case eItemTypes.TITAN_SCORCH_PASSIVE:
		case eItemTypes.TITAN_LEGION_PASSIVE:
		case eItemTypes.TITAN_VANGUARD_PASSIVE:
		case eItemTypes.TITAN_UPGRADE1_PASSIVE:
		case eItemTypes.TITAN_UPGRADE2_PASSIVE:
		case eItemTypes.TITAN_UPGRADE3_PASSIVE:
		case eItemTypes.TITAN_NOSE_ART:
		case eItemTypes.PRIME_TITAN_NOSE_ART:
		case eItemTypes.SUB_PILOT_WEAPON_ATTACHMENT:
		case eItemTypes.SUB_PILOT_WEAPON_MOD:
		case eItemTypes.CAMO_SKIN:
		case eItemTypes.CAMO_SKIN_TITAN:
		case eItemTypes.TITAN_WARPAINT:
		case eItemTypes.WEAPON_FEATURE:
		case eItemTypes.TITAN_FD_UPGRADE:
		case eItemTypes.WEAPON_SKIN:
			return true
	}

	return false
}

ItemDisplayData function GetItemDisplayData( string itemRef, string parentRef = "" )
{
	if ( (parentRef + itemRef) in file.displayDataCache )
		return file.displayDataCache[parentRef + itemRef]

	ItemData itemData = GetItemData( itemRef )
	ItemDisplayData displayData

	if ( parentRef != "" && !IsItemRandom( itemRef ) )
	{
		Assert( IsSubItemType( itemData.itemType ) )
		ItemData parentItem = GetItemData( parentRef )

		displayData.itemType = parentItem.subitems[itemRef].itemType
		displayData.i = clone parentItem.subitems[itemRef].i
	}
	else
	{
		Assert( !IsSubItemType( itemData.itemType ) )
		displayData.itemType = itemData.itemType
		displayData.i = clone itemData.i
	}

	displayData.name = itemData.name
	displayData.desc = itemData.desc
	displayData.longdesc = itemData.longdesc
	displayData.image = itemData.image
	displayData.hidden = itemData.hidden
	displayData.ref = itemRef
	displayData.parentRef = parentRef
	displayData.imageAtlas = itemData.imageAtlas
	displayData.persistenceId = itemData.persistenceId

	file.displayDataCache[parentRef + itemRef] <- displayData

	return displayData
}


bool function IsItemRandom( string itemRef )
{
	if ( itemRef == "random" )
		return true

	if ( itemRef == "advocate_gift" )
		return true

	return false
}

string function DEV_GetEnumStringFromIndex( string enumName, int enumIndex )
{
	table enumTable = expect table( getconsttable()[enumName] )

	foreach ( name, index in enumTable )
	{
		if ( index == enumIndex )
			return string( name )
	}

	return "not found"
}

ItemDisplayData function GetItemDisplayDataFromGuid( int refGuid, int parentRefGuid = 0 )
{
	string itemRef
	string parentItemRef

	for( int index = 0; index < file.allItems.len(); index++ )
	{
		GlobalItemRef globalItemRef = file.allItems[index]

		if ( itemRef == "" && globalItemRef.guid == refGuid )
		{
			itemRef = globalItemRef.ref
			if ( parentRefGuid == 0 || parentItemRef != "" )
				break
		}
		else if ( parentItemRef == "" && parentRefGuid != 0 && globalItemRef.guid == parentRefGuid )
		{
			parentItemRef = globalItemRef.ref
			if ( itemRef != "" )
				break
		}
	}

	Assert( itemRef != "" )
	Assert( (parentRefGuid == 0 && parentItemRef == "") || parentItemRef != "" )

	return GetItemDisplayData( itemRef, parentItemRef )
}


int function StringHash( string str )
{
	int res = 0
	int length = str.len()
	for ( int i = 0; i < length; i++ )
	{
		res *= 31
		res += expect int( str[i] )
	}
	return res
}


string function GetFullRef( string itemRef, string parentRef = "" )
{
	if ( parentRef != "" )
		return parentRef + "." + itemRef
	else
		return itemRef

	unreachable
}

bool function IsItemInEntitlementUnlock( string itemRef, string parentRef = "" )
{
	string fullRef = GetFullRef( itemRef, parentRef )

	return fullRef in file.entitlementUnlocks
}


void function InitUnlockAsEntitlement( string itemRef, string parentRef, int entitlementId, string purchaseMenu = "" )
{
    if ( IsDisabledRef( itemRef ) || IsDisabledRef( parentRef ) )
        return

#if DEV
	if ( parentRef == "" )
	{
		Assert( ItemDefined( itemRef ), itemRef + " does not exist but is being initialized as an entitlement" )

		if ( itemRef in file.unlocks )
			CodeWarning( parentRef + "." + itemRef + " already exists in Unlocks but is being initialized as an entitlement" )
	}
	else
	{
		Assert( SubitemDefined( parentRef, itemRef ), parentRef + "." + itemRef + " does not exist but is being initialized as an entitlement" )

		if ( parentRef in file.unlocks && itemRef in file.unlocks[ parentRef ].child )
			CodeWarning( parentRef + "." + itemRef + " already exists in Unlocks but is being initialized as an entitlement" )
	}

	if ( IsItemInRandomUnlocks( itemRef, parentRef ) )
		CodeWarning( parentRef + "." + itemRef + " already exists in Random Unlocks but is being initialized as an entitlement" )

#endif
	string fullRef = GetFullRef( itemRef, parentRef )
	Unlock unlock

	if ( !(fullRef in file.entitlementUnlocks) )
	{
		unlock.unlockType = eUnlockType.ENTITLEMENT
		file.entitlementUnlocks[fullRef] <- unlock
		unlock.purchaseData.purchaseMenu = purchaseMenu
	}
	else
	{
		unlock = file.entitlementUnlocks[fullRef]
	}

	unlock.entitlementIds.append( entitlementId )
}

array<int> function GetEntitlementIds( string itemRef, string parentRef = "" )
{
	string fullRef = GetFullRef( itemRef, parentRef )

	Assert( fullRef in file.entitlementUnlocks )

	return clone file.entitlementUnlocks[fullRef].entitlementIds
}

int function GetSortedIndex( string menuName, int elemNum )
{
	if ( menuName in file.sortedElems )
		return file.sortedElems[menuName][elemNum]

	return elemNum
}

void function RefreshSortedElems( entity player, string menuName, int maxElems, ItemDisplayData functionref(int) getFunc )
{
	if (!( menuName in file.sortedElems ))
	{
		file.sortedElems[menuName] <- []
	}

	file.sortedElems[menuName].clear()
	array<int> new = []
	array<int> locked = []
	array<int> unlocked = []
	for( int i=0; i<maxElems; i++ )
	{
		ItemDisplayData item = getFunc( i )
		string ref = item.ref
		if ( IsItemLocked( player, ref ) )
			locked.append( i )
		else if ( IsItemNew( player, ref, item.parentRef ) )
			new.append( i )
		else
			unlocked.append( i )
	}
	file.sortedElems[menuName].extend( new )
	file.sortedElems[menuName].extend( unlocked )
	file.sortedElems[menuName].extend( locked )
}
#if SERVER

void function StatsCallback_ItemUnlockUpdate( entity player, float changeInValue, string itemRef )
{
	Unlock unlock = file.unlocks[ itemRef ]
	int statType = expect int( unlock.additionalData.statType )
	string statVar = expect string( unlock.additionalData.statVar )
	string statCategory = expect string( unlock.additionalData.statCategory )
	string statAlias = expect string( unlock.additionalData.statAlias )
	string statSubAlias = expect string( unlock.additionalData.statSubAlias )

	thread Stats_SaveStatDelayed( player, statCategory, statAlias, statSubAlias )

	if ( statType == ePlayerStatType.INT )
	{
		int oldStatVal = GetPlayerStatInt( player, statCategory, statAlias, statSubAlias )
		int deltaStatVal = PlayerStat_GetCurrentInt( player, statCategory, statAlias, statSubAlias )

		if ( oldStatVal >= unlock.unlockIntVal )
			return

		if ( oldStatVal + deltaStatVal < unlock.unlockIntVal )
			return

		StatUnlock_Unlocked( player, itemRef, "", statCategory, statAlias, statSubAlias )
	}
	else
	{
		float oldStatVal = GetPlayerStatFloat( player, statCategory, statAlias, statSubAlias )
		float deltaStatVal = PlayerStat_GetCurrentFloat( player, statCategory, statAlias, statSubAlias )

		if ( oldStatVal >= unlock.unlockFloatVal )
			return

		if ( oldStatVal + deltaStatVal < unlock.unlockFloatVal )
			return

		StatUnlock_Unlocked( player, itemRef, "", statCategory, statAlias, statSubAlias )
	}
}


void function StatsCallback_SubItemUnlockUpdate( entity player, float changeInValue, string fullRef )
{
	array<string> splitArray = SplitAndStripUnlockField( fullRef )
	string itemRef = splitArray[0]
	string parentRef = splitArray[1]

	ChildUnlock unlock = file.unlocks[ parentRef ].child[itemRef]
	int statType = expect int( unlock.additionalData.statType )
	string statVar = expect string( unlock.additionalData.statVar )
	string statCategory = expect string( unlock.additionalData.statCategory )
	string statAlias = expect string( unlock.additionalData.statAlias )
	string statSubAlias = expect string( unlock.additionalData.statSubAlias )

	thread Stats_SaveStatDelayed( player, statCategory, statAlias, statSubAlias )

	if ( statType == ePlayerStatType.INT )
	{
		int oldStatVal = GetPlayerStatInt( player, statCategory, statAlias, statSubAlias )
		int curStatVal = PlayerStat_GetCurrentInt( player, statCategory, statAlias, statSubAlias )

		if ( oldStatVal >= unlock.unlockIntVal )
			return

		if ( oldStatVal + curStatVal < unlock.unlockIntVal )
			return

		StatUnlock_Unlocked( player, itemRef, parentRef, statCategory, statAlias, statSubAlias )
	}
	else
	{
		float oldStatVal = GetPlayerStatFloat( player, statCategory, statAlias, statSubAlias )
		float curStatVal = PlayerStat_GetCurrentFloat( player, statCategory, statAlias, statSubAlias )

		if ( oldStatVal >= unlock.unlockFloatVal )
			return

		if ( oldStatVal + curStatVal < unlock.unlockFloatVal )
			return

		StatUnlock_Unlocked( player, itemRef, parentRef, statCategory, statAlias, statSubAlias )
	}
}

void function StatUnlock_Unlocked( entity player, string itemRef, string parentRef, string statCategory, string statAlias, string statSubAlias )
{
	// early out if we've already marked this as new
	if ( IsItemNew( player, itemRef, parentRef ) )
		return

	int refGuid = file.itemRefToGuid[itemRef]
	int parentRefGuid = parentRef == "" ? 0 : file.itemRefToGuid[parentRef]

	if ( parentRef != "" )
	{
		int itemType = GetItemType( parentRef )
		switch ( itemType )
		{
			case eItemTypes.PILOT_PRIMARY:
			case eItemTypes.PILOT_SECONDARY:
				int weaponIndex = shWeaponXP.weaponClassNames.find( parentRef )
				Remote_CallFunction_NonReplay( player, "ServerCallback_WeaponChallengeCompleted", weaponIndex, refGuid, parentRefGuid )
				break
			case eItemTypes.TITAN_PRIMARY:
				int titanIndex = shTitanXP.titanClasses.find( GetTitanForWeapon( parentRef ) )
				Remote_CallFunction_NonReplay( player, "ServerCallback_TitanChallengeCompleted", titanIndex, refGuid, parentRefGuid )
				break
			case eItemTypes.TITAN:
				int titanIndex = shTitanXP.titanClasses.find( parentRef )
				Remote_CallFunction_NonReplay( player, "ServerCallback_TitanChallengeCompleted", titanIndex, refGuid, parentRefGuid )
				break
			default:
				Remote_CallFunction_NonReplay( player, "ServerCallback_PlayerChallengeCompleted", refGuid, parentRefGuid )
				break
		}
	}
	else
	{
		int itemType = GetItemType( itemRef )
		switch ( itemType )
		{
			case eItemTypes.TITAN:
				int titanIndex = shTitanXP.titanClasses.find( parentRef )
				Remote_CallFunction_NonReplay( player, "ServerCallback_TitanChallengeCompleted", titanIndex, refGuid, parentRefGuid )
				break
			default:
				Remote_CallFunction_NonReplay( player, "ServerCallback_PlayerChallengeCompleted", refGuid, parentRefGuid )
				break
		}
	}

	if ( player.p.challengeUnlocks.len() < 6 )
	{
		RecentUnlock challengeUnlock
		challengeUnlock.refGuid = refGuid
		challengeUnlock.parentRefGuid = parentRefGuid

		player.p.challengeUnlocks.append( challengeUnlock )
	}

	SetItemNewStatus( player, itemRef, parentRef, true )
}
#endif

int function CheckItemUnlockType( string ref, string parentRef = "" )
{
	if ( IsItemInRandomUnlocks( ref, parentRef ) )
		return eUnlockType.RANDOM

	if ( IsItemInEntitlementUnlock( ref, parentRef ) )
		return eUnlockType.ENTITLEMENT

	if ( parentRef != "" )
		return file.unlocks[parentRef].child[ref].unlockType
	else
		return file.unlocks[ref].unlockType

	unreachable
}

#if SERVER
void function PersistenceCleanup( entity player )
{
	ClearTargetNew( player )
	FixupLevelCamosForRegen( player )
}

string function GetNoseArtRefFromTitanClassAndPersistenceValue( string titanClass, int persistenceValue ) //TODO: Replace NoseArtIndexToRef() with this eventually
{
	if ( !( titanClass in file.titanClassAndPersistenceValueToNoseArtRefTable ) )
		return INVALID_REF

	if ( !( persistenceValue in file.titanClassAndPersistenceValueToNoseArtRefTable[ titanClass ] ) )
		return INVALID_REF

	return file.titanClassAndPersistenceValueToNoseArtRefTable[ titanClass ][ persistenceValue ]
}

string function GetSkinRefFromTitanClassAndPersistenceValue( string titanClass, int persistenceValue )
{
	if ( !( titanClass in file.titanClassAndPersistenceValueToSkinRefTable ) )
		return INVALID_REF

	if ( !( persistenceValue in file.titanClassAndPersistenceValueToSkinRefTable[ titanClass ] ) )
		return INVALID_REF

	return file.titanClassAndPersistenceValueToSkinRefTable[ titanClass ][ persistenceValue ]
}
#endif // SERVER

string function GetSkinRefFromWeaponRefAndPersistenceValue( string weaponRef, int persistenceValue )
{
	if ( !( weaponRef in file.weaponRefAndPersistenceValueToSkinRefTable ) )
		return INVALID_REF

	if ( !( persistenceValue in file.weaponRefAndPersistenceValueToSkinRefTable[ weaponRef ] ) )
		return INVALID_REF

	return file.weaponRefAndPersistenceValueToSkinRefTable[ weaponRef ][ persistenceValue ]
}

const array<string> liveDisabledRefs = [ "vanguard_skin_01", "vanguard_skin_02", "vanguard_skin_03", "vanguard_skin_07", "vanguard_skin_08" ]
const array<string> disabledRefs = [ "mp_ability_pathchooser" ]

bool function IsDisabledRef( string ref )
{
	if ( liveDisabledRefs.contains( ref ) )
		return true

    #if DEVSCRIPTS
        return false
    #endif

    return ( disabledRefs.contains( ref ) )
}

#if DEV
void function GenerateAllValidateDataTableCRCCheckText()
{
	GenerateValidateDataTableCRCText( $"datatable/burn_meter_rewards.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/calling_cards.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/callsign_icons.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/camo_skins.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/faction_leaders.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/features_mp.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/pilot_abilities.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/pilot_executions.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/pilot_passives.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/pilot_properties.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/pilot_weapon_features.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/pilot_weapon_mods.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/pilot_weapon_mods_common.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/pilot_weapons.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/playlist_items.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/titan_nose_art.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/titan_passives.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/titan_primary_mods.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/titan_primary_mods_common.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/titan_properties.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/titan_skins.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/titan_voices.rpak" )
	GenerateValidateDataTableCRCText( $"datatable/titans_mp.rpak" )
}

string function GenerateValidateDataTableCRCText( asset dataTableAsset )
{
	var dataTable = GetDataTable( dataTableAsset )
	int numRows = GetDatatableRowCount( dataTable )

	int dataTableCRC = 0

	for( int index = 0; index < numRows; index++ )
	{
		string ref = GetDataTableString( dataTable, index, 0 )

		dataTableCRC = dataTableCRC ^ StringHash( ref )
		dataTableCRC = (dataTableCRC << 13) ^ (dataTableCRC >> 17)
	}

	string resultString = ( "ValidateDataTableCRC( " + dataTableAsset + ", " + numRows + ", " + dataTableCRC + ")" )

	printt( resultString )

	return resultString
}


void function ValidateDataTableCRC( asset dataTableAsset, int numRows, int generatedCRC )
{
	var dataTable = GetDataTable( dataTableAsset )

	int dataTableCRC = 0

	for( int index = 0; index < numRows; index++ )
	{
		string ref = GetDataTableString( dataTable, index, 0 )

		dataTableCRC = dataTableCRC ^ StringHash( ref )
		dataTableCRC = (dataTableCRC << 13) ^ (dataTableCRC >> 17)
	}

	if( dataTableCRC != generatedCRC )
	{
		printt( "DataTableCRC mismatch:", dataTableAsset )
		Assert( dataTableCRC == generatedCRC )
	}
}
#endif

bool function GetItemRequiresPrime( string ref, string parentRef = "" )
{
	Assert( ref in file.itemData )
	return file.itemData[ref].reqPrime
}

void function SetupWeaponSkinData()
{
	var dataTable = GetDataTable( $"datatable/weapon_skins.rpak" )
	for ( int row = 0; row < GetDatatableRowCount( dataTable ); row++ )
	{
		string weaponRef = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "weaponRef" ) )
		string ref = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "ref" ) )
		asset image = GetDataTableAsset( dataTable, row, GetDataTableColumnByName( dataTable, "image" ) )
		string name = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "name" ) )
		int skinIndex = GetDataTableInt( dataTable, row, GetDataTableColumnByName( dataTable, "skinIndex" ) )
		int skinType = GetDataTableInt( dataTable, row, GetDataTableColumnByName( dataTable, "skinType" ) )
		int datatableIndex = row

		if ( IsDisabledRef( weaponRef ) )
			continue

		CreateWeaponSkinData( datatableIndex, eItemTypes.WEAPON_SKIN, false, ref, weaponRef, name, image, skinIndex, skinType )
		CreateGenericSubItemData( eItemTypes.WEAPON_SKIN, weaponRef, ref, 0, { skinIndex = skinIndex } )

		if ( !( weaponRef in file.weaponRefAndPersistenceValueToSkinRefTable ) )
			file.weaponRefAndPersistenceValueToSkinRefTable[ weaponRef ] <- {}

		file.weaponRefAndPersistenceValueToSkinRefTable[ weaponRef ][ skinIndex ] <- ref
	}
}

bool function ItemsInSameMenuCategory( string itemRef1, string itemRef2 )
{
	int category1 = expect int( GetItemDisplayData( itemRef1 ).i.menuCategory )
	int category2 = expect int( GetItemDisplayData( itemRef2 ).i.menuCategory )

	if ( category1 == category2 )
		return true

	return false
}

asset function GetTitanLoadoutIconFD( string titanRef )
{
	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )
	int loadoutIconCol = GetDataTableColumnByName( dataTable, "loadoutIconFD" )
	int titanCol = GetDataTableColumnByName( dataTable, "titanRef" )

	int row = GetDataTableRowMatchingStringValue( dataTable, titanCol, titanRef )

	return GetDataTableAsset( dataTable, row, loadoutIconCol )
}

array<string> function GetOwnedEliteWeaponSkins( entity player )
{
	array<ItemData> allWeaponSkins = GetAllItemsOfType( eItemTypes.WEAPON_SKIN )

	array<string> ownedWeaponSkinRefs
	foreach ( weaponSkinItem in allWeaponSkins )
	{
		string parentRef = weaponSkinItem.parentRef

		if ( !IsSubItemLocked( player, weaponSkinItem.ref, weaponSkinItem.parentRef ) && expect int( weaponSkinItem.i.skinType ) == 1 )
			ownedWeaponSkinRefs.append( weaponSkinItem.ref )
	}

	return ownedWeaponSkinRefs
}

asset function GetTitanPrimeBg( string titanClass )
{
	switch ( titanClass )
	{
		case "ion":
			return $"rui/menu/store/prime_ion_bg"
		case "scorch":
			return $"rui/menu/store/prime_scorch_bg"
		case "northstar":
			return $"rui/menu/store/prime_northstar_bg"
		case "ronin":
			return $"rui/menu/store/prime_ronin_bg"
		case "tone":
			return $"rui/menu/store/prime_tone_bg"
		case "legion":
			return $"rui/menu/store/prime_legion_bg"
		case "monarch":
			return $"rui/menu/store/prime_legion_bg"
	}

	return $""
}

struct FullRefWithEntitlements
{
	string fullRef
	array<int> entitlementIds
}

array<string> function GetItemRefsForEntitlements( array<int> entitlements )
{
	array<int> filteredEntitlements

	foreach ( entitlement in entitlements )
	{
		if ( HasChildEntitlements( entitlement ) )
		{
			array<int> childEntitlements = GetChildEntitlements( entitlement )
			foreach ( childEntitlement in childEntitlements )
			{
				if ( !filteredEntitlements.contains( childEntitlement ) )
					filteredEntitlements.append( childEntitlement )
			}
		}
		else
		{
			if ( !filteredEntitlements.contains( entitlement ) )
				filteredEntitlements.append( entitlement )
		}
	}

	array<FullRefWithEntitlements> unlocks
	foreach ( key, val in file.entitlementUnlocks )
	{
		foreach ( entitlement in filteredEntitlements )
		{
			if ( val.entitlementIds.contains( entitlement ) )
			{
				//printt( "key:", key, "entitlement:", entitlement )
				FullRefWithEntitlements record
				record.fullRef = key
				record.entitlementIds = val.entitlementIds
				unlocks.append( record )
			}
		}
	}

	// Sort to match original entitlement order as best we can avoiding dupes.
	// We diverge from this order whenever mulitple entitlements are associated with an unlock.
	array<FullRefWithEntitlements> sortedUnlocks
	foreach ( entitlement in filteredEntitlements )
	{
		foreach ( unlock in unlocks )
		{
			if ( unlock.entitlementIds.contains( entitlement ) && !sortedUnlocks.contains( unlock ) )
			{
				//printt( "unlock.fullRef:", unlock.fullRef, "entitlement:", entitlement )
				sortedUnlocks.append( unlock )
			}
		}
	}

	array<string> sortedRefs
	foreach ( unlock in sortedUnlocks )
	{
		string fullRef = unlock.fullRef
		array<string> tokens = split( fullRef, "." )

		if ( tokens.len() == 2 )
			sortedRefs.append( tokens[1] )
		else
			sortedRefs.append( fullRef )
	}

	return sortedRefs
}

ItemDisplayData function WeaponWarpaint_GetByIndex( int skinIndex, string parentRef )
{
	array<SubItemData> subItems = GetAllSubItemsOfType( parentRef, eItemTypes.WEAPON_SKIN )
	foreach ( subItem in subItems )
	{
		if ( subItem.i.skinIndex != skinIndex )
			continue

		return GetSubitemDisplayData( parentRef, subItem.ref )
	}

	unreachable
}