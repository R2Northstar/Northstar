#pragma once

// use the R2 namespace for game funcs
namespace R2
{
	inline const char* (*GetCurrentPlaylistName)();
	inline void (*SetCurrentPlaylist)(const char* pPlaylistName);
	inline void (*SetPlaylistVarOverride)(const char* pVarName, const char* pValue);
	inline const char* (*GetCurrentPlaylistVar)(const char* pVarName, bool bUseOverrides);
} // namespace R2
