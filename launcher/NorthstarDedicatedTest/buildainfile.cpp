#include "pch.h"
#include "buildainfile.h"
#include "hookutils.h"

const int MAX_HULLS = 5;

struct CAI_Node
{
	int index; // not present on disk
	float x;
	float y;
	float z;
	float yaw;
	float hulls[MAX_HULLS];

	int unk0;			 // always 2 in buildainfile, maps directly to unk0 in disk struct
	int unk1;			 // maps directly to unk1 in disk struct
	int unk2[MAX_HULLS]; // maps directly to unk2 in disk struct, despite being ints rather than shorts

	// view server.dll+393672 for context and death wish
	char unk3[MAX_HULLS];  // hell on earth, should map to unk3 on disk
	char pad[3];		   // aligns next bytes
	float unk4[MAX_HULLS]; // i have no fucking clue, calculated using some kind of demon hell function float magic

	char unk5[32]; // padding until next bits i know
	short unk6;	   // should match up to unk4 on disk
	char unk7[16]; // padding until next bit
	short unk8;	   // should match up to unk5 on disk
	char unk9[8];  // padding until next bit
	char unk10[8]; // should match up to unk6 on disk
};

// the way CAI_Nodes are represented in on-disk ain files
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
	char unk0[84172];
	int nodecount;
	CAI_Node** nodes;
};

typedef void (*CAI_NetworkBuilder__BuildType)(void* builder, CAI_Network* aiNetwork, void* unknown);
CAI_NetworkBuilder__BuildType CAI_NetworkBuilder__Build;

void CAI_NetworkBuilder__BuildHook(void* builder, CAI_Network* aiNetwork, void* unknown)
{
	CAI_NetworkBuilder__Build(builder, aiNetwork, unknown);

	// dump from memory
	spdlog::info("DUMPING BUILDAINFILE INFO!!!");
	spdlog::info("");
	spdlog::info("");
	spdlog::info("");
	spdlog::info("");
	spdlog::info("");

	// path nodes
	spdlog::info("nodecount: {}", aiNetwork->nodecount);
	for (int i = 0; i < aiNetwork->nodecount; i++)
	{
		// spdlog::info("x = {}", aiNetwork->nodes[i]->x);
		// spdlog::info("y = {}", aiNetwork->nodes[i]->y);
		// spdlog::info("z = {}", aiNetwork->nodes[i]->z);
		// spdlog::info("yaw = {}", aiNetwork->nodes[i]->yaw);
		// spdlog::info("hulls = {} {} {} {} {}", aiNetwork->nodes[i]->hulls[0], aiNetwork->nodes[i]->hulls[1],
		// aiNetwork->nodes[i]->hulls[2], aiNetwork->nodes[i]->hulls[3], aiNetwork->nodes[i]->hulls[4]);
		//
		// spdlog::info("unk0 = {} (should always be 2)", aiNetwork->nodes[i]->unk0);
		// spdlog::info("unk1 = {}", aiNetwork->nodes[i]->unk1);
		// spdlog::info("unk2 = {} {} {} {} {}", aiNetwork->nodes[i]->unk2[0], aiNetwork->nodes[i]->unk2[1], aiNetwork->nodes[i]->unk2[2],
		// aiNetwork->nodes[i]->unk2[3], aiNetwork->nodes[i]->unk2[4]);
		//
		// spdlog::info("unk3 = {} {} {} {} {}", (int)aiNetwork->nodes[i]->unk3[0], (int)aiNetwork->nodes[i]->unk3[1],
		// (int)aiNetwork->nodes[i]->unk3[2], (int)aiNetwork->nodes[i]->unk3[3], (int)aiNetwork->nodes[i]->unk3[4]); spdlog::info("unk4 = {}
		// {} {} {} {}", aiNetwork->nodes[i]->unk4[0], aiNetwork->nodes[i]->unk4[1], aiNetwork->nodes[i]->unk4[2],
		// aiNetwork->nodes[i]->unk4[3], aiNetwork->nodes[i]->unk4[4]);

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
			diskNode.unk3[j] = (short)aiNetwork->nodes[i]->unk3[j];

		diskNode.unk4 = aiNetwork->nodes[i]->unk6;
		diskNode.unk5 = aiNetwork->nodes[i]->unk8;
		memcpy(diskNode.unk6, aiNetwork->nodes[i]->unk10, sizeof(diskNode.unk6));

		spdlog::info("node {} at {} has on-disk fields:", aiNetwork->nodes[i]->index, (void*)aiNetwork->nodes[i]);
		spdlog::info("x = {}", diskNode.x);
		spdlog::info("y = {}", diskNode.y);
		spdlog::info("z = {}", diskNode.z);
		spdlog::info("yaw = {}", diskNode.yaw);
		spdlog::info(
			"hulls = {} {} {} {} {}", diskNode.hulls[0], diskNode.hulls[1], diskNode.hulls[2], diskNode.hulls[3], diskNode.hulls[4]);
		spdlog::info("unk0 = {}", (int)diskNode.unk0);
		spdlog::info("unk1 = {}", diskNode.unk1);
		spdlog::info("unk2 = {} {} {} {} {}", diskNode.unk2[0], diskNode.unk2[1], diskNode.unk2[2], diskNode.unk2[3], diskNode.unk2[4]);
		spdlog::info(
			"unk3 = {} {} {} {} {}", (int)diskNode.unk3[0], (int)diskNode.unk3[1], (int)diskNode.unk3[2], (int)diskNode.unk3[3],
			(int)diskNode.unk3[4]);
		spdlog::info("unk4 = {}", diskNode.unk4);
		spdlog::info("unk5 = {}", diskNode.unk5);
		spdlog::info(
			"unk6 = {} {} {} {} {} {} {} {}", (int)diskNode.unk6[0], (int)diskNode.unk6[1], (int)diskNode.unk6[2], (int)diskNode.unk6[3],
			(int)diskNode.unk6[4], (int)diskNode.unk6[5], (int)diskNode.unk6[6], (int)diskNode.unk6[7]);
	}
}

void InitialiseBuildAINFileHooks(HMODULE baseAddress)
{
	HookEnabler hook;
	ENABLER_CREATEHOOK(
		hook, (char*)baseAddress + 0x385E20, &CAI_NetworkBuilder__BuildHook, reinterpret_cast<LPVOID*>(&CAI_NetworkBuilder__Build));

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