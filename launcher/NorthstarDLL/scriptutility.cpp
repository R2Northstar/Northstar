#include "pch.h"
#include "squirrel.h"

// asset function StringToAsset( string assetName )
template <ScriptContext context> SQRESULT SQ_StringToAsset(HSquirrelVM* sqvm)
{
	g_pSquirrel<context>->pushasset(sqvm, g_pSquirrel<context>->getstring(sqvm, 1), -1);
	return SQRESULT_NOTNULL;
}

ON_DLL_LOAD_CLIENT_RELIESON("client.dll", ClientSharedScriptUtility, ClientSquirrel, (CModule module))
{
	g_pSquirrel<ScriptContext::CLIENT>->AddFuncRegistration(
		"asset", "StringToAsset", "string assetName", "converts a given string to an asset", SQ_StringToAsset<ScriptContext::CLIENT>);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"asset", "StringToAsset", "string assetName", "converts a given string to an asset", SQ_StringToAsset<ScriptContext::UI>);
}

ON_DLL_LOAD_RELIESON("server.dll", ServerSharedScriptUtility, ServerSquirrel, (CModule module))
{
	g_pSquirrel<ScriptContext::SERVER>->AddFuncRegistration(
		"asset", "StringToAsset", "string assetName", "converts a given string to an asset", SQ_StringToAsset<ScriptContext::SERVER>);
}