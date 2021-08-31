untyped

global function CodeCallback_RegisterClass_CBaseEntity

//=========================================================
// CBaseEntity
// Properties and methods added here can be accessed on all script entities
//=========================================================

#if DEV
table __scriptVarDelegate = {}
#endif

function CodeCallback_RegisterClass_CBaseEntity()
{
	//printl( "Class Script: CBaseEntity" )

	CBaseEntity.ClassName <- "CBaseEntity"

	// Script variables; initializing these to something other than "null" will cause them to be treated as a
	// static variable on the class instead of a unique variable on each instance.
	CBaseEntity.s <- null

	CBaseEntity.funcsByString <- null

	CBaseEntity.useFunction <- null // should match on server/client

	CBaseEntity._entityVars <- null

	CBaseEntity.invulnerable <- 0

	// this replacement could just be made in the scripts where this call happens,
	// but there's too many for me to replace right now
	CBaseEntity.__KeyValueFromString <- CBaseEntity.SetValueForKey
	CBaseEntity.__KeyValueFromInt <- CBaseEntity.SetValueForKey

	function CBaseEntity::constructor()
	{
		#if DEV
			this.s = delegate __scriptVarDelegate : {}
		#else
			this.s = {}
		#endif

		this.useFunction = UseReturnTrue // default use function

		this.funcsByString = {}
	}

	#if DEV
		function __scriptVarDelegate::_typeof()
		{
			return "ScriptVariableTable"
		}

		disableoverwrite( __scriptVarDelegate )
	#endif

	/*
	Do not delete, thanks.

	CBaseEntity.__SetOrigin <- CBaseEntity.SetOrigin
	function CBaseEntity::SetOrigin( origin )
	{
		if ( this.GetTargetName() == "xauto_1" )
		{
			printl( "\n\n" )
			DumpStack()
		}
		this.__SetOrigin( origin )
	}
	*/

	function CBaseEntity::_typeof()
	{
		return format( "[%d] %s: %s", this.entindex(), this.GetClassName(), this.GetTargetName() )
	}

	function CBaseEntity::Get( val )
	{
		return this.GetValueForKey( val )
	}

	function CBaseEntity::Set( key, val )
	{
		return this.SetValueForKey( key, val )
	}

	// This exists in code too and is only here for untyped entity variables
	function CBaseEntity::WaitSignal( signalID )
	{
		return WaitSignal( this, signalID )
	}

	// This exists in code too and is only here for untyped entity variables
	function CBaseEntity::EndSignal( signalID )
	{
		EndSignal( this, signalID )
	}

	// This exists in code too and is only here for untyped entity variables
	function CBaseEntity::Signal( signalID, results = null )
	{
		Signal( this, signalID, results )
	}

	function CBaseEntity::DisableDraw()
	{
		this.FireNow( "DisableDraw" )
	}
	#document( "CBaseEntity::DisableDraw", "consider this the mega hide" )

	function CBaseEntity::EnableDraw()
	{
		this.FireNow( "EnableDraw" )
	}
	#document( "CBaseEntity::EnableDraw", "its back!" )


	// --------------------------------------------------------
	function CBaseEntity::Kill_Deprecated_UseDestroyInstead( time = 0 )
	{
		EntFireByHandle( this, "kill", "", time, null, null )
	}
	#document( "CBaseEntity::Kill_Deprecated_UseDestroyInstead", "Kill this entity: this function is deprecated because it has a one-frame delay; instead, call ent.Destroy()" )

	// --------------------------------------------------------
	function CBaseEntity::Fire( output, param = "", delay = 0, activator = null, caller = null )
	{
		Assert( type( output ) == "string", "output type " + type( output ) + " is not a string" )
		EntFireByHandle( this, output, string( param ), delay, activator, caller )
	}
	#document( "CBaseEntity::Fire", "Fire an output on this entity, with optional parm and delay" )

	function CBaseEntity::FireNow( output, param = "", activator = null, caller = null )
	{
		Assert( type( output ) == "string" )
		EntFireByHandleNow( this, output, string( param ), activator, caller )
	}
	#document( "CBaseEntity::FireNow", "Fire an output on this entity, with optional parm and delay (synchronous)" )

	// --------------------------------------------------------
	function CBaseEntity::AddOutput( outputName, target, inputName, parameter = "", delay = 0, maxFires = 0 )
	{
		local targetName = target

		if ( type( target ) != "string" )
		{
			Assert( type( target ) == "instance" )
			targetName = target.GetTargetName()
			Assert( targetName.len(), "AddOutput: targetted entity must have a name!" )
		}
		Assert( targetName.len(), "Attemped to AddOutput on an unnamed target" )

		local addOutputString = outputName + " " + targetName + ":" + inputName + ":" + parameter + ":" + delay + ":" + maxFires
		//printl(" Added output string: " + addOutputString )

		EntFireByHandle( this, "AddOutput", addOutputString, 0, null, null )
	}
	#document( "CBaseEntity::AddOutput", "Connects an output on this entity to an input on another entity via code.  The \"target\" can be a name or a named entity." )

	/*
	function MoveTo()
	*/

	function CBaseEntity::MoveTo( dest, time, easeIn = 0, easeOut = 0 )
	{
		if ( this.GetClassName() == "script_mover" )
		{
			this.NonPhysicsMoveTo( dest, time, easeIn, easeOut )
		}
		else
		{
			this.SetOrigin( dest )
			CodeWarning( "Used moveto on non script_mover: " + this.GetClassName() + ", " + this )
		}
	}
	#document( "CBaseEntity::MoveTo", "Move to the specified origin over time with ease in and ease out." )

	/*
	function RotateTo()
	*/

	function CBaseEntity::RotateTo( dest, time, easeIn = 0, easeOut = 0 )
	{
		if ( this.GetClassName() == "script_mover" )
		{
			this.NonPhysicsRotateTo( dest, time, easeIn, easeOut )
		}
		else
		{
			this.SetAngles( dest )
			CodeWarning( "Used rotateto on non script_mover: " + this.GetClassName() + ", " + this )
		}
	}
	#document( "CBaseEntity::RotateTo", "Rotate to the specified angles over time with ease in and ease out." )

	function CBaseEntity::AddVar( varname, value )
	{
		Assert( !( varname in this.s ), "Tried to add variable to " + this + " that already existed: " + varname )

		this.s[ varname ] <- value
	}

	function CBaseEntity::CreateStringForFunction( func )
	{
		// this is a general purpose function that returns a string which, when executed,
		// runs the given function on this entity.
		// the function must be called (or the entity deleted) at some point to avoid leaking the new slot we make in this Table.

		Assert( type( func ) == "function" )

		string newGuid = UniqueString()
		this.funcsByString[newGuid] <- func

		return "_RunFunctionByString( \"" + newGuid + "\" )"
	}

	function _RunFunctionByString( guid )
	{
		local activator = this.activator
		Assert( activator.funcsByString[guid] )

		local func = activator.funcsByString[guid].bindenv( activator.scope() )
		delete activator.funcsByString[guid]

		func()
	}
}
