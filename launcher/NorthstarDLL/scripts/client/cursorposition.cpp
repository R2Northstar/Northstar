#include "pch.h"
#include "squirrel/squirrel.h"
#include "util/wininfo.h"

ADD_SQFUNC("vector ornull", NSGetCursorPosition, "", "", ScriptContext::UI)
{
	RECT rcClient;
	POINT p;
	if (GetCursorPos(&p) && ScreenToClient(*g_gameHWND, &p) && GetClientRect(*g_gameHWND, &rcClient))
	{
		if (GetAncestor(GetForegroundWindow(), GA_ROOTOWNER) != *g_gameHWND)
			return SQRESULT_NULL;

		g_pSquirrel<context>->pushvector(
			sqvm,
			{p.x > 0 ? p.x > rcClient.right ? rcClient.right : (float)p.x : 0,
			 p.y > 0 ? p.y > rcClient.bottom ? rcClient.bottom : (float)p.y : 0,
			 0});
		return SQRESULT_NOTNULL;
	}
	g_pSquirrel<context>->raiseerror(sqvm, "Failed retrieving cursor position of game window");
	return SQRESULT_ERROR;
}
