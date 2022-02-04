#pragma once
#include "pch.h"
#include "bansystem.h"
#include "serverauthentication.h"
#include "concommand.h"
#include "miscserverscript.h"
#include <filesystem>
#include "configurables.h"

const char* BANLIST_PATH_SUFFIX = "/banlist.txt";

ServerBanSystem* g_ServerBanSystem;

void ServerBanSystem::OpenBanlist()
{
	std::ifstream enabledModsStream(GetNorthstarPrefix() + "/banlist.txt");
	std::stringstream enabledModsStringStream;

	if (!enabledModsStream.fail())
	{
		std::string line;
		while (std::getline(enabledModsStream, line))
			m_vBannedUids.push_back(strtoll(line.c_str(), nullptr, 10));

		enabledModsStream.close();
	}

	// open write stream for banlist
	m_sBanlistStream.open(GetNorthstarPrefix() + "/banlist.txt", std::ofstream::out | std::ofstream::binary | std::ofstream::app);
}

void ServerBanSystem::ClearBanlist()
{
	m_vBannedUids.clear();

	// reopen the file, don't provide std::ofstream::app so it clears on open
	m_sBanlistStream.close();
	m_sBanlistStream.open(GetNorthstarPrefix() + "/banlist.txt", std::ofstream::out | std::ofstream::binary);
}

void ServerBanSystem::BanUID(uint64_t uid)
{
	m_vBannedUids.push_back(uid);
	m_sBanlistStream << std::to_string(uid) << std::endl;
	spdlog::info("{} was banned", uid);
}

void ServerBanSystem::UnbanUID(uint64_t uid)
{
	auto findResult = std::find(m_vBannedUids.begin(), m_vBannedUids.end(), uid);
	if (findResult == m_vBannedUids.end())
		return;

	m_vBannedUids.erase(findResult);
	spdlog::info("{} was unbanned", uid);
	// todo: this needs to erase from the banlist file
	// atm unsure how to do this aside from just clearing and fully rewriting the file
}

bool ServerBanSystem::IsUIDAllowed(uint64_t uid)
{
	return std::find(m_vBannedUids.begin(), m_vBannedUids.end(), uid) == m_vBannedUids.end();
}

void BanPlayerCommand(const CCommand& args)
{
	if (args.ArgC() < 2)
		return;

	// assuming maxplayers 32
	for (int i = 0; i < 32; i++)
	{
		void* player = GetPlayerByIndex(i);

		if (!strcmp((char*)player + 0x16, args.Arg(1)) || !strcmp((char*)player + 0xF500, args.Arg(1)))
		{
			g_ServerBanSystem->BanUID(strtoll((char*)player + 0xF500, nullptr, 10));
			CBaseClient__Disconnect(player, 1, "Banned from server");
			break;
		}
	}
}

void UnbanPlayerCommand(const CCommand& args)
{
	if (args.ArgC() < 2)
		return;

	// assumedly the player being unbanned here wasn't already connected, so don't need to iterate over players or anything
	g_ServerBanSystem->UnbanUID(strtoll(args.Arg(1), nullptr, 10));
}

void ClearBanlistCommand(const CCommand& args) { g_ServerBanSystem->ClearBanlist(); }

void InitialiseBanSystem(HMODULE baseAddress)
{
	g_ServerBanSystem = new ServerBanSystem;
	g_ServerBanSystem->OpenBanlist();

	RegisterConCommand("ban", BanPlayerCommand, "bans a given player by uid or name", FCVAR_GAMEDLL);
	RegisterConCommand("unban", UnbanPlayerCommand, "unbans a given player by uid", FCVAR_NONE);
	RegisterConCommand("clearbanlist", ClearBanlistCommand, "clears all uids on the banlist", FCVAR_NONE);
}