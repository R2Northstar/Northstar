//===========================================================================//
//
// Purpose: Implementation of the CMemory class.
//
// Original commit: https://github.com/IcePixelx/silver-bun/commit/72c74b455bf4d02b424096ad2f30cd65535f814c
//
//===========================================================================//
#pragma once

#include <iostream>
#include <string>
#include <vector>
#include <windows.h>
#include <psapi.h>

class CMemory
{
public:
	enum class Direction : int
	{
		DOWN = 0,
		UP,
	};

	CMemory(void) = default;
	CMemory(const uintptr_t ptr) : ptr(ptr) {}
	CMemory(const void* ptr) : ptr(uintptr_t(ptr)) {}

	inline operator uintptr_t(void) const
	{
		return ptr;
	}

	inline operator void*(void) const
	{
		return reinterpret_cast<void*>(ptr);
	}

	inline operator bool(void) const
	{
		return ptr != NULL;
	}

	inline bool operator!= (const CMemory& addr) const
	{
		return ptr != addr.ptr;
	}

	inline bool operator== (const CMemory& addr) const
	{
		return ptr == addr.ptr;
	}

	inline bool operator== (const uintptr_t& addr) const
	{
		return ptr == addr;
	}

	inline uintptr_t GetPtr(void) const
	{
		return ptr;
	}

	template<class T> inline T GetValue(void) const
	{
		return *reinterpret_cast<T*>(ptr);
	}

	template<class T> inline T GetVirtualFunctionIndex(void) const
	{
		return *reinterpret_cast<T*>(ptr) / 8;
	}

	template<typename T> inline T CCast(void) const
	{
		return (T)ptr;
	}

	template<typename T> inline T RCast(void) const
	{
		return reinterpret_cast<T>(ptr);
	}

	inline CMemory Offset(ptrdiff_t offset) const
	{
		return CMemory(ptr + offset);
	}

	inline CMemory OffsetSelf(ptrdiff_t offset)
	{
		ptr += offset;
		return *this;
	}

	inline CMemory Deref(int deref = 1) const
	{
		uintptr_t reference = ptr;

		while (deref--)
		{
			if (reference)
				reference = *reinterpret_cast<uintptr_t*>(reference);
		}

		return CMemory(reference);
	}

	inline CMemory DerefSelf(int deref = 1)
	{
		while (deref--)
		{
			if (ptr)
				ptr = *reinterpret_cast<uintptr_t*>(ptr);
		}

		return *this;
	}

	inline CMemory WalkVTable(ptrdiff_t vfuncIndex)
	{
		uintptr_t reference = ptr + (sizeof(uintptr_t) * vfuncIndex);
		return CMemory(reference);
	}

	inline CMemory WalkVTableSelf(ptrdiff_t vfuncIndex)
	{
		ptr += (sizeof(uintptr_t) * vfuncIndex);
		return *this;
	}

	bool CheckOpCodes(const std::vector<uint8_t>& vOpcodeArray) const;
	bool IsMemoryReadable(const size_t nSize) const;

	void NOP(const size_t nSize) const;
	void Patch(const char* pszOpcodes) const;
	void Patch(const uint8_t* pOpcodeArray, const size_t nSize) const;
	void Patch(const std::vector<uint8_t>& vOpcodeArray) const;
	void PatchString(const char* szString) const;

	CMemory FindPattern(const char* szPattern, const Direction searchDirect = Direction::DOWN, const int opCodesToScan = 512, const ptrdiff_t occurrence = 1) const;
	CMemory FindPatternSelf(const char* szPattern, const Direction searchDirect = Direction::DOWN, const int opCodesToScan = 512, const ptrdiff_t occurrence = 1);
	std::vector<CMemory> FindAllCallReferences(const uintptr_t sectionBase, const size_t sectionSize);

	CMemory FollowNearCall(const ptrdiff_t opcodeOffset = 0x1, const ptrdiff_t nextInstructionOffset = 0x5) const;
	CMemory FollowNearCallSelf(const ptrdiff_t opcodeOffset = 0x1, const ptrdiff_t nextInstructionOffset = 0x5);
	CMemory ResolveRelativeAddress(const ptrdiff_t registerOffset = 0x0, const ptrdiff_t nextInstructionOffset = 0x4) const;
	CMemory ResolveRelativeAddressSelf(const ptrdiff_t registerOffset = 0x0, const ptrdiff_t nextInstructionOffset = 0x4);

	static void HookVirtualMethod(const uintptr_t virtualTable, const void* pHookMethod, const ptrdiff_t methodIndex, void** ppOriginalMethod);
	static void HookImportedFunction(const uintptr_t pImportedMethod, const void* pHookMethod, void** ppOriginalMethod);

private:
	uintptr_t ptr = 0;
};
