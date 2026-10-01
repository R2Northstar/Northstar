#include "origin.h"
#include <cstdint>

static bool(__fastcall* o_pCheckIfOriginIsInstalled)() = nullptr;
static bool __fastcall h_CheckIfOriginIsInstalled()
{
	if (!strstr(GetCommandLineA(), "-noOriginStartup"))
		return o_pCheckIfOriginIsInstalled();

	if (o_pCheckIfOriginIsInstalled())
	{
		NS::log::NORTHSTAR->warn(
			"Origin is NOT installed according to OriginSDK's check (HKLM\\SOFTWARE\\Wow6432Node\\Origin\\ClientPath is missing/empty).");
		NS::log::NORTHSTAR->warn("We are bypassing this check in case LSX server is remotely ran (such as in Linux in another WINE "
								 "prefix), but note that things will fail if Origin is actually not running.");
	}

	return true;
}

static uint64_t(__fastcall* o_pTryToStartOrigin)(void* a1) = nullptr;
static uint64_t __fastcall h_TryToStartOrigin(void* a1)
{
	if (!strstr(GetCommandLineA(), "-noOriginStartup"))
		return o_pTryToStartOrigin(a1);

	if (o_pTryToStartOrigin(a1) != 0)
	{
		NS::log::NORTHSTAR->warn("Origin process has failed to start. We are ignoring this and let it fail on LSX connection attempt, "
								 "because LSX might still be up regardless, even if this failed.");
	}
	return 0;
}

ON_DLL_LOAD("OriginSDK.dll", OriginSDKFuncs, (CModule module))
{
	// these hooks are required for linux to work without EA app or Origin in the same wine prefix

	o_pCheckIfOriginIsInstalled = module.Offset(0xa1850).RCast<decltype(o_pCheckIfOriginIsInstalled)>();
	HookAttach(&(PVOID&)o_pCheckIfOriginIsInstalled, (PVOID)h_CheckIfOriginIsInstalled);

	o_pTryToStartOrigin = module.Offset(0xa19b0).RCast<decltype(o_pTryToStartOrigin)>();
	HookAttach(&(PVOID&)o_pTryToStartOrigin, (PVOID)h_TryToStartOrigin);
}
