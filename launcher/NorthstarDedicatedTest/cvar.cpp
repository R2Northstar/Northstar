#include "pch.h"
#include "cvar.h"
#include "convar.h"
#include "concommand.h"

//-----------------------------------------------------------------------------
// Purpose: finds base commands.
// Input  : *pszCommandName -
//-----------------------------------------------------------------------------
ConCommandBase* CCvar::FindCommandBase(const char* pszCommandName)
{
	static int index = 14;
	return CallVFunc<ConCommandBase*>(index, this, pszCommandName);
}

//-----------------------------------------------------------------------------
// Purpose: finds ConVars.
// Input  : *pszVarName -
//-----------------------------------------------------------------------------
ConVar* CCvar::FindVar(const char* pszVarName)
{
	static int index = 16;
	return CallVFunc<ConVar*>(index, this, pszVarName);
}

//-----------------------------------------------------------------------------
// Purpose: finds ConCommands.
// Input  : *pszCommandName -
//-----------------------------------------------------------------------------
ConCommand* CCvar::FindCommand(const char* pszCommandName)
{
	static int index = 18;
	return CallVFunc<ConCommand*>(index, this, pszCommandName);
}

//-----------------------------------------------------------------------------
// Purpose: iterates over all ConVars
//-----------------------------------------------------------------------------
CCVarIteratorInternal* CCvar::FactoryInternalIterator()
{
	static int index = 41;
	return CallVFunc<CCVarIteratorInternal*>(index, this);
}

//-----------------------------------------------------------------------------
// Purpose: returns all ConVars
//-----------------------------------------------------------------------------
std::unordered_map<std::string, ConCommandBase*> CCvar::DumpToMap()
{
	std::stringstream ss;
	CCVarIteratorInternal* itint = FactoryInternalIterator(); // Allocate new InternalIterator.

	std::unordered_map<std::string, ConCommandBase*> allConVars;

	for (itint->SetFirst(); itint->IsValid(); itint->Next()) // Loop through all instances.
	{
		ConCommandBase* pCommand = itint->Get();
		const char* pszCommandName = pCommand->m_pszName;
		allConVars[pszCommandName] = pCommand;
	}

	return allConVars;
}
SourceInterface<CCvar>* g_pCVarInterface;
CCvar* g_pCVar;