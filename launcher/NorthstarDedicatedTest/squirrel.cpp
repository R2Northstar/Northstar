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

typedef void* (*CreateNewVMType)(void* a1, Context contextArg);
CreateNewVMType ClientCreateNewVM; // only need a client one since ui doesn't have its own func for this
CreateNewVMType ServerCreateNewVM;
void* CreateNewVMHook(void* a1, Context contextArg);

// inits
SquirrelManager<CLIENT>* g_ClientSquirrelManager;
SquirrelManager<SERVER>* g_ServerSquirrelManager;
SquirrelManager<UI>* g_UISquirrelManager;

void InitialiseClientSquirrel(HMODULE baseAddress)
{
	HookEnabler hook;

	// client inits
	g_ClientSquirrelManager = new SquirrelManager<CLIENT>();
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x12B00, &SQPrintHook<CLIENT>, reinterpret_cast<LPVOID*>(&ClientSQPrint)); // client print function

	// ui inits
	g_UISquirrelManager = new SquirrelManager<UI>();
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x12BA0, &SQPrintHook<UI>, reinterpret_cast<LPVOID*>(&UISQPrint)); // ui print function

	// hooks for both client and ui, since they share some functions
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x26130, &CreateNewVMHook, reinterpret_cast<LPVOID*>(&ClientCreateNewVM)); // client createnewvm function
}

void InitialiseServerSquirrel(HMODULE baseAddress)
{
	g_ServerSquirrelManager = new SquirrelManager<SERVER>();

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x1FE90, &SQPrintHook<SERVER>, reinterpret_cast<LPVOID*>(&ServerSQPrint)); // server print function
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x260E0, &CreateNewVMHook, reinterpret_cast<LPVOID*>(&ServerCreateNewVM)); // server createnewvm function
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

		spdlog::info("[{} SCRIPT] {}", GetContextName(context), buf);
	}

	va_end(va);
	return 0;
}

void* CreateNewVMHook(void* a1, Context context)
{
	std::cout << "CreateNewVM " << GetContextName(context) << std::endl;
	
	if (context == CLIENT)
	{
		void* sqvm = ClientCreateNewVM(a1, context);
		g_ClientSquirrelManager->sqvm = sqvm;

		return sqvm;
	}
	else if (context == UI)
	{
		void* sqvm = ClientCreateNewVM(a1, context);
		g_UISquirrelManager->sqvm = sqvm;

		return sqvm;
	}
	else if (context == SERVER)
	{
		void* sqvm = ServerCreateNewVM(a1, context);
		g_ServerSquirrelManager->sqvm = sqvm;

		return sqvm;
	}
}

// manager
template<Context context> SquirrelManager<context>::SquirrelManager() : sqvm(nullptr)
{
	
}