#include "pch.h"
#include "masterserver.h"
#include "concommand.h"
#include "gameutils.h"
#include "hookutils.h"
#include "serverauthentication.h"
#include "gameutils.h"
#include "rapidjson/document.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/writer.h"
#include "rapidjson/error/en.h"
#include "modmanager.h"
#include "misccommands.h"
#include <cstring>
#include <regex>
// NOTE for anyone reading this: we used to use httplib for requests here, but it had issues, so we're moving to curl now for masterserver
// requests so httplib is used exclusively for server stuff now

ConVar* Cvar_ns_masterserver_hostname;
ConVar* Cvar_ns_report_server_to_masterserver;
ConVar* Cvar_ns_report_sp_server_to_masterserver;

ConVar* Cvar_ns_server_name;
ConVar* Cvar_ns_server_desc;
ConVar* Cvar_ns_server_password;

// Source ConVar
ConVar* Cvar_hostname;

MasterServerManager* g_MasterServerManager;

typedef void (*CHostState__State_NewGameType)(CHostState* hostState);
CHostState__State_NewGameType CHostState__State_NewGame;

typedef void (*CHostState__State_ChangeLevelMPType)(CHostState* hostState);
CHostState__State_ChangeLevelMPType CHostState__State_ChangeLevelMP;

typedef void (*CHostState__State_ChangeLevelSPType)(CHostState* hostState);
CHostState__State_ChangeLevelSPType CHostState__State_ChangeLevelSP;

typedef void (*CHostState__State_GameShutdownType)(CHostState* hostState);
CHostState__State_GameShutdownType CHostState__State_GameShutdown;

// Convert a hex digit char to integer.
inline int hctod(char c)
{
	if (c >= 'A' && c <= 'F')
	{
		return c - 'A' + 10;
	}
	else if (c >= 'a' && c <= 'f')
	{
		return c - 'a' + 10;
	}
	else
	{
		return c - '0';
	}
}

// This function interprets all 4-hexadecimal-digit unicode codepoint characters like \u4E2D to UTF-8 encoding.
std::string unescape_unicode(const std::string& str)
{
	std::string result;
	std::regex r("\\\\u([a-f\\d]{4})", std::regex::icase);
	auto matches_begin = std::sregex_iterator(str.begin(), str.end(), r);
	auto matches_end = std::sregex_iterator();
	std::smatch last_match;
	for (std::sregex_iterator i = matches_begin; i != matches_end; ++i)
	{
		last_match = *i;
		result.append(last_match.prefix());
		unsigned int cp = 0;
		for (int i = 2; i <= 5; ++i)
		{
			cp *= 16;
			cp += hctod(last_match.str()[i]);
		}
		if (cp <= 0x7F)
		{
			result.push_back(cp);
		}
		else if (cp <= 0x7FF)
		{
			result.push_back((cp >> 6) | 0b11000000 & (~(1 << 5)));
			result.push_back(cp & ((1 << 6) - 1) | 0b10000000 & (~(1 << 6)));
		}
		else if (cp <= 0xFFFF)
		{
			result.push_back((cp >> 12) | 0b11100000 & (~(1 << 4)));
			result.push_back((cp >> 6) & ((1 << 6) - 1) | 0b10000000 & (~(1 << 6)));
			result.push_back(cp & ((1 << 6) - 1) | 0b10000000 & (~(1 << 6)));
		}
	}
	if (!last_match.ready())
	{
		return str;
	}
	else
	{
		result.append(last_match.suffix());
	}
	return result;
}

void UpdateServerInfoFromUnicodeToUTF8()
{
	g_MasterServerManager->ns_auth_srvName = unescape_unicode(Cvar_ns_server_name->GetString());
	g_MasterServerManager->ns_auth_srvDesc = unescape_unicode(Cvar_ns_server_desc->GetString());
}

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

RemoteServerInfo::RemoteServerInfo(
	const char* newId, const char* newName, const char* newDescription, const char* newMap, const char* newPlaylist, int newPlayerCount,
	int newMaxPlayers, bool newRequiresPassword)
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

void MasterServerManager::SetCommonHttpClientOptions(CURL* curl)
{
	curl_easy_setopt(curl, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
	curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
	// curl_easy_setopt(curl, CURLOPT_STDERR, stdout);
	if (CommandLine()->FindParm("-msinsecure")) // TODO: this check doesn't seem to work
	{
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
	}
}

void MasterServerManager::ClearServerList()
{
	// this doesn't really do anything lol, probably isn't threadsafe
	m_requestingServerList = true;

	m_remoteServers.clear();

	m_requestingServerList = false;
}

size_t CurlWriteToStringBufferCallback(char* contents, size_t size, size_t nmemb, void* userp)
{
	((std::string*)userp)->append((char*)contents, size * nmemb);
	return size * nmemb;
}

void MasterServerManager::AuthenticateOriginWithMasterServer(char* uid, char* originToken)
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
				curl, CURLOPT_URL,
				fmt::format("{}/client/origin_auth?id={}&token={}", Cvar_ns_masterserver_hostname->GetString(), uidStr, tokenStr).c_str());
			curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "GET");
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

			CURLcode result = curl_easy_perform(curl);

			if (result == CURLcode::CURLE_OK)
			{
				m_successfullyConnected = true;

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
					strncpy(m_ownClientAuthToken, originAuthInfo["token"].GetString(), sizeof(m_ownClientAuthToken));
					m_ownClientAuthToken[sizeof(m_ownClientAuthToken) - 1] = 0;
					spdlog::info("Northstar origin authentication completed successfully!");
				}
				else
					spdlog::error("Northstar origin authentication failed");
			}
			else
			{
				spdlog::error("Failed performing northstar origin auth: error {}", curl_easy_strerror(result));
				m_successfullyConnected = false;
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
	m_scriptRequestingServerList = true;

	std::thread requestThread(
		[this]()
		{
			// make sure we never have 2 threads writing at once
			// i sure do hope this is actually threadsafe
			while (m_requestingServerList)
				Sleep(100);

			m_requestingServerList = true;
			m_scriptRequestingServerList = true;

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
				m_successfullyConnected = true;

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
					for (RemoteServerInfo& server : m_remoteServers)
					{
						// if server already exists, update info rather than adding to it
						if (!strncmp((const char*)server.id, id, 32))
						{
							server = RemoteServerInfo(
								id, serverObj["name"].GetString(), serverObj["description"].GetString(), serverObj["map"].GetString(),
								serverObj["playlist"].GetString(), serverObj["playerCount"].GetInt(), serverObj["maxPlayers"].GetInt(),
								serverObj["hasPassword"].IsTrue());
							newServer = &server;
							createNewServerInfo = false;
							break;
						}
					}

					// server didn't exist
					if (createNewServerInfo)
						newServer = &m_remoteServers.emplace_back(
							id, serverObj["name"].GetString(), serverObj["description"].GetString(), serverObj["map"].GetString(),
							serverObj["playlist"].GetString(), serverObj["playerCount"].GetInt(), serverObj["maxPlayers"].GetInt(),
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
					m_remoteServers.begin(), m_remoteServers.end(),
					[](RemoteServerInfo& a, RemoteServerInfo& b) { return a.playerCount > b.playerCount; });
			}
			else
			{
				spdlog::error("Failed requesting servers: error {}", curl_easy_strerror(result));
				m_successfullyConnected = false;
			}

			// we goto this instead of returning so we always hit this
		REQUEST_END_CLEANUP:
			m_requestingServerList = false;
			m_scriptRequestingServerList = false;
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
				m_successfullyConnected = true;

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
				spdlog::error("Failed requesting main menu promos: error {}", curl_easy_strerror(result));
				m_successfullyConnected = false;
			}

		REQUEST_END_CLEANUP:
			// nothing lol
			curl_easy_cleanup(curl);
		});

	requestThread.detach();
}

void MasterServerManager::AuthenticateWithOwnServer(char* uid, char* playerToken)
{
	// dont wait, just stop if we're trying to do 2 auth requests at once
	if (m_authenticatingWithGameServer)
		return;

	m_authenticatingWithGameServer = true;
	m_scriptAuthenticatingWithGameServer = true;
	m_successfullyAuthenticatedWithGameServer = false;

	std::string uidStr(uid);
	std::string tokenStr(playerToken);

	std::thread requestThread(
		[this, uidStr, tokenStr]()
		{
			CURL* curl = curl_easy_init();
			SetCommonHttpClientOptions(curl);

			std::string readBuffer;
			curl_easy_setopt(
				curl, CURLOPT_URL,
				fmt::format("{}/client/auth_with_self?id={}&playerToken={}", Cvar_ns_masterserver_hostname->GetString(), uidStr, tokenStr)
					.c_str());
			curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "POST");
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

			CURLcode result = curl_easy_perform(curl);

			if (result == CURLcode::CURLE_OK)
			{
				m_successfullyConnected = true;

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

				AuthData newAuthData;
				strncpy(newAuthData.uid, authInfoJson["id"].GetString(), sizeof(newAuthData.uid));
				newAuthData.uid[sizeof(newAuthData.uid) - 1] = 0;

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

				std::lock_guard<std::mutex> guard(g_ServerAuthenticationManager->m_authDataMutex);
				g_ServerAuthenticationManager->m_authData.clear();
				g_ServerAuthenticationManager->m_authData.insert(std::make_pair(authInfoJson["authToken"].GetString(), newAuthData));

				m_successfullyAuthenticatedWithGameServer = true;
			}
			else
			{
				spdlog::error("Failed authenticating with own server: error {}", curl_easy_strerror(result));
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

			curl_easy_cleanup(curl);
		});

	requestThread.detach();
}

void MasterServerManager::AuthenticateWithServer(char* uid, char* playerToken, char* serverId, char* password)
{
	// dont wait, just stop if we're trying to do 2 auth requests at once
	if (m_authenticatingWithGameServer)
		return;

	m_authenticatingWithGameServer = true;
	m_scriptAuthenticatingWithGameServer = true;
	m_successfullyAuthenticatedWithGameServer = false;

	std::string uidStr(uid);
	std::string tokenStr(playerToken);
	std::string serverIdStr(serverId);
	std::string passwordStr(password);

	std::thread requestThread(
		[this, uidStr, tokenStr, serverIdStr, passwordStr]()
		{
			// esnure that any persistence saving is done, so we know masterserver has newest
			while (m_savingPersistentData)
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
					curl, CURLOPT_URL,
					fmt::format(
						"{}/client/auth_with_server?id={}&playerToken={}&server={}&password={}", Cvar_ns_masterserver_hostname->GetString(),
						uidStr, tokenStr, serverIdStr, escapedPassword)
						.c_str());

				curl_free(escapedPassword);
			}

			CURLcode result = curl_easy_perform(curl);

			if (result == CURLcode::CURLE_OK)
			{
				m_successfullyConnected = true;

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

				strncpy(m_pendingConnectionInfo.authToken, connectionInfoJson["authToken"].GetString(), 31);
				m_pendingConnectionInfo.authToken[31] = 0;

				m_hasPendingConnectionInfo = true;
				m_successfullyAuthenticatedWithGameServer = true;
			}
			else
			{
				spdlog::error("Failed authenticating with server: error {}", curl_easy_strerror(result));
				m_successfullyConnected = false;
				m_successfullyAuthenticatedWithGameServer = false;
				m_scriptAuthenticatingWithGameServer = false;
			}

		REQUEST_END_CLEANUP:
			m_authenticatingWithGameServer = false;
			m_scriptAuthenticatingWithGameServer = false;
			curl_easy_cleanup(curl);
		});

	requestThread.detach();
}

void MasterServerManager::AddSelfToServerList(
	int port, int authPort, char* name, char* description, char* map, char* playlist, int maxPlayers, char* password)
{
	if (!Cvar_ns_report_server_to_masterserver->GetBool())
		return;

	if (!Cvar_ns_report_sp_server_to_masterserver->GetBool() && !strncmp(map, "sp_", 3))
	{
		m_bRequireClientAuth = false;
		return;
	}

	m_bRequireClientAuth = true;

	std::string strName(name);
	std::string strDescription(description);
	std::string strMap(map);
	std::string strPlaylist(playlist);
	std::string strPassword(password);

	std::thread requestThread(
		[this, port, authPort, strName, strDescription, strMap, strPlaylist, maxPlayers, strPassword]
		{
			m_ownServerId[0] = 0;
			m_ownServerAuthToken[0] = 0;

			CURL* curl = curl_easy_init();
			SetCommonHttpClientOptions(curl);

			std::string readBuffer;
			curl_easy_setopt(curl, CURLOPT_POST, 1L);
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

			curl_mime* mime = curl_mime_init(curl);
			curl_mimepart* part = curl_mime_addpart(mime);

			curl_mime_data(part, m_ownModInfoJson.c_str(), m_ownModInfoJson.size());
			curl_mime_name(part, "modinfo");
			curl_mime_filename(part, "modinfo.json");
			curl_mime_type(part, "application/json");

			curl_easy_setopt(curl, CURLOPT_MIMEPOST, mime);

			// format every paramter because computers hate me
			{
				char* nameEscaped = curl_easy_escape(curl, strName.c_str(), strName.length());
				char* descEscaped = curl_easy_escape(curl, strDescription.c_str(), strDescription.length());
				char* mapEscaped = curl_easy_escape(curl, strMap.c_str(), strMap.length());
				char* playlistEscaped = curl_easy_escape(curl, strPlaylist.c_str(), strPlaylist.length());
				char* passwordEscaped = curl_easy_escape(curl, strPassword.c_str(), strPassword.length());

				curl_easy_setopt(
					curl, CURLOPT_URL,
					fmt::format(
						"{}/server/add_server?port={}&authPort={}&name={}&description={}&map={}&playlist={}&maxPlayers={}&password={}",
						Cvar_ns_masterserver_hostname->GetString(), port, authPort, nameEscaped, descEscaped, mapEscaped, playlistEscaped,
						maxPlayers, passwordEscaped)
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
				m_successfullyConnected = true;

				rapidjson_document serverAddedJson;
				serverAddedJson.Parse(readBuffer.c_str());

				if (serverAddedJson.HasParseError())
				{
					spdlog::error(
						"Failed reading masterserver authentication response: encountered parse error \"{}\"",
						rapidjson::GetParseError_En(serverAddedJson.GetParseError()));
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
					spdlog::error(readBuffer);
					goto REQUEST_END_CLEANUP;
				}

				if (!serverAddedJson["success"].IsTrue())
				{
					spdlog::error("Adding server to masterserver failed: \"success\" is not true");
					goto REQUEST_END_CLEANUP;
				}

				if (!serverAddedJson.HasMember("id") || !serverAddedJson["id"].IsString() ||
					!serverAddedJson.HasMember("serverAuthToken") || !serverAddedJson["serverAuthToken"].IsString())
				{
					spdlog::error("Failed reading masterserver response: malformed json object");
					goto REQUEST_END_CLEANUP;
				}

				strncpy(m_ownServerId, serverAddedJson["id"].GetString(), sizeof(m_ownServerId));
				m_ownServerId[sizeof(m_ownServerId) - 1] = 0;

				strncpy(m_ownServerAuthToken, serverAddedJson["serverAuthToken"].GetString(), sizeof(m_ownServerAuthToken));
				m_ownServerAuthToken[sizeof(m_ownServerAuthToken) - 1] = 0;

				// heartbeat thread
				// ideally this should actually be done in main thread, rather than on it's own thread, so it'd stop if server freezes
				std::thread heartbeatThread(
					[this]
					{
						Sleep(5000);

						do
						{
							CURL* curl = curl_easy_init();
							SetCommonHttpClientOptions(curl);

							std::string readBuffer;
							curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "POST");
							curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurlWriteToStringBufferCallback);
							curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
							curl_easy_setopt(curl, CURLOPT_VERBOSE, 0L);

							// send all registration info so we have all necessary info to reregister our server if masterserver goes down,
							// without a restart this isn't threadsafe :terror:
							{
								char* escapedNameNew = curl_easy_escape(curl, g_MasterServerManager->ns_auth_srvName.c_str(), NULL);
								char* escapedDescNew = curl_easy_escape(curl, g_MasterServerManager->ns_auth_srvDesc.c_str(), NULL);
								char* escapedMapNew = curl_easy_escape(curl, g_pHostState->m_levelName, NULL);
								char* escapedPlaylistNew = curl_easy_escape(curl, GetCurrentPlaylistName(), NULL);
								char* escapedPasswordNew = curl_easy_escape(curl, Cvar_ns_server_password->GetString(), NULL);

								int maxPlayers = 6;
								char* maxPlayersVar = GetCurrentPlaylistVar("max_players", false);
								if (maxPlayersVar) // GetCurrentPlaylistVar can return null so protect against this
									maxPlayers = std::stoi(maxPlayersVar);

								curl_easy_setopt(
									curl, CURLOPT_URL,
									fmt::format(
										"{}/server/"
										"update_values?id={}&port={}&authPort={}&name={}&description={}&map={}&playlist={}&playerCount={}&"
										"maxPlayers={}&password={}",
										Cvar_ns_masterserver_hostname->GetString(), m_ownServerId, Cvar_hostport->GetInt(),
										Cvar_ns_player_auth_port->GetInt(), escapedNameNew, escapedDescNew, escapedMapNew,
										escapedPlaylistNew, g_ServerAuthenticationManager->m_additionalPlayerData.size(), maxPlayers,
										escapedPasswordNew)
										.c_str());

								curl_free(escapedNameNew);
								curl_free(escapedDescNew);
								curl_free(escapedMapNew);
								curl_free(escapedPlaylistNew);
								curl_free(escapedPasswordNew);
							}

							curl_mime* mime = curl_mime_init(curl);
							curl_mimepart* part = curl_mime_addpart(mime);

							curl_mime_data(part, m_ownModInfoJson.c_str(), m_ownModInfoJson.size());
							curl_mime_name(part, "modinfo");
							curl_mime_filename(part, "modinfo.json");
							curl_mime_type(part, "application/json");

							curl_easy_setopt(curl, CURLOPT_MIMEPOST, mime);

							CURLcode result = curl_easy_perform(curl);
							if (result == CURLcode::CURLE_OK)
							{
								rapidjson_document serverAddedJson;
								serverAddedJson.Parse(readBuffer.c_str());

								if (!serverAddedJson.HasParseError() && serverAddedJson.IsObject())
								{
									if (serverAddedJson.HasMember("id") && serverAddedJson["id"].IsString())
									{
										strncpy(m_ownServerId, serverAddedJson["id"].GetString(), sizeof(m_ownServerId));
										m_ownServerId[sizeof(m_ownServerId) - 1] = 0;
									}

									if (serverAddedJson.HasMember("serverAuthToken") && serverAddedJson["serverAuthToken"].IsString())
									{
										strncpy(
											m_ownServerAuthToken, serverAddedJson["serverAuthToken"].GetString(),
											sizeof(m_ownServerAuthToken));
										m_ownServerAuthToken[sizeof(m_ownServerAuthToken) - 1] = 0;
									}
								}
							}
							else
								spdlog::warn("Heartbeat failed with error {}", curl_easy_strerror(result));

							curl_easy_cleanup(curl);
							Sleep(10000);
						} while (*m_ownServerId);
					});

				heartbeatThread.detach();
			}
			else
			{
				spdlog::error("Failed adding self to server list: error {}", curl_easy_strerror(result));
				m_successfullyConnected = false;
			}

		REQUEST_END_CLEANUP:
			curl_easy_cleanup(curl);
			curl_mime_free(mime);
		});

	requestThread.detach();
}

void MasterServerManager::UpdateServerMapAndPlaylist(char* map, char* playlist, int maxPlayers)
{
	// dont call this if we don't have a server id
	if (!*m_ownServerId)
		return;

	std::string strMap(map);
	std::string strPlaylist(playlist);

	std::thread requestThread(
		[this, strMap, strPlaylist, maxPlayers]
		{
			CURL* curl = curl_easy_init();
			SetCommonHttpClientOptions(curl);

			std::string readBuffer;
			curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "POST");
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

			// escape params
			{
				char* mapEscaped = curl_easy_escape(curl, strMap.c_str(), strMap.length());
				char* playlistEscaped = curl_easy_escape(curl, strPlaylist.c_str(), strPlaylist.length());

				curl_easy_setopt(
					curl, CURLOPT_URL,
					fmt::format(
						"{}/server/update_values?id={}&map={}&playlist={}&maxPlayers={}", Cvar_ns_masterserver_hostname->GetString(),
						m_ownServerId, mapEscaped, playlistEscaped, maxPlayers)
						.c_str());

				curl_free(mapEscaped);
				curl_free(playlistEscaped);
			}

			CURLcode result = curl_easy_perform(curl);

			if (result == CURLcode::CURLE_OK)
				m_successfullyConnected = true;
			else
				m_successfullyConnected = false;

			curl_easy_cleanup(curl);
		});

	requestThread.detach();
}

void MasterServerManager::UpdateServerPlayerCount(int playerCount)
{
	// dont call this if we don't have a server id
	if (!*m_ownServerId)
		return;

	std::thread requestThread(
		[this, playerCount]
		{
			CURL* curl = curl_easy_init();
			SetCommonHttpClientOptions(curl);

			std::string readBuffer;
			curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "POST");
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
			curl_easy_setopt(
				curl, CURLOPT_URL,
				fmt::format(
					"{}/server/update_values?id={}&playerCount={}", Cvar_ns_masterserver_hostname->GetString(), m_ownServerId, playerCount)
					.c_str());

			CURLcode result = curl_easy_perform(curl);

			if (result == CURLcode::CURLE_OK)
				m_successfullyConnected = true;
			else
				m_successfullyConnected = false;

			curl_easy_cleanup(curl);
		});

	requestThread.detach();
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

	std::string strPlayerId(playerId);
	std::string strPdata(pdata, pdataSize);

	std::thread requestThread(
		[this, strPlayerId, strPdata, pdataSize]
		{
			CURL* curl = curl_easy_init();
			SetCommonHttpClientOptions(curl);

			std::string readBuffer;
			curl_easy_setopt(
				curl, CURLOPT_URL,
				fmt::format(
					"{}/accounts/write_persistence?id={}&serverId={}", Cvar_ns_masterserver_hostname->GetString(), strPlayerId,
					m_ownServerId)
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
				m_successfullyConnected = true;
			else
				m_successfullyConnected = false;

			curl_easy_cleanup(curl);

			m_savingPersistentData = false;
		});

	requestThread.detach();
}

void MasterServerManager::RemoveSelfFromServerList()
{
	// dont call this if we don't have a server id
	if (!*m_ownServerId || !Cvar_ns_report_server_to_masterserver->GetBool())
		return;

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
				curl, CURLOPT_URL,
				fmt::format("{}/server/remove_server?id={}", Cvar_ns_masterserver_hostname->GetString(), m_ownServerId).c_str());

			CURLcode result = curl_easy_perform(curl);

			if (result == CURLcode::CURLE_OK)
				m_successfullyConnected = true;
			else
				m_successfullyConnected = false;

			curl_easy_cleanup(curl);
		});

	requestThread.detach();
}

void ConCommand_ns_fetchservers(const CCommand& args) { g_MasterServerManager->RequestServerList(); }

void CHostState__State_NewGameHook(CHostState* hostState)
{
	Cbuf_AddText(Cbuf_GetCurrentPlayer(), "exec autoexec_ns_server", cmd_source_t::kCommandSrcCode);
	Cbuf_Execute();

	// need to do this to ensure we don't go to private match
	if (g_ServerAuthenticationManager->m_bNeedLocalAuthForNewgame)
		SetCurrentPlaylist("tdm");

	// net_data_block_enabled is required for sp, force it if we're on an sp map
	// sucks for security but just how it be
	if (!strncmp(g_pHostState->m_levelName, "sp_", 3))
	{
		Cbuf_AddText(Cbuf_GetCurrentPlayer(), "net_data_block_enabled 1", cmd_source_t::kCommandSrcCode);
		Cbuf_Execute();
	}

	CHostState__State_NewGame(hostState);

	int maxPlayers = 6;
	char* maxPlayersVar = GetCurrentPlaylistVar("max_players", false);
	if (maxPlayersVar) // GetCurrentPlaylistVar can return null so protect against this
		maxPlayers = std::stoi(maxPlayersVar);

	// Copy new server name cvar to source
	Cvar_hostname->SetValue(Cvar_ns_server_name->GetString());
	// This calls the function that converts unicode strings from servername and serverdesc to UTF-8
	UpdateServerInfoFromUnicodeToUTF8();

	g_MasterServerManager->AddSelfToServerList(
		Cvar_hostport->GetInt(), Cvar_ns_player_auth_port->GetInt(), (char*)Cvar_ns_server_name->GetString(),
		(char*)Cvar_ns_server_desc->GetString(), hostState->m_levelName, (char*)GetCurrentPlaylistName(), maxPlayers,
		(char*)Cvar_ns_server_password->GetString());
	g_ServerAuthenticationManager->StartPlayerAuthServer();
	g_ServerAuthenticationManager->m_bNeedLocalAuthForNewgame = false;
}

void CHostState__State_ChangeLevelMPHook(CHostState* hostState)
{
	int maxPlayers = 6;
	char* maxPlayersVar = GetCurrentPlaylistVar("max_players", false);
	if (maxPlayersVar) // GetCurrentPlaylistVar can return null so protect against this
		maxPlayers = std::stoi(maxPlayersVar);

	// net_data_block_enabled is required for sp, force it if we're on an sp map
	// sucks for security but just how it be
	if (!strncmp(g_pHostState->m_levelName, "sp_", 3))
	{
		Cbuf_AddText(Cbuf_GetCurrentPlayer(), "net_data_block_enabled 1", cmd_source_t::kCommandSrcCode);
		Cbuf_Execute();
	}

	g_MasterServerManager->UpdateServerMapAndPlaylist(hostState->m_levelName, (char*)GetCurrentPlaylistName(), maxPlayers);
	CHostState__State_ChangeLevelMP(hostState);
}

void CHostState__State_ChangeLevelSPHook(CHostState* hostState)
{
	// is this even called? genuinely i don't think so
	// from what i can tell, it's not called on mp=>sp change or sp=>sp change
	// so idk it's fucked

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

MasterServerManager::MasterServerManager() : m_pendingConnectionInfo{}, m_ownServerId{""}, m_ownClientAuthToken{""} {}

void InitialiseSharedMasterServer(HMODULE baseAddress)
{
	Cvar_ns_masterserver_hostname = new ConVar("ns_masterserver_hostname", "127.0.0.1", FCVAR_NONE, "");
	// unfortunately lib doesn't let us specify a port and still have https work
	// Cvar_ns_masterserver_port = new ConVar("ns_masterserver_port", "8080", FCVAR_NONE, "");

	Cvar_ns_server_name = new ConVar("ns_server_name", "Unnamed Northstar Server", FCVAR_GAMEDLL, "");
	Cvar_ns_server_desc = new ConVar("ns_server_desc", "Default server description", FCVAR_GAMEDLL, "");
	Cvar_ns_server_password = new ConVar("ns_server_password", "", FCVAR_GAMEDLL, "");
	Cvar_ns_report_server_to_masterserver = new ConVar("ns_report_server_to_masterserver", "1", FCVAR_GAMEDLL, "");
	Cvar_ns_report_sp_server_to_masterserver = new ConVar("ns_report_sp_server_to_masterserver", "0", FCVAR_GAMEDLL, "");

	Cvar_hostname = *(ConVar**)((char*)baseAddress + 0x1315bae8);

	g_MasterServerManager = new MasterServerManager;

	RegisterConCommand("ns_fetchservers", ConCommand_ns_fetchservers, "", FCVAR_CLIENTDLL);

	HookEnabler hook;
	ENABLER_CREATEHOOK(
		hook, (char*)baseAddress + 0x16E7D0, CHostState__State_NewGameHook, reinterpret_cast<LPVOID*>(&CHostState__State_NewGame));
	ENABLER_CREATEHOOK(
		hook, (char*)baseAddress + 0x16E520, CHostState__State_ChangeLevelMPHook,
		reinterpret_cast<LPVOID*>(&CHostState__State_ChangeLevelMP));
	ENABLER_CREATEHOOK(
		hook, (char*)baseAddress + 0x16E5D0, CHostState__State_ChangeLevelSPHook,
		reinterpret_cast<LPVOID*>(&CHostState__State_ChangeLevelSP));
	ENABLER_CREATEHOOK(
		hook, (char*)baseAddress + 0x16E640, CHostState__State_GameShutdownHook,
		reinterpret_cast<LPVOID*>(&CHostState__State_GameShutdown));
}
