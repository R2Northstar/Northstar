#pragma once

void InitialiseEngineRpakFilesystem(HMODULE baseAddress);

class PakLoadManager
{
  public:
	void LoadPakSync(const char* path);
	void LoadPakAsync(const char* path, bool bMarkForUnload);
	void UnloadPaks();

	bool IsPakLoaded(int32_t pakHandle);
	bool IsPakLoaded(size_t hash);
	void AddLoadedPak(int32_t pakHandle, size_t hash);
	void RemoveLoadedPak(int32_t pakHandle);

  private:
	std::vector<int> m_pakHandlesToUnload;
	// these size_t s are the asset path hashed with STR_HASH
	std::unordered_map<int32_t, size_t> loadedPaks {};
	std::unordered_map<size_t, int32_t> loadedPaksInv {};
};

extern PakLoadManager* g_PakLoadManager;