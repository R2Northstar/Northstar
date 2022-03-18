#include "pch.h"
#include "scriptservertoclientstringcommand.h"
#include "squirrel.h"
#include "convar.h"
#include "concommand.h"

void ConCommand_ns_script_servertoclientstringcommand(const CCommand& arg)
{
	if (g_ClientSquirrelManager->sqvm &&
		g_ClientSquirrelManager->setupfunc("NSClientCodeCallback_RecievedServerToClientStringCommand") != SQRESULT_ERROR)
	{
		g_ClientSquirrelManager->pusharg(arg.ArgS());
		g_ClientSquirrelManager->call(1); // todo: doesn't throw or log errors from within this, probably not great behaviour
	}
}

void InitialiseScriptServerToClientStringCommands(HMODULE baseAddress)
{
	RegisterConCommand(
		"ns_script_servertoclientstringcommand", ConCommand_ns_script_servertoclientstringcommand, "",
		FCVAR_CLIENTDLL | FCVAR_SERVER_CAN_EXECUTE);
}
