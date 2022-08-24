#include "pch.h"
#include "scriptutility.h"
#include "squirrel.h"

template <ScriptContext context> SQRESULT SQ_StringToAsset(void* sqvm)
{
	if (context == ScriptContext::SERVER)
	{
		const char* asset = ServerSq_getstring(sqvm, 1);
		ServerSq_pushAsset(sqvm, asset, -1);
	}
	else
	{
		const char* asset = ClientSq_getstring(sqvm, 1);
		ClientSq_pushAsset(sqvm, asset, -1);
	}
	return SQRESULT_NOTNULL;
}

void InitialiseClientSquirrelUtilityFunctions(HMODULE baseAddress)
{
	g_ClientSquirrelManager->AddFuncRegistration("asset", "StringToAsset", "string assetName", "", SQ_StringToAsset<ScriptContext::CLIENT>);
	g_UISquirrelManager->AddFuncRegistration("asset", "StringToAsset", "string assetName", "", SQ_StringToAsset<ScriptContext::UI>);
}

void InitialiseServerSquirrelUtilityFunctions(HMODULE baseAddress)
{
	g_ServerSquirrelManager->AddFuncRegistration("asset", "StringToAsset", "string assetName", "", SQ_StringToAsset<ScriptContext::SERVER>);
}
