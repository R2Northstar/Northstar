#pragma once

#include "tier1/convar.h"
#include "server/serverpresence.h"
#include <concepts>
#include <cstdint>
#include <memory>
#include <optional>
#include <span>
#include <variant>
#include <vector>
#include <winhttp.h>
#include <winsock2.h>
#include <string>
#include <cstring>
#include <expected>
#include <future>
#include <unordered_set>

extern ConVar* Cvar_ns_masterserver_hostname;
extern ConVar* Cvar_ns_curl_log_enable;

struct RemoteModInfo
{
public:
	std::string Name;
	std::string Version;
};

// class ServerState
// {
// public:
// 	char id[33]; // 32 bytes + nullterminator

// 	// server info
// 	char name[64];
// 	std::string description;
// 	char map[32];
// 	char playlist[16];
// 	char region[32];
// 	std::vector<RemoteModInfo> requiredMods;

// 	int playerCount;
// 	int maxPlayers;

// 	// connection stuff
// 	bool requiresPassword;
// };

struct RemoteServerConnectionInfo
{
public:
	char authToken[32];

	in_addr ip;
	unsigned short port;
};

class ServerAuth
{
	in_addr ip;
	uint64_t uid;
	std::string password;
};

class ServerConnect
{
	std::string token;
	std::vector<uint8_t> pdata;
};

class ServerState
{
	std::string name;
	std::string description;
	bool hasPassword;
	uint16_t port;
	// TODO
};

class ServerInfo
{
	std::string id;
	std::string name;
	// TODO
};

class ClientConnectInfo
{
	in_addr ip;
	uint16_t port;
	std::string token;
};

struct MainMenuPromoData
{
public:
	std::string newInfoTitle1;
	std::string newInfoTitle2;
	std::string newInfoTitle3;

	std::string largeButtonTitle;
	std::string largeButtonText;
	std::string largeButtonUrl;
	int largeButtonImageIndex;

	std::string smallButton1Title;
	std::string smallButton1Url;
	int smallButton1ImageIndex;

	std::string smallButton2Title;
	std::string smallButton2Url;
	int smallButton2ImageIndex;
};

enum class MasterServerErrorCode
{
	session_expired = 40124, // must get a new session token (expired/invalid)
	player_auth_req = 401, // must player (e.g., origin) auth (expired/invalid)
	server_auth_req = 401, // must server auth (expired/invalid)
	not_found = 404, // server: must = r, //register server (or can't connect to one); pdata: player doesn't have saved pdata
	invalid_pdata_lock = 423, // took too long to update pdata, or lock was otherwise lost
	no_server_response = 504, // server did not reply to connectionless packet in time
	ns_update_required = 403, // northstar is too old
	bad_request = 402, // obvious
	server_connection_rejected = 403, // server rejected connection
	internal_error = 500, // internal atlas error, shouldn't happen normally
	error = 500, // generic error
	stryder_auth_rejected = 403, // invalid stryder token
	extra_verification_required = 401, // captcha, etc (will have link to open in browser) (note: can handle this with a proxy in front of
									   // atlas since all protected requests have session tokens)
};

enum class MenuPromoState
{
	Fetching,
	Available,
	Missing,
}

class MasterServerManager
{
private:
	bool m_bRequestingServerList = false;
	bool m_bAuthenticatingWithGameServer = false;

	MenuPromoState m_eMainMenuState = MenuPromoState::Missing;
	MainMenuPromoData m_sMainMenuPromoData;

public:
	char m_sOwnServerId[33];
	char m_sOwnServerAuthToken[33];
	char m_sOwnClientAuthToken[33];

	std::string m_sOwnModInfoJson;

	bool m_bOriginAuthWithMasterServerDone = false;
	bool m_bOriginAuthWithMasterServerInProgress = false;

	bool m_bOriginAuthWithMasterServerSuccessful = false;
	std::string m_sOriginAuthWithMasterServerErrorCode = "";
	std::string m_sOriginAuthWithMasterServerErrorMessage = "";

	bool m_bSavingPersistentData = false;

	bool m_bScriptRequestingServerList = false;
	bool m_bSuccessfullyConnected = true;

	bool m_bNewgameAfterSelfAuth = false;
	bool m_bScriptAuthenticatingWithGameServer = false;
	bool m_bSuccessfullyAuthenticatedWithGameServer = false;
	std::string m_sAuthFailureReason {};

	bool m_bHasPendingConnectionInfo = false;
	RemoteServerConnectionInfo m_pendingConnectionInfo;

	std::vector<ServerState> m_vRemoteServers;

	std::optional<ServerState> m_currentServer;
	std::string m_sCurrentServerPassword;

	std::unordered_set<std::string> m_handledServerConnections;
	std::mutex m_handledServerConnectionsMutex;

public:
	MasterServerManager();

	// run handling code in a thread
	auto HandleConnectionlessPacket(std::span<uint8_t> buf) -> void;
	// pass hooked connectionless packets to this
	void ServerHandleConnectionlessPacket(std::span<uint8_t> buf);
	// checks whether to accept a player connection
	// func is of type void (*func)(ServerAuth)
	template <class F> void ServerSetAuthCallback(F callback)
		requires std::invocable<F, ServerAuth>;
	// prepares the server to receive a player
	// func is of type void void (*func)(ServerConnect)
	template <class F> void ServerSetConnectCallback(F callback)
		requires std::invocable<F, ServerConnect>;

	// updates server presence
	void ServerUpdate(ServerState state);

	// deletes server presence
	void ServerRemove();

	// sets the current client uid (not verified or authed until a request)
	void ClientSetUID(uint64_t uid);

	// sets the callback to get a new origin token
	// func is of type void void (*func)(std::expected<std::string, some error type>)
	template <class F> void ClientSetOriginCallback(F callback)
		requires std::invocable<F, std::expected<std::string, std::string>>;

	// locks and gets pdata for the current uid
	std::expected<std::vector<uint8_t>, MasterServerManager> ClientGetPdata();

	// resets server-side pdata for the current uid (should usually call ClientGetPdata after)
	void ClientResetPdata();

	// sends a connection request to a server
	std::future<std::expected<ClientConnectInfo, MasterServerErrorCode>> ClientConnect(std::string serverID);

	// write pdata if we have a lock, returns an error otherwise
	std::expected<void, MasterServerErrorCode> WritePdata(uint64_t uid, std::span<uint8_t> pdata);

	// gets the server list
	std::future<std::expected<std::vector<ServerInfo>, MasterServerErrorCode>> GetServerList();

	// fetches the main menu promos
	void FetchMainMenuPromo();

	//
	std::optional<const MainMenuPromoData*> GetMainMenuPromo();

private:
	// verify connectionless packet
	std::string VerifyConnectionlessPacket(std::span<uint8_t> buf);

	// run handling code in a thread
	void HandleConnectionlessPacket(std::span<uint8_t> buf);
};

extern MasterServerManager* g_pMasterServerManager;
extern ConVar* Cvar_ns_masterserver_hostname;

/** Result returned in the std::future of a MasterServerPresenceReporter::ReportPresence() call. */
enum class MasterServerReportPresenceResult
{
	// Adding this server to the MS was successful.
	Success,
	// We failed to add this server to the MS and should retry.
	Failed,
	// We failed to add this server to the MS and shouldn't retry.
	FailedNoRetry,
	// We failed to even reach the MS.
	FailedNoConnect,
	// We failed to add the server because an existing server with the same ip:port exists.
	FailedDuplicateServer,
};

class MasterServerPresenceReporter : public ServerPresenceReporter
{
public:
	/** Full data returned in the std::future of a MasterServerPresenceReporter::ReportPresence() call. */
	struct ReportPresenceResultData
	{
		MasterServerReportPresenceResult result;

		std::optional<std::string> id;
		std::optional<std::string> serverAuthToken;
	};

	const int MAX_REGISTRATION_ATTEMPTS = 5;

	// Called to initialise the master server presence reporter's state.
	void CreatePresence(const ServerPresence* pServerPresence) override;

	// Run on an internal to either add the server to the MS or update it.
	void ReportPresence(const ServerPresence* pServerPresence) override;

	// Called when we need to remove the server from the master server.
	void DestroyPresence(const ServerPresence* pServerPresence) override;

	// Called every frame.
	void RunFrame(double flCurrentTime, const ServerPresence* pServerPresence) override;

protected:
	// Contains the async logic to add the server to the MS.
	void InternalAddServer(const ServerPresence* pServerPresence);

	// Contains the async logic to update the server on the MS.
	void InternalUpdateServer(const ServerPresence* pServerPresence);

	// The future used for InternalAddServer() calls.
	std::future<ReportPresenceResultData> addServerFuture;

	// The future used for InternalAddServer() calls.
	std::future<ReportPresenceResultData> updateServerFuture;

	int m_nNumRegistrationAttempts;

	double m_fNextAddServerAttemptTime;
};
