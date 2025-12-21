#pragma once

#include "squirrelclasstypes.h"
#include "squirrelautobind.h"
#include "core/math/vector.h"
#include "mods/modmanager.h"
#include <vscript/languages/squirrel_re/vsquirrel.h>

namespace fs = std::filesystem;

/*
	definitions from hell
	required to function
*/

template <typename T> inline void SqRecurseArgs(FunctionVector& v, T& arg);

template <typename T, typename... Args> inline void SqRecurseArgs(FunctionVector& v, T& arg, Args... args);

/*
	sanity below
*/

// stolen from ttf2sdk: sqvm types
typedef float SQFloat;
typedef long SQInteger;
typedef unsigned long SQUnsignedInteger;
typedef char SQChar;
typedef SQUnsignedInteger SQBool;

static constexpr int operator&(ScriptContext first, ScriptContext second)
{
	return first == second;
}

static constexpr int operator&(int first, ScriptContext second)
{
	return first & (1 << static_cast<int>(second));
}

static constexpr int operator|(ScriptContext first, ScriptContext second)
{
	return (1 << static_cast<int>(first)) + (1 << static_cast<int>(second));
}

static constexpr int operator|(int first, ScriptContext second)
{
	return first + (1 << static_cast<int>(second));
}

const char* GetContextName(ScriptContext context);
const char* GetContextName_Short(ScriptContext context);
eSQReturnType SQReturnTypeFromString(const char* pReturnType);
const char* SQTypeNameFromID(const int iTypeId);

ScriptContext ScriptContextFromString(std::string string);

namespace NS::log
{
	std::shared_ptr<spdlog::logger> squirrel_logger(ScriptContext context);
}; // namespace NS::log

class SquirrelManager
{
protected:
	std::vector<SQFuncRegistration*> m_funcRegistrations;

public:
	ScriptContext m_context;
	std::shared_ptr<spdlog::logger> m_logger;
	CSquirrelVM* m_pSQVM;
	std::map<std::string, SQFunction> m_funcOverrides = {};
	std::map<std::string, SQFunction> m_funcOriginals = {};

	bool m_bFatalCompilationErrors = false;

public:
	SquirrelManager(ScriptContext context)
	{
		m_pSQVM = nullptr;
		m_context = context;
		m_logger = NS::log::squirrel_logger(m_context);
	}

	void VMCreated(CSquirrelVM* newSqvm);
	void VMDestroyed();
	void ExecuteCode(const char* code);
	void AddFuncRegistration(std::string returnType, std::string name, std::string argTypes, std::string helpText, SQFunction func);
	SQRESULT setupfunc(const SQChar* funcname);
	void AddFuncOverride(std::string name, SQFunction func);
	void ProcessMessageBuffer();

#pragma region SQVM funcs
	RegisterSquirrelFuncType RegisterSquirrelFunc;
	sq_defconstType __sq_defconst;

	sq_compilebufferType __sq_compilebuffer;
	sq_callType __sq_call;
	sq_raiseerrorType __sq_raiseerror;
	sq_compilefileType __sq_compilefile;

	sq_newarrayType __sq_newarray;
	sq_arrayappendType __sq_arrayappend;

	sq_newtableType __sq_newtable;
	sq_newslotType __sq_newslot;

	sq_pushroottableType __sq_pushroottable;
	sq_pushstringType __sq_pushstring;
	sq_pushintegerType __sq_pushinteger;
	sq_pushfloatType __sq_pushfloat;
	sq_pushboolType __sq_pushbool;
	sq_pushassetType __sq_pushasset;
	sq_pushvectorType __sq_pushvector;
	sq_pushobjectType __sq_pushobject;

	sq_getstringType __sq_getstring;
	sq_getintegerType __sq_getinteger;
	sq_getfloatType __sq_getfloat;
	sq_getboolType __sq_getbool;
	sq_getType __sq_get;
	sq_getassetType __sq_getasset;
	sq_getuserdataType __sq_getuserdata;
	sq_getvectorType __sq_getvector;
	sq_getthisentityType __sq_getthisentity;
	sq_getobjectType __sq_getobject;

	sq_stackinfosType __sq_stackinfos;

	sq_createuserdataType __sq_createuserdata;
	sq_setuserdatatypeidType __sq_setuserdatatypeid;
	sq_getfunctionType __sq_getfunction;

	sq_getentityfrominstanceType __sq_getentityfrominstance;
	sq_createscriptinstanceType __sq_createscriptinstance;
	sq_GetEntityConstantType __sq_GetEntityConstant_CBaseEntity;

	sq_pushnewstructinstanceType __sq_pushnewstructinstance;
	sq_sealstructslotType __sq_sealstructslot;

#pragma endregion

#pragma region SQVM func wrappers
	inline void defconst(CSquirrelVM* sqvm, const SQChar* pName, int nValue) { __sq_defconst(sqvm, pName, nValue); }

	inline SQRESULT
	compilebuffer(SQBufferState* bufferState, const SQChar* bufferName = "unnamedbuffer", const SQBool bShouldThrowError = false)
	{
		return __sq_compilebuffer(m_pSQVM->sqvm, bufferState, bufferName, -1, bShouldThrowError);
	}

	inline SQRESULT _call(HSQUIRRELVM sqvm, const SQInteger args) { return __sq_call(sqvm, args + 1, false, true); }

	inline SQInteger raiseerror(HSQUIRRELVM sqvm, const SQChar* sError) { return __sq_raiseerror(sqvm, sError); }

	inline bool compilefile(CSquirrelVM* sqvm, const char* path, const char* name, int a4)
	{
		return __sq_compilefile(sqvm, path, name, a4);
	}

	inline void newarray(HSQUIRRELVM sqvm, const SQInteger stackpos = 0) { __sq_newarray(sqvm, stackpos); }

	inline SQRESULT arrayappend(HSQUIRRELVM sqvm, const SQInteger stackpos) { return __sq_arrayappend(sqvm, stackpos); }

	inline SQRESULT newtable(HSQUIRRELVM sqvm) { return __sq_newtable(sqvm); }

	inline SQRESULT newslot(HSQUIRRELVM sqvm, SQInteger idx, SQBool bStatic) { return __sq_newslot(sqvm, idx, bStatic); }

	inline void pushroottable(HSQUIRRELVM sqvm) { __sq_pushroottable(sqvm); }

	inline void pushstring(HSQUIRRELVM sqvm, const SQChar* sVal, int length = -1) { __sq_pushstring(sqvm, sVal, length); }

	inline void pushinteger(HSQUIRRELVM sqvm, const SQInteger iVal) { __sq_pushinteger(sqvm, iVal); }

	inline void pushfloat(HSQUIRRELVM sqvm, const SQFloat flVal) { __sq_pushfloat(sqvm, flVal); }

	inline void pushbool(HSQUIRRELVM sqvm, const SQBool bVal) { __sq_pushbool(sqvm, bVal); }

	inline void pushasset(HSQUIRRELVM sqvm, const SQChar* sVal, int length = -1) { __sq_pushasset(sqvm, sVal, length); }

	inline void pushvector(HSQUIRRELVM sqvm, const Vector3 pVal) { __sq_pushvector(sqvm, (float*)&pVal); }

	inline void pushobject(HSQUIRRELVM sqvm, SQObject* obj) { __sq_pushobject(sqvm, obj); }

	inline const SQChar* getstring(HSQUIRRELVM sqvm, const SQInteger stackpos) { return __sq_getstring(sqvm, stackpos); }

	inline SQInteger getinteger(HSQUIRRELVM sqvm, const SQInteger stackpos) { return __sq_getinteger(sqvm, stackpos); }

	inline SQFloat getfloat(HSQUIRRELVM sqvm, const SQInteger stackpos) { return __sq_getfloat(sqvm, stackpos); }

	inline SQBool getbool(HSQUIRRELVM sqvm, const SQInteger stackpos) { return __sq_getbool(sqvm, stackpos); }

	inline SQRESULT get(HSQUIRRELVM sqvm, const SQInteger stackpos) { return __sq_get(sqvm, stackpos); }

	inline Vector3 getvector(HSQUIRRELVM sqvm, const SQInteger stackpos) { return *(Vector3*)__sq_getvector(sqvm, stackpos); }

	inline int sq_getfunction(HSQUIRRELVM sqvm, const char* name, SQObject* returnObj, const char* signature)
	{
		return __sq_getfunction(sqvm, name, returnObj, signature);
	}

	inline SQRESULT getasset(HSQUIRRELVM sqvm, const SQInteger stackpos, const char** result)
	{
		return __sq_getasset(sqvm, stackpos, result);
	}

	inline long long sq_stackinfos(HSQUIRRELVM sqvm, int level, SQStackInfos& out)
	{
		return __sq_stackinfos(sqvm, level, &out, sqvm->_callstacksize);
	}

	inline Mod* getcallingmod(HSQUIRRELVM sqvm, int depth = 0)
	{
		SQStackInfos stackInfo {};
		if (1 + depth >= sqvm->_callstacksize)
		{
			return nullptr;
		}
		sq_stackinfos(sqvm, 1 + depth, stackInfo);
		std::string sourceName = stackInfo._sourceName;
		std::replace(sourceName.begin(), sourceName.end(), '/', '\\');
		std::string filename = g_pModManager->NormaliseModFilePath(fs::path("scripts\\vscripts\\" + sourceName));
		if (auto res = g_pModManager->m_ModFiles.find(filename); res != g_pModManager->m_ModFiles.end())
		{
			return res->second.m_pOwningMod;
		}
		return nullptr;
	}
	template <typename T> inline SQRESULT getuserdata(HSQUIRRELVM sqvm, const SQInteger stackpos, T* data, uint64_t* typeId)
	{
		return __sq_getuserdata(sqvm, stackpos, (void**)data, typeId); // this sometimes crashes idk
	}

	template <typename T> inline T* createuserdata(HSQUIRRELVM sqvm, SQInteger size)
	{
		void* ret = __sq_createuserdata(sqvm, size);
		memset(ret, 0, size);
		return (T*)ret;
	}

	inline SQRESULT setuserdatatypeid(HSQUIRRELVM sqvm, const SQInteger stackpos, uint64_t typeId)
	{
		return __sq_setuserdatatypeid(sqvm, stackpos, typeId);
	}

	template <typename T> inline SQBool getthisentity(HSQUIRRELVM sqvm, T* ppEntity) { return __sq_getthisentity(sqvm, (void**)ppEntity); }

	template <typename T> inline T* getentity(HSQUIRRELVM sqvm, SQInteger iStackPos)
	{
		SQObject obj;
		__sq_getobject(sqvm, iStackPos, &obj);

		// there are entity constants for other types, but seemingly CBaseEntity's is the only one needed
		return (T*)__sq_getentityfrominstance(m_pSQVM, &obj, __sq_GetEntityConstant_CBaseEntity());
	}

	inline SQRESULT pushnewstructinstance(HSQUIRRELVM sqvm, const int fieldCount) { return __sq_pushnewstructinstance(sqvm, fieldCount); }

	inline SQRESULT sealstructslot(HSQUIRRELVM sqvm, const int fieldIndex) { return __sq_sealstructslot(sqvm, fieldIndex); }
#pragma endregion

#pragma region MessageBuffer
	SquirrelMessageBuffer* m_messageBuffer;

	template <typename... Args> SquirrelMessage AsyncCall(std::string funcname, Args... args)
	{
		// This function schedules a call to be executed on the next frame
		// This is useful for things like threads and plugins, which do not run on the main thread
		if (!m_pSQVM || !m_pSQVM->sqvm)
		{
			spdlog::error("AsyncCall {} was called on context {} while VM was not initialized.", funcname, GetContextName(m_context));
			return SquirrelMessage();
		}
		FunctionVector functionVector;
		SqRecurseArgs(this, functionVector, args...);
		SquirrelMessage message = {funcname, functionVector};
		m_messageBuffer->push(message);
		return message;
	}

	SquirrelMessage AsyncCall(std::string funcname)
	{
		// This function schedules a call to be executed on the next frame
		// This is useful for things like threads and plugins, which do not run on the main thread
		if (!m_pSQVM || !m_pSQVM->sqvm)
		{
			spdlog::error("AsyncCall {} was called on context {} while VM was not initialized.", funcname, GetContextName(m_context));
			return SquirrelMessage();
		}
		FunctionVector functionVector = {};
		SquirrelMessage message = {funcname, functionVector};
		m_messageBuffer->push(message);
		return message;
	}

	SQRESULT Call(const char* funcname)
	{
		// Warning!
		// This function assumes the squirrel VM is stopped/blocked at the moment of call
		// Calling this function while the VM is running is likely to result in a crash due to stack destruction
		// If you want to call into squirrel asynchronously, use `AsyncCall` instead

		if (!m_pSQVM || !m_pSQVM->sqvm)
		{
			spdlog::error("{} was called on context {} while VM was not initialized.", __FUNCTION__, GetContextName(m_context));
			return SQRESULT_ERROR;
		}

		SQObject functionobj {};
		int result = sq_getfunction(m_pSQVM->sqvm, funcname, &functionobj, 0);
		if (result != 0) // This func returns 0 on success for some reason
		{
			m_logger->error("Call was unable to find function with name '{}'. Is it global?", funcname);
			return SQRESULT_ERROR;
		}
		pushobject(m_pSQVM->sqvm, &functionobj); // Push the function object
		pushroottable(m_pSQVM->sqvm); // Push root table
		return _call(m_pSQVM->sqvm, 0);
	}

	template <typename... Args> SQRESULT Call(const char* funcname, Args... args)
	{
		// Warning!
		// This function assumes the squirrel VM is stopped/blocked at the moment of call
		// Calling this function while the VM is running is likely to result in a crash due to stack destruction
		// If you want to call into squirrel asynchronously, use `schedule_call` instead
		if (!m_pSQVM || !m_pSQVM->sqvm)
		{
			spdlog::error("{} was called on context {} while VM was not initialized.", __FUNCTION__, GetContextName(m_context));
			return SQRESULT_ERROR;
		}
		SQObject functionobj {};
		int result = sq_getfunction(m_pSQVM->sqvm, funcname, &functionobj, 0);
		if (result != 0) // This func returns 0 on success for some reason
		{
			m_logger->error("Call was unable to find function with name '{}'. Is it global?", funcname);
			return SQRESULT_ERROR;
		}
		pushobject(m_pSQVM->sqvm, &functionobj); // Push the function object
		pushroottable(m_pSQVM->sqvm); // Push root table

		FunctionVector functionVector;
		SqRecurseArgs(this, functionVector, args...);

		for (auto& v : functionVector)
		{
			// Execute lambda to push arg to stack
			v();
		}

		return _call(m_pSQVM->sqvm, (SQInteger)functionVector.size());
	}

#pragma endregion
};

// just a wrapper that lets us still access SquirrelManagers using [] operators
class SquirrelManagerManager
{
public:
	void InitialiseSquirrelManagers()
	{
		m_pSquirrel[static_cast<int>(ScriptContext::CLIENT)] = new SquirrelManager(ScriptContext::CLIENT);
		m_pSquirrel[static_cast<int>(ScriptContext::UI)] = new SquirrelManager(ScriptContext::UI);
		m_pSquirrel[static_cast<int>(ScriptContext::SERVER)] = new SquirrelManager(ScriptContext::SERVER);
	}

	SquirrelManager* operator[](ScriptContext context) { return m_pSquirrel[static_cast<int>(context)]; }

private:
	SquirrelManager* m_pSquirrel[3] = {};
};

extern SquirrelManagerManager g_pSquirrel;

/*
	Beware all ye who enter below.
	This place is not a place of honor... no highly esteemed deed is commemorated here... nothing valued is here.
	What is here was dangerous and repulsive to us. This message is a warning about danger.
*/

#pragma region MessageBuffer templates

// Clang-formatting makes this whole thing unreadable
// clang-format off

#ifndef MessageBufferFuncs
#define MessageBufferFuncs
// Bools
template <typename T>
requires std::convertible_to<T, bool> && (!std::is_floating_point_v<T>) && (!std::convertible_to<T, std::string>) && (!std::convertible_to<T, int>)
inline VoidFunction SQMessageBufferPushArg(SquirrelManager* squirrel, T& arg) {
	return [squirrel, arg]{ squirrel->pushbool(squirrel->m_pSQVM->sqvm, static_cast<bool>(arg)); };
}
// Vectors
inline VoidFunction SQMessageBufferPushArg(SquirrelManager* squirrel, Vector3& arg) {
	return [squirrel, arg]{ squirrel->pushvector(squirrel->m_pSQVM->sqvm, arg); };
}
// Vectors
inline VoidFunction SQMessageBufferPushArg(SquirrelManager* squirrel, SQObject* arg) {
	return [squirrel, arg]{ squirrel->pushobject(squirrel->m_pSQVM->sqvm, arg); };
}
// Ints
template <typename T>
requires std::convertible_to<T, int> && (!std::is_floating_point_v<T>)
inline VoidFunction SQMessageBufferPushArg(SquirrelManager* squirrel, T& arg) {
	return [squirrel, arg]{ squirrel->pushinteger(squirrel->m_pSQVM->sqvm, static_cast<int>(arg)); };
}
// Floats
template <typename T>
requires std::convertible_to<T, float> && (std::is_floating_point_v<T>)
inline VoidFunction SQMessageBufferPushArg(SquirrelManager* squirrel, T& arg) {
	return [squirrel, arg]{ squirrel->pushfloat(squirrel->m_pSQVM->sqvm, static_cast<float>(arg)); };
}
// Strings
template <typename T>
requires (std::convertible_to<T, std::string> || std::is_constructible_v<std::string, T>)
inline VoidFunction SQMessageBufferPushArg(SquirrelManager* squirrel, T& arg) {
	auto converted = std::string(arg);
	return [squirrel, converted]{ squirrel->pushstring(squirrel->m_pSQVM->sqvm, converted.c_str(), (int)converted.length()); };
}
// Assets
inline VoidFunction SQMessageBufferPushArg(SquirrelManager* squirrel, SquirrelAsset& arg) {
	return [squirrel, arg]{ squirrel->pushasset(squirrel->m_pSQVM->sqvm, arg.path.c_str(), arg.path.length()); };
}
// Maps
template <typename T>
requires is_iterable<T>
inline VoidFunction SQMessageBufferPushArg(SquirrelManager* squirrel, T& arg) {
	FunctionVector localv = {};
	localv.push_back([squirrel]{squirrel->newarray(squirrel->m_pSQVM->sqvm, 0);});

	for (const auto& item : arg) {
		localv.push_back(SQMessageBufferPushArg(squirrel, item));
		localv.push_back([squirrel]{squirrel->arrayappend(squirrel->m_pSQVM->sqvm, -2);});
	}

	return [localv] { for (auto& func : localv) { func(); } };
}
// Vectors
template <typename T>
requires is_map<T>
inline VoidFunction SQMessageBufferPushArg(SquirrelManager* squirrel, T& map) {
	FunctionVector localv = {};
	localv.push_back([squirrel]{squirrel->newtable(squirrel->m_pSQVM->sqvm);});

	for (const auto& item : map) {
		localv.push_back(SQMessageBufferPushArg(squirrel,item.first));
		localv.push_back(SQMessageBufferPushArg(squirrel,item.second));
		localv.push_back([squirrel]{squirrel->newslot(squirrel->m_pSQVM->sqvm, -3, false);});
	}

	return [localv]{ for (auto& func : localv) { func(); } };
}

template <typename T>
inline void SqRecurseArgs(SquirrelManager* squirrel, FunctionVector& v, T& arg) {
	v.push_back(SQMessageBufferPushArg(squirrel, arg));
}

// This function is separated from the PushArg function so as to not generate too many template instances
// This is the main function responsible for unrolling the argument pack
template <typename T, typename... Args>
inline void SqRecurseArgs(SquirrelManager* squirrel, FunctionVector& v, T& arg, Args... args) {
	v.push_back(SQMessageBufferPushArg(squirrel, arg));
	SqRecurseArgs(squirrel, v, args...);
}

// clang-format on
#endif

#pragma endregion
