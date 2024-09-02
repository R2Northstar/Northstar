#pragma once

#include "vscript/languages/squirrel_re/include/squirrel.h"
#include "vscript/languages/squirrel_re/squirrel/sqstring.h"

struct SQVM;

enum class ScriptContext : int
{
	INVALID = -1,
	SERVER,
	CLIENT,
	UI,
};

struct alignas(8) SQVM
{
	struct alignas(8) CallInfo
	{
		long long ip;
		SQObject* _literals;
		SQObject obj10;
		SQObject closure;
		int _etraps[4];
		int _root;
		short _vargs_size;
		short _vargs_base;
		unsigned char gap[16];
	};

	void* vftable;
	int uiRef;
	unsigned char gap_8[12];
	void* _toString;
	void* _roottable_pointer;
	void* pointer_28;
	CallInfo* ci;
	CallInfo* _callstack;
	int _callstacksize;
	int _stackbase;
	SQObject* _stackOfCurrentFunction;
	SQSharedState* sharedState;
	void* pointer_58;
	void* pointer_60;
	int _top;
	SQObject* _stack;
	unsigned char gap_78[8];
	SQObject* _vargvstack;
	unsigned char gap_88[8];
	SQObject temp_reg;
	unsigned char gapA0[8];
	void* pointer_A8;
	unsigned char gap_B0[8];
	SQObject _roottable_object;
	SQObject _lasterror;
	SQObject _errorHandler;
	long long field_E8;
	int traps;
	unsigned char gap_F4[12];
	int _nnativecalls;
	int _suspended;
	int _suspended_root;
	int _unk;
	int _suspended_target;
	int trapAmount;
	int _suspend_varargs;
	int unknown_field_11C;
	SQObject object_120;
};
