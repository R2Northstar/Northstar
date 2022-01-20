global function ClMapHack_Init

void function ClMapHack_Init()
{
	StatusEffect_RegisterEnabledCallback( eStatusEffect.maphack_detected, EntitySonarDetectedEnabled )
	StatusEffect_RegisterDisabledCallback( eStatusEffect.maphack_detected, EntitySonarDetectedDisabled )
}

void function EntitySonarDetectedEnabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( ent == GetLocalViewPlayer() )
	{
		// player is already maphack highlighted
		if ( statusEffect == eStatusEffect.maphack_detected && StatusEffect_Get( ent, eStatusEffect.lockon_detected ) )
			return

		entity viewModelEntity = ent.GetViewModelEntity()
		entity firstPersonProxy = ent.GetFirstPersonProxy()
		entity predictedFirstPersonProxy = ent.GetPredictedFirstPersonProxy()

		vector highlightColor = statusEffect == eStatusEffect.maphack_detected ? HIGHLIGHT_COLOR_ENEMY : <1, 0, 0>

		if ( IsValid( viewModelEntity ) )
			SonarViewModelHighlight( viewModelEntity, highlightColor )

		if ( IsValid( firstPersonProxy ) )
			SonarViewModelHighlight( firstPersonProxy, highlightColor )

		if ( IsValid( predictedFirstPersonProxy ) )
			SonarViewModelHighlight( predictedFirstPersonProxy, highlightColor )

		thread PlayLoopingSonarSound( ent )
	}
	else
	{
		ClInitHighlight( ent )
	}
}

void function EntitySonarDetectedDisabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( ent == GetLocalViewPlayer() )
	{
		// player should have maphack highlighted
		if ( statusEffect == eStatusEffect.maphack_detected && StatusEffect_Get( ent, eStatusEffect.lockon_detected ) )
		{
			return
		}
		else if ( statusEffect == eStatusEffect.lockon_detected && StatusEffect_Get( ent, eStatusEffect.maphack_detected ) )
		{
			// restore sonar after lockon wears off
			EntitySonarDetectedEnabled( ent, eStatusEffect.maphack_detected, true )
			return
		}

		entity viewModelEntity = ent.GetViewModelEntity()
		entity firstPersonProxy = ent.GetFirstPersonProxy()
		entity predictedFirstPersonProxy = ent.GetPredictedFirstPersonProxy()

		if ( IsValid( viewModelEntity ) )
			SonarViewModelClearHighlight( viewModelEntity )

		if ( IsValid( firstPersonProxy ) )
			SonarViewModelClearHighlight( firstPersonProxy )

		if ( IsValid( predictedFirstPersonProxy ) )
			SonarViewModelClearHighlight( predictedFirstPersonProxy )

		ent.Signal( "EntitySonarDetectedDisabled" )
	}
	else
	{
		ClInitHighlight( ent )
	}
}

void function PlayLoopingSonarSound( entity ent )
{
	EmitSoundOnEntity( ent, "HUD_MP_EnemySonarTag_Activated_1P" )

	ent.EndSignal( "EntitySonarDetectedDisabled" )
	ent.EndSignal( "OnDeath" )

	while( true )
	{
		wait 1.5
		EmitSoundOnEntity( ent, "HUD_MP_EnemySonarTag_Flashed_1P" )
	}

}