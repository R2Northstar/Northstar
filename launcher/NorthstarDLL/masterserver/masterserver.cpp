#include "pch.h"
#include "masterserver/masterserver.h"
#include "core/convar/concommand.h"
#include "playlist.h"
#include "server/auth/serverauthentication.h"
#include "core/tier0.h"
#include "engine/r2engine.h"
#include "mods/modmanager.h"
#include "shared/misccommands.h"
#include "util/version.h"

#include "rapidjson/document.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/writer.h"
#include "rapidjson/error/en.h"

#include <cstring>
#include <regex>

using namespace std::chrono_literals;

MasterServerManager* g_pMasterServerManager;

ConVar* Cvar_ns_masterserver_hostname;
ConVar* Cvar_ns_curl_log_enable;

RemoteServerInfo::RemoteServerInfo(
	const char* newId,
	const char* newName,
	const char* newDescription,
	const char* newMap,
	const char* newPlaylist,
	const char* newRegion,
	int newPlayerCount,
	int newMaxPlayers,
	bool newRequiresPassword)
{
	// passworded servers don't have public ips
	requiresPassword = newRequiresPassword;

	strncpy_s((char*)id, sizeof(id), newId, sizeof(id) - 1);
	strncpy_s((char*)name, sizeof(name), newName, sizeof(name) - 1);

	description = std::string(newDescription);

	strncpy_s((char*)map, sizeof(map), newMap, sizeof(map) - 1);
	strncpy_s((char*)playlist, sizeof(playlist), newPlaylist, sizeof(playlist) - 1);

	strncpy((char*)region, newRegion, sizeof(region));
	region[sizeof(region) - 1] = 0;

	playerCount = newPlayerCount;
	maxPlayers = newMaxPlayers;
}

void SetCommonHttpClientOptions(CURL* curl)
{
	curl_easy_setopt(curl, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
	curl_easy_setopt(curl, CURLOPT_VERBOSE, Cvar_ns_curl_log_enable->GetBool());
	curl_easy_setopt(curl, CURLOPT_USERAGENT, &NSUserAgent);
	// Timeout since the MS has fucky async functions without await, making curl hang due to a successful connection but no response for ~90
	// seconds.
	curl_easy_setopt(curl, CURLOPT_TIMEOUT, 30L);
	// curl_easy_setopt(curl, CURLOPT_STDERR, stdout);
	if (Tier0::CommandLine()->FindParm("-msinsecure")) // TODO: this check doesn't seem to work
	{
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
	}
}

void MasterServerManager::ClearServerList()
{
	// this doesn't really do anything lol, probably isn't threadsafe
	m_bRequestingServerList = true;

	m_vRemoteServers.clear();

	m_bRequestingServerList = false;
}

size_t CurlWriteToStringBufferCallback(char* contents, size_t size, size_t nmemb, void* userp)
{
	((std::string*)userp)->append((char*)contents, size * nmemb);
	return size * nmemb;
}

void MasterServerManager::AuthenticateOriginWithMasterServer(const char* uid, const char* originToken)
{
	if (m_bOriginAuthWithMasterServerInProgress)
		return;

	// do this here so it's instantly set
	m_bOriginAuthWithMasterServerInProgress = true;
	std::string uidStr(uid);
	std::string tokenStr(originToken);

	std::thread requestThread(
		[this, uidStr, tokenStr]()
		{
			spdlog::info("Trying to authenticate with northstar masterserver for user {}", uidStr);

			CURL* curl = curl_easy_init();
			SetCommonHttpClientOptions(curl);
			std::string readBuffer;
			curl_easy_setopt(
				curl,
				CURLOPT_URL,
				fmt::format("{}/client/origin_auth?id={}&token={}", Cvar_ns_masterserver_hostname->GetString(), uidStr, tokenStr).c_str());
			curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "GET");
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

			CURLcode result = curl_easy_perform(curl);

			if (result == CURLcode::CURLE_OK)
			{
				m_bSuccessfullyConnected = true;

				rapidjson_document originAuthInfo;
				originAuthInfo.Parse(readBuffer.c_str());

				if (originAuthInfo.HasParseError())
				{
					spdlog::error(
						"Failed reading origin auth info response: encountered parse error \"{}\"",
						rapidjson::GetParseError_En(originAuthInfo.GetParseError()));
					goto REQUEST_END_CLEANUP;
				}

				if (!originAuthInfo.IsObject() || !originAuthInfo.HasMember("success"))
				{
					spdlog::error("Failed reading origin auth info response: malformed response object {}", readBuffer);
					goto REQUEST_END_CLEANUP;
				}

				if (originAuthInfo["success"].IsTrue() && originAuthInfo.HasMember("token") && originAuthInfo["token"].IsString())
				{
					strncpy_s(
						m_sOwnClientAuthToken,
						sizeof(m_sOwnClientAuthToken),
						originAuthInfo["token"].GetString(),
						sizeof(m_sOwnClientAuthToken) - 1);
					spdlog::info("Northstar origin authentication completed successfully!");
				}
				else
					spdlog::error("Northstar origin authentication failed");
			}
			else
			{
				spdlog::error("Failed performing northstar origin auth: error {}", curl_easy_strerror(result));
				m_bSuccessfullyConnected = false;
			}

			// we goto this instead of returning so we always hit this
		REQUEST_END_CLEANUP:
			m_bOriginAuthWithMasterServerInProgress = false;
			m_bOriginAuthWithMasterServerDone = true;
			curl_easy_cleanup(curl);
		});

	requestThread.detach();
}

void MasterServerManager::RequestServerList()
{
	// do this here so it's instantly set on call for scripts
	m_bScriptRequestingServerList = true;

	std::thread requestThread(
		[this]()
		{
			// make sure we never have 2 threads writing at once
			// i sure do hope this is actually threadsafe
			while (m_bRequestingServerList)
				Sleep(100);

			m_bRequestingServerList = true;
			m_bScriptRequestingServerList = true;

			spdlog::info("Requesting server list from {}", Cvar_ns_masterserver_hostname->GetString());

			CURL* curl = curl_easy_init();
			SetCommonHttpClientOptions(curl);

			std::string readBuffer;
			curl_easy_setopt(curl, CURLOPT_URL, fmt::format("{}/client/servers", Cvar_ns_masterserver_hostname->GetString()).c_str());
			curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "GET");
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

			CURLcode result = curl_easy_perform(curl);

			if (result == CURLcode::CURLE_OK)
			{
				m_bSuccessfullyConnected = true;

				rapidjson_document serverInfoJson;
				serverInfoJson.Parse(readBuffer.c_str());

				if (serverInfoJson.HasParseError())
				{
					spdlog::error(
						"Failed reading masterserver response: encountered parse error \"{}\"",
						rapidjson::GetParseError_En(serverInfoJson.GetParseError()));
					goto REQUEST_END_CLEANUP;
				}

				if (serverInfoJson.IsObject() && serverInfoJson.HasMember("error"))
				{
					spdlog::error("Failed reading masterserver response: got fastify error response");
					spdlog::error(readBuffer);
					goto REQUEST_END_CLEANUP;
				}

				if (!serverInfoJson.IsArray())
				{
					spdlog::error("Failed reading masterserver response: root object is not an array");
					goto REQUEST_END_CLEANUP;
				}

				rapidjson::GenericArray<false, rapidjson_document::GenericValue> serverArray = serverInfoJson.GetArray();

				spdlog::info("Got {} servers", serverArray.Size());

				for (auto& serverObj : serverArray)
				{
					if (!serverObj.IsObject())
					{
						spdlog::error("Failed reading masterserver response: member of server array is not an object");
						goto REQUEST_END_CLEANUP;
					}

					// todo: verify json props are fine before adding to m_remoteServers
					if (!serverObj.HasMember("id") || !serverObj["id"].IsString() || !serverObj.HasMember("name") ||
						!serverObj["name"].IsString() || !serverObj.HasMember("description") || !serverObj["description"].IsString() ||
						!serverObj.HasMember("map") || !serverObj["map"].IsString() || !serverObj.HasMember("playlist") ||
						!serverObj["playlist"].IsString() || !serverObj.HasMember("playerCount") || !serverObj["playerCount"].IsNumber() ||
						!serverObj.HasMember("maxPlayers") || !serverObj["maxPlayers"].IsNumber() || !serverObj.HasMember("hasPassword") ||
						!serverObj["hasPassword"].IsBool() || !serverObj.HasMember("modInfo") || !serverObj["modInfo"].HasMember("Mods") ||
						!serverObj["modInfo"]["Mods"].IsArray())
					{
						spdlog::error("Failed reading masterserver response: malformed server object");
						continue;
					};

					const char* id = serverObj["id"].GetString();

					RemoteServerInfo* newServer = nullptr;

					bool createNewServerInfo = true;
					for (RemoteServerInfo& server : m_vRemoteServers)
					{
						// if server already exists, update info rather than adding to it
						if (!strncmp((const char*)server.id, id, 32))
						{
							server = RemoteServerInfo(
								id,
								serverObj["name"].GetString(),
								serverObj["description"].GetString(),
								serverObj["map"].GetString(),
								serverObj["playlist"].GetString(),
								(serverObj.HasMember("region") && serverObj["region"].IsString()) ? serverObj["region"].GetString() : "",
								serverObj["playerCount"].GetInt(),
								serverObj["maxPlayers"].GetInt(),
								serverObj["hasPassword"].IsTrue());
							newServer = &server;
							createNewServerInfo = false;
							break;
						}
					}

					// server didn't exist
					if (createNewServerInfo)
						newServer = &m_vRemoteServers.emplace_back(
							id,
							serverObj["name"].GetString(),
							serverObj["description"].GetString(),
							serverObj["map"].GetString(),
							serverObj["playlist"].GetString(),
							(serverObj.HasMember("region") && serverObj["region"].IsString()) ? serverObj["region"].GetString() : "",
							serverObj["playerCount"].GetInt(),
							serverObj["maxPlayers"].GetInt(),
							serverObj["hasPassword"].IsTrue());

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
					// Can probably re-enable this later with a -verbose flag, but slows down loading of the server browser quite a bit as
					// is
					// spdlog::info(
					//	"Server {} on map {} with playlist {} has {}/{} players", serverObj["name"].GetString(),
					//	serverObj["map"].GetString(), serverObj["playlist"].GetString(), serverObj["playerCount"].GetInt(),
					//	serverObj["maxPlayers"].GetInt());
				}

				std::sort(
					m_vRemoteServers.begin(),
					m_vRemoteServers.end(),
					[](RemoteServerInfo& a, RemoteServerInfo& b) { return a.playerCount > b.playerCount; });
			}
			else
			{
				spdlog::error("Failed requesting servers: error {}", curl_easy_strerror(result));
				m_bSuccessfullyConnected = false;
			}

			// we goto this instead of returning so we always hit this
		REQUEST_END_CLEANUP:
			m_bRequestingServerList = false;
			m_bScriptRequestingServerList = false;
			curl_easy_cleanup(curl);
		});

	requestThread.detach();
}

void MasterServerManager::RequestMainMenuPromos()
{
	m_bHasMainMenuPromoData = false;

	std::thread requestThread(
		[this]()
		{
			while (m_bOriginAuthWithMasterServerInProgress || !m_bOriginAuthWithMasterServerDone)
				Sleep(500);

			CURL* curl = curl_easy_init();
			SetCommonHttpClientOptions(curl);

			std::string readBuffer;
			curl_easy_setopt(
				curl, CURLOPT_URL, fmt::format("{}/client/mainmenupromos", Cvar_ns_masterserver_hostname->GetString()).c_str());
			curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "GET");
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

			CURLcode result = curl_easy_perform(curl);

			if (result == CURLcode::CURLE_OK)
			{
				m_bSuccessfullyConnected = true;

				rapidjson_document mainMenuPromoJson;
				mainMenuPromoJson.Parse(readBuffer.c_str());

				if (mainMenuPromoJson.HasParseError())
				{
					spdlog::error(
						"Failed reading masterserver main menu promos response: encountered parse error \"{}\"",
						rapidjson::GetParseError_En(mainMenuPromoJson.GetParseError()));
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
					spdlog::error(readBuffer);
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
					!mainMenuPromoJson["largeButton"].HasMember("ImageIndex") ||
					!mainMenuPromoJson["largeButton"]["ImageIndex"].IsNumber() ||

					!mainMenuPromoJson.HasMember("smallButton1") || !mainMenuPromoJson["smallButton1"].IsObject() ||
					!mainMenuPromoJson["smallButton1"].HasMember("Title") || !mainMenuPromoJson["smallButton1"]["Title"].IsString() ||
					!mainMenuPromoJson["smallButton1"].HasMember("Url") || !mainMenuPromoJson["smallButton1"]["Url"].IsString() ||
					!mainMenuPromoJson["smallButton1"].HasMember("ImageIndex") ||
					!mainMenuPromoJson["smallButton1"]["ImageIndex"].IsNumber() ||

					!mainMenuPromoJson.HasMember("smallButton2") || !mainMenuPromoJson["smallButton2"].IsObject() ||
					!mainMenuPromoJson["smallButton2"].HasMember("Title") || !mainMenuPromoJson["smallButton2"]["Title"].IsString() ||
					!mainMenuPromoJson["smallButton2"].HasMember("Url") || !mainMenuPromoJson["smallButton2"]["Url"].IsString() ||
					!mainMenuPromoJson["smallButton2"].HasMember("ImageIndex") ||
					!mainMenuPromoJson["smallButton2"]["ImageIndex"].IsNumber())
				{
					spdlog::error("Failed reading masterserver main menu promos response: malformed json object");
					goto REQUEST_END_CLEANUP;
				}

				m_sMainMenuPromoData.newInfoTitle1 = mainMenuPromoJson["newInfo"]["Title1"].GetString();
				m_sMainMenuPromoData.newInfoTitle2 = mainMenuPromoJson["newInfo"]["Title2"].GetString();
				m_sMainMenuPromoData.newInfoTitle3 = mainMenuPromoJson["newInfo"]["Title3"].GetString();

				m_sMainMenuPromoData.largeButtonTitle = mainMenuPromoJson["largeButton"]["Title"].GetString();
				m_sMainMenuPromoData.largeButtonText = mainMenuPromoJson["largeButton"]["Text"].GetString();
				m_sMainMenuPromoData.largeButtonUrl = mainMenuPromoJson["largeButton"]["Url"].GetString();
				m_sMainMenuPromoData.largeButtonImageIndex = mainMenuPromoJson["largeButton"]["ImageIndex"].GetInt();

				m_sMainMenuPromoData.smallButton1Title = mainMenuPromoJson["smallButton1"]["Title"].GetString();
				m_sMainMenuPromoData.smallButton1Url = mainMenuPromoJson["smallButton1"]["Url"].GetString();
				m_sMainMenuPromoData.smallButton1ImageIndex = mainMenuPromoJson["smallButton1"]["ImageIndex"].GetInt();

				m_sMainMenuPromoData.smallButton2Title = mainMenuPromoJson["smallButton2"]["Title"].GetString();
				m_sMainMenuPromoData.smallButton2Url = mainMenuPromoJson["smallButton2"]["Url"].GetString();
				m_sMainMenuPromoData.smallButton2ImageIndex = mainMenuPromoJson["smallButton2"]["ImageIndex"].GetInt();

				m_bHasMainMenuPromoData = true;
			}
			else
			{
				spdlog::error("Failed requesting main menu promos: error {}", curl_easy_strerror(result));
				m_bSuccessfullyConnected = false;
			}

		REQUEST_END_CLEANUP:
			// nothing lol
			curl_easy_cleanup(curl);
		});

	requestThread.detach();
}

void MasterServerManager::AuthenticateWithOwnServer(const char* uid, const char* playerToken)
{
	// dont wait, just stop if we're trying to do 2 auth requests at once
	if (m_bAuthenticatingWithGameServer)
		return;

	m_bAuthenticatingWithGameServer = true;
	m_bScriptAuthenticatingWithGameServer = true;
	m_bSuccessfullyAuthenticatedWithGameServer = false;

	std::string uidStr(uid);
	std::string tokenStr(playerToken);

	std::thread requestThread(
		[this, uidStr, tokenStr]()
		{
			CURL* curl = curl_easy_init();
			SetCommonHttpClientOptions(curl);

			std::string readBuffer;
			curl_easy_setopt(
				curl,
				CURLOPT_URL,
				fmt::format("{}/client/auth_with_self?id={}&playerToken={}", Cvar_ns_masterserver_hostname->GetString(), uidStr, tokenStr)
					.c_str());
			curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "POST");
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

			CURLcode result = curl_easy_perform(curl);

			if (result == CURLcode::CURLE_OK)
			{
				m_bSuccessfullyConnected = true;

				rapidjson_document authInfoJson;
				authInfoJson.Parse(readBuffer.c_str());

				if (authInfoJson.HasParseError())
				{
					spdlog::error(
						"Failed reading masterserver authentication response: encountered parse error \"{}\"",
						rapidjson::GetParseError_En(authInfoJson.GetParseError()));
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
					spdlog::error(readBuffer);

					if (authInfoJson["error"].HasMember("enum"))
						m_sAuthFailureReason = authInfoJson["error"]["enum"].GetString();
					else
						m_sAuthFailureReason = "No error message provided";

					goto REQUEST_END_CLEANUP;
				}

				if (!authInfoJson["success"].IsTrue())
				{
					spdlog::error("Authentication with masterserver failed: \"success\" is not true");
					goto REQUEST_END_CLEANUP;
				}

				if (!authInfoJson.HasMember("success") || !authInfoJson.HasMember("id") || !authInfoJson["id"].IsString() ||
					!authInfoJson.HasMember("authToken") || !authInfoJson["authToken"].IsString() ||
					!authInfoJson.HasMember("persistentData") || !authInfoJson["persistentData"].IsArray())
				{
					spdlog::error("Failed reading masterserver authentication response: malformed json object");
					goto REQUEST_END_CLEANUP;
				}

				RemoteAuthData newAuthData {};
				strncpy_s(newAuthData.uid, sizeof(newAuthData.uid), authInfoJson["id"].GetString(), sizeof(newAuthData.uid) - 1);

				newAuthData.pdataSize = authInfoJson["persistentData"].GetArray().Size();
				newAuthData.pdata = new char[newAuthData.pdataSize];
				// memcpy(newAuthData.pdata, authInfoJson["persistentData"].GetString(), newAuthData.pdataSize);

				int i = 0;
				// note: persistentData is a uint8array because i had problems getting strings to behave, it sucks but it's just how it be
				// unfortunately potentially refactor later
				for (auto& byte : authInfoJson["persistentData"].GetArray())
				{
					if (!byte.IsUint() || byte.GetUint() > 255)
					{
						spdlog::error("Failed reading masterserver authentication response: malformed json object");
						goto REQUEST_END_CLEANUP;
					}

					newAuthData.pdata[i++] = static_cast<char>(byte.GetUint());
				}

				std::lock_guard<std::mutex> guard(g_pServerAuthentication->m_AuthDataMutex);
				g_pServerAuthentication->m_RemoteAuthenticationData.clear();
				g_pServerAuthentication->m_RemoteAuthenticationData.insert(
					std::make_pair(authInfoJson["authToken"].GetString(), newAuthData));

				m_bSuccessfullyAuthenticatedWithGameServer = true;
			}
			else
			{
				spdlog::error("Failed authenticating with own server: error {}", curl_easy_strerror(result));
				m_bSuccessfullyConnected = false;
				m_bSuccessfullyAuthenticatedWithGameServer = false;
				m_bScriptAuthenticatingWithGameServer = false;
			}

		REQUEST_END_CLEANUP:
			m_bAuthenticatingWithGameServer = false;
			m_bScriptAuthenticatingWithGameServer = false;

			if (m_bNewgameAfterSelfAuth)
			{
				// pretty sure this is threadsafe?
				R2::Cbuf_AddText(R2::Cbuf_GetCurrentPlayer(), "ns_end_reauth_and_leave_to_lobby", R2::cmd_source_t::kCommandSrcCode);
				m_bNewgameAfterSelfAuth = false;
			}

			curl_easy_cleanup(curl);
		});

	requestThread.detach();
}

void MasterServerManager::AuthenticateWithServer(const char* uid, const char* playerToken, const char* serverId, const char* password)
{
	// dont wait, just stop if we're trying to do 2 auth requests at once
	if (m_bAuthenticatingWithGameServer)
		return;

	m_bAuthenticatingWithGameServer = true;
	m_bScriptAuthenticatingWithGameServer = true;
	m_bSuccessfullyAuthenticatedWithGameServer = false;

	std::string uidStr(uid);
	std::string tokenStr(playerToken);
	std::string serverIdStr(serverId);
	std::string passwordStr(password);

	std::thread requestThread(
		[this, uidStr, tokenStr, serverIdStr, passwordStr]()
		{
			// esnure that any persistence saving is done, so we know masterserver has newest
			while (m_bSavingPersistentData)
				Sleep(100);

			spdlog::info("Attempting authentication with server of id \"{}\"", serverIdStr);

			CURL* curl = curl_easy_init();
			SetCommonHttpClientOptions(curl);

			std::string readBuffer;
			curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "POST");
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

			{
				char* escapedPassword = curl_easy_escape(curl, passwordStr.c_str(), passwordStr.length());

				curl_easy_setopt(
					curl,
					CURLOPT_URL,
					fmt::format(
						"{}/client/auth_with_server?id={}&playerToken={}&server={}&password={}",
						Cvar_ns_masterserver_hostname->GetString(),
						uidStr,
						tokenStr,
						serverIdStr,
						escapedPassword)
						.c_str());

				curl_free(escapedPassword);
			}

			CURLcode result = curl_easy_perform(curl);

			if (result == CURLcode::CURLE_OK)
			{
				m_bSuccessfullyConnected = true;

				rapidjson_document connectionInfoJson;
				connectionInfoJson.Parse(readBuffer.c_str());

				if (connectionInfoJson.HasParseError())
				{
					spdlog::error(
						"Failed reading masterserver authentication response: encountered parse error \"{}\"",
						rapidjson::GetParseError_En(connectionInfoJson.GetParseError()));
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
					spdlog::error(readBuffer);

					if (connectionInfoJson["error"].HasMember("enum"))
						m_sAuthFailureReason = connectionInfoJson["error"]["enum"].GetString();
					else
						m_sAuthFailureReason = "No error message provided";

					goto REQUEST_END_CLEANUP;
				}

				if (!connectionInfoJson["success"].IsTrue())
				{
					spdlog::error("Authentication with masterserver failed: \"success\" is not true");
					goto REQUEST_END_CLEANUP;
				}

				if (!connectionInfoJson.HasMember("success") || !connectionInfoJson.HasMember("ip") ||
					!connectionInfoJson["ip"].IsString() || !connectionInfoJson.HasMember("port") ||
					!connectionInfoJson["port"].IsNumber() || !connectionInfoJson.HasMember("authToken") ||
					!connectionInfoJson["authToken"].IsString())
				{
					spdlog::error("Failed reading masterserver authentication response: malformed json object");
					goto REQUEST_END_CLEANUP;
				}

				m_pendingConnectionInfo.ip.S_un.S_addr = inet_addr(connectionInfoJson["ip"].GetString());
				m_pendingConnectionInfo.port = (unsigned short)connectionInfoJson["port"].GetUint();

				strncpy_s(
					m_pendingConnectionInfo.authToken,
					sizeof(m_pendingConnectionInfo.authToken),
					connectionInfoJson["authToken"].GetString(),
					sizeof(m_pendingConnectionInfo.authToken) - 1);

				m_bHasPendingConnectionInfo = true;
				m_bSuccessfullyAuthenticatedWithGameServer = true;
			}
			else
			{
				spdlog::error("Failed authenticating with server: error {}", curl_easy_strerror(result));
				m_bSuccessfullyConnected = false;
				m_bSuccessfullyAuthenticatedWithGameServer = false;
				m_bScriptAuthenticatingWithGameServer = false;
			}

		REQUEST_END_CLEANUP:
			m_bAuthenticatingWithGameServer = false;
			m_bScriptAuthenticatingWithGameServer = false;
			curl_easy_cleanup(curl);
		});

	requestThread.detach();
}

void MasterServerManager::WritePlayerPersistentData(const char* playerId, const char* pdata, size_t pdataSize)
{
	// still call this if we don't have a server id, since lobbies that aren't port forwarded need to be able to call it
	m_bSavingPersistentData = true;
	if (!pdataSize)
	{
		spdlog::warn("attempted to write pdata of size 0!");
		return;
	}

	std::string strPlayerId(playerId);
	std::string strPdata(pdata, pdataSize);

	std::thread requestThread(
		[this, strPlayerId, strPdata, pdataSize]
		{
			CURL* curl = curl_easy_init();
			SetCommonHttpClientOptions(curl);

			std::string readBuffer;
			curl_easy_setopt(
				curl,
				CURLOPT_URL,
				fmt::format(
					"{}/accounts/write_persistence?id={}&serverId={}",
					Cvar_ns_masterserver_hostname->GetString(),
					strPlayerId,
					m_sOwnServerId)
					.c_str());
			curl_easy_setopt(curl, CURLOPT_POST, 1L);
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

			curl_mime* mime = curl_mime_init(curl);
			curl_mimepart* part = curl_mime_addpart(mime);

			curl_mime_data(part, strPdata.c_str(), pdataSize);
			curl_mime_name(part, "pdata");
			curl_mime_filename(part, "file.pdata");
			curl_mime_type(part, "application/octet-stream");

			curl_easy_setopt(curl, CURLOPT_MIMEPOST, mime);

			CURLcode result = curl_easy_perform(curl);

			if (result == CURLcode::CURLE_OK)
				m_bSuccessfullyConnected = true;
			else
				m_bSuccessfullyConnected = false;

			curl_easy_cleanup(curl);

			m_bSavingPersistentData = false;
		});

	requestThread.detach();
}

void ConCommand_ns_fetchservers(const CCommand& args)
{
	g_pMasterServerManager->RequestServerList();
}

MasterServerManager::MasterServerManager() : m_pendingConnectionInfo {}, m_sOwnServerId {""}, m_sOwnClientAuthToken {""} {}

ON_DLL_LOAD_RELIESON("engine.dll", MasterServer, (ConCommand, ServerPresence), (CModule module))
{
	g_pMasterServerManager = new MasterServerManager;

	Cvar_ns_masterserver_hostname = new ConVar("ns_masterserver_hostname", "127.0.0.1", FCVAR_NONE, "");
	Cvar_ns_curl_log_enable = new ConVar("ns_curl_log_enable", "0", FCVAR_NONE, "Whether curl should log to the console");

	RegisterConCommand("ns_fetchservers", ConCommand_ns_fetchservers, "Fetch all servers from the masterserver", FCVAR_CLIENTDLL);

	MasterServerPresenceReporter* presenceReporter = new MasterServerPresenceReporter;
	g_pServerPresence->AddPresenceReporter(presenceReporter);
}

void MasterServerPresenceReporter::CreatePresence(const ServerPresence* pServerPresence)
{
	m_nNumRegistrationAttempts = 0;
}

void MasterServerPresenceReporter::ReportPresence(const ServerPresence* pServerPresence)
{
	// make a copy of presence for multithreading purposes
	ServerPresence threadedPresence(pServerPresence);

	if (!*g_pMasterServerManager->m_sOwnServerId)
	{
		// Don't try if we've reached the max registration attempts.
		// In the future, we should probably allow servers to re-authenticate after a while if the MS was down.
		if (m_nNumRegistrationAttempts >= MAX_REGISTRATION_ATTEMPTS)
		{
			return;
		}

		// Make sure to wait til the cooldown is over for DUPLICATE_SERVER failures.
		if (Tier0::Plat_FloatTime() < m_fNextAddServerAttemptTime)
		{
			return;
		}

		// If we're not running any InternalAddServer() attempt in the background.
		if (!addServerFuture.valid())
		{
			// Launch an attempt to add the local server to the master server.
			InternalAddServer(pServerPresence);
		}
	}
	else
	{
		// If we're not running any InternalUpdateServer() attempt in the background.
		if (!updateServerFuture.valid())
		{
			// Launch an attempt to update the local server on the master server.
			InternalUpdateServer(pServerPresence);
		}
	}
}

void MasterServerPresenceReporter::DestroyPresence(const ServerPresence* pServerPresence)
{
	// Don't call this if we don't have a server id.
	if (!*g_pMasterServerManager->m_sOwnServerId)
	{
		return;
	}

	// Not bothering with better thread safety in this case since DestroyPresence() is called when the game is shutting down.
	*g_pMasterServerManager->m_sOwnServerId = 0;

	std::thread requestThread(
		[this]
		{
			CURL* curl = curl_easy_init();
			SetCommonHttpClientOptions(curl);

			std::string readBuffer;
			curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "DELETE");
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
			curl_easy_setopt(
				curl,
				CURLOPT_URL,
				fmt::format(
					"{}/server/remove_server?id={}", Cvar_ns_masterserver_hostname->GetString(), g_pMasterServerManager->m_sOwnServerId)
					.c_str());

			CURLcode result = curl_easy_perform(curl);
			curl_easy_cleanup(curl);
		});

	requestThread.detach();
}

void MasterServerPresenceReporter::RunFrame(double flCurrentTime, const ServerPresence* pServerPresence)
{
	// Check if we're already running an InternalAddServer() call in the background.
	// If so, grab the result if it's ready.
	if (addServerFuture.valid())
	{
		std::future_status status = addServerFuture.wait_for(0ms);
		if (status != std::future_status::ready)
		{
			// Still running, no need to do anything.
			return;
		}

		// Check the result.
		auto resultData = addServerFuture.get();

		g_pMasterServerManager->m_bSuccessfullyConnected = resultData.result != MasterServerReportPresenceResult::FailedNoConnect;

		switch (resultData.result)
		{
		case MasterServerReportPresenceResult::Success:
			// Copy over the server id and auth token granted by the MS.
			strncpy_s(
				g_pMasterServerManager->m_sOwnServerId,
				sizeof(g_pMasterServerManager->m_sOwnServerId),
				resultData.id.value().c_str(),
				sizeof(g_pMasterServerManager->m_sOwnServerId) - 1);
			strncpy_s(
				g_pMasterServerManager->m_sOwnServerAuthToken,
				sizeof(g_pMasterServerManager->m_sOwnServerAuthToken),
				resultData.serverAuthToken.value().c_str(),
				sizeof(g_pMasterServerManager->m_sOwnServerAuthToken) - 1);
			break;
		case MasterServerReportPresenceResult::FailedNoRetry:
		case MasterServerReportPresenceResult::FailedNoConnect:
			// If we failed to connect to the master server, or failed with no retry, stop trying.
			m_nNumRegistrationAttempts = MAX_REGISTRATION_ATTEMPTS;
			break;
		case MasterServerReportPresenceResult::Failed:
			++m_nNumRegistrationAttempts;
			break;
		case MasterServerReportPresenceResult::FailedDuplicateServer:
			++m_nNumRegistrationAttempts;
			// Wait at least twenty seconds until we re-attempt to add the server.
			m_fNextAddServerAttemptTime = Tier0::Plat_FloatTime() + 20.0f;
			break;
		}

		if (m_nNumRegistrationAttempts >= MAX_REGISTRATION_ATTEMPTS)
		{
			spdlog::error("Reached max ms server registration attempts.");
		}
	}
	else if (updateServerFuture.valid())
	{
		// Check if the InternalUpdateServer() call completed.
		std::future_status status = updateServerFuture.wait_for(0ms);
		if (status != std::future_status::ready)
		{
			// Still running, no need to do anything.
			return;
		}

		auto resultData = updateServerFuture.get();
		if (resultData.result == MasterServerReportPresenceResult::Success)
		{
			if (resultData.id)
			{
				strncpy_s(
					g_pMasterServerManager->m_sOwnServerId,
					sizeof(g_pMasterServerManager->m_sOwnServerId),
					resultData.id.value().c_str(),
					sizeof(g_pMasterServerManager->m_sOwnServerId) - 1);
			}

			if (resultData.serverAuthToken)
			{
				strncpy_s(
					g_pMasterServerManager->m_sOwnServerAuthToken,
					sizeof(g_pMasterServerManager->m_sOwnServerAuthToken),
					resultData.serverAuthToken.value().c_str(),
					sizeof(g_pMasterServerManager->m_sOwnServerAuthToken) - 1);
			}
		}
	}
}

void MasterServerPresenceReporter::InternalAddServer(const ServerPresence* pServerPresence)
{
	const ServerPresence threadedPresence(pServerPresence);
	// Never call this with an ongoing InternalAddServer() call.
	assert(!addServerFuture.valid());

	g_pMasterServerManager->m_sOwnServerId[0] = 0;
	g_pMasterServerManager->m_sOwnServerAuthToken[0] = 0;

	std::string modInfo = g_pMasterServerManager->m_sOwnModInfoJson;
	std::string hostname = Cvar_ns_masterserver_hostname->GetString();

	spdlog::info("Attempting to register the local server to the master server.");

	addServerFuture = std::async(
		std::launch::async,
		[threadedPresence, modInfo, hostname]
		{
			CURL* curl = curl_easy_init();
			SetCommonHttpClientOptions(curl);

			std::string readBuffer;
			curl_easy_setopt(curl, CURLOPT_POST, 1L);
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

			curl_mime* mime = curl_mime_init(curl);
			curl_mimepart* part = curl_mime_addpart(mime);

			// Lambda to quickly cleanup resources and return a value.
			auto ReturnCleanup =
				[curl, mime](MasterServerReportPresenceResult result, const char* id = "", const char* serverAuthToken = "")
			{
				curl_easy_cleanup(curl);
				curl_mime_free(mime);

				MasterServerPresenceReporter::ReportPresenceResultData data;
				data.result = result;
				data.id = id;
				data.serverAuthToken = serverAuthToken;

				return data;
			};

			curl_mime_data(part, modInfo.c_str(), modInfo.size());
			curl_mime_name(part, "modinfo");
			curl_mime_filename(part, "modinfo.json");
			curl_mime_type(part, "application/json");

			curl_easy_setopt(curl, CURLOPT_MIMEPOST, mime);

			// format every paramter because computers hate me
			{
				char* nameEscaped = curl_easy_escape(curl, threadedPresence.m_sServerName.c_str(), NULL);
				char* descEscaped = curl_easy_escape(curl, threadedPresence.m_sServerDesc.c_str(), NULL);
				char* mapEscaped = curl_easy_escape(curl, threadedPresence.m_MapName, NULL);
				char* playlistEscaped = curl_easy_escape(curl, threadedPresence.m_PlaylistName, NULL);
				char* passwordEscaped = curl_easy_escape(curl, threadedPresence.m_Password, NULL);

				curl_easy_setopt(
					curl,
					CURLOPT_URL,
					fmt::format(
						"{}/server/"
						"add_server?port={}&authPort={}&name={}&description={}&map={}&playlist={}&maxPlayers={}&password={}",
						hostname.c_str(),
						threadedPresence.m_iPort,
						threadedPresence.m_iAuthPort,
						nameEscaped,
						descEscaped,
						mapEscaped,
						playlistEscaped,
						threadedPresence.m_iMaxPlayers,
						passwordEscaped)
						.c_str());

				curl_free(nameEscaped);
				curl_free(descEscaped);
				curl_free(mapEscaped);
				curl_free(playlistEscaped);
				curl_free(passwordEscaped);
			}

			CURLcode result = curl_easy_perform(curl);

			if (result == CURLcode::CURLE_OK)
			{
				rapidjson_document serverAddedJson;
				serverAddedJson.Parse(readBuffer.c_str());

				// If we could not parse the JSON or it isn't an object, assume the MS is either wrong or we're completely out of date.
				// No retry.
				if (serverAddedJson.HasParseError())
				{
					spdlog::error(
						"Failed reading masterserver authentication response: encountered parse error \"{}\"",
						rapidjson::GetParseError_En(serverAddedJson.GetParseError()));
					return ReturnCleanup(MasterServerReportPresenceResult::FailedNoRetry);
				}

				if (!serverAddedJson.IsObject())
				{
					spdlog::error("Failed reading masterserver authentication response: root object is not an object");
					return ReturnCleanup(MasterServerReportPresenceResult::FailedNoRetry);
				}

				if (serverAddedJson.HasMember("error"))
				{
					spdlog::error("Failed reading masterserver response: got fastify error response");
					spdlog::error(readBuffer);

					// If this is DUPLICATE_SERVER, we'll retry adding the server every 20 seconds.
					// The master server will only update its internal server list and clean up dead servers on certain events.
					// And then again, only if a player requests the server list after the cooldown (1 second by default), or a server is
					// added/updated/removed. In any case this needs to be fixed in the master server rewrite.
					if (serverAddedJson["error"].HasMember("enum") &&
						strcmp(serverAddedJson["error"]["enum"].GetString(), "DUPLICATE_SERVER") == 0)
					{
						spdlog::error("Cooling down while the master server cleans the dead server entry, if any.");
						return ReturnCleanup(MasterServerReportPresenceResult::FailedDuplicateServer);
					}

					// Retry until we reach max retries.
					return ReturnCleanup(MasterServerReportPresenceResult::Failed);
				}

				if (!serverAddedJson["success"].IsTrue())
				{
					spdlog::error("Adding server to masterserver failed: \"success\" is not true");
					return ReturnCleanup(MasterServerReportPresenceResult::FailedNoRetry);
				}

				if (!serverAddedJson.HasMember("id") || !serverAddedJson["id"].IsString() ||
					!serverAddedJson.HasMember("serverAuthToken") || !serverAddedJson["serverAuthToken"].IsString())
				{
					spdlog::error("Failed reading masterserver response: malformed json object");
					return ReturnCleanup(MasterServerReportPresenceResult::FailedNoRetry);
				}

				spdlog::info("Successfully registered the local server to the master server.");
				return ReturnCleanup(
					MasterServerReportPresenceResult::Success,
					serverAddedJson["id"].GetString(),
					serverAddedJson["serverAuthToken"].GetString());
			}
			else
			{
				spdlog::error("Failed adding self to server list: error {}", curl_easy_strerror(result));
				return ReturnCleanup(MasterServerReportPresenceResult::FailedNoConnect);
			}
		});
}

void MasterServerPresenceReporter::InternalUpdateServer(const ServerPresence* pServerPresence)
{
	const ServerPresence threadedPresence(pServerPresence);

	// Never call this with an ongoing InternalUpdateServer() call.
	assert(!updateServerFuture.valid());

	const std::string serverId = g_pMasterServerManager->m_sOwnServerId;
	const std::string hostname = Cvar_ns_masterserver_hostname->GetString();
	const std::string modinfo = g_pMasterServerManager->m_sOwnModInfoJson;

	updateServerFuture = std::async(
		std::launch::async,
		[threadedPresence, serverId, hostname, modinfo]
		{
			CURL* curl = curl_easy_init();
			SetCommonHttpClientOptions(curl);

			// Lambda to quickly cleanup resources and return a value.
			auto ReturnCleanup = [curl](MasterServerReportPresenceResult result, const char* id = "", const char* serverAuthToken = "")
			{
				curl_easy_cleanup(curl);

				MasterServerPresenceReporter::ReportPresenceResultData data;
				data.result = result;

				if (id != nullptr)
				{
					data.id = id;
				}

				if (serverAuthToken != nullptr)
				{
					data.serverAuthToken = serverAuthToken;
				}

				return data;
			};

			std::string readBuffer;
			curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "POST");
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
			curl_easy_setopt(curl, CURLOPT_VERBOSE, 0L);

			// send all registration info so we have all necessary info to reregister our server if masterserver goes down,
			// without a restart this isn't threadsafe :terror:
			{
				char* nameEscaped = curl_easy_escape(curl, threadedPresence.m_sServerName.c_str(), NULL);
				char* descEscaped = curl_easy_escape(curl, threadedPresence.m_sServerDesc.c_str(), NULL);
				char* mapEscaped = curl_easy_escape(curl, threadedPresence.m_MapName, NULL);
				char* playlistEscaped = curl_easy_escape(curl, threadedPresence.m_PlaylistName, NULL);
				char* passwordEscaped = curl_easy_escape(curl, threadedPresence.m_Password, NULL);

				curl_easy_setopt(
					curl,
					CURLOPT_URL,
					fmt::format(
						"{}/server/"
						"update_values?id={}&port={}&authPort={}&name={}&description={}&map={}&playlist={}&playerCount={}&"
						"maxPlayers={}&password={}",
						hostname.c_str(),
						serverId.c_str(),
						threadedPresence.m_iPort,
						threadedPresence.m_iAuthPort,
						nameEscaped,
						descEscaped,
						mapEscaped,
						playlistEscaped,
						threadedPresence.m_iPlayerCount,
						threadedPresence.m_iMaxPlayers,
						passwordEscaped)
						.c_str());

				curl_free(nameEscaped);
				curl_free(descEscaped);
				curl_free(mapEscaped);
				curl_free(playlistEscaped);
				curl_free(passwordEscaped);
			}

			curl_mime* mime = curl_mime_init(curl);
			curl_mimepart* part = curl_mime_addpart(mime);

			curl_mime_data(part, modinfo.c_str(), modinfo.size());
			curl_mime_name(part, "modinfo");
			curl_mime_filename(part, "modinfo.json");
			curl_mime_type(part, "application/json");

			curl_easy_setopt(curl, CURLOPT_MIMEPOST, mime);

			CURLcode result = curl_easy_perform(curl);

			if (result == CURLcode::CURLE_OK)
			{
				rapidjson_document serverAddedJson;
				serverAddedJson.Parse(readBuffer.c_str());

				const char* updatedId = nullptr;
				const char* updatedAuthToken = nullptr;

				if (!serverAddedJson.HasParseError() && serverAddedJson.IsObject())
				{
					if (serverAddedJson.HasMember("id") && serverAddedJson["id"].IsString())
					{
						updatedId = serverAddedJson["id"].GetString();
					}

					if (serverAddedJson.HasMember("serverAuthToken") && serverAddedJson["serverAuthToken"].IsString())
					{
						updatedAuthToken = serverAddedJson["serverAuthToken"].GetString();
					}
				}

				return ReturnCleanup(MasterServerReportPresenceResult::Success, updatedId, updatedAuthToken);
			}
			else
			{
				spdlog::warn("Heartbeat failed with error {}", curl_easy_strerror(result));
				return ReturnCleanup(MasterServerReportPresenceResult::Failed);
			}
		});
}
