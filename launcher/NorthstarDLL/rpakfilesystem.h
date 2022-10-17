#pragma once

enum class ePakLoadSource
{
	UNTRACKED = -1, // not a pak we loaded, we shouldn't touch this one

	CONSTANT, // should be loaded at all times
	MAP // loaded from a map, should be unloaded when the map is unloaded
};

struct LoadedPak
{
	ePakLoadSource m_nLoadSource;
	int m_nPakHandle;
	size_t m_nPakNameHash;
};

class PakLoadManager
{
  private:
	std::map<int, LoadedPak> m_vLoadedPaks {};
	std::unordered_map<size_t, int> m_HashToPakHandle {};

  public:
	int LoadPakAsync(const char* pPath, const ePakLoadSource nLoadSource);
	void UnloadPak(const int nPakHandle);
	void UnloadMapPaks();
	void* LoadFile(const char* path); // this is a guess

	LoadedPak* TrackLoadedPak(ePakLoadSource nLoadSource, int nPakHandle, size_t nPakNameHash);
	void RemoveLoadedPak(int nPakHandle);

	LoadedPak* GetPakInfo(const int nPakHandle);

	int GetPakHandle(const size_t nPakNameHash);
	int GetPakHandle(const char* pPath);
};

extern PakLoadManager* g_pPakLoadManager;
