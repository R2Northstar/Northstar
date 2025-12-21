#include "squirrel/squirrel.h"
#include "masterserver/masterserver.h"
#include "server/auth/serverauthentication.h"
#include "engine/r2engine.h"
#include "client/r2client.h"

// functions for viewing server browser

ADD_SQFUNC("void", NSRequestServerList, "", "", ScriptContext::UI)
{
	NOTE_UNUSED(sqvm);
	g_pMasterServerManager->RequestServerList();
	return SQRESULT_NULL;
}

ADD_SQFUNC("bool", NSIsRequestingServerList, "", "", ScriptContext::UI)
{
	g_pSquirrel[context]->pushbool(sqvm, g_pMasterServerManager->m_bScriptRequestingServerList);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("bool", NSMasterServerConnectionSuccessful, "", "", ScriptContext::UI)
{
	g_pSquirrel[context]->pushbool(sqvm, g_pMasterServerManager->m_bSuccessfullyConnected);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("int", NSGetServerCount, "", "", ScriptContext::UI)
{
	g_pSquirrel[context]->pushinteger(sqvm, (SQInteger)g_pMasterServerManager->m_vRemoteServers.size());
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("void", NSClearRecievedServerList, "", "", ScriptContext::UI)
{
	NOTE_UNUSED(sqvm);
	g_pMasterServerManager->ClearServerList();
	return SQRESULT_NULL;
}

// functions for authenticating with servers

ADD_SQFUNC("void", NSTryAuthWithServer, "int serverIndex, string password = ''", "", ScriptContext::UI)
{
	SQInteger serverIndex = g_pSquirrel[context]->getinteger(sqvm, 1);
	const SQChar* password = g_pSquirrel[context]->getstring(sqvm, 2);

	if (serverIndex >= g_pMasterServerManager->m_vRemoteServers.size())
	{
		g_pSquirrel[context]->raiseerror(
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
		g_pLocalPlayerUserID,
		g_pMasterServerManager->m_sOwnClientAuthToken,
		g_pMasterServerManager->m_vRemoteServers[serverIndex],
		(char*)password);

	return SQRESULT_NULL;
}

ADD_SQFUNC("bool", NSIsAuthenticatingWithServer, "", "", ScriptContext::UI)
{
	g_pSquirrel[context]->pushbool(sqvm, g_pMasterServerManager->m_bScriptAuthenticatingWithGameServer);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("bool", NSWasAuthSuccessful, "", "", ScriptContext::UI)
{
	g_pSquirrel[context]->pushbool(sqvm, g_pMasterServerManager->m_bSuccessfullyAuthenticatedWithGameServer);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("void", NSConnectToAuthedServer, "", "", ScriptContext::UI)
{
	if (!g_pMasterServerManager->m_bHasPendingConnectionInfo)
	{
		g_pSquirrel[context]->raiseerror(
			sqvm, fmt::format("Tried to connect to authed server before any pending connection info was available").c_str());
		return SQRESULT_ERROR;
	}

	RemoteServerConnectionInfo& info = g_pMasterServerManager->m_pendingConnectionInfo;

	// set auth token, then try to connect
	// i'm honestly not entirely sure how silentconnect works regarding ports and encryption so using connect for now
	g_pCVar->FindVar("serverfilter")->SetValue(info.authToken);
	Cbuf_AddText(
		Cbuf_GetCurrentPlayer(),
		fmt::format(
			"connect {}.{}.{}.{}:{}",
			info.ip.S_un.S_un_b.s_b1,
			info.ip.S_un.S_un_b.s_b2,
			info.ip.S_un.S_un_b.s_b3,
			info.ip.S_un.S_un_b.s_b4,
			info.port)
			.c_str(),
		cmd_source_t::kCommandSrcCode);

	g_pMasterServerManager->m_bHasPendingConnectionInfo = false;
	return SQRESULT_NULL;
}

ADD_SQFUNC("void", NSTryAuthWithLocalServer, "", "", ScriptContext::UI)
{
	NOTE_UNUSED(sqvm);
	// do auth request
	g_pMasterServerManager->AuthenticateWithOwnServer(g_pLocalPlayerUserID, g_pMasterServerManager->m_sOwnClientAuthToken);

	return SQRESULT_NULL;
}

ADD_SQFUNC("void", NSCompleteAuthWithLocalServer, "", "", ScriptContext::UI)
{
	NOTE_UNUSED(sqvm);
	// literally just set serverfilter
	// note: this assumes we have no authdata other than our own
	if (g_pServerAuthentication->m_RemoteAuthenticationData.size())
		g_pCVar->FindVar("serverfilter")->SetValue(g_pServerAuthentication->m_RemoteAuthenticationData.begin()->first.c_str());

	return SQRESULT_NULL;
}

ADD_SQFUNC("string", NSGetAuthFailReason, "", "", ScriptContext::UI)
{
	g_pSquirrel[context]->pushstring(sqvm, g_pMasterServerManager->m_sAuthFailureReason.c_str(), -1);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("array<ServerInfo>", NSGetGameServers, "", "", ScriptContext::UI)
{
	g_pSquirrel[context]->newarray(sqvm, 0);
	for (size_t i = 0; i < g_pMasterServerManager->m_vRemoteServers.size(); i++)
	{
		const RemoteServerInfo& remoteServer = g_pMasterServerManager->m_vRemoteServers[i];

		g_pSquirrel[context]->pushnewstructinstance(sqvm, 11);

		// index
		g_pSquirrel[context]->pushinteger(sqvm, (SQInteger)i);
		g_pSquirrel[context]->sealstructslot(sqvm, 0);

		// id
		g_pSquirrel[context]->pushstring(sqvm, remoteServer.id, -1);
		g_pSquirrel[context]->sealstructslot(sqvm, 1);

		// name
		g_pSquirrel[context]->pushstring(sqvm, remoteServer.name, -1);
		g_pSquirrel[context]->sealstructslot(sqvm, 2);

		// description
		g_pSquirrel[context]->pushstring(sqvm, remoteServer.description.c_str(), -1);
		g_pSquirrel[context]->sealstructslot(sqvm, 3);

		// map
		g_pSquirrel[context]->pushstring(sqvm, remoteServer.map, -1);
		g_pSquirrel[context]->sealstructslot(sqvm, 4);

		// playlist
		g_pSquirrel[context]->pushstring(sqvm, remoteServer.playlist, -1);
		g_pSquirrel[context]->sealstructslot(sqvm, 5);

		// playerCount
		g_pSquirrel[context]->pushinteger(sqvm, remoteServer.playerCount);
		g_pSquirrel[context]->sealstructslot(sqvm, 6);

		// maxPlayerCount
		g_pSquirrel[context]->pushinteger(sqvm, remoteServer.maxPlayers);
		g_pSquirrel[context]->sealstructslot(sqvm, 7);

		// requiresPassword
		g_pSquirrel[context]->pushbool(sqvm, remoteServer.requiresPassword);
		g_pSquirrel[context]->sealstructslot(sqvm, 8);

		// region
		g_pSquirrel[context]->pushstring(sqvm, remoteServer.region, -1);
		g_pSquirrel[context]->sealstructslot(sqvm, 9);

		// requiredMods
		g_pSquirrel[context]->newarray(sqvm);
		for (const RemoteModInfo& mod : remoteServer.requiredMods)
		{
			g_pSquirrel[context]->pushnewstructinstance(sqvm, 2);

			// name
			g_pSquirrel[context]->pushstring(sqvm, mod.Name.c_str(), -1);
			g_pSquirrel[context]->sealstructslot(sqvm, 0);

			// version
			g_pSquirrel[context]->pushstring(sqvm, mod.Version.c_str(), -1);
			g_pSquirrel[context]->sealstructslot(sqvm, 1);

			g_pSquirrel[context]->arrayappend(sqvm, -2);
		}
		g_pSquirrel[context]->sealstructslot(sqvm, 10);

		g_pSquirrel[context]->arrayappend(sqvm, -2);
	}
	return SQRESULT_NOTNULL;
}
