#include "pch.h"
#include "memalloc.h"
#include "gameutils.h"

// so for anyone reading this code, you may be curious why the fuck i'm overriding new to alloc into a static 100k buffer
// pretty much, the issue here is that we need to use the game's memory allocator (g_pMemAllocSingleton) or risk heap corruptions, but this allocator is defined in tier0
// as such, it doesn't exist when we inject
// initially i wanted to just call malloc and free until g_pMemAllocSingleton was initialised, but the issue then becomes that we might try to 
// call g_pMemAllocSingleton->Free on memory that was allocated with malloc, which will cause game to crash
// so, the best idea i had for this was to just alloc 100k of memory, have all pre-tier0 allocations use that 
// (from what i can tell we hit about 12k before tier0 is loaded atm in debug builds, so it's more than enough)
// then just use the game's allocator after that
// yes, this means we leak 100k of memory, idk how else to do this without breaking stuff

const int STATIC_ALLOC_SIZE = 100000; // alot more than we need, could reduce to 50k or even 25k later potentially

size_t g_iStaticAllocated = 0;
void* g_pLastAllocated = nullptr;
char pStaticAllocBuf[STATIC_ALLOC_SIZE];

// TODO: rename to malloc and free after removing statically compiled .libs

void* malloc_(size_t n)
{
	// allocate into static buffer if g_pMemAllocSingleton isn't initialised
	if (g_pMemAllocSingleton)
	{
		//printf("Northstar malloc (g_pMemAllocSingleton): %llu\n", n);
		return g_pMemAllocSingleton->m_vtable->Alloc(g_pMemAllocSingleton, n);
	}
	else
	{
		if (g_iStaticAllocated + n > STATIC_ALLOC_SIZE)
		{
			throw "Ran out of prealloc space"; // we could log, but spdlog probably does use allocations as well...
		}
		//printf("Northstar malloc (prealloc): %llu\n", n);
		void* ret = pStaticAllocBuf + g_iStaticAllocated;
		g_iStaticAllocated += n;
		return ret;
	}
}

void free_(void* p)
{
	// if it was allocated into the static buffer, just do nothing, safest way to deal with it
	if (p >= pStaticAllocBuf && p <= pStaticAllocBuf + STATIC_ALLOC_SIZE)
	{
		//printf("Northstar free (prealloc): %p\n", p);
		return;
	}

	//printf("Northstar free (g_pMemAllocSingleton): %p\n", p);
	g_pMemAllocSingleton->m_vtable->Free(g_pMemAllocSingleton, p);
}

void* realloc_(void* old_ptr, size_t size) {
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
			return malloc_(size);
		}
	}

	if (g_pMemAllocSingleton)
		return g_pMemAllocSingleton->m_vtable->Realloc(g_pMemAllocSingleton, old_ptr, size);
}

void* operator new(size_t n)
{
	return malloc_(n);
}

void operator delete(void* p)
{
	free_(p);
}