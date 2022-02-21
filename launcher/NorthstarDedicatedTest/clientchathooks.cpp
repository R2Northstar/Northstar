#include "pch.h"
#include "clientchathooks.h"
#include <rapidjson/document.h>
#include "squirrel.h"
#include "serverchathooks.h"
#include "localchatwriter.h"

typedef void(__fastcall* CHudChat__AddGameLineType)(void* self, const char* message, int fromPlayerId, bool isteam, bool isdead);
CHudChat__AddGameLineType CHudChat__AddGameLine;

struct ChatTags
{
	bool whisper;
	bool team;
	bool dead;
};

static void CHudChat__AddGameLineHook(void* self, const char* message, int inboxId, bool isTeam, bool isDead)
{
	// This hook is called for each HUD, but we only want our logic to run once.
	if (!IsFirstHud(self))
	{
		return;
	}

	int senderId = inboxId & CUSTOM_MESSAGE_INDEX_MASK;
	bool isAnonymous = senderId == 0;
	bool isCustom = isAnonymous || (inboxId & CUSTOM_MESSAGE_INDEX_BIT);

	// Type is set to 0 for non-custom messages, custom messages have a type encoded as the first byte
	int type = 0;
	const char* payload = message;
	if (isCustom)
	{
		type = message[0];
		payload = message + 1;
	}

	g_ClientSquirrelManager->setupfunc("CHudChat_ProcessMessageStartThread");
	g_ClientSquirrelManager->pusharg((int)senderId - 1);
	g_ClientSquirrelManager->pusharg(payload);
	g_ClientSquirrelManager->pusharg(isTeam);
	g_ClientSquirrelManager->pusharg(isDead);
	g_ClientSquirrelManager->pusharg(type);
	g_ClientSquirrelManager->call(5);
}

// void NSChatWrite( int context, string str )
static SQRESULT SQ_ChatWrite(void* sqvm)
{
	int context = ClientSq_getinteger(sqvm, 1);
	const char* str = ClientSq_getstring(sqvm, 2);

	LocalChatWriter((LocalChatWriter::Context)context).Write(str);
	return SQRESULT_NOTNULL;
}

// void NSChatWriteRaw( int context, string str )
static SQRESULT SQ_ChatWriteRaw(void* sqvm)
{
	int context = ClientSq_getinteger(sqvm, 1);
	const char* str = ClientSq_getstring(sqvm, 2);

	LocalChatWriter((LocalChatWriter::Context)context).InsertText(str);
	return SQRESULT_NOTNULL;
}

// void NSChatWriteLine( int context, string str )
static SQRESULT SQ_ChatWriteLine(void* sqvm)
{
	int context = ClientSq_getinteger(sqvm, 1);
	const char* str = ClientSq_getstring(sqvm, 2);

	LocalChatWriter((LocalChatWriter::Context)context).WriteLine(str);
	return SQRESULT_NOTNULL;
}

void InitialiseClientChatHooks(HMODULE baseAddress)
{
	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x22E580, &CHudChat__AddGameLineHook, reinterpret_cast<LPVOID*>(&CHudChat__AddGameLine));

	g_ClientSquirrelManager->AddFuncRegistration("void", "NSChatWrite", "int context, string text", "", SQ_ChatWrite);
	g_ClientSquirrelManager->AddFuncRegistration("void", "NSChatWriteRaw", "int context, string text", "", SQ_ChatWriteRaw);
	g_ClientSquirrelManager->AddFuncRegistration("void", "NSChatWriteLine", "int context, string text", "", SQ_ChatWriteLine);
}
