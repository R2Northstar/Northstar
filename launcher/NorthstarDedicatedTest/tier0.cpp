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
	if (tier0Func)
		tier0Func(buf);
	else
		std::cout << "FATAL ERROR " << buf << std::endl;
}