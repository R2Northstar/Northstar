#include "pch.h"
#include "squirrel/squirrel.h"
#include "masterserver/masterserver.h"
#include "server/auth/serverauthentication.h"
#include "engine/r2engine.h"
#include "client/r2client.h"

// functions for viewing server browser

ADD_SQFUNC("bool", NSIsMasterServerAuthenticated, "", "", ScriptContext::UI)
{
	g_pSquirrel<context>->pushbool(sqvm, g_pMasterServerManager->m_bOriginAuthWithMasterServerDone);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("void", NSRequestServerList, "", "", ScriptContext::UI)
{
	g_pMasterServerManager->RequestServerList();
	return SQRESULT_NULL;
}

ADD_SQFUNC("bool", NSIsRequestingServerList, "", "", ScriptContext::UI)
{
	g_pSquirrel<context>->pushbool(sqvm, g_pMasterServerManager->m_bScriptRequestingServerList);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("bool", NSMasterServerConnectionSuccessful, "", "", ScriptContext::UI)
{
	g_pSquirrel<context>->pushbool(sqvm, g_pMasterServerManager->m_bSuccessfullyConnected);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("int", NSGetServerCount, "", "", ScriptContext::UI)
{
	g_pSquirrel<context>->pushinteger(sqvm, g_pMasterServerManager->m_vRemoteServers.size());
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("string", NSGetServerName, "int serverIndex", "", ScriptContext::UI)
{
	SQInteger serverIndex = g_pSquirrel<context>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get name of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushstring(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].name);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("string", NSGetServerDescription, "int serverIndex", "", ScriptContext::UI)
{
	SQInteger serverIndex = g_pSquirrel<context>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get description of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushstring(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].description.c_str());
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("string", NSGetServerMap, "int serverIndex", "", ScriptContext::UI)
{
	SQInteger serverIndex = g_pSquirrel<context>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get map of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushstring(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].map);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("string", NSGetServerPlaylist, "int serverIndex", "", ScriptContext::UI)
{
	SQInteger serverIndex = g_pSquirrel<context>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get playlist of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushstring(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].playlist);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("int", NSGetServerPlayerCount, "int serverIndex", "", ScriptContext::UI)
{
	SQInteger serverIndex = g_pSquirrel<context>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get playercount of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushinteger(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].playerCount);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("int", NSGetServerMaxPlayerCount, "int serverIndex", "", ScriptContext::UI)
{
	SQInteger serverIndex = g_pSquirrel<context>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get max playercount of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushinteger(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].maxPlayers);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("string", NSGetServerID, "int serverIndex", "", ScriptContext::UI)
{
	SQInteger serverIndex = g_pSquirrel<context>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get id of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushstring(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].id);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("bool", NSServerRequiresPassword, "int serverIndex", "", ScriptContext::UI)
{
	SQInteger serverIndex = g_pSquirrel<context>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get hasPassword of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushbool(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].requiresPassword);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("int", NSGetServerRequiredModsCount, "int serverIndex", "", ScriptContext::UI)
{
	SQInteger serverIndex = g_pSquirrel<context>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get required mods count of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushinteger(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].requiredMods.size());
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("string", NSGetServerRegion, "int serverIndex", "", ScriptContext::UI)
{
	SQInteger serverIndex = g_pSquirrel<context>->getinteger(sqvm, 1);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get region of server index {} when only {} servers are available",
				serverIndex,
				g_pMasterServerManager->m_vRemoteServers.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushstring(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].region, -1);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("string", NSGetServerRequiredModName, "int serverIndex, int modIndex", "", ScriptContext::UI)
{
	SQInteger serverIndex = g_pSquirrel<context>->getinteger(sqvm, 1);
	SQInteger modIndex = g_pSquirrel<context>->getinteger(sqvm, 2);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<context>->raiseerror(
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
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get required mod name of mod index {} when only {} mod are available",
				modIndex,
				g_pMasterServerManager->m_vRemoteServers[serverIndex].requiredMods.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushstring(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].requiredMods[modIndex].Name.c_str());
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("string", NSGetServerRequiredModVersion, "int serverIndex, int modIndex", "", ScriptContext::UI)
{
	SQInteger serverIndex = g_pSquirrel<context>->getinteger(sqvm, 1);
	SQInteger modIndex = g_pSquirrel<context>->getinteger(sqvm, 2);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<context>->raiseerror(
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
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"Tried to get required mod version of mod index {} when only {} mod are available",
				modIndex,
				g_pMasterServerManager->m_vRemoteServers[serverIndex].requiredMods.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushstring(sqvm, g_pMasterServerManager->m_vRemoteServers[serverIndex].requiredMods[modIndex].Version.c_str());
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("void", NSClearRecievedServerList, "", "", ScriptContext::UI)
{
	g_pMasterServerManager->ClearServerList();
	return SQRESULT_NULL;
}

// functions for authenticating with servers

ADD_SQFUNC("void", NSTryAuthWithServer, "int serverIndex, string password = ''", "", ScriptContext::UI)
{
	SQInteger serverIndex = g_pSquirrel<context>->getinteger(sqvm, 1);
	const SQChar* password = g_pSquirrel<context>->getstring(sqvm, 2);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel<context>->raiseerror(
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

ADD_SQFUNC("bool", NSIsAuthenticatingWithServer, "", "", ScriptContext::UI)
{
	g_pSquirrel<context>->pushbool(sqvm, g_pMasterServerManager->m_bScriptAuthenticatingWithGameServer);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("bool", NSWasAuthSuccessful, "", "", ScriptContext::UI)
{
	g_pSquirrel<context>->pushbool(sqvm, g_pMasterServerManager->m_bSuccessfullyAuthenticatedWithGameServer);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("void", NSConnectToAuthedServer, "", "", ScriptContext::UI)
{
	if (!g_pMasterServerManager->m_bHasPendingConnectionInfo)
	{
		g_pSquirrel<context>->raiseerror(
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

ADD_SQFUNC("void", NSTryAuthWithLocalServer, "", "", ScriptContext::UI)
{
	// do auth request
	g_pMasterServerManager->AuthenticateWithOwnServer(R2::g_pLocalPlayerUserID, g_pMasterServerManager->m_sOwnClientAuthToken);

	return SQRESULT_NULL;
}

ADD_SQFUNC("void", NSCompleteAuthWithLocalServer, "", "", ScriptContext::UI)
{
	// literally just set serverfilter
	// note: this assumes we have no authdata other than our own
	if (g_pServerAuthentication->m_RemoteAuthenticationData.size())
		R2::g_pCVar->FindVar("serverfilter")->SetValue(g_pServerAuthentication->m_RemoteAuthenticationData.begin()->first.c_str());

	return SQRESULT_NULL;
}

ADD_SQFUNC("string", NSGetAuthFailReason, "", "", ScriptContext::UI)
{
	g_pSquirrel<context>->pushstring(sqvm, g_pMasterServerManager->m_sAuthFailureReason.c_str(), -1);
	return SQRESULT_NOTNULL;
}
