#include "pch.h"
#include "scriptserverbrowser.h"
#include "squirrel.h"
#include "masterserver.h"
#include "gameutils.h"
#include "serverauthentication.h"
#include "dedicated.h"

// functions for viewing server browser

// bool function NSIsMasterServerAuthenticated()
SQRESULT SQ_IsMasterServerAuthenticated(void* sqvm)
{
	ClientSq_pushbool(sqvm, g_MasterServerManager->m_bOriginAuthWithMasterServerDone);
	return SQRESULT_NOTNULL;
}

// void function NSRequestServerList()
SQRESULT SQ_RequestServerList(void* sqvm)
{
	g_MasterServerManager->RequestServerList();
	return SQRESULT_NULL;
}

// bool function NSIsRequestingServerList()
SQRESULT SQ_IsRequestingServerList(void* sqvm)
{
	ClientSq_pushbool(sqvm, g_MasterServerManager->m_scriptRequestingServerList);
	return SQRESULT_NOTNULL;
}

// bool function NSMasterServerConnectionSuccessful()
SQRESULT SQ_MasterServerConnectionSuccessful(void* sqvm)
{
	ClientSq_pushbool(sqvm, g_MasterServerManager->m_successfullyConnected);
	return SQRESULT_NOTNULL;
}

// int function NSGetServerCount()
SQRESULT SQ_GetServerCount(void* sqvm)
{
	ClientSq_pushinteger(sqvm, g_MasterServerManager->m_remoteServers.size());
	return SQRESULT_NOTNULL;
}

// string function NSGetServerName( int serverIndex )
SQRESULT SQ_GetServerName(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		ClientSq_pusherror(
			sqvm, fmt::format(
					  "Tried to get name of server index {} when only {} servers are available", serverIndex,
					  g_MasterServerManager->m_remoteServers.size())
					  .c_str());
		return SQRESULT_ERROR;
	}

	ClientSq_pushstring(sqvm, g_MasterServerManager->m_remoteServers[serverIndex].name, -1);
	return SQRESULT_NOTNULL;
}

// string function NSGetServerDescription( int serverIndex )
SQRESULT SQ_GetServerDescription(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		ClientSq_pusherror(
			sqvm, fmt::format(
					  "Tried to get description of server index {} when only {} servers are available", serverIndex,
					  g_MasterServerManager->m_remoteServers.size())
					  .c_str());
		return SQRESULT_ERROR;
	}

	ClientSq_pushstring(sqvm, g_MasterServerManager->m_remoteServers[serverIndex].description.c_str(), -1);
	return SQRESULT_NOTNULL;
}

// string function NSGetServerMap( int serverIndex )
SQInteger SQ_GetServerMap(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		ClientSq_pusherror(
			sqvm, fmt::format(
					  "Tried to get map of server index {} when only {} servers are available", serverIndex,
					  g_MasterServerManager->m_remoteServers.size())
					  .c_str());
		return SQRESULT_ERROR;
	}

	ClientSq_pushstring(sqvm, g_MasterServerManager->m_remoteServers[serverIndex].map, -1);
	return SQRESULT_NOTNULL;
}

// string function NSGetServerPlaylist( int serverIndex )
SQRESULT SQ_GetServerPlaylist(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		ClientSq_pusherror(
			sqvm, fmt::format(
					  "Tried to get playlist of server index {} when only {} servers are available", serverIndex,
					  g_MasterServerManager->m_remoteServers.size())
					  .c_str());
		return SQRESULT_ERROR;
	}

	ClientSq_pushstring(sqvm, g_MasterServerManager->m_remoteServers[serverIndex].playlist, -1);
	return SQRESULT_NOTNULL;
}

// int function NSGetServerPlayerCount( int serverIndex )
SQRESULT SQ_GetServerPlayerCount(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		ClientSq_pusherror(
			sqvm, fmt::format(
					  "Tried to get playercount of server index {} when only {} servers are available", serverIndex,
					  g_MasterServerManager->m_remoteServers.size())
					  .c_str());
		return SQRESULT_ERROR;
	}

	ClientSq_pushinteger(sqvm, g_MasterServerManager->m_remoteServers[serverIndex].playerCount);
	return SQRESULT_NOTNULL;
}

// int function NSGetServerMaxPlayerCount( int serverIndex )
SQRESULT SQ_GetServerMaxPlayerCount(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		ClientSq_pusherror(
			sqvm, fmt::format(
					  "Tried to get max playercount of server index {} when only {} servers are available", serverIndex,
					  g_MasterServerManager->m_remoteServers.size())
					  .c_str());
		return SQRESULT_ERROR;
	}

	ClientSq_pushinteger(sqvm, g_MasterServerManager->m_remoteServers[serverIndex].maxPlayers);
	return SQRESULT_NOTNULL;
}

// string function NSGetServerID( int serverIndex )
SQRESULT SQ_GetServerID(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		ClientSq_pusherror(
			sqvm, fmt::format(
					  "Tried to get id of server index {} when only {} servers are available", serverIndex,
					  g_MasterServerManager->m_remoteServers.size())
					  .c_str());
		return SQRESULT_ERROR;
	}

	ClientSq_pushstring(sqvm, g_MasterServerManager->m_remoteServers[serverIndex].id, -1);
	return SQRESULT_NOTNULL;
}

// bool function NSServerRequiresPassword( int serverIndex )
SQRESULT SQ_ServerRequiresPassword(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		ClientSq_pusherror(
			sqvm, fmt::format(
					  "Tried to get hasPassword of server index {} when only {} servers are available", serverIndex,
					  g_MasterServerManager->m_remoteServers.size())
					  .c_str());
		return SQRESULT_ERROR;
	}

	ClientSq_pushbool(sqvm, g_MasterServerManager->m_remoteServers[serverIndex].requiresPassword);
	return SQRESULT_NOTNULL;
}

// int function NSGetServerRequiredModsCount( int serverIndex )
SQRESULT SQ_GetServerRequiredModsCount(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		ClientSq_pusherror(
			sqvm, fmt::format(
					  "Tried to get required mods count of server index {} when only {} servers are available", serverIndex,
					  g_MasterServerManager->m_remoteServers.size())
					  .c_str());
		return SQRESULT_ERROR;
	}

	ClientSq_pushinteger(sqvm, g_MasterServerManager->m_remoteServers[serverIndex].requiredMods.size());
	return SQRESULT_NOTNULL;
}

// string function NSGetServerRequiredModName( int serverIndex, int modIndex )
SQRESULT SQ_GetServerRequiredModName(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);
	SQInteger modIndex = ClientSq_getinteger(sqvm, 2);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		ClientSq_pusherror(
			sqvm, fmt::format(
					  "Tried to get hasPassword of server index {} when only {} servers are available", serverIndex,
					  g_MasterServerManager->m_remoteServers.size())
					  .c_str());
		return SQRESULT_ERROR;
	}

	if (modIndex >= g_MasterServerManager->m_remoteServers[serverIndex].requiredMods.size())
	{
		ClientSq_pusherror(
			sqvm, fmt::format(
					  "Tried to get required mod name of mod index {} when only {} mod are available", modIndex,
					  g_MasterServerManager->m_remoteServers[serverIndex].requiredMods.size())
					  .c_str());
		return SQRESULT_ERROR;
	}

	ClientSq_pushstring(sqvm, g_MasterServerManager->m_remoteServers[serverIndex].requiredMods[modIndex].Name.c_str(), -1);
	return SQRESULT_NOTNULL;
}

// string function NSGetServerRequiredModVersion( int serverIndex, int modIndex )
SQRESULT SQ_GetServerRequiredModVersion(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);
	SQInteger modIndex = ClientSq_getinteger(sqvm, 2);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		ClientSq_pusherror(
			sqvm, fmt::format(
					  "Tried to get required mod version of server index {} when only {} servers are available", serverIndex,
					  g_MasterServerManager->m_remoteServers.size())
					  .c_str());
		return SQRESULT_ERROR;
	}

	if (modIndex >= g_MasterServerManager->m_remoteServers[serverIndex].requiredMods.size())
	{
		ClientSq_pusherror(
			sqvm, fmt::format(
					  "Tried to get required mod version of mod index {} when only {} mod are available", modIndex,
					  g_MasterServerManager->m_remoteServers[serverIndex].requiredMods.size())
					  .c_str());
		return SQRESULT_ERROR;
	}

	ClientSq_pushstring(sqvm, g_MasterServerManager->m_remoteServers[serverIndex].requiredMods[modIndex].Version.c_str(), -1);
	return SQRESULT_NOTNULL;
}

// void function NSClearRecievedServerList()
SQRESULT SQ_ClearRecievedServerList(void* sqvm)
{
	g_MasterServerManager->ClearServerList();
	return SQRESULT_NULL;
}

// functions for authenticating with servers

// void function NSTryAuthWithServer( int serverIndex, string password = "" )
SQRESULT SQ_TryAuthWithServer(void* sqvm)
{
	SQInteger serverIndex = ClientSq_getinteger(sqvm, 1);
	const SQChar* password = ClientSq_getstring(sqvm, 2);

	if (serverIndex >= g_MasterServerManager->m_remoteServers.size())
	{
		ClientSq_pusherror(
			sqvm, fmt::format(
					  "Tried to auth with server index {} when only {} servers are available", serverIndex,
					  g_MasterServerManager->m_remoteServers.size())
					  .c_str());
		return SQRESULT_ERROR;
	}

	// send off persistent data first, don't worry about server/client stuff, since m_additionalPlayerData should only have entries when
	// we're a local server note: this seems like it could create a race condition, test later
	for (auto& pair : g_ServerAuthenticationManager->m_additionalPlayerData)
		g_ServerAuthenticationManager->WritePersistentData(pair.first);

	// do auth
	g_MasterServerManager->AuthenticateWithServer(
		g_LocalPlayerUserID, g_MasterServerManager->m_ownClientAuthToken, g_MasterServerManager->m_remoteServers[serverIndex].id,
		(char*)password);

	return SQRESULT_NULL;
}

// bool function NSIsAuthenticatingWithServer()
SQRESULT SQ_IsAuthComplete(void* sqvm)
{
	ClientSq_pushbool(sqvm, g_MasterServerManager->m_scriptAuthenticatingWithGameServer);
	return SQRESULT_NOTNULL;
}

// bool function NSWasAuthSuccessful()
SQRESULT SQ_WasAuthSuccessful(void* sqvm)
{
	ClientSq_pushbool(sqvm, g_MasterServerManager->m_successfullyAuthenticatedWithGameServer);
	return SQRESULT_NOTNULL;
}

// void function NSConnectToAuthedServer()
SQRESULT SQ_ConnectToAuthedServer(void* sqvm)
{
	if (!g_MasterServerManager->m_hasPendingConnectionInfo)
	{
		ClientSq_pusherror(sqvm, fmt::format("Tried to connect to authed server before any pending connection info was available").c_str());
		return SQRESULT_ERROR;
	}

	RemoteServerConnectionInfo info = g_MasterServerManager->m_pendingConnectionInfo;

	// set auth token, then try to connect
	// i'm honestly not entirely sure how silentconnect works regarding ports and encryption so using connect for now
	Cbuf_AddText(Cbuf_GetCurrentPlayer(), fmt::format("serverfilter {}", info.authToken).c_str(), cmd_source_t::kCommandSrcCode);
	Cbuf_AddText(
		Cbuf_GetCurrentPlayer(),
		fmt::format(
			"connect {}.{}.{}.{}:{}", info.ip.S_un.S_un_b.s_b1, info.ip.S_un.S_un_b.s_b2, info.ip.S_un.S_un_b.s_b3,
			info.ip.S_un.S_un_b.s_b4, info.port)
			.c_str(),
		cmd_source_t::kCommandSrcCode);

	g_MasterServerManager->m_hasPendingConnectionInfo = false;
	return SQRESULT_NULL;
}

// void function NSTryAuthWithLocalServer()
SQRESULT SQ_TryAuthWithLocalServer(void* sqvm)
{
	// do auth request
	g_MasterServerManager->AuthenticateWithOwnServer(g_LocalPlayerUserID, g_MasterServerManager->m_ownClientAuthToken);

	return SQRESULT_NULL;
}

// void function NSCompleteAuthWithLocalServer()
SQRESULT SQ_CompleteAuthWithLocalServer(void* sqvm)
{
	// literally just set serverfilter
	// note: this assumes we have no authdata other than our own
	Cbuf_AddText(
		Cbuf_GetCurrentPlayer(), fmt::format("serverfilter {}", g_ServerAuthenticationManager->m_authData.begin()->first).c_str(),
		cmd_source_t::kCommandSrcCode);

	return SQRESULT_NULL;
}

void InitialiseScriptServerBrowser(HMODULE baseAddress)
{
	if (IsDedicated())
		return;

	g_UISquirrelManager->AddFuncRegistration("bool", "NSIsMasterServerAuthenticated", "", "", SQ_IsMasterServerAuthenticated);
	g_UISquirrelManager->AddFuncRegistration("void", "NSRequestServerList", "", "", SQ_RequestServerList);
	g_UISquirrelManager->AddFuncRegistration("bool", "NSIsRequestingServerList", "", "", SQ_IsRequestingServerList);
	g_UISquirrelManager->AddFuncRegistration("bool", "NSMasterServerConnectionSuccessful", "", "", SQ_MasterServerConnectionSuccessful);
	g_UISquirrelManager->AddFuncRegistration("int", "NSGetServerCount", "", "", SQ_GetServerCount);
	g_UISquirrelManager->AddFuncRegistration("void", "NSClearRecievedServerList", "", "", SQ_ClearRecievedServerList);

	g_UISquirrelManager->AddFuncRegistration("string", "NSGetServerName", "int serverIndex", "", SQ_GetServerName);
	g_UISquirrelManager->AddFuncRegistration("string", "NSGetServerDescription", "int serverIndex", "", SQ_GetServerDescription);
	g_UISquirrelManager->AddFuncRegistration("string", "NSGetServerMap", "int serverIndex", "", SQ_GetServerMap);
	g_UISquirrelManager->AddFuncRegistration("string", "NSGetServerPlaylist", "int serverIndex", "", SQ_GetServerPlaylist);
	g_UISquirrelManager->AddFuncRegistration("int", "NSGetServerPlayerCount", "int serverIndex", "", SQ_GetServerPlayerCount);
	g_UISquirrelManager->AddFuncRegistration("int", "NSGetServerMaxPlayerCount", "int serverIndex", "", SQ_GetServerMaxPlayerCount);
	g_UISquirrelManager->AddFuncRegistration("string", "NSGetServerID", "int serverIndex", "", SQ_GetServerID);
	g_UISquirrelManager->AddFuncRegistration("bool", "NSServerRequiresPassword", "int serverIndex", "", SQ_ServerRequiresPassword);
	g_UISquirrelManager->AddFuncRegistration("int", "NSGetServerRequiredModsCount", "int serverIndex", "", SQ_GetServerRequiredModsCount);
	g_UISquirrelManager->AddFuncRegistration(
		"string", "NSGetServerRequiredModName", "int serverIndex, int modIndex", "", SQ_GetServerRequiredModName);
	g_UISquirrelManager->AddFuncRegistration(
		"string", "NSGetServerRequiredModVersion", "int serverIndex, int modIndex", "", SQ_GetServerRequiredModVersion);

	g_UISquirrelManager->AddFuncRegistration(
		"void", "NSTryAuthWithServer", "int serverIndex, string password = \"\"", "", SQ_TryAuthWithServer);
	g_UISquirrelManager->AddFuncRegistration("bool", "NSIsAuthenticatingWithServer", "", "", SQ_IsAuthComplete);
	g_UISquirrelManager->AddFuncRegistration("bool", "NSWasAuthSuccessful", "", "", SQ_WasAuthSuccessful);
	g_UISquirrelManager->AddFuncRegistration("void", "NSConnectToAuthedServer", "", "", SQ_ConnectToAuthedServer);

	g_UISquirrelManager->AddFuncRegistration("void", "NSTryAuthWithLocalServer", "", "", SQ_TryAuthWithLocalServer);
	g_UISquirrelManager->AddFuncRegistration("void", "NSCompleteAuthWithLocalServer", "", "", SQ_CompleteAuthWithLocalServer);
}