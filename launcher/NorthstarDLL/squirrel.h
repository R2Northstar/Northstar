#include <../modmanager.h>
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

const SQRESULT SQRESULT_ERROR = -1;
const SQRESULT SQRESULT_NULL = 0;
const SQRESULT SQRESULT_NOTNULL = 1;

typedef SQInteger (*SQFunction)(void* sqvm);

enum SQReturnTypeEnum
{
	SqReturnFloat = 0x1,
	SqReturnVector = 0x3,
	SqReturnInteger = 0x5,
	SqReturnBoolean = 0x6,
	SqReturnEntity = 0xD,
	SqReturnString = 0x21,
	SqReturnDefault = 0x20,
	SqReturnArrays = 0x25,
	SqReturnAsset = 0x28,
	SqReturnTable = 0x26,
};

const char* sq_getTypeName(int type);

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
	__int32 unknown1;
	__int32 devLevel;
	const char* shortNameMaybe;
	__int32 unknown2;
	SQReturnTypeEnum returnTypeEnum;
	__int32* externalBufferPointer;
	__int64 externalBufferSize;
	__int64 unknown3;
	__int64 unknown4;
	void* funcPtr;

	SQFuncRegistration()
	{
		memset(this, 0, sizeof(SQFuncRegistration));
		this->returnTypeEnum = SqReturnDefault;
	}
};

SQReturnTypeEnum GetReturnTypeEnumFromString(const char* returnTypeString);

struct CallInfo;
struct SQTable;
struct SQString;
struct SQFunctionProto;
struct SQClosure;
struct SQSharedState;
struct StringTable;
struct SQStructInstance;
struct SQStructDef;
struct SQNativeClosure;
struct SQArray;
struct SQInstruction;

/* 127 */
enum SQObjectType : __int32
{
	_RT_NULL = 0x1,
	_RT_INTEGER = 0x2,
	_RT_FLOAT = 0x4,
	_RT_BOOL = 0x8,
	_RT_STRING = 0x10,
	_RT_TABLE = 0x20,
	_RT_ARRAY = 0x40,
	_RT_USERDATA = 0x80,
	_RT_CLOSURE = 0x100,
	_RT_NATIVECLOSURE = 0x200,
	_RT_GENERATOR = 0x400,
	OT_USERPOINTER = 0x800,
	_RT_USERPOINTER = 0x800,
	_RT_THREAD = 0x1000,
	_RT_FUNCPROTO = 0x2000,
	_RT_CLASS = 0x4000,
	_RT_INSTANCE = 0x8000,
	_RT_WEAKREF = 0x10000,
	OT_VECTOR = 0x40000,
	SQOBJECT_CANBEFALSE = 0x1000000,
	OT_NULL = 0x1000001,
	OT_BOOL = 0x1000008,
	SQOBJECT_DELEGABLE = 0x2000000,
	SQOBJECT_NUMERIC = 0x4000000,
	OT_INTEGER = 0x5000002,
	OT_FLOAT = 0x5000004,
	SQOBJECT_REF_COUNTED = 0x8000000,
	OT_STRING = 0x8000010,
	OT_ARRAY = 0x8000040,
	OT_CLOSURE = 0x8000100,
	OT_NATIVECLOSURE = 0x8000200,
	OT_ASSET = 0x8000400,
	OT_THREAD = 0x8001000,
	OT_FUNCPROTO = 0x8002000,
	OT_CLAAS = 0x8004000,
	OT_STRUCT = 0x8200000,
	OT_WEAKREF = 0x8010000,
	OT_TABLE = 0xA000020,
	OT_USERDATA = 0xA000080,
	OT_INSTANCE = 0xA008000,
	OT_ENTITY = 0xA400000,
};

/* 156 */
union alignas(8) SQObjectValue
{
	SQString* asString;
	SQTable* asTable;
	SQClosure* asClosure;
	SQFunctionProto* asFuncProto;
	SQStructDef* asStructDef;
	__int64 asInteger;
	SQStructInstance* asStructInstance;
	float asFloat;
	SQNativeClosure* asNativeClosure;
	SQArray* asArray;
};

/* 128 */
struct alignas(8) SQObject
{
	SQObjectType _Type;
	__int32 _structOffset;
	SQObjectValue _VAL;
};

struct tableNode
{
	SQObject val;
	SQObject key;
	tableNode* next;
};

/* 138 */
struct alignas(8) SQString
{
	__int64* vftable;
	__int32 uiRef;
	__int32 uiRef1;
	SQString* _next_maybe;
	SQSharedState* sharedState;
	__int32 length;
	uint8_t gap_24[4];
	char _hash[8];
	char _val[1];
};

/* 137 */
struct alignas(8) SQTable
{
	__int64* vftable;
	uint8_t gap_08[4];
	__int32 uiRef;
	uint8_t gap_10[8];
	void* pointer_18;
	void* pointer_20;
	void* _sharedState;
	__int64 field_30;
	tableNode* _nodes;
	__int32 _numOfNodes;
	__int32 size;
	__int32 field_48;
	__int32 _usedNodes;
	uint8_t _gap_50[20];
	__int32 field_64;
	uint8_t _gap_68[80];
};

/* 140 */
struct alignas(8) SQClosure
{
	void* vftable;
	uint8_t gap_08[4];
	__int32 uiRef;
	void* pointer_10;
	void* pointer_18;
	void* pointer_20;
	void* sharedState;
	SQObject obj_30;
	SQObject _function;
	SQObject* _outervalues;
	uint8_t gap_58[8];
	uint8_t gap_60[96];
	SQObject* objectPointer_C0;
};

/* 139 */
struct alignas(8) SQFunctionProto
{
	void* vftable;
	uint8_t gap_08[4];
	__int32 uiRef;
	uint8_t gap_10[8];
	void* pointer_18;
	void* pointer_20;
	void* sharedState;
	void* pointer_30;
	SQObject fileName;
	SQObject funcName;
	SQObject obj_58;
	uint8_t gap_68[64];
	__int32 nParameters;
	uint8_t gap_AC[60];
	__int32 nDefaultParams;
	uint8_t gap_EC[200];
};

/* 152 */
struct SQStructDef
{
	uint8_t gap_0[56];
	SQString* name;
	uint8_t gap_[300];
};

/* 150 */
struct SQStructInstance
{
	void* vftable;
	uint8_t gap_8[16];
	void* pointer_18;
	uint8_t gap_20[8];
	SQSharedState* _sharedState;
	uint8_t gap_30[8];
	SQObject data[1];
};

/* 157 */
struct alignas(8) SQNativeClosure
{
	void* vftable;
	uint8_t gap_08[4];
	__int32 uiRef;
	uint8_t gap_10[88];
	SQString* _name;
	uint8_t gap_0[300];
};

/* 148 */
struct SQSharedState
{
	uint8_t gap_0[72];
	StringTable* _stringtable;
	uint8_t gap_50[30000];
};

/* 149 */
struct StringTable
{
	uint8_t gap_0[12];
	int _numofslots;
	uint8_t gap_10[200];
};

/* 129 */
struct alignas(8) HSquirrelVM
{
	void* vftable;
	__int32 uiRef;
	uint8_t gap_8[12];
	void* _toString;
	void* _roottable_pointer;
	void* pointer_28;
	CallInfo* ci;
	CallInfo* _callsstack;
	__int32 _callsstacksize;
	__int32 _stackbase;
	SQObject* _stackOfCurrentFunction;
	SQSharedState* sharedState;
	void* pointer_58;
	void* pointer_60;
	__int32 _top;
	SQObject* _stack;
	uint8_t gap_78[8];
	SQObject* _vargsstack;
	uint8_t gap_88[8];
	SQObject temp_reg;
	uint8_t gapA0[8];
	void* pointer_A8;
	uint8_t gap_B0[8];
	SQObject _roottable_object;
	SQObject _lasterror;
	SQObject _errorHandler;
	__int64 field_E8;
	__int32 traps;
	uint8_t gap_F4[12];
	__int32 _nnativecalls;
	__int32 _suspended;
	__int32 _suspended_root;
	__int32 _callstacksize;
	__int32 _suspended_target;
	__int32 field_114;
	__int32 _suspend_varargs;
	SQObject* _object_pointer_120;
};

/* 136 */
struct alignas(8) CallInfo
{
	SQInstruction* ip;
	SQObject* _literals;
	SQObject obj10;
	SQObject closure;
	__int32 _etraps[4];
	__int32 _root;
	short _vargs_size;
	short _vargs_base;
};

/* 135 */
enum SQOpcode : int
{
	_OP_LOAD = 0x0,
	_OP_LOADCOPY = 0x1,
	_OP_LOADINT = 0x2,
	_OP_LOADFLOAT = 0x3,
	_OP_DLOAD = 0x4,
	_OP_TAILCALL = 0x5,
	_OP_CALL = 0x6,
	_OP_PREPCALL = 0x7,
	_OP_PREPCALLK = 0x8,
	_OP_GETK = 0x9,
	_OP_MOVE = 0xA,
	_OP_NEWSLOT = 0xB,
	_OP_DELETE = 0xC,
	_OP_SET = 0xD,
	_OP_GET = 0xE,
	_OP_EQ = 0xF,
	_OP_NE = 0x10,
	_OP_ARITH = 0x11,
	_OP_BITW = 0x12,
	_OP_RETURN = 0x13,
	_OP_LOADNULLS = 0x14,
	_OP_LOADROOTTABLE = 0x15,
	_OP_LOADBOOL = 0x16,
	_OP_DMOVE = 0x17,
	_OP_JMP = 0x18,
	_OP_JNZ = 0x19,
	_OP_JZ = 0x1A,
	_OP_LOADFREEVAR = 0x1B,
	_OP_VARGC = 0x1C,
	_OP_GETVARGV = 0x1D,
	_OP_NEWTABLE = 0x1E,
	_OP_NEWARRAY = 0x1F,
	_OP_APPENDARRAY = 0x20,
	_OP_GETPARENT = 0x21,
	_OP_COMPOUND_ARITH = 0x22,
	_OP_COMPOUND_ARITH_LOCAL = 0x23,
	_OP_INCREMENT_PREFIX = 0x24,
	_OP_INCREMENT_PREFIX_LOCAL = 0x25,
	_OP_INCREMENT_PREFIX_STRUCTFIELD = 0x26,
	_OP_INCREMENT_POSTFIX = 0x27,
	_OP_INCREMENT_POSTFIX_LOCAL = 0x28,
	_OP_INCREMENT_POSTFIX_STRUCTFIELD = 0x29,
	_OP_CMP = 0x2A,
	_OP_EXISTS = 0x2B,
	_OP_INSTANCEOF = 0x2C,
	_OP_NEG = 0x2D,
	_OP_NOT = 0x2E,
	_OP_BWNOT = 0x2F,
	_OP_CLOSURE = 0x30,
	_OP_FOREACH = 0x31,
	_OP_FOREACH_STATICARRAY_START = 0x32,
	_OP_FOREACH_STATICARRAY_NEXT = 0x33,
	_OP_FOREACH_STATICARRAY_NESTEDSTRUCT_START = 0x34,
	_OP_FOREACH_STATICARRAY_NESTEDSTRUCT_NEXT = 0x35,
	_OP_DELEGATE = 0x36,
	_OP_CLONE = 0x37,
	_OP_TYPEOF = 0x38,
	_OP_PUSHTRAP = 0x39,
	_OP_POPTRAP = 0x3A,
	_OP_THROW = 0x3B,
	_OP_CLASS = 0x3C,
	_OP_NEWSLOTA = 0x3D,
	_OP_EQ_LITERAL = 0x3E,
	_OP_NE_LITERAL = 0x3F,
	_OP_FOREACH_SETUP = 0x40,
	_OP_ASSERT_FAILED = 0x41,
	_OP_ADD = 0x42,
	_OP_SUB = 0x43,
	_OP_MUL = 0x44,
	_OP_DIV = 0x45,
	_OP_MOD = 0x46,
	_OP_PREPCALLK_CALL = 0x47,
	_OP_PREPCALLK_MOVE_CALL = 0x48,
	_OP_PREPCALLK_LOADINT_CALL = 0x49,
	_OP_CMP_JZ = 0x4A,
	_OP_INCREMENT_LOCAL_DISCARD_JMP = 0x4B,
	_OP_JZ_RETURN = 0x4C,
	_OP_JZ_LOADBOOL_RETURN = 0x4D,
	_OP_NEWVECTOR = 0x4E,
	_OP_ZEROVECTOR = 0x4F,
	_OP_GET_VECTOR_COMPONENT = 0x50,
	_OP_SET_VECTOR_COMPONENT = 0x51,
	_OP_VECTOR_COMPONENT_MINUSEQ = 0x52,
	_OP_VECTOR_COMPONENT_PLUSEQ = 0x53,
	_OP_VECTOR_COMPONENT_MULEQ = 0x54,
	_OP_VECTOR_COMPONENT_DIVEQ = 0x55,
	_OP_VECTOR_NORMALIZE = 0x56,
	_OP_VECTOR_NORMALIZE_IN_PLACE = 0x57,
	_OP_VECTOR_DOT_PRODUCT = 0x58,
	_OP_VECTOR_DOT_PRODUCT2D = 0x59,
	_OP_VECTOR_CROSS_PRODUCT = 0x5A,
	_OP_VECTOR_CROSS_PRODUCT2D = 0x5B,
	_OP_VECTOR_LENGTH = 0x5C,
	_OP_VECTOR_LENGTHSQR = 0x5D,
	_OP_VECTOR_LENGTH2D = 0x5E,
	_OP_VECTOR_LENGTH2DSQR = 0x5F,
	_OP_VECTOR_DISTANCE = 0x60,
	_OP_VECTOR_DISTANCESQR = 0x61,
	_OP_VECTOR_DISTANCE2D = 0x62,
	_OP_VECTOR_DISTANCE2DSQR = 0x63,
	_OP_INCREMENT_LOCAL_DISCARD = 0x64,
	_OP_FASTCALL = 0x65,
	_OP_FASTCALL_NATIVE = 0x66,
	_OP_FASTCALL_NATIVE_ARGTYPECHECK = 0x67,
	_OP_FASTCALL_ENV = 0x68,
	_OP_FASTCALL_NATIVE_ENV = 0x69,
	_OP_FASTCALL_NATIVE_ENV_ARGTYPECHECK = 0x6A,
	_OP_LOADGLOBALARRAY = 0x6B,
	_OP_GETGLOBAL = 0x6C,
	_OP_SETGLOBAL = 0x6D,
	_OP_COMPOUND_ARITH_GLOBAL = 0x6E,
	_OP_GETSTRUCTFIELD = 0x6F,
	_OP_SETSTRUCTFIELD = 0x70,
	_OP_COMPOUND_ARITH_STRUCTFIELD = 0x71,
	_OP_NEWSTRUCT = 0x72,
	_OP_GETSUBSTRUCT = 0x73,
	_OP_GETSUBSTRUCT_DYNAMIC = 0x74,
	_OP_TYPECAST = 0x75,
	_OP_TYPECHECK = 0x76,
	_OP_TYPECHECK_ORNULL = 0x77,
	_OP_TYPECHECK_NOTNULL = 0x78,
	_OP_CHECK_ENTITY_CLASS = 0x79,
	_OP_UNREACHABLE = 0x7A,
	_OP_ARRAY_RESIZE = 0x7B,
};

/* 141 */
struct alignas(8) SQStackInfos
{
	char* _name;
	char* _sourceName;
	__int32 _line;
};

/* 151 */
struct alignas(4) SQInstruction
{
	int op;
	int arg1;
	int output;
	__int16 arg2;
	__int16 arg3;
};

/* 154 */
struct SQLexer
{
	uint8_t gap_0[112];
};

/* 153 */
struct SQCompiler
{
	uint8_t gap_0[4];
	__int32 _token;
	uint8_t gap_8[8];
	SQObject object_10;
	SQLexer lexer;
	uint8_t gap_1[768];
};

/* 155 */
struct CSquirrelVM
{
	uint8_t gap_0[8];
	HSquirrelVM* sqvm;
};

struct SQVector
{
	SQObjectType _Type;
	float x;
	float y;
	float z;
};

struct SQArray
{
	void* vftable;
	__int32 uiRef;
	uint8_t gap_24[36];
	SQObject* _values;
	__int32 _usedSlots;
	__int32 _allocated;
};

#define INCREMENT_REFERENCECOUNT(val)                                                                                                      \
	if ((val->_Type & SQOBJECT_REF_COUNTED) != 0)                                                                                          \
		++val->_VAL.asString->uiRef;

#define DECREMENT_REFERENCECOUNT(val)                                                                                                      \
	if ((val->_Type & SQOBJECT_REF_COUNTED) != 0)                                                                                          \
	{                                                                                                                                      \
		if (val->_VAL.asString->uiRef-- == 1)                                                                                              \
		{                                                                                                                                  \
			spdlog::info("Deleted SQObject of type {} with address {:X}", sq_getTypeName(val->_Type), val->_VAL.asInteger);                \
			(*(void(__fastcall**)(SQString*))(&val->_VAL.asString->vftable[1]))(val->_VAL.asString);                                       \
		}                                                                                                                                  \
	}

// core sqvm funcs
typedef SQRESULT (*sq_compilebufferType)(void* sqvm, CompileBufferState* compileBuffer, const char* file, int a1, ScriptContext a2);
extern sq_compilebufferType ClientSq_compilebuffer;
extern sq_compilebufferType ServerSq_compilebuffer;

typedef void (*sq_pushroottableType)(void* sqvm);
extern sq_pushroottableType ClientSq_pushroottable;
extern sq_pushroottableType ServerSq_pushroottable;

typedef SQRESULT (*sq_callType)(void* sqvm, SQInteger s1, SQBool a2, SQBool a3);
extern sq_callType ClientSq_call;
extern sq_callType ServerSq_call;

typedef int64_t (*RegisterSquirrelFuncType)(void* sqvm, SQFuncRegistration* funcReg, char unknown);
extern RegisterSquirrelFuncType ClientRegisterSquirrelFunc;
extern RegisterSquirrelFuncType ServerRegisterSquirrelFunc;

// sq stack array funcs
typedef void (*sq_newarrayType)(void* sqvm, SQInteger stackpos);
extern sq_newarrayType ClientSq_newarray;
extern sq_newarrayType ServerSq_newarray;

typedef SQRESULT (*sq_arrayappendType)(void* sqvm, SQInteger stackpos);
extern sq_arrayappendType ClientSq_arrayappend;
extern sq_arrayappendType ServerSq_arrayappend;

// sq stack push funcs
typedef void (*sq_pushstringType)(void* sqvm, const SQChar* str, SQInteger stackpos);
extern sq_pushstringType ClientSq_pushstring;
extern sq_pushstringType ServerSq_pushstring;

// weird how these don't take a stackpos arg?
typedef void (*sq_pushintegerType)(void* sqvm, SQInteger i);
extern sq_pushintegerType ClientSq_pushinteger;
extern sq_pushintegerType ServerSq_pushinteger;

typedef void (*sq_pushfloatType)(void* sqvm, SQFloat f);
extern sq_pushfloatType ClientSq_pushfloat;
extern sq_pushfloatType ServerSq_pushfloat;

typedef void (*sq_pushboolType)(void* sqvm, SQBool b);
extern sq_pushboolType ClientSq_pushbool;
extern sq_pushboolType ServerSq_pushbool;

typedef SQInteger (*sq_pusherrorType)(void* sqvm, const SQChar* error);
extern sq_pusherrorType ClientSq_pusherror;
extern sq_pusherrorType ServerSq_pusherror;

typedef void (*sq_defconst)(void* sqvm, const SQChar* name, int value);
extern sq_defconst ClientSq_defconst;
extern sq_defconst ServerSq_defconst;

typedef SQRESULT (*sq_pushAssetType)(void* sqvm, const SQChar* assetName, SQInteger nameLength);
extern sq_pushAssetType ServerSq_pushAsset;
extern sq_pushAssetType ClientSq_pushAsset;

// sq stack get funcs
typedef const SQChar* (*sq_getstringType)(void* sqvm, SQInteger stackpos);
extern sq_getstringType ClientSq_getstring;
extern sq_getstringType ServerSq_getstring;

typedef SQInteger (*sq_getintegerType)(void* sqvm, SQInteger stackpos);
extern sq_getintegerType ClientSq_getinteger;
extern sq_getintegerType ServerSq_getinteger;

typedef SQFloat (*sq_getfloatType)(void*, SQInteger stackpos);
extern sq_getfloatType ClientSq_getfloat;
extern sq_getfloatType ServerSq_getfloat;

typedef SQBool (*sq_getboolType)(void*, SQInteger stackpos);
extern sq_getboolType ClientSq_getbool;
extern sq_getboolType ServerSq_getbool;

typedef SQRESULT (*sq_getType)(void* sqvm, SQInteger idx);
extern sq_getType ServerSq_sq_get;
extern sq_getType ClientSq_sq_get;

// sq table functions
typedef SQRESULT (*sq_newTableType)(void* sqvm);
extern sq_newTableType ServerSq_newTable;
extern sq_newTableType ClientSq_newTable;

typedef SQRESULT (*sq_newSlotType)(void* sqvm, int idx, bool bStatic);
extern sq_newSlotType ServerSq_newSlot;
extern sq_newSlotType ClientSq_newSlot;

template <ScriptContext context> class SquirrelManager
{
  private:
	std::vector<SQFuncRegistration*> m_funcRegistrations;

  public:
	void* sqvm;
	void* sqvm2;

  public:
	SquirrelManager() : sqvm(nullptr) {}

	void VMCreated(void* newSqvm)
	{
		sqvm = newSqvm;
		sqvm2 = *((void**)((char*)sqvm + 8)); // honestly not 100% sure on what this is, but alot of functions take it

		for (SQFuncRegistration* funcReg : m_funcRegistrations)
		{
			spdlog::info("Registering {} function {}", GetContextName(context), funcReg->squirrelFuncName);

			if (context == ScriptContext::CLIENT || context == ScriptContext::UI)
				ClientRegisterSquirrelFunc(sqvm, funcReg, 1);
			else
				ServerRegisterSquirrelFunc(sqvm, funcReg, 1);
		}
		for (auto& pair : g_ModManager->DependencyConstants)
		{
			bool wasFound = false;
			for (Mod& dependency : g_ModManager->m_loadedMods)
			{
				if (dependency.Name == pair.second)
				{
					wasFound = dependency.Enabled;
					break;
				}
			}
			if (context == ScriptContext::SERVER)
				ServerSq_defconst(sqvm, pair.first.c_str(), wasFound);
			else
				ClientSq_defconst(sqvm, pair.first.c_str(), wasFound);
		}
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

		spdlog::info("Executing {} script code {} ", GetContextName(context), code);

		std::string strCode(code);
		CompileBufferState bufferState = CompileBufferState(strCode);

		SQRESULT compileResult;
		if (context == ScriptContext::CLIENT || context == ScriptContext::UI)
			compileResult = ClientSq_compilebuffer(sqvm2, &bufferState, "console", -1, context);
		else if (context == ScriptContext::SERVER)
			compileResult = ServerSq_compilebuffer(sqvm2, &bufferState, "console", -1, context);

		spdlog::info("sq_compilebuffer returned {}", compileResult);
		if (compileResult >= 0)
		{
			if (context == ScriptContext::CLIENT || context == ScriptContext::UI)
			{
				ClientSq_pushroottable(sqvm2);
				SQRESULT callResult = ClientSq_call(sqvm2, 1, false, false);
				spdlog::info("sq_call returned {}", callResult);
			}
			else if (context == ScriptContext::SERVER)
			{
				ServerSq_pushroottable(sqvm2);
				SQRESULT callResult = ServerSq_call(sqvm2, 1, false, false);
				spdlog::info("sq_call returned {}", callResult);
			}
		}
	}

	int setupfunc(const char* funcname)
	{
		int result = -2;
		if (context == ScriptContext::CLIENT || context == ScriptContext::UI)
		{
			ClientSq_pushroottable(sqvm2);
			ClientSq_pushstring(sqvm2, funcname, -1);
			result = ClientSq_sq_get(sqvm2, -2);
			if (result != SQRESULT_ERROR)
			{
				ClientSq_pushroottable(sqvm2);
			}
		}
		else if (context == ScriptContext::SERVER)
		{
			ServerSq_pushroottable(sqvm2);
			ServerSq_pushstring(sqvm2, funcname, -1);
			result = ServerSq_sq_get(sqvm2, -2);
			if (result != SQRESULT_ERROR)
			{
				ServerSq_pushroottable(sqvm2);
			}
		}
		return result;
	}

	void pusharg(int arg)
	{
		if (context == ScriptContext::CLIENT || context == ScriptContext::UI)
			ClientSq_pushinteger(sqvm2, arg);
		else if (context == ScriptContext::SERVER)
			ServerSq_pushinteger(sqvm2, arg);
	}
	void pusharg(const char* arg)
	{
		if (context == ScriptContext::CLIENT || context == ScriptContext::UI)
			ClientSq_pushstring(sqvm2, arg, -1);
		else if (context == ScriptContext::SERVER)
			ServerSq_pushstring(sqvm2, arg, -1);
	}
	void pusharg(float arg)
	{
		if (context == ScriptContext::CLIENT || context == ScriptContext::UI)
			ClientSq_pushfloat(sqvm2, arg);
		else if (context == ScriptContext::SERVER)
			ServerSq_pushfloat(sqvm2, arg);
	}
	void pusharg(bool arg)
	{
		if (context == ScriptContext::CLIENT || context == ScriptContext::UI)
			ClientSq_pushbool(sqvm2, arg);
		else if (context == ScriptContext::SERVER)
			ServerSq_pushbool(sqvm2, arg);
	}

	int call(int args)
	{
		int result = -2;
		if (context == ScriptContext::CLIENT || context == ScriptContext::UI)
			result = ClientSq_call(sqvm2, args + 1, false, false);
		else if (context == ScriptContext::SERVER)
			result = ServerSq_call(sqvm2, args + 1, false, false);

		return result;
	}

	void AddFuncRegistration(std::string returnType, std::string name, std::string argTypes, std::string helpText, SQFunction func)
	{
		SQFuncRegistration* reg = new SQFuncRegistration;

		reg->squirrelFuncName = new char[name.size() + 1];
		strcpy((char*)reg->squirrelFuncName, name.c_str());
		reg->cppFuncName = reg->squirrelFuncName;

		reg->helpText = new char[helpText.size() + 1];
		strcpy((char*)reg->helpText, helpText.c_str());

		reg->returnTypeString = new char[returnType.size() + 1];
		strcpy((char*)reg->returnTypeString, returnType.c_str());
		reg->returnTypeEnum = GetReturnTypeEnumFromString(returnType.c_str());

		reg->argTypes = new char[argTypes.size() + 1];
		strcpy((char*)reg->argTypes, argTypes.c_str());

		reg->funcPtr = reinterpret_cast<void*>(func);

		m_funcRegistrations.push_back(reg);
	}
};

extern SquirrelManager<ScriptContext::CLIENT>* g_ClientSquirrelManager;
extern SquirrelManager<ScriptContext::SERVER>* g_ServerSquirrelManager;
extern SquirrelManager<ScriptContext::UI>* g_UISquirrelManager;
