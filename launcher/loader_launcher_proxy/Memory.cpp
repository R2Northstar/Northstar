#include "pch.h"

extern HMODULE hTier0Module;
IMemAlloc** g_ppMemAllocSingleton;

void LoadTier0Handle()
{
    if (!hTier0Module) hTier0Module = GetModuleHandleA("tier0.dll");
    if (!hTier0Module) return;

    g_ppMemAllocSingleton = (IMemAlloc**)GetProcAddress(hTier0Module, "g_pMemAllocSingleton");
}

const int STATIC_ALLOC_SIZE = 4096;

size_t g_iStaticAllocated = 0;
char pStaticAllocBuf[STATIC_ALLOC_SIZE];

// they should never be used here, except in LibraryLoadError?

void* malloc(size_t n)
{
    // allocate into static buffer
    if (g_iStaticAllocated + n <= STATIC_ALLOC_SIZE)
    {
        void* ret = pStaticAllocBuf + g_iStaticAllocated;
        g_iStaticAllocated += n;
        return ret;
    }
    else
    {
        // try to fallback to g_pMemAllocSingleton
        if (!hTier0Module || !g_ppMemAllocSingleton) LoadTier0Handle();
        if (g_ppMemAllocSingleton && *g_ppMemAllocSingleton)
            return (*g_ppMemAllocSingleton)->m_vtable->Alloc(*g_ppMemAllocSingleton, n);
        else
            throw "Cannot allocate";
    }
}

void free(void* p)
{
    // if it was allocated into the static buffer, just do nothing, safest way to deal with it
    if (p >= pStaticAllocBuf && p <= pStaticAllocBuf + STATIC_ALLOC_SIZE)
        return;

    if (g_ppMemAllocSingleton && *g_ppMemAllocSingleton)
        (*g_ppMemAllocSingleton)->m_vtable->Free(*g_ppMemAllocSingleton, p);
}

void* operator new(size_t n)
{
    return malloc(n);
}

void operator delete(void* p)
{
    return free(p);
}
