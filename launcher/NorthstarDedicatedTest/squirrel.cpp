#include "pch.h"
#include "squirrel.h"
#include "hooks.h"
#include "hookutils.h"
#include "sigscanning.h"
#include <iostream>

// hook forward declarations
typedef SQInteger(*SQPrintType)(void* sqvm, char* fmt, ...);
SQPrintType ClientSQPrint;
SQPrintType UISQPrint;
SQPrintType ServerSQPrint;
template<Context context> SQInteger SQPrintHook(void* sqvm, char* fmt, ...);


// inits
SquirrelManager<CLIENT>* g_ClientSquirrelManager;
SquirrelManager<SERVER>* g_ServerSquirrelManager;

void InitialiseClientSquirrel(HMODULE baseAddress)
{
	g_ClientSquirrelManager = new SquirrelManager<CLIENT>();

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x12B00, &SQPrintHook<CLIENT>, reinterpret_cast<LPVOID*>(&ClientSQPrint));

	// ui inits
	// currently these are mostly incomplete

	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x12BA0, &SQPrintHook<UI>, reinterpret_cast<LPVOID*>(&UISQPrint));
}

void InitialiseServerSquirrel(HMODULE baseAddress)
{
	g_ServerSquirrelManager = new SquirrelManager<SERVER>();

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x1FE90, &SQPrintHook<SERVER>, reinterpret_cast<LPVOID*>(&ServerSQPrint));
}

// hooks
template<Context context> SQInteger SQPrintHook(void* sqvm, char* fmt, ...)
{
	va_list va;
	va_start(va, fmt);

	SQChar buf[1024];
	int charsWritten = vsnprintf_s(buf, _TRUNCATE, fmt, va);

	if (charsWritten > 0)
	{
		if (buf[charsWritten - 1] == '\n')
			buf[charsWritten - 1] == '\0';

		Log(context, buf, "");
	}

	va_end(va);
	return 0;
}


// manager
template<Context context> SquirrelManager<context>::SquirrelManager()
{
	
}