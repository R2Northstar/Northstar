#pragma once
#include "convar.h"
#include "pch.h"

//-----------------------------------------------------------------------------
// Forward declarations
//-----------------------------------------------------------------------------
class ConCommandBase;
class ConCommand;
class ConVar;

//-----------------------------------------------------------------------------
// Internals for ICVarIterator
//-----------------------------------------------------------------------------
class CCVarIteratorInternal // Fully reversed table, just look at the virtual function table and rename the function.
{
  public:
	virtual void SetFirst(void) = 0; // 0
	virtual void Next(void) = 0; // 1
	virtual bool IsValid(void) = 0; // 2
	virtual ConCommandBase* Get(void) = 0; // 3
};

//-----------------------------------------------------------------------------
// Default implementation
//-----------------------------------------------------------------------------
class CCvar
{
  public:
	M_VMETHOD(ConCommandBase*, FindCommandBase, 14, (const char* pszCommandName), (this, pszCommandName));
	M_VMETHOD(ConVar*, FindVar, 16, (const char* pszVarName), (this, pszVarName));
	M_VMETHOD(ConCommand*, FindCommand, 18, (const char* pszCommandName), (this, pszCommandName));
	M_VMETHOD(CCVarIteratorInternal*, FactoryInternalIterator, 41, (), (this));

	std::unordered_map<std::string, ConCommandBase*> DumpToMap();
};

// use the R2 namespace for game funcs
namespace R2
{
	extern SourceInterface<CCvar>* g_pCVarInterface;
	extern CCvar* g_pCVar;
} // namespace R2
