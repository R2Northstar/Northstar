untyped

globalize_all_functions

function GiveServerFlag( player, passive )
{
	if ( !( player.serverFlags & passive ) )
	{
		player.serverFlags = player.serverFlags | passive
	}

	// enter/exit functions for specific passives
	switch ( passive )
	{
	}
}

function TakeServerFlag( player, passive )
{
	if ( !PlayerHasServerFlag( player, passive ) )
		return

	player.serverFlags = player.serverFlags & ( ~passive )

	// enter/exit functions for specific passives
	switch ( passive )
	{
	}

}

bool function PlayerHasServerFlag( player, passive )
{
	return bool( player.serverFlags & passive )
}
