#include "pch.h"
#include "concommand.h"
#include "misccommands.h"

#include <iostream>

//-----------------------------------------------------------------------------
// Purpose: Returns true if this is a command
// Output : bool
//-----------------------------------------------------------------------------
bool ConCommand::IsCommand(void) const
{
	return true;
}

//-----------------------------------------------------------------------------
// Purpose: Returns true if this is a command
// Output : bool
//-----------------------------------------------------------------------------
bool ConCommandBase::IsCommand(void) const
{
	return true;
}

//-----------------------------------------------------------------------------
// Purpose: Has this cvar been registered
// Output : Returns true on success, false on failure.
//-----------------------------------------------------------------------------
bool ConCommandBase::IsRegistered(void) const
{
	return m_bRegistered;
}

//-----------------------------------------------------------------------------
// Purpose: Test each ConCommand query before execution.
// Input  : *pCommandBase - nFlags
// Output : False if execution is permitted, true if not.
//-----------------------------------------------------------------------------
bool ConCommandBase::IsFlagSet(int nFlags) const
{
	return m_nFlags & nFlags;
}

//-----------------------------------------------------------------------------
// Purpose: Checks if ConCommand has requested flags.
// Input  : nFlags -
// Output : True if ConCommand has nFlags.
//-----------------------------------------------------------------------------
bool ConCommandBase::HasFlags(int nFlags)
{
	return m_nFlags & nFlags;
}

//-----------------------------------------------------------------------------
// Purpose: Add's flags to ConCommand.
// Input  : nFlags -
//-----------------------------------------------------------------------------
void ConCommandBase::AddFlags(int nFlags)
{
	m_nFlags |= nFlags;
}

//-----------------------------------------------------------------------------
// Purpose: Removes flags from ConCommand.
// Input  : nFlags -
//-----------------------------------------------------------------------------
void ConCommandBase::RemoveFlags(int nFlags)
{
	m_nFlags &= ~nFlags;
}

//-----------------------------------------------------------------------------
// Purpose: Returns current flags.
// Output : int
//-----------------------------------------------------------------------------
int ConCommandBase::GetFlags(void) const
{
	return m_nFlags;
}

//-----------------------------------------------------------------------------
// Purpose:
// Output : const ConCommandBase
//-----------------------------------------------------------------------------
ConCommandBase* ConCommandBase::GetNext(void) const
{
	return m_pNext;
}

//-----------------------------------------------------------------------------
// Purpose: Returns the ConCommandBase help text.
// Output : const char*
//-----------------------------------------------------------------------------
const char* ConCommandBase::GetHelpText(void) const
{
	return m_pszHelpString;
}

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

typedef void (*ConCommandConstructorType)(
	ConCommand* newCommand, const char* name, FnCommandCallback_t callback, const char* helpString, int flags, void* parent);
ConCommandConstructorType ConCommandConstructor;

void RegisterConCommand(const char* name, FnCommandCallback_t callback, const char* helpString, int flags)
{
	spdlog::info("Registering ConCommand {}", name);

	// no need to free this ever really, it should exist as long as game does
	ConCommand* newCommand = new ConCommand;
	ConCommandConstructor(newCommand, name, callback, helpString, flags, nullptr);
}

void RegisterConCommand(
	const char* name, FnCommandCallback_t callback, const char* helpString, int flags, FnCommandCompletionCallback completionCallback)
{
	spdlog::info("Registering ConCommand {}", name);

	// no need to free this ever really, it should exist as long as game does
	ConCommand* newCommand = new ConCommand;
	ConCommandConstructor(newCommand, name, callback, helpString, flags, nullptr);
	newCommand->m_pCompletionCallback = completionCallback;
}

ON_DLL_LOAD("engine.dll", ConCommand, (CModule module))
{
	ConCommandConstructor = module.Offset(0x415F60).As<ConCommandConstructorType>();
	AddMiscConCommands();
}
