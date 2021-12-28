#include "pch.h"
#include "masterserver.h"
#include "concommand.h"
#include "gameutils.h"
#include "hookutils.h"
#include "httplib.h"
#include "serverauthentication.h"
#include "gameutils.h"
#include "rapidjson/document.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/writer.h"
#include "rapidjson/error/en.h"
#include "modmanager.h"
#include "misccommands.h"

ConVar* Cvar_ns_masterserver_hostname;
ConVar* Cvar_ns_report_server_to_masterserver;
ConVar* Cvar_ns_report_sp_server_to_masterserver;

ConVar* Cvar_ns_server_name;
ConVar* Cvar_ns_server_desc;
ConVar* Cvar_ns_server_password;

// Source ConVar
ConVar* Cvar_hostname;

MasterServerManager* g_MasterServerManager;

typedef void(*CHostState__State_NewGameType)(CHostState* hostState);
CHostState__State_NewGameType CHostState__State_NewGame;

typedef void(*CHostState__State_ChangeLevelMPType)(CHostState* hostState);
CHostState__State_ChangeLevelMPType CHostState__State_ChangeLevelMP;

typedef void(*CHostState__State_ChangeLevelSPType)(CHostState* hostState);
CHostState__State_ChangeLevelSPType CHostState__State_ChangeLevelSP;

typedef void(*CHostState__State_GameShutdownType)(CHostState* hostState);
CHostState__State_GameShutdownType CHostState__State_GameShutdown;

const char* HttplibErrorToString(httplib::Error error)
{
	switch (error)
	{
	case httplib::Error::Success:
		return "httplib::Error::Success";
	case httplib::Error::Unknown:
		return "httplib::Error::Unknown";
	case httplib::Error::Connection:
		return "httplib::Error::Connection";
	case httplib::Error::BindIPAddress:
		return "httplib::Error::BindIPAddress";
	case httplib::Error::Read:
		return "httplib::Error::Read";
	case httplib::Error::Write:
		return "httplib::Error::Write";
	case httplib::Error::ExceedRedirectCount:
		return "httplib::Error::ExceedRedirectCount";
	case httplib::Error::Canceled:
		return "httplib::Error::Canceled";
	case httplib::Error::SSLConnection:
		return "httplib::Error::SSLConnection";
	case httplib::Error::SSLLoadingCerts:
		return "httplib::Error::SSLLoadingCerts";
	case httplib::Error::SSLServerVerification:
		return "httplib::Error::SSLServerVerification";
	case httplib::Error::UnsupportedMultipartBoundaryChars:
		return "httplib::Error::UnsupportedMultipartBoundaryChars";
	}

	return "";
}

RemoteServerInfo::RemoteServerInfo(const char* newId, const char* newName, const char* newDescription, const char* newMap, const char* newPlaylist, int newPlayerCount, int newMaxPlayers, bool newRequiresPassword)
{
	// passworded servers don't have public ips
	requiresPassword = newRequiresPassword;

	strncpy((char*)id, newId, sizeof(id));
	id[sizeof(id) - 1] = 0;
	strncpy((char*)name, newName, sizeof(name));
	name[sizeof(name) - 1] = 0;

	description = std::string(newDescription);

	strncpy((char*)map, newMap, sizeof(map));
	map[sizeof(map) - 1] = 0;
	strncpy((char*)playlist, newPlaylist, sizeof(playlist));
	playlist[sizeof(playlist) - 1] = 0;

	playerCount = newPlayerCount;
	maxPlayers = newMaxPlayers;
}

void MasterServerManager::LazyCreateHttpClient()
{
	if (m_httpClient)
		return;

	m_httpClient = new httplib::Client(Cvar_ns_masterserver_hostname->m_pszString);
	m_httpClient->set_connection_timeout(25);
	m_httpClient->set_read_timeout(25);
	m_httpClient->set_write_timeout(25);
	m_httpClient->set_tcp_nodelay(true);
}

void MasterServerManager::ClearServerList()
{
	// this doesn't really do anything lol, probably isn't threadsafe
	m_requestingServerList = true;

	m_remoteServers.clear();

	m_requestingServerList = false;
}

bool MasterServerManager::AuthenticateOriginWithMasterServerThread(std::string uidStr, std::string tokenStr)
{
	spdlog::info("Trying to authenticate with northstar masterserver for user {}", uidStr);

	LazyCreateHttpClient();
	if (auto result = m_httpClient->Get(fmt::format("/client/origin_auth?id={}&token={}", uidStr, tokenStr).c_str()))
	{
		m_successfullyConnected = true;

		rapidjson::Document originAuthInfo;
		originAuthInfo.Parse(result->body.c_str());

		if (originAuthInfo.HasParseError())
		{
			spdlog::error("Failed reading origin auth info response: encountered parse error \{}\"", rapidjson::GetParseError_En(originAuthInfo.GetParseError()));
			goto REQUEST_END_CLEANUP;
		}

		if (!originAuthInfo.IsObject() || !originAuthInfo.HasMember("success"))
		{
			spdlog::error("Failed reading origin auth info response: malformed response object {}", result->body);
			goto REQUEST_END_CLEANUP;
		}

		if (originAuthInfo["success"].IsTrue() && originAuthInfo.HasMember("token") && originAuthInfo["token"].IsString())
		{
			strncpy(m_ownClientAuthToken, originAuthInfo["token"].GetString(), sizeof(m_ownClientAuthToken));
			m_ownClientAuthToken[sizeof(m_ownClientAuthToken) - 1] = 0;
			spdlog::info("Northstar origin authentication completed successfully!");
		}
		else
			spdlog::error("Northstar origin authentication failed");
	}
	else
	{
		spdlog::error("Failed performing northstar origin auth: error {}", HttplibErrorToString(result.error()));
		m_successfullyConnected = false;
	}

	// we goto this instead of returning so we always hit this
REQUEST_END_CLEANUP:
	m_bOriginAuthWithMasterServerInProgress = false;
	m_bOriginAuthWithMasterServerDone = true;

	return m_successfullyConnected;
}

void MasterServerManager::AuthenticateOriginWithMasterServer(char* uid, char* originToken)
{
	if (m_bOriginAuthWithMasterServerInProgress)
		return;

	// do this here so it's instantly set
	m_bOriginAuthWithMasterServerInProgress = true;
	std::string uidStr(uid);
	std::string tokenStr(originToken);

	std::thread requestThread([this, uidStr, tokenStr]()
		{
			for (int i = 0; i < 5; i++)
			{
				if (!AuthenticateOriginWithMasterServerThread(uidStr, tokenStr))
					spdlog::info("retrying...");
				else
					return;
			}
		});

	requestThread.detach();
}

bool MasterServerManager::RequestServerListThread()
{
	// make sure we never have 2 threads writing at once
	// i sure do hope this is actually threadsafe
	while (m_requestingServerList)
		Sleep(100);

	m_requestingServerList = true;
	m_scriptRequestingServerList = true;


	spdlog::info("Requesting server list from {}", Cvar_ns_masterserver_hostname->m_pszString);

	LazyCreateHttpClient();
	if (auto result = m_httpClient->Get("/client/servers"))
	{
		m_successfullyConnected = true;

		rapidjson::Document serverInfoJson;
		serverInfoJson.Parse(result->body.c_str());

		if (serverInfoJson.HasParseError())
		{
			spdlog::error("Failed reading masterserver response: encountered parse error \"{}\"", rapidjson::GetParseError_En(serverInfoJson.GetParseError()));
			goto REQUEST_END_CLEANUP;
		}

		if (serverInfoJson.IsObject() && serverInfoJson.HasMember("error"))
		{
			spdlog::error("Failed reading masterserver response: got fastify error response");
			spdlog::error(result->body);
			goto REQUEST_END_CLEANUP;
		}

		if (!serverInfoJson.IsArray())
		{
			spdlog::error("Failed reading masterserver response: root object is not an array");
			goto REQUEST_END_CLEANUP;
		}

		rapidjson::GenericArray<false, rapidjson::Value> serverArray = serverInfoJson.GetArray();

		spdlog::info("Got {} servers", serverArray.Size());

		for (auto& serverObj : serverArray)
		{
			if (!serverObj.IsObject())
			{
				spdlog::error("Failed reading masterserver response: member of server array is not an object");
				goto REQUEST_END_CLEANUP;
			}

			// todo: verify json props are fine before adding to m_remoteServers
			if (!serverObj.HasMember("id") || !serverObj["id"].IsString()
				|| !serverObj.HasMember("name") || !serverObj["name"].IsString()
				|| !serverObj.HasMember("description") || !serverObj["description"].IsString()
				|| !serverObj.HasMember("map") || !serverObj["map"].IsString()
				|| !serverObj.HasMember("playlist") || !serverObj["playlist"].IsString()
				|| !serverObj.HasMember("playerCount") || !serverObj["playerCount"].IsNumber()
				|| !serverObj.HasMember("maxPlayers") || !serverObj["maxPlayers"].IsNumber()
				|| !serverObj.HasMember("hasPassword") || !serverObj["hasPassword"].IsBool()
				|| !serverObj.HasMember("modInfo") || !serverObj["modInfo"].HasMember("Mods") || !serverObj["modInfo"]["Mods"].IsArray())
			{
				spdlog::error("Failed reading masterserver response: malformed server object");
				continue;
			};

			const char* id = serverObj["id"].GetString();

			RemoteServerInfo* newServer = nullptr;

			bool createNewServerInfo = true;
			for (RemoteServerInfo& server : m_remoteServers)
			{
				// if server already exists, update info rather than adding to it
				if (!strncmp((const char*)server.id, id, 32))
				{
					server = RemoteServerInfo(id, serverObj["name"].GetString(), serverObj["description"].GetString(), serverObj["map"].GetString(), serverObj["playlist"].GetString(), serverObj["playerCount"].GetInt(), serverObj["maxPlayers"].GetInt(), serverObj["hasPassword"].IsTrue());
					newServer = &server;
					createNewServerInfo = false;
					break;
				}
			}

			// server didn't exist
			if (createNewServerInfo)
				newServer = &m_remoteServers.emplace_back(id, serverObj["name"].GetString(), serverObj["description"].GetString(), serverObj["map"].GetString(), serverObj["playlist"].GetString(), serverObj["playerCount"].GetInt(), serverObj["maxPlayers"].GetInt(), serverObj["hasPassword"].IsTrue());

			newServer->requiredMods.clear();
			for (auto& requiredMod : serverObj["modInfo"]["Mods"].GetArray())
			{
				RemoteModInfo modInfo;

				if (!requiredMod.HasMember("RequiredOnClient") || !requiredMod["RequiredOnClient"].IsTrue())
					continue;

				if (!requiredMod.HasMember("Name") || !requiredMod["Name"].IsString())
					continue;
				modInfo.Name = requiredMod["Name"].GetString();

				if (!requiredMod.HasMember("Version") || !requiredMod["Version"].IsString())
					continue;
				modInfo.Version = requiredMod["Version"].GetString();

				newServer->requiredMods.push_back(modInfo);
			}

			spdlog::info("Server {} on map {} with playlist {} has {}/{} players", serverObj["name"].GetString(), serverObj["map"].GetString(), serverObj["playlist"].GetString(), serverObj["playerCount"].GetInt(), serverObj["maxPlayers"].GetInt());
		}

		std::sort(m_remoteServers.begin(), m_remoteServers.end(), [](RemoteServerInfo& a, RemoteServerInfo& b) {
			return a.playerCount > b.playerCount;
			});
	}
	else
	{
		spdlog::error("Failed requesting servers: error {}", HttplibErrorToString(result.error()));
		m_successfullyConnected = false;
	}

	// we goto this instead of returning so we always hit this
REQUEST_END_CLEANUP:
	m_requestingServerList = false;
	m_scriptRequestingServerList = false;

	return m_successfullyConnected;
}

void MasterServerManager::RequestServerList()
{
	// do this here so it's instantly set on call for scripts
	m_scriptRequestingServerList = true;

	std::thread requestThread([this]()
		{
			for (int i = 0; i < 3; i++)
			{
				if (!RequestServerListThread())
					spdlog::info("retrying...");
				else
					return;
			}
		});

	requestThread.detach();
}

bool MasterServerManager::RequestMainMenuPromosThread()
{
	while (m_bOriginAuthWithMasterServerInProgress || !m_bOriginAuthWithMasterServerDone)
		Sleep(500);

	LazyCreateHttpClient();
	if (auto result = m_httpClient->Get("/client/mainmenupromos"))
	{
		m_successfullyConnected = true;

		rapidjson::Document mainMenuPromoJson;
		mainMenuPromoJson.Parse(result->body.c_str());

		if (mainMenuPromoJson.HasParseError())
		{
			spdlog::error("Failed reading masterserver main menu promos response: encountered parse error \"{}\"", rapidjson::GetParseError_En(mainMenuPromoJson.GetParseError()));
			goto REQUEST_END_CLEANUP;
		}

		if (!mainMenuPromoJson.IsObject())
		{
			spdlog::error("Failed reading masterserver main menu promos response: root object is not an object");
			goto REQUEST_END_CLEANUP;
		}

		if (mainMenuPromoJson.HasMember("error"))
		{
			spdlog::error("Failed reading masterserver response: got fastify error response");
			spdlog::error(result->body);
			goto REQUEST_END_CLEANUP;
		}

		if (!mainMenuPromoJson.HasMember("newInfo") || !mainMenuPromoJson["newInfo"].IsObject() ||
			!mainMenuPromoJson["newInfo"].HasMember("Title1") || !mainMenuPromoJson["newInfo"]["Title1"].IsString() ||
			!mainMenuPromoJson["newInfo"].HasMember("Title2") || !mainMenuPromoJson["newInfo"]["Title2"].IsString() ||
			!mainMenuPromoJson["newInfo"].HasMember("Title3") || !mainMenuPromoJson["newInfo"]["Title3"].IsString() ||

			!mainMenuPromoJson.HasMember("largeButton") || !mainMenuPromoJson["largeButton"].IsObject() ||
			!mainMenuPromoJson["largeButton"].HasMember("Title") || !mainMenuPromoJson["largeButton"]["Title"].IsString() ||
			!mainMenuPromoJson["largeButton"].HasMember("Text") || !mainMenuPromoJson["largeButton"]["Text"].IsString() ||
			!mainMenuPromoJson["largeButton"].HasMember("Url") || !mainMenuPromoJson["largeButton"]["Url"].IsString() ||
			!mainMenuPromoJson["largeButton"].HasMember("ImageIndex") || !mainMenuPromoJson["largeButton"]["ImageIndex"].IsNumber() ||

			!mainMenuPromoJson.HasMember("smallButton1") || !mainMenuPromoJson["smallButton1"].IsObject() ||
			!mainMenuPromoJson["smallButton1"].HasMember("Title") || !mainMenuPromoJson["smallButton1"]["Title"].IsString() ||
			!mainMenuPromoJson["smallButton1"].HasMember("Url") || !mainMenuPromoJson["smallButton1"]["Url"].IsString() ||
			!mainMenuPromoJson["smallButton1"].HasMember("ImageIndex") || !mainMenuPromoJson["smallButton1"]["ImageIndex"].IsNumber() ||

			!mainMenuPromoJson.HasMember("smallButton2") || !mainMenuPromoJson["smallButton2"].IsObject() ||
			!mainMenuPromoJson["smallButton2"].HasMember("Title") || !mainMenuPromoJson["smallButton2"]["Title"].IsString() ||
			!mainMenuPromoJson["smallButton2"].HasMember("Url") || !mainMenuPromoJson["smallButton2"]["Url"].IsString() ||
			!mainMenuPromoJson["smallButton2"].HasMember("ImageIndex") || !mainMenuPromoJson["smallButton2"]["ImageIndex"].IsNumber())
		{
			spdlog::error("Failed reading masterserver main menu promos response: malformed json object");
			goto REQUEST_END_CLEANUP;
		}

		m_MainMenuPromoData.newInfoTitle1 = mainMenuPromoJson["newInfo"]["Title1"].GetString();
		m_MainMenuPromoData.newInfoTitle2 = mainMenuPromoJson["newInfo"]["Title2"].GetString();
		m_MainMenuPromoData.newInfoTitle3 = mainMenuPromoJson["newInfo"]["Title3"].GetString();

		m_MainMenuPromoData.largeButtonTitle = mainMenuPromoJson["largeButton"]["Title"].GetString();
		m_MainMenuPromoData.largeButtonText = mainMenuPromoJson["largeButton"]["Text"].GetString();
		m_MainMenuPromoData.largeButtonUrl = mainMenuPromoJson["largeButton"]["Url"].GetString();
		m_MainMenuPromoData.largeButtonImageIndex = mainMenuPromoJson["largeButton"]["ImageIndex"].GetInt();

		m_MainMenuPromoData.smallButton1Title = mainMenuPromoJson["smallButton1"]["Title"].GetString();
		m_MainMenuPromoData.smallButton1Url = mainMenuPromoJson["smallButton1"]["Url"].GetString();
		m_MainMenuPromoData.smallButton1ImageIndex = mainMenuPromoJson["smallButton1"]["ImageIndex"].GetInt();

		m_MainMenuPromoData.smallButton2Title = mainMenuPromoJson["smallButton2"]["Title"].GetString();
		m_MainMenuPromoData.smallButton2Url = mainMenuPromoJson["smallButton2"]["Url"].GetString();
		m_MainMenuPromoData.smallButton2ImageIndex = mainMenuPromoJson["smallButton2"]["ImageIndex"].GetInt();

		m_bHasMainMenuPromoData = true;
	}
	else
	{
		spdlog::error("Failed requesting main menu promos: error {}", HttplibErrorToString(result.error()));
		m_successfullyConnected = false;
	}

REQUEST_END_CLEANUP:
	// nothing lol
	return m_successfullyConnected;
}

void MasterServerManager::RequestMainMenuPromos()
{
	m_bHasMainMenuPromoData = false;

	std::thread requestThread([this]()
		{
			for (int i = 0; i < 3; i++)
			{
				if (!RequestMainMenuPromosThread())
					spdlog::info("retrying...");
				else
					return;
			}
		});

	requestThread.detach();
}

bool MasterServerManager::AuthenticateWithOwnServerThread(char* uid, char* playerToken)
{
	LazyCreateHttpClient();
	if (auto result = m_httpClient->Post(fmt::format("/client/auth_with_self?id={}&playerToken={}", uid, playerToken).c_str()))
	{
		m_successfullyConnected = true;

		rapidjson::Document authInfoJson;
		authInfoJson.Parse(result->body.c_str());

		if (authInfoJson.HasParseError())
		{
			spdlog::error("Failed reading masterserver authentication response: encountered parse error \"{}\"", rapidjson::GetParseError_En(authInfoJson.GetParseError()));
			goto REQUEST_END_CLEANUP;
		}

		if (!authInfoJson.IsObject())
		{
			spdlog::error("Failed reading masterserver authentication response: root object is not an object");
			goto REQUEST_END_CLEANUP;
		}

		if (authInfoJson.HasMember("error"))
		{
			spdlog::error("Failed reading masterserver response: got fastify error response");
			spdlog::error(result->body);
			goto REQUEST_END_CLEANUP;
		}

		if (!authInfoJson["success"].IsTrue())
		{
			spdlog::error("Authentication with masterserver failed: \"success\" is not true");
			goto REQUEST_END_CLEANUP;
		}

		if (!authInfoJson.HasMember("success") || !authInfoJson.HasMember("id") || !authInfoJson["id"].IsString() || !authInfoJson.HasMember("authToken") || !authInfoJson["authToken"].IsString() || !authInfoJson.HasMember("persistentData") || !authInfoJson["persistentData"].IsArray())
		{
			spdlog::error("Failed reading masterserver authentication response: malformed json object");
			goto REQUEST_END_CLEANUP;
		}

		AuthData newAuthData;
		strncpy(newAuthData.uid, authInfoJson["id"].GetString(), sizeof(newAuthData.uid));
		newAuthData.uid[sizeof(newAuthData.uid) - 1] = 0;

		newAuthData.pdataSize = authInfoJson["persistentData"].GetArray().Size();
		newAuthData.pdata = new char[newAuthData.pdataSize];
		//memcpy(newAuthData.pdata, authInfoJson["persistentData"].GetString(), newAuthData.pdataSize);

		int i = 0;
		// note: persistentData is a uint8array because i had problems getting strings to behave, it sucks but it's just how it be unfortunately
		// potentially refactor later
		for (auto& byte : authInfoJson["persistentData"].GetArray())
		{
			if (!byte.IsUint() || byte.GetUint() > 255)
			{
				spdlog::error("Failed reading masterserver authentication response: malformed json object");
				goto REQUEST_END_CLEANUP;
			}

			newAuthData.pdata[i++] = (char)byte.GetUint();
		}

		std::lock_guard<std::mutex> guard(g_ServerAuthenticationManager->m_authDataMutex);
		g_ServerAuthenticationManager->m_authData.clear();
		g_ServerAuthenticationManager->m_authData.insert(std::make_pair(authInfoJson["authToken"].GetString(), newAuthData));

		m_successfullyAuthenticatedWithGameServer = true;
	}
	else
	{
		spdlog::error("Failed authenticating with own server: error {}", HttplibErrorToString(result.error()));
		m_successfullyConnected = false;
		m_successfullyAuthenticatedWithGameServer = false;
		m_scriptAuthenticatingWithGameServer = false;
	}

REQUEST_END_CLEANUP:
	m_authenticatingWithGameServer = false;
	m_scriptAuthenticatingWithGameServer = false;

	if (m_bNewgameAfterSelfAuth)
	{
		// pretty sure this is threadsafe?
		Cbuf_AddText(Cbuf_GetCurrentPlayer(), "ns_end_reauth_and_leave_to_lobby", cmd_source_t::kCommandSrcCode);
		m_bNewgameAfterSelfAuth = false;
	}

	return m_successfullyConnected;
}

void MasterServerManager::AuthenticateWithOwnServer(char* uid, char* playerToken)
{
	// dont wait, just stop if we're trying to do 2 auth requests at once
	if (m_authenticatingWithGameServer)
		return;

	m_authenticatingWithGameServer = true;
	m_scriptAuthenticatingWithGameServer = true;
	m_successfullyAuthenticatedWithGameServer = false;
	
	std::thread requestThread([this, uid, playerToken]()
		{
			for (int i = 0; i < 5; i++)
			{
				if (!AuthenticateWithOwnServerThread(uid, playerToken))
					spdlog::info("retrying...");
				else
					return;
			}
		});

	requestThread.detach();
}

bool MasterServerManager::AuthenticateWithServerThread(char* uid, char* playerToken, char* serverId, char* password)
{
	// esnure that any persistence saving is done, so we know masterserver has newest
	while (m_savingPersistentData)
		Sleep(100);

	LazyCreateHttpClient();
	spdlog::info("Attempting authentication with server of id \"{}\"", serverId);

	if (auto result = m_httpClient->Post(fmt::format("/client/auth_with_server?id={}&playerToken={}&server={}&password={}", uid, playerToken, serverId, password).c_str()))
	{
		m_successfullyConnected = true;

		rapidjson::Document connectionInfoJson;
		connectionInfoJson.Parse(result->body.c_str());

		if (connectionInfoJson.HasParseError())
		{
			spdlog::error("Failed reading masterserver authentication response: encountered parse error \"{}\"", rapidjson::GetParseError_En(connectionInfoJson.GetParseError()));
			goto REQUEST_END_CLEANUP;
		}

		if (!connectionInfoJson.IsObject())
		{
			spdlog::error("Failed reading masterserver authentication response: root object is not an object");
			goto REQUEST_END_CLEANUP;
		}

		if (connectionInfoJson.HasMember("error"))
		{
			spdlog::error("Failed reading masterserver response: got fastify error response");
			spdlog::error(result->body);
			goto REQUEST_END_CLEANUP;
		}

		if (!connectionInfoJson["success"].IsTrue())
		{
			spdlog::error("Authentication with masterserver failed: \"success\" is not true");
			goto REQUEST_END_CLEANUP;
		}

		if (!connectionInfoJson.HasMember("success") || !connectionInfoJson.HasMember("ip") || !connectionInfoJson["ip"].IsString() || !connectionInfoJson.HasMember("port") || !connectionInfoJson["port"].IsNumber() || !connectionInfoJson.HasMember("authToken") || !connectionInfoJson["authToken"].IsString())
		{
			spdlog::error("Failed reading masterserver authentication response: malformed json object");
			goto REQUEST_END_CLEANUP;
		}

		m_pendingConnectionInfo.ip.S_un.S_addr = inet_addr(connectionInfoJson["ip"].GetString());
		m_pendingConnectionInfo.port = connectionInfoJson["port"].GetInt();

		strncpy(m_pendingConnectionInfo.authToken, connectionInfoJson["authToken"].GetString(), 31);
		m_pendingConnectionInfo.authToken[31] = 0;

		m_hasPendingConnectionInfo = true;
		m_successfullyAuthenticatedWithGameServer = true;
	}
	else
	{
		spdlog::error("Failed authenticating with server: error {}", HttplibErrorToString(result.error()));
		m_successfullyConnected = false;
		m_successfullyAuthenticatedWithGameServer = false;
		m_scriptAuthenticatingWithGameServer = false;
	}

REQUEST_END_CLEANUP:
	m_authenticatingWithGameServer = false;
	m_scriptAuthenticatingWithGameServer = false;

	return m_successfullyConnected;
}

void MasterServerManager::AuthenticateWithServer(char* uid, char* playerToken, char* serverId, char* password)
{
	// dont wait, just stop if we're trying to do 2 auth requests at once
	if (m_authenticatingWithGameServer)
		return;

	m_authenticatingWithGameServer = true;
	m_scriptAuthenticatingWithGameServer = true;
	m_successfullyAuthenticatedWithGameServer = false;

	std::thread requestThread([this, uid, playerToken, serverId, password]()
		{
			for (int i = 0; i < 5; i++)
			{
				if (!AuthenticateWithServerThread(uid, playerToken, serverId, password))
					spdlog::info("retrying...");
				else
					return;
			}
		});

	requestThread.detach();
}

bool MasterServerManager::AddSelfToServerListThread(int port, int authPort, char* name, char* description, char* map, char* playlist, int maxPlayers, char* password)
{
	m_ownServerId[0] = 0;

	std::string request;
	if (*password)
		request = fmt::format("/server/add_server?port={}&authPort={}&name={}&description={}&map={}&playlist={}&maxPlayers={}&password={}", port, authPort, name, description, map, playlist, maxPlayers, password);
	else
		request = fmt::format("/server/add_server?port={}&authPort={}&name={}&description={}&map={}&playlist={}&maxPlayers={}&password=", port, authPort, name, description, map, playlist, maxPlayers);

	// build modinfo obj
	rapidjson::Document modinfoDoc;
	modinfoDoc.SetObject();
	modinfoDoc.AddMember("Mods", rapidjson::Value(rapidjson::kArrayType), modinfoDoc.GetAllocator());

	int currentModIndex = 0;
	for (Mod& mod : g_ModManager->m_loadedMods)
	{
		if (!mod.Enabled || (!mod.RequiredOnClient && !mod.Pdiff.size()))
			continue;

		modinfoDoc["Mods"].PushBack(rapidjson::Value(rapidjson::kObjectType), modinfoDoc.GetAllocator());
		modinfoDoc["Mods"][currentModIndex].AddMember("Name", rapidjson::StringRef(&mod.Name[0]), modinfoDoc.GetAllocator());
		modinfoDoc["Mods"][currentModIndex].AddMember("Version", rapidjson::StringRef(&mod.Version[0]), modinfoDoc.GetAllocator());
		modinfoDoc["Mods"][currentModIndex].AddMember("RequiredOnClient", mod.RequiredOnClient, modinfoDoc.GetAllocator());
		modinfoDoc["Mods"][currentModIndex].AddMember("Pdiff", rapidjson::StringRef(&mod.Pdiff[0]), modinfoDoc.GetAllocator());

		currentModIndex++;
	}

	rapidjson::StringBuffer buffer;
	buffer.Clear();
	rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
	modinfoDoc.Accept(writer);
	const char* modInfoString = buffer.GetString();

	httplib::MultipartFormDataItems requestItems = {
		{"modinfo", std::string(modInfoString, buffer.GetSize()), "modinfo.json", "application/octet-stream"}
	};

	LazyCreateHttpClient();
	if (auto result = m_httpClient->Post(request.c_str(), requestItems))
	{
		m_successfullyConnected = true;

		rapidjson::Document serverAddedJson;
		serverAddedJson.Parse(result->body.c_str());

		if (serverAddedJson.HasParseError())
		{
			spdlog::error("Failed reading masterserver authentication response: encountered parse error \"{}\"", rapidjson::GetParseError_En(serverAddedJson.GetParseError()));
			goto REQUEST_END_CLEANUP;
		}

		if (!serverAddedJson.IsObject())
		{
			spdlog::error("Failed reading masterserver authentication response: root object is not an object");
			goto REQUEST_END_CLEANUP;
		}

		if (serverAddedJson.HasMember("error"))
		{
			spdlog::error("Failed reading masterserver response: got fastify error response");
			spdlog::error(result->body);
			goto REQUEST_END_CLEANUP;
		}

		if (!serverAddedJson["success"].IsTrue())
		{
			spdlog::error("Adding server to masterserver failed: \"success\" is not true");
			goto REQUEST_END_CLEANUP;
		}

		if (!serverAddedJson.HasMember("id") || !serverAddedJson["id"].IsString())
		{
			spdlog::error("Failed reading masterserver response: malformed json object");
			goto REQUEST_END_CLEANUP;
		}

		strncpy(m_ownServerId, serverAddedJson["id"].GetString(), sizeof(m_ownServerId));
		m_ownServerId[sizeof(m_ownServerId) - 1] = 0;


		// heartbeat thread
		// ideally this should actually be done in main thread, rather than on it's own thread, so it'd stop if server freezes
		std::thread heartbeatThread([this] {
			while (*m_ownServerId)
			{
				Sleep(10000);
				for (int i = 0; i < 3; i++)
				{
					if (!(int)m_httpClient->Post(fmt::format("/server/heartbeat?id={}&playerCount={}", m_ownServerId, g_ServerAuthenticationManager->m_additionalPlayerData.size()).c_str()).error())
						break;
					else
						spdlog::warn("retrying heartbeat...");
				}
			}
			});

		heartbeatThread.detach();
	}
	else
	{
		spdlog::error("Failed adding self to server list: error {}", HttplibErrorToString(result.error()));
		m_successfullyConnected = false;
	}

REQUEST_END_CLEANUP:
	return m_successfullyConnected;
}

void MasterServerManager::AddSelfToServerList(int port, int authPort, char* name, char* description, char* map, char* playlist, int maxPlayers, char* password)
{
	if (!Cvar_ns_report_server_to_masterserver->m_nValue)
		return;

	if (!Cvar_ns_report_sp_server_to_masterserver->m_nValue && !strncmp(map, "sp_", 3))
	{
		m_bRequireClientAuth = false;
		return;
	}

	m_bRequireClientAuth = true;

	std::thread requestThread([this, port, authPort, name, description, map, playlist, maxPlayers, password] 
		{
			for (int i = 0; i < 5; i++)
			{
				if (!AddSelfToServerListThread(port, authPort, name, description, map, playlist, maxPlayers, password))
					spdlog::info("retrying...");
				else
					return;
			}
		});

	requestThread.detach();
}

bool MasterServerManager::UpdateServerMapAndPlaylistThread(char* map, char* playlist, int maxPlayers)
{
	// we dont process this at all atm, maybe do later, but atm not necessary
	LazyCreateHttpClient();
	if (auto result = m_httpClient->Post(fmt::format("/server/update_values?id={}&map={}&playlist={}&maxPlayers={}", m_ownServerId, map, playlist, maxPlayers).c_str()))
	{
		m_successfullyConnected = true;
	}
	else
	{
		m_successfullyConnected = false;
	}

	return m_successfullyConnected;
}

void MasterServerManager::UpdateServerMapAndPlaylist(char* map, char* playlist, int maxPlayers)
{
	// dont call this if we don't have a server id
	if (!*m_ownServerId)
		return;

	std::thread requestThread([this, map, playlist, maxPlayers] 
		{
			for (int i = 0; i < 3; i++)
			{
				if (!UpdateServerMapAndPlaylistThread(map, playlist, maxPlayers))
					spdlog::info("retrying...");
				else
					return;
			}
		});

	requestThread.detach();
}

void MasterServerManager::UpdateServerPlayerCount(int playerCount)
{
	// dont call this if we don't have a server id
	if (!*m_ownServerId)
		return;

	std::thread requestThread([this, playerCount] {

			// we dont process this at all atm, maybe do later, but atm not necessary
			LazyCreateHttpClient();
			if (auto result = m_httpClient->Post(fmt::format("/server/update_values?id={}&playerCount={}", m_ownServerId, playerCount).c_str()))
			{
				m_successfullyConnected = true;
			}
			else
			{
				m_successfullyConnected = false;
			}		
		});

	requestThread.detach();
}

bool MasterServerManager::WritePlayerPersistentDataThread(std::string playerIdTemp, char* pdata, size_t pdataSize)
{
	httplib::MultipartFormDataItems requestItems = {
	{ "pdata", std::string(pdata, pdataSize), "file.pdata", "application/octet-stream"}
	};

	// we dont process this at all atm, maybe do later, but atm not necessary
	LazyCreateHttpClient();
	if (auto result = m_httpClient->Post(fmt::format("/accounts/write_persistence?id={}&serverId={}", playerIdTemp, m_ownServerId).c_str(), requestItems))
	{
		m_successfullyConnected = true;
	}
	else
	{
		m_successfullyConnected = false;
	}

	m_savingPersistentData = false;
	return m_successfullyConnected;
}

void MasterServerManager::WritePlayerPersistentData(char* playerId, char* pdata, size_t pdataSize)
{
	// still call this if we don't have a server id, since lobbies that aren't port forwarded need to be able to call it
	m_savingPersistentData = true;
	if (!pdataSize)
	{
		spdlog::warn("attempted to write pdata of size 0!");
		return;
	}

	std::string playerIdTemp(playerId);
	std::thread requestThread([this, playerIdTemp, pdata, pdataSize] 
		{
			for (int i = 0; i < 5; i++)
			{
				if (!WritePlayerPersistentDataThread(playerIdTemp, pdata, pdataSize))
					spdlog::info("retrying...");
				else
					return;
			}
		});

	requestThread.detach();
}

bool MasterServerManager::RemoveSelfFromServerListThread()
{
	bool removed = true;

	// we dont process this at all atm, maybe do later, but atm not necessary
	LazyCreateHttpClient();
	if (auto result = m_httpClient->Delete(fmt::format("/server/remove_server?id={}", m_ownServerId).c_str()))
	{
		m_successfullyConnected = true;
		m_ownServerId[0] = 0;
	}
	else
	{
		m_successfullyConnected = false;
		removed = false;
	}

	return removed;
}

void MasterServerManager::RemoveSelfFromServerList()
{
	// dont call this if we don't have a server id
	if (!*m_ownServerId || !Cvar_ns_report_server_to_masterserver->m_nValue)
		return;

	std::thread requestThread([this] {
			for (int i = 0; i < 5; i++)
			{
				if (!RemoveSelfFromServerListThread())
					spdlog::info("retrying...");
				else
					return;
			}
		});

	requestThread.detach();
}

void ConCommand_ns_fetchservers(const CCommand& args)
{
	g_MasterServerManager->RequestServerList();
}

void CHostState__State_NewGameHook(CHostState* hostState)
{
	Cbuf_AddText(Cbuf_GetCurrentPlayer(), "exec autoexec_ns_server", cmd_source_t::kCommandSrcCode);
	Cbuf_Execute();

	// need to do this to ensure we don't go to private match
	if (g_ServerAuthenticationManager->m_bNeedLocalAuthForNewgame)
		SetCurrentPlaylist("tdm");

	CHostState__State_NewGame(hostState);

	int maxPlayers = 6;
	char* maxPlayersVar = GetCurrentPlaylistVar("max_players", false);
	if (maxPlayersVar) // GetCurrentPlaylistVar can return null so protect against this
		maxPlayers = std::stoi(maxPlayersVar);

	// Copy new server name cvar to source
	Cvar_hostname->m_pszString = Cvar_ns_server_name->m_pszString;
	Cvar_hostname->m_StringLength = Cvar_ns_server_name->m_StringLength;

	g_MasterServerManager->AddSelfToServerList(Cvar_hostport->m_nValue, Cvar_ns_player_auth_port->m_nValue, Cvar_ns_server_name->m_pszString, Cvar_ns_server_desc->m_pszString, hostState->m_levelName, (char*)GetCurrentPlaylistName(), maxPlayers, Cvar_ns_server_password->m_pszString);
	g_ServerAuthenticationManager->StartPlayerAuthServer();
	g_ServerAuthenticationManager->m_bNeedLocalAuthForNewgame = false;
}

void CHostState__State_ChangeLevelMPHook(CHostState* hostState)
{
	int maxPlayers = 6;
	char* maxPlayersVar = GetCurrentPlaylistVar("max_players", false);
	if (maxPlayersVar) // GetCurrentPlaylistVar can return null so protect against this
		maxPlayers = std::stoi(maxPlayersVar);

	g_MasterServerManager->UpdateServerMapAndPlaylist(hostState->m_levelName, (char*)GetCurrentPlaylistName(), maxPlayers);
	CHostState__State_ChangeLevelMP(hostState);
}

void CHostState__State_ChangeLevelSPHook(CHostState* hostState)
{
	int maxPlayers = 6;
	char* maxPlayersVar = GetCurrentPlaylistVar("max_players", false);
	if (maxPlayersVar) // GetCurrentPlaylistVar can return null so protect against this
		maxPlayers = std::stoi(maxPlayersVar);

	g_MasterServerManager->UpdateServerMapAndPlaylist(hostState->m_levelName, (char*)GetCurrentPlaylistName(), maxPlayers);
	CHostState__State_ChangeLevelSP(hostState);
}

void CHostState__State_GameShutdownHook(CHostState* hostState)
{
	g_MasterServerManager->RemoveSelfFromServerList();
	g_ServerAuthenticationManager->StopPlayerAuthServer();

	CHostState__State_GameShutdown(hostState);
}

void InitialiseSharedMasterServer(HMODULE baseAddress)
{
	Cvar_ns_masterserver_hostname = RegisterConVar("ns_masterserver_hostname", "127.0.0.1", FCVAR_NONE, "");
	// unfortunately lib doesn't let us specify a port and still have https work
	//Cvar_ns_masterserver_port = RegisterConVar("ns_masterserver_port", "8080", FCVAR_NONE, "");

	Cvar_ns_server_name = RegisterConVar("ns_server_name", "Unnamed Northstar Server", FCVAR_GAMEDLL, "");
	Cvar_ns_server_desc = RegisterConVar("ns_server_desc", "Default server description", FCVAR_GAMEDLL, "");
	Cvar_ns_server_password = RegisterConVar("ns_server_password", "", FCVAR_GAMEDLL, "");
	Cvar_ns_report_server_to_masterserver = RegisterConVar("ns_report_server_to_masterserver", "1", FCVAR_GAMEDLL, "");
	Cvar_ns_report_sp_server_to_masterserver = RegisterConVar("ns_report_sp_server_to_masterserver", "0", FCVAR_GAMEDLL, "");

	Cvar_hostname = *(ConVar**)((char*)baseAddress + 0x1315bae8);

	g_MasterServerManager = new MasterServerManager;

	RegisterConCommand("ns_fetchservers", ConCommand_ns_fetchservers, "", FCVAR_CLIENTDLL);

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x16E7D0, CHostState__State_NewGameHook, reinterpret_cast<LPVOID*>(&CHostState__State_NewGame));
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x16E5D0, CHostState__State_ChangeLevelMPHook, reinterpret_cast<LPVOID*>(&CHostState__State_ChangeLevelMP));
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x16E520, CHostState__State_ChangeLevelSPHook, reinterpret_cast<LPVOID*>(&CHostState__State_ChangeLevelSP));
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x16E640, CHostState__State_GameShutdownHook, reinterpret_cast<LPVOID*>(&CHostState__State_GameShutdown));
}
