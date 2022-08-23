#pragma once
#include <vector>

// Enables all hooks created with the HookEnabler object when it goes out of scope and handles hook errors
class HookEnabler
{
  private:
	struct HookTarget
	{
		char* targetName;
		LPVOID targetAddress;
	};

	std::vector<HookTarget*> m_hookTargets;

  public:
	void CreateHook(LPVOID ppTarget, LPVOID ppDetour, LPVOID* ppOriginal, const char* targetName = nullptr);
	~HookEnabler();
};

// macro to call HookEnabler::CreateHook with the hook's name
#define ENABLER_CREATEHOOK(enabler, ppTarget, ppDetour, ppOriginal)                                                                        \
	enabler.CreateHook(ppTarget, reinterpret_cast<void*>(ppDetour), ppOriginal, #ppDetour)
