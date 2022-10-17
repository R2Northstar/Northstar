#pragma once
#include "concommand.h"

void PrintCommandHelpDialogue(const ConCommandBase* command, const char* name);
void TryPrintCvarHelpForCommand(const char* pCommand);
void InitialiseCommandPrint();
