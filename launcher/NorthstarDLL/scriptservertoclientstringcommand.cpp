#include "pch.h"
#include "squirrel.h"
#include "convar.h"
#include "concommand.h"

void ConCommand_ns_script_servertoclientstringcommand(const CCommand& arg)
{
	if (g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM &&
		g_pSquirrel<ScriptContext::CLIENT>->setupfunc("NSClientCodeCallback_RecievedServerToClientStringCommand") != SQRESULT_ERROR)
	{
		g_pSquirrel<ScriptContext::CLIENT>->pushstring(g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM->sqvm, arg.ArgS());
		g_pSquirrel<ScriptContext::CLIENT>->call(
			g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM->sqvm,
			1); // todo: doesn't throw or log errors from within this, probably not great behaviour
	}
}

ON_DLL_LOAD_CLIENT_RELIESON("client.dll", ScriptServerToClientStringCommand, ClientSquirrel, (CModule module))
{
	RegisterConCommand(
		"ns_script_servertoclientstringcommand",
		ConCommand_ns_script_servertoclientstringcommand,
		"",
		FCVAR_CLIENTDLL | FCVAR_SERVER_CAN_EXECUTE);
}
