#include "pch.h"
#include "chatcommand.h"
#include "concommand.h"

typedef void(__fastcall *ClientSayTextType)(void* a1, const char* message, char unknownAlways1, bool isTeamChat);
ClientSayTextType SayText;

void ConCommand_say(const CCommand& args)
{
	if (args.ArgC() >= 2)
		SayText(nullptr, args.Arg(1), 0, false);
}

void ConCommand_say_team(const CCommand& args)
{
	if (args.ArgC() >= 2)
		SayText(nullptr, args.Arg(1), 0, true);
}

void InitialiseChatCommands(HMODULE baseAddress)
{
	SayText = (ClientSayTextType)((char*)baseAddress + 0x54780);
	RegisterConCommand("say", ConCommand_say, "Enters a message in public chat", FCVAR_CLIENTDLL);
	RegisterConCommand("say_team", ConCommand_say_team, "Enters a message in team chat", FCVAR_CLIENTDLL);
}