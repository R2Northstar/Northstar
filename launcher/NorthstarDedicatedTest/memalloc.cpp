#include "pch.h"
#include "memalloc.h"
#include "gameutils.h"

// TODO: rename to malloc and free after removing statically compiled .libs

extern "C" void* _malloc_base(size_t n)
{
	// allocate into static buffer if g_pMemAllocSingleton isn't initialised
	if (!g_pMemAllocSingleton)
	{
		InitialiseTier0GameUtilFunctions(GetModuleHandleA("tier0.dll"));
	}
	return g_pMemAllocSingleton->m_vtable->Alloc(g_pMemAllocSingleton, n);
}

/*extern "C" void* malloc(size_t n)
{
	return _malloc_base(n);
}*/

extern "C" void _free_base(void* p)
{
	if (!g_pMemAllocSingleton)
	{
		spdlog::warn("Trying to free something before g_pMemAllocSingleton was ready, this should never happen");
		InitialiseTier0GameUtilFunctions(GetModuleHandleA("tier0.dll"));
	}
	g_pMemAllocSingleton->m_vtable->Free(g_pMemAllocSingleton, p);
}

extern "C" void* _realloc_base(void* oldPtr, size_t size)
{
	if (!g_pMemAllocSingleton)
	{
		InitialiseTier0GameUtilFunctions(GetModuleHandleA("tier0.dll"));
	}
	return g_pMemAllocSingleton->m_vtable->Realloc(g_pMemAllocSingleton, oldPtr, size);
}

extern "C" void* _calloc_base(size_t n, size_t size)
{
	size_t bytes = n * size;
	void* memory = _malloc_base(bytes);
	if (memory)
	{
		memset(memory, 0, bytes);
	}
	return memory;
}

extern "C" char* _strdup_base(const char* src)
{
	char* str;
	char* p;
	int len = 0;

	while (src[len])
		len++;
	str = reinterpret_cast<char*>(_malloc_base(len + 1));
	p = str;
	while (*src)
		*p++ = *src++;
	*p = '\0';
	return str;
}

void* operator new(size_t n)
{
	return _malloc_base(n);
}

void operator delete(void* p)
{
	_free_base(p);
} // /FORCE:MULTIPLE