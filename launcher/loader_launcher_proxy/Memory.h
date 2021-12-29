#pragma once

class IMemAlloc
{
public:
    struct VTable
    {
        void* unknown[1];
        void* (*Alloc) (IMemAlloc* memAlloc, size_t nSize);
        void* unknown2[3];
        void(*Free) (IMemAlloc* memAlloc, void* pMem);
    };

    VTable* m_vtable;
};
