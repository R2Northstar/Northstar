untyped

global function CodeCallback_RegisterClass_CTitanSoul

function CodeCallback_RegisterClass_CTitanSoul()
{
	CTitanSoul.ClassName <- "CTitanSoul"

	// all soul-specific vars should be created here
	CTitanSoul.lastAttackInfo <- null
	CTitanSoul.hijackProgress <- null
	CTitanSoul.lastHijackTime <- null
	CTitanSoul.capturable <- null
	CTitanSoul.followOnly <- null
	CTitanSoul.passives <- null
	CTitanSoul.createTime <- null
	CTitanSoul.rodeoRiderTracker <- null
	CTitanSoul.doomedTime <- null
	CTitanSoul.nextRegenTime <- 0.0
	CTitanSoul.nextHealthRegenTime <- 0.0
	CTitanSoul.rodeoReservedSlots <- null

	// the functions below should not change

	function CTitanSoul::constructor()
	{
		CBaseEntity.constructor()

		this.lastAttackInfo = { time = 0 }
		this.passives = arrayofsize( GetNumPassives(), false )
		this.createTime = Time()
		this.doomedTime = null
		this.rodeoRiderTracker = {} // all players that rode this titan, so they cant get multiple score events
		this.capturable = false
		this.followOnly = false
		this.rodeoReservedSlots = arrayofsize( PROTOTYPE_DEFAULT_TITAN_RODEO_SLOTS, null )  //hardcoded 3 slots for now!
	}


	// function SoulDeath()
	function CTitanSoul::SoulDestroy()
	{
		// transfer the soul away from the last owner
		entity titan = expect entity( this.GetTitan() )
		foreach ( func in svGlobal.soulTransferFuncs )
		{
			func( expect entity( this ), null, titan )
		}
	}
}
