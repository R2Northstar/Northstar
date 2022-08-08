#include <cstdio>

#include "pch.h"
#include "../NorthstarDedicatedTest/hookutils.h"

#define HU_ERROR(...)                                                                                                                      \
	{                                                                                                                                      \
		char err[2048];                                                                                                                    \
		snprintf(err, sizeof(err), __VA_ARGS__);                                                                                           \
		MessageBoxA(GetForegroundWindow(), err, "Northstar Wsock32 Proxy Error", 0);                                                       \
	}

void HookEnabler::CreateHook(LPVOID ppTarget, LPVOID ppDetour, LPVOID* ppOriginal, const char* targetName)
{
	// the macro for this uses ppTarget's name as targetName, and this typically starts with &
	// targetname is used for debug stuff and debug output is nicer if we don't have this
	if (*targetName == '&')
		targetName++;

	if (MH_CreateHook(ppTarget, ppDetour, ppOriginal) == MH_OK)
	{
		HookTarget* target = new HookTarget;
		target->targetAddress = ppTarget;
		target->targetName = (char*)targetName;

		m_hookTargets.push_back(target);
	}
	else
	{
		if (targetName != nullptr)
		{
			HU_ERROR("MH_CreateHook failed for function %s", targetName);
		}
		else
		{
			HU_ERROR("MH_CreateHook failed for unknown function");
		}
	}
}

HookEnabler::~HookEnabler()
{
	for (auto& hook : m_hookTargets)
	{
		if (MH_EnableHook(hook->targetAddress) != MH_OK)
		{
			if (hook->targetName != nullptr)
			{
				HU_ERROR("MH_EnableHook failed for function %s", hook->targetName);
			}
			else
			{
				HU_ERROR("MH_EnableHook failed for unknown function");
			}
		}
		else
		{
			// HU_ERROR("Enabling hook %s", hook->targetName);
		}
	}
}
