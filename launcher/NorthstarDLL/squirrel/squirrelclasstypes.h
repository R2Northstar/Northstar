#pragma once
#include "pch.h"
#include "squirreldatatypes.h"

#include <queue>

enum SQRESULT : SQInteger
{
	SQRESULT_ERROR = -1,
	SQRESULT_NULL = 0,
	SQRESULT_NOTNULL = 1,
};

typedef SQRESULT (*SQFunction)(HSquirrelVM* sqvm);

enum class eSQReturnType
{
	Float = 0x1,
	Vector = 0x3,
	Integer = 0x5,
	Boolean = 0x6,
	Entity = 0xD,
	String = 0x21,
	Default = 0x20,
	Arrays = 0x25,
	Asset = 0x28,
	Table = 0x26,
};

const std::map<SQRESULT, const char*> PrintSQRESULT = {
	{SQRESULT::SQRESULT_ERROR, "SQRESULT_ERROR"},
	{SQRESULT::SQRESULT_NULL, "SQRESULT_NULL"},
	{SQRESULT::SQRESULT_NOTNULL, "SQRESULT_NOTNULL"}};

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

struct SQFuncRegistration
{
	const char* squirrelFuncName;
	const char* cppFuncName;
	const char* helpText;
	const char* returnTypeString;
	const char* argTypes;
	uint32_t unknown1;
	uint32_t devLevel;
	const char* shortNameMaybe;
	uint32_t unknown2;
	eSQReturnType returnType;
	uint32_t* externalBufferPointer;
	uint64_t externalBufferSize;
	uint64_t unknown3;
	uint64_t unknown4;
	SQFunction funcPtr;

	SQFuncRegistration()
	{
		memset(this, 0, sizeof(SQFuncRegistration));
		this->returnType = eSQReturnType::Default;
	}
};

enum class ScriptContext : int
{
	INVALID = -1,
	SERVER,
	CLIENT,
	UI,
};

typedef std::vector<std::function<void()>> FunctionVector;
typedef std::function<void()> VoidFunction;

// clang-format off
template <typename T>
concept is_map =
	// Simple maps
	std::same_as<T, std::map<typename T::key_type, typename T::mapped_type, typename T::key_compare, typename T::allocator_type>> ||
	std::same_as<T, std::unordered_map<typename T::key_type, typename T::mapped_type, typename T::hasher, typename T::key_equal, typename T::allocator_type>> ||

	// Nested maps
	std::same_as <
		std::map<typename T::key_type, typename T::mapped_type, typename T::key_compare, typename T::allocator_type>,
		std::map<typename T::key_type, typename T::mapped_type, typename T::key_compare, typename T::allocator_type>
	> ||
	std::same_as <
		std::unordered_map<typename T::key_type, typename T::mapped_type, typename T::key_compare, typename T::allocator_type>,
		std::unordered_map<typename T::key_type, typename T::mapped_type, typename T::key_compare, typename T::allocator_type>
	> ||
	std::same_as <
		std::unordered_map<typename T::key_type, typename T::mapped_type, typename T::key_compare, typename T::allocator_type>,
		std::map<typename T::key_type, typename T::mapped_type, typename T::key_compare, typename T::allocator_type>
	> ||
	std::same_as <
		std::map<typename T::key_type, typename T::mapped_type, typename T::key_compare, typename T::allocator_type>,
		std::unordered_map<typename T::key_type, typename T::mapped_type, typename T::key_compare, typename T::allocator_type>
	>
;

template<typename T>
concept is_iterable = requires(std::ranges::range_value_t<T> x)
{
    x.begin();          // must have `x.begin()`
    x.end();            // and `x.end()`
};

// clang-format on

typedef void (*SquirrelMessage_External_Pop)(HSquirrelVM* sqvm);
typedef void (*sq_schedule_call_externalType)(ScriptContext context, const char* funcname, SquirrelMessage_External_Pop function);

class SquirrelMessage
{
  public:
	std::string functionName;
	FunctionVector args;
	bool isExternal = false;
	SquirrelMessage_External_Pop externalFunc = NULL;
};

class SquirrelMessageBuffer
{

  private:
	std::queue<SquirrelMessage> messages = {};

  public:
	std::mutex mutex;
	std::optional<SquirrelMessage> pop()
	{
		std::lock_guard<std::mutex> guard(mutex);
		if (!messages.empty())
		{
			auto message = messages.front();
			messages.pop();
			return message;
		}
		else
		{
			return std::nullopt;
		}
	}

	void unwind()
	{
		auto maybeMessage = this->pop();
		if (!maybeMessage)
		{
			spdlog::error("Plugin tried consuming SquirrelMessage while buffer was empty");
			return;
		}
		auto message = maybeMessage.value();
		for (auto& v : message.args)
		{
			// Execute lambda to push arg to stack
			v();
		}
	}

	void push(SquirrelMessage message)
	{
		std::lock_guard<std::mutex> guard(mutex);
		messages.push(message);
	}
};

// Super simple wrapper class to allow pushing Assets via call
class SquirrelAsset
{
  public:
	std::string path;
	SquirrelAsset(std::string path) : path(path) {};
};

#pragma region TypeDefs

// core sqvm funcs
typedef int64_t (*RegisterSquirrelFuncType)(CSquirrelVM* sqvm, SQFuncRegistration* funcReg, char unknown);
typedef void (*sq_defconstType)(CSquirrelVM* sqvm, const SQChar* name, int value);

typedef SQRESULT (*sq_compilebufferType)(
	HSquirrelVM* sqvm, CompileBufferState* compileBuffer, const char* file, int a1, SQBool bShouldThrowError);
typedef SQRESULT (*sq_callType)(HSquirrelVM* sqvm, SQInteger iArgs, SQBool bShouldReturn, SQBool bThrowError);
typedef SQInteger (*sq_raiseerrorType)(HSquirrelVM* sqvm, const SQChar* pError);

// sq stack array funcs
typedef void (*sq_newarrayType)(HSquirrelVM* sqvm, SQInteger iStackpos);
typedef SQRESULT (*sq_arrayappendType)(HSquirrelVM* sqvm, SQInteger iStackpos);

// sq table funcs
typedef SQRESULT (*sq_newtableType)(HSquirrelVM* sqvm);
typedef SQRESULT (*sq_newslotType)(HSquirrelVM* sqvm, SQInteger idx, SQBool bStatic);

// sq stack push funcs
typedef void (*sq_pushroottableType)(HSquirrelVM* sqvm);
typedef void (*sq_pushstringType)(HSquirrelVM* sqvm, const SQChar* pStr, SQInteger iLength);
typedef void (*sq_pushintegerType)(HSquirrelVM* sqvm, SQInteger i);
typedef void (*sq_pushfloatType)(HSquirrelVM* sqvm, SQFloat f);
typedef void (*sq_pushboolType)(HSquirrelVM* sqvm, SQBool b);
typedef void (*sq_pushassetType)(HSquirrelVM* sqvm, const SQChar* str, SQInteger iLength);
typedef void (*sq_pushvectorType)(HSquirrelVM* sqvm, const SQFloat* pVec);
typedef void (*sq_pushobjectType)(HSquirrelVM* sqvm, SQObject* pVec);

// sq stack get funcs
typedef const SQChar* (*sq_getstringType)(HSquirrelVM* sqvm, SQInteger iStackpos);
typedef SQInteger (*sq_getintegerType)(HSquirrelVM* sqvm, SQInteger iStackpos);
typedef SQFloat (*sq_getfloatType)(HSquirrelVM*, SQInteger iStackpos);
typedef SQBool (*sq_getboolType)(HSquirrelVM*, SQInteger iStackpos);
typedef SQRESULT (*sq_getType)(HSquirrelVM* sqvm, SQInteger iStackpos);
typedef SQRESULT (*sq_getassetType)(HSquirrelVM* sqvm, SQInteger iStackpos, const char** pResult);
typedef SQRESULT (*sq_getuserdataType)(HSquirrelVM* sqvm, SQInteger iStackpos, void** pData, uint64_t* pTypeId);
typedef SQFloat* (*sq_getvectorType)(HSquirrelVM* sqvm, SQInteger iStackpos);
typedef SQBool (*sq_getthisentityType)(HSquirrelVM*, void** ppEntity);
typedef void (*sq_getobjectType)(HSquirrelVM*, SQInteger iStackPos, SQObject* pOutObj);

typedef long long (*sq_stackinfosType)(HSquirrelVM* sqvm, int iLevel, SQStackInfos* pOutObj, int iCallStackSize);

// sq stack userpointer funcs
typedef void* (*sq_createuserdataType)(HSquirrelVM* sqvm, SQInteger iSize);
typedef SQRESULT (*sq_setuserdatatypeidType)(HSquirrelVM* sqvm, SQInteger iStackpos, uint64_t iTypeId);

// sq misc entity funcs
typedef void* (*sq_getentityfrominstanceType)(CSquirrelVM* sqvm, SQObject* pInstance, char** ppEntityConstant);
typedef char** (*sq_GetEntityConstantType)();

typedef int (*sq_getfunctionType)(HSquirrelVM* sqvm, const char* name, SQObject* returnObj, const char* signature);

#pragma endregion

// These "external" versions of the types are for plugins
typedef int64_t (*RegisterSquirrelFuncType_External)(ScriptContext context, SQFuncRegistration* funcReg, char unknown);
