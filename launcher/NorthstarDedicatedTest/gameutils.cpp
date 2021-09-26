#include "pch.h"
#include "gameutils.h"
#include "convar.h"
#include "concommand.h"

// cmd.h
Cbuf_GetCurrentPlayerType Cbuf_GetCurrentPlayer;
Cbuf_AddTextType Cbuf_AddText;
Cbuf_ExecuteType Cbuf_Execute;

// hoststate stuff
CHostState* g_GameCHostStateSingleton;

// network stuff
ConVar* Cvar_hostport;

// playlist stuff
GetCurrentPlaylistType GetCurrentPlaylistName;
SetCurrentPlaylistType SetCurrentPlaylist;

// uid
char* g_LocalPlayerUserID;

void InitialiseEngineGameUtilFunctions(HMODULE baseAddress)
{
	Cbuf_GetCurrentPlayer = (Cbuf_GetCurrentPlayerType)((char*)baseAddress + 0x120630);
	Cbuf_AddText = (Cbuf_AddTextType)((char*)baseAddress + 0x1203B0);
	Cbuf_Execute = (Cbuf_ExecuteType)((char*)baseAddress + 0x1204B0);

	g_GameCHostStateSingleton = (CHostState*)((char*)baseAddress + 0x7CF180);

	Cvar_hostport = (ConVar*)((char*)baseAddress + 0x13FA6070);

	GetCurrentPlaylistName = (GetCurrentPlaylistType)((char*)baseAddress + 0x18C640);
	SetCurrentPlaylist = (SetCurrentPlaylistType)((char*)baseAddress + 0x18EB20);

	g_LocalPlayerUserID = (char*)baseAddress + 0x13F8E688;
}
