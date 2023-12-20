#pragma once

/// Determines if we are in vanilla-compatibility mode.
/// In this mode we shouldn't auth with Atlas, which prevents users from joining a
/// non-trusted server. This means that we can unrestrict client/server commands
/// as well as various other small changes for compatibility
class VanillaCompatibility
{
public:
	void SetVanillaCompatibility(bool isVanilla)
	{
		static bool bInitialised = false;
		if (bInitialised)
			return;

		bInitialised = true;
		m_bIsVanillaCompatible = isVanilla;
	}

	bool GetVanillaCompatibility()
	{
		return m_bIsVanillaCompatible;
	}

private:
	bool m_bIsVanillaCompatible = false;
};

inline VanillaCompatibility* g_pVanillaCompatibility;
