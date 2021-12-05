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
char pStaticAllocBuf[STATIC_ALLOC_SIZE];

void* operator new(size_t n)
{
	// allocate into static buffer if g_pMemAllocSingleton isn't initialised
	if (g_pMemAllocSingleton)
		return g_pMemAllocSingleton->m_vtable->Alloc(g_pMemAllocSingleton, n);
	else
	{
		void* ret = pStaticAllocBuf + g_iStaticAllocated;
		g_iStaticAllocated += n;
		return ret;
	}	
}

void operator delete(void* p)
{
	// if it was allocated into the static buffer, just do nothing, safest way to deal with it
	if (p >= pStaticAllocBuf && p <= pStaticAllocBuf + STATIC_ALLOC_SIZE)
		return;

	g_pMemAllocSingleton->m_vtable->Free(g_pMemAllocSingleton, p);
}