#include "serverchathooks.h"
#include "shared/exploit_fixes/ns_limits.h"
#include "squirrel/squirrel.h"
#include "server/r2server.h"
#include "util/utils.h"

#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

class CServerGameDLL;

class CRecipientFilter
{
	char unknown[58];
};

CServerGameDLL* g_pServerGameDLL;

void(__fastcall* CRecipientFilter__Construct)(CRecipientFilter* self);
void(__fastcall* CRecipientFilter__Destruct)(CRecipientFilter* self);
void(__fastcall* CRecipientFilter__AddAllPlayers)(CRecipientFilter* self);
void(__fastcall* CRecipientFilter__AddRecipient)(CRecipientFilter* self, const CBasePlayer* player);
void(__fastcall* CRecipientFilter__MakeReliable)(CRecipientFilter* self);

void(__fastcall* UserMessageBegin)(CRecipientFilter* filter, const char* messagename);
void(__fastcall* MessageEnd)();
void(__fastcall* MessageWriteByte)(int iValue);
void(__fastcall* MessageWriteString)(const char* sz);
void(__fastcall* MessageWriteBool)(bool bValue);

bool bShouldCallSayTextHook = false;

static void(__fastcall* o_pCServerGameDLL__OnReceivedSayTextMessage)(
	CServerGameDLL* self, unsigned int senderPlayerId, const char* text, bool isTeam) = nullptr;
static void __fastcall h_CServerGameDLL__OnReceivedSayTextMessage(
	CServerGameDLL* self, unsigned int senderPlayerId, const char* text, bool isTeam)
{
	RemoveAsciiControlSequences(const_cast<char*>(text), true);

	// MiniHook doesn't allow calling the base function outside of anywhere but the hook function.
	// To allow bypassing the hook, isSkippingHook can be set.
	if (bShouldCallSayTextHook)
	{
		bShouldCallSayTextHook = false;
		o_pCServerGameDLL__OnReceivedSayTextMessage(self, senderPlayerId, text, isTeam);
		return;
	}

	// check chat ratelimits
	if (!g_pServerLimits->CheckChatLimits(&g_pClientArray[senderPlayerId - 1]))
		return;

	SQRESULT result = g_pSquirrel<ScriptContext::SERVER>->Call(
		"CServerGameDLL_ProcessMessageStartThread", static_cast<int>(senderPlayerId) - 1, text, isTeam);

	if (result == SQRESULT_ERROR)
		o_pCServerGameDLL__OnReceivedSayTextMessage(self, senderPlayerId, text, isTeam);
}

void ChatSendMessage(unsigned int playerIndex, const char* text, bool isTeam)
{
	bShouldCallSayTextHook = true;
	h_CServerGameDLL__OnReceivedSayTextMessage(
		g_pServerGameDLL,
		// Ensure the first bit isn't set, since this indicates a custom message
		(playerIndex + 1) & CUSTOM_MESSAGE_INDEX_MASK,
		text,
		isTeam);
}

void ChatBroadcastMessage(int fromPlayerIndex, int toPlayerIndex, const char* text, bool isTeam, bool isDead, CustomMessageType messageType)
{
	CBasePlayer* toPlayer = NULL;
	if (toPlayerIndex >= 0)
	{
		toPlayer = UTIL_PlayerByIndex(toPlayerIndex + 1);
		if (toPlayer == NULL)
			return;
	}

	// Build a new string where the first byte is the message type
	char sendText[256];
	sendText[0] = (char)messageType;
	strncpy_s(sendText + 1, 255, text, 254);

	// Anonymous custom messages use playerId=0, non-anonymous ones use a player ID with the first bit set
	unsigned int fromPlayerId = fromPlayerIndex < 0 ? 0 : ((fromPlayerIndex + 1) | CUSTOM_MESSAGE_INDEX_BIT);

	CRecipientFilter filter;
	CRecipientFilter__Construct(&filter);
	if (toPlayer == NULL)
	{
		CRecipientFilter__AddAllPlayers(&filter);
	}
	else
	{
		CRecipientFilter__AddRecipient(&filter, toPlayer);
	}
	CRecipientFilter__MakeReliable(&filter);

	UserMessageBegin(&filter, "SayText");
	MessageWriteByte(fromPlayerId);
	MessageWriteString(sendText);
	MessageWriteBool(isTeam);
	MessageWriteBool(isDead);
	MessageEnd();

	CRecipientFilter__Destruct(&filter);
}

ADD_SQFUNC("void", NSSendMessage, "int playerIndex, string text, bool isTeam", "", ScriptContext::SERVER)
{
	int playerIndex = g_pSquirrel<ScriptContext::SERVER>->getinteger(sqvm, 1);
	const char* text = g_pSquirrel<ScriptContext::SERVER>->getstring(sqvm, 2);
	bool isTeam = g_pSquirrel<ScriptContext::SERVER>->getbool(sqvm, 3);

	ChatSendMessage(playerIndex, text, isTeam);

	return SQRESULT_NULL;
}

ADD_SQFUNC(
	"void",
	NSBroadcastMessage,
	"int fromPlayerIndex, int toPlayerIndex, string text, bool isTeam, bool isDead, int messageType",
	"",
	ScriptContext::SERVER)
{
	int fromPlayerIndex = g_pSquirrel<ScriptContext::SERVER>->getinteger(sqvm, 1);
	int toPlayerIndex = g_pSquirrel<ScriptContext::SERVER>->getinteger(sqvm, 2);
	const char* text = g_pSquirrel<ScriptContext::SERVER>->getstring(sqvm, 3);
	bool isTeam = g_pSquirrel<ScriptContext::SERVER>->getbool(sqvm, 4);
	bool isDead = g_pSquirrel<ScriptContext::SERVER>->getbool(sqvm, 5);
	int messageType = g_pSquirrel<ScriptContext::SERVER>->getinteger(sqvm, 6);

	if (messageType < 1)
	{
		g_pSquirrel<ScriptContext::SERVER>->raiseerror(sqvm, fmt::format("Invalid message type {}", messageType).c_str());
		return SQRESULT_ERROR;
	}

	ChatBroadcastMessage(fromPlayerIndex, toPlayerIndex, text, isTeam, isDead, (CustomMessageType)messageType);

	return SQRESULT_NULL;
}

ON_DLL_LOAD("engine.dll", EngineServerChatHooks, (CModule module))
{
	g_pServerGameDLL = module.Offset(0x13F0AA98).RCast<CServerGameDLL*>();
}

ON_DLL_LOAD_RELIESON("server.dll", ServerChatHooks, ServerSquirrel, (CModule module))
{
	o_pCServerGameDLL__OnReceivedSayTextMessage = module.Offset(0x1595C0).RCast<decltype(o_pCServerGameDLL__OnReceivedSayTextMessage)>();
	HookAttach(&(PVOID&)o_pCServerGameDLL__OnReceivedSayTextMessage, (PVOID)h_CServerGameDLL__OnReceivedSayTextMessage);

	CRecipientFilter__Construct = module.Offset(0x1E9440).RCast<void(__fastcall*)(CRecipientFilter*)>();
	CRecipientFilter__Destruct = module.Offset(0x1E9700).RCast<void(__fastcall*)(CRecipientFilter*)>();
	CRecipientFilter__AddAllPlayers = module.Offset(0x1E9940).RCast<void(__fastcall*)(CRecipientFilter*)>();
	CRecipientFilter__AddRecipient = module.Offset(0x1E9B30).RCast<void(__fastcall*)(CRecipientFilter*, const CBasePlayer*)>();
	CRecipientFilter__MakeReliable = module.Offset(0x1EA4E0).RCast<void(__fastcall*)(CRecipientFilter*)>();

	UserMessageBegin = module.Offset(0x15C520).RCast<void(__fastcall*)(CRecipientFilter*, const char*)>();
	MessageEnd = module.Offset(0x158880).RCast<void(__fastcall*)()>();
	MessageWriteByte = module.Offset(0x158A90).RCast<void(__fastcall*)(int)>();
	MessageWriteString = module.Offset(0x158D00).RCast<void(__fastcall*)(const char*)>();
	MessageWriteBool = module.Offset(0x158A00).RCast<void(__fastcall*)(bool)>();
}
