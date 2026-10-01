#pragma once

#define PAK_MAX_SEGMENTS 20

enum PakHandle : int
{
	INVALID = -1,
};

struct struct_v16
{
	int64_t startPointerMaybe;
	int64_t endPointerMaybe;
	int64_t decompressedSize;
	bool isCompressed;
	int8_t gap_19[7];
};

struct struct_v1
{
	uint64_t qword_0;
	uint64_t compressedSize;
	uint32_t fileHandle;
	int fileReadJobs[32];
	uint8_t charBuf_94[32];
	uint32_t unsigned_int_B4;
	uint32_t unsigned_int_B8;
	uint8_t byte_BC;
	uint8_t byte_BD;
	uint8_t gap_BE;
	uint8_t byte_BF;
	struct_v16 filesizeStruct[8];
	uint8_t* fileBuffer;
	int64_t qword_1C8;
	int64_t file_size;
};

struct __declspec(align(8)) PakDecompState
{
	uint8_t* input_buf;
	uint64_t out;
	uint64_t mask;
	uint64_t out_mask;
	uint64_t file_len_total;
	uint64_t decompressed_size;
	uint64_t inv_mask_in;
	uint64_t inv_mask_out;
	uint32_t header_skip_bytes_bs;
	uint32_t dword44;
	uint64_t input_byte_pos;
	uint64_t decompressed_position;
	uint64_t len_needed;
	uint64_t byte;
	uint32_t byte_bit_offset;
	uint32_t dword6C;
	uint64_t qword70;
	uint64_t stream_compressed_size;
	uint64_t stream_decompressed_size;
};

class RFixedArray
{
	// have not these int fields in r2, but the size is accurate at least
	int index;
	int slotsLeft;
	int structSize;
	int modMask;
	void* buffer;
};

struct PakPatchCompressPair
{
	uint64_t compressedSize;
	uint64_t decompressedSize;
};

struct PakVirtualSegment
{
	uint32_t flags;
	uint32_t align;
	uint64_t size;
};

struct PakPageInfo
{
	uint32_t segIdx;
	uint32_t align;
	uint32_t dataSize;
};

struct PakDescriptor
{
	uint32_t index;
	uint32_t offset;
};

struct PakPtr
{
	uint32_t index;
	uint32_t offset;
};

/* 89 */
struct PakAssetEntry
{
	uint64_t nameHash;
	uint64_t padding;
	PakPtr subHeader;
	PakPtr rawData;
	int64_t starpakOffset;
	uint16_t highestPageNum;
	int16_t unknown2;
	uint32_t relationsStartIndex;
	uint32_t usesStartIndex;
	uint32_t relationsCount;
	uint16_t usesCount;
	uint16_t unknown;
	uint32_t subHeaderSize;
	uint32_t version;
	char magic[4];
};

struct PakFilePointer
{
	PakPatchCompressPair* patchCompressPairs;
	__int16* patchFileIndexes;
	const char* starpakPath;
	PakVirtualSegment* virtualSegments;
	PakPageInfo* pageInfo;
	PakDescriptor* descriptors;
	PakAssetEntry* assetEntrys;
	uint64_t* guidDescriptors;
	uint64_t fileRelations;
	int* externalAssetOffsets;
	char* externalAssetStrings;
	uint64_t pages;
	uint64_t patchHeader;
};
struct PakHeader
{
	char magic[4];
	uint16_t version;
	uint8_t flags;
	uint8_t IsCompressed;
	uint64_t timeCreated;
	uint64_t unknown_0;
	uint64_t compressedSize;
	uint64_t starpakFileOffsetMaybe;
	uint64_t decompressedSize;
	uint64_t unknown2;
	uint16_t lenStarpakPaths;
	uint16_t virtualSegmentCount;
	uint16_t pageCount;
	uint16_t patchIndex;
	uint32_t descriptorCount;
	uint32_t assetEntryCount;
	uint32_t guidDescriptorCount;
	uint32_t fileRelationCount;
	uint32_t externalAssetCount;
	uint32_t externalAssetSize;
};

struct PakFile
{
	bool IsValid();

	int dword_0;
	int assetsRead;
	int readPagesMaybe;
	int dword_C;
	int lastLoadedPatchIndex;
	int dword_14;
	struct_v1 v1;
	int64_t qword_1F0;
	char byte_1F8;
	BYTE gap_1F9[4];
	char byte_1FD;
	int16_t word_1FE;
	PakDecompState decomp_state;
	int64_t decompressedBuffer;
	int64_t qword_290;
	int64_t qword_298;
	uint64_t qword_2A0;
	char* puint8_2A8;
	char* qword_2B0;
	int32_t dword_2B8;
	uint8_t gap_2BC[4];
	int32_t dword_2C0;
	uint8_t gap_2C4[4];
	uint8_t buf_2C8[64];
	uint8_t buf_308[64];
	uint8_t gap_348[512];
	int64_t qword_548;
	int64_t startOfGuidDescriptorsRelativeToFileStart;
	char* qword_558;
	int64_t qword_560;
	bool(__fastcall* func_568)(void*, size_t*);
	int64_t qword_570;
	int dword_578;
	unsigned int jobId;
	int* pdword_580;
	int64_t* pageOffsets;
	PakFilePointer headerFields;
	int** pdword_5F8;
	int dword_600;
	int32_t dword_604;
	int64_t qword_608[16];
	const char* pakFileName;
	PakHeader header;
};

#define PAK_MAX_TRACKED_TYPES 16
#define PAK_MAX_TRACKED_TYPES_MASK (PAK_MAX_TRACKED_TYPES - 1)

#define PAK_MAX_LOADED_PAKS 512
#define PAK_MAX_LOADED_PAKS_MASK (PAK_MAX_LOADED_PAKS - 1)

#define PAK_MAX_LOADED_ASSETS 0x20000
#define PAK_MAX_LOADED_ASSETS_MASK (PAK_MAX_LOADED_ASSETS - 1)

#define PAK_MAX_TRACKED_ASSETS (PAK_MAX_LOADED_ASSETS / 2)
#define PAK_MAX_TRACKED_ASSETS_MASK (PAK_MAX_TRACKED_ASSETS - 1)

#define MAX_PAK_STREAMING_HANDLES 12

#define PAK_SLAB_BUFFER_TYPES 4

#define PAK_MAX_DISPATCH_LOAD_JOBS 4

// these are still wrong i think
enum PakStatus_e : int
{
	PAK_STATUS_FREED = 0x0,
	PAK_STATUS_LOAD_PENDING = 0x1,
	PAK_STATUS_REPAK_RUNNING = 0x2,
	PAK_STATUS_REPAK_DONE = 0x3,
	PAK_STATUS_LOAD_STARTING = 0x4,
	PAK_STATUS_LOAD_PATCH_INIT = 0x5,
	PAK_STATUS_LOAD_ASSETS = 0x6,
	PAK_STATUS_LOADED = 0x7,
	PAK_STATUS_UNLOAD_PENDING = 0x8,
	PAK_STATUS_FREE_PENDING = 0x9,
	PAK_STATUS_CANCELING = 0xA,
	PAK_STATUS_ERROR = 0xB,
	PAK_STATUS_INVALID_PAKHANDLE = 0xC,
	PAK_STATUS_BUSY = 0xD,
};

typedef uint64_t PakGuid_t;

struct PakAssetShort_s
{
	PakGuid_t m_Guid;
	uint32_t bindingIndex;
	uint32_t globalIndex;
};

struct PakAssetBinding_s
{
	char type[4];
	char* description;
	void* loadAssetFunc;
	void* unloadAssetFunc;
	void* replaceAssetFunc;
	void* allocator;

	uint32_t N00009080;
	uint32_t N0000908D;
	uint32_t N00009081;
	uint32_t count;

	RFixedArray trackers;
	void* page;
};

struct PakAssetTracker_s
{
	void* page;
	int32_t trackerIndex;
	int32_t loadedPakIndex;
	int8_t assetTypeHashIdx;
};

struct PakLoadedInfo_s
{
	// are these even streaming related, might be patch handles?
	struct PakStreamingInfo_s
	{
		// not sure about this, maybe the first handle is something else? it's always -1
		PakHandle handles[MAX_PAK_STREAMING_HANDLES];
		int fileCount;
	};

	PakHandle handle;
	PakStatus_e status;
	int loadJobId;
	int assetCount;
	char* filename;
	char pad_0018[8];
	void* allocator;
	void* assetGuids;
	void* slabBuffers[PAK_SLAB_BUFFER_TYPES];
	void* guidDescriptors;
	FILETIME fileTime;
	PakFile* pakFile;
	int fileHandle;
	PakStreamingInfo_s streamingInfo;
	HMODULE hModule;
};

struct JobFifoLock_s
{
	int id;
	int depth;
	int tls[64];
};

struct PakGlobalState_s
{
	PakAssetBinding_s assetBindings[PAK_MAX_TRACKED_TYPES];
	PakAssetShort_s loadedAssets[PAK_MAX_LOADED_ASSETS];
	PakAssetTracker_s trackedAssets[PAK_MAX_TRACKED_ASSETS];

	RFixedArray trackedAssetMap;
	RFixedArray loadedPakMap;

	PakLoadedInfo_s loadedPaks[PAK_MAX_LOADED_PAKS];

	// b64
	__int64 loadJobFinished;
	int lastAssetTrackerIndex;
	bool updateSplitScreenAnims;

	int16_t numAssetLoadJobs;
	JobFifoLock_s fifoLock;
	int pakLoadJobId;

	int16_t loadedPakCount;
	int16_t requestedPakCount;

	int loadedPakHandles[PAK_MAX_LOADED_PAKS]; // 0x0120

	// these fields might be related to loading, int16s increment but haven't checked what they actually are
	int16_t N00009286; // 0x0920
	int16_t N0000A1B5; // 0x0923

	int32_t N0000A1AD; // 0x0924
	int32_t N00009287; // 0x0928

	int16_t N0000A1B0; // 0x092C
	int16_t N0000A1BC; // 0x092F

	int unusedSlots[PAK_MAX_DISPATCH_LOAD_JOBS]; // 0x0930

	int32_t N0000928A; // 0x0940
	int32_t N0000A1C2; // 0x0944
	int32_t N0000928B; // 0x0948
	uint32_t N0000A1C6; // 0x094C
	__int64 gap;
	RTL_SRWLOCK lock;
	char pad_0950[48]; // 0x0950

	int currentLoadedPaks; // haven't checked exactly what this offset is
	int numPatchedPaks;
	const char** patchedPakNames;
	uint8_t* patchNumbers;
};

static_assert(sizeof(PakGlobalState_s) == 3760088);
static_assert(sizeof(PakLoadedInfo_s) == 0xA8);

extern PakGlobalState_s* g_pakGlobalState;

extern std::vector<PakHandle> g_pBadPaks;
