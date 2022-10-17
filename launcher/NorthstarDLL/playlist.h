#pragma once

// use the R2 namespace for game funcs
namespace R2
{
	extern const char* (*GetCurrentPlaylistName)();
	extern void (*SetCurrentPlaylist)(const char* pPlaylistName);
	extern void (*SetPlaylistVarOverride)(const char* pVarName, const char* pValue);
	extern const char* (*GetCurrentPlaylistVar)(const char* pVarName, bool bUseOverrides);
} // namespace R2
