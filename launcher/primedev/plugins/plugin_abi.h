#pragma once
#include "squirrel/squirrelclasstypes.h"

#define ABI_VERSION 3

enum PluginLoadDLL
{
	ENGINE = 0,
	CLIENT,
	SERVER
};

enum ObjectType
{
	CONCOMMANDS = 0,
	CONVAR = 1,
};

struct SquirrelFunctions
{
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

	sq_schedule_call_externalType __sq_schedule_call_external;

	sq_getentityfrominstanceType __sq_getentityfrominstance;
	sq_GetEntityConstantType __sq_GetEntityConstant_CBaseEntity;

	sq_pushnewstructinstanceType __sq_pushnewstructinstance;
	sq_sealstructslotType __sq_sealstructslot;
};

struct MessageSource
{
	const char* file;
	const char* func;
	int line;
};

// This is a modified version of spdlog::details::log_msg
// This is so that we can make it cross DLL boundaries
struct LogMsg
{
	int level;
	uint64_t timestamp;
	const char* msg;
	MessageSource source;
	int pluginHandle;
};

extern "C"
{
	typedef void (*loggerfunc_t)(LogMsg* msg);
	typedef void (*PLUGIN_RELAY_INVITE_TYPE)(const char* invite);
	typedef void* (*CreateObjectFunc)(ObjectType type);

	typedef void (*PluginFnCommandCallback_t)(void* command);
	typedef void (*PluginConCommandConstructorType)(
		void* newCommand, const char* name, PluginFnCommandCallback_t callback, const char* helpString, int flags, void* parent);
	typedef void (*PluginConVarRegisterType)(
		void* pConVar,
		const char* pszName,
		const char* pszDefaultValue,
		int nFlags,
		const char* pszHelpString,
		bool bMin,
		float fMin,
		bool bMax,
		float fMax,
		void* pCallback);
	typedef void (*PluginConVarMallocType)(void* pConVarMaloc, int a2, int a3);
}

struct PluginNorthstarData
{
	const char* version;
	HMODULE northstarModule;
	int pluginHandle;
};

struct PluginInitFuncs
{
	loggerfunc_t logger;
	PLUGIN_RELAY_INVITE_TYPE relayInviteFunc;
	CreateObjectFunc createObject;
};

struct PluginEngineData
{
	PluginConCommandConstructorType ConCommandConstructor;
	PluginConVarMallocType conVarMalloc;
	PluginConVarRegisterType conVarRegister;
	void* ConVar_Vtable;
	void* IConVar_Vtable;
	void* g_pCVar;
};

/// <summary> Async communication within the plugin system
/// Due to the asynchronous nature of plugins, combined with the limitations of multi-compiler support
/// and the custom memory allocator used by r2, is it difficult to safely get data across DLL boundaries
/// from Northstar to plugin unless Northstar can own that memory.
/// This means that plugins should manage their own memory and can only receive data from northstar using one of the functions below.
/// These should be exports of the plugin DLL. If they are not exported, they will not be called.
/// Note that it is not required to have these exports if you do not use them.
/// </summary>

// Northstar -> Plugin
typedef void (*PLUGIN_INIT_TYPE)(PluginInitFuncs* funcs, PluginNorthstarData* data);
typedef void (*PLUGIN_INIT_SQVM_TYPE)(SquirrelFunctions* funcs);
typedef void (*PLUGIN_INFORM_SQVM_CREATED_TYPE)(ScriptContext context, CSquirrelVM* sqvm);
typedef void (*PLUGIN_INFORM_SQVM_DESTROYED_TYPE)(ScriptContext context);

typedef void (*PLUGIN_INFORM_DLL_LOAD_TYPE)(const char* dll, PluginEngineData* data, void* dllPtr);
typedef void (*PLUGIN_RUNFRAME)();
