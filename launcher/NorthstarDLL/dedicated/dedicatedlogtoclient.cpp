#include "pch.h"
#include "dedicatedlogtoclient.h"
#include "engine/r2engine.h"

void (*CGameClient__ClientPrintf)(R2::CBaseClient* pClient, const char* fmt, ...);

void DedicatedServerLogToClientSink::custom_sink_it_(const custom_log_msg& msg)
{
	if (*R2::g_pServerState == R2::server_state_t::ss_dead)
		return;

	enum class eSendPrintsToClient
	{
		NONE = -1,
		FIRST,
		ALL
	};

	static const ConVar* Cvar_dedi_sendPrintsToClient = R2::g_pCVar->FindVar("dedi_sendPrintsToClient");
	eSendPrintsToClient eSendPrints = static_cast<eSendPrintsToClient>(Cvar_dedi_sendPrintsToClient->GetInt());
	if (eSendPrints == eSendPrintsToClient::NONE)
		return;

	std::string sLogMessage = fmt::format("[DEDICATED SERVER] [{}] {}", level_names[msg.level], msg.payload);
	for (int i = 0; i < R2::g_pGlobals->m_nMaxClients; i++)
	{
		R2::CBaseClient* pClient = &R2::g_pClientArray[i];

		if (pClient->m_Signon >= R2::eSignonState::CONNECTED)
		{
			CGameClient__ClientPrintf(pClient, sLogMessage.c_str());

			if (eSendPrints == eSendPrintsToClient::FIRST)
				break;
		}
	}
}

void DedicatedServerLogToClientSink::sink_it_(const spdlog::details::log_msg& msg)
{
	throw std::runtime_error("sink_it_ called on DedicatedServerLogToClientSink with pure log_msg. This is an error!");
}

void DedicatedServerLogToClientSink::flush_() {}

ON_DLL_LOAD_DEDI("engine.dll", DedicatedServerLogToClient, (CModule module))
{
	CGameClient__ClientPrintf = module.Offset(0x1016A0).RCast<void (*)(R2::CBaseClient*, const char*, ...)>();
}
