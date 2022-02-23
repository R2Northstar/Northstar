#include "pch.h"
#include "concommand.h"
#include "gameutils.h"
#include "misccommands.h"
#include <iostream>

typedef void (*ConCommandConstructorType)(
	ConCommand* newCommand, const char* name, void (*callback)(const CCommand&), const char* helpString, int flags, void* parent);
ConCommandConstructorType conCommandConstructor;

void RegisterConCommand(const char* name, void (*callback)(const CCommand&), const char* helpString, int flags)
{
	spdlog::info("Registering ConCommand {}", name);

	// no need to free this ever really, it should exist as long as game does
	ConCommand* newCommand = new ConCommand;
	conCommandConstructor(newCommand, name, callback, helpString, flags, nullptr);
}

void InitialiseConCommands(HMODULE baseAddress)
{
	conCommandConstructor = (ConCommandConstructorType)((char*)baseAddress + 0x415F60);
	AddMiscConCommands();
}

//-----------------------------------------------------------------------------
// Purpose: Returns true if this is a command
// Output : bool
//-----------------------------------------------------------------------------
bool ConCommand::IsCommand(void) const { return true; }

//-----------------------------------------------------------------------------
// Purpose: Returns true if this is a command
// Output : bool
//-----------------------------------------------------------------------------
bool ConCommandBase::IsCommand(void) const { return true; }

//-----------------------------------------------------------------------------
// Purpose: Has this cvar been registered
// Output : Returns true on success, false on failure.
//-----------------------------------------------------------------------------
bool ConCommandBase::IsRegistered(void) const { return m_bRegistered; }

//-----------------------------------------------------------------------------
// Purpose: Test each ConCommand query before execution.
// Input  : *pCommandBase - nFlags
// Output : False if execution is permitted, true if not.
//-----------------------------------------------------------------------------
bool ConCommandBase::IsFlagSet(int nFlags) const
{
	return false; // !TODO: Returning false on every query? (original implementation in Northstar before ConCommandBase refactor)
}

//-----------------------------------------------------------------------------
// Purpose: Checks if ConCommand has requested flags.
// Input  : nFlags -
// Output : True if ConCommand has nFlags.
//-----------------------------------------------------------------------------
bool ConCommandBase::HasFlags(int nFlags) { return m_nFlags & nFlags; }

//-----------------------------------------------------------------------------
// Purpose: Add's flags to ConCommand.
// Input  : nFlags -
//-----------------------------------------------------------------------------
void ConCommandBase::AddFlags(int nFlags) { m_nFlags |= nFlags; }

//-----------------------------------------------------------------------------
// Purpose: Removes flags from ConCommand.
// Input  : nFlags -
//-----------------------------------------------------------------------------
void ConCommandBase::RemoveFlags(int nFlags) { m_nFlags &= ~nFlags; }

//-----------------------------------------------------------------------------
// Purpose: Returns current flags.
// Output : int
//-----------------------------------------------------------------------------
int ConCommandBase::GetFlags(void) const { return m_nFlags; }

//-----------------------------------------------------------------------------
// Purpose:
// Output : const ConCommandBase
//-----------------------------------------------------------------------------
ConCommandBase* ConCommandBase::GetNext(void) const { return m_pNext; }

//-----------------------------------------------------------------------------
// Purpose: Returns the ConCommandBase help text.
// Output : const char*
//-----------------------------------------------------------------------------
const char* ConCommandBase::GetHelpText(void) const { return m_pszHelpString; }

//-----------------------------------------------------------------------------
// Purpose: Copies string using local new/delete operators
// Input  : *szFrom -
// Output : char
//-----------------------------------------------------------------------------
char* ConCommandBase::CopyString(const char* szFrom) const
{
	size_t nLen;
	char* szTo;

	nLen = strlen(szFrom);
	if (nLen <= 0)
	{
		szTo = new char[1];
		szTo[0] = 0;
	}
	else
	{
		szTo = new char[nLen + 1];
		memmove(szTo, szFrom, nLen + 1);
	}
	return szTo;
}
