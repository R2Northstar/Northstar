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
		virtual void CreateCmdLine(const char* commandline) = 0;
		virtual void CreateCmdLine(int argc, char** argv) = 0;
		virtual void unknown() = 0;
		virtual const char* GetCmdLine(void) const = 0;

		virtual const char* CheckParm(const char* psz, const char** ppszValue = 0) const = 0;
		virtual void RemoveParm() const = 0;
		virtual void AppendParm(const char* pszParm, const char* pszValues) = 0;

		virtual const char* ParmValue(const char* psz, const char* pDefaultVal = 0) const = 0;
		virtual int ParmValue(const char* psz, int nDefaultVal) const = 0;
		virtual float ParmValue(const char* psz, float flDefaultVal) const = 0;

		virtual int ParmCount() const = 0;
		virtual int FindParm(const char* psz) const = 0;
		virtual const char* GetParm(int nIndex) const = 0;
		virtual void SetParm(int nIndex, char const* pParm) = 0;

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
