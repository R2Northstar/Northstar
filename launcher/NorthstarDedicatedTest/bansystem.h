#pragma once
#include <fstream>

class ServerBanSystem
{
  private:
	std::ofstream m_sBanlistStream;
	std::vector<uint64_t> m_vBannedUids;

  public:
	void OpenBanlist();
	void ClearBanlist();
	void BanUID(uint64_t uid);
	void UnbanUID(uint64_t uid);
	bool IsUIDAllowed(uint64_t uid);
};

extern ServerBanSystem* g_ServerBanSystem;

void InitialiseBanSystem(HMODULE baseAddress);