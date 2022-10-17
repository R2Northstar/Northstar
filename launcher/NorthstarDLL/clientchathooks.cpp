#include "pch.h"
#include "squirrel.h"
#include "serverchathooks.h"
#include "localchatwriter.h"

#include <rapidjson/document.h>

AUTOHOOK_INIT()

// clang-format off
AUTOHOOK(CHudChat__AddGameLine, client.dll + 0x22E580,
void, __fastcall, (void* self, const char* message, int inboxId, bool isTeam, bool isDead))
// clang-format on
{
	// This hook is called for each HUD, but we only want our logic to run once.
	if (self != *CHudChat::allHuds)
		return;

	if (g_pSquirrel<ScriptContext::CLIENT>->setupfunc("CHudChat_ProcessMessageStartThread") != SQRESULT_ERROR)
	{
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

		g_pSquirrel<ScriptContext::CLIENT>->pushinteger(g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM->sqvm, (int)senderId - 1);
		g_pSquirrel<ScriptContext::CLIENT>->pushstring(g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM->sqvm, payload);
		g_pSquirrel<ScriptContext::CLIENT>->pushbool(g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM->sqvm, isTeam);
		g_pSquirrel<ScriptContext::CLIENT>->pushbool(g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM->sqvm, isDead);
		g_pSquirrel<ScriptContext::CLIENT>->pushinteger(g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM->sqvm, type);
		g_pSquirrel<ScriptContext::CLIENT>->call(g_pSquirrel<ScriptContext::CLIENT>->m_pSQVM->sqvm, 5);
	}
	else
		for (CHudChat* hud = *CHudChat::allHuds; hud != NULL; hud = hud->next)
			CHudChat__AddGameLine(hud, message, inboxId, isTeam, isDead);
}

// void NSChatWrite( int context, string str )
SQRESULT SQ_ChatWrite(HSquirrelVM* sqvm)
{
	int context = g_pSquirrel<ScriptContext::CLIENT>->getinteger(sqvm, 1);
	const char* str = g_pSquirrel<ScriptContext::CLIENT>->getstring(sqvm, 2);

	LocalChatWriter((LocalChatWriter::Context)context).Write(str);
	return SQRESULT_NULL;
}

// void NSChatWriteRaw( int context, string str )
SQRESULT SQ_ChatWriteRaw(HSquirrelVM* sqvm)
{
	int context = g_pSquirrel<ScriptContext::CLIENT>->getinteger(sqvm, 1);
	const char* str = g_pSquirrel<ScriptContext::CLIENT>->getstring(sqvm, 2);

	LocalChatWriter((LocalChatWriter::Context)context).InsertText(str);
	return SQRESULT_NULL;
}

// void NSChatWriteLine( int context, string str )
SQRESULT SQ_ChatWriteLine(HSquirrelVM* sqvm)
{
	int context = g_pSquirrel<ScriptContext::CLIENT>->getinteger(sqvm, 1);
	const char* str = g_pSquirrel<ScriptContext::CLIENT>->getstring(sqvm, 2);

	LocalChatWriter((LocalChatWriter::Context)context).WriteLine(str);
	return SQRESULT_NULL;
}

ON_DLL_LOAD_CLIENT_RELIESON("client.dll", ClientChatHooks, ClientSquirrel, (CModule module))
{
	AUTOHOOK_DISPATCH()

	g_pSquirrel<ScriptContext::CLIENT>->AddFuncRegistration("void", "NSChatWrite", "int context, string text", "", SQ_ChatWrite);
	g_pSquirrel<ScriptContext::CLIENT>->AddFuncRegistration("void", "NSChatWriteRaw", "int context, string text", "", SQ_ChatWriteRaw);
	g_pSquirrel<ScriptContext::CLIENT>->AddFuncRegistration("void", "NSChatWriteLine", "int context, string text", "", SQ_ChatWriteLine);
}
