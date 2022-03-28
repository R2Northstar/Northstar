// dllmain.cpp : Defines the entry point for the DLL application.
#include "pch.h"
#include "dllmain.h"
#include <array>
#include <cassert>
#include <csignal>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <thread>
#include <vector>
#include <windows.h>
#include <chrono>

#include "library/discord.h"

#define DLLEXPORT __declspec(dllexport)
#include "plugin_abi.h" // Make sure you copy over plugin_abi.h from the NorthstarLauncher project before building

#if defined(_WIN32)
#pragma pack(push, 1)

struct BitmapImageHeader
{
	uint32_t const structSize{sizeof(BitmapImageHeader)};
	int32_t width{0};
	int32_t height{0};
	uint16_t const planes{1};
	uint16_t const bpp{32};
	uint32_t const pad0{0};
	uint32_t const pad1{0};
	uint32_t const hres{2835};
	uint32_t const vres{2835};
	uint32_t const pad4{0};
	uint32_t const pad5{0};

	BitmapImageHeader& operator=(BitmapImageHeader const&) = delete;
};

struct BitmapFileHeader
{
	uint8_t const magic0{'B'};
	uint8_t const magic1{'M'};
	uint32_t size{0};
	uint32_t const pad{0};
	uint32_t const offset{sizeof(BitmapFileHeader) + sizeof(BitmapImageHeader)};

	BitmapFileHeader& operator=(BitmapFileHeader const&) = delete;
};
#pragma pack(pop)
#endif

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}

struct DiscordState
{
	discord::User currentUser;

	std::unique_ptr<discord::Core> core;
};

namespace
{
volatile bool interrupted{false};
}

GameState* gameStatePtr = 0;
ServerInfo* serverInfoPtr = 0;
PlayerInfo* playerInfoPtr = 0;

void* (*getPluginData)(PluginObject);

extern "C" DLLEXPORT void initializePlugin(void* getPluginData_external)
{
	getPluginData = (void*(*)(PluginObject))getPluginData_external;
	gameStatePtr = (GameState*) getPluginData(PluginObject::GAMESTATE);
	serverInfoPtr = (ServerInfo*)getPluginData(PluginObject::SERVERINFO);
	playerInfoPtr = (PlayerInfo*)getPluginData(PluginObject::PLAYERINFO);
	std::thread discord(main, 0, (char**)0);
	discord.detach();
}

DiscordState state{};
bool wasInGame;

static struct PluginData
{
	char map[32];
	char mapDisplayName[64];
	char playlist[32];
	char playlistDisplayName[64];
	int players;
	int maxPlayers;
	bool loading;
	int ourScore;
	int secondHighestScore;
	int highestScore;
	int scoreLimit;
	int endTime;
} pluginData;

int main(int, char**)
{
	discord::Core* core{};
	auto result = discord::Core::Create(941428101429231617, DiscordCreateFlags_NoRequireDiscord, &core);
	state.core.reset(core);
	if (!state.core)
	{
		std::cout << "Failed to instantiate discord core! (err " << static_cast<int>(result) << ")\n";
		std::exit(-1);
	}
	std::cout << "Instantiated discord core!\n";

	state.core->SetLogHook(
		discord::LogLevel::Debug, [](discord::LogLevel level, const char* message)
		{ std::cerr << "Log(" << static_cast<uint32_t>(level) << "): " << message << "\n"; });

	discord::Activity activity{};

	const auto p1 = std::chrono::system_clock::now().time_since_epoch();
	activity.GetTimestamps().SetStart(std::chrono::duration_cast<std::chrono::seconds>(p1).count());

	

	activity.SetDetails("");
	activity.SetState("Loading...");
	activity.GetAssets().SetLargeImage("northstar");
	activity.GetAssets().SetLargeText("");
	activity.SetType(discord::ActivityType::Playing);

	activity.GetParty().GetSize().SetCurrentSize(4);
	activity.GetParty().GetSize().SetMaxSize(12);


	state.core->ActivityManager().UpdateActivity(
		activity,
		[](discord::Result result)
		{
			printf(((result == discord::Result::Ok) ? "Succeeded" : "Failed"));
			printf("\n");
		});

	std::signal(SIGINT, [](int) { interrupted = true; });

	 do
	{
		state.core->RunCallbacks();
		std::this_thread::sleep_for(std::chrono::milliseconds(100));

		std::string details = "Score: ";

		(*gameStatePtr).getGameStateChar(pluginData.playlist, sizeof(pluginData.playlist), GameStateInfoType::playlist);
		(*gameStatePtr).getGameStateChar(pluginData.playlistDisplayName, sizeof(pluginData.playlistDisplayName), GameStateInfoType::playlistDisplayName);
		(*gameStatePtr).getGameStateChar(pluginData.map, sizeof(pluginData.map), GameStateInfoType::map);
		(*gameStatePtr).getGameStateChar(pluginData.mapDisplayName, sizeof(pluginData.mapDisplayName), GameStateInfoType::mapDisplayName);
		(*gameStatePtr).getGameStateBool(&pluginData.loading, GameStateInfoType::loading);
		(*gameStatePtr).getGameStateInt(&pluginData.players, GameStateInfoType::players);
		(*serverInfoPtr).getServerInfoInt(&pluginData.maxPlayers, ServerInfoType::maxPlayers);


		activity.SetState(pluginData.playlistDisplayName);
		activity.GetAssets().SetLargeImage(pluginData.map);
		activity.GetAssets().SetLargeText(pluginData.mapDisplayName);
		if (!strncmp(pluginData.map, "", 1))
		{
			activity.GetParty().GetSize().SetCurrentSize(0);
			activity.GetParty().GetSize().SetMaxSize(0);
			activity.SetDetails("Main Menu");
			activity.SetState("On Main Menu");
			activity.GetAssets().SetLargeImage("northstar");
			activity.GetAssets().SetLargeText("Titanfall 2 + Northstar");
			activity.GetAssets().SetSmallImage("");
			activity.GetAssets().SetSmallText("");
			activity.GetTimestamps().SetEnd(0);
			if (wasInGame)
			{
				const auto p1 = std::chrono::system_clock::now().time_since_epoch();
				activity.GetTimestamps().SetStart(std::chrono::duration_cast<std::chrono::seconds>(p1).count());
				wasInGame = false;
			}
		}
		else if (!strncmp(pluginData.map, "mp_lobby", 9))
		{
			activity.SetState("In the Lobby");
			activity.GetParty().GetSize().SetCurrentSize(0);
			activity.GetParty().GetSize().SetMaxSize(0);
			activity.SetDetails("Lobby");
			activity.GetAssets().SetLargeImage("northstar");
			activity.GetAssets().SetLargeText("Titanfall 2 + Northstar");
			activity.GetAssets().SetSmallImage("");
			activity.GetAssets().SetSmallText("");
			activity.GetTimestamps().SetEnd(0);
			if (wasInGame)
			{
				const auto p1 = std::chrono::system_clock::now().time_since_epoch();
				activity.GetTimestamps().SetStart(std::chrono::duration_cast<std::chrono::seconds>(p1).count());
				wasInGame = false;
			}
		}
		else
		{
			if (!pluginData.loading)
			{
				activity.GetParty().GetSize().SetCurrentSize(pluginData.players);
				activity.GetParty().GetSize().SetMaxSize(pluginData.maxPlayers);
				(*gameStatePtr).getGameStateInt(&pluginData.ourScore, GameStateInfoType::ourScore);
				(*gameStatePtr).getGameStateInt(&pluginData.secondHighestScore, GameStateInfoType::secondHighestScore);
				(*gameStatePtr).getGameStateInt(&pluginData.highestScore, GameStateInfoType::highestScore);
				(*serverInfoPtr).getServerInfoInt(&pluginData.scoreLimit, ServerInfoType::scoreLimit);
				(*serverInfoPtr).getServerInfoInt(&pluginData.endTime, ServerInfoType::endTime);
				(*gameStatePtr).getGameStateChar(pluginData.playlistDisplayName, sizeof(pluginData.playlistDisplayName), GameStateInfoType::playlistDisplayName);
				activity.SetState(pluginData.playlistDisplayName);
				if (pluginData.ourScore == pluginData.highestScore)
				{
					details += std::to_string(pluginData.ourScore) + " - " + std::to_string(pluginData.secondHighestScore);
				}
				else
				{
					details += std::to_string(pluginData.ourScore) + " - " + std::to_string(pluginData.highestScore);
				}

				details += " (First to " + std::to_string(pluginData.scoreLimit) + ")";
				activity.SetDetails(details.c_str());
				const auto p1 = std::chrono::system_clock::now().time_since_epoch();
				if (pluginData.endTime > 0) {
					activity.GetTimestamps().SetEnd(std::chrono::duration_cast<std::chrono::seconds>(p1).count() + pluginData.endTime);
					activity.GetTimestamps().SetStart(0);
				}
				wasInGame = true;
			}
			else
			{
				activity.GetParty().GetSize().SetCurrentSize(0);
				activity.GetParty().GetSize().SetMaxSize(0);
				activity.SetDetails("Loading...");
				if (wasInGame) {
					wasInGame = false;
				}
			}
		}


		state.core->ActivityManager().UpdateActivity(
			activity, [](discord::Result result){});

	} while (!interrupted);

	return 0;
}