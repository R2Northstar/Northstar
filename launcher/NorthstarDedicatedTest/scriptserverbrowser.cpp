#include "pch.h"
#include "scriptserverbrowser.h"
#include "squirrel.h"

// functions for viewing server browser

// bool function NSPollServerPage( int page )
SQInteger SQ_PollServerPage(void* sqvm)
{
	SQInteger page = ClientSq_getinteger(sqvm, 1);

	ClientSq_pushbool(sqvm, true);
	return 1;
}

// int function NSGetNumServersOnPage( int page )
SQInteger SQ_GetNumServersOnPage(void* sqvm)
{
	SQInteger page = ClientSq_getinteger(sqvm, 1);

	ClientSq_pushinteger(sqvm, 1);
	return 1;
}

// string function NSGetServerName( int page, int serverIndex )
SQInteger SQ_GetServerName(void* sqvm)
{
	SQInteger page = ClientSq_getinteger(sqvm, 1);
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 2);

	ClientSq_pushstring(sqvm, "cool", -1);
	return 1;
}

// string function NSGetServerMap( int page, int serverIndex )
SQInteger SQ_GetServerMap(void* sqvm)
{
	SQInteger page = ClientSq_getinteger(sqvm, 1);
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 2);

	ClientSq_pushstring(sqvm, "mp_thaw", -1);
	return 1;
}

// string function NSGetServerMode( int page, int serverIndex )
SQInteger SQ_GetServerMode(void* sqvm)
{
	SQInteger page = ClientSq_getinteger(sqvm, 1);
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 2);

	ClientSq_pushstring(sqvm, "ffa", -1);
	return 1;
}

// string function NSGetServerID( int page, int serverIndex )
SQInteger SQ_GetServerID(void* sqvm)
{

	return 0;
}

// void function NSResetRecievedServers()
SQInteger SQ_ResetRecievedServers(void* sqvm)
{
	return 0;
}


// functions for authenticating with servers

// void function NSTryAuthWithServer( string serverId )
SQInteger SQ_TryAuthWithServer(void* sqvm)
{
	return 0;
}

// int function NSWasAuthSuccessful()
SQInteger SQ_WasAuthSuccessful(void* sqvm)
{
	return 0;
}

// string function NSTryGetAuthedServerAddress()
SQInteger SQ_TryGetAuthedServerAddress(void* sqvm)
{
	return 0;
}

// string function NSTryGetAuthedServerToken()
SQInteger SQ_TryGetAuthedServerToken(void* sqvm)
{
	return 0;
}

void InitialiseScriptServerBrowser(HMODULE baseAddress)
{
	g_UISquirrelManager->AddFuncRegistration("bool", "NSPollServerPage", "int page", "", SQ_PollServerPage);
	g_UISquirrelManager->AddFuncRegistration("int", "NSGetNumServersOnPage", "int page", "", SQ_GetNumServersOnPage);
	g_UISquirrelManager->AddFuncRegistration("string", "NSGetServerName", "int page, int serverIndex", "", SQ_GetServerName);
	g_UISquirrelManager->AddFuncRegistration("string", "NSGetServerMap", "int page, int serverIndex", "", SQ_GetServerMap);
	g_UISquirrelManager->AddFuncRegistration("string", "NSGetServerMode", "int page, int serverIndex", "", SQ_GetServerMode);
	g_UISquirrelManager->AddFuncRegistration("void", "NSResetRecievedServers", "", "", SQ_ResetRecievedServers);
}