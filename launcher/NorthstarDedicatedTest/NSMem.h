#pragma once
#include "pch.h"

// KittenPopo's memory stuff, made for northstar (because I really can't handle working with northstar's original memory stuff tbh)

#pragma region Pattern Scanning
namespace NSMem {
	inline void* PatternScan(void* module, const int* pattern, int patternSize, int offset) {
		if (!module)
			return NULL;

		auto dosHeader = (PIMAGE_DOS_HEADER)module;
		auto ntHeaders = (PIMAGE_NT_HEADERS)((BYTE*)module + dosHeader->e_lfanew);

		auto sizeOfImage = ntHeaders->OptionalHeader.SizeOfImage;

		auto scanBytes = (BYTE*)module;

		for (auto i = 0; i < sizeOfImage - patternSize; ++i) {
			bool found = true;
			for (auto j = 0; j < patternSize; ++j) {
				if (scanBytes[i + j] != pattern[j] && pattern[j] != -1) {
					found = false;
					break;
				}
			}

			if (found) {
				uintptr_t addressInt = (uintptr_t)(&scanBytes[i]) + offset;
				return (uint8_t*)addressInt;
			}
		}

		return nullptr;
	}

	inline void* PatternScan(const char* moduleName, const char* pattern, int offset = 0) {
		std::vector<int> patternNums;

		bool lastChar = 0;
		int size = strlen(pattern);
		for (int i = 0; i < size; i++) {
			char c = pattern[i];

			// If this is a space character, ignore it
			if (c == ' ' || c == '\t')
				continue;

			if (c == '?') {
				// Add a wildcard (-1)
				patternNums.push_back(-1);
			} else if (i < size - 1) {
				BYTE result = 0;
				for (int j = 0; j < 2; j++) {
					int val = 0;
					char c = (pattern + i + j)[0];
					if (c >= 'a') {
						val = c - 'a' + 0xA;
					} else if (c >= 'A') {
						val = c - 'A' + 0xA;
					} else {
						val = c - '0';
					}

					result += (j == 0) ? val * 16 : val;
				}
				patternNums.push_back(result);
			}

			i++;
		}
		return PatternScan(GetModuleHandleA(moduleName), &patternNums[0], patternNums.size(), offset);
	}

	inline void BytePatch(uintptr_t address, const BYTE* vals, int size) {
		WriteProcessMemory(GetCurrentProcess(), (LPVOID)address, vals, size, NULL);
	}

	inline void BytePatch(uintptr_t address, std::initializer_list<BYTE> vals) {
		std::vector<BYTE> bytes = vals;
		if (!bytes.empty())
			BytePatch(address, &bytes[0], bytes.size());
	}

	inline void NOP(uintptr_t address, int size) {
		BYTE* buf = (BYTE*)malloc(size);
		memset(buf, 0x90, size);
		BytePatch(address, buf, size);
		free(buf);
	}

	inline bool IsMemoryReadable(void* ptr, size_t size) {
		BYTE* buffer = (BYTE*)malloc(size);

		size_t numWritten = 0;
		ReadProcessMemory(GetCurrentProcess(), ptr, buffer, size, &numWritten);
		free(buffer);

		return numWritten == size;
	}
}

#pragma region KHOOK
struct KHookPatternInfo {
	const char* moduleName, *pattern;
	int offset = 0;

	KHookPatternInfo(const char* moduleName, const char* pattern, int offset = 0) 
		: moduleName(moduleName), pattern(pattern), offset(offset) {}
};

struct KHook {
	KHookPatternInfo targetFunc;
	void* targetFuncAddr;
	void* hookFunc;
	void** original;

	static inline std::vector<KHook*> _allHooks;

	KHook(KHookPatternInfo targetFunc, void* hookFunc, void** original) : targetFunc(targetFunc) {
		this->hookFunc = hookFunc;
		this->original = original;
		_allHooks.push_back(this);
	}

	bool Setup() {
		targetFuncAddr = NSMem::PatternScan(targetFunc.moduleName, targetFunc.pattern, targetFunc.offset);
		if (!targetFuncAddr)
			return false;

		return MH_CreateHook(targetFuncAddr, hookFunc, original) == MH_OK;
	}

	// Returns true if succeeded
	static bool InitAllHooks() {
		for (KHook* hook : _allHooks) {
			if (hook->Setup()) {
				spdlog::info("KHook hooked at {}", hook->targetFuncAddr);
			} else {
				return false;
			}
		}

		return MH_EnableHook(MH_ALL_HOOKS) == MH_OK;
	}
};
#define KHOOK(name, funcPatternInfo, returnType, convention, args)                                                                             \
	returnType convention hk##name args;                                                                                                   \
	auto o##name = (returnType(convention*) args)0;                                                                                        \
	KHook k##name = KHook(KHookPatternInfo funcPatternInfo, &hk##name, (void**)&o##name);                                                                \
	returnType convention hk##name args
#pragma endregion