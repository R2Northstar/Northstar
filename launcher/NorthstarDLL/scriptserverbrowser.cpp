#include "pch.h"
#include "squirrel.h"
#include "masterserver.h"
#include "serverauthentication.h"
#include "r2engine.h"
#include "r2client.h"

// functions for viewing server browser

// bool function NSIsMasterServerAuthenticated()
SQRESULT SQ_IsMasterServerAuthenticated(HSquirrelVM* sqvm)
{
	g_pSquirrel<ScriptContext::UI>->pushbool(sqvm, g_pMasterServerManager->m_bOriginAuthWithMasterServerDone);
	return SQRESULT_NOTNULL;
}

// void function NSRequestServerList()
SQRESULT SQ_RequestServerList(HSquirrelVM* sqvm)
{
	g_pMasterServerManager->RequestServerList();
	return SQRESULT_NULL;
}

// bool function NSIsRequestingServerList()
SQRESULT SQ_IsRequestingServerList(HSquirrelVM* sqvm)
{
	g_pSquirrel<ScriptContext::UI>->pushbool(sqvm, g_pMasterServerManager->m_bScriptRequestingServerList);
	return SQRESULT_NOTNULL;
}

// bool function NSMasterServerConnectionSuccessful()
SQRESULT SQ_MasterServerConnectionSuccessful(HSquirrelVM* sqvm)
{
	g_pSquirrel<ScriptContext::UI>->pushbool(sqvm, g_pMasterServerManager->m_bSuccessfullyConnected);
	return SQRESULT_NOTNULL;
}

// int function NSGetServerCount()
SQRESULT SQ_GetServerCount(HSquirrelVM* sqvm)
{
	g_pSquirrel<ScriptContext::UI>->pushinteger(sqvm, g_pMasterServerManager->m_vRemoteServers.size());
	return SQRESULT_NOTNULL;
}

// string function NSGetServerName( int serverIndex )
SQRESULT SQ_GetServerName(HSquirrelVM* sqvm)
{
	SQInteger serverIndex = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<ScriptContext::UI>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get name of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].name);
	return SQRESULT_NOTNULL;
}

// string function NSGetServerDescription( int serverIndex )
SQRESULT SQ_GetServerDescription(HSquirrelVM* sqvm)
{
	SQInteger serverIndex = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<ScriptContext::UI>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get description of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].description.c_str());
	return SQRESULT_NOTNULL;
}

// string function NSGetServerMap( int serverIndex )
SQRESULT SQ_GetServerMap(HSquirrelVM* sqvm)
{
	SQInteger serverIndex = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<ScriptContext::UI>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get map of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].map);
	return SQRESULT_NOTNULL;
}

// string function NSGetServerPlaylist( int serverIndex )
SQRESULT SQ_GetServerPlaylist(HSquirrelVM* sqvm)
{
	SQInteger serverIndex = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<ScriptContext::UI>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get playlist of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].playlist);
	return SQRESULT_NOTNULL;
}

// int function NSGetServerPlayerCount( int serverIndex )
SQRESULT SQ_GetServerPlayerCount(HSquirrelVM* sqvm)
{
	SQInteger serverIndex = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<ScriptContext::UI>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get playercount of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<ScriptContext::UI>->pushinteger(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].playerCount);
	return SQRESULT_NOTNULL;
}

// int function NSGetServerMaxPlayerCount( int serverIndex )
SQRESULT SQ_GetServerMaxPlayerCount(HSquirrelVM* sqvm)
{
	SQInteger serverIndex = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<ScriptContext::UI>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get max playercount of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<ScriptContext::UI>->pushinteger(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].maxPlayers);
	return SQRESULT_NOTNULL;
}

// string function NSGetServerID( int serverIndex )
SQRESULT SQ_GetServerID(HSquirrelVM* sqvm)
{
	SQInteger serverIndex = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<ScriptContext::UI>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get id of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].id);
	return SQRESULT_NOTNULL;
}

// bool function NSServerRequiresPassword( int serverIndex )
SQRESULT SQ_ServerRequiresPassword(HSquirrelVM* sqvm)
{
	SQInteger serverIndex = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<ScriptContext::UI>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get hasPassword of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<ScriptContext::UI>->pushbool(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].requiresPassword);
	return SQRESULT_NOTNULL;
}

// int function NSGetServerRequiredModsCount( int serverIndex )
SQRESULT SQ_GetServerRequiredModsCount(HSquirrelVM* sqvm)
{
	SQInteger serverIndex = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<ScriptContext::UI>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get required mods count of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<ScriptContext::UI>->pushinteger(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].requiredMods.size());
	return SQRESULT_NOTNULL;
}

// string function NSGetServerRequiredModName( int serverIndex, int modIndex )
SQRESULT SQ_GetServerRequiredModName(HSquirrelVM* sqvm)
{
	SQInteger serverIndex = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 1);
	SQInteger modIndex = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 2);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<ScriptContext::UI>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get hasPassword of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	if (modIndex >= g_pMasterServerManager->m_vRemoteServers[serverIndex].requiredMods.size())
	{
		g_pSquirrel<ScriptContext::UI>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get required mod name of mod index {} when only {} mod are available",
				modIndex,
				g_pMasterServerManager->m_vRemoteServers[serverIndex].requiredMods.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<ScriptContext::UI>->pushstring(
		sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].requiredMods[modIndex].Name.c_str());
	return SQRESULT_NOTNULL;
}

// string function NSGetServerRequiredModVersion( int serverIndex, int modIndex )
SQRESULT SQ_GetServerRequiredModVersion(HSquirrelVM* sqvm)
{
	SQInteger serverIndex = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 1);
	SQInteger modIndex = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 2);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<ScriptContext::UI>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get required mod version of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	if (modIndex >= g_pMasterServerManager->m_vRemoteServers[serverIndex].requiredMods.size())
	{
		g_pSquirrel<ScriptContext::UI>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get required mod version of mod index {} when only {} mod are available",
				modIndex,
				g_pMasterServerManager->m_vRemoteServers[serverIndex].requiredMods.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<ScriptContext::UI>->pushstring(
		sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].requiredMods[modIndex].Version.c_str());
	return SQRESULT_NOTNULL;
}

// void function NSClearRecievedServerList()
SQRESULT SQ_ClearRecievedServerList(HSquirrelVM* sqvm)
{
	g_pMasterServerManager->ClearServerList();
	return SQRESULT_NULL;
}

// functions for authenticating with servers

// void function NSTryAuthWithServer( int serverIndex, string password = "" )
SQRESULT SQ_TryAuthWithServer(HSquirrelVM* sqvm)
{
	SQInteger serverIndex = g_pSquirrel<ScriptContext::UI>->getinteger(sqvm, 1);
	const SQChar* password = g_pSquirrel<ScriptContext::UI>->getstring(sqvm, 2);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<ScriptContext::UI>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to auth with server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	// send off persistent data first, don't worry about server/client stuff, since m_additionalPlayerData should only have entries when
	// we're a local server note: this seems like it could create a race condition, test later
	for (auto& pair : g_pServerAuthentication->m_PlayerAuthenticationData)
		g_pServerAuthentication->WritePersistentData(pair.first);

	// do auth
	g_pMasterServerManager->AuthenticateWithServer(
		R2::g_pLocalPlayerUserID,
		g_pMasterServerManager->m_sOwnClientAuthToken,
		g_pMasterServerManager->m_vRemoteServers[serverIndex].id,
		(char*)password);

	return SQRESULT_NULL;
}

// bool function NSIsAuthenticatingWithServer()
SQRESULT SQ_IsAuthComplete(HSquirrelVM* sqvm)
{
	g_pSquirrel<ScriptContext::UI>->pushbool(sqvm, g_pMasterServerManager->m_bScriptAuthenticatingWithGameServer);
	return SQRESULT_NOTNULL;
}

// bool function NSWasAuthSuccessful()
SQRESULT SQ_WasAuthSuccessful(HSquirrelVM* sqvm)
{
	g_pSquirrel<ScriptContext::UI>->pushbool(sqvm, g_pMasterServerManager->m_bSuccessfullyAuthenticatedWithGameServer);
	return SQRESULT_NOTNULL;
}

// void function NSConnectToAuthedServer()
SQRESULT SQ_ConnectToAuthedServer(HSquirrelVM* sqvm)
{
	if (!g_pMasterServerManager->m_bHasPendingConnectionInfo)
	{
		g_pSquirrel<ScriptContext::UI>->raiseerror(
			sqvm, fmt::format("Tried to connect to authed server before any pending connection info was available").c_str());
		return SQRESULT_ERROR;
	}

	RemoteServerConnectionInfo& info = g_pMasterServerManager->m_pendingConnectionInfo;

	// set auth token, then try to connect
	// i'm honestly not entirely sure how silentconnect works regarding ports and encryption so using connect for now
	R2::g_pCVar->FindVar("serverfilter")->SetValue(info.authToken);
	R2::Cbuf_AddText(
		R2::Cbuf_GetCurrentPlayer(),
		fmt::format(
			"connect {}.{}.{}.{}:{}",
			info.ip.S_un.S_un_b.s_b1,
			info.ip.S_un.S_un_b.s_b2,
			info.ip.S_un.S_un_b.s_b3,
			info.ip.S_un.S_un_b.s_b4,
			info.port)
			.c_str(),
		R2::cmd_source_t::kCommandSrcCode);

	g_pMasterServerManager->m_bHasPendingConnectionInfo = false;
	return SQRESULT_NULL;
}

// void function NSTryAuthWithLocalServer()
SQRESULT SQ_TryAuthWithLocalServer(HSquirrelVM* sqvm)
{
	// do auth request
	g_pMasterServerManager->AuthenticateWithOwnServer(R2::g_pLocalPlayerUserID, g_pMasterServerManager->m_sOwnClientAuthToken);

	return SQRESULT_NULL;
}

// void function NSCompleteAuthWithLocalServer()
SQRESULT SQ_CompleteAuthWithLocalServer(HSquirrelVM* sqvm)
{
	// literally just set serverfilter
	// note: this assumes we have no authdata other than our own
	if (g_pServerAuthentication->m_RemoteAuthenticationData.size())
		R2::g_pCVar->FindVar("serverfilter")->SetValue(g_pServerAuthentication->m_RemoteAuthenticationData.begin()->first.c_str());

	return SQRESULT_NULL;
}

// string function NSGetAuthFailReason()
SQRESULT SQ_GetAuthFailReason(HSquirrelVM* sqvm)
{
	g_pSquirrel<ScriptContext::UI>->pushstring(sqvm, g_pMasterServerManager->m_sAuthFailureReason.c_str(), -1);
	return SQRESULT_NOTNULL;
}

ON_DLL_LOAD_CLIENT_RELIESON("client.dll", ScriptServerBrowser, ClientSquirrel, (CModule module))
{
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("bool", "NSIsMasterServerAuthenticated", "", "", SQ_IsMasterServerAuthenticated);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("void", "NSRequestServerList", "", "", SQ_RequestServerList);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("bool", "NSIsRequestingServerList", "", "", SQ_IsRequestingServerList);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"bool", "NSMasterServerConnectionSuccessful", "", "", SQ_MasterServerConnectionSuccessful);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("int", "NSGetServerCount", "", "", SQ_GetServerCount);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("void", "NSClearRecievedServerList", "", "", SQ_ClearRecievedServerList);

	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("string", "NSGetServerName", "int serverIndex", "", SQ_GetServerName);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("string", "NSGetServerDescription", "int serverIndex", "", SQ_GetServerDescription);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("string", "NSGetServerMap", "int serverIndex", "", SQ_GetServerMap);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("string", "NSGetServerPlaylist", "int serverIndex", "", SQ_GetServerPlaylist);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("int", "NSGetServerPlayerCount", "int serverIndex", "", SQ_GetServerPlayerCount);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"int", "NSGetServerMaxPlayerCount", "int serverIndex", "", SQ_GetServerMaxPlayerCount);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("string", "NSGetServerID", "int serverIndex", "", SQ_GetServerID);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"bool", "NSServerRequiresPassword", "int serverIndex", "", SQ_ServerRequiresPassword);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"int", "NSGetServerRequiredModsCount", "int serverIndex", "", SQ_GetServerRequiredModsCount);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"string", "NSGetServerRequiredModName", "int serverIndex, int modIndex", "", SQ_GetServerRequiredModName);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"string", "NSGetServerRequiredModVersion", "int serverIndex, int modIndex", "", SQ_GetServerRequiredModVersion);

	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(
		"void", "NSTryAuthWithServer", "int serverIndex, string password = \"\"", "", SQ_TryAuthWithServer);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("bool", "NSIsAuthenticatingWithServer", "", "", SQ_IsAuthComplete);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("bool", "NSWasAuthSuccessful", "", "", SQ_WasAuthSuccessful);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("void", "NSConnectToAuthedServer", "", "", SQ_ConnectToAuthedServer);

	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("void", "NSTryAuthWithLocalServer", "", "", SQ_TryAuthWithLocalServer);
	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("void", "NSCompleteAuthWithLocalServer", "", "", SQ_CompleteAuthWithLocalServer);

	g_pSquirrel<ScriptContext::UI>->AddFuncRegistration("string", "NSGetAuthFailReason", "", "", SQ_GetAuthFailReason);
}
