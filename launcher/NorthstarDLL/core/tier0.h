#pragma once
namespace Tier0
{
	class IMemAlloc
	{
	  public:
		struct VTable
		{
			void* unknown[1]; // alloc debug
			void* (*Alloc)(IMemAlloc* memAlloc, size_t nSize);
			void* unknown2[1]; // realloc debug
			void* (*Realloc)(IMemAlloc* memAlloc, void* pMem, size_t nSize);
			void* unknown3[1]; // free #1
			void (*Free)(IMemAlloc* memAlloc, void* pMem);
			void* unknown4[2]; // nullsubs, maybe CrtSetDbgFlag
			size_t (*GetSize)(IMemAlloc* memAlloc, void* pMem);
			void* unknown5[9]; // they all do literally nothing
			void (*DumpStats)(IMemAlloc* memAlloc);
			void (*DumpStatsFileBase)(IMemAlloc* memAlloc, const char* pchFileBase);
			void* unknown6[4];
			int (*heapchk)(IMemAlloc* memAlloc);
		};

		VTable* m_vtable;
	};

	class CCommandLine
	{
	  public:
		// based on the defs in the 2013 source sdk, but for some reason has an extra function (may be another CreateCmdLine overload?)
		// these seem to line up with what they should be though
		virtual void CreateCmdLine(const char* commandline) {}
		virtual void CreateCmdLine(int argc, char** argv) {}
		virtual void unknown() {}
		virtual const char* GetCmdLine(void) const {}

		virtual const char* CheckParm(const char* psz, const char** ppszValue = 0) const {}
		virtual void RemoveParm() const {}
		virtual void AppendParm(const char* pszParm, const char* pszValues) {}

		virtual const char* ParmValue(const char* psz, const char* pDefaultVal = 0) const {}
		virtual int ParmValue(const char* psz, int nDefaultVal) const {}
		virtual float ParmValue(const char* psz, float flDefaultVal) const {}

		virtual int ParmCount() const {}
		virtual int FindParm(const char* psz) const {}
		virtual const char* GetParm(int nIndex) const {}
		virtual void SetParm(int nIndex, char const* pParm) {}

		// virtual const char** GetParms() const {}
	};

	extern IMemAlloc* g_pMemAllocSingleton;

	typedef void (*ErrorType)(const char* fmt, ...);
	extern ErrorType Error;

	typedef CCommandLine* (*CommandLineType)();
	extern CommandLineType CommandLine;

	typedef double (*Plat_FloatTimeType)();
	extern Plat_FloatTimeType Plat_FloatTime;

	typedef bool (*ThreadInServerFrameThreadType)();
	extern ThreadInServerFrameThreadType ThreadInServerFrameThread;
} // namespace Tier0

void TryCreateGlobalMemAlloc();
