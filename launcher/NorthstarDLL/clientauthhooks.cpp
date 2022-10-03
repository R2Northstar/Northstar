#include "pch.h"
#include "clientauthhooks.h"
#include "hookutils.h"
#include "gameutils.h"
#include "masterserver.h"
#include "convar.h"

typedef void (*AuthWithStryderType)(void* a1);
AuthWithStryderType AuthWithStryder;

ConVar* Cvar_ns_has_agreed_to_send_token;

// mirrored in script
const int NOT_DECIDED_TO_SEND_TOKEN = 0;
const int AGREED_TO_SEND_TOKEN = 1;
const int DISAGREED_TO_SEND_TOKEN = 2;

typedef char* (*Auth3PTokenType)();
Auth3PTokenType Auth3PToken;

char* token_location = 0x0;

void AuthWithStryderHook(void* a1)
{
	// game will call this forever, until it gets a valid auth key
	// so, we need to manually invalidate our key until we're authed with northstar, then we'll allow game to auth with stryder
	if (!g_MasterServerManager->m_bOriginAuthWithMasterServerDone && Cvar_ns_has_agreed_to_send_token->GetInt() != DISAGREED_TO_SEND_TOKEN)
	{
		// if player has agreed to send token and we aren't already authing, try to auth
		if (Cvar_ns_has_agreed_to_send_token->GetInt() == AGREED_TO_SEND_TOKEN &&
			!g_MasterServerManager->m_bOriginAuthWithMasterServerInProgress)
			g_MasterServerManager->AuthenticateOriginWithMasterServer(g_LocalPlayerUserID, g_LocalPlayerOriginToken);

		// invalidate key so auth will fail
		*g_LocalPlayerOriginToken = 0;
	}

	AuthWithStryder(a1);
}

char* Auth3PTokenHook()
{
	if (g_MasterServerManager->m_sOwnClientAuthToken[0] != 0)
	{
		memset(token_location, 0x0, 1024);
		strcpy(token_location, "Protocol 3: Protect the Pilot");
	}

	return Auth3PToken();
}

void InitialiseClientAuthHooks(HMODULE baseAddress)
{
	// this cvar will save to cfg once initially agreed with
	Cvar_ns_has_agreed_to_send_token = new ConVar(
		"ns_has_agreed_to_send_token",
		"0",
		FCVAR_ARCHIVE_PLAYERPROFILE,
		"whether the user has agreed to send their origin token to the northstar masterserver");

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x1843A0, &AuthWithStryderHook, reinterpret_cast<LPVOID*>(&AuthWithStryder));
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x183760, &Auth3PTokenHook, reinterpret_cast<LPVOID*>(&Auth3PToken));
	token_location = (char*)baseAddress + 0x13979D80;
}
