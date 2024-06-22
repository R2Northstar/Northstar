#include "core/memalloc.h"
#include "core/tier0.h"

// TODO: rename to malloc and free after removing statically compiled .libs

void* _malloc_base(size_t n)
{
	// allocate into static buffer if g_pMemAllocSingleton isn't initialised
	if (!g_pMemAllocSingleton)
		TryCreateGlobalMemAlloc();

	return g_pMemAllocSingleton->m_vtable->Alloc(g_pMemAllocSingleton, n);
}

/*extern "C" void* malloc(size_t n)
{
	return _malloc_base(n);
}*/

void _free_base(void* p)
{
	if (!g_pMemAllocSingleton)
		TryCreateGlobalMemAlloc();

	g_pMemAllocSingleton->m_vtable->Free(g_pMemAllocSingleton, p);
}

void* _realloc_base(void* oldPtr, size_t size)
{
	if (!g_pMemAllocSingleton)
		TryCreateGlobalMemAlloc();

	return g_pMemAllocSingleton->m_vtable->Realloc(g_pMemAllocSingleton, oldPtr, size);
}

void* _calloc_base(size_t n, size_t size)
{
	size_t bytes = n * size;
	void* memory = _malloc_base(bytes);
	if (memory)
	{
		memset(memory, 0, bytes);
	}
	return memory;
}

void* _recalloc_base(void* const block, size_t const count, size_t const size)
{
	if (!block)
		return _calloc_base(count, size);

	const size_t new_size = count * size;
	const size_t old_size = _msize(block);

	void* const memory = _realloc_base(block, new_size);

	if (memory && old_size < new_size)
	{
		memset(static_cast<char*>(memory) + old_size, 0, new_size - old_size);
	}

	return memory;
}

size_t _msize(void* const block)
{
	if (!g_pMemAllocSingleton)
		TryCreateGlobalMemAlloc();

	return g_pMemAllocSingleton->m_vtable->GetSize(g_pMemAllocSingleton, block);
}

char* _strdup_base(const char* src)
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

void operator delete(void* p) noexcept
{
	_free_base(p);
} // /FORCE:MULTIPLE
