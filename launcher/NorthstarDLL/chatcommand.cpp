#include "pch.h"
#include "convar.h"
#include "concommand.h"
#include "localchatwriter.h"

// note: isIngameChat is an int64 because the whole register the arg is stored in needs to be 0'd out to work
// if isIngameChat is false, we use network chat instead
void(__fastcall* ClientSayText)(void* a1, const char* message, uint64_t isIngameChat, bool isTeamChat);

void ConCommand_say(const CCommand& args)
{
	if (args.ArgC() >= 2)
		ClientSayText(nullptr, args.ArgS(), true, false);
}

void ConCommand_say_team(const CCommand& args)
{
	if (args.ArgC() >= 2)
		ClientSayText(nullptr, args.ArgS(), true, true);
}

void ConCommand_log(const CCommand& args)
{
	if (args.ArgC() >= 2)
	{
		LocalChatWriter(LocalChatWriter::GameContext).WriteLine(args.ArgS());
	}
}

ON_DLL_LOAD_CLIENT_RELIESON("engine.dll", ClientChatCommand, ConCommand, (CModule module))
{
	ClientSayText = module.Offset(0x54780).As<void(__fastcall*)(void* a1, const char* message, uint64_t isIngameChat, bool isTeamChat)>();
	RegisterConCommand("say", ConCommand_say, "Enters a message in public chat", FCVAR_CLIENTDLL);
	RegisterConCommand("say_team", ConCommand_say_team, "Enters a message in team chat", FCVAR_CLIENTDLL);
	RegisterConCommand("log", ConCommand_log, "Log a message to the local chat window", FCVAR_CLIENTDLL);
}
