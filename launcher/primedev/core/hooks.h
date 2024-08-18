#pragma once

#include <string>
#include <iostream>

//-----------------------------------------------------------------------------
// Purpose: Init minhook
//-----------------------------------------------------------------------------
void HookSys_Init();

//-----------------------------------------------------------------------------
// Purpose: MH_MakeHook wrapper
// Input  : *ppOriginal - Original function being detoured
//          pDetour - Detour function
//-----------------------------------------------------------------------------
inline void HookAttach(PVOID* ppOriginal, PVOID pDetour)
{
	PVOID pAddr = *ppOriginal;
	if (MH_CreateHook(pAddr, pDetour, ppOriginal) == MH_OK)
	{
		if (MH_EnableHook(pAddr) != MH_OK)
		{
			spdlog::error("Failed enabling a function hook!");
		}
	}
	else
	{
		spdlog::error("Failed creating a function hook!");
	}
}

void CallLoadLibraryACallbacks(LPCSTR lpLibFileName, HMODULE moduleAddress);

typedef void (*DllLoadCallbackFuncType)(CModule moduleAddress);
void AddDllLoadCallback(std::string dll, DllLoadCallbackFuncType callback, std::string tag = "", std::vector<std::string> reliesOn = {});
void AddDllLoadCallbackForDedicatedServer(
	std::string dll, DllLoadCallbackFuncType callback, std::string tag = "", std::vector<std::string> reliesOn = {});
void AddDllLoadCallbackForClient(
	std::string dll, DllLoadCallbackFuncType callback, std::string tag = "", std::vector<std::string> reliesOn = {});

void CallAllPendingDLLLoadCallbacks();

// new dll load callback stuff
enum class eDllLoadCallbackSide
{
	UNSIDED,
	CLIENT,
	DEDICATED_SERVER
};

class __dllLoadCallback
{
public:
	__dllLoadCallback() = delete;
	__dllLoadCallback(
		eDllLoadCallbackSide side,
		const std::string dllName,
		DllLoadCallbackFuncType callback,
		std::string uniqueStr,
		std::string reliesOn);
};

#define __CONCAT3(x, y, z) x##y##z
#define CONCAT3(x, y, z) __CONCAT3(x, y, z)
#define __CONCAT2(x, y) x##y
#define CONCAT2(x, y) __CONCAT2(x, y)
#define __STR(s) #s

// adds a callback to be called when a given dll is loaded, for creating hooks and such
#define __ON_DLL_LOAD(dllName, side, uniquestr, reliesOn, args)                                                                            \
	void CONCAT2(__dllLoadCallback, uniquestr) args;                                                                                       \
	namespace                                                                                                                              \
	{                                                                                                                                      \
		__dllLoadCallback CONCAT2(__dllLoadCallbackInstance, __LINE__)(                                                                    \
			side, dllName, CONCAT2(__dllLoadCallback, uniquestr), __STR(uniquestr), reliesOn);                                             \
	}                                                                                                                                      \
	void CONCAT2(__dllLoadCallback, uniquestr) args

#define ON_DLL_LOAD(dllName, uniquestr, args) __ON_DLL_LOAD(dllName, eDllLoadCallbackSide::UNSIDED, uniquestr, "", args)
#define ON_DLL_LOAD_RELIESON(dllName, uniquestr, reliesOn, args)                                                                           \
	__ON_DLL_LOAD(dllName, eDllLoadCallbackSide::UNSIDED, uniquestr, __STR(reliesOn), args)
#define ON_DLL_LOAD_CLIENT(dllName, uniquestr, args) __ON_DLL_LOAD(dllName, eDllLoadCallbackSide::CLIENT, uniquestr, "", args)
#define ON_DLL_LOAD_CLIENT_RELIESON(dllName, uniquestr, reliesOn, args)                                                                    \
	__ON_DLL_LOAD(dllName, eDllLoadCallbackSide::CLIENT, uniquestr, __STR(reliesOn), args)
#define ON_DLL_LOAD_DEDI(dllName, uniquestr, args) __ON_DLL_LOAD(dllName, eDllLoadCallbackSide::DEDICATED_SERVER, uniquestr, "", args)
#define ON_DLL_LOAD_DEDI_RELIESON(dllName, uniquestr, reliesOn, args)                                                                      \
	__ON_DLL_LOAD(dllName, eDllLoadCallbackSide::DEDICATED_SERVER, uniquestr, __STR(reliesOn), args)

// new macro hook stuff
class __autohook;
class __autovar;

class __fileAutohook
{
public:
	std::vector<__autohook*> hooks;
	std::vector<__autovar*> vars;

	void Dispatch();
	void DispatchForModule(const char* pModuleName);
};

uintptr_t ParseDLLOffsetString(const char* pAddrString);

// initialise autohooks for this file
#define AUTOHOOK_INIT()                                                                                                                    \
	namespace                                                                                                                              \
	{                                                                                                                                      \
		__fileAutohook __FILEAUTOHOOK;                                                                                                     \
	}

// dispatch all autohooks in this file
#define AUTOHOOK_DISPATCH() __FILEAUTOHOOK.Dispatch();

#define AUTOHOOK_DISPATCH_MODULE(moduleName) __FILEAUTOHOOK.DispatchForModule(__STR(moduleName));

class __autohook
{
public:
	enum AddressResolutionMode
	{
		OFFSET_STRING, // we're using a string that of the format dllname.dll + offset
		ABSOLUTE_ADDR, // we're using an absolute address, we don't need to process it at all
		PROCADDRESS // resolve using GetModuleHandle and GetProcAddress
	};

	char* pFuncName;

	LPVOID pHookFunc;
	LPVOID* ppOrigFunc;

	// address resolution props
	AddressResolutionMode iAddressResolutionMode;
	char* pAddrString = nullptr; // for OFFSET_STRING
	LPVOID iAbsoluteAddress = nullptr; // for ABSOLUTE_ADDR
	char* pModuleName; // for PROCADDRESS
	char* pProcName; // for PROCADDRESS

public:
	__autohook() = delete;

	__autohook(__fileAutohook* autohook, const char* funcName, LPVOID absoluteAddress, LPVOID* orig, LPVOID func)
		: pHookFunc(func), ppOrigFunc(orig), iAbsoluteAddress(absoluteAddress)
	{
		iAddressResolutionMode = ABSOLUTE_ADDR;

		const size_t iFuncNameStrlen = strlen(funcName) + 1;
		pFuncName = new char[iFuncNameStrlen];
		memcpy(pFuncName, funcName, iFuncNameStrlen);

		autohook->hooks.push_back(this);
	}

	__autohook(__fileAutohook* autohook, const char* funcName, const char* addrString, LPVOID* orig, LPVOID func)
		: pHookFunc(func), ppOrigFunc(orig)
	{
		iAddressResolutionMode = OFFSET_STRING;

		const size_t iFuncNameStrlen = strlen(funcName) + 1;
		pFuncName = new char[iFuncNameStrlen];
		memcpy(pFuncName, funcName, iFuncNameStrlen);

		const size_t iAddrStrlen = strlen(addrString) + 1;
		pAddrString = new char[iAddrStrlen];
		memcpy(pAddrString, addrString, iAddrStrlen);

		autohook->hooks.push_back(this);
	}

	__autohook(__fileAutohook* autohook, const char* funcName, const char* moduleName, const char* procName, LPVOID* orig, LPVOID func)
		: pHookFunc(func), ppOrigFunc(orig)
	{
		iAddressResolutionMode = PROCADDRESS;

		const size_t iFuncNameStrlen = strlen(funcName) + 1;
		pFuncName = new char[iFuncNameStrlen];
		memcpy(pFuncName, funcName, iFuncNameStrlen);

		const size_t iModuleNameStrlen = strlen(moduleName) + 1;
		pModuleName = new char[iModuleNameStrlen];
		memcpy(pModuleName, moduleName, iModuleNameStrlen);

		const size_t iProcNameStrlen = strlen(procName) + 1;
		pProcName = new char[iProcNameStrlen];
		memcpy(pProcName, procName, iProcNameStrlen);

		autohook->hooks.push_back(this);
	}

	~__autohook()
	{
		delete[] pFuncName;

		if (pAddrString)
			delete[] pAddrString;

		if (pModuleName)
			delete[] pModuleName;

		if (pProcName)
			delete[] pProcName;
	}

	void Dispatch()
	{
		LPVOID targetAddr = nullptr;

		// determine the address of the function we're hooking
		switch (iAddressResolutionMode)
		{
		case ABSOLUTE_ADDR:
		{
			targetAddr = iAbsoluteAddress;
			break;
		}

		case OFFSET_STRING:
		{
			targetAddr = (LPVOID)ParseDLLOffsetString(pAddrString);
			break;
		}

		case PROCADDRESS:
		{
			targetAddr = (LPVOID)GetProcAddress(GetModuleHandleA(pModuleName), pProcName);
			break;
		}
		}

		if (!targetAddr)
			spdlog::error("Address for hook {} is invalid", pFuncName);
		else if (MH_CreateHook(targetAddr, pHookFunc, ppOrigFunc) == MH_OK)
		{
			if (MH_EnableHook(targetAddr) == MH_OK)
				spdlog::info("Enabling hook {}", pFuncName);
			else
				spdlog::error("MH_EnableHook failed for function {}", pFuncName);
		}
		else
			spdlog::error("MH_CreateHook failed for function {}", pFuncName);
	}
};

// hook a function at a given offset from a dll to be dispatched with AUTOHOOK_DISPATCH()
#define AUTOHOOK(name, addrString, type, callingConvention, args)                                                                          \
	type callingConvention CONCAT2(__autohookfunc, name) args;                                                                             \
	namespace                                                                                                                              \
	{                                                                                                                                      \
		type(*name) args;                                                                                                                  \
		__autohook CONCAT2(__autohook, __LINE__)(                                                                                          \
			&__FILEAUTOHOOK, __STR(name), __STR(addrString), (LPVOID*)&name, (LPVOID)CONCAT2(__autohookfunc, name));                       \
	}                                                                                                                                      \
	type callingConvention CONCAT2(__autohookfunc, name) args

// hook a function at a given absolute constant address to be dispatched with AUTOHOOK_DISPATCH()
#define AUTOHOOK_ABSOLUTEADDR(name, addr, type, callingConvention, args)                                                                   \
	type callingConvention CONCAT2(__autohookfunc, name) args;                                                                             \
	namespace                                                                                                                              \
	{                                                                                                                                      \
		type(*name) args;                                                                                                                  \
		__autohook                                                                                                                         \
			CONCAT2(__autohook, __LINE__)(&__FILEAUTOHOOK, __STR(name), addr, (LPVOID*)&name, (LPVOID)CONCAT2(__autohookfunc, name));      \
	}                                                                                                                                      \
	type callingConvention CONCAT2(__autohookfunc, name) args

// hook a function at a given module and exported function to be dispatched with AUTOHOOK_DISPATCH()
#define AUTOHOOK_PROCADDRESS(name, moduleName, procName, type, callingConvention, args)                                                    \
	type callingConvention CONCAT2(__autohookfunc, name) args;                                                                             \
	namespace                                                                                                                              \
	{                                                                                                                                      \
		type(*name) args;                                                                                                                  \
		__autohook CONCAT2(__autohook, __LINE__)(                                                                                          \
			&__FILEAUTOHOOK, __STR(name), __STR(moduleName), __STR(procName), (LPVOID*)&name, (LPVOID)CONCAT2(__autohookfunc, name));      \
	}                                                                                                                                      \
	type callingConvention CONCAT2(__autohookfunc, name)                                                                                   \
	args

class ManualHook
{
public:
	char* pFuncName;

	LPVOID pHookFunc;
	LPVOID* ppOrigFunc;

public:
	ManualHook() = delete;
	ManualHook(const char* funcName, LPVOID func);
	ManualHook(const char* funcName, LPVOID* orig, LPVOID func);
	bool Dispatch(LPVOID addr, LPVOID* orig = nullptr);
};

// hook a function to be dispatched manually later
#define HOOK(varName, originalFunc, type, callingConvention, args)                                                                         \
	namespace                                                                                                                              \
	{                                                                                                                                      \
		type(*originalFunc) args;                                                                                                          \
	}                                                                                                                                      \
	type callingConvention CONCAT2(__manualhookfunc, varName) args;                                                                        \
	ManualHook varName = ManualHook(__STR(varName), (LPVOID*)&originalFunc, (LPVOID)CONCAT2(__manualhookfunc, varName));                   \
	type callingConvention CONCAT2(__manualhookfunc, varName) args

#define HOOK_NOORIG(varName, type, callingConvention, args)                                                                                \
	type callingConvention CONCAT2(__manualhookfunc, varName) args;                                                                        \
	ManualHook varName = ManualHook(__STR(varName), (LPVOID)CONCAT2(__manualhookfunc, varName));                                           \
	type callingConvention CONCAT2(__manualhookfunc, varName)                                                                              \
	args

void MakeHook(LPVOID pTarget, LPVOID pDetour, void* ppOriginal, const char* pFuncName = "");
#define MAKEHOOK(pTarget, pDetour, ppOriginal) MakeHook((LPVOID)pTarget, (LPVOID)pDetour, (void*)ppOriginal, __STR(pDetour))

class __autovar
{
public:
	char* m_pAddrString;
	void** m_pTarget;

public:
	__autovar(__fileAutohook* pAutohook, const char* pAddrString, void** pTarget)
	{
		m_pTarget = pTarget;

		const size_t iAddrStrlen = strlen(pAddrString) + 1;
		m_pAddrString = new char[iAddrStrlen];
		memcpy(m_pAddrString, pAddrString, iAddrStrlen);

		pAutohook->vars.push_back(this);
	}

	void Dispatch()
	{
		*m_pTarget = (void*)ParseDLLOffsetString(m_pAddrString);
	}
};

// VAR_AT(engine.dll+0x404, ConVar*, Cvar_host_timescale)
#define VAR_AT(addrString, type, name)                                                                                                     \
	type name;                                                                                                                             \
	namespace                                                                                                                              \
	{                                                                                                                                      \
		__autovar CONCAT2(__autovar, __LINE__)(&__FILEAUTOHOOK, __STR(addrString), (void**)&name);                                         \
	}

// FUNCTION_AT(engine.dll + 0xDEADBEEF, void, __fastcall, SomeFunc, (void* a1))
#define FUNCTION_AT(addrString, type, callingConvention, name, args)                                                                       \
	type(*name) args;                                                                                                                      \
	namespace                                                                                                                              \
	{                                                                                                                                      \
		__autovar CONCAT2(__autovar, __LINE__)(&__FILEAUTOHOOK, __STR(addrString), (void**)&name);                                         \
	}

// int* g_pSomeInt;
// DEFINED_VAR_AT(engine.dll + 0x5005, g_pSomeInt)
#define DEFINED_VAR_AT(addrString, name)                                                                                                   \
	namespace                                                                                                                              \
	{                                                                                                                                      \
		__autovar CONCAT2(__autovar, __LINE__)(&__FILEAUTOHOOK, __STR(addrString), (void**)&name);                                         \
	}
