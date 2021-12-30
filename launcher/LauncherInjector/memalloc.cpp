#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include "memalloc.h"
#include <stdio.h>

extern HMODULE hTier0Module;
IMemAlloc** g_ppMemAllocSingleton;

void LoadTier0Handle()
{
    if (!hTier0Module) hTier0Module = GetModuleHandleA("tier0.dll");
    if (!hTier0Module) return;

    g_ppMemAllocSingleton = (IMemAlloc**)GetProcAddress(hTier0Module, "g_pMemAllocSingleton");
}

const int STATIC_ALLOC_SIZE = 16384;

size_t g_iStaticAllocated = 0;
void* g_pLastAllocated = nullptr;
char pStaticAllocBuf[STATIC_ALLOC_SIZE];

// they should never be used here, except in LibraryLoadError // haha not true

void* malloc(size_t n)
{
    //printf("NorthstarLauncher malloc: %llu\n", n);
    // allocate into static buffer
    if (g_iStaticAllocated + n <= STATIC_ALLOC_SIZE)
    {
        void* ret = pStaticAllocBuf + g_iStaticAllocated;
        g_iStaticAllocated += n;
        g_pLastAllocated = ret;
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
    //printf("NorthstarLauncher free: %p\n", p);
    // if it was allocated into the static buffer, just do nothing, safest way to deal with it
    if (p >= pStaticAllocBuf && p <= pStaticAllocBuf + STATIC_ALLOC_SIZE)
        return;

    if (g_ppMemAllocSingleton && *g_ppMemAllocSingleton)
        (*g_ppMemAllocSingleton)->m_vtable->Free(*g_ppMemAllocSingleton, p);
}

void* realloc(void* old_ptr, size_t size) {
    // it was allocated into the static buffer
    if (old_ptr >= pStaticAllocBuf && old_ptr <= pStaticAllocBuf + STATIC_ALLOC_SIZE)
    {
        if (g_pLastAllocated == old_ptr)
        {
            // nothing was allocated after this
            size_t old_size = g_iStaticAllocated - ((size_t)g_pLastAllocated - (size_t)pStaticAllocBuf);
            size_t diff = size - old_size;
            if (diff > 0)
                g_iStaticAllocated += diff;
            return old_ptr;
        }
        else
        {
            return malloc(size);
        }
    }

    if (g_ppMemAllocSingleton && *g_ppMemAllocSingleton)
        return (*g_ppMemAllocSingleton)->m_vtable->Realloc(*g_ppMemAllocSingleton, old_ptr, size);
    return nullptr;
}

void* operator new(size_t n)
{
    return malloc(n);
}

void operator delete(void* p)
{
    free(p);
}
