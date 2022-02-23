#pragma once
#include "convar.h"

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
	virtual void SetFirst(void) = 0;	   // 0
	virtual void Next(void) = 0;		   // 1
	virtual bool IsValid(void) = 0;		   // 2
	virtual ConCommandBase* Get(void) = 0; // 3
};

//-----------------------------------------------------------------------------
// Default implementation
//-----------------------------------------------------------------------------
class CCvar
{
  public:
	ConCommandBase* FindCommandBase(const char* pszCommandName);
	ConVar* FindVar(const char* pszVarName);
	ConCommand* FindCommand(const char* pszCommandName);
	CCVarIteratorInternal* FactoryInternalIterator();
	std::unordered_map<std::string, ConCommandBase*> DumpToMap();
};

extern SourceInterface<CCvar>* g_pCVarInterface;
extern CCvar* g_pCVar;