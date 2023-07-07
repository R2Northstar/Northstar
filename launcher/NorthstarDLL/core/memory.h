#pragma once

class CMemoryAddress
{
  public:
	uintptr_t m_nAddress;

  public:
	CMemoryAddress();
	CMemoryAddress(const uintptr_t nAddress);
	CMemoryAddress(const void* pAddress);

	// operators
	operator uintptr_t() const;
	operator void*() const;
	operator bool() const;

	bool operator==(const CMemoryAddress& other) const;
	bool operator!=(const CMemoryAddress& other) const;
	bool operator==(const uintptr_t& addr) const;
	bool operator!=(const uintptr_t& addr) const;

	CMemoryAddress operator+(const CMemoryAddress& other) const;
	CMemoryAddress operator-(const CMemoryAddress& other) const;
	CMemoryAddress operator+(const uintptr_t& other) const;
	CMemoryAddress operator-(const uintptr_t& other) const;
	CMemoryAddress operator*() const;

	template <typename T> T RCast()
	{
		return reinterpret_cast<T>(m_nAddress);
	}

	// traversal
	CMemoryAddress Offset(const uintptr_t nOffset) const;
	CMemoryAddress Deref(const int nNumDerefs = 1) const;

	// patching
	void Patch(const uint8_t* pBytes, const size_t nSize);
	void Patch(const std::initializer_list<uint8_t> bytes);
	void Patch(const char* pBytes);
	void NOP(const size_t nSize);

	bool IsMemoryReadable(const size_t nSize);
};

// based on https://github.com/Mauler125/r5sdk/blob/master/r5dev/public/include/module.h
class CModule : public CMemoryAddress
{
  public:
	struct ModuleSections_t
	{
		ModuleSections_t(void) = default;
		ModuleSections_t(const std::string& svSectionName, uintptr_t pSectionBase, size_t nSectionSize)
			: m_svSectionName(svSectionName), m_pSectionBase(pSectionBase), m_nSectionSize(nSectionSize)
		{
		}

		bool IsSectionValid(void) const
		{
			return m_nSectionSize != 0;
		}

		std::string m_svSectionName; // Name of section.
		uintptr_t m_pSectionBase {}; // Start address of section.
		size_t m_nSectionSize {}; // Size of section.
	};

	ModuleSections_t m_ExecutableCode;
	ModuleSections_t m_ExceptionTable;
	ModuleSections_t m_RunTimeData;
	ModuleSections_t m_ReadOnlyData;

  private:
	std::string m_svModuleName;
	uintptr_t m_pModuleBase {};
	DWORD m_nModuleSize {};
	IMAGE_NT_HEADERS64* m_pNTHeaders = nullptr;
	IMAGE_DOS_HEADER* m_pDOSHeader = nullptr;
	std::vector<ModuleSections_t> m_vModuleSections;

  public:
	CModule() = delete; // no default, we need a module name
	CModule(const HMODULE pModule);
	CModule(const char* pModuleName);

	CMemoryAddress GetExport(const char* pExportName);
	CMemoryAddress FindPattern(const uint8_t* pPattern, const char* pMask);
	CMemoryAddress FindPattern(const char* pPattern);
};
