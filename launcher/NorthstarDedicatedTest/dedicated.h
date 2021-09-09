#pragma once

bool IsDedicated();

struct CDedicatedExports; // forward declare

// functions for CDedicatedServerAPI
typedef void (*DedicatedSys_Printf)(CDedicatedExports* dedicated, char* msg);
typedef void (*DedicatedRunServer)(CDedicatedExports* dedicated);

void Sys_Printf(CDedicatedExports* dedicated, char* msg);
void RunServer(CDedicatedExports* dedicated);

// functions for running dedicated server
typedef bool (*CEngine__Frame)(void* engineSelf);
typedef void (*CEngineAPI__SetMap)(void* engineApiSelf, const char* pMapName);
typedef void (*CEngineAPI__ActivateSimulation)(void* engineApiSelf, bool bActive);

// struct used internally
struct CDedicatedExports
{
	char unused[64];
	DedicatedSys_Printf Sys_Printf; // base + 64
	DedicatedRunServer RunServer; // base + 72
};

// hooking stuff
extern bool bDedicatedHooksInitialised;
void InitialiseDedicated(HMODULE moduleAddress);
