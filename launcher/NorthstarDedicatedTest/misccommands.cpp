#include "pch.h"
#include "misccommands.h"
#include "concommand.h"
#include "gameutils.h"

void ForceLoadMapCommand(const CCommand& arg)
{
	if (arg.ArgC() < 2)
		return;

	g_pHostState->m_iNextState = HS_NEW_GAME;
	strncpy(g_pHostState->m_levelName, arg.Arg(1), sizeof(g_pHostState->m_levelName));
}

void LeaveToLobbyCommand(const CCommand& arg)
{
	SetCurrentPlaylist("tdm");

	// note: for host, this will kick all clients, since it hits HS_GAME_SHUTDOWN
	g_pHostState->m_iNextState = HS_NEW_GAME;
	strcpy(g_pHostState->m_levelName, "mp_lobby");
}

void AddMiscConCommands()
{
	RegisterConCommand("force_newgame", ForceLoadMapCommand, "forces a map load through directly setting g_pHostState->m_iNextState to HS_NEW_GAME", FCVAR_NONE);
	RegisterConCommand("ns_leave_to_lobby", LeaveToLobbyCommand, "called by the server, used to return the player to lobby when leaving a game", FCVAR_SERVER_CAN_EXECUTE);
}