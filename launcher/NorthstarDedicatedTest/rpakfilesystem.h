#pragma once

void InitialiseEngineRpakFilesystem(HMODULE baseAddress);

class PakLoadManager
{
  public:
	void LoadPakSync(const char* path);
	void LoadPakAsync(const char* path, bool bMarkForUnload);
	void UnloadPaks();

  private:
	std::vector<int> m_pakHandlesToUnload;
};

extern PakLoadManager* g_PakLoadManager;