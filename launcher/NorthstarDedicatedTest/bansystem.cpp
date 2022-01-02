#pragma once
#include "pch.h"
#include "bansystem.h"
#include "serverauthentication.h"
#include "concommand.h"
#include "miscserverscript.h"
#include <filesystem>

const char* BANLIST_PATH = "R2Northstar/banlist.txt";

ServerBanSystem* g_ServerBanSystem;

void ServerBanSystem::OpenBanlist()
{
	std::ifstream enabledModsStream(BANLIST_PATH);
	std::stringstream enabledModsStringStream;

	if (!enabledModsStream.fail())
	{
		std::string line;
		while (std::getline(enabledModsStream, line))
			m_vBannedUids.push_back(strtoll(line.c_str(), nullptr, 10));

		enabledModsStream.close();
	}	

	// open write stream for banlist
	m_sBanlistStream.open(BANLIST_PATH, std::ofstream::out | std::ofstream::binary | std::ofstream::app);
}

void ServerBanSystem::BanUID(uint64_t uid)
{
	m_vBannedUids.push_back(uid);
	m_sBanlistStream << std::to_string(uid) << std::endl;
}

bool ServerBanSystem::IsUIDAllowed(uint64_t uid)
{
	return std::find(m_vBannedUids.begin(), m_vBannedUids.end(), uid) == m_vBannedUids.end();
}

void BanPlayerCommand(const CCommand& args)
{
	if (args.ArgC() < 2)
		return;

	for (int i = 0; i < 32; i++)
	{
		void* player = GetPlayerByIndex(i);

		if (!strcmp((char*)player + 0x16, args.Arg(1)) || strcmp((char*)player + 0xF500, args.Arg(1)))
		{
			g_ServerBanSystem->BanUID(strtoll((char*)player + 0xF500, nullptr, 10));
			CBaseClient__Disconnect(player, 1, "Banned from server");
			break;
		}
	}
}

void InitialiseBanSystem(HMODULE baseAddress)
{
	g_ServerBanSystem = new ServerBanSystem;
	g_ServerBanSystem->OpenBanlist();

	RegisterConCommand("ban", BanPlayerCommand, "bans a given player by uid or name", FCVAR_GAMEDLL);
}