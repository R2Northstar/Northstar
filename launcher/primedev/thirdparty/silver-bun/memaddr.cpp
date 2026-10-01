//===========================================================================//
//
// Purpose: Implementation of the CMemory class.
//
// Original commit: https://github.com/IcePixelx/silver-bun/commit/72c74b455bf4d02b424096ad2f30cd65535f814c
//
//===========================================================================//

#include "memaddr.h"
#include "utils.h"

//-----------------------------------------------------------------------------
// Purpose: check array of opcodes starting from current address
// Input  : &vOpcodeArray - 
// Output : true if equal, false otherwise
//-----------------------------------------------------------------------------
bool CMemory::CheckOpCodes(const std::vector<uint8_t>& vOpcodeArray) const
{
	uintptr_t ref = ptr;

	// Loop forward in the ptr class member.
	for (auto [byteAtCurrentAddress, i] = std::tuple<uint8_t, size_t>{ uint8_t(), (size_t)0 }; i < vOpcodeArray.size(); i++, ref++)
	{
		byteAtCurrentAddress = *reinterpret_cast<uint8_t*>(ref);

		// If byte at ptr doesn't equal in the byte array return false.
		if (byteAtCurrentAddress != vOpcodeArray[i])
			return false;
	}

	return true;
}

//-----------------------------------------------------------------------------
// Purpose: Checx if memory is readable
// Input  : nSize -
//-----------------------------------------------------------------------------
bool CMemory::IsMemoryReadable(const size_t nSize) const
{
	static SYSTEM_INFO sysInfo;
	if (!sysInfo.dwPageSize)
		GetSystemInfo(&sysInfo);

	MEMORY_BASIC_INFORMATION memInfo;
	if (!VirtualQuery(reinterpret_cast<LPCVOID>(GetPtr()), &memInfo, sizeof(memInfo)))
		return false;

	return memInfo.RegionSize >= nSize && memInfo.State & MEM_COMMIT && !(memInfo.Protect & PAGE_NOACCESS);
}

//-----------------------------------------------------------------------------
// Purpose: patch size with nop opcodes
// Input  : nSize -
//-----------------------------------------------------------------------------
void CMemory::NOP(const size_t nSize) const
{
	std::vector<uint8_t> vOpcodeArray;
	vOpcodeArray.resize(nSize);
	memset(vOpcodeArray.data(), 0x90, nSize);
	Patch(vOpcodeArray);
}

//-----------------------------------------------------------------------------
// Purpose: patch array of opcodes
// Input  : *pszOpcodes -
//-----------------------------------------------------------------------------
void CMemory::Patch(const char* pszOpcodes) const
{
	const std::vector<uint8_t> vOpcodeArray = Utils::StringPatternToBytes(pszOpcodes);
	Patch(vOpcodeArray);
}

//-----------------------------------------------------------------------------
// Purpose: patch array of opcodes starting from current address
// Input  : *pOpcodeArray -
//          nSize -
//-----------------------------------------------------------------------------
void CMemory::Patch(const uint8_t* pOpcodeArray, const size_t nSize) const
{
	const std::vector<uint8_t> vOpcodeArray(pOpcodeArray, pOpcodeArray + nSize * sizeof(uint8_t));
	Patch(vOpcodeArray);
}

//-----------------------------------------------------------------------------
// Purpose: patch array of opcodes starting from current address
// Input  : &vOpcodeArray - 
//-----------------------------------------------------------------------------
void CMemory::Patch(const std::vector<uint8_t>& vOpcodeArray) const
{
	DWORD oldProt = NULL;

	SIZE_T dwSize = vOpcodeArray.size();
	VirtualProtect(reinterpret_cast<void*>(ptr), dwSize, PAGE_EXECUTE_READWRITE, &oldProt); // Patch page to be able to read and write to it.

	for (size_t i = 0; i < vOpcodeArray.size(); i++)
	{
		*reinterpret_cast<uint8_t*>(ptr + i) = vOpcodeArray[i]; // Write opcodes to Address.
	}

	dwSize = vOpcodeArray.size();
	VirtualProtect(reinterpret_cast<void*>(ptr), dwSize, oldProt, &oldProt); // Restore protection.
}

//-----------------------------------------------------------------------------
// Purpose: patch string constant at current address
// Input  : *szString - 
//-----------------------------------------------------------------------------
void CMemory::PatchString(const char* szString) const
{
	DWORD oldProt = NULL;
	SIZE_T dwSize =  strlen(szString);

	VirtualProtect(reinterpret_cast<void*>(ptr), dwSize, PAGE_EXECUTE_READWRITE, &oldProt); // Patch page to be able to read and write to it.

	for (size_t i = 0; i < dwSize; i++)
	{
		*reinterpret_cast<uint8_t*>(ptr + i) = szString[i]; // Write string to Address.
	}

	VirtualProtect(reinterpret_cast<void*>(ptr), dwSize, oldProt, &oldProt); // Restore protection.
}

//-----------------------------------------------------------------------------
// Purpose: find array of bytes in process memory
// Input  : *szPattern - 
//			searchDirect - 
//			opCodesToScan - 
//			occurrence - 
// Output : CMemory
//-----------------------------------------------------------------------------
CMemory CMemory::FindPattern(const char* szPattern, const Direction searchDirect, const int opCodesToScan, const ptrdiff_t occurrence) const
{
	uint8_t* pScanBytes = reinterpret_cast<uint8_t*>(ptr); // Get the base of the module.

	const std::vector<int> PatternBytes = Utils::PatternToBytes(szPattern); // Convert our pattern to a byte array.
	const std::pair<size_t, const int*> bytesInfo = std::make_pair<size_t, const int*>(PatternBytes.size(), PatternBytes.data()); // Get the size and data of our bytes.
	ptrdiff_t occurrences = 0;

	for (long i = 01; i < opCodesToScan + bytesInfo.first; i++)
	{
		bool bFound = true;
		int nMemOffset = searchDirect == Direction::DOWN ? i : -i;

		for (DWORD j = 0ul; j < bytesInfo.first; j++)
		{
			// If either the current byte equals to the byte in our pattern or our current byte in the pattern is a wildcard
			// our if clause will be false.
			uint8_t currentByte = *(pScanBytes + nMemOffset + j);
			_mm_prefetch(reinterpret_cast<const CHAR*>(static_cast<int64_t>(currentByte + nMemOffset + 64)), _MM_HINT_T0); // precache some data in L1.
			if (currentByte != bytesInfo.second[j] && bytesInfo.second[j] != -1)
			{
				bFound = false;
				break;
			}
		}

		if (bFound)
		{
			occurrences++;
			if (occurrence == occurrences)
			{
				return CMemory(&*(pScanBytes + nMemOffset));
			}
		}
	}

	return CMemory();
}

//-----------------------------------------------------------------------------
// Purpose: find array of bytes in process memory starting from current address
// Input  : *szPattern - 
//			searchDirect - 
//			opCodesToScan - 
//			occurrence - 
// Output : CMemory
//-----------------------------------------------------------------------------
CMemory CMemory::FindPatternSelf(const char* szPattern, const Direction searchDirect, const int opCodesToScan, const ptrdiff_t occurrence)
{
	uint8_t* pScanBytes = reinterpret_cast<uint8_t*>(ptr); // Get the base of the module.

	const std::vector<int> PatternBytes = Utils::PatternToBytes(szPattern); // Convert our pattern to a byte array.
	const std::pair<size_t, const int*> bytesInfo = std::make_pair<size_t, const int*>(PatternBytes.size(), PatternBytes.data()); // Get the size and data of our bytes.
	ptrdiff_t occurrences = 0;

	for (long i = 01; i < opCodesToScan + bytesInfo.first; i++)
	{
		bool bFound = true;
		int nMemOffset = searchDirect == Direction::DOWN ? i : -i;

		for (DWORD j = 0ul; j < bytesInfo.first; j++)
		{
			// If either the current byte equals to the byte in our pattern or our current byte in the pattern is a wildcard
			// our if clause will be false.
			uint8_t currentByte = *(pScanBytes + nMemOffset + j);
			_mm_prefetch(reinterpret_cast<const CHAR*>(static_cast<int64_t>(currentByte + nMemOffset + 64)), _MM_HINT_T0); // precache some data in L1.
			if (currentByte != bytesInfo.second[j] && bytesInfo.second[j] != -1)
			{
				bFound = false;
				break;
			}
		}

		if (bFound)
		{
			occurrences++;
			if (occurrence == occurrences)
			{
				ptr = uintptr_t(&*(pScanBytes + nMemOffset));
				return *this;
			}
		}
	}

	ptr = uintptr_t();
	return *this;
}

//-----------------------------------------------------------------------------
// Purpose: ResolveRelativeAddress wrapper
// Input  : opcodeOffset - 
//			nextInstructionOffset - 
// Output : CMemory
//-----------------------------------------------------------------------------
CMemory CMemory::FollowNearCall(const ptrdiff_t opcodeOffset, const ptrdiff_t nextInstructionOffset) const
{
	return ResolveRelativeAddress(opcodeOffset, nextInstructionOffset);
}

//-----------------------------------------------------------------------------
// Purpose: ResolveRelativeAddressSelf wrapper
// Input  : opcodeOffset - 
//			nextInstructionOffset - 
// Output : CMemory
//-----------------------------------------------------------------------------
CMemory CMemory::FollowNearCallSelf(const ptrdiff_t opcodeOffset, const ptrdiff_t nextInstructionOffset)
{
	return ResolveRelativeAddressSelf(opcodeOffset, nextInstructionOffset);
}

//-----------------------------------------------------------------------------
// Purpose: resolves the relative pointer to offset
// Input  : registerOffset - 
//			nextInstructionOffset - 
// Output : CMemory
//-----------------------------------------------------------------------------
CMemory CMemory::ResolveRelativeAddress(const ptrdiff_t registerOffset, const ptrdiff_t nextInstructionOffset) const
{
	// Skip register.
	const uintptr_t skipRegister = ptr + registerOffset;

	// Get 4-byte long relative Address.
	const int32_t relativeAddress = *reinterpret_cast<int32_t*>(skipRegister);

	// Get location of next instruction.
	const uintptr_t nextInstruction = ptr + nextInstructionOffset;

	// Get function location via adding relative Address to next instruction.
	return CMemory(nextInstruction + relativeAddress);
}

//-----------------------------------------------------------------------------
// Purpose: resolves the relative pointer to offset from current address
// Input  : registerOffset - 
//			nextInstructionOffset - 
// Output : CMemory
//-----------------------------------------------------------------------------
CMemory CMemory::ResolveRelativeAddressSelf(const ptrdiff_t registerOffset, const ptrdiff_t nextInstructionOffset)
{
	// Skip register.
	const uintptr_t skipRegister = ptr + registerOffset;

	// Get 4-byte long relative Address.
	const int32_t relativeAddress = *reinterpret_cast<int32_t*>(skipRegister);

	// Get location of next instruction.
	const uintptr_t nextInstruction = ptr + nextInstructionOffset;

	// Get function location via adding relative Address to next instruction.
	ptr = nextInstruction + relativeAddress;
	return *this;
}

//-----------------------------------------------------------------------------
// Purpose: resolve all 'call' references to ptr 
// (This is very slow only use for mass patching.)
// Input  : sectionBase - 
//			sectionSize - 
// Output : std::vector<CMemory>
//-----------------------------------------------------------------------------
std::vector<CMemory> CMemory::FindAllCallReferences(const uintptr_t sectionBase, const size_t sectionSize)
{
	std::vector <CMemory> referencesInfo = {};

	uint8_t* pTextStart = reinterpret_cast<uint8_t*>(sectionBase);
	for (size_t i = 0ull; i < sectionSize - 0x5; i++, _mm_prefetch(reinterpret_cast<const char*>(pTextStart + 64), _MM_HINT_NTA))
	{
		if (pTextStart[i] == 0xE8)
		{
			CMemory memAddr = CMemory(&pTextStart[i]);
			if (!memAddr.Offset(0x1).CheckOpCodes({ 0x00, 0x00, 0x00, 0x00 })) // Check if its not a dynamic resolved call.
			{
				if (memAddr.FollowNearCall() == *this)
					referencesInfo.push_back(memAddr);
			}
		}
	}

	return referencesInfo;
}

//-----------------------------------------------------------------------------
// Purpose: patch virtual method to point to a user set function
// Input  : virtualTable - 
//          pHookMethod - 
//          methodIndex -
//          ppOriginalMethod -
// Output : void** via ppOriginalMethod
//-----------------------------------------------------------------------------
void CMemory::HookVirtualMethod(const uintptr_t virtualTable, const void* pHookMethod, const ptrdiff_t methodIndex, void** ppOriginalMethod)
{
	DWORD oldProt = NULL;

	// Calculate delta to next virtual method.
	const uintptr_t virtualMethod = virtualTable + (methodIndex * sizeof(ptrdiff_t));

	// Preserve original function.
	const uintptr_t originalFunction = *reinterpret_cast<uintptr_t*>(virtualMethod);

	// Set page for current virtual method to execute n read n write.
	VirtualProtect(reinterpret_cast<void*>(virtualMethod), sizeof(virtualMethod), PAGE_EXECUTE_READWRITE, &oldProt);

	// Set virtual method to our hook.
	*reinterpret_cast<uintptr_t*>(virtualMethod) = reinterpret_cast<uintptr_t>(pHookMethod);

	// Restore original page.
	VirtualProtect(reinterpret_cast<void*>(virtualMethod), sizeof(virtualMethod), oldProt, &oldProt);

	// Move original function into argument.
	*ppOriginalMethod = reinterpret_cast<void*>(originalFunction);
}

//-----------------------------------------------------------------------------
// Purpose: patch iat entry to point to a user set function
// Input  : pImportedMethod - 
//          pHookMethod - 
//          ppOriginalMethod -
// Output : void** via ppOriginalMethod
//-----------------------------------------------------------------------------
void CMemory::HookImportedFunction(const uintptr_t pImportedMethod, const void* pHookMethod, void** ppOriginalMethod)
{
	DWORD oldProt = NULL;

	// Preserve original function.
	const uintptr_t originalFunction = *reinterpret_cast<uintptr_t*>(pImportedMethod);

	// Set page for current iat entry to execute n read n write.
	VirtualProtect(reinterpret_cast<void*>(pImportedMethod), sizeof(void*), PAGE_EXECUTE_READWRITE, &oldProt);

	// Set method to our hook.
	*reinterpret_cast<uintptr_t*>(pImportedMethod) = reinterpret_cast<uintptr_t>(pHookMethod);

	// Restore original page.
	VirtualProtect(reinterpret_cast<void*>(pImportedMethod), sizeof(void*), oldProt, &oldProt);

	// Move original function into argument.
	*ppOriginalMethod = reinterpret_cast<void*>(originalFunction);
}
