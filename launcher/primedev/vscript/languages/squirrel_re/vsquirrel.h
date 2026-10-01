#pragma once

struct CSquirrelVM
{
	BYTE gap_0[8];
	HSQUIRRELVM sqvm;
	BYTE gap_10[8];
	SQObject unknownObject_18;
	__int64 unknown_28;
	BYTE gap_30[12];
	__int32 vmContext;
	BYTE gap_40[648];
	char* (*formatString)(__int64 a1, const char* format, ...);
	BYTE gap_2D0[24];
};
static_assert(sizeof(CSquirrelVM) == 744);
