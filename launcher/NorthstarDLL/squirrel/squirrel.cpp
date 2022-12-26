#include "pch.h"
#include "squirrel.h"
#include "core/convar/concommand.h"
#include "mods/modmanager.h"
#include "dedicated/dedicated.h"
#include "engine/r2engine.h"
#include "core/tier0.h"

#include <any>

AUTOHOOK_INIT()

std::shared_ptr<ColoredLogger> getSquirrelLoggerByContext(ScriptContext context)
{
	switch (context)
	{
	case ScriptContext::UI:
		return NS::log::SCRIPT_UI;
	case ScriptContext::CLIENT:
		return NS::log::SCRIPT_CL;
	case ScriptContext::SERVER:
		return NS::log::SCRIPT_SV;
	default:
		throw std::runtime_error("getSquirrelLoggerByContext called with invalid context");
		return nullptr;
	}
}

namespace NS::log
{
	template <ScriptContext context> std::shared_ptr<spdlog::logger> squirrel_logger()
	{
		// Switch statements can't be constexpr afaik
		// clang-format off
		if constexpr (context == ScriptContext::UI) { return SCRIPT_UI; }
		if constexpr (context == ScriptContext::CLIENT) { return SCRIPT_CL; }
		if constexpr (context == ScriptContext::SERVER) { return SCRIPT_SV; }
		// clang-format on
	}
}; // namespace NS::log

const char* GetContextName(ScriptContext context)
{
	switch (context)
	{
	case ScriptContext::CLIENT:
		return "CLIENT";
	case ScriptContext::SERVER:
		return "SERVER";
	case ScriptContext::UI:
		return "UI";
	default:
		return "UNKNOWN";
	}
}

const char* GetContextName_Short(ScriptContext context)
{
	switch (context)
	{
	case ScriptContext::CLIENT:
		return "CL";
	case ScriptContext::SERVER:
		return "SV";
	case ScriptContext::UI:
		return "UI";
	default:
		return "??";
	}
}

eSQReturnType SQReturnTypeFromString(const char* pReturnType)
{
	static const std::map<std::string, eSQReturnType> sqReturnTypeNameToString = {
		{"bool", eSQReturnType::Boolean},
		{"float", eSQReturnType::Float},
		{"vector", eSQReturnType::Vector},
		{"int", eSQReturnType::Integer},
		{"entity", eSQReturnType::Entity},
		{"string", eSQReturnType::String},
		{"array", eSQReturnType::Arrays},
		{"asset", eSQReturnType::Asset},
		{"table", eSQReturnType::Table}};

	if (sqReturnTypeNameToString.find(pReturnType) != sqReturnTypeNameToString.end())
		return sqReturnTypeNameToString.at(pReturnType);
	else
		return eSQReturnType::Default; // previous default value
}

ScriptContext ScriptContextFromString(std::string string)
{
	if (string == "UI")
		return ScriptContext::UI;
	if (string == "CLIENT")
		return ScriptContext::CLIENT;
	if (string == "SERVER")
		return ScriptContext::SERVER;
	else
		return ScriptContext::INVALID;
}

const char* SQTypeNameFromID(int type)
{
	switch (type)
	{
	case OT_ASSET:
		return "asset";
	case OT_INTEGER:
		return "int";
	case OT_BOOL:
		return "bool";
	case SQOBJECT_NUMERIC:
		return "float or int";
	case OT_NULL:
		return "null";
	case OT_VECTOR:
		return "vector";
	case 0:
		return "var";
	case OT_USERDATA:
		return "userdata";
	case OT_FLOAT:
		return "float";
	case OT_STRING:
		return "string";
	case OT_ARRAY:
		return "array";
	case 0x8000200:
		return "function";
	case 0x8100000:
		return "structdef";
	case OT_THREAD:
		return "thread";
	case OT_FUNCPROTO:
		return "function";
	case OT_CLAAS:
		return "class";
	case OT_WEAKREF:
		return "weakref";
	case 0x8080000:
		return "unimplemented function";
	case 0x8200000:
		return "struct instance";
	case OT_TABLE:
		return "table";
	case 0xA008000:
		return "instance";
	case OT_ENTITY:
		return "entity";
	}
	return "";
}

// Allows for generating squirrelmessages from plugins.
// Not used in this version, but will be used later
void AsyncCall_External(ScriptContext context, const char* func_name, SquirrelMessage_External_Pop function)
{
	SquirrelMessage message {};
	message.functionName = func_name;
	message.isExternal = true;
	message.externalFunc = function;
	switch (context)
	{
	case ScriptContext::CLIENT:
		g_pSquirrel<ScriptContext::CLIENT>->messageBuffer->push(message);
		break;
	case ScriptContext::SERVER:
		g_pSquirrel<ScriptContext::SERVER>->messageBuffer->push(message);
		break;
	case ScriptContext::UI:
		g_pSquirrel<ScriptContext::UI>->messageBuffer->push(message);
		break;
	}
}

// needed to define implementations for squirrelmanager outside of squirrel.h without compiler errors
template class SquirrelManager<ScriptContext::SERVER>;
template class SquirrelManager<ScriptContext::CLIENT>;
template class SquirrelManager<ScriptContext::UI>;

template <ScriptContext context> void SquirrelManager<context>::VMCreated(CSquirrelVM* newSqvm)
{
	m_pSQVM = newSqvm;

	for (SQFuncRegistration* funcReg : m_funcRegistrations)
	{
		spdlog::info("Registering {} function {}", GetContextName(context), funcReg->squirrelFuncName);
		RegisterSquirrelFunc(m_pSQVM, funcReg, 1);
	}

	for (auto& pair : g_pModManager->m_DependencyConstants)
	{
		bool bWasFound = false;

		for (Mod& dependency : g_pModManager->m_LoadedMods)
		{
			if (!dependency.m_bEnabled)
				continue;

			if (dependency.Name == pair.second)
			{
				bWasFound = true;
				break;
			}
		}

		defconst(m_pSQVM, pair.first.c_str(), bWasFound);
	}
	g_pSquirrel<context>->messageBuffer = new SquirrelMessageBuffer();
}

template <ScriptContext context> void SquirrelManager<context>::VMDestroyed()
{
	m_pSQVM = nullptr;
}

template <ScriptContext context> void SquirrelManager<context>::ExecuteCode(const char* pCode)
{
	if (!m_pSQVM || !m_pSQVM->sqvm)
	{
		spdlog::error("Cannot execute code, {} squirrel vm is not initialised", GetContextName(context));
		return;
	}

	spdlog::info("Executing {} script code {} ", GetContextName(context), pCode);

	std::string strCode(pCode);
	CompileBufferState bufferState = CompileBufferState(strCode);

	SQRESULT compileResult = compilebuffer(&bufferState, "console");
	spdlog::info("sq_compilebuffer returned {}", PrintSQRESULT.at(compileResult));

	if (compileResult != SQRESULT_ERROR)
	{
		pushroottable(m_pSQVM->sqvm);
		SQRESULT callResult = _call(m_pSQVM->sqvm, 0);
		spdlog::info("sq_call returned {}", PrintSQRESULT.at(callResult));
	}
}

template <ScriptContext context> void SquirrelManager<context>::AddFuncRegistration(
	std::string returnType, std::string name, std::string argTypes, std::string helpText, SQFunction func)
{
	SQFuncRegistration* reg = new SQFuncRegistration;

	reg->squirrelFuncName = new char[name.size() + 1];
	strcpy((char*)reg->squirrelFuncName, name.c_str());
	reg->cppFuncName = reg->squirrelFuncName;

	reg->helpText = new char[helpText.size() + 1];
	strcpy((char*)reg->helpText, helpText.c_str());

	reg->returnTypeString = new char[returnType.size() + 1];
	strcpy((char*)reg->returnTypeString, returnType.c_str());
	reg->returnType = SQReturnTypeFromString(returnType.c_str());

	reg->argTypes = new char[argTypes.size() + 1];
	strcpy((char*)reg->argTypes, argTypes.c_str());

	reg->funcPtr = func;

	m_funcRegistrations.push_back(reg);
}

template <ScriptContext context> SQRESULT SquirrelManager<context>::setupfunc(const SQChar* funcname)
{
	pushroottable(m_pSQVM->sqvm);
	pushstring(m_pSQVM->sqvm, funcname, -1);

	SQRESULT result = get(m_pSQVM->sqvm, -2);
	if (result != SQRESULT_ERROR)
		pushroottable(m_pSQVM->sqvm);

	return result;
}

template <ScriptContext context> void SquirrelManager<context>::AddFuncOverride(std::string name, SQFunction func)
{
	m_funcOverrides[name] = func;
}

// hooks
bool IsUIVM(ScriptContext context, HSquirrelVM* pSqvm)
{
	return context != ScriptContext::SERVER && g_pSquirrel<ScriptContext::UI>->m_pSQVM &&
		   g_pSquirrel<ScriptContext::UI>->m_pSQVM->sqvm == pSqvm;
}

template <ScriptContext context> void* (*__fastcall sq_compiler_create)(HSquirrelVM* sqvm, void* a2, void* a3, SQBool bShouldThrowError);
template <ScriptContext context> void* __fastcall sq_compiler_createHook(HSquirrelVM* sqvm, void* a2, void* a3, SQBool bShouldThrowError)
{
	// store whether errors generated from this compile should be fatal
	if (IsUIVM(context, sqvm))
		g_pSquirrel<ScriptContext::UI>->m_bFatalCompilationErrors = bShouldThrowError;
	else
		g_pSquirrel<context>->m_bFatalCompilationErrors = bShouldThrowError;

	return sq_compiler_create<context>(sqvm, a2, a3, bShouldThrowError);
}

template <ScriptContext context> SQInteger (*SQPrint)(HSquirrelVM* sqvm, const char* fmt);
template <ScriptContext context> SQInteger SQPrintHook(HSquirrelVM* sqvm, const char* fmt, ...)
{
	va_list va;
	va_start(va, fmt);

	SQChar buf[1024];
	int charsWritten = vsnprintf_s(buf, _TRUNCATE, fmt, va);

	if (charsWritten > 0)
	{
		if (buf[charsWritten - 1] == '\n')
			buf[charsWritten - 1] = '\0';
		g_pSquirrel<context>->logger->info("{}", buf);
	}

	va_end(va);
	return 0;
}

template <ScriptContext context> CSquirrelVM* (*__fastcall CreateNewVM)(void* a1, ScriptContext realContext);
template <ScriptContext context> CSquirrelVM* __fastcall CreateNewVMHook(void* a1, ScriptContext realContext)
{
	CSquirrelVM* sqvm = CreateNewVM<context>(a1, realContext);
	if (realContext == ScriptContext::UI)
		g_pSquirrel<ScriptContext::UI>->VMCreated(sqvm);
	else
		g_pSquirrel<context>->VMCreated(sqvm);

	spdlog::info("CreateNewVM {} {}", GetContextName(realContext), (void*)sqvm);
	return sqvm;
}

template <ScriptContext context> void (*__fastcall DestroyVM)(void* a1, CSquirrelVM* sqvm);
template <ScriptContext context> void __fastcall DestroyVMHook(void* a1, CSquirrelVM* sqvm)
{
	ScriptContext realContext = context; // ui and client use the same function so we use this for prints
	if (IsUIVM(context, sqvm->sqvm))
	{
		realContext = ScriptContext::UI;
		g_pSquirrel<ScriptContext::UI>->VMDestroyed();
		DestroyVM<ScriptContext::CLIENT>(a1, sqvm); // If we pass UI here it crashes
	}
	else
	{
		g_pSquirrel<context>->VMDestroyed();
		DestroyVM<context>(a1, sqvm);
	}

	spdlog::info("DestroyVM {} {}", GetContextName(realContext), (void*)sqvm);
}

template <ScriptContext context>
void (*__fastcall SQCompileError)(HSquirrelVM* sqvm, const char* error, const char* file, int line, int column);
template <ScriptContext context>
void __fastcall ScriptCompileErrorHook(HSquirrelVM* sqvm, const char* error, const char* file, int line, int column)
{
	bool bIsFatalError = g_pSquirrel<context>->m_bFatalCompilationErrors;
	ScriptContext realContext = context; // ui and client use the same function so we use this for prints
	if (IsUIVM(context, sqvm))
	{
		realContext = ScriptContext::UI;
		bIsFatalError = g_pSquirrel<ScriptContext::UI>->m_bFatalCompilationErrors;
	}

	auto logger = getSquirrelLoggerByContext(realContext);

	logger->error("COMPILE ERROR {}", error);
	logger->error("{} line [{}] column [{}]", file, line, column);

	// use disconnect to display an error message for the compile error, but only if the compilation error was fatal
	// todo, we could get this from sqvm itself probably, rather than hooking sq_compiler_create
	if (bIsFatalError)
	{
		// kill dedicated server if we hit this
		if (IsDedicatedServer())
		{
			// flush the logger before we exit so debug things get saved to log file
			logger->flush();
			exit(EXIT_FAILURE);
		}
		else
		{
			R2::Cbuf_AddText(
				R2::Cbuf_GetCurrentPlayer(),
				fmt::format("disconnect \"Encountered {} script compilation error, see console for details.\"", GetContextName(realContext))
					.c_str(),
				R2::cmd_source_t::kCommandSrcCode);

			// likely temp: show console so user can see any errors, as error message wont display if ui is dead
			// maybe we could disable all mods other than the coremods and try a reload before doing this?
			// could also maybe do some vgui bullshit to show something visually rather than console
			if (realContext == ScriptContext::UI)
				R2::Cbuf_AddText(R2::Cbuf_GetCurrentPlayer(), "showconsole", R2::cmd_source_t::kCommandSrcCode);
		}
	}

	// dont call the original function since it kills game lol
}

template <ScriptContext context>
int64_t (*__fastcall RegisterSquirrelFunction)(CSquirrelVM* sqvm, SQFuncRegistration* funcReg, char unknown);
template <ScriptContext context>
int64_t __fastcall RegisterSquirrelFunctionHook(CSquirrelVM* sqvm, SQFuncRegistration* funcReg, char unknown)
{
	if (IsUIVM(context, sqvm->sqvm))
	{
		if (g_pSquirrel<ScriptContext::UI>->m_funcOverrides.count(funcReg->squirrelFuncName))
		{
			g_pSquirrel<ScriptContext::UI>->m_funcOriginals[funcReg->squirrelFuncName] = funcReg->funcPtr;
			funcReg->funcPtr = g_pSquirrel<ScriptContext::UI>->m_funcOverrides[funcReg->squirrelFuncName];
			spdlog::info("Replacing {} in UI", std::string(funcReg->squirrelFuncName));
		}

		return g_pSquirrel<ScriptContext::UI>->RegisterSquirrelFunc(sqvm, funcReg, unknown);
	}

	if (g_pSquirrel<context>->m_funcOverrides.find(funcReg->squirrelFuncName) != g_pSquirrel<context>->m_funcOverrides.end())
	{
		g_pSquirrel<context>->m_funcOriginals[funcReg->squirrelFuncName] = funcReg->funcPtr;
		funcReg->funcPtr = g_pSquirrel<context>->m_funcOverrides[funcReg->squirrelFuncName];
		spdlog::info("Replacing {} in Client", std::string(funcReg->squirrelFuncName));
	}

	return g_pSquirrel<context>->RegisterSquirrelFunc(sqvm, funcReg, unknown);
}

template <ScriptContext context> bool (*__fastcall CallScriptInitCallback)(void* sqvm, const char* callback);
template <ScriptContext context> bool __fastcall CallScriptInitCallbackHook(void* sqvm, const char* callback)
{
	ScriptContext realContext = context;
	bool bShouldCallCustomCallbacks = true;

	if (context == ScriptContext::CLIENT)
	{
		if (!strcmp(callback, "UICodeCallback_UIInit"))
			realContext = ScriptContext::UI;
		else if (strcmp(callback, "ClientCodeCallback_MapSpawn"))
			bShouldCallCustomCallbacks = false;
	}
	else if (context == ScriptContext::SERVER)
		bShouldCallCustomCallbacks = !strcmp(callback, "CodeCallback_MapSpawn");

	if (bShouldCallCustomCallbacks)
	{
		for (Mod mod : g_pModManager->m_LoadedMods)
		{
			if (!mod.m_bEnabled)
				continue;

			for (ModScript script : mod.Scripts)
			{
				for (ModScriptCallback modCallback : script.Callbacks)
				{
					if (modCallback.Context == realContext && modCallback.BeforeCallback.length())
					{
						spdlog::info("Running custom {} script callback \"{}\"", GetContextName(realContext), modCallback.BeforeCallback);
						CallScriptInitCallback<context>(sqvm, modCallback.BeforeCallback.c_str());
					}
				}
			}
		}
	}

	spdlog::info("{} CodeCallback {} called", GetContextName(realContext), callback);
	if (!bShouldCallCustomCallbacks)
		spdlog::info("Not executing custom callbacks for CodeCallback {}", callback);
	bool ret = CallScriptInitCallback<context>(sqvm, callback);

	// run after callbacks
	if (bShouldCallCustomCallbacks)
	{
		for (Mod mod : g_pModManager->m_LoadedMods)
		{
			if (!mod.m_bEnabled)
				continue;

			for (ModScript script : mod.Scripts)
			{
				for (ModScriptCallback modCallback : script.Callbacks)
				{
					if (modCallback.Context == realContext && modCallback.AfterCallback.length())
					{
						spdlog::info("Running custom {} script callback \"{}\"", GetContextName(realContext), modCallback.AfterCallback);
						CallScriptInitCallback<context>(sqvm, modCallback.AfterCallback.c_str());
					}
				}
			}
		}
	}

	return ret;
}

template <ScriptContext context> void ConCommand_script(const CCommand& args)
{
	g_pSquirrel<context>->ExecuteCode(args.ArgS());
}

// literal class type that wraps a constant expression string
template <size_t N> struct TemplateStringLiteral
{
	constexpr TemplateStringLiteral(const char (&str)[N])
	{
		std::copy_n(str, N, value);
	}

	char value[N];
};

template <ScriptContext context, TemplateStringLiteral funcName> SQRESULT SQ_StubbedFunc(HSquirrelVM* sqvm)
{
	spdlog::info("Blocking call to stubbed function {} in {}", funcName.value, GetContextName(context));
	return SQRESULT_NULL;
}

template <ScriptContext context> void StubUnsafeSQFuncs()
{
	if (!Tier0::CommandLine()->CheckParm("-allowunsafesqfuncs"))
	{
		g_pSquirrel<context>->AddFuncOverride("DevTextBufferWrite", SQ_StubbedFunc<context, "DevTextBufferWrite">);
		g_pSquirrel<context>->AddFuncOverride("DevTextBufferClear", SQ_StubbedFunc<context, "DevTextBufferClear">);
		g_pSquirrel<context>->AddFuncOverride("DevTextBufferDumpToFile", SQ_StubbedFunc<context, "DevTextBufferDumpToFile">);
		g_pSquirrel<context>->AddFuncOverride("Dev_CommandLineAddParam", SQ_StubbedFunc<context, "Dev_CommandLineAddParam">);
		g_pSquirrel<context>->AddFuncOverride("DevP4Checkout", SQ_StubbedFunc<context, "DevP4Checkout">);
		g_pSquirrel<context>->AddFuncOverride("DevP4Add", SQ_StubbedFunc<context, "DevP4Add">);
	}
}

template <ScriptContext context> void SquirrelManager<context>::ProcessMessageBuffer()
{
	while (std::optional<SquirrelMessage> maybeMessage = messageBuffer->pop())
	{
		SquirrelMessage message = maybeMessage.value();

		SQObject functionobj {};
		int result = sq_getfunction(m_pSQVM->sqvm, message.functionName.c_str(), &functionobj, 0);
		if (result != 0) // This func returns 0 on success for some reason
		{
			NS::log::squirrel_logger<context>()->error(
				"ProcessMessageBuffer was unable to find function with name '{}'. Is it global?", message.functionName);
			continue;
		}

		pushobject(m_pSQVM->sqvm, &functionobj); // Push the function object
		pushroottable(m_pSQVM->sqvm);

		if (message.isExternal)
		{
			message.externalFunc(m_pSQVM->sqvm);
		}
		else
		{
			for (auto& v : message.args)
			{
				// Execute lambda to push arg to stack
				v();
			}
		}

		_call(m_pSQVM->sqvm, message.args.size());
	}
}

ADD_SQFUNC(
	"string",
	NSGetCurrentModName,
	"",
	"Returns the mod name of the script running this function",
	ScriptContext::UI | ScriptContext::CLIENT | ScriptContext::SERVER)
{
	int depth = g_pSquirrel<context>->getinteger(sqvm, 1);
	if (auto mod = g_pSquirrel<context>->getcallingmod(sqvm, depth); mod == nullptr)
	{
		g_pSquirrel<context>->raiseerror(sqvm, "NSGetModName was called from a non-mod script. This shouldn't be possible");
		return SQRESULT_ERROR;
	}
	else
	{
		g_pSquirrel<context>->pushstring(sqvm, mod->Name.c_str());
	}
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC(
	"string",
	NSGetCallingModName,
	"int depth = 0",
	"Returns the mod name of the script running this function",
	ScriptContext::UI | ScriptContext::CLIENT | ScriptContext::SERVER)
{
	int depth = g_pSquirrel<context>->getinteger(sqvm, 1);
	if (auto mod = g_pSquirrel<context>->getcallingmod(sqvm, depth); mod == nullptr)
	{
		g_pSquirrel<context>->pushstring(sqvm, "Unknown");
	}
	else
	{
		g_pSquirrel<context>->pushstring(sqvm, mod->Name.c_str());
	}
	return SQRESULT_NOTNULL;
}

ON_DLL_LOAD_RELIESON("client.dll", ClientSquirrel, ConCommand, (CModule module))
{
	AUTOHOOK_DISPATCH_MODULE(client.dll)

	g_pSquirrel<ScriptContext::CLIENT>->__sq_defconst = module.Offset(0x12120).As<sq_defconstType>();
	g_pSquirrel<ScriptContext::UI>->__sq_defconst = g_pSquirrel<ScriptContext::CLIENT>->__sq_defconst;

	g_pSquirrel<ScriptContext::CLIENT>->__sq_compilebuffer = module.Offset(0x3110).As<sq_compilebufferType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_pushroottable = module.Offset(0x5860).As<sq_pushroottableType>();
	g_pSquirrel<ScriptContext::UI>->__sq_compilebuffer = g_pSquirrel<ScriptContext::CLIENT>->__sq_compilebuffer;
	g_pSquirrel<ScriptContext::UI>->__sq_pushroottable = g_pSquirrel<ScriptContext::CLIENT>->__sq_pushroottable;

	g_pSquirrel<ScriptContext::CLIENT>->__sq_call = module.Offset(0x8650).As<sq_callType>();
	g_pSquirrel<ScriptContext::UI>->__sq_call = g_pSquirrel<ScriptContext::CLIENT>->__sq_call;

	g_pSquirrel<ScriptContext::CLIENT>->__sq_newarray = module.Offset(0x39F0).As<sq_newarrayType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_arrayappend = module.Offset(0x3C70).As<sq_arrayappendType>();
	g_pSquirrel<ScriptContext::UI>->__sq_newarray = g_pSquirrel<ScriptContext::CLIENT>->__sq_newarray;
	g_pSquirrel<ScriptContext::UI>->__sq_arrayappend = g_pSquirrel<ScriptContext::CLIENT>->__sq_arrayappend;

	g_pSquirrel<ScriptContext::CLIENT>->__sq_newtable = module.Offset(0x3960).As<sq_newtableType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_newslot = module.Offset(0x70B0).As<sq_newslotType>();
	g_pSquirrel<ScriptContext::UI>->__sq_newtable = g_pSquirrel<ScriptContext::CLIENT>->__sq_newtable;
	g_pSquirrel<ScriptContext::UI>->__sq_newslot = g_pSquirrel<ScriptContext::CLIENT>->__sq_newslot;

	g_pSquirrel<ScriptContext::CLIENT>->__sq_pushstring = module.Offset(0x3440).As<sq_pushstringType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_pushinteger = module.Offset(0x36A0).As<sq_pushintegerType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_pushfloat = module.Offset(0x3800).As<sq_pushfloatType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_pushbool = module.Offset(0x3710).As<sq_pushboolType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_pushasset = module.Offset(0x3560).As<sq_pushassetType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_pushvector = module.Offset(0x3780).As<sq_pushvectorType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_pushobject = module.Offset(0x83D0).As<sq_pushobjectType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_raiseerror = module.Offset(0x8470).As<sq_raiseerrorType>();
	g_pSquirrel<ScriptContext::UI>->__sq_pushstring = g_pSquirrel<ScriptContext::CLIENT>->__sq_pushstring;
	g_pSquirrel<ScriptContext::UI>->__sq_pushinteger = g_pSquirrel<ScriptContext::CLIENT>->__sq_pushinteger;
	g_pSquirrel<ScriptContext::UI>->__sq_pushfloat = g_pSquirrel<ScriptContext::CLIENT>->__sq_pushfloat;
	g_pSquirrel<ScriptContext::UI>->__sq_pushbool = g_pSquirrel<ScriptContext::CLIENT>->__sq_pushbool;
	g_pSquirrel<ScriptContext::UI>->__sq_pushvector = g_pSquirrel<ScriptContext::CLIENT>->__sq_pushvector;
	g_pSquirrel<ScriptContext::UI>->__sq_pushasset = g_pSquirrel<ScriptContext::CLIENT>->__sq_pushasset;
	g_pSquirrel<ScriptContext::UI>->__sq_pushobject = g_pSquirrel<ScriptContext::CLIENT>->__sq_pushobject;
	g_pSquirrel<ScriptContext::UI>->__sq_raiseerror = g_pSquirrel<ScriptContext::CLIENT>->__sq_raiseerror;

	g_pSquirrel<ScriptContext::CLIENT>->__sq_getstring = module.Offset(0x60C0).As<sq_getstringType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_getinteger = module.Offset(0x60E0).As<sq_getintegerType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_getfloat = module.Offset(0x6100).As<sq_getfloatType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_getbool = module.Offset(0x6130).As<sq_getboolType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_get = module.Offset(0x7C30).As<sq_getType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_getasset = module.Offset(0x6010).As<sq_getassetType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_getuserdata = module.Offset(0x63D0).As<sq_getuserdataType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_getvector = module.Offset(0x6140).As<sq_getvectorType>();
	g_pSquirrel<ScriptContext::UI>->__sq_getstring = g_pSquirrel<ScriptContext::CLIENT>->__sq_getstring;
	g_pSquirrel<ScriptContext::UI>->__sq_getinteger = g_pSquirrel<ScriptContext::CLIENT>->__sq_getinteger;
	g_pSquirrel<ScriptContext::UI>->__sq_getfloat = g_pSquirrel<ScriptContext::CLIENT>->__sq_getfloat;
	g_pSquirrel<ScriptContext::UI>->__sq_getbool = g_pSquirrel<ScriptContext::CLIENT>->__sq_getbool;
	g_pSquirrel<ScriptContext::UI>->__sq_get = g_pSquirrel<ScriptContext::CLIENT>->__sq_get;
	g_pSquirrel<ScriptContext::UI>->__sq_getasset = g_pSquirrel<ScriptContext::CLIENT>->__sq_getasset;
	g_pSquirrel<ScriptContext::UI>->__sq_getuserdata = g_pSquirrel<ScriptContext::CLIENT>->__sq_getuserdata;
	g_pSquirrel<ScriptContext::UI>->__sq_getvector = g_pSquirrel<ScriptContext::CLIENT>->__sq_getvector;
	g_pSquirrel<ScriptContext::UI>->__sq_getthisentity = g_pSquirrel<ScriptContext::CLIENT>->__sq_getthisentity;
	g_pSquirrel<ScriptContext::UI>->__sq_getobject = g_pSquirrel<ScriptContext::CLIENT>->__sq_getobject;

	g_pSquirrel<ScriptContext::CLIENT>->__sq_createuserdata = module.Offset(0x38D0).As<sq_createuserdataType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_setuserdatatypeid = module.Offset(0x6490).As<sq_setuserdatatypeidType>();
	g_pSquirrel<ScriptContext::UI>->__sq_createuserdata = g_pSquirrel<ScriptContext::CLIENT>->__sq_createuserdata;
	g_pSquirrel<ScriptContext::UI>->__sq_setuserdatatypeid = g_pSquirrel<ScriptContext::CLIENT>->__sq_setuserdatatypeid;

	g_pSquirrel<ScriptContext::CLIENT>->__sq_GetEntityConstant_CBaseEntity = module.Offset(0x3E49B0).As<sq_GetEntityConstantType>();
	g_pSquirrel<ScriptContext::CLIENT>->__sq_getentityfrominstance = module.Offset(0x114F0).As<sq_getentityfrominstanceType>();
	g_pSquirrel<ScriptContext::UI>->__sq_GetEntityConstant_CBaseEntity =
		g_pSquirrel<ScriptContext::CLIENT>->__sq_GetEntityConstant_CBaseEntity;
	g_pSquirrel<ScriptContext::UI>->__sq_getentityfrominstance = g_pSquirrel<ScriptContext::CLIENT>->__sq_getentityfrominstance;

	// Message buffer stuff
	g_pSquirrel<ScriptContext::UI>->messageBuffer = g_pSquirrel<ScriptContext::CLIENT>->messageBuffer;
	g_pSquirrel<ScriptContext::CLIENT>->__sq_getfunction = module.Offset(0x572FB0).As<sq_getfunctionType>();
	g_pSquirrel<ScriptContext::UI>->__sq_getfunction = g_pSquirrel<ScriptContext::CLIENT>->__sq_getfunction;
	g_pSquirrel<ScriptContext::CLIENT>->__sq_stackinfos = module.Offset(0x35970).As<sq_stackinfosType>();
	g_pSquirrel<ScriptContext::UI>->__sq_stackinfos = g_pSquirrel<ScriptContext::CLIENT>->__sq_stackinfos;

	MAKEHOOK(
		module.Offset(0x108E0),
		&RegisterSquirrelFunctionHook<ScriptContext::CLIENT>,
		&g_pSquirrel<ScriptContext::CLIENT>->RegisterSquirrelFunc);
	g_pSquirrel<ScriptContext::UI>->RegisterSquirrelFunc = g_pSquirrel<ScriptContext::CLIENT>->RegisterSquirrelFunc;

	g_pSquirrel<ScriptContext::CLIENT>->logger = NS::log::SCRIPT_CL;
	g_pSquirrel<ScriptContext::UI>->logger = NS::log::SCRIPT_UI;

	// uiscript_reset concommand: don't loop forever if compilation fails
	module.Offset(0x3C6E4C).NOP(6);

	MAKEHOOK(module.Offset(0x8AD0), &sq_compiler_createHook<ScriptContext::CLIENT>, &sq_compiler_create<ScriptContext::CLIENT>);

	MAKEHOOK(module.Offset(0x12B00), &SQPrintHook<ScriptContext::CLIENT>, &SQPrint<ScriptContext::CLIENT>);
	MAKEHOOK(module.Offset(0x12BA0), &SQPrintHook<ScriptContext::UI>, &SQPrint<ScriptContext::UI>);

	MAKEHOOK(module.Offset(0x26130), &CreateNewVMHook<ScriptContext::CLIENT>, &CreateNewVM<ScriptContext::CLIENT>);
	MAKEHOOK(module.Offset(0x26E70), &DestroyVMHook<ScriptContext::CLIENT>, &DestroyVM<ScriptContext::CLIENT>);
	MAKEHOOK(module.Offset(0x79A50), &ScriptCompileErrorHook<ScriptContext::CLIENT>, &SQCompileError<ScriptContext::CLIENT>);

	MAKEHOOK(module.Offset(0x10190), &CallScriptInitCallbackHook<ScriptContext::CLIENT>, &CallScriptInitCallback<ScriptContext::CLIENT>);

	RegisterConCommand("script_client", ConCommand_script<ScriptContext::CLIENT>, "Executes script code on the client vm", FCVAR_CLIENTDLL);
	RegisterConCommand("script_ui", ConCommand_script<ScriptContext::UI>, "Executes script code on the ui vm", FCVAR_CLIENTDLL);

	StubUnsafeSQFuncs<ScriptContext::CLIENT>();
	StubUnsafeSQFuncs<ScriptContext::UI>();

	g_pSquirrel<ScriptContext::CLIENT>->__sq_getfunction = module.Offset(0x6CB0).As<sq_getfunctionType>();
	g_pSquirrel<ScriptContext::UI>->__sq_getfunction = g_pSquirrel<ScriptContext::CLIENT>->__sq_getfunction;
}

ON_DLL_LOAD_RELIESON("server.dll", ServerSquirrel, ConCommand, (CModule module))
{
	AUTOHOOK_DISPATCH_MODULE(server.dll)

	g_pSquirrel<ScriptContext::SERVER>->__sq_defconst = module.Offset(0x1F550).As<sq_defconstType>();

	g_pSquirrel<ScriptContext::SERVER>->__sq_compilebuffer = module.Offset(0x3110).As<sq_compilebufferType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_pushroottable = module.Offset(0x5840).As<sq_pushroottableType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_call = module.Offset(0x8620).As<sq_callType>();

	g_pSquirrel<ScriptContext::SERVER>->__sq_newarray = module.Offset(0x39F0).As<sq_newarrayType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_arrayappend = module.Offset(0x3C70).As<sq_arrayappendType>();

	g_pSquirrel<ScriptContext::SERVER>->__sq_newtable = module.Offset(0x3960).As<sq_newtableType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_newslot = module.Offset(0x7080).As<sq_newslotType>();

	g_pSquirrel<ScriptContext::SERVER>->__sq_pushstring = module.Offset(0x3440).As<sq_pushstringType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_pushinteger = module.Offset(0x36A0).As<sq_pushintegerType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_pushfloat = module.Offset(0x3800).As<sq_pushfloatType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_pushbool = module.Offset(0x3710).As<sq_pushboolType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_pushasset = module.Offset(0x3560).As<sq_pushassetType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_pushvector = module.Offset(0x3780).As<sq_pushvectorType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_pushobject = module.Offset(0x83A0).As<sq_pushobjectType>();

	g_pSquirrel<ScriptContext::SERVER>->__sq_raiseerror = module.Offset(0x8440).As<sq_raiseerrorType>();

	g_pSquirrel<ScriptContext::SERVER>->__sq_getstring = module.Offset(0x60A0).As<sq_getstringType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_getinteger = module.Offset(0x60C0).As<sq_getintegerType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_getfloat = module.Offset(0x60E0).As<sq_getfloatType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_getbool = module.Offset(0x6110).As<sq_getboolType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_getasset = module.Offset(0x5FF0).As<sq_getassetType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_getuserdata = module.Offset(0x63B0).As<sq_getuserdataType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_getvector = module.Offset(0x6120).As<sq_getvectorType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_get = module.Offset(0x7C00).As<sq_getType>();

	g_pSquirrel<ScriptContext::SERVER>->__sq_getthisentity = module.Offset(0x203B0).As<sq_getthisentityType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_getobject = module.Offset(0x6140).As<sq_getobjectType>();

	g_pSquirrel<ScriptContext::SERVER>->__sq_createuserdata = module.Offset(0x38D0).As<sq_createuserdataType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_setuserdatatypeid = module.Offset(0x6470).As<sq_setuserdatatypeidType>();

	g_pSquirrel<ScriptContext::SERVER>->__sq_GetEntityConstant_CBaseEntity = module.Offset(0x418AF0).As<sq_GetEntityConstantType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_getentityfrominstance = module.Offset(0x1E920).As<sq_getentityfrominstanceType>();

	g_pSquirrel<ScriptContext::SERVER>->logger = NS::log::SCRIPT_SV;
	// Message buffer stuff
	g_pSquirrel<ScriptContext::SERVER>->__sq_getfunction = module.Offset(0x6C85).As<sq_getfunctionType>();
	g_pSquirrel<ScriptContext::SERVER>->__sq_stackinfos = module.Offset(0x35920).As<sq_stackinfosType>();

	MAKEHOOK(
		module.Offset(0x1DD10),
		&RegisterSquirrelFunctionHook<ScriptContext::SERVER>,
		&g_pSquirrel<ScriptContext::SERVER>->RegisterSquirrelFunc);

	MAKEHOOK(module.Offset(0x8AA0), &sq_compiler_createHook<ScriptContext::SERVER>, &sq_compiler_create<ScriptContext::SERVER>);

	MAKEHOOK(module.Offset(0x1FE90), &SQPrintHook<ScriptContext::SERVER>, &SQPrint<ScriptContext::SERVER>);
	MAKEHOOK(module.Offset(0x260E0), &CreateNewVMHook<ScriptContext::SERVER>, &CreateNewVM<ScriptContext::SERVER>);
	MAKEHOOK(module.Offset(0x26E20), &DestroyVMHook<ScriptContext::SERVER>, &DestroyVM<ScriptContext::SERVER>);
	MAKEHOOK(module.Offset(0x799E0), &ScriptCompileErrorHook<ScriptContext::SERVER>, &SQCompileError<ScriptContext::SERVER>);
	MAKEHOOK(module.Offset(0x1D5C0), &CallScriptInitCallbackHook<ScriptContext::SERVER>, &CallScriptInitCallback<ScriptContext::SERVER>);

	// FCVAR_CHEAT and FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS allows clients to execute this, but since it's unsafe we only allow it when cheats
	// are enabled for script_client and script_ui, we don't use cheats, so clients can execute them on themselves all they want
	RegisterConCommand(
		"script",
		ConCommand_script<ScriptContext::SERVER>,
		"Executes script code on the server vm",
		FCVAR_GAMEDLL | FCVAR_GAMEDLL_FOR_REMOTE_CLIENTS | FCVAR_CHEAT);

	StubUnsafeSQFuncs<ScriptContext::SERVER>();
}

void InitialiseSquirrelManagers()
{
	g_pSquirrel<ScriptContext::CLIENT> = new SquirrelManager<ScriptContext::CLIENT>;
	g_pSquirrel<ScriptContext::UI> = new SquirrelManager<ScriptContext::UI>;
	g_pSquirrel<ScriptContext::SERVER> = new SquirrelManager<ScriptContext::SERVER>;
}
