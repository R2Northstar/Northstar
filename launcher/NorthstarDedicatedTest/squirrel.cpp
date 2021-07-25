#include "pch.h"
#include "squirrel.h"
#include "hooks.h"
#include "hookutils.h"
#include "sigscanning.h"
#include "concommand.h"
#include "modmanager.h"
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

typedef void(*ScriptCompileError)(void* sqvm, const char* error, const char* file, int line, int column);
ScriptCompileError ClientSQCompileError; // only need a client one since ui doesn't have its own func for this
ScriptCompileError ServerSQCompileError;
template<Context context> void ScriptCompileErrorHook(void* sqvm, const char* error, const char* file, int line, int column);

typedef char(*CallScriptInitCallbackType)(void* sqvm, const char* callback);
CallScriptInitCallbackType ClientCallScriptInitCallback;
CallScriptInitCallbackType ServerCallScriptInitCallback;
template<Context context> char CallScriptInitCallbackHook(void* sqvm, const char* callback);

sq_compilebufferType ClientSq_compilebuffer;
sq_compilebufferType ServerSq_compilebuffer;

sq_pushroottableType ClientSq_pushroottable;
sq_pushroottableType ServerSq_pushroottable;

sq_callType ClientSq_call;
sq_callType ServerSq_call;

RegisterSquirrelFuncType ClientRegisterSquirrelFunc;
RegisterSquirrelFuncType ServerRegisterSquirrelFunc;

template<Context context> void ExecuteCodeCommand(const CCommand& args);

// inits
SquirrelManager<CLIENT>* g_ClientSquirrelManager;
SquirrelManager<SERVER>* g_ServerSquirrelManager;
SquirrelManager<UI>* g_UISquirrelManager;

SQInteger NSTestFunc(void* sqvm)
{
	return 1;
}

void InitialiseClientSquirrel(HMODULE baseAddress)
{
	HookEnabler hook;

	// client inits
	g_ClientSquirrelManager = new SquirrelManager<CLIENT>();

	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x12B00, &SQPrintHook<CLIENT>, reinterpret_cast<LPVOID*>(&ClientSQPrint)); // client print function
	RegisterConCommand("script_client", ExecuteCodeCommand<CLIENT>, "Executes script code on the client vm", FCVAR_CLIENTDLL);

	// ui inits
	g_UISquirrelManager = new SquirrelManager<UI>();

	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x12BA0, &SQPrintHook<UI>, reinterpret_cast<LPVOID*>(&UISQPrint)); // ui print function
	RegisterConCommand("script_ui", ExecuteCodeCommand<UI>, "Executes script code on the ui vm", FCVAR_CLIENTDLL);

	// inits for both client and ui, since they share some functions
	ClientSq_compilebuffer = (sq_compilebufferType)((char*)baseAddress + 0x3110);
	ClientSq_pushroottable = (sq_pushroottableType)((char*)baseAddress + 0x5860);
	ClientSq_call = (sq_callType)((char*)baseAddress + 0x8650);
	ClientRegisterSquirrelFunc = (RegisterSquirrelFuncType)((char*)baseAddress + 0x108E0);

	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x26130, &CreateNewVMHook<CLIENT>, reinterpret_cast<LPVOID*>(&ClientCreateNewVM)); // client createnewvm function
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x26E70, &DestroyVMHook<CLIENT>, reinterpret_cast<LPVOID*>(&ClientDestroyVM)); // client destroyvm function
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x79A50, &ScriptCompileErrorHook<CLIENT>, reinterpret_cast<LPVOID*>(&ClientSQCompileError)); // client compileerror function
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x10190, &CallScriptInitCallbackHook<CLIENT>, reinterpret_cast<LPVOID*>(&ClientCallScriptInitCallback)); // client callscriptinitcallback function
}

void InitialiseServerSquirrel(HMODULE baseAddress)
{
	g_ServerSquirrelManager = new SquirrelManager<SERVER>();

	HookEnabler hook;

	ServerSq_compilebuffer = (sq_compilebufferType)((char*)baseAddress + 0x3110);
	ServerSq_pushroottable = (sq_pushroottableType)((char*)baseAddress + 0x5840);
	ServerSq_call = (sq_callType)((char*)baseAddress + 0x8620);
	ServerRegisterSquirrelFunc = (RegisterSquirrelFuncType)((char*)baseAddress + 0x1DDD10);

	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x1FE90, &SQPrintHook<SERVER>, reinterpret_cast<LPVOID*>(&ServerSQPrint)); // server print function
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x260E0, &CreateNewVMHook<SERVER>, reinterpret_cast<LPVOID*>(&ServerCreateNewVM)); // server createnewvm function
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x26E20, &DestroyVMHook<SERVER>, reinterpret_cast<LPVOID*>(&ServerDestroyVM)); // server destroyvm function
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x799E0, &ScriptCompileErrorHook<SERVER>, reinterpret_cast<LPVOID*>(&ServerSQCompileError)); // server compileerror function

	RegisterConCommand("script", ExecuteCodeCommand<SERVER>, "Executes script code on the server vm", FCVAR_GAMEDLL);
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
			g_UISquirrelManager->VMCreated(sqvm);
		else
			g_ClientSquirrelManager->VMCreated(sqvm);
	}
	else if (context == SERVER)
	{
		sqvm = ServerCreateNewVM(a1, context);
		g_ServerSquirrelManager->VMCreated(sqvm);
	}

	spdlog::info("CreateNewVM {} {}", GetContextName(realContext), sqvm);
	return sqvm;
}

template<Context context> void DestroyVMHook(void* a1, void* sqvm)
{
	Context realContext = context; // ui and client use the same function so we use this for prints

	if (context == CLIENT)
	{
		if (g_ClientSquirrelManager->sqvm == sqvm)
			g_ClientSquirrelManager->VMDestroyed();
		else if (g_UISquirrelManager->sqvm == sqvm)
		{
			g_UISquirrelManager->VMDestroyed();
			realContext = UI;
		}

		ClientDestroyVM(a1, sqvm);
	}
	else if (context == SERVER)
	{
		g_ServerSquirrelManager->VMDestroyed();
		ServerDestroyVM(a1, sqvm);
	}

	spdlog::info("DestroyVM {} {}", GetContextName(realContext), sqvm);
}

template<Context context> void ScriptCompileErrorHook(void* sqvm, const char* error, const char* file, int line, int column)
{
	// note: i think vanilla might actually show the script line that errored, might be nice to implement that if it's a thing
	// look into client.dll+79540 for way better errors too

	Context realContext = context; // ui and client use the same function so we use this for prints
	if (context == CLIENT && sqvm == g_UISquirrelManager->sqvm)
		realContext = UI;

	spdlog::error("{} SCRIPT COMPILE ERROR {}", GetContextName(realContext), error);
	spdlog::error("{} line [{}] column [{}]", file, line, column);

	// dont call the original since it kills game
	// in the future it'd be nice to do an actual error with UICodeCallback_ErrorDialog here, but only if we're compiling level scripts
	// compilestring and stuff shouldn't tho
	// though, that also has potential to be REALLY bad if we're compiling ui scripts lol
}

template<Context context> char CallScriptInitCallbackHook(void* sqvm, const char* callback)
{
	char ret;

	if (context == CLIENT)
	{
		Context realContext = context; // ui and client use the same function so we use this for prints
		bool shouldCallCustomCallbacks = false;
		
		// since we don't hook arbitrary callbacks yet, make sure we're only doing callbacks on inits
		if (!strcmp(callback, "UICodeCallback_UIInit"))
		{
			realContext = UI;
			shouldCallCustomCallbacks = true;
		}
		else if (!strcmp(callback, "ClientCodeCallback_MapSpawn"))
			shouldCallCustomCallbacks = true;

		// run before callbacks
		// todo: we need to verify if RunOn is valid for current state before calling callbacks
		if (shouldCallCustomCallbacks)
		{
			for (Mod* mod : g_ModManager->m_loadedMods)
			{
				for (ModScript* script : mod->Scripts)
				{
					for (ModScriptCallback* modCallback : script->Callbacks)
					{
						if (modCallback->Context == realContext && modCallback->BeforeCallback.length())
						{
							spdlog::info("Running custom {} script callback \"{}\"", GetContextName(realContext), modCallback->BeforeCallback);
							ClientCallScriptInitCallback(sqvm, modCallback->BeforeCallback.c_str());
						}
					}
				}
			}
		}

		spdlog::info("{} CodeCallback {} called", GetContextName(realContext), callback);
		if (!shouldCallCustomCallbacks)
			spdlog::info("Not executing custom callbacks for CodeCallback {}", callback);
		ret = ClientCallScriptInitCallback(sqvm, callback);

		// run after callbacks
		if (shouldCallCustomCallbacks)
		{
			for (Mod* mod : g_ModManager->m_loadedMods)
			{
				for (ModScript* script : mod->Scripts)
				{
					for (ModScriptCallback* modCallback : script->Callbacks)
					{
						if (modCallback->Context == realContext && modCallback->AfterCallback.length())
						{
							spdlog::info("Running custom {} script callback \"{}\"", GetContextName(realContext), modCallback->AfterCallback);
							ClientCallScriptInitCallback(sqvm, modCallback->AfterCallback.c_str());
						}
					}
				}
			}
		}
	}
	else if (context == SERVER)
	{
		// since we don't hook arbitrary callbacks yet, make sure we're only doing callbacks on inits
		bool shouldCallCustomCallbacks = !strcmp(callback, "CodeCallback_MapSpawn");

		// run before callbacks
		// todo: we need to verify if RunOn is valid for current state before calling callbacks
		if (shouldCallCustomCallbacks)
		{
			for (Mod* mod : g_ModManager->m_loadedMods)
			{
				for (ModScript* script : mod->Scripts)
				{
					for (ModScriptCallback* modCallback : script->Callbacks)
					{
						if (modCallback->Context == SERVER && modCallback->BeforeCallback.length())
						{
							spdlog::info("Running custom {} script callback \"{}\"", GetContextName(context), modCallback->BeforeCallback);
							ServerCallScriptInitCallback(sqvm, modCallback->BeforeCallback.c_str());
						}
					}
				}
			}
		}

		spdlog::info("{} CodeCallback {} called", GetContextName(context), callback);
		if (!shouldCallCustomCallbacks)
			spdlog::info("Not executing custom callbacks for CodeCallback {}", callback);
		ret = ServerCallScriptInitCallback(sqvm, callback);

		// run after callbacks
		if (shouldCallCustomCallbacks)
		{
			for (Mod* mod : g_ModManager->m_loadedMods)
			{
				for (ModScript* script : mod->Scripts)
				{
					for (ModScriptCallback* modCallback : script->Callbacks)
					{
						if (modCallback->Context == SERVER  && modCallback->AfterCallback.length())
						{
							spdlog::info("Running custom {} script callback \"{}\"", GetContextName(context), modCallback->AfterCallback);
							ClientCallScriptInitCallback(sqvm, modCallback->AfterCallback.c_str());
						}
					}
				}
			}
		}
	}

	return ret;
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