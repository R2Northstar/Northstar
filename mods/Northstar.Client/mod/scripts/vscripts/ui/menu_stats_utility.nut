untyped


global function SetPieChartData
global function SetStatsBarValues
global function SetStatsValueInfo
global function SetStatsLabelValue
global function GetPercent
//global function GetChallengeCompleteData
global function GetItemUnlockCountData
global function GetOverviewWeaponData
global function StatToTimeString
global function HoursToTimeString
global function StatToDistanceString
global function ComparePieChartEntryValues
global function SetStatBoxDisplay
global function SetMedalStatBoxDisplay

void function SetPieChartData( var menu, string panelName, string titleString, PieChartData data )
{
	Assert( data.entries.len() <= 8 )

	// Get nested panel
	var piePanel = GetElem( menu, panelName )

	// Create background
	var background = Hud_GetChild( piePanel, "BarBG" )
	Hud_SetBarProgress( background, 1.0 )
	Hud_SetColor( background, [190, 190, 190, 255] )

	// Calculate total of all values combined
	foreach ( entry in data.entries )
		data.sum += entry.numValue

	// Calculate bar fraction for each value
	foreach ( entry in data.entries )
	{
		if ( data.sum > 0 )
			entry.fracValue = entry.numValue / data.sum
		else
			entry.fracValue = 0.0
	}

	// Set slice sizes and text data
	var titleLabel = Hud_GetChild( piePanel, "Title" )
	Hud_SetText( titleLabel, titleString )
	Hud_SetColor( titleLabel, data.labelColor )

	var noDataLabel = Hud_GetChild( piePanel, "NoData" )

	for ( int index = 0; index < 8; index++ )
	{
		var barColorGuide = Hud_GetChild( piePanel, "BarColorGuide" + index )
		//			Hud_SetColor( barColorGuide, entry.color )
		Hud_Hide( barColorGuide )

		var barColorGuideFrame = Hud_GetChild( piePanel, "BarColorGuideFrame" + index )
		Hud_Hide( barColorGuideFrame )

		var barName = Hud_GetChild( piePanel, "BarName" + index )
		Hud_SetColor( barName, data.labelColor )
		Hud_SetText( barName, "" )

		var bar = Hud_GetChild( piePanel, "Bar" + index )
		//Hud_SetBarProgress( bar, combinedFrac )
		//Hud_SetColor( bar, entry.color )
		Hud_Hide( bar )
	}

	if ( data.entries.len() > 0 )
	{
		Hud_Hide( noDataLabel )

		float combinedFrac = 0.0
		int largestTextWidth = 0

		foreach ( index, entry in data.entries )
		{
			var barColorGuide = Hud_GetChild( piePanel, "BarColorGuide" + index )
			Hud_SetColor( barColorGuide, entry.color )
			Hud_Show( barColorGuide )

			var barColorGuideFrame = Hud_GetChild( piePanel, "BarColorGuideFrame" + index )
			Hud_Show( barColorGuideFrame )

			string percent = GetPercent( entry.fracValue, 1.0, 0, true )
			var barName = Hud_GetChild( piePanel, "BarName" + index )
			Hud_SetColor( barName, data.labelColor )

			if ( data.timeBased )
				Hud_SetText( barName, PieChartHoursToTimeString( entry.numValue, entry.displayName, percent ) )
			else
				Hud_SetText( barName, "#STATS_TEXT_AND_PERCENTAGE", entry.displayName, percent )

			int currentTextWidth = Hud_GetTextWidth( barName )
			if ( currentTextWidth > largestTextWidth )
				largestTextWidth = currentTextWidth

			Hud_Show( barName )

			combinedFrac += entry.fracValue
			var bar = Hud_GetChild( piePanel, "Bar" + index )
			Hud_SetBarProgress( bar, combinedFrac )
			Hud_SetColor( bar, entry.color )
			Hud_Show( bar )
		}

		// Position the list
		int xOffset = int( ( largestTextWidth / -2 ) + ContentScaledX( 18 ) )
		Hud_SetX( Hud_GetChild( piePanel, "BarName0" ), xOffset )
	}
	else
	{
		Hud_Show( noDataLabel )
		for ( int index = 0; index < 8; index++ )
		{
			var barColorGuide = Hud_GetChild( piePanel, "BarColorGuide" + index )
//			Hud_SetColor( barColorGuide, entry.color )
			Hud_Hide( barColorGuide )

			var barColorGuideFrame = Hud_GetChild( piePanel, "BarColorGuideFrame" + index )
			Hud_Hide( barColorGuideFrame )

			var barName = Hud_GetChild( piePanel, "BarName" + index )
			Hud_SetColor( barName, data.labelColor )
			Hud_SetText( barName, "" )

			var bar = Hud_GetChild( piePanel, "Bar" + index )
			//Hud_SetBarProgress( bar, combinedFrac )
			//Hud_SetColor( bar, entry.color )
			Hud_Hide( bar )
		}
	}
}

function SetStatsBarValues( menu, panelName, titleString, startValue, endValue, currentValue )
{
	Assert( endValue > startValue )
	Assert( currentValue >= startValue && currentValue <= endValue )

	// Get nested panel
	var panel = GetElem( menu, panelName )

	// Update titel
	var title = Hud_GetChild( panel, "Title" )
	Hud_SetText( title, titleString )

	// Update progress text
	var progressText = Hud_GetChild( panel, "ProgressText" )
	Hud_SetText( progressText, "#STATS_PROGRESS_BAR_VALUE", currentValue, endValue )

	// Update bar progress
	float frac = GraphCapped( currentValue, startValue, endValue, 0.0, 1.0 )

	var barFill = Hud_GetChild( panel, "BarFill" )
	Hud_SetScaleX( barFill, frac )

	var barFillShadow = Hud_GetChild( panel, "BarFillShadow" )
	Hud_SetScaleX( barFillShadow, frac )
}

void function SetStatsValueInfo( var menu, valueID, labelText, textString )
{
	var elem = GetElem( menu, "Column0Label" + valueID )
	Assert( elem != null )
	Hud_SetText( elem, labelText )

	elem = GetElem( menu, "Column0Value" + valueID )
	Assert( elem != null )
	SetStatsLabelValueOnLabel( elem, textString )
}

void function SetStatsLabelValue( var menu, labelName, textString )
{
	var elem = GetElem( menu, labelName )
	Assert( elem != null)
	SetStatsLabelValueOnLabel( elem, textString )
}

void function SetStatsLabelValueOnLabel( elem, textString )
{
	if ( type( textString ) == "array" )
	{
		if ( textString.len() == 6 )
			Hud_SetText( elem, string( textString[0] ), textString[1], textString[2], textString[3], textString[4], textString[5] )
		if ( textString.len() == 5 )
			Hud_SetText( elem, string( textString[0] ), textString[1], textString[2], textString[3], textString[4] )
		if ( textString.len() == 4 )
			Hud_SetText( elem, string( textString[0] ), textString[1], textString[2], textString[3] )
		if ( textString.len() == 3 )
			Hud_SetText( elem, string( textString[0] ), textString[1], textString[2] )
		if ( textString.len() == 2 )
			Hud_SetText( elem, string( textString[0] ), textString[1] )
		if ( textString.len() == 1 )
			Hud_SetText( elem, string( textString[0] ) )
	}
	else
	{
		Hud_SetText( elem, string( textString ) )
	}
}

string function GetPercent( float val, float total, float defaultPercent, bool doClamp = true )
{
	float percent = defaultPercent
	if ( total > 0 )
	{
		percent = val / total
		percent *= 100
	}

	if ( doClamp )
		percent = clamp( percent, 0, 100 )

	string formattedPercent
	if ( int( percent * 10 ) % 10 == 0 )
		formattedPercent = format( "%.0f", percent )
	else
		formattedPercent = format( "%.1f", percent )

	return formattedPercent
}

//function GetChallengeCompleteData()
//{
//	local Table = {}
//	Table.total <- 0
//	Table.complete <- 0
//
//	UI_GetAllChallengesProgress()
//	var allChallenges = GetLocalChallengeTable()
//
//	foreach( challengeRef, val in allChallenges )
//	{
//		if ( IsDailyChallenge( challengeRef ) )
//			continue
//		local tierCount = GetChallengeTierCount( challengeRef )
//		Table.total += tierCount
//		for ( int i = 0; i < tierCount; i++ )
//		{
//			if ( IsChallengeTierComplete( challengeRef, i ) )
//				Table.complete++
//		}
//	}
//
//	return Table
//}

function GetItemUnlockCountData()
{
	entity player = GetUIPlayer()
	if ( player == null )
		return {}

	local Table = {}
	Table[ "weapons" ] <- {}
	Table[ "weapons" ].total <- 0
	Table[ "weapons" ].unlocked <- 0
	Table[ "attachments" ] <- {}
	Table[ "attachments" ].total <- 0
	Table[ "attachments" ].unlocked <- 0
	Table[ "mods" ] <- {}
	Table[ "mods" ].total <- 0
	Table[ "mods" ].unlocked <- 0
	Table[ "abilities" ] <- {}
	Table[ "abilities" ].total <- 0
	Table[ "abilities" ].unlocked <- 0
	Table[ "gear" ] <- {}
	Table[ "gear" ].total <- 0
	Table[ "gear" ].unlocked <- 0
/*
	local tableMapping = {}

	tableMapping[ eItemTypes.PILOT_PRIMARY ] 			<- "weapons"
	tableMapping[ eItemTypes.PILOT_SECONDARY ] 			<- "weapons"
	tableMapping[ eItemTypes.PILOT_ORDNANCE ] 			<- "weapons"
	tableMapping[ eItemTypes.TITAN_PRIMARY ] 			<- "weapons"
	tableMapping[ eItemTypes.TITAN_ORDNANCE ] 			<- "weapons"
	tableMapping[ eItemTypes.PILOT_PRIMARY_ATTACHMENT ] <- "attachments"
	tableMapping[ eItemTypes.PILOT_PRIMARY_MOD ] 		<- "mods"
	tableMapping[ eItemTypes.PILOT_SECONDARY_MOD ] 		<- "mods"
	tableMapping[ eItemTypes.TITAN_PRIMARY_MOD ] 		<- "mods"
	tableMapping[ eItemTypes.PILOT_SPECIAL_MOD ] 		<- "mods"
	tableMapping[ eItemTypes.TITAN_SPECIAL_MOD ] 		<- "mods"
	tableMapping[ eItemTypes.PILOT_SPECIAL ] 			<- "abilities"
	tableMapping[ eItemTypes.TITAN_SPECIAL ] 			<- "abilities"

	local itemRefs = GetAllItemRefs()
	foreach ( data in itemRefs )
	{
		if ( !( data.Type in tableMapping ) )
			continue
		Table[ tableMapping[ data.Type ] ].total++

		if ( !IsItemLocked( player, expect string( data.childRef ), expect string( data.ref ) ) )
			Table[ tableMapping[ data.Type ] ].unlocked++
	}
*/
	return Table
}

table<string, table> function GetOverviewWeaponData()
{
	table<string, table> Table = {}
	Table[ "most_kills" ] <- {}
	Table[ "most_kills" ].ref <- ""
	Table[ "most_kills" ].printName <- ""
	Table[ "most_kills" ].val <- 0
	Table[ "most_used" ] <- {}
	Table[ "most_used" ].ref <- ""
	Table[ "most_used" ].printName <- ""
	Table[ "most_used" ].val <- 0
	Table[ "highest_kpm" ] <- {}
	Table[ "highest_kpm" ].ref <- ""
	Table[ "highest_kpm" ].printName <- ""
	Table[ "highest_kpm" ].val <- 0

	entity player = GetUIPlayer()
	if ( player == null )
		return Table

	array<ItemDisplayData> allWeapons = []

	allWeapons.extend( GetVisibleItemsOfType( eItemTypes.PILOT_PRIMARY ) )
	allWeapons.extend( GetVisibleItemsOfType( eItemTypes.PILOT_SECONDARY ) )
	//allWeapons.extend( GetVisibleItemsOfType( eItemTypes.PILOT_ORDNANCE ) ) // art looks bad
	allWeapons.extend( GetVisibleItemsOfType( eItemTypes.TITAN_PRIMARY ) )
	allWeapons.extend( GetVisibleItemsOfType( eItemTypes.TITAN_ORDNANCE ) )
	allWeapons.extend( GetVisibleItemsOfType( eItemTypes.TITAN_ANTIRODEO ) )
	allWeapons.extend( GetVisibleItemsOfType( eItemTypes.TITAN_SPECIAL ) )
	//allWeapons.extend( GetVisibleItemsOfType( eItemTypes.BURN_METER_REWARD ) ) // script errors

	foreach ( weapon in allWeapons )
	{
		string weaponName = weapon.ref
		string weaponDisplayName = expect string( GetWeaponInfoFileKeyField_Global( weaponName, "printname" ) )

		if ( !PersistenceEnumValueIsValid( "loadoutWeaponsAndAbilities", weaponName ) )
			continue

		int val = GetPlayerStatInt( player, "weapon_kill_stats", "total", weaponName )
		if ( val > Table[ "most_kills" ].val )
		{
			Table[ "most_kills" ].ref = weaponName
			Table[ "most_kills" ].printName = weaponDisplayName
			Table[ "most_kills" ].val = val
		}

		float fVal = GetPlayerStatFloat( player, "weapon_stats", "hoursUsed", weaponName )
		if ( fVal > Table[ "most_used" ].val )
		{
			Table[ "most_used" ].ref = weaponName
			Table[ "most_used" ].printName = weaponDisplayName
			Table[ "most_used" ].val = fVal
		}

		local killsPerMinute = 0
		local hoursEquipped = GetPlayerStatFloat( player, "weapon_stats", "hoursEquipped", weaponName )
		local killCount = GetPlayerStatInt( player, "weapon_kill_stats", "total", weaponName )
		if ( hoursEquipped > 0 )
			killsPerMinute = format( "%.2f", ( killCount / ( hoursEquipped * 60.0 ) ).tofloat() )
		if ( killsPerMinute.tofloat() > Table[ "highest_kpm" ].val.tofloat() )
		{
			Table[ "highest_kpm" ].ref = weaponName
			Table[ "highest_kpm" ].printName = weaponDisplayName
			Table[ "highest_kpm" ].val = killsPerMinute
		}
	}

	return Table
}

string function StatToTimeString( string category, string alias, string weapon = "" )
{
	entity player = GetUIPlayer()
	if ( player == null )
		return "0"

	string statString = GetStatVar( category, alias, weapon )
	float savedHours = expect float( player.GetPersistentVar( statString ) )

	return HoursToTimeString( savedHours )
}

string function HoursToTimeString( float savedHours )
{
	string timeString
	local minutes = floor( savedHours * 60.0 )

	if ( minutes < 0 )
		minutes = 0

	int days = 0
	int hours = 0
	
	// For archiving code, i would like to keep this code here
	// It is a testament to Respawn's hubris and determination to writing the absolutely worst fucking code ever
	// These motherfuckers managed to run an O(1) operation in O(n) time. Genuinely impressive. 
	//	while ( minutes >= 1440 )
	//	{
	//		minutes -= 1440
	//		days++
	//	}
	//
	//	while ( minutes >= 60 )
	//	{
	//		minutes -= 60
	//		hours++
	//	}

	days = int(floor(minutes / 1440))
	minutes = minutes % 1440

	hours = int(floor(minutes / 60))
	minutes = minutes % 60

	if ( days > 0 && hours > 0 && minutes > 0 )
	{
		timeString = Localize( "#STATS_TIME_STRING_D_H_M", days, hours, minutes )
	}
	else if ( days > 0 && hours == 0 && minutes == 0 )
	{
		timeString = Localize( "#STATS_TIME_STRING_D", days )
	}
	else if ( days == 0 && hours > 0 && minutes == 0 )
	{
		timeString = Localize( "#STATS_TIME_STRING_H", hours )
	}
	else if ( days == 0 && hours == 0 && minutes >= 0 )
	{
		timeString = Localize( "#STATS_TIME_STRING_M", minutes )
	}
	else if ( days > 0 && hours > 0 && minutes == 0 )
	{
		timeString = Localize( "#STATS_TIME_STRING_D_H", days, hours )
	}
	else if ( days == 0 && hours > 0 && minutes > 0 )
	{
		timeString = Localize( "#STATS_TIME_STRING_H_M", hours, minutes )
	}
	else if ( days > 0 && hours == 0 && minutes > 0 )
	{
		timeString = Localize( "#STATS_TIME_STRING_D_M", days, minutes )
	}
	else
	{
		Assert( 0, "Unhandled time string creation case" )
	}

	return timeString
}

string function PieChartHoursToTimeString( float savedHours, string pieChartHeader, string pieChartPercent )
{
	string timeString
	local minutes = floor( savedHours * 60.0 )

	if ( minutes < 0 )
		minutes = 0

	int days = 0
	int hours = 0

	while ( minutes >= 1440 )
	{
		minutes -= 1440
		days++
	}

	while ( minutes >= 60 )
	{
		minutes -= 60
		hours++
	}

	if ( days > 0 && hours > 0 && minutes > 0 )
	{
		timeString = Localize( "#STATS_TIME_STRING_D_H_M_PIECHART", days, hours, minutes, Localize( pieChartHeader ), pieChartPercent )
	}
	else if ( days > 0 && hours == 0 && minutes == 0 )
	{
		timeString = Localize( "#STATS_TIME_STRING_D_PIECHART", days, Localize( pieChartHeader ), pieChartPercent )
	}
	else if ( days == 0 && hours > 0 && minutes == 0 )
	{
		timeString = Localize( "#STATS_TIME_STRING_H_PIECHART", hours, Localize( pieChartHeader ), pieChartPercent )
	}
	else if ( days == 0 && hours == 0 && minutes >= 0 )
	{
		timeString = Localize( "#STATS_TIME_STRING_M_PIECHART", minutes, Localize( pieChartHeader ), pieChartPercent )
	}
	else if ( days > 0 && hours > 0 && minutes == 0 )
	{
		timeString = Localize( "#STATS_TIME_STRING_D_H_PIECHART", days, hours, Localize( pieChartHeader ), pieChartPercent )
	}
	else if ( days == 0 && hours > 0 && minutes > 0 )
	{
		timeString = Localize( "#STATS_TIME_STRING_H_M_PIECHART", hours, minutes, Localize( pieChartHeader ), pieChartPercent )
	}
	else if ( days > 0 && hours == 0 && minutes > 0 )
	{
		timeString = Localize( "#STATS_TIME_STRING_D_M_PIECHART", days, minutes, Localize( pieChartHeader ), pieChartPercent )
	}
	else
	{
		Assert( 0, "Unhandled time string creation case" )
	}

	return timeString
}

string function StatToDistanceString( string category, string alias, string weapon = "" )
{
	entity player = GetUIPlayer()
	if ( player == null )
		return ""

	string statString = GetStatVar( category, alias, weapon )
	float kilometers = expect float( player.GetPersistentVar( statString ) )

	string formattedNum
	if ( kilometers % 1 == 0 )
		formattedNum = format( "%.0f", kilometers )
	else
		formattedNum = format( "%.2f", kilometers )

	string distString = Localize( "#STATS_KILOMETERS_ABBREVIATION", formattedNum )

	return distString
}

int function ComparePieChartEntryValues( PieChartEntry a, PieChartEntry b )
{
	float aVal = a.numValue
	float bVal = b.numValue

	if ( aVal < bVal )
		return 1
	else if ( aVal > bVal )
		return -1

	return 0
}

void function SetStatBoxDisplay( var vguiElem, string text, string value )
{
	var rui = Hud_GetRui( vguiElem )

	RuiSetString( rui, "statText", text )
	RuiSetString( rui, "statValue", value )
}

void function SetMedalStatBoxDisplay( var vguiElem, string text, asset image, int value )
{
	var rui = Hud_GetRui( vguiElem )

	RuiSetString( rui, "statText", text )
	RuiSetString( rui, "statValue", string( value ) )
	RuiSetImage( rui, "statImage", image )
}