#include "pch.h"
#include "cvar.h"
#include "convar.h"
#include "concommand.h"

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

// use the R2 namespace for game funcs
namespace R2
{
	SourceInterface<CCvar>* g_pCVarInterface;
	CCvar* g_pCVar;
} // namespace R2
