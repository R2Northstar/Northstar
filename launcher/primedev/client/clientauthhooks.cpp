#include "masterserver/masterserver.h"
#include "core/convar/convar.h"
#include "client/r2client.h"
#include "core/vanilla.h"

ConVar* Cvar_ns_has_agreed_to_send_token;

// mirrored in script
const int NOT_DECIDED_TO_SEND_TOKEN = 0;
const int AGREED_TO_SEND_TOKEN = 1;
const int DISAGREED_TO_SEND_TOKEN = 2;

static void (*__fastcall o_pAuthWithStryder)(void* a1) = nullptr;
static void __fastcall h_AuthWithStryder(void* a1)
{
	// don't attempt to do Atlas auth if we are in vanilla compatibility mode
	// this prevents users from joining untrustworthy servers (unless they use a concommand or something)
	if (g_pVanillaCompatibility->GetVanillaCompatibility())
	{
		o_pAuthWithStryder(a1);
		return;
	}

	// game will call this forever, until it gets a valid auth key
	// so, we need to manually invalidate our key until we're authed with northstar, then we'll allow game to auth with stryder
	if (!g_pMasterServerManager->m_bOriginAuthWithMasterServerDone && Cvar_ns_has_agreed_to_send_token->GetInt() != DISAGREED_TO_SEND_TOKEN)
	{
		// if player has agreed to send token and we aren't already authing, try to auth
		if (Cvar_ns_has_agreed_to_send_token->GetInt() == AGREED_TO_SEND_TOKEN &&
			!g_pMasterServerManager->m_bOriginAuthWithMasterServerInProgress)
			g_pMasterServerManager->AuthenticateOriginWithMasterServer(g_pLocalPlayerUserID, g_pLocalPlayerOriginToken);

		// invalidate key so auth will fail
		*g_pLocalPlayerOriginToken = 0;
	}

	o_pAuthWithStryder(a1);
}

char* p3PToken;

static char* (*__fastcall o_pAuth3PToken)() = nullptr;
static char* __fastcall h_Auth3PToken()
{
	if (!g_pVanillaCompatibility->GetVanillaCompatibility() && g_pMasterServerManager->m_sOwnClientAuthToken[0])
	{
		memset(p3PToken, 0x0, 1024);
		strcpy(p3PToken, "Protocol 3: Protect the Pilot");
	}

	return o_pAuth3PToken();
}

ON_DLL_LOAD_CLIENT_RELIESON("engine.dll", ClientAuthHooks, ConVar, (CModule module))
{
	o_pAuthWithStryder = module.Offset(0x1843A0).RCast<decltype(o_pAuthWithStryder)>();
	HookAttach(&(PVOID&)o_pAuthWithStryder, (PVOID)h_AuthWithStryder);

	o_pAuth3PToken = module.Offset(0x183760).RCast<decltype(o_pAuth3PToken)>();
	HookAttach(&(PVOID&)o_pAuth3PToken, (PVOID)h_Auth3PToken);

	p3PToken = module.Offset(0x13979D80).RCast<char*>();

	// this cvar will save to cfg once initially agreed with
	Cvar_ns_has_agreed_to_send_token = new ConVar(
		"ns_has_agreed_to_send_token",
		"0",
		FCVAR_ARCHIVE_PLAYERPROFILE,
		"whether the user has agreed to send their origin token to the northstar masterserver");
}
