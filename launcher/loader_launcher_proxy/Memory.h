#pragma once

class IMemAlloc
{
public:
    struct VTable
    {
        void* unknown[1]; // alloc debug
        void* (*Alloc) (IMemAlloc* memAlloc, size_t nSize);
        void* unknown2[1]; // realloc debug
        void* (*Realloc)(IMemAlloc* memAlloc, void* pMem, size_t nSize);
        void* unknown3[1]; // free #1
        void (*Free) (IMemAlloc* memAlloc, void* pMem);
        void* unknown4[2]; // nullsubs, maybe CrtSetDbgFlag
        size_t(*GetSize) (IMemAlloc* memAlloc, void* pMem);
        void* unknown5[9]; // they all do literally nothing
        void (*DumpStats) (IMemAlloc* memAlloc);
        void (*DumpStatsFileBase) (IMemAlloc* memAlloc, const char* pchFileBase);
        void* unknown6[4];
        int (*heapchk) (IMemAlloc* memAlloc);
    };

    VTable* m_vtable;
};
