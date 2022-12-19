#pragma once
#include "pch.h"
#include "bansystem.h"
#include "serverauthentication.h"
#include "shared/maxplayers.h"
#include "core/convar/concommand.h"
#include "server/r2server.h"
#include "engine/r2engine.h"
#include "config/profile.h"

#include <filesystem>

const char* BANLIST_PATH_SUFFIX = "/banlist.txt";
const char BANLIST_COMMENT_CHAR = '#';

ServerBanSystem* g_pBanSystem;

void ServerBanSystem::OpenBanlist()
{
	std::ifstream banlistStream(GetNorthstarPrefix() + "/banlist.txt");

	if (!banlistStream.fail())
	{
		std::string line;
		while (std::getline(banlistStream, line))
		{
			// ignore line if first char is # or line is empty
			if (line == "" || line.front() == BANLIST_COMMENT_CHAR)
				continue;

			// remove tabs which shouldnt be there but maybe someone did the funny
			line.erase(std::remove(line.begin(), line.end(), '\t'), line.end());
			// remove spaces to allow for spaces before uids
			line.erase(std::remove(line.begin(), line.end(), ' '), line.end());

			// check if line is empty to allow for newlines in the file
			if (line == "")
				continue;

			// for inline comments like: 123123123 #banned for unfunny
			std::string uid = line.substr(0, line.find(BANLIST_COMMENT_CHAR));

			m_vBannedUids.push_back(strtoull(uid.c_str(), nullptr, 10));
		}

		banlistStream.close();
	}

	// open write stream for banlist // dont do this to allow for all time access
	// m_sBanlistStream.open(GetNorthstarPrefix() + "/banlist.txt", std::ofstream::out | std::ofstream::binary | std::ofstream::app);
}

void ServerBanSystem::ReloadBanlist()
{
	std::ifstream fsBanlist(GetNorthstarPrefix() + "/banlist.txt");

	if (!fsBanlist.fail())
	{
		std::string line;
		// since we wanna use this as the reload func we need to clear the list
		m_vBannedUids.clear();
		while (std::getline(fsBanlist, line))
			m_vBannedUids.push_back(strtoull(line.c_str(), nullptr, 10));

		fsBanlist.close();
	}
}

void ServerBanSystem::ClearBanlist()
{
	m_vBannedUids.clear();

	// reopen the file, don't provide std::ofstream::app so it clears on open
	m_sBanlistStream.close();
	m_sBanlistStream.open(GetNorthstarPrefix() + "/banlist.txt", std::ofstream::out | std::ofstream::binary);
	m_sBanlistStream.close();
}

void ServerBanSystem::BanUID(uint64_t uid)
{
	// checking if last char is \n to make sure uids arent getting fucked
	std::ifstream fsBanlist(GetNorthstarPrefix() + "/banlist.txt");
	std::string content((std::istreambuf_iterator<char>(fsBanlist)), (std::istreambuf_iterator<char>()));
	fsBanlist.close();

	m_sBanlistStream.open(GetNorthstarPrefix() + "/banlist.txt", std::ofstream::out | std::ofstream::binary | std::ofstream::app);
	if (content.back() != '\n')
		m_sBanlistStream << std::endl;

	m_vBannedUids.push_back(uid);
	m_sBanlistStream << std::to_string(uid) << std::endl;
	m_sBanlistStream.close();
	spdlog::info("{} was banned", uid);
}

void ServerBanSystem::UnbanUID(uint64_t uid)
{
	auto findResult = std::find(m_vBannedUids.begin(), m_vBannedUids.end(), uid);
	if (findResult == m_vBannedUids.end())
		return;

	m_vBannedUids.erase(findResult);

	std::vector<std::string> banlistText;
	std::ifstream fs_readBanlist(GetNorthstarPrefix() + "/banlist.txt");

	if (!fs_readBanlist.fail())
	{
		std::string line;
		while (std::getline(fs_readBanlist, line))
		{
			// support for comments and newlines added in https://github.com/R2Northstar/NorthstarLauncher/pull/227

			std::string modLine = line; // copy the line into a free var that we can fuck with, line will be the original

			// remove tabs which shouldnt be there but maybe someone did the funny
			modLine.erase(std::remove(modLine.begin(), modLine.end(), '\t'), modLine.end());
			// remove spaces to allow for spaces before uids
			modLine.erase(std::remove(modLine.begin(), modLine.end(), ' '), modLine.end());

			// ignore line if first char is # or empty line, just add it
			if (line.front() == BANLIST_COMMENT_CHAR || modLine == "")
			{
				banlistText.push_back(line);
				continue;
			}

			// for inline comments like: 123123123 #banned for unfunny
			std::string lineUid = line.substr(0, line.find(BANLIST_COMMENT_CHAR));
			// have to erase spaces or else inline comments will fuck up the uid finding
			lineUid.erase(std::remove(lineUid.begin(), lineUid.end(), '\t'), lineUid.end());
			lineUid.erase(std::remove(lineUid.begin(), lineUid.end(), ' '), lineUid.end());

			// if the uid in the line is the uid we wanna unban
			if (std::to_string(uid) == lineUid)
			{
				// comment the uid out
				line.insert(0, "# ");

				// add a comment with unban date
				// not necessary but i feel like this makes it better
				std::time_t t = std::time(0);
				std::tm* now = std::localtime(&t);

				std::ostringstream unbanComment;

				//{y}/{m}/{d} {h}:{m}
				unbanComment << " # unban date: ";
				unbanComment << now->tm_year + 1900 << "-"; // this lib is so fucking awful
				unbanComment << std::setw(2) << std::setfill('0') << now->tm_mon + 1 << "-";
				unbanComment << std::setw(2) << std::setfill('0') << now->tm_mday << " ";
				unbanComment << std::setw(2) << std::setfill('0') << now->tm_hour << ":";
				unbanComment << std::setw(2) << std::setfill('0') << now->tm_min;

				line.append(unbanComment.str());
			}

			banlistText.push_back(line);
		}

		fs_readBanlist.close();
	}

	// open write stream for banlist // without append so we clear the file
	if (m_sBanlistStream.is_open())
		m_sBanlistStream.close();
	m_sBanlistStream.open(GetNorthstarPrefix() + "/banlist.txt", std::ofstream::out | std::ofstream::binary);

	for (std::string updatedLine : banlistText)
		m_sBanlistStream << updatedLine << std::endl;

	m_sBanlistStream.close();
	spdlog::info("{} was unbanned", uid);
}

bool ServerBanSystem::IsUIDAllowed(uint64_t uid)
{
	ReloadBanlist(); // Reload to have up to date list on join
	return std::find(m_vBannedUids.begin(), m_vBannedUids.end(), uid) == m_vBannedUids.end();
}

void ConCommand_ban(const CCommand& args)
{
	if (args.ArgC() < 2)
		return;

	for (int i = 0; i < R2::GetMaxPlayers(); i++)
	{
		R2::CBaseClient* player = &R2::g_pClientArray[i];

		if (!strcmp(player->m_Name, args.Arg(1)) || !strcmp(player->m_UID, args.Arg(1)))
		{
			g_pBanSystem->BanUID(strtoull(player->m_UID, nullptr, 10));
			R2::CBaseClient__Disconnect(player, 1, "Banned from server");
			break;
		}
	}
}

void ConCommand_unban(const CCommand& args)
{
	if (args.ArgC() < 2)
		return;

	// assumedly the player being unbanned here wasn't already connected, so don't need to iterate over players or anything
	g_pBanSystem->UnbanUID(strtoull(args.Arg(1), nullptr, 10));
}

void ConCommand_clearbanlist(const CCommand& args)
{
	g_pBanSystem->ClearBanlist();
}

ON_DLL_LOAD_RELIESON("engine.dll", BanSystem, ConCommand, (CModule module))
{
	g_pBanSystem = new ServerBanSystem;
	g_pBanSystem->OpenBanlist();

	RegisterConCommand("ban", ConCommand_ban, "bans a given player by uid or name", FCVAR_GAMEDLL);
	RegisterConCommand("unban", ConCommand_unban, "unbans a given player by uid", FCVAR_GAMEDLL);
	RegisterConCommand("clearbanlist", ConCommand_clearbanlist, "clears all uids on the banlist", FCVAR_GAMEDLL);
}
