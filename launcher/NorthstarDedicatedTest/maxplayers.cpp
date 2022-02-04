#include "pch.h"
#include "maxplayers.h"
#include "gameutils.h"

// never set this to anything below 32
#define NEW_MAX_PLAYERS 64
// dg note: the theoretical limit is actually 100, 76 works without entity issues, and 64 works without clientside prediction issues.

#define PAD_NUMBER(number, boundary) (((number) + ((boundary)-1)) / (boundary)) * (boundary)

// this is horrible
constexpr int PlayerResource_Name_Start = 0;						  // Start of modded allocated space.
constexpr int PlayerResource_Name_Size = ((NEW_MAX_PLAYERS + 1) * 8); // const char* m_szName[MAX_PLAYERS + 1];

constexpr int PlayerResource_Ping_Start = PlayerResource_Name_Start + PlayerResource_Name_Size;
constexpr int PlayerResource_Ping_Size = ((NEW_MAX_PLAYERS + 1) * 4); // int m_iPing[MAX_PLAYERS + 1];

constexpr int PlayerResource_Team_Start = PlayerResource_Ping_Start + PlayerResource_Ping_Size;
constexpr int PlayerResource_Team_Size = ((NEW_MAX_PLAYERS + 1) * 4); // int m_iTeam[MAX_PLAYERS + 1];

constexpr int PlayerResource_PRHealth_Start = PlayerResource_Team_Start + PlayerResource_Team_Size;
constexpr int PlayerResource_PRHealth_Size = ((NEW_MAX_PLAYERS + 1) * 4); // int m_iPRHealth[MAX_PLAYERS + 1];

constexpr int PlayerResource_Connected_Start = PlayerResource_PRHealth_Start + PlayerResource_PRHealth_Size;
constexpr int PlayerResource_Connected_Size = ((NEW_MAX_PLAYERS + 1) * 4); // int (used as a bool) m_bConnected[MAX_PLAYERS + 1];

constexpr int PlayerResource_Alive_Start = PlayerResource_Connected_Start + PlayerResource_Connected_Size;
constexpr int PlayerResource_Alive_Size = ((NEW_MAX_PLAYERS + 1) * 4); // int (used as a bool) m_bAlive[MAX_PLAYERS + 1];

constexpr int PlayerResource_BoolStats_Start = PlayerResource_Alive_Start + PlayerResource_Alive_Size;
constexpr int PlayerResource_BoolStats_Size = ((NEW_MAX_PLAYERS + 1) * 4); // int (used as a bool idk) m_boolStats[MAX_PLAYERS + 1];

constexpr int PlayerResource_KillStats_Start = PlayerResource_BoolStats_Start + PlayerResource_BoolStats_Size;
constexpr int PlayerResource_KillStats_Length = PAD_NUMBER((NEW_MAX_PLAYERS + 1) * 6, 4);
constexpr int PlayerResource_KillStats_Size = (PlayerResource_KillStats_Length * 6); // int m_killStats[MAX_PLAYERS + 1][6];

constexpr int PlayerResource_ScoreStats_Start = PlayerResource_KillStats_Start + PlayerResource_KillStats_Size;
constexpr int PlayerResource_ScoreStats_Length = PAD_NUMBER((NEW_MAX_PLAYERS + 1) * 5, 4);
constexpr int PlayerResource_ScoreStats_Size = (PlayerResource_ScoreStats_Length * 4); // int m_scoreStats[MAX_PLAYERS + 1][5];

// must be the usage of the last field to account for any possible paddings
constexpr int PlayerResource_TotalSize = PlayerResource_ScoreStats_Start + PlayerResource_ScoreStats_Size;

constexpr int Team_PlayerArray_AddedLength = NEW_MAX_PLAYERS - 32;
constexpr int Team_PlayerArray_AddedSize = PAD_NUMBER(Team_PlayerArray_AddedLength * 8, 4);
constexpr int Team_AddedSize = Team_PlayerArray_AddedSize;

template <class T> void ChangeOffset(void* addr, unsigned int offset)
{
	TempReadWrite rw(addr);
	*((T*)addr) = offset;
}

/*
typedef bool(*MatchRecvPropsToSendProps_R_Type)(__int64 lookup, __int64 tableNameBroken, __int64 sendTable, __int64 recvTable);
MatchRecvPropsToSendProps_R_Type MatchRecvPropsToSendProps_R_Original;

bool MatchRecvPropsToSendProps_R_Hook(__int64 lookup, __int64 tableNameBroken, __int64 sendTable, __int64 recvTable)
{
	const char* tableName = *(const char**)(sendTable + 0x118);

	spdlog::info("MatchRecvPropsToSendProps_R table name {}", tableName);

	bool orig = MatchRecvPropsToSendProps_R_Original(lookup, tableNameBroken, sendTable, recvTable);
	return orig;
}

typedef bool(*DataTable_SetupReceiveTableFromSendTable_Type)(__int64 sendTable, bool needsDecoder);
DataTable_SetupReceiveTableFromSendTable_Type DataTable_SetupReceiveTableFromSendTable_Original;

bool DataTable_SetupReceiveTableFromSendTable_Hook(__int64 sendTable, bool needsDecoder)
{
	const char* tableName = *(const char**)(sendTable + 0x118);

	spdlog::info("DataTable_SetupReceiveTableFromSendTable table name {}", tableName);
	if (!strcmp(tableName, "m_bConnected")) {
		char f[64];
		sprintf_s(f, "%p", sendTable);
		MessageBoxA(0, f, "DataTable_SetupReceiveTableFromSendTable", 0);
	}

	return DataTable_SetupReceiveTableFromSendTable_Original(sendTable, needsDecoder);
}
*/

typedef void* (*StringTables_CreateStringTable_Type)(
	__int64 thisptr, const char* name, int maxentries, int userdatafixedsize, int userdatanetworkbits, int flags);
StringTables_CreateStringTable_Type StringTables_CreateStringTable_Original;

void* StringTables_CreateStringTable_Hook(
	__int64 thisptr, const char* name, int maxentries, int userdatafixedsize, int userdatanetworkbits, int flags)
{
	// Change the amount of entries to account for a bigger player amount
	if (!strcmp(name, "userinfo"))
	{
		int maxPlayersPowerOf2 = 1;
		while (maxPlayersPowerOf2 < NEW_MAX_PLAYERS)
			maxPlayersPowerOf2 <<= 1;

		maxentries = maxPlayersPowerOf2;
	}

	return StringTables_CreateStringTable_Original(thisptr, name, maxentries, userdatafixedsize, userdatanetworkbits, flags);
}

bool MaxPlayersIncreaseEnabled() { return CommandLine() && CommandLine()->CheckParm("-experimentalmaxplayersincrease"); }

void InitialiseMaxPlayersOverride_Engine(HMODULE baseAddress)
{
	if (!MaxPlayersIncreaseEnabled())
		return;

	// patch GetPlayerLimits to ignore the boundary limit
	ChangeOffset<unsigned char>((char*)baseAddress + 0x116458, 0xEB); // jle => jmp

	// patch ED_Alloc to change nFirstIndex
	ChangeOffset<int>((char*)baseAddress + 0x18F46C + 1, NEW_MAX_PLAYERS + 8 + 1); // original: 41 (sv.GetMaxClients() + 1)

	// patch CGameServer::SpawnServer to change GetMaxClients inline
	ChangeOffset<int>((char*)baseAddress + 0x119543 + 2, NEW_MAX_PLAYERS + 8 + 1); // original: 41 (sv.GetMaxClients() + 1)

	// patch CGameServer::SpawnServer to change for loop
	ChangeOffset<unsigned char>((char*)baseAddress + 0x11957F + 2, NEW_MAX_PLAYERS); // original: 32

	// patch CGameServer::SpawnServer to change for loop (there are two)
	ChangeOffset<unsigned char>((char*)baseAddress + 0x119586 + 2, NEW_MAX_PLAYERS + 1); // original: 33 (32 + 1)

	// patch max players somewhere in CClientState
	ChangeOffset<unsigned char>((char*)baseAddress + 0x1A162C + 2, NEW_MAX_PLAYERS - 1); // original: 31 (32 - 1)

	// patch max players in userinfo stringtable creation
	/*{
		int maxPlayersPowerOf2 = 1;
		while (maxPlayersPowerOf2 < NEW_MAX_PLAYERS)
			maxPlayersPowerOf2 <<= 1;
		ChangeOffset<unsigned char>((char*)baseAddress + 0x114B79 + 3, maxPlayersPowerOf2); // original: 32
	}*/
	// this is not supposed to work at all but it does on 64 players (how)
	// proper fix below

	// patch max players in userinfo stringtable creation loop
	ChangeOffset<unsigned char>((char*)baseAddress + 0x114C48 + 2, NEW_MAX_PLAYERS); // original: 32

	// do not load prebaked SendTable message list
	ChangeOffset<unsigned char>((char*)baseAddress + 0x75859, 0xEB); // jnz -> jmp

	HookEnabler hook;

	// ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x209000, &MatchRecvPropsToSendProps_R_Hook,
	// reinterpret_cast<LPVOID*>(&MatchRecvPropsToSendProps_R_Original)); ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x1FACD0,
	// &DataTable_SetupReceiveTableFromSendTable_Hook, reinterpret_cast<LPVOID*>(&DataTable_SetupReceiveTableFromSendTable_Original));

	ENABLER_CREATEHOOK(
		hook, (char*)baseAddress + 0x22E220, &StringTables_CreateStringTable_Hook,
		reinterpret_cast<LPVOID*>(&StringTables_CreateStringTable_Original));
}

typedef void (*RunUserCmds_Type)(bool a1, float a2);
RunUserCmds_Type RunUserCmds_Original;

HMODULE serverBase = 0;
auto RandomIntZeroMax = (__int64(__fastcall*)())0;

// lazy rebuild
void RunUserCmds_Hook(bool a1, float a2)
{
	unsigned char v3;			  // bl
	int v5;						  // er14
	int i;						  // edi
	__int64 v7;					  // rax
	DWORD* v8;					  // rbx
	int v9;						  // edi
	__int64* v10;				  // rsi
	__int64 v11;				  // rax
	int v12;					  // er12
	__int64 v13;				  // rdi
	int v14;					  // ebx
	int v15;					  // eax
	__int64 v16;				  // r8
	int v17;					  // edx
	char v18;					  // r15
	char v19;					  // bp
	int v20;					  // esi
	__int64* v21;				  // rdi
	__int64 v22;				  // rcx
	bool v23;					  // al
	__int64 v24;				  // rax
	__int64 v25[NEW_MAX_PLAYERS]; // [rsp+20h] [rbp-138h] BYREF

	uintptr_t base = (__int64)serverBase;
	auto g_pGlobals = *(__int64*)(base + 0xBFBE08);
	__int64 globals = g_pGlobals;

	auto g_pEngineServer = *(__int64*)(base + 0xBFBD98);

	auto qword_1814D9648 = *(__int64*)(base + 0x14D9648);
	auto qword_1814DA408 = *(__int64*)(base + 0x14DA408);
	auto qword_1812107E8 = *(__int64*)(base + 0x12107E8);
	auto qword_1812105A8 = *(__int64*)(base + 0x12105A8);

	auto UTIL_PlayerByIndex = (__int64(__fastcall*)(int index))(base + 0x26AA10);
	auto sub_180485590 = (void(__fastcall*)(__int64))(base + 0x485590);
	auto sub_18058CD80 = (void(__fastcall*)(__int64))(base + 0x58CD80);
	auto sub_1805A6D90 = (void(__fastcall*)(__int64))(base + 0x5A6D90);
	auto sub_1805A6E50 = (bool(__fastcall*)(__int64, int, char))(base + 0x5A6E50);
	auto sub_1805A6C20 = (void(__fastcall*)(__int64))(base + 0x5A6C20);

	v3 = *(unsigned char*)(g_pGlobals + 73);
	if (*(DWORD*)(qword_1814D9648 + 92) &&
		((*(unsigned __int8(__fastcall**)(__int64))(*(__int64*)g_pEngineServer + 32i64))(g_pEngineServer) ||
		 !*(DWORD*)(qword_1814DA408 + 92)) &&
		v3)
	{
		globals = g_pGlobals;
		v5 = 1;
		for (i = 1; i <= *(DWORD*)(g_pGlobals + 52); ++i)
		{
			v7 = UTIL_PlayerByIndex(i);
			v8 = (DWORD*)v7;
			if (v7)
			{
				*(__int64*)(base + 0x1210420) = v7;
				*(float*)(g_pGlobals + 16) = a2;
				if (!a1)
					sub_18058CD80(v7);
				sub_1805A6D90((__int64)v8);
			}
			globals = g_pGlobals;
		}
		memset(v25, 0, sizeof(v25));
		v9 = 0;
		if (*(int*)(globals + 52) > 0)
		{
			v10 = v25;
			do
			{
				v11 = UTIL_PlayerByIndex(++v9);
				globals = g_pGlobals;
				*v10++ = v11;
			} while (v9 < *(DWORD*)(globals + 52));
		}
		v12 = *(DWORD*)(qword_1812107E8 + 92);
		if (*(DWORD*)(qword_1812105A8 + 92))
		{
			v13 = *(DWORD*)(globals + 52) - 1;
			if (v13 >= 1)
			{
				v14 = *(DWORD*)(globals + 52);
				do
				{
					v15 = RandomIntZeroMax();
					v16 = v25[v13--];
					v17 = v15 % v14--;
					v25[v13 + 1] = v25[v17];
					v25[v17] = v16;
				} while (v13 >= 1);
				globals = g_pGlobals;
			}
		}
		v18 = 1;
		do
		{
			v19 = 0;
			v20 = 0;
			if (*(int*)(globals + 52) > 0)
			{
				v21 = v25;
				do
				{
					v22 = *v21;
					if (*v21)
					{
						*(__int64*)(base + 0x1210420) = *v21;
						*(float*)(globals + 16) = a2;
						v23 = sub_1805A6E50(v22, v12, v18);
						globals = g_pGlobals;
						if (v23)
							v19 = 1;
						else
							*v21 = 0i64;
					}
					++v20;
					++v21;
				} while (v20 < *(DWORD*)(globals + 52));
			}
			v18 = 0;
		} while (v19);
		if (*(int*)(globals + 52) >= 1)
		{
			do
			{
				v24 = UTIL_PlayerByIndex(v5);
				if (v24)
				{
					*(__int64*)(base + 0x1210420) = v24;
					*(float*)(g_pGlobals + 16) = a2;
					sub_1805A6C20(v24);
				}
				++v5;
			} while (v5 <= *(DWORD*)(g_pGlobals + 52));
		}
		sub_180485590(*(__int64*)(base + 0xB7B2D8));
	}
}

typedef __int64 (*SendPropArray2_Type)(__int64 recvProp, int elements, int flags, const char* name, __int64 proxyFn, unsigned char unk1);
SendPropArray2_Type SendPropArray2_Original;

__int64 __fastcall SendPropArray2_Hook(__int64 recvProp, int elements, int flags, const char* name, __int64 proxyFn, unsigned char unk1)
{
	// Change the amount of elements to account for a bigger player amount
	if (!strcmp(name, "\"player_array\""))
		elements = NEW_MAX_PLAYERS;

	return SendPropArray2_Original(recvProp, elements, flags, name, proxyFn, unk1);
}

void InitialiseMaxPlayersOverride_Server(HMODULE baseAddress)
{
	if (!MaxPlayersIncreaseEnabled())
		return;

	// get required data
	serverBase = GetModuleHandleA("server.dll");
	RandomIntZeroMax = (decltype(RandomIntZeroMax))(GetProcAddress(GetModuleHandleA("vstdlib.dll"), "RandomIntZeroMax"));

	// patch max players amount
	ChangeOffset<unsigned char>((char*)baseAddress + 0x9A44D + 3, NEW_MAX_PLAYERS); // 0x20 (32) => 0x80 (128)

	// patch SpawnGlobalNonRewinding to change forced edict index
	ChangeOffset<unsigned char>((char*)baseAddress + 0x2BC403 + 2, NEW_MAX_PLAYERS + 1); // original: 33 (32 + 1)

	constexpr int CPlayerResource_OriginalSize = 4776;
	constexpr int CPlayerResource_AddedSize = PlayerResource_TotalSize;
	constexpr int CPlayerResource_ModifiedSize = CPlayerResource_OriginalSize + CPlayerResource_AddedSize;

	// CPlayerResource class allocation function - allocate a bigger amount to fit all new max player data
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C560A + 1, CPlayerResource_ModifiedSize);

	// DT_PlayerResource::m_iPing SendProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C5059 + 2, CPlayerResource_OriginalSize + PlayerResource_Ping_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C50A8 + 2, CPlayerResource_OriginalSize + PlayerResource_Ping_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C50E2 + 4, NEW_MAX_PLAYERS + 1);

	// DT_PlayerResource::m_iPing DataMap
	ChangeOffset<unsigned int>((char*)baseAddress + 0xB94598, CPlayerResource_OriginalSize + PlayerResource_Ping_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB9459C, NEW_MAX_PLAYERS + 1);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB945C0, PlayerResource_Ping_Size);

	// DT_PlayerResource::m_iTeam SendProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C5110 + 2, CPlayerResource_OriginalSize + PlayerResource_Team_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C519C + 2, CPlayerResource_OriginalSize + PlayerResource_Team_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C517E + 4, NEW_MAX_PLAYERS + 1);

	// DT_PlayerResource::m_iTeam DataMap
	ChangeOffset<unsigned int>((char*)baseAddress + 0xB94600, CPlayerResource_OriginalSize + PlayerResource_Team_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB94604, NEW_MAX_PLAYERS + 1);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB94628, PlayerResource_Team_Size);

	// DT_PlayerResource::m_iPRHealth SendProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C51C0 + 2, CPlayerResource_OriginalSize + PlayerResource_PRHealth_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C5204 + 2, CPlayerResource_OriginalSize + PlayerResource_PRHealth_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C523E + 4, NEW_MAX_PLAYERS + 1);

	// DT_PlayerResource::m_iPRHealth DataMap
	ChangeOffset<unsigned int>((char*)baseAddress + 0xB94668, CPlayerResource_OriginalSize + PlayerResource_PRHealth_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB9466C, NEW_MAX_PLAYERS + 1);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB94690, PlayerResource_PRHealth_Size);

	// DT_PlayerResource::m_bConnected SendProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C526C + 2, CPlayerResource_OriginalSize + PlayerResource_Connected_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C52B4 + 2, CPlayerResource_OriginalSize + PlayerResource_Connected_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C52EE + 4, NEW_MAX_PLAYERS + 1);

	// DT_PlayerResource::m_bConnected DataMap
	ChangeOffset<unsigned int>((char*)baseAddress + 0xB946D0, CPlayerResource_OriginalSize + PlayerResource_Connected_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB946D4, NEW_MAX_PLAYERS + 1);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB946F8, PlayerResource_Connected_Size);

	// DT_PlayerResource::m_bAlive SendProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C5321 + 2, CPlayerResource_OriginalSize + PlayerResource_Alive_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C5364 + 2, CPlayerResource_OriginalSize + PlayerResource_Alive_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C539E + 4, NEW_MAX_PLAYERS + 1);

	// DT_PlayerResource::m_bAlive DataMap
	ChangeOffset<unsigned int>((char*)baseAddress + 0xB94738, CPlayerResource_OriginalSize + PlayerResource_Alive_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB9473C, NEW_MAX_PLAYERS + 1);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB94760, PlayerResource_Alive_Size);

	// DT_PlayerResource::m_boolStats SendProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C53CC + 2, CPlayerResource_OriginalSize + PlayerResource_BoolStats_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C5414 + 2, CPlayerResource_OriginalSize + PlayerResource_BoolStats_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C544E + 4, NEW_MAX_PLAYERS + 1);

	// DT_PlayerResource::m_boolStats DataMap
	ChangeOffset<unsigned int>((char*)baseAddress + 0xB947A0, CPlayerResource_OriginalSize + PlayerResource_BoolStats_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB947A4, NEW_MAX_PLAYERS + 1);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB947C8, PlayerResource_BoolStats_Size);

	// DT_PlayerResource::m_killStats SendProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C547C + 2, CPlayerResource_OriginalSize + PlayerResource_KillStats_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C54E2 + 2, CPlayerResource_OriginalSize + PlayerResource_KillStats_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C54FE + 4, PlayerResource_KillStats_Length);

	// DT_PlayerResource::m_killStats DataMap
	ChangeOffset<unsigned int>((char*)baseAddress + 0xB94808, CPlayerResource_OriginalSize + PlayerResource_KillStats_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB9480C, PlayerResource_KillStats_Length);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB94830, PlayerResource_KillStats_Size);

	// DT_PlayerResource::m_scoreStats SendProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C5528 + 2, CPlayerResource_OriginalSize + PlayerResource_ScoreStats_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C5576 + 2, CPlayerResource_OriginalSize + PlayerResource_ScoreStats_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C5584 + 4, PlayerResource_ScoreStats_Length);

	// DT_PlayerResource::m_scoreStats DataMap
	ChangeOffset<unsigned int>((char*)baseAddress + 0xB94870, CPlayerResource_OriginalSize + PlayerResource_ScoreStats_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB94874, PlayerResource_ScoreStats_Length);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xB94898, PlayerResource_ScoreStats_Size);

	// CPlayerResource::UpdatePlayerData - m_bConnected
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C66EE + 4, CPlayerResource_OriginalSize + PlayerResource_Connected_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C672E + 4, CPlayerResource_OriginalSize + PlayerResource_Connected_Start);

	// CPlayerResource::UpdatePlayerData - m_iPing
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C6394 + 4, CPlayerResource_OriginalSize + PlayerResource_Ping_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C63DB + 4, CPlayerResource_OriginalSize + PlayerResource_Ping_Start);

	// CPlayerResource::UpdatePlayerData - m_iTeam
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C63FD + 4, CPlayerResource_OriginalSize + PlayerResource_Team_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C6442 + 4, CPlayerResource_OriginalSize + PlayerResource_Team_Start);

	// CPlayerResource::UpdatePlayerData - m_iPRHealth
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C645B + 4, CPlayerResource_OriginalSize + PlayerResource_PRHealth_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C64A0 + 4, CPlayerResource_OriginalSize + PlayerResource_PRHealth_Start);

	// CPlayerResource::UpdatePlayerData - m_bConnected
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C64AA + 4, CPlayerResource_OriginalSize + PlayerResource_Connected_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C64F0 + 4, CPlayerResource_OriginalSize + PlayerResource_Connected_Start);

	// CPlayerResource::UpdatePlayerData - m_bAlive
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C650A + 4, CPlayerResource_OriginalSize + PlayerResource_Alive_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C654F + 4, CPlayerResource_OriginalSize + PlayerResource_Alive_Start);

	// CPlayerResource::UpdatePlayerData - m_boolStats
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C6557 + 4, CPlayerResource_OriginalSize + PlayerResource_BoolStats_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C65A5 + 4, CPlayerResource_OriginalSize + PlayerResource_BoolStats_Start);

	// CPlayerResource::UpdatePlayerData - m_scoreStats
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C65C2 + 3, CPlayerResource_OriginalSize + PlayerResource_ScoreStats_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C65E3 + 4, CPlayerResource_OriginalSize + PlayerResource_ScoreStats_Start);

	// CPlayerResource::UpdatePlayerData - m_killStats
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C6654 + 3, CPlayerResource_OriginalSize + PlayerResource_KillStats_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x5C665B + 3, CPlayerResource_OriginalSize + PlayerResource_KillStats_Start);

	// GameLoop::RunUserCmds - rebuild
	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x483D10, &RunUserCmds_Hook, reinterpret_cast<LPVOID*>(&RunUserCmds_Original));

	*(DWORD*)((char*)baseAddress + 0x14E7390) = 0;
	auto DT_PlayerResource_Construct = (__int64(__fastcall*)())((char*)baseAddress + 0x5C4FE0);
	DT_PlayerResource_Construct();

	constexpr int CTeam_OriginalSize = 3336;
	constexpr int CTeam_AddedSize = Team_AddedSize;
	constexpr int CTeam_ModifiedSize = CTeam_OriginalSize + CTeam_AddedSize;

	// CTeam class allocation function - allocate a bigger amount to fit all new team player data
	ChangeOffset<unsigned int>((char*)baseAddress + 0x23924A + 1, CTeam_ModifiedSize);

	// CTeam::CTeam - increase memset length to clean newly allocated data
	ChangeOffset<unsigned int>((char*)baseAddress + 0x2395AE + 2, 256 + CTeam_AddedSize);

	// hook required to change the size of DT_Team::"player_array"
	HookEnabler hook2;
	ENABLER_CREATEHOOK(hook2, (char*)baseAddress + 0x12B130, &SendPropArray2_Hook, reinterpret_cast<LPVOID*>(&SendPropArray2_Original));
	hook2.~HookEnabler(); // force hook before calling construct function

	*(DWORD*)((char*)baseAddress + 0xC945A0) = 0;
	auto DT_Team_Construct = (__int64(__fastcall*)())((char*)baseAddress + 0x238F50);
	DT_Team_Construct();
}

typedef __int64 (*RecvPropArray2_Type)(__int64 recvProp, int elements, int flags, const char* name, __int64 proxyFn);
RecvPropArray2_Type RecvPropArray2_Original;

__int64 __fastcall RecvPropArray2_Hook(__int64 recvProp, int elements, int flags, const char* name, __int64 proxyFn)
{
	// Change the amount of elements to account for a bigger player amount
	if (!strcmp(name, "\"player_array\""))
		elements = NEW_MAX_PLAYERS;

	return RecvPropArray2_Original(recvProp, elements, flags, name, proxyFn);
}

void InitialiseMaxPlayersOverride_Client(HMODULE baseAddress)
{
	if (!MaxPlayersIncreaseEnabled())
		return;

	constexpr int C_PlayerResource_OriginalSize = 5768;
	constexpr int C_PlayerResource_AddedSize = PlayerResource_TotalSize;
	constexpr int C_PlayerResource_ModifiedSize = C_PlayerResource_OriginalSize + C_PlayerResource_AddedSize;

	// C_PlayerResource class allocation function - allocate a bigger amount to fit all new max player data
	ChangeOffset<unsigned int>((char*)baseAddress + 0x164C41 + 1, C_PlayerResource_ModifiedSize);

	// C_PlayerResource::C_PlayerResource - change loop end value
	ChangeOffset<unsigned char>((char*)baseAddress + 0x1640C4 + 2, NEW_MAX_PLAYERS - 32);

	// C_PlayerResource::C_PlayerResource - change m_szName address
	ChangeOffset<unsigned int>(
		(char*)baseAddress + 0x1640D0 + 3, C_PlayerResource_OriginalSize + PlayerResource_Name_Start); // appended to the end of the class

	// C_PlayerResource::C_PlayerResource - change m_szName address
	ChangeOffset<unsigned int>(
		(char*)baseAddress + 0x1640D0 + 3, C_PlayerResource_OriginalSize + PlayerResource_Name_Start); // appended to the end of the class

	// C_PlayerResource::C_PlayerResource - increase memset length to clean newly allocated data
	ChangeOffset<unsigned int>((char*)baseAddress + 0x1640D0 + 3, 2244 + C_PlayerResource_AddedSize);

	// C_PlayerResource::UpdatePlayerName - change m_szName address
	ChangeOffset<unsigned int>((char*)baseAddress + 0x16431F + 3, C_PlayerResource_OriginalSize + PlayerResource_Name_Start);

	// C_PlayerResource::GetPlayerName - change m_szName address 1
	ChangeOffset<unsigned int>((char*)baseAddress + 0x1645B1 + 3, C_PlayerResource_OriginalSize + PlayerResource_Name_Start);

	// C_PlayerResource::GetPlayerName - change m_szName address 2
	ChangeOffset<unsigned int>((char*)baseAddress + 0x1645C0 + 3, C_PlayerResource_OriginalSize + PlayerResource_Name_Start);

	// C_PlayerResource::GetPlayerName - change m_szName address 3
	ChangeOffset<unsigned int>((char*)baseAddress + 0x1645DD + 3, C_PlayerResource_OriginalSize + PlayerResource_Name_Start);

	// C_PlayerResource::GetPlayerName internal func - change m_szName address 1
	ChangeOffset<unsigned int>((char*)baseAddress + 0x164B71 + 4, C_PlayerResource_OriginalSize + PlayerResource_Name_Start);

	// C_PlayerResource::GetPlayerName internal func - change m_szName address 2
	ChangeOffset<unsigned int>((char*)baseAddress + 0x164B9B + 4, C_PlayerResource_OriginalSize + PlayerResource_Name_Start);

	// C_PlayerResource::GetPlayerName2 (?) - change m_szName address 1
	ChangeOffset<unsigned int>((char*)baseAddress + 0x164641 + 3, C_PlayerResource_OriginalSize + PlayerResource_Name_Start);

	// C_PlayerResource::GetPlayerName2 (?) - change m_szName address 2
	ChangeOffset<unsigned int>((char*)baseAddress + 0x164650 + 3, C_PlayerResource_OriginalSize + PlayerResource_Name_Start);

	// C_PlayerResource::GetPlayerName2 (?) - change m_szName address 3
	ChangeOffset<unsigned int>((char*)baseAddress + 0x16466D + 3, C_PlayerResource_OriginalSize + PlayerResource_Name_Start);

	// C_PlayerResource::GetPlayerName internal func - change m_szName2 (?) address 1
	ChangeOffset<unsigned int>((char*)baseAddress + 0x164BA3 + 4, C_PlayerResource_OriginalSize + PlayerResource_Name_Start);

	// C_PlayerResource::GetPlayerName internal func - change m_szName2 (?) address 2
	ChangeOffset<unsigned int>((char*)baseAddress + 0x164BCE + 4, C_PlayerResource_OriginalSize + PlayerResource_Name_Start);

	// C_PlayerResource::GetPlayerName internal func - change m_szName2 (?) address 3
	ChangeOffset<unsigned int>((char*)baseAddress + 0x164BE7 + 4, C_PlayerResource_OriginalSize + PlayerResource_Name_Start);

	// C_PlayerResource::m_szName
	ChangeOffset<unsigned int>((char*)baseAddress + 0xc350f8, C_PlayerResource_OriginalSize + PlayerResource_Name_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xc350f8 + 4, NEW_MAX_PLAYERS + 1);

	// DT_PlayerResource size
	ChangeOffset<unsigned int>((char*)baseAddress + 0x163415 + 6, C_PlayerResource_ModifiedSize);

	// DT_PlayerResource::m_iPing RecvProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x163492 + 2, C_PlayerResource_OriginalSize + PlayerResource_Ping_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x1634D6 + 2, C_PlayerResource_OriginalSize + PlayerResource_Ping_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x163515 + 5, NEW_MAX_PLAYERS + 1);

	// C_PlayerResource::m_iPing
	ChangeOffset<unsigned int>((char*)baseAddress + 0xc35170, C_PlayerResource_OriginalSize + PlayerResource_Ping_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xc35170 + 4, NEW_MAX_PLAYERS + 1);

	// DT_PlayerResource::m_iTeam RecvProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x163549 + 2, C_PlayerResource_OriginalSize + PlayerResource_Team_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x1635C8 + 2, C_PlayerResource_OriginalSize + PlayerResource_Team_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x1635AD + 5, NEW_MAX_PLAYERS + 1);

	// C_PlayerResource::m_iTeam
	ChangeOffset<unsigned int>((char*)baseAddress + 0xc351e8, C_PlayerResource_OriginalSize + PlayerResource_Team_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xc351e8 + 4, NEW_MAX_PLAYERS + 1);

	// DT_PlayerResource::m_iPRHealth RecvProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x1635F9 + 2, C_PlayerResource_OriginalSize + PlayerResource_PRHealth_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x163625 + 2, C_PlayerResource_OriginalSize + PlayerResource_PRHealth_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x163675 + 5, NEW_MAX_PLAYERS + 1);

	// C_PlayerResource::m_iPRHealth
	ChangeOffset<unsigned int>((char*)baseAddress + 0xc35260, C_PlayerResource_OriginalSize + PlayerResource_PRHealth_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xc35260 + 4, NEW_MAX_PLAYERS + 1);

	// DT_PlayerResource::m_bConnected RecvProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x1636A9 + 2, C_PlayerResource_OriginalSize + PlayerResource_Connected_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x1636D5 + 2, C_PlayerResource_OriginalSize + PlayerResource_Connected_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x163725 + 5, NEW_MAX_PLAYERS + 1);

	// C_PlayerResource::m_bConnected
	ChangeOffset<unsigned int>((char*)baseAddress + 0xc352d8, C_PlayerResource_OriginalSize + PlayerResource_Connected_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xc352d8 + 4, NEW_MAX_PLAYERS + 1);

	// DT_PlayerResource::m_bAlive RecvProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x163759 + 2, C_PlayerResource_OriginalSize + PlayerResource_Alive_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x163785 + 2, C_PlayerResource_OriginalSize + PlayerResource_Alive_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x1637D5 + 5, NEW_MAX_PLAYERS + 1);

	// C_PlayerResource::m_bAlive
	ChangeOffset<unsigned int>((char*)baseAddress + 0xc35350, C_PlayerResource_OriginalSize + PlayerResource_Alive_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xc35350 + 4, NEW_MAX_PLAYERS + 1);

	// DT_PlayerResource::m_boolStats RecvProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x163809 + 2, C_PlayerResource_OriginalSize + PlayerResource_BoolStats_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x163835 + 2, C_PlayerResource_OriginalSize + PlayerResource_BoolStats_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x163885 + 5, NEW_MAX_PLAYERS + 1);

	// C_PlayerResource::m_boolStats
	ChangeOffset<unsigned int>((char*)baseAddress + 0xc353c8, C_PlayerResource_OriginalSize + PlayerResource_BoolStats_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xc353c8 + 4, NEW_MAX_PLAYERS + 1);

	// DT_PlayerResource::m_killStats RecvProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x1638B3 + 2, C_PlayerResource_OriginalSize + PlayerResource_KillStats_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x1638E5 + 2, C_PlayerResource_OriginalSize + PlayerResource_KillStats_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x163935 + 5, PlayerResource_KillStats_Length);

	// C_PlayerResource::m_killStats
	ChangeOffset<unsigned int>((char*)baseAddress + 0xc35440, C_PlayerResource_OriginalSize + PlayerResource_KillStats_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xc35440 + 4, PlayerResource_KillStats_Length);

	// DT_PlayerResource::m_scoreStats RecvProp
	ChangeOffset<unsigned int>((char*)baseAddress + 0x163969 + 2, C_PlayerResource_OriginalSize + PlayerResource_ScoreStats_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x163995 + 2, C_PlayerResource_OriginalSize + PlayerResource_ScoreStats_Start);
	ChangeOffset<unsigned int>((char*)baseAddress + 0x1639E5 + 5, PlayerResource_ScoreStats_Length);

	// C_PlayerResource::m_scoreStats
	ChangeOffset<unsigned int>((char*)baseAddress + 0xc354b8, C_PlayerResource_OriginalSize + PlayerResource_ScoreStats_Start);
	ChangeOffset<unsigned short>((char*)baseAddress + 0xc354b8 + 4, PlayerResource_ScoreStats_Length);

	// C_PlayerResource::GetPlayerName - change m_bConnected address
	ChangeOffset<unsigned int>((char*)baseAddress + 0x164599 + 3, C_PlayerResource_OriginalSize + PlayerResource_Connected_Start);

	// C_PlayerResource::GetPlayerName2 (?) - change m_bConnected address
	ChangeOffset<unsigned int>((char*)baseAddress + 0x164629 + 3, C_PlayerResource_OriginalSize + PlayerResource_Connected_Start);

	// C_PlayerResource::GetPlayerName internal func - change m_bConnected address
	ChangeOffset<unsigned int>((char*)baseAddress + 0x164B13 + 3, C_PlayerResource_OriginalSize + PlayerResource_Connected_Start);

	// Some other get name func (that seems to be unused) - change m_bConnected address
	ChangeOffset<unsigned int>((char*)baseAddress + 0x164860 + 3, C_PlayerResource_OriginalSize + PlayerResource_Connected_Start);

	// Some other get name func 2 (that seems to be unused too) - change m_bConnected address
	ChangeOffset<unsigned int>((char*)baseAddress + 0x164834 + 3, C_PlayerResource_OriginalSize + PlayerResource_Connected_Start);

	*(DWORD*)((char*)baseAddress + 0xC35068) = 0;
	auto DT_PlayerResource_Construct = (__int64(__fastcall*)())((char*)baseAddress + 0x163400);
	DT_PlayerResource_Construct();

	constexpr int C_Team_OriginalSize = 3200;
	constexpr int C_Team_AddedSize = Team_AddedSize;
	constexpr int C_Team_ModifiedSize = C_Team_OriginalSize + C_Team_AddedSize;

	// C_Team class allocation function - allocate a bigger amount to fit all new team player data
	ChangeOffset<unsigned int>((char*)baseAddress + 0x182321 + 1, C_Team_ModifiedSize);

	// C_Team::C_Team - increase memset length to clean newly allocated data
	ChangeOffset<unsigned int>((char*)baseAddress + 0x1804A2 + 2, 256 + C_Team_AddedSize);

	// DT_Team size
	ChangeOffset<unsigned int>((char*)baseAddress + 0xC3AA0C, C_Team_ModifiedSize);

	// hook required to change the size of DT_Team::"player_array"
	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x1CEDA0, &RecvPropArray2_Hook, reinterpret_cast<LPVOID*>(&RecvPropArray2_Original));
	hook.~HookEnabler(); // force hook before calling construct function

	*(DWORD*)((char*)baseAddress + 0xC3AFF8) = 0;
	auto DT_Team_Construct = (__int64(__fastcall*)())((char*)baseAddress + 0x17F950);
	DT_Team_Construct();
}