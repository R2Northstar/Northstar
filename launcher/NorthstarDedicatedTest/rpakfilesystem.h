#pragma once

void InitialiseEngineRpakFilesystem(HMODULE baseAddress);

class PakLoadManager
{
  public:
	void LoadPakSync(const char* path);
	void LoadPakAsync(const char* path);
};

extern PakLoadManager* g_PakLoadManager;