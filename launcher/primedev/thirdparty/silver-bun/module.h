//===========================================================================//
//
// Purpose: Implementation of the CModule class.
//
// Original commit: https://github.com/IcePixelx/silver-bun/commit/72c74b455bf4d02b424096ad2f30cd65535f814c
//
//===========================================================================//
#pragma once

#include "memaddr.h"
#include <iostream>
#include <string>
#include <vector>
#include <windows.h>
#include <psapi.h>
#include <intrin.h>
#include <algorithm>

class CModule
{
public:
	struct ModuleSections_t
	{
		ModuleSections_t(void) = default;
		ModuleSections_t(const char* sectionName, uintptr_t pSectionBase, size_t nSectionSize) :
			m_SectionName(sectionName), m_pSectionBase(pSectionBase), m_nSectionSize(nSectionSize) {}

		inline bool IsSectionValid(void) const { return m_nSectionSize != 0; }

		std::string m_SectionName;           // Name of section.
		uintptr_t   m_pSectionBase;          // Start address of section.
		size_t      m_nSectionSize;          // Size of section.
	};

	CModule(void) = default;
	CModule(HMODULE hModule);
	CModule(const char* szModuleName);

	void Init();
	void LoadSections();

	CMemory Offset(const uintptr_t nOffset) const;

	CMemory FindPatternSIMD(const char* szPattern, const ModuleSections_t* moduleSection = nullptr) const;
	CMemory FindString(const char* szString, const ptrdiff_t occurrence = 1, bool nullTerminator = false) const;
	CMemory FindStringReadOnly(const char* szString, bool nullTerminator) const;
	CMemory FindFreeDataPage(const size_t nSize) const;

	CMemory          GetVirtualMethodTable(const char* szTableName, const size_t nRefIndex = 0);
	CMemory          GetImportedFunction(const char* szModuleName, const char* szFunctionName, const bool bGetFunctionReference) const;
	CMemory          GetExportedFunction(const char* szFunctionName) const;
	ModuleSections_t GetSectionByName(const char* szSectionName) const;

	inline const std::vector<CModule::ModuleSections_t>& GetSections() const { return m_ModuleSections; }
	inline const std::vector<std::string>& GetImportedModules() const { return m_vImportedModules; }
	inline uintptr_t     GetModuleBase(void) const { return m_pModuleBase; }
	inline DWORD         GetModuleSize(void) const { return m_nModuleSize; }
	inline const std::string& GetModuleName(void) const { return m_ModuleName; }
	inline uintptr_t     GetRVA(const uintptr_t nAddress) const { return (nAddress - GetModuleBase()); }

	IMAGE_NT_HEADERS64*      m_pNTHeaders;
	IMAGE_DOS_HEADER*        m_pDOSHeader;

	ModuleSections_t         m_ExecutableCode;
	ModuleSections_t         m_ExceptionTable;
	ModuleSections_t         m_RunTimeData;
	ModuleSections_t         m_ReadOnlyData;

private:
	CMemory FindPatternSIMD(const uint8_t* pPattern, const char* szMask,
		const ModuleSections_t* moduleSection = nullptr, const size_t nOccurrence = 0) const;

	std::string                   m_ModuleName;
	uintptr_t                     m_pModuleBase;
	DWORD                         m_nModuleSize;
	std::vector<ModuleSections_t> m_ModuleSections;
	std::vector<std::string> m_vImportedModules;
};
