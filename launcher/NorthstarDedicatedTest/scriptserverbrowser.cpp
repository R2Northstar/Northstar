#include "pch.h"
#include "scriptserverbrowser.h"
#include "squirrel.h"
#include "masterserver.h"

// functions for viewing server browser

// void NSRequestServerList()
SQInteger SQ_RequestServerList(void* sqvm)
{
	g_MasterServerManager->RequestServerList();
	return 0;
}

// bool function NSIsRequestingServerList()
SQInteger SQ_IsRequestingServerList(void* sqvm)
{
	ClientSq_pushbool(sqvm, g_MasterServerManager->m_scriptRequestingServerList);
	return 1;
}

// bool function NSMasterServerConnectionSuccessful()
SQInteger SQ_MasterServerConnectionSuccessful(void* sqvm)
{
	ClientSq_pushbool(sqvm, g_MasterServerManager->m_successfullyConnected);
	return 1;
}

// int function NSGetServerCount()
SQInteger SQ_GetServerCount(void* sqvm)
{
	ClientSq_pushinteger(sqvm, g_MasterServerManager->m_remoteServers.size());
	return 1;
}

// string function NSGetServerName( int serverIndex )
SQInteger SQ_GetServerName(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		spdlog::warn("Tried to get name of server index {} when only {} servers are available", serverIndex, g_MasterServerManager->m_remoteServers.size());
		return 0;
	}

	auto iterator = g_MasterServerManager->m_remoteServers.begin();
	std::advance(iterator, serverIndex);

	ClientSq_pushstring(sqvm, iterator->name, -1);
	return 1;
}

// string function NSGetServerMap( int serverIndex )
SQInteger SQ_GetServerMap(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		spdlog::warn("Tried to get map of server index {} when only {} servers are available", serverIndex, g_MasterServerManager->m_remoteServers.size());
		return 0;
	}

	auto iterator = g_MasterServerManager->m_remoteServers.begin();
	std::advance(iterator, serverIndex);

	ClientSq_pushstring(sqvm, iterator->map, -1);
	return 1;
}

// string function NSGetServerPlaylist( int serverIndex )
SQInteger SQ_GetServerPlaylist(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		spdlog::warn("Tried to get playlist of server index {} when only {} servers are available", serverIndex, g_MasterServerManager->m_remoteServers.size());
		return 0;
	}

	auto iterator = g_MasterServerManager->m_remoteServers.begin();
	std::advance(iterator, serverIndex);

	ClientSq_pushstring(sqvm, iterator->playlist, -1);
	return 1;
}

// string function NSGetServerID( int serverIndex )
SQInteger SQ_GetServerID(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		spdlog::warn("Tried to get id of server index {} when only {} servers are available", serverIndex, g_MasterServerManager->m_remoteServers.size());
		return 0;
	}

	auto iterator = g_MasterServerManager->m_remoteServers.begin();
	std::advance(iterator, serverIndex);

	ClientSq_pushstring(sqvm, iterator->id, -1);
	return 1;
}

// void function NSClearRecievedServerList()
SQInteger SQ_ClearRecievedServerList(void* sqvm)
{
	g_MasterServerManager->ClearServerList();
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
	g_UISquirrelManager->AddFuncRegistration("void", "NSRequestServerList", "", "", SQ_RequestServerList);
	g_UISquirrelManager->AddFuncRegistration("bool", "NSIsRequestingServerList", "", "", SQ_IsRequestingServerList);
	g_UISquirrelManager->AddFuncRegistration("bool", "NSMasterServerConnectionSuccessful", "", "", SQ_MasterServerConnectionSuccessful);
	g_UISquirrelManager->AddFuncRegistration("int", "NSGetServerCount", "", "", SQ_GetServerCount);
	g_UISquirrelManager->AddFuncRegistration("void", "NSClearRecievedServerList", "", "", SQ_ClearRecievedServerList);

	g_UISquirrelManager->AddFuncRegistration("string", "NSGetServerName", "int serverIndex", "", SQ_GetServerName);
	g_UISquirrelManager->AddFuncRegistration("string", "NSGetServerMap", "int serverIndex", "", SQ_GetServerMap);
	g_UISquirrelManager->AddFuncRegistration("string", "NSGetServerPlaylist", "int serverIndex", "", SQ_GetServerPlaylist);
	g_UISquirrelManager->AddFuncRegistration("string", "NSGetServerID", "int serverIndex", "", SQ_GetServerID);

	//g_UISquirrelManager->AddFuncRegistration("bool", "NSPollServerPage", "int page", "", SQ_PollServerPage);
	//g_UISquirrelManager->AddFuncRegistration("int", "NSGetNumServersOnPage", "int page", "", SQ_GetNumServersOnPage);
	//g_UISquirrelManager->AddFuncRegistration("string", "NSGetServerName", "int page, int serverIndex", "", SQ_GetServerName);
	//g_UISquirrelManager->AddFuncRegistration("string", "NSGetServerMap", "int page, int serverIndex", "", SQ_GetServerMap);
	//g_UISquirrelManager->AddFuncRegistration("string", "NSGetServerMode", "int page, int serverIndex", "", SQ_GetServerMode);
	//g_UISquirrelManager->AddFuncRegistration("void", "NSResetRecievedServers", "", "", SQ_ResetRecievedServers);
	//
	//g_UISquirrelManager->AddFuncRegistration("string", "NSTryGetAuthedServerToken", "", "", SQ_TryGetAuthedServerToken);
}