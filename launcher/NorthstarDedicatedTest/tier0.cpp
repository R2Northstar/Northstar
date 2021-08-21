#include "pch.h"
#include "tier0.h"
#include <stdio.h>
#include <iostream>

void* ResolveTier0Function(const char* name)
{
	HMODULE tier0 = GetModuleHandle(L"tier0.dll");

	// todo: maybe cache resolved funcs? idk the performance hit of getprocaddress
	std::cout << "ResolveTier0Function " << name << " " << tier0 << "::" <<  GetProcAddress(tier0, name) << std::endl;
	return GetProcAddress(tier0, name);
}

// memory stuff
typedef IMemAlloc* (*Tier0CreateGlobalMemAlloc)();
void* operator new(size_t n)
{
	// we should be trying to use tier0's g_pMemAllocSingleton, but atm i can't get it stable
	// this actually seems relatively stable though, somehow???
	return malloc(n);

	//IMemAlloc** alloc = (IMemAlloc**)ResolveTier0Function("g_pMemAllocSingleton");
	//if (!alloc)
	//{
	//	Tier0CreateGlobalMemAlloc createAlloc = (Tier0CreateGlobalMemAlloc)ResolveTier0Function("CreateGlobalMemAlloc");
	//	if (!createAlloc)
	//		return malloc(n);
	//	else
	//		(*alloc) = createAlloc();
	//}
	//
	//return (*alloc)->m_vtable->Alloc(*alloc, n);
}

void operator delete(void* p) throw()
{
	// we should be trying to use tier0's g_pMemAllocSingleton, but atm i can't get it stable
	// this actually seems relatively stable though, somehow???
	free(p);

	//IMemAlloc** alloc = (IMemAlloc**)ResolveTier0Function("g_pMemAllocSingleton");
	//if (!alloc)
	//{
	//	Tier0CreateGlobalMemAlloc createAlloc = (Tier0CreateGlobalMemAlloc)ResolveTier0Function("CreateGlobalMemAlloc");
	//	if (!createAlloc)
	//	{
	//		free(p);
	//		return;
	//	}
	//	else
	//		(*alloc) = createAlloc();
	//}
	//
	//(*alloc)->m_vtable->Free(*alloc, p);
}

typedef void(*Tier0Error)(const char* fmt, ...);
void Error(const char* fmt, ...)
{
	Tier0Error tier0Func = (Tier0Error)ResolveTier0Function("Error");

	// reformat args because you can't pass varargs between funcs
	char buf[1024];

	va_list args;
	va_start(args, fmt);
	vsnprintf(buf, sizeof(buf), fmt, args);
	va_end(args);

	// tier0 isn't loaded yet
	//if (tier0Func)
	//	tier0Func(buf);
	//else
		std::cout << "FATAL ERROR " << buf << std::endl;
}

typedef double(*Tier0FloatTime)();
double Plat_FloatTime()
{
	Tier0FloatTime tier0Func = (Tier0FloatTime)ResolveTier0Function("Plat_FloatTime");

	if (tier0Func)
		return tier0Func();
	else
		return 0.0f;
}