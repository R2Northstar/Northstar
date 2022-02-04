#pragma once
#include "sourceinterface.h"

// taken from ttf2sdk
typedef void* FileHandle_t;

#pragma pack(push, 1)
struct VPKFileEntry
{
	char* directory;
	char* filename;
	char* extension;
	unsigned char unknown[0x38];
};
#pragma pack(pop)

#pragma pack(push, 1)
struct VPKData
{
	unsigned char unknown[5];
	char path[255];
	unsigned char unknown2[0x134];
	int32_t numEntries;
	unsigned char unknown3[12];
	VPKFileEntry* entries;
};
#pragma pack(pop)

enum SearchPathAdd_t
{
	PATH_ADD_TO_HEAD, // First path searched
	PATH_ADD_TO_TAIL, // Last path searched
};

class CSearchPath
{
  public:
	unsigned char unknown[0x18];
	const char* debugPath;
};

class IFileSystem
{
  public:
	struct VTable
	{
		void* unknown[10];
		void (*AddSearchPath)(IFileSystem* fileSystem, const char* pPath, const char* pathID, SearchPathAdd_t addType);
		void* unknown2[84];
		bool (*ReadFromCache)(IFileSystem* fileSystem, const char* path, void* result);
		void* unknown3[15];
		VPKData* (*MountVPK)(IFileSystem* fileSystem, const char* vpkPath);
	};

	struct VTable2
	{
		int (*Read)(IFileSystem::VTable2** fileSystem, void* pOutput, int size, FileHandle_t file);
		void* unknown[1];
		FileHandle_t (*Open)(
			IFileSystem::VTable2** fileSystem, const char* pFileName, const char* pOptions, const char* pathID, int64_t unknown);
		void (*Close)(IFileSystem* fileSystem, FileHandle_t file);
		void* unknown2[6];
		bool (*FileExists)(IFileSystem::VTable2** fileSystem, const char* pFileName, const char* pPathID);
	};

	VTable* m_vtable;
	VTable2* m_vtable2;
};

std::string ReadVPKFile(const char* path);
std::string ReadVPKOriginalFile(const char* path);

void InitialiseFilesystem(HMODULE baseAddress);
extern SourceInterface<IFileSystem>* g_Filesystem;