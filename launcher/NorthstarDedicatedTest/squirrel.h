#pragma once

void InitialiseClientSquirrel(HMODULE baseAddress);
void InitialiseServerSquirrel(HMODULE baseAddress);

// stolen from ttf2sdk: sqvm types
typedef float SQFloat;
typedef long SQInteger;
typedef unsigned long SQUnsignedInteger;
typedef char SQChar;

typedef SQUnsignedInteger SQBool;
typedef SQInteger SQRESULT;

struct CompileBufferState
{
	const SQChar* buffer;
	const SQChar* bufferPlusLength;
	const SQChar* bufferAgain;

	CompileBufferState(const std::string& code)
	{
		buffer = code.c_str();
		bufferPlusLength = code.c_str() + code.size();
		bufferAgain = code.c_str();
	}
};

typedef SQRESULT(*sq_compilebufferType)(void* sqvm, CompileBufferState* compileBuffer, const char* file, int a1, int a2);
extern sq_compilebufferType ClientSq_compilebuffer;
extern sq_compilebufferType ServerSq_compilebuffer;

typedef void(*sq_pushroottableType)(void* sqvm);
extern sq_pushroottableType ClientSq_pushroottable;
extern sq_pushroottableType ServerSq_pushroottable;

typedef SQRESULT(*sq_callType)(void* sqvm, SQInteger s1, SQBool a2, SQBool a3);
extern sq_callType ClientSq_call;
extern sq_callType ServerSq_call;

//template<Context context> void ExecuteSQCode(SquirrelManager<context> sqManager, const char* code); // need this because we can't do template class functions in the .cpp file

typedef SQInteger(*SQFunction)(void* sqvm);

template<Context context> class SquirrelManager
{
public:
	void* sqvm;

public:
	SquirrelManager() : sqvm(nullptr)
	{}

	void VMCreated(void* sqvm)
	{
		sqvm = sqvm;
	}

	void VMDestroyed()
	{
		sqvm = nullptr;
	}

	void ExecuteCode(const char* code)
	{
		// ttf2sdk checks ThreadIsInMainThread here, might be good to do that? doesn't seem like an issue rn tho

		if (!sqvm)
		{
			spdlog::error("Cannot execute code, {} squirrel vm is not initialised", GetContextName(context));
			return;
		}

		void* sqvm2 = *((void**)((char*)sqvm + 8)); // honestly not 100% sure on what this is, but it seems to be what this function is supposed to take
		// potentially move to a property later if it's used alot

		spdlog::info("Executing {} script code {} ", GetContextName(context), code);

		std::string strCode(code);
		CompileBufferState bufferState = CompileBufferState(strCode);

		SQRESULT compileResult;
		if (context == CLIENT || context == UI)
			compileResult = ClientSq_compilebuffer(sqvm2, &bufferState, "console", -1, context);
		else if (context == SERVER)
			compileResult = ServerSq_compilebuffer(sqvm2, &bufferState, "console", -1, context);

		spdlog::info("sq_compilebuffer returned {}", compileResult);
		if (compileResult >= 0)
		{
			if (context == CLIENT || context == UI)
			{
				ClientSq_pushroottable(sqvm2);
				SQRESULT callResult = ClientSq_call(sqvm2, 1, false, false);
				spdlog::info("sq_call returned {}", callResult);
			}
			else if (context == SERVER)
			{
				ServerSq_pushroottable(sqvm2);
				SQRESULT callResult = ServerSq_call(sqvm2, 1, false, false);
				spdlog::info("sq_call returned {}", callResult);
			}
		}
	}

	void AddFuncRegistration(std::string returnType, std::string name, std::string argTypes, std::string helpText, SQFunction func)
	{
		
	}
};

extern SquirrelManager<CLIENT>* g_ClientSquirrelManager;
extern SquirrelManager<SERVER>* g_ServerSquirrelManager;
extern SquirrelManager<UI>* g_UISquirrelManager;