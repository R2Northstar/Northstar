#include "pch.h"
#include "printcommand.h"
#include "convar.h"
#include "concommand.h"

void PrintCommandHelpDialogue(const ConCommandBase* command, const char* name)
{
	if (!command)
	{
		spdlog::info("unknown command {}", name);
		return;
	}

	// temp because command->IsCommand does not currently work
	ConVar* cvar = R2::g_pCVar->FindVar(command->m_pszName);

	// build string for flags if not FCVAR_NONE
	std::string flagString;
	if (command->GetFlags() != FCVAR_NONE)
	{
		flagString = "( ";

		for (auto& flagPair : g_PrintCommandFlags)
		{
			if (command->GetFlags() & flagPair.first)
			{
				// special case, slightly hacky: PRINTABLEONLY is for commands, GAMEDLL_FOR_REMOTE_CLIENTS is for concommands, both have the
				// same value
				if (flagPair.first == FCVAR_PRINTABLEONLY)
				{
					if (cvar && !strcmp(flagPair.second, "GAMEDLL_FOR_REMOTE_CLIENTS"))
						continue;

					if (!cvar && !strcmp(flagPair.second, "PRINTABLEONLY"))
						continue;
				}

				flagString += flagPair.second;
				flagString += " ";
			}
		}

		flagString += ") ";
	}

	if (cvar)
		spdlog::info("\"{}\" = \"{}\" {}- {}", cvar->GetBaseName(), cvar->GetString(), flagString, cvar->GetHelpText());
	else
		spdlog::info("\"{}\" {} - {}", command->m_pszName, flagString, command->GetHelpText());
}

void TryPrintCvarHelpForCommand(const char* pCommand)
{
	// try to display help text for an inputted command string from the console
	int pCommandLen = strlen(pCommand);
	char* pCvarStr = new char[pCommandLen];
	strcpy(pCvarStr, pCommand);

	// trim whitespace from right
	for (int i = pCommandLen - 1; i; i--)
	{
		if (isspace(pCvarStr[i]))
			pCvarStr[i] = '\0';
		else
			break;
	}

	// check if we're inputting a cvar, but not setting it at all
	ConVar* cvar = R2::g_pCVar->FindVar(pCvarStr);
	if (cvar)
		PrintCommandHelpDialogue(&cvar->m_ConCommandBase, pCvarStr);

	delete[] pCvarStr;
}

void ConCommand_help(const CCommand& arg)
{
	if (arg.ArgC() < 2)
	{
		spdlog::info("Usage: help <cvarname>");
		return;
	}

	PrintCommandHelpDialogue(R2::g_pCVar->FindCommandBase(arg.Arg(1)), arg.Arg(1));
}

void ConCommand_find(const CCommand& arg)
{
	if (arg.ArgC() < 2)
	{
		spdlog::info("Usage: find <string> [<string>...]");
		return;
	}

	char pTempName[256];
	char pTempSearchTerm[256];

	for (auto& map : R2::g_pCVar->DumpToMap())
	{
		bool bPrintCommand = true;
		for (int i = 0; i < arg.ArgC() - 1; i++)
		{
			// make lowercase to avoid case sensitivity
			strncpy_s(pTempName, sizeof(pTempName), map.second->m_pszName, sizeof(pTempName) - 1);
			strncpy_s(pTempSearchTerm, sizeof(pTempSearchTerm), arg.Arg(i + 1), sizeof(pTempSearchTerm) - 1);

			for (int i = 0; pTempName[i]; i++)
				pTempName[i] = tolower(pTempName[i]);

			for (int i = 0; pTempSearchTerm[i]; i++)
				pTempSearchTerm[i] = tolower(pTempSearchTerm[i]);

			if (!strstr(pTempName, pTempSearchTerm))
			{
				bPrintCommand = false;
				break;
			}
		}

		if (bPrintCommand)
			PrintCommandHelpDialogue(map.second, map.second->m_pszName);
	}
}

void ConCommand_findflags(const CCommand& arg)
{
	if (arg.ArgC() < 2)
	{
		spdlog::info("Usage: findflags <string>");
		for (auto& flagPair : g_PrintCommandFlags)
			spdlog::info("   - {}", flagPair.second);

		return;
	}

	// convert input flag to uppercase
	char* upperFlag = new char[strlen(arg.Arg(1))];
	strcpy(upperFlag, arg.Arg(1));

	for (int i = 0; upperFlag[i]; i++)
		upperFlag[i] = toupper(upperFlag[i]);

	// resolve flag name => int flags
	int resolvedFlag = FCVAR_NONE;
	for (auto& flagPair : g_PrintCommandFlags)
	{
		if (!strcmp(flagPair.second, upperFlag))
		{
			resolvedFlag |= flagPair.first;
			break;
		}
	}

	// print cvars
	for (auto& map : R2::g_pCVar->DumpToMap())
	{
		if (map.second->m_nFlags & resolvedFlag)
			PrintCommandHelpDialogue(map.second, map.second->m_pszName);
	}

	delete[] upperFlag;
}

void InitialiseCommandPrint()
{
	RegisterConCommand("find", ConCommand_find, "Find concommands with the specified string in their name/help text.", FCVAR_NONE);
	RegisterConCommand("findflags", ConCommand_findflags, "Find concommands by flags.", FCVAR_NONE);

	// help is already a command, so we need to modify the preexisting command to use our func instead
	// and clear the flags also
	ConCommand* helpCommand = R2::g_pCVar->FindCommand("help");
	helpCommand->m_nFlags = FCVAR_NONE;
	helpCommand->m_pCommandCallback = ConCommand_help;
}
