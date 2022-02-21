#pragma once
#include "pch.h"
#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>

enum class CustomMessageType : char
{
	Chat = 1,
	Whisper = 2
};

constexpr unsigned char CUSTOM_MESSAGE_INDEX_BIT = 0b10000000;
constexpr unsigned char CUSTOM_MESSAGE_INDEX_MASK = ~CUSTOM_MESSAGE_INDEX_BIT;

// Send a vanilla chat message as if it was from the player.
void ChatSendMessage(unsigned int playerIndex, const char* text, bool isteam);

// Send a custom message.
//   fromPlayerIndex: set to -1 for a [SERVER] message, or another value to send from a specific player
//   toPlayerIndex: set to -1 to send to all players, or another value to send to a single player
//   isTeam: display a [TEAM] badge
//   isDead: display a [DEAD] badge
//   messageType: send a specific message type
void ChatBroadcastMessage(
	int fromPlayerIndex, int toPlayerIndex, const char* text, bool isTeam, bool isDead, CustomMessageType messageType);

void InitialiseServerChatHooks_Engine(HMODULE baseAddress);

void InitialiseServerChatHooks_Server(HMODULE baseAddress);
