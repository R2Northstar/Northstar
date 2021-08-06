#include "pch.h"
#include "gameutils.h"

// cmd.h

Cbuf_GetCurrentPlayerType Cbuf_GetCurrentPlayer;
Cbuf_AddTextType Cbuf_AddText;

void InitialiseEngineGameUtilFunctions(HMODULE baseAddress)
{
	Cbuf_GetCurrentPlayer = (Cbuf_GetCurrentPlayerType)((char*)baseAddress + 0x120630);
	Cbuf_AddText = (Cbuf_AddTextType)((char*)baseAddress + 0x1203B0);
}