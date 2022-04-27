#include "version.h"
#include "pch.h"
#include "ns_version.h"

char version[16];
char NSUserAgent[32];

void InitialiseVersion()
{
	constexpr int northstar_version[4] {NORTHSTAR_VERSION};

	// We actually use the rightmost integer do determine whether or not we're a debug/dev build
	// If it is set to 1, we are a dev build
	// On github CI, we set this 1 to a 0 automatically as we replace the 0,0,0,1 with the real version number
	if (northstar_version[3] == 1)
	{
		sprintf(version, "%d.%d.%d.%d+dev", northstar_version[0], northstar_version[1], northstar_version[2], northstar_version[3]);
		sprintf(NSUserAgent, "R2Northstar/%d.%d.%d+dev", northstar_version[0], northstar_version[1], northstar_version[2]);
	}
	else
	{
		sprintf(version, "%d.%d.%d.%d", northstar_version[0], northstar_version[1], northstar_version[2], northstar_version[3]);
		sprintf(NSUserAgent, "R2Northstar/%d.%d.%d", northstar_version[0], northstar_version[1], northstar_version[2]);
	}
	return;
}
