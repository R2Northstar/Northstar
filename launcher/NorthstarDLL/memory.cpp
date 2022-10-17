#include "pch.h"
#include "memory.h"

MemoryAddress::MemoryAddress() : m_nAddress(0) {}
MemoryAddress::MemoryAddress(const uintptr_t nAddress) : m_nAddress(nAddress) {}
MemoryAddress::MemoryAddress(const void* pAddress) : m_nAddress(reinterpret_cast<uintptr_t>(pAddress)) {}

// operators
MemoryAddress::operator uintptr_t() const
{
	return m_nAddress;
}

MemoryAddress::operator void*() const
{
	return reinterpret_cast<void*>(m_nAddress);
}

MemoryAddress::operator bool() const
{
	return m_nAddress != 0;
}

bool MemoryAddress::operator==(const MemoryAddress& other) const
{
	return m_nAddress == other.m_nAddress;
}

bool MemoryAddress::operator!=(const MemoryAddress& other) const
{
	return m_nAddress != other.m_nAddress;
}

bool MemoryAddress::operator==(const uintptr_t& addr) const
{
	return m_nAddress == addr;
}

bool MemoryAddress::operator!=(const uintptr_t& addr) const
{
	return m_nAddress != addr;
}

MemoryAddress MemoryAddress::operator+(const MemoryAddress& other) const
{
	return Offset(other.m_nAddress);
}

MemoryAddress MemoryAddress::operator-(const MemoryAddress& other) const
{
	return MemoryAddress(m_nAddress - other.m_nAddress);
}

MemoryAddress MemoryAddress::operator+(const uintptr_t& addr) const
{
	return Offset(addr);
}

MemoryAddress MemoryAddress::operator-(const uintptr_t& addr) const
{
	return MemoryAddress(m_nAddress - addr);
}

MemoryAddress MemoryAddress::operator*() const
{
	return Deref();
}

// traversal
MemoryAddress MemoryAddress::Offset(const uintptr_t nOffset) const
{
	return MemoryAddress(m_nAddress + nOffset);
}

MemoryAddress MemoryAddress::Deref(const int nNumDerefs) const
{
	uintptr_t ret = m_nAddress;
	for (int i = 0; i < nNumDerefs; i++)
		ret = *reinterpret_cast<uintptr_t*>(ret);

	return MemoryAddress(ret);
}

// patching
void MemoryAddress::Patch(const uint8_t* pBytes, const size_t nSize)
{
	if (nSize)
		WriteProcessMemory(GetCurrentProcess(), reinterpret_cast<LPVOID>(m_nAddress), pBytes, nSize, NULL);
}

void MemoryAddress::Patch(const std::initializer_list<uint8_t> bytes)
{
	uint8_t* pBytes = new uint8_t[bytes.size()];

	int i = 0;
	for (const uint8_t& byte : bytes)
		pBytes[i++] = byte;

	Patch(pBytes, bytes.size());
	delete[] pBytes;
}

inline std::vector<uint8_t> HexBytesToString(const char* pHexString)
{
	std::vector<uint8_t> ret;

	int size = strlen(pHexString);
	for (int i = 0; i < size; i++)
	{
		// If this is a space character, ignore it
		if (isspace(pHexString[i]))
			continue;

		if (i < size - 1)
		{
			BYTE result = 0;
			for (int j = 0; j < 2; j++)
			{
				int val = 0;
				char c = *(pHexString + i + j);
				if (c >= 'a')
				{
					val = c - 'a' + 0xA;
				}
				else if (c >= 'A')
				{
					val = c - 'A' + 0xA;
				}
				else if (isdigit(c))
				{
					val = c - '0';
				}
				else
				{
					assert(false, "Failed to parse invalid hex string.");
					val = -1;
				}

				result += (j == 0) ? val * 16 : val;
			}
			ret.push_back(result);
		}

		i++;
	}

	return ret;
}

void MemoryAddress::Patch(const char* pBytes)
{
	std::vector<uint8_t> vBytes = HexBytesToString(pBytes);
	Patch(vBytes.data(), vBytes.size());
}

void MemoryAddress::NOP(const size_t nSize)
{
	uint8_t* pBytes = new uint8_t[nSize];

	memset(pBytes, 0x90, nSize);
	Patch(pBytes, nSize);

	delete[] pBytes;
}

bool MemoryAddress::IsMemoryReadable(const size_t nSize)
{
	static SYSTEM_INFO sysInfo;
	if (!sysInfo.dwPageSize)
		GetSystemInfo(&sysInfo);

	MEMORY_BASIC_INFORMATION memInfo;
	if (!VirtualQuery(reinterpret_cast<LPCVOID>(m_nAddress), &memInfo, sizeof(memInfo)))
		return false;

	return memInfo.RegionSize >= nSize && memInfo.State & MEM_COMMIT && !(memInfo.Protect & PAGE_NOACCESS);
}

CModule::CModule(const HMODULE pModule)
{
	MODULEINFO mInfo {0};

	if (pModule && pModule != INVALID_HANDLE_VALUE)
		GetModuleInformation(GetCurrentProcess(), pModule, &mInfo, sizeof(MODULEINFO));

	m_nModuleSize = static_cast<size_t>(mInfo.SizeOfImage);
	m_pModuleBase = reinterpret_cast<uintptr_t>(mInfo.lpBaseOfDll);
	m_nAddress = m_pModuleBase;

	if (!m_nModuleSize || !m_pModuleBase)
		return;

	m_pDOSHeader = reinterpret_cast<IMAGE_DOS_HEADER*>(m_pModuleBase);
	m_pNTHeaders = reinterpret_cast<IMAGE_NT_HEADERS64*>(m_pModuleBase + m_pDOSHeader->e_lfanew);

	const IMAGE_SECTION_HEADER* hSection = IMAGE_FIRST_SECTION(m_pNTHeaders); // Get first image section.

	for (WORD i = 0; i < m_pNTHeaders->FileHeader.NumberOfSections; i++) // Loop through the sections.
	{
		const IMAGE_SECTION_HEADER& hCurrentSection = hSection[i]; // Get current section.

		ModuleSections_t moduleSection = ModuleSections_t(
			std::string(reinterpret_cast<const char*>(hCurrentSection.Name)),
			static_cast<uintptr_t>(m_pModuleBase + hCurrentSection.VirtualAddress),
			hCurrentSection.SizeOfRawData);

		if (!strcmp((const char*)hCurrentSection.Name, ".text"))
			m_ExecutableCode = moduleSection;
		else if (!strcmp((const char*)hCurrentSection.Name, ".pdata"))
			m_ExceptionTable = moduleSection;
		else if (!strcmp((const char*)hCurrentSection.Name, ".data"))
			m_RunTimeData = moduleSection;
		else if (!strcmp((const char*)hCurrentSection.Name, ".rdata"))
			m_ReadOnlyData = moduleSection;

		m_vModuleSections.push_back(moduleSection); // Push back a struct with the section data.
	}
}

CModule::CModule(const char* pModuleName) : CModule(GetModuleHandleA(pModuleName)) {}

MemoryAddress CModule::GetExport(const char* pExportName)
{
	return MemoryAddress(reinterpret_cast<uintptr_t>(GetProcAddress(reinterpret_cast<HMODULE>(m_nAddress), pExportName)));
}

MemoryAddress CModule::FindPattern(const uint8_t* pPattern, const char* pMask)
{
	if (!m_ExecutableCode.IsSectionValid())
		return MemoryAddress();

	uint64_t nBase = static_cast<uint64_t>(m_ExecutableCode.m_pSectionBase);
	uint64_t nSize = static_cast<uint64_t>(m_ExecutableCode.m_nSectionSize);

	const uint8_t* pData = reinterpret_cast<uint8_t*>(nBase);
	const uint8_t* pEnd = pData + static_cast<uint32_t>(nSize) - strlen(pMask);

	int nMasks[64]; // 64*16 = enough masks for 1024 bytes.
	int iNumMasks = static_cast<int>(ceil(static_cast<float>(strlen(pMask)) / 16.f));

	memset(nMasks, '\0', iNumMasks * sizeof(int));
	for (intptr_t i = 0; i < iNumMasks; ++i)
	{
		for (intptr_t j = strnlen(pMask + i * 16, 16) - 1; j >= 0; --j)
		{
			if (pMask[i * 16 + j] == 'x')
			{
				_bittestandset(reinterpret_cast<LONG*>(&nMasks[i]), j);
			}
		}
	}
	__m128i xmm1 = _mm_loadu_si128(reinterpret_cast<const __m128i*>(pPattern));
	__m128i xmm2, xmm3, msks;
	for (; pData != pEnd; _mm_prefetch(reinterpret_cast<const char*>(++pData + 64), _MM_HINT_NTA))
	{
		if (pPattern[0] == pData[0])
		{
			xmm2 = _mm_loadu_si128(reinterpret_cast<const __m128i*>(pData));
			msks = _mm_cmpeq_epi8(xmm1, xmm2);
			if ((_mm_movemask_epi8(msks) & nMasks[0]) == nMasks[0])
			{
				for (uintptr_t i = 1; i < static_cast<uintptr_t>(iNumMasks); ++i)
				{
					xmm2 = _mm_loadu_si128(reinterpret_cast<const __m128i*>((pData + i * 16)));
					xmm3 = _mm_loadu_si128(reinterpret_cast<const __m128i*>((pPattern + i * 16)));
					msks = _mm_cmpeq_epi8(xmm2, xmm3);
					if ((_mm_movemask_epi8(msks) & nMasks[i]) == nMasks[i])
					{
						if ((i + 1) == iNumMasks)
						{
							return MemoryAddress(const_cast<uint8_t*>(pData));
						}
					}
					else
						goto CONTINUE;
				}

				return MemoryAddress((&*(const_cast<uint8_t*>(pData))));
			}
		}

	CONTINUE:;
	}

	return MemoryAddress();
}

inline std::pair<std::vector<uint8_t>, std::string> MaskedBytesFromPattern(const char* pPatternString)
{
	std::vector<uint8_t> vRet;
	std::string sMask;

	int size = strlen(pPatternString);
	for (int i = 0; i < size; i++)
	{
		// If this is a space character, ignore it
		if (isspace(pPatternString[i]))
			continue;

		if (pPatternString[i] == '?')
		{
			// Add a wildcard
			vRet.push_back(0);
			sMask.append("?");
		}
		else if (i < size - 1)
		{
			BYTE result = 0;
			for (int j = 0; j < 2; j++)
			{
				int val = 0;
				char c = *(pPatternString + i + j);
				if (c >= 'a')
				{
					val = c - 'a' + 0xA;
				}
				else if (c >= 'A')
				{
					val = c - 'A' + 0xA;
				}
				else if (isdigit(c))
				{
					val = c - '0';
				}
				else
				{
					assert(false, "Failed to parse invalid pattern string.");
					val = -1;
				}

				result += (j == 0) ? val * 16 : val;
			}

			vRet.push_back(result);
			sMask.append("x");
		}

		i++;
	}

	return std::make_pair(vRet, sMask);
}

MemoryAddress CModule::FindPattern(const char* pPattern)
{
	const auto pattern = MaskedBytesFromPattern(pPattern);
	return FindPattern(pattern.first.data(), pattern.second.c_str());
}
