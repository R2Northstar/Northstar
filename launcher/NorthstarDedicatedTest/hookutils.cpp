#include "pch.h"
#include "hookutils.h"

#include <iostream>

TempReadWrite::TempReadWrite(void* ptr)
{
	m_ptr = ptr;
	MEMORY_BASIC_INFORMATION mbi;
	VirtualQuery(m_ptr, &mbi, sizeof(mbi));
	VirtualProtect(mbi.BaseAddress, mbi.RegionSize, PAGE_EXECUTE_READWRITE, &mbi.Protect);
	m_origProtection = mbi.Protect;
}

TempReadWrite::~TempReadWrite()
{
	MEMORY_BASIC_INFORMATION mbi;
	VirtualQuery(m_ptr, &mbi, sizeof(mbi));
	VirtualProtect(mbi.BaseAddress, mbi.RegionSize, m_origProtection, &mbi.Protect);
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
			spdlog::error("MH_CreateHook failed for function {}", targetName);
		else
			spdlog::error("MH_CreateHook failed for unknown function");
	}
}

HookEnabler::~HookEnabler()
{
	for (auto& hook : m_hookTargets)
	{
		if (MH_EnableHook(hook->targetAddress) != MH_OK)
		{
			if (hook->targetName != nullptr)
				spdlog::error("MH_EnableHook failed for function {}", hook->targetName);
			else
				spdlog::error("MH_EnableHook failed for unknown function");
		}
		else
			spdlog::info("Enabling hook {}", hook->targetName);
	}
}