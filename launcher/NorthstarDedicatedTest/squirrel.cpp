#include "pch.h"
#include "squirrel.h"
#include "hooks.h"
#include "hookutils.h"
#include "sigscanning.h"
#include "concommand.h"
#include <iostream>

// hook forward declarations
typedef SQInteger(*SQPrintType)(void* sqvm, char* fmt, ...);
SQPrintType ClientSQPrint;
SQPrintType UISQPrint;
SQPrintType ServerSQPrint;
template<Context context> SQInteger SQPrintHook(void* sqvm, char* fmt, ...);

typedef void*(*CreateNewVMType)(void* a1, Context contextArg);
CreateNewVMType ClientCreateNewVM; // only need a client one since ui doesn't have its own func for this
CreateNewVMType ServerCreateNewVM;
template<Context context> void* CreateNewVMHook(void* a1, Context contextArg);

typedef void(*DestroyVMType)(void* a1, void* sqvm);
DestroyVMType ClientDestroyVM; // only need a client one since ui doesn't have its own func for this
DestroyVMType ServerDestroyVM;
template<Context context> void DestroyVMHook(void* a1, void* sqvm);

typedef void (*SQCompileErrorType)(void* sqvm, const char* error, const char* file, int line, int column);
SQCompileErrorType ClientSQCompileError; // only need a client one since ui doesn't have its own func for this
SQCompileErrorType ServerSQCompileError;
template<Context context> void SQCompileErrorHook(void* sqvm, const char* error, const char* file, int line, int column);

sq_compilebufferType ClientSq_compilebuffer;
sq_compilebufferType ServerSq_compilebuffer;

sq_pushroottableType ClientSq_pushroottable;
sq_pushroottableType ServerSq_pushroottable;

sq_callType ClientSq_call;
sq_callType ServerSq_call;

template<Context context> void ExecuteCodeCommand(const CCommand& args);

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
	RegisterConCommand("script_client", ExecuteCodeCommand<CLIENT>, "Executes script code in the client vm", FCVAR_CLIENTDLL);

	// ui inits
	g_UISquirrelManager = new SquirrelManager<UI>();
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x12BA0, &SQPrintHook<UI>, reinterpret_cast<LPVOID*>(&UISQPrint)); // ui print function
	RegisterConCommand("script_ui", ExecuteCodeCommand<UI>, "Executes script code in the client vm", FCVAR_CLIENTDLL);

	// inits for both client and ui, since they share some functions
	ClientSq_compilebuffer = (sq_compilebufferType)((char*)baseAddress + 0x3110);
	ClientSq_pushroottable = (sq_pushroottableType)((char*)baseAddress + 0x5860);
	ClientSq_call = (sq_callType)((char*)baseAddress + 0x8650);

	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x26130, &CreateNewVMHook<CLIENT>, reinterpret_cast<LPVOID*>(&ClientCreateNewVM)); // client createnewvm function
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x26E70, &DestroyVMHook<CLIENT>, reinterpret_cast<LPVOID*>(&ClientDestroyVM)); // client destroyvm function
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x79A50, &SQCompileErrorHook<CLIENT>, reinterpret_cast<LPVOID*>(&ClientSQCompileError)); // client compileerror function
}

void InitialiseServerSquirrel(HMODULE baseAddress)
{
	g_ServerSquirrelManager = new SquirrelManager<SERVER>();

	HookEnabler hook;

	ServerSq_compilebuffer = (sq_compilebufferType)((char*)baseAddress + 0x3110);
	ServerSq_pushroottable = (sq_pushroottableType)((char*)baseAddress + 0x5840);
	ServerSq_call = (sq_callType)((char*)baseAddress + 0x8620);

	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x1FE90, &SQPrintHook<SERVER>, reinterpret_cast<LPVOID*>(&ServerSQPrint)); // server print function
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x260E0, &CreateNewVMHook<SERVER>, reinterpret_cast<LPVOID*>(&ServerCreateNewVM)); // server createnewvm function
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x26E20, &DestroyVMHook<SERVER>, reinterpret_cast<LPVOID*>(&ServerDestroyVM)); // server destroyvm function
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x799E0, &SQCompileErrorHook<SERVER>, reinterpret_cast<LPVOID*>(&ServerSQCompileError)); // server compileerror function

	RegisterConCommand("script", ExecuteCodeCommand<SERVER>, "Executes script code in the server vm", FCVAR_GAMEDLL);
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
			buf[charsWritten - 1] = '\0';

		spdlog::info("[{} SCRIPT] {}", GetContextName(context), buf);
	}

	va_end(va);
	return 0;
}

template<Context context> void* CreateNewVMHook(void* a1, Context realContext)
{	
	void* sqvm;

	if (context == CLIENT)
	{
		sqvm = ClientCreateNewVM(a1, realContext);

		if (realContext == UI)
			g_UISquirrelManager->sqvm = sqvm;
		else
			g_ClientSquirrelManager->sqvm = sqvm;
	}
	else if (context == SERVER)
	{
		sqvm = ServerCreateNewVM(a1, context);
		g_ServerSquirrelManager->sqvm = sqvm;
	}

	spdlog::info("CreateNewVM {} {}", GetContextName(context), sqvm);
	return sqvm;
}

template<Context context> void DestroyVMHook(void* a1, void* sqvm)
{
	Context realContext = context; // ui and client use the same function so we use this for prints

	if (context == CLIENT)
	{
		if (g_ClientSquirrelManager->sqvm == sqvm)
			g_ClientSquirrelManager->sqvm = nullptr;
		else if (g_UISquirrelManager->sqvm == sqvm)
		{
			g_UISquirrelManager->sqvm = nullptr;
			realContext == UI;
		}

		ClientDestroyVM(a1, sqvm);
	}
	else if (context == SERVER)
	{
		g_ServerSquirrelManager->sqvm = nullptr;
		ServerDestroyVM(a1, sqvm);
	}

	spdlog::info("DestroyVM {} {}", GetContextName(realContext), sqvm);
}

template<Context context> void SQCompileErrorHook(void* sqvm, const char* error, const char* file, int line, int column)
{
	// note: i think vanilla might actually show the script line that errored, might be nice to implement that if it's a thing
	// look into client.dll+79540 for way better errors too

	Context realContext = context;
	if (context == CLIENT && sqvm == g_UISquirrelManager->sqvm)
		realContext = UI;

	spdlog::error("{} SCRIPT COMPILE ERROR {}", GetContextName(realContext), error);
	spdlog::error("{} line [{}] column [{}]", file, line, column);

	// dont call the original since it kills game
	// in the future it'd be nice to do an actual error with UICodeCallback_ErrorDialog here, but only if we're compiling level scripts
	// compilestring and stuff shouldn't tho
	// though, that also has potential to be REALLY bad if we're compiling ui scripts lol
}

template<Context context> void ExecuteCodeCommand(const CCommand& args)
{
	if (context == CLIENT)
		g_ClientSquirrelManager->ExecuteCode(args.ArgS());
	else if (context == UI)
		g_UISquirrelManager->ExecuteCode(args.ArgS());
	else if (context == SERVER)
		g_ServerSquirrelManager->ExecuteCode(args.ArgS());
}