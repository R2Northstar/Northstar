#pragma once

#include "vscript/vscript.h"

#include <queue>

const std::map<SQRESULT, const char*> PrintSQRESULT = {
	{SQRESULT::SQRESULT_ERROR, "SQRESULT_ERROR"},
	{SQRESULT::SQRESULT_NULL, "SQRESULT_NULL"},
	{SQRESULT::SQRESULT_NOTNULL, "SQRESULT_NOTNULL"}};

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

class SquirrelMessage
{
public:
	std::string functionName;
	FunctionVector args;
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
	SquirrelAsset(std::string path)
		: path(path) {};
};

#pragma region TypeDefs

// core sqvm funcs
typedef int64_t (*RegisterSquirrelFuncType)(CSquirrelVM* sqvm, SQFuncRegistration* funcReg, char unknown);
typedef void (*sq_defconstType)(CSquirrelVM* sqvm, const SQChar* name, int value);

typedef SQRESULT (*sq_compilebufferType)(
	HSQUIRRELVM sqvm, SQBufferState* compileBuffer, const char* file, int a1, SQBool bShouldThrowError);
typedef SQRESULT (*sq_callType)(HSQUIRRELVM sqvm, SQInteger iArgs, SQBool bShouldReturn, SQBool bThrowError);
typedef SQInteger (*sq_raiseerrorType)(HSQUIRRELVM sqvm, const SQChar* pError);
typedef bool (*sq_compilefileType)(CSquirrelVM* sqvm, const char* path, const char* name, int a4);

// sq stack array funcs
typedef void (*sq_newarrayType)(HSQUIRRELVM sqvm, SQInteger iStackpos);
typedef SQRESULT (*sq_arrayappendType)(HSQUIRRELVM sqvm, SQInteger iStackpos);

// sq table funcs
typedef SQRESULT (*sq_newtableType)(HSQUIRRELVM sqvm);
typedef SQRESULT (*sq_newslotType)(HSQUIRRELVM sqvm, SQInteger idx, SQBool bStatic);

// sq stack push funcs
typedef void (*sq_pushroottableType)(HSQUIRRELVM sqvm);
typedef void (*sq_pushstringType)(HSQUIRRELVM sqvm, const SQChar* pStr, SQInteger iLength);
typedef void (*sq_pushintegerType)(HSQUIRRELVM sqvm, SQInteger i);
typedef void (*sq_pushfloatType)(HSQUIRRELVM sqvm, SQFloat f);
typedef void (*sq_pushboolType)(HSQUIRRELVM sqvm, SQBool b);
typedef void (*sq_pushassetType)(HSQUIRRELVM sqvm, const SQChar* str, SQInteger iLength);
typedef void (*sq_pushvectorType)(HSQUIRRELVM sqvm, const SQFloat* pVec);
typedef void (*sq_pushobjectType)(HSQUIRRELVM sqvm, SQObject* pVec);

// sq stack get funcs
typedef const SQChar* (*sq_getstringType)(HSQUIRRELVM sqvm, SQInteger iStackpos);
typedef SQInteger (*sq_getintegerType)(HSQUIRRELVM sqvm, SQInteger iStackpos);
typedef SQFloat (*sq_getfloatType)(HSQUIRRELVM, SQInteger iStackpos);
typedef SQBool (*sq_getboolType)(HSQUIRRELVM, SQInteger iStackpos);
typedef SQRESULT (*sq_getType)(HSQUIRRELVM sqvm, SQInteger iStackpos);
typedef SQRESULT (*sq_getassetType)(HSQUIRRELVM sqvm, SQInteger iStackpos, const char** pResult);
typedef SQRESULT (*sq_getuserdataType)(HSQUIRRELVM sqvm, SQInteger iStackpos, void** pData, uint64_t* pTypeId);
typedef SQFloat* (*sq_getvectorType)(HSQUIRRELVM sqvm, SQInteger iStackpos);
typedef SQBool (*sq_getthisentityType)(HSQUIRRELVM, void** ppEntity);
typedef void (*sq_getobjectType)(HSQUIRRELVM, SQInteger iStackPos, SQObject* pOutObj);

typedef long long (*sq_stackinfosType)(HSQUIRRELVM sqvm, int iLevel, SQStackInfos* pOutObj, int iCallStackSize);

// sq stack userpointer funcs
typedef void* (*sq_createuserdataType)(HSQUIRRELVM sqvm, SQInteger iSize);
typedef SQRESULT (*sq_setuserdatatypeidType)(HSQUIRRELVM sqvm, SQInteger iStackpos, uint64_t iTypeId);

// sq misc entity funcs
typedef void* (*sq_getentityfrominstanceType)(CSquirrelVM* sqvm, SQObject* pInstance, char** ppEntityConstant);
typedef SQObject* (*sq_createscriptinstanceType)(void* ent);
typedef char** (*sq_GetEntityConstantType)();

typedef int (*sq_getfunctionType)(HSQUIRRELVM sqvm, const char* name, SQObject* returnObj, const char* signature);

// structs
typedef SQRESULT (*sq_pushnewstructinstanceType)(HSQUIRRELVM sqvm, int fieldCount);
typedef SQRESULT (*sq_sealstructslotType)(HSQUIRRELVM sqvm, int slotIndex);

#pragma endregion
