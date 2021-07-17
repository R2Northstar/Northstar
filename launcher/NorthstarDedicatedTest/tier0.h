#pragma once
#include "pch.h"

// get exported tier0 by name 
void* ResolveTier0Function(const char* name);

// memory stuff
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

void* operator new(std::size_t n);
void operator delete(void* p) throw();

// actual function defs
// would've liked to resolve these at compile time, but we load before tier0 so not really possible
void Error(const char* fmt, ...);