#include "pch.h"
#include "sigscanning.h"
#include <map>

// note: sigscanning is only really intended to be used for resolving stuff like shared function definitions
// we mostly use raw function addresses for stuff

size_t GetDLLLength(HMODULE moduleHandle)
{
	// based on sigscn code from ttf2sdk, which is in turn based on CSigScan from https://wiki.alliedmods.net/Signature_Scanning
	MEMORY_BASIC_INFORMATION mem;
	VirtualQuery(moduleHandle, &mem, sizeof(mem));

	IMAGE_DOS_HEADER* dos = (IMAGE_DOS_HEADER*)mem.AllocationBase;
	IMAGE_NT_HEADERS* pe = (IMAGE_NT_HEADERS*)((unsigned char*)dos + dos->e_lfanew);

	return pe->OptionalHeader.SizeOfImage;
}

void* FindSignature(std::string dllName, const char* sig, const char* mask)
{
	HMODULE dllAddress = GetModuleHandleA(dllName.c_str());
	char* dllEnd = (char*)(dllAddress + GetDLLLength(dllAddress));

	size_t sigLength = strlen(mask);

	for (char* i = (char*)dllAddress; i < dllEnd - sigLength; i++)
	{
		int j = 0;
		for (; j < sigLength; j++)
			if (mask[j] != '?' && sig[j] != i[j])
				break;

		if (j == sigLength) // loop finished of its own accord
			return (void*)i;
	}

	return nullptr;
}
