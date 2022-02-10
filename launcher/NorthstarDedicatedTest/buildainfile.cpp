#include "pch.h"
#include "buildainfile.h"
#include "convar.h"
#include "hookutils.h"
#include <fstream>

const int AINET_VERSION_NUMBER = 57;
const int AINET_SCRIPT_VERSION_NUMBER = 21;
const int MAP_VERSION_TEMP = 30;
const int PLACEHOLDER_CRC = 0;
const int MAX_HULLS = 5;

struct CAI_NodeLink
{
	short srcId;
	short destId;
	bool hulls[MAX_HULLS];
	char unk0;
	char unk1; // maps => unk0 on disk
	char unk2[5];
	int64_t flags;
};

#pragma pack (push, 1)
struct CAI_NodeLinkDisk
{
	short srcId;
	short destId;
	char unk0;
	bool hulls[MAX_HULLS];
};

struct CAI_Node
{
	int index; // not present on disk
	float x;
	float y;
	float z;
	float hulls[MAX_HULLS];
	float yaw;

	int unk0;			 // always 2 in buildainfile, maps directly to unk0 in disk struct
	int unk1;			 // maps directly to unk1 in disk struct
	int unk2[MAX_HULLS]; // maps directly to unk2 in disk struct, despite being ints rather than shorts

	// view server.dll+393672 for context and death wish
	char unk3[MAX_HULLS];  // hell on earth, should map to unk3 on disk
	char pad[3];		   // aligns next bytes
	float unk4[MAX_HULLS]; // i have no fucking clue, calculated using some kind of demon hell function float magic

	CAI_NodeLink** links;
	char unk5[16];
	int linkcount;
	int unk11; // bad name lmao
	short unk6; // should match up to unk4 on disk
	char unk7[16]; // padding until next bit
	short unk8;	   // should match up to unk5 on disk
	char unk9[8];  // padding until next bit
	char unk10[8]; // should match up to unk6 on disk
};

// the way CAI_Nodes are represented in on-disk ain files
#pragma pack (push, 1)
struct CAI_NodeDisk
{
	float x;
	float y;
	float z;
	float yaw;
	float hulls[MAX_HULLS];

	char unk0;
	int unk1;
	short unk2[MAX_HULLS];
	char unk3[MAX_HULLS];
	short unk4;
	short unk5;
	char unk6[8];
}; // total size of 68 bytes

struct CAI_Network
{
	// +0
	char unk0[8];
	// +8
	int linkcount; // this is uninitialised and never set on ain build, fun!
	// +12
	char unk1[124];
	// +136
	int zonecount;
	// +140
	char unk2[24];
	// +164
	int hintcount;
	// +168
	char unk3[4000];
	// +4168
	int scriptnodecount;
	// +4172
	char unk4[80000];
	// +84172
	int nodecount;
	// +84176
	CAI_Node** nodes;
};

ConVar* Cvar_ns_ai_dumpAINfileFromLoad;

void DumpAINInfo(CAI_Network* aiNetwork)
{
	// dump from memory
	spdlog::info("writing .ain to file....");
	spdlog::info("");
	spdlog::info("");
	spdlog::info("");
	spdlog::info("");
	spdlog::info("");

	std::ofstream writeStream("dumped_ain.ain", std::ofstream::binary);
	spdlog::info("writing ainet version: {}", AINET_VERSION_NUMBER);
	writeStream.write((char*)&AINET_VERSION_NUMBER, sizeof(int));
	spdlog::info("writing map version: {}", MAP_VERSION_TEMP); // temp
	writeStream.write((char*)&MAP_VERSION_TEMP, sizeof(int));
	spdlog::info("writing placeholder crc: {}", PLACEHOLDER_CRC);
	writeStream.write((char*)&PLACEHOLDER_CRC, sizeof(int));

	int calculatedLinkcount = 0;

	// path nodes
	spdlog::info("writing nodecount: {}", aiNetwork->nodecount);
	writeStream.write((char*)&aiNetwork->nodecount, sizeof(int));

	for (int i = 0; i < aiNetwork->nodecount; i++)
	{
		// construct on-disk node struct
		CAI_NodeDisk diskNode;
		diskNode.x = aiNetwork->nodes[i]->x;
		diskNode.y = aiNetwork->nodes[i]->y;
		diskNode.z = aiNetwork->nodes[i]->z;
		diskNode.yaw = aiNetwork->nodes[i]->yaw;
		memcpy(diskNode.hulls, aiNetwork->nodes[i]->hulls, sizeof(diskNode.hulls));
		diskNode.unk0 = (char)aiNetwork->nodes[i]->unk0;
		diskNode.unk1 = aiNetwork->nodes[i]->unk1;

		for (int j = 0; j < MAX_HULLS; j++)
		{
			diskNode.unk2[j] = (short)aiNetwork->nodes[i]->unk2[j];
			spdlog::info((short)aiNetwork->nodes[i]->unk2[j]);
		}

		memcpy(diskNode.unk3, aiNetwork->nodes[i]->unk3, sizeof(diskNode.unk3));
		diskNode.unk4 = aiNetwork->nodes[i]->unk6;
		diskNode.unk5 = -1; // aiNetwork->nodes[i]->unk8; // this field is wrong, however, it's always -1 in vanilla navmeshes anyway, so no biggie
		memcpy(diskNode.unk6, aiNetwork->nodes[i]->unk10, sizeof(diskNode.unk6));

		spdlog::info("writing node {} from {} to {:x}", aiNetwork->nodes[i]->index, (void*)aiNetwork->nodes[i], writeStream.tellp());
		writeStream.write((char*)&diskNode, sizeof(CAI_NodeDisk));

		calculatedLinkcount += aiNetwork->nodes[i]->linkcount;
	}

	spdlog::info("linkcount: {}", aiNetwork->linkcount);
	spdlog::info("calculated total linkcount: {}", calculatedLinkcount);

	calculatedLinkcount /= 2;
	if (Cvar_ns_ai_dumpAINfileFromLoad->m_nValue)
	{
		if (aiNetwork->linkcount == calculatedLinkcount)
			spdlog::info("caculated linkcount is normal!");
		else
			spdlog::warn("calculated linkcount has weird value! this is expected on build!");
	}	

	spdlog::info("writing linkcount: {}", calculatedLinkcount);
	writeStream.write((char*)&calculatedLinkcount, sizeof(int));

	for (int i = 0; i < aiNetwork->nodecount; i++)
	{
		for (int j = 0; j < aiNetwork->nodes[i]->linkcount; j++)
		{
			// skip links that don't originate from current node
			if (aiNetwork->nodes[i]->links[j]->srcId != aiNetwork->nodes[i]->index)
				continue;

			CAI_NodeLinkDisk diskLink;
			diskLink.srcId = aiNetwork->nodes[i]->links[j]->srcId;
			diskLink.destId = aiNetwork->nodes[i]->links[j]->destId;
			diskLink.unk0 = aiNetwork->nodes[i]->links[j]->unk1;
			memcpy(diskLink.hulls, aiNetwork->nodes[i]->links[j]->hulls, sizeof(diskLink.hulls));

			spdlog::info("writing link {} => {} to {:x}", diskLink.srcId, diskLink.destId, writeStream.tellp());
			writeStream.write((char*)&diskLink, sizeof(CAI_NodeLinkDisk));
		}
	}

	// don't know what this is, it's likely a block from tf1 that got deprecated?
	spdlog::info("writing {:x} bytes for unknown block at {:x}", aiNetwork->nodecount * sizeof(uint32_t), writeStream.tellp());
	uint32_t* unkNodeBlock = new uint32_t[aiNetwork->nodecount];
	memset(unkNodeBlock, 0, aiNetwork->nodecount * sizeof(uint32_t));
	writeStream.write((char*)unkNodeBlock, aiNetwork->nodecount * sizeof(uint32_t));
	delete[] unkNodeBlock;

	spdlog::info("hintcount: {}", aiNetwork->hintcount);
	spdlog::info("scriptnodecount: {}", aiNetwork->scriptnodecount);
	spdlog::info("zonecount: {}", aiNetwork->zonecount);

	writeStream.close();
}

typedef void(*CAI_NetworkBuilder__BuildType)(void* builder, CAI_Network* aiNetwork, void* unknown);
CAI_NetworkBuilder__BuildType CAI_NetworkBuilder__Build;

void CAI_NetworkBuilder__BuildHook(void* builder, CAI_Network* aiNetwork, void* unknown)
{
	CAI_NetworkBuilder__Build(builder, aiNetwork, unknown);

	DumpAINInfo(aiNetwork);
}

typedef void(*LoadAINFileType)(void* aimanager, void* buf, const char* filename);
LoadAINFileType LoadAINFile;

void LoadAINFileHook(void* aimanager, void* buf, const char* filename)
{
	LoadAINFile(aimanager, buf, filename);

	if (Cvar_ns_ai_dumpAINfileFromLoad->m_nValue)
	{
		spdlog::info("running DumpAINInfo for loaded file {}", filename);
		DumpAINInfo(*(CAI_Network**)((char*)aimanager + 2536));
	}
}

void InitialiseBuildAINFileHooks(HMODULE baseAddress)
{
	Cvar_ns_ai_dumpAINfileFromLoad = RegisterConVar("ns_ai_dumpAINfileFromLoad", "0", FCVAR_NONE, "For debugging: whether we should dump ain data for ains loaded from disk");

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x385E20, &CAI_NetworkBuilder__BuildHook, reinterpret_cast<LPVOID*>(&CAI_NetworkBuilder__Build));
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x3933A0, &LoadAINFileHook, reinterpret_cast<LPVOID*>(&LoadAINFile));

	// remove a check that prevents a logging function in link generation from working
	// due to the sheer amount of logging this is a massive perf hit to generation, but spewlog_enable 0 exists so whatever
	{
		void* ptr = (char*)baseAddress + 0x3889B6;
		TempReadWrite rw(ptr);
		*((char*)ptr) = (char)0x90;
		*((char*)ptr + 1) = (char)0x90;
		*((char*)ptr + 2) = (char)0x90;
		*((char*)ptr + 3) = (char)0x90;
		*((char*)ptr + 4) = (char)0x90;
		*((char*)ptr + 5) = (char)0x90;
	}

	{
		void* ptr = (char*)baseAddress + 0x3889BF;
		TempReadWrite rw(ptr);
		*((char*)ptr) = (char)0x90;
		*((char*)ptr + 1) = (char)0x90;
		*((char*)ptr + 2) = (char)0x90;
		*((char*)ptr + 3) = (char)0x90;
		*((char*)ptr + 4) = (char)0x90;
		*((char*)ptr + 5) = (char)0x90;
	}
}