#pragma once
#include "pch.h"
#include "dedicated.h"
#include "dedicatedmaterialsystem.h"
#include "hookutils.h"
#include "gameutils.h"

typedef HRESULT (*__stdcall D3D11CreateDeviceType)(
	void* pAdapter, int DriverType, HMODULE Software, UINT Flags, int* pFeatureLevels, UINT FeatureLevels, UINT SDKVersion, void** ppDevice,
	int* pFeatureLevel, void** ppImmediateContext);
D3D11CreateDeviceType D3D11CreateDevice;

HRESULT __stdcall D3D11CreateDeviceHook(
	void* pAdapter, int DriverType, HMODULE Software, UINT Flags, int* pFeatureLevels, UINT FeatureLevels, UINT SDKVersion, void** ppDevice,
	int* pFeatureLevel, void** ppImmediateContext)
{
	// note: this is super duper temp pretty much just messing around with it
	// does run surprisingly well on dedi for a software driver tho if you ignore the +1gb ram usage at times, seems like dedi doesn't
	// really call gpu much even with renderthread still being a thing will be using this hook for actual d3d stubbing and stuff later

	// atm, i think the play might be to run d3d in software, and then just stub out any calls that allocate memory/use alot of resources
	// (e.g. createtexture and that sorta thing)
	// note: this has been succeeded by the d3d11 and gfsdk stubs, and is only being kept around for posterity and as a fallback option
	if (CommandLine()->CheckParm("-softwared3d11"))
		DriverType = 5; // D3D_DRIVER_TYPE_WARP

	return D3D11CreateDevice(
		pAdapter, DriverType, Software, Flags, pFeatureLevels, FeatureLevels, SDKVersion, ppDevice, pFeatureLevel, ppImmediateContext);
}

void InitialiseDedicatedMaterialSystem(HMODULE baseAddress)
{
	if (!IsDedicated())
		return;

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0xD9A0E, &D3D11CreateDeviceHook, reinterpret_cast<LPVOID*>(&D3D11CreateDevice));

	// not using these for now since they're related to nopping renderthread/gamewindow i.e. very hard
	//{
	//	// function that launches renderthread
	//	char* ptr = (char*)baseAddress + 0x87047;
	//	TempReadWrite rw(ptr);
	//
	//	// make it not launch renderthread
	//	*ptr = (char)0x90;
	//	*(ptr + 1) = (char)0x90;
	//	*(ptr + 2) = (char)0x90;
	//	*(ptr + 3) = (char)0x90;
	//	*(ptr + 4) = (char)0x90;
	//	*(ptr + 5) = (char)0x90;
	//}
	//
	//{
	//	// some function that waits on renderthread job
	//	char* ptr = (char*)baseAddress + 0x87d00;
	//	TempReadWrite rw(ptr);
	//
	//	// return immediately
	//	*ptr = (char)0xC3;
	//}

	{
		// CMaterialSystem::FindMaterial
		char* ptr = (char*)baseAddress + 0x5F0F1;
		TempReadWrite rw(ptr);

		// make the game always use the error material
		*ptr = (char)0xE9;
		*(ptr + 1) = (char)0x34;
		*(ptr + 2) = (char)0x03;
		*(ptr + 3) = (char)0x00;
	}

	// previously had DisableDedicatedWindowCreation stuff here, removing for now since shit and unstable
	// check commit history if needed
}

typedef void* (*PakLoadAPI__LoadRpakType)(char* filename, void* unknown, int flags);
PakLoadAPI__LoadRpakType PakLoadAPI__LoadRpak;

void* PakLoadAPI__LoadRpakHook(char* filename, void* unknown, int flags)
{
	spdlog::info("PakLoadAPI__LoadRpakHook {}", filename);

	// on dedi, don't load any paks that aren't required
	if (strncmp(filename, "common", 6))
		return 0;

	return PakLoadAPI__LoadRpak(filename, unknown, flags);
}

typedef void* (*PakLoadAPI__LoadRpak2Type)(char* filename, void* unknown, int flags, void* callback, void* callback2);
PakLoadAPI__LoadRpak2Type PakLoadAPI__LoadRpak2;

void* PakLoadAPI__LoadRpak2Hook(char* filename, void* unknown, int flags, void* callback, void* callback2)
{
	spdlog::info("PakLoadAPI__LoadRpak2Hook {}", filename);

	// on dedi, don't load any paks that aren't required
	if (strncmp(filename, "common", 6))
		return 0;

	return PakLoadAPI__LoadRpak2(filename, unknown, flags, callback, callback2);
}

void InitialiseDedicatedRtechGame(HMODULE baseAddress)
{
	if (!IsDedicated())
		return;

	baseAddress = GetModuleHandleA("rtech_game.dll");

	HookEnabler hook;
	// unfortunately this is unstable, seems to freeze when changing maps
	// ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0xB0F0, &PakLoadAPI__LoadRpakHook, reinterpret_cast<LPVOID*>(&PakLoadAPI__LoadRpak));
	// ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0xB170, &PakLoadAPI__LoadRpak2Hook, reinterpret_cast<LPVOID*>(&PakLoadAPI__LoadRpak2));
}