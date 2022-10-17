#include "pch.h"
#include "limits.h"
#include "hoststate.h"
#include "r2client.h"
#include "r2engine.h"
#include "r2server.h"
#include "maxplayers.h"
#include "tier0.h"
#include "vector.h"
#include "serverauthentication.h"

AUTOHOOK_INIT()

ServerLimitsManager* g_pServerLimits;

ConVar* Cvar_net_datablock_enabled;

// todo: make this work on higher timescales, also possibly disable when sv_cheats is set
void ServerLimitsManager::RunFrame(double flCurrentTime, float flFrameTime)
{
	if (Cvar_sv_antispeedhack_enable->GetBool())
	{
		// for each player, set their usercmd processing budget for the frame to the last frametime for the server
		for (int i = 0; i < R2::GetMaxPlayers(); i++)
		{
			R2::CBaseClient* player = &R2::g_pClientArray[i];

			if (m_PlayerLimitData.find(player) != m_PlayerLimitData.end())
			{
				PlayerLimitData* pLimitData = &g_pServerLimits->m_PlayerLimitData[player];
				if (pLimitData->flFrameUserCmdBudget < 0.016666667 * Cvar_sv_antispeedhack_maxtickbudget->GetFloat())
					pLimitData->flFrameUserCmdBudget +=
						fmax(flFrameTime, 0.016666667) * g_pServerLimits->Cvar_sv_antispeedhack_budgetincreasemultiplier->GetFloat();
			}
		}
	}
}

void ServerLimitsManager::AddPlayer(R2::CBaseClient* player)
{
	PlayerLimitData limitData;
	limitData.flFrameUserCmdBudget = 0.016666667 * Cvar_sv_antispeedhack_maxtickbudget->GetFloat();

	m_PlayerLimitData.insert(std::make_pair(player, limitData));
}

void ServerLimitsManager::RemovePlayer(R2::CBaseClient* player)
{
	if (m_PlayerLimitData.find(player) != m_PlayerLimitData.end())
		m_PlayerLimitData.erase(player);
}

bool ServerLimitsManager::CheckStringCommandLimits(R2::CBaseClient* player)
{
	if (CVar_sv_quota_stringcmdspersecond->GetInt() != -1)
	{
		// note: this isn't super perfect, legit clients can trigger it in lobby if they try, mostly good enough tho imo
		if (Tier0::Plat_FloatTime() - m_PlayerLimitData[player].lastClientCommandQuotaStart >= 1.0)
		{
			// reset quota
			m_PlayerLimitData[player].lastClientCommandQuotaStart = Tier0::Plat_FloatTime();
			m_PlayerLimitData[player].numClientCommandsInQuota = 0;
		}

		m_PlayerLimitData[player].numClientCommandsInQuota++;
		if (m_PlayerLimitData[player].numClientCommandsInQuota > CVar_sv_quota_stringcmdspersecond->GetInt())
		{
			// too many stringcmds, dc player
			return false;
		}
	}

	return true;
}

bool ServerLimitsManager::CheckChatLimits(R2::CBaseClient* player)
{
	if (Tier0::Plat_FloatTime() - m_PlayerLimitData[player].lastSayTextLimitStart >= 1.0)
	{
		m_PlayerLimitData[player].lastSayTextLimitStart = Tier0::Plat_FloatTime();
		m_PlayerLimitData[player].sayTextLimitCount = 0;
	}

	if (m_PlayerLimitData[player].sayTextLimitCount >= Cvar_sv_max_chat_messages_per_sec->GetInt())
		return false;

	m_PlayerLimitData[player].sayTextLimitCount++;
	return true;
}

// clang-format off
AUTOHOOK(CNetChan__ProcessMessages, engine.dll + 0x2140A0, 
char, __fastcall, (void* self, void* buf))
// clang-format on
{
	enum eNetChanLimitMode
	{
		NETCHANLIMIT_WARN,
		NETCHANLIMIT_KICK
	};

	double startTime = Tier0::Plat_FloatTime();
	char ret = CNetChan__ProcessMessages(self, buf);

	// check processing limits, unless we're in a level transition
	if (R2::g_pHostState->m_iCurrentState == R2::HostState_t::HS_RUN && Tier0::ThreadInServerFrameThread())
	{
		// player that sent the message
		R2::CBaseClient* sender = *(R2::CBaseClient**)((char*)self + 368);

		// if no sender, return
		// relatively certain this is fine?
		if (!sender || !g_pServerLimits->m_PlayerLimitData.count(sender))
			return ret;

		// reset every second
		if (startTime - g_pServerLimits->m_PlayerLimitData[sender].lastNetChanProcessingLimitStart >= 1.0 ||
			g_pServerLimits->m_PlayerLimitData[sender].lastNetChanProcessingLimitStart == -1.0)
		{
			g_pServerLimits->m_PlayerLimitData[sender].lastNetChanProcessingLimitStart = startTime;
			g_pServerLimits->m_PlayerLimitData[sender].netChanProcessingLimitTime = 0.0;
		}
		g_pServerLimits->m_PlayerLimitData[sender].netChanProcessingLimitTime += (Tier0::Plat_FloatTime() * 1000) - (startTime * 1000);

		if (g_pServerLimits->m_PlayerLimitData[sender].netChanProcessingLimitTime >=
			g_pServerLimits->Cvar_net_chan_limit_msec_per_sec->GetInt())
		{
			spdlog::warn(
				"Client {} hit netchan processing limit with {}ms of processing time this second (max is {})",
				(char*)sender + 0x16,
				g_pServerLimits->m_PlayerLimitData[sender].netChanProcessingLimitTime,
				g_pServerLimits->Cvar_net_chan_limit_msec_per_sec->GetInt());

			// never kick local player
			if (g_pServerLimits->Cvar_net_chan_limit_mode->GetInt() != NETCHANLIMIT_WARN && strcmp(R2::g_pLocalPlayerUserID, sender->m_UID))
			{
				R2::CBaseClient__Disconnect(sender, 1, "Exceeded net channel processing limit");
				return false;
			}
		}
	}

	return ret;
}

// clang-format off
AUTOHOOK(ProcessConnectionlessPacket, engine.dll + 0x117800, 
bool, , (void* a1, R2::netpacket_t* packet))
// clang-format on
{
	if (packet->adr.type == R2::NA_IP &&
		(!(packet->data[4] == 'N' && Cvar_net_datablock_enabled->GetBool()) || !Cvar_net_datablock_enabled->GetBool()))
	{
		// bad lookup: optimise later tm
		UnconnectedPlayerLimitData* sendData = nullptr;
		for (UnconnectedPlayerLimitData& foundSendData : g_pServerLimits->m_UnconnectedPlayerLimitData)
		{
			if (!memcmp(packet->adr.ip, foundSendData.ip, 16))
			{
				sendData = &foundSendData;
				break;
			}
		}

		if (!sendData)
		{
			sendData = &g_pServerLimits->m_UnconnectedPlayerLimitData.emplace_back();
			memcpy(sendData->ip, packet->adr.ip, 16);
		}

		if (Tier0::Plat_FloatTime() < sendData->timeoutEnd)
			return false;

		if (Tier0::Plat_FloatTime() - sendData->lastQuotaStart >= 1.0)
		{
			sendData->lastQuotaStart = Tier0::Plat_FloatTime();
			sendData->packetCount = 0;
		}

		sendData->packetCount++;

		if (sendData->packetCount >= g_pServerLimits->Cvar_sv_querylimit_per_sec->GetInt())
		{
			spdlog::warn(
				"Client went over connectionless ratelimit of {} per sec with packet of type {}",
				g_pServerLimits->Cvar_sv_querylimit_per_sec->GetInt(),
				packet->data[4]);

			// timeout for a minute
			sendData->timeoutEnd = Tier0::Plat_FloatTime() + 60.0;
			return false;
		}
	}

	return ProcessConnectionlessPacket(a1, packet);
}

// this is weird and i'm not sure if it's correct, so not using for now
/*AUTOHOOK(CBasePlayer__PhysicsSimulate, server.dll + 0x5A6E50, bool, __fastcall, (void* self, int a2, char a3))
{
	spdlog::info("CBasePlayer::PhysicsSimulate");
	return CBasePlayer__PhysicsSimulate(self, a2, a3);
}*/

struct alignas(4) SV_CUserCmd
{
	DWORD command_number;
	DWORD tick_count;
	float command_time;
	Vector3 worldViewAngles;
	BYTE gap18[4];
	Vector3 localViewAngles;
	Vector3 attackangles;
	Vector3 move;
	DWORD buttons;
	BYTE impulse;
	short weaponselect;
	DWORD meleetarget;
	BYTE gap4C[24];
	char headoffset;
	BYTE gap65[11];
	Vector3 cameraPos;
	Vector3 cameraAngles;
	BYTE gap88[4];
	int tickSomething;
	DWORD dword90;
	DWORD predictedServerEventAck;
	DWORD dword98;
	float frameTime;
};

// clang-format off
AUTOHOOK(CPlayerMove__RunCommand, server.dll + 0x5B8100,
void, __fastcall, (void* self, R2::CBasePlayer* player, SV_CUserCmd* pUserCmd, uint64_t a4))
// clang-format on
{
	if (g_pServerLimits->Cvar_sv_antispeedhack_enable->GetBool())
	{
		R2::CBaseClient* pClient = &R2::g_pClientArray[player->m_nPlayerIndex - 1];

		if (g_pServerLimits->m_PlayerLimitData.find(pClient) != g_pServerLimits->m_PlayerLimitData.end())
		{
			PlayerLimitData* pLimitData = &g_pServerLimits->m_PlayerLimitData[pClient];

			pLimitData->flFrameUserCmdBudget = fmax(0.0, pLimitData->flFrameUserCmdBudget - pUserCmd->frameTime);

			if (pLimitData->flFrameUserCmdBudget <= 0.0)
			{
				spdlog::warn("player {} went over usercmd budget ({})", pClient->m_Name, pLimitData->flFrameUserCmdBudget);
				return;
			}
			// else
			//	spdlog::info("{}: {}", pClient->m_Name, pLimitData->flFrameUserCmdBudget);
		}
	}

	CPlayerMove__RunCommand(self, player, pUserCmd, a4);
}

ON_DLL_LOAD_RELIESON("engine.dll", ServerLimits, ConVar, (CModule module))
{
	AUTOHOOK_DISPATCH_MODULE(engine.dll)

	g_pServerLimits = new ServerLimitsManager;

	g_pServerLimits->CVar_sv_quota_stringcmdspersecond = new ConVar(
		"sv_quota_stringcmdspersecond",
		"60",
		FCVAR_GAMEDLL,
		"How many string commands per second clients are allowed to submit, 0 to disallow all string commands, -1 to disable");
	g_pServerLimits->Cvar_net_chan_limit_mode =
		new ConVar("net_chan_limit_mode", "0", FCVAR_GAMEDLL, "The mode for netchan processing limits: 0 = warn, 1 = kick");
	g_pServerLimits->Cvar_net_chan_limit_msec_per_sec = new ConVar(
		"net_chan_limit_msec_per_sec",
		"100",
		FCVAR_GAMEDLL,
		"Netchannel processing is limited to so many milliseconds, abort connection if exceeding budget");
	g_pServerLimits->Cvar_sv_querylimit_per_sec = new ConVar("sv_querylimit_per_sec", "15", FCVAR_GAMEDLL, "");
	g_pServerLimits->Cvar_sv_max_chat_messages_per_sec = new ConVar("sv_max_chat_messages_per_sec", "5", FCVAR_GAMEDLL, "");
	g_pServerLimits->Cvar_sv_antispeedhack_enable =
		new ConVar("sv_antispeedhack_enable", "0", FCVAR_NONE, "whether to enable antispeedhack protections");
	g_pServerLimits->Cvar_sv_antispeedhack_maxtickbudget = new ConVar(
		"sv_antispeedhack_maxtickbudget",
		"64",
		FCVAR_GAMEDLL,
		"Maximum number of client-issued usercmd ticks that can be replayed in packet loss conditions, 0 to allow no restrictions");
	g_pServerLimits->Cvar_sv_antispeedhack_budgetincreasemultiplier = new ConVar(
		"sv_antispeedhack_budgetincreasemultiplier",
		"1.2",
		FCVAR_GAMEDLL,
		"Increase usercmd processing budget by tickinterval * value per tick");

	Cvar_net_datablock_enabled = R2::g_pCVar->FindVar("net_datablock_enabled");
}

ON_DLL_LOAD("server.dll", ServerLimitsServer, (CModule module))
{
	AUTOHOOK_DISPATCH_MODULE(server.dll)
}
