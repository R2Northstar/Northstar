#pragma once
#include <string>

void InstallInitialHooks();

typedef void (*DllLoadCallbackFuncType)(HMODULE moduleAddress);
void AddDllLoadCallback(std::string dll, DllLoadCallbackFuncType callback);
void AddDllLoadCallbackForDedicatedServer(std::string dll, DllLoadCallbackFuncType callback);
void AddDllLoadCallbackForClient(std::string dll, DllLoadCallbackFuncType callback);

void CallAllPendingDLLLoadCallbacks();