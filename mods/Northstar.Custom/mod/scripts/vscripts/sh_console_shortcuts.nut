#if !UI
	global function gwep // GetActiveWeapon
#endif

#if !SERVER
	global function glc // GetLocalClientPlayer
	global function glv // GetLocalViewPlayer
#endif

#if !UI
	entity function gwep( entity ent )
	{
		if ( !IsValid( ent ) )
			return null

		return ent.GetActiveWeapon()
	}
#endif

#if !SERVER
	entity function glc()
	{
		#if UI
			return GetUIPlayer()
		#else
			return GetLocalClientPlayer()
		#endif
	}

	entity function glv()
	{
		#if UI
			return GetUIPlayer()
		#else
			return GetLocalViewPlayer()
		#endif
	}
#endif
