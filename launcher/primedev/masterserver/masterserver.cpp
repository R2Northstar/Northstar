#include "masterserver.h"
#include <cstddef>
#include <optional>

#include "rapidjson/document.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/writer.h"
#include "rapidjson/error/en.h"

auto MasterServerManager::ServerHandleConnectionlessPacket(std::span<uint8_t> buf) -> void {}

template <typename func> auto MasterServerManager::ServerSetAuthCallback(func callback) -> void {}
// prepares the server to receive a player
// func is of type void void (*func)(ServerConnect)
template <typename func> auto ServerSetConnectCallback(func callback) -> void {}

// updates server presence
auto MasterServerManager::ServerUpdate(ServerState state) -> void {}

// deletes server presence
// TODO: return an error somehow?
auto MasterServerManager::ServerRemove() -> void {}

// sets the current client uid (not verified or authed until a request)
auto MasterServerManager::ClientSetUID(uint64_t uid) -> void {}

// sets the callback to get a new origin token
// func is of type void void (*func)(std::variant<std::string, some error type>)
template <typename func> void MasterServerManager::ClientSetOriginCallback(func callback) {}

// locks and gets pdata for the current uid
auto MasterServerManager::ClientGetPdata() -> std::variant<std::vector<uint8_t>, MasterServerManager> {}

auto MasterServerManager::ClientResetPdata() -> void {}

auto MasterServerManager::ClientConnect(std::string serverID) -> std::future<std::variant<ClientConnectInfo, MasterServerErrorCode>> {}

// write pdata if we have a lock, returns an error otherwise
// TODO: return an error somehow?
auto MasterServerManager::WritePdata(uint64_t uid, std::span<uint8_t> pdata) -> std::optional<MasterServerErrorCode> {}

// gets the server list
auto MasterServerManager::GetServerList() -> std::future<std::variant<std::vector<ServerInfo>, MasterServerErrorCode>> {}

// fetches the main menu promos
auto MasterServerManager::FetchMainMenuPromo() -> void
{
	switch (this->m_eMainMenuState)
	{
	case MenuPromoState::Available:
	case MenuPromoState::Missing:
		break;
	case MenuPromoState::Fetching:
		break;
	}
}

auto MasterServerManager::GetMainMenuPromo() -> std::optional<const MainMenuPromoData*>
{
	switch (this->m_eMainMenuState)
	{
	case MenuPromoState::Available:
		return std::make_optional(&this->m_sMainMenuPromoData);
	case MenuPromoState::Fetching:
	case MenuPromoState::Missing:
		break;
	}
	return std::nullopt;
}
