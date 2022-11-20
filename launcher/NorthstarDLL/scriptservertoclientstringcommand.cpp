#include "pch.h"
#include "squirrel.h"
#include "convar.h"
#include "concommand.h"

void ConCommand_ns_script_servertoclientstringcommand(const CCommand& arg)
{
	if (g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM)
		g_pSquirrel<ScriptContext::CLIENT>->Call("NSClientCodeCallback_RecievedServerToClientStringCommand", arg.ArgS());
}

ON_DLL_LOAD_CLIENT_RELIESON("client.dll", ScriptServerToClientStringCommand, ClientSquirrel, (CModule module))
{
	RegisterConCommand(
		"ns_script_servertoclientstringcommand",
		ConCommand_ns_script_servertoclientstringcommand,
		"",
		FCVAR_CLIENTDLL | FCVAR_SERVER_CAN_EXECUTE);
}
