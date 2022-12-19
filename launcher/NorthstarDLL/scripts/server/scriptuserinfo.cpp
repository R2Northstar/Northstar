#include "pch.h"
#include "squirrel/squirrel.h"
#include "engine/r2engine.h"
#include "server/r2server.h"

// clang-format off
ADD_SQFUNC("string", GetUserInfoKVString_Internal, "entity player, string key, string defaultValue = \"\"",
	"Gets the string value of a given player's userinfo convar by name", ScriptContext::SERVER)
// clang-format on
{
	const R2::CBasePlayer* pPlayer = g_pSquirrel<ScriptContext::SERVER>->getentity<R2::CBasePlayer>(sqvm, 1);
	if (!pPlayer)
	{
		g_pSquirrel<ScriptContext::SERVER>->raiseerror(sqvm, "player is null");
		return SQRESULT_ERROR;
	}

	const char* pKey = g_pSquirrel<ScriptContext::SERVER>->getstring(sqvm, 2);
	const char* pDefaultValue = g_pSquirrel<ScriptContext::SERVER>->getstring(sqvm, 3);

	const char* pResult = R2::g_pClientArray[pPlayer->m_nPlayerIndex - 1].m_ConVars->GetString(pKey, pDefaultValue);
	g_pSquirrel<ScriptContext::SERVER>->pushstring(sqvm, pResult);
	return SQRESULT_NOTNULL;
}

// clang-format off
ADD_SQFUNC("asset", GetUserInfoKVAsset_Internal, "entity player, string key, asset defaultValue = $\"\"",
	"Gets the asset value of a given player's userinfo convar by name", ScriptContext::SERVER)
// clang-format on
{
	const R2::CBasePlayer* pPlayer = g_pSquirrel<ScriptContext::SERVER>->getentity<R2::CBasePlayer>(sqvm, 1);
	if (!pPlayer)
	{
		g_pSquirrel<ScriptContext::SERVER>->raiseerror(sqvm, "player is null");
		return SQRESULT_ERROR;
	}

	const char* pKey = g_pSquirrel<ScriptContext::SERVER>->getstring(sqvm, 2);
	const char* pDefaultValue;
	g_pSquirrel<ScriptContext::SERVER>->getasset(sqvm, 3, &pDefaultValue);

	const char* pResult = R2::g_pClientArray[pPlayer->m_nPlayerIndex - 1].m_ConVars->GetString(pKey, pDefaultValue);
	g_pSquirrel<ScriptContext::SERVER>->pushasset(sqvm, pResult);
	return SQRESULT_NOTNULL;
}

// clang-format off
ADD_SQFUNC("int", GetUserInfoKVInt_Internal, "entity player, string key, int defaultValue = 0",
	"Gets the int value of a given player's userinfo convar by name", ScriptContext::SERVER)
// clang-format on
{
	const R2::CBasePlayer* pPlayer = g_pSquirrel<ScriptContext::SERVER>->getentity<R2::CBasePlayer>(sqvm, 1);
	if (!pPlayer)
	{
		g_pSquirrel<ScriptContext::SERVER>->raiseerror(sqvm, "player is null");
		return SQRESULT_ERROR;
	}

	const char* pKey = g_pSquirrel<ScriptContext::SERVER>->getstring(sqvm, 2);
	const int iDefaultValue = g_pSquirrel<ScriptContext::SERVER>->getinteger(sqvm, 3);

	const int iResult = R2::g_pClientArray[pPlayer->m_nPlayerIndex - 1].m_ConVars->GetInt(pKey, iDefaultValue);
	g_pSquirrel<ScriptContext::SERVER>->pushinteger(sqvm, iResult);
	return SQRESULT_NOTNULL;
}

// clang-format off
ADD_SQFUNC("float", GetUserInfoKVFloat_Internal, "entity player, string key, float defaultValue = 0",
	"Gets the float value of a given player's userinfo convar by name", ScriptContext::SERVER)
// clang-format on
{
	const R2::CBasePlayer* pPlayer = g_pSquirrel<ScriptContext::SERVER>->getentity<R2::CBasePlayer>(sqvm, 1);
	if (!pPlayer)
	{
		g_pSquirrel<ScriptContext::SERVER>->raiseerror(sqvm, "player is null");
		return SQRESULT_ERROR;
	}

	const char* pKey = g_pSquirrel<ScriptContext::SERVER>->getstring(sqvm, 2);
	const float flDefaultValue = g_pSquirrel<ScriptContext::SERVER>->getfloat(sqvm, 3);

	const float flResult = R2::g_pClientArray[pPlayer->m_nPlayerIndex - 1].m_ConVars->GetFloat(pKey, flDefaultValue);
	g_pSquirrel<ScriptContext::SERVER>->pushfloat(sqvm, flResult);
	return SQRESULT_NOTNULL;
}

// clang-format off
ADD_SQFUNC("bool", GetUserInfoKVBool_Internal, "entity player, string key, bool defaultValue = false",
	"Gets the bool value of a given player's userinfo convar by name", ScriptContext::SERVER)
// clang-format on
{
	const R2::CBasePlayer* pPlayer = g_pSquirrel<ScriptContext::SERVER>->getentity<R2::CBasePlayer>(sqvm, 1);
	if (!pPlayer)
	{
		g_pSquirrel<ScriptContext::SERVER>->raiseerror(sqvm, "player is null");
		return SQRESULT_ERROR;
	}

	const char* pKey = g_pSquirrel<ScriptContext::SERVER>->getstring(sqvm, 2);
	const bool bDefaultValue = g_pSquirrel<ScriptContext::SERVER>->getbool(sqvm, 3);

	const bool bResult = R2::g_pClientArray[pPlayer->m_nPlayerIndex - 1].m_ConVars->GetInt(pKey, bDefaultValue);
	g_pSquirrel<ScriptContext::SERVER>->pushbool(sqvm, bResult);
	return SQRESULT_NOTNULL;
}
