#include "pch.h"
#include "masterserver.h"
#include "httplib.h"
#include "rapidjson/document.h"
#include "rapidjson/error/en.h"

#include "concommand.h"

ConVar* Cvar_ns_masterserver_hostname;
ConVar* Cvar_ns_masterserver_port;

MasterServerManager* g_MasterServerManager;

// requires password constructor
RemoteServerInfo::RemoteServerInfo(const char* newId, const char* newName, const char* newDescription, const char* newMap, const char* newPlaylist, int newPlayerCount, int newMaxPlayers)
{
	// passworded servers don't have public ips
	requiresPassword = true;
	memset(&ip, 0, sizeof(ip));
	port = 0;

	strncpy((char*)id, newId, 31);
	id[31] = 0;
	strncpy((char*)name, newName, 63);
	name[63] = 0;

	description = new char[strlen(newDescription) + 1];
	strcpy(description, newDescription);

	strncpy((char*)map, newMap, 31);
	map[31] = 0;
	strncpy((char*)playlist, newPlaylist, 15);
	playlist[15] = 0;

	playerCount = newPlayerCount;
	maxPlayers = newMaxPlayers;
}

// doesnt require password constructor
RemoteServerInfo::RemoteServerInfo(const char* newId, const char* newName, const char* newDescription, const char* newMap, const char* newPlaylist, int newPlayerCount, int newMaxPlayers, in_addr newIp, int newPort)
{
	requiresPassword = false;

	strncpy((char*)id, newId, 31);
	id[31] = 0;
	strncpy((char*)name, newName, 63);
	name[63] = 0;

	description = new char[strlen(newDescription) + 1];
	strcpy(description, newDescription);

	strncpy((char*)map, newMap, 31);
	map[31] = 0;
	strncpy((char*)playlist, newPlaylist, 15);
	playlist[15] = 0;

	playerCount = newPlayerCount;
	maxPlayers = newMaxPlayers;

	ip = newIp;
	port = newPort;
}

RemoteServerInfo::~RemoteServerInfo()
{
	delete[] description;
}

void MasterServerManager::ClearServerList()
{
	// this doesn't really do anything lol, probably isn't threadsafe
	m_requestingServerList = true;

	m_remoteServers.clear();

	m_requestingServerList = false;
}

void MasterServerManager::RequestServerList()
{
	m_scriptRequestingServerList = true;

	std::thread requestThread([this]()
		{
			// make sure we never have 2 threads writing at once
			// i sure do hope this is actually threadsafe
			while (m_requestingServerList)
				Sleep(100);

			m_requestingServerList = true;
			m_scriptRequestingServerList = true;
			
			httplib::Client http(Cvar_ns_masterserver_hostname->m_pszString, Cvar_ns_masterserver_port->m_nValue);
			http.set_connection_timeout(10);

			spdlog::info("Requesting server list from {}", Cvar_ns_masterserver_hostname->m_pszString);

			if (auto result = http.Get("/servers"))
			{
				m_successfullyConnected = true;

				rapidjson::Document serverInfoJson;
				serverInfoJson.Parse(result->body.c_str());

				if (serverInfoJson.HasParseError())
				{
					spdlog::error("Failed reading masterserver response: encountered parse error \"{}\"", rapidjson::GetParseError_En(serverInfoJson.GetParseError()));
					goto REQUEST_SERVER_LIST_END;
				}

				if (!serverInfoJson.IsArray())
				{
					spdlog::error("Failed reading masterserver response: root object is not an array");
					goto REQUEST_SERVER_LIST_END;
				}

				rapidjson::GenericArray<false, rapidjson::Value> serverArray = serverInfoJson.GetArray();

				spdlog::info("Got {} servers", serverArray.Size());

				for (auto& serverObj : serverArray)
				{
					if (!serverObj.IsObject())
					{
						spdlog::error("Failed reading masterserver response: member of server array is not an object");
						goto REQUEST_SERVER_LIST_END;
					}

					// todo: verify json props are fine before adding to m_remoteServers

					if (!serverObj.HasMember("id") || !serverObj["id"].IsString() 
						|| !serverObj.HasMember("name") || !serverObj["name"].IsString() 
						|| !serverObj.HasMember("description") || !serverObj["description"].IsString()
						|| !serverObj.HasMember("map") || !serverObj["map"].IsString()
						|| !serverObj.HasMember("playlist") || !serverObj["playlist"].IsString()
						|| !serverObj.HasMember("playerCount") || !serverObj["playerCount"].IsNumber()
						|| !serverObj.HasMember("maxPlayers") || !serverObj["maxPlayers"].IsNumber()
						|| !serverObj.HasMember("hasPassword") || !serverObj["hasPassword"].IsBool())
					{
						spdlog::error("Failed reading masterserver response: malformed server object");
						goto REQUEST_SERVER_LIST_END;
					}

					bool hasPassword = serverObj["hasPassword"].GetBool();
					const char* id = serverObj["id"].GetString();

					bool createNewServerInfo = true;
					for (RemoteServerInfo& server : m_remoteServers)
					{
						// server already exists, update info
						if (!strncmp((const char*)server.id, id, 31))
						{
							if (hasPassword)
								server = RemoteServerInfo(id, serverObj["name"].GetString(), serverObj["description"].GetString(), serverObj["map"].GetString(), serverObj["playlist"].GetString(), serverObj["playerCount"].GetInt(), serverObj["maxPlayers"].GetInt());
							else
							{
								in_addr addr;
								addr.S_un.S_addr = serverObj["ip"].GetUint64();

								server = RemoteServerInfo(id, serverObj["name"].GetString(), serverObj["description"].GetString(), serverObj["map"].GetString(), serverObj["playlist"].GetString(), serverObj["playerCount"].GetInt(), serverObj["maxPlayers"].GetInt(), addr, serverObj["port"].GetInt());
							}

							createNewServerInfo = false;
							break;
						}
					}

					// server didn't exist
					if (createNewServerInfo)
					{
						// passworded servers shouldn't send ip/port
						if (hasPassword)
							m_remoteServers.emplace_back(id, serverObj["name"].GetString(), serverObj["description"].GetString(), serverObj["map"].GetString(), serverObj["playlist"].GetString(), serverObj["playerCount"].GetInt(), serverObj["maxPlayers"].GetInt());
						else
						{
							in_addr addr;
							addr.S_un.S_addr = serverObj["ip"].GetUint64();

							m_remoteServers.emplace_back(id, serverObj["name"].GetString(), serverObj["description"].GetString(), serverObj["map"].GetString(), serverObj["playlist"].GetString(), serverObj["playerCount"].GetInt(), serverObj["maxPlayers"].GetInt(), addr, serverObj["port"].GetInt());
						}
					}

					spdlog::info("Server {} on map {} with playlist {} has {}/{} players", serverObj["name"].GetString(), serverObj["map"].GetString(), serverObj["playlist"].GetString(), serverObj["playerCount"].GetInt(), serverObj["maxPlayers"].GetInt());
				}
			}
			else
			{
				spdlog::error("Failed requesting servers: error {}", result.error());
				m_successfullyConnected = false;
			}

			// we goto this instead of returning so we always hit this
			REQUEST_SERVER_LIST_END:
			m_requestingServerList = false;
			m_scriptRequestingServerList = false;
		});

	requestThread.detach();
}

void ConCommand_ns_fetchservers(const CCommand& args)
{
	g_MasterServerManager->RequestServerList();
}

void InitialiseSharedMasterServer(HMODULE baseAddress)
{
	Cvar_ns_masterserver_hostname = RegisterConVar("ns_masterserver_hostname", "localhost", FCVAR_NONE, "");
	Cvar_ns_masterserver_port = RegisterConVar("ns_masterserver_port", "8080", FCVAR_NONE, "");
	g_MasterServerManager = new MasterServerManager;

	RegisterConCommand("ns_fetchservers", ConCommand_ns_fetchservers, "", FCVAR_CLIENTDLL);
}