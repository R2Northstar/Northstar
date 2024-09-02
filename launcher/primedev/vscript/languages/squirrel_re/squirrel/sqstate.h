#pragma once

#include "vscript/languages/squirrel_re/include/squirrel.h"

class CSquirrelVM;
struct SQCompiler;

// TODO [Fifty]: Verify size
struct StringTable
{
	unsigned char gap_0[12];
	int _numofslots;
	unsigned char gap_10[200];
};

struct SQSharedState
{
	unsigned char gap_0[72];
	void* unknown;
	unsigned char gap_50[16344];
	SQObjectType _unknownTableType00;
	long long _unknownTableValue00;
	unsigned char gap_4038[16];
	StringTable* _stringTable;
	unsigned char gap_4050[32];
	SQObjectType _unknownTableType0;
	long long _unknownTableValue0;
	SQObjectType _unknownObjectType1;
	long long _unknownObjectValue1;
	unsigned char gap_4090[8];
	SQObjectType _unknownArrayType2;
	long long _unknownArrayValue2;
	SQObjectType _gobalsArrayType;
	SQStructInstance* _globalsArray;
	unsigned char gap_40B8[16];
	SQObjectType _nativeClosuresType;
	SQTable* _nativeClosures;
	SQObjectType _typedConstantsType;
	SQTable* _typedConstants;
	SQObjectType _untypedConstantsType;
	SQTable* _untypedConstants;
	SQObjectType _globalsMaybeType;
	SQTable* _globals;
	SQObjectType _functionsType;
	SQTable* _functions;
	SQObjectType _structsType;
	SQTable* _structs;
	SQObjectType _typeDefsType;
	SQTable* _typeDefs;
	SQObjectType unknownTableType;
	SQTable* unknownTable;
	SQObjectType _squirrelFilesType;
	SQTable* _squirrelFiles;
	unsigned char gap_4158[80];
	SQObjectType _nativeClosures2Type;
	SQTable* _nativeClosures2;
	SQObjectType _entityTypesMaybeType;
	SQTable* _entityTypesMaybe;
	SQObjectType unknownTable2Type;
	SQTable* unknownTable2;
	unsigned char gap_41D8[64];
	SQCompiler* pCompiler;
	SQObjectType _compilerKeywordsType;
	SQTable* _compilerKeywords;
	HSQUIRRELVM _currentThreadMaybe;
	unsigned char gap_4238[8];
	SQObjectType unknownTable3Type;
	SQTable* unknownTable3;
	unsigned char gap_4250[16];
	SQObjectType unknownThreadType;
	SQTable* unknownThread;
	SQObjectType _tableNativeFunctionsType;
	SQTable* _tableNativeFunctions;
	SQObjectType _unknownTableType4;
	long long _unknownObjectValue4;
	SQObjectType _unknownObjectType5;
	long long _unknownObjectValue5;
	SQObjectType _unknownObjectType6;
	long long _unknownObjectValue6;
	SQObjectType _unknownObjectType7;
	long long _unknownObjectValue7;
	SQObjectType _unknownObjectType8;
	long long _unknownObjectValue8;
	SQObjectType _unknownObjectType9;
	long long _unknownObjectValue9;
	SQObjectType _unknownObjectType10;
	long long _unknownObjectValue10;
	SQObjectType _unknownObjectType11;
	long long _unknownObjectValue11;
	SQObjectType _unknownObjectType12;
	long long _unknownObjectValue12;
	SQObjectType _unknownObjectType13;
	long long _unknownObjectValue13;
	SQObjectType _unknownObjectType14;
	long long _unknownObjectValue14;
	SQObjectType _unknownObjectType15;
	long long _unknownObjectValue15;
	unsigned __int8 gap_4340[8];
	void* fnFatalErrorCallback;
	void* fnPrintCallback;
	unsigned __int8 gap_4358[16];
	void* logEntityFunction;
	unsigned char gap_4370[1];
	SQChar szContextName[8];
	unsigned char gap[31];
	SQObjectType _waitStringType;
	SQString* _waitStringValue;
	SQObjectType _SpinOffAndWaitForStringType;
	SQString* _SpinOffAndWaitForStringValue;
	SQObjectType _SpinOffAndWaitForSoloStringType;
	SQString* _SpinOffAndWaitForSoloStringValue;
	SQObjectType _SpinOffStringType;
	SQString* _SpinOffStringValue;
	SQObjectType _SpinOffDelayedStringType;
	SQString* _SpinOffDelayedStringValue;
	CSquirrelVM* cSquirrelVM;
	bool enableDebugInfo; // functionality stripped
	unsigned char gap_43F1[23];
};
static_assert(sizeof(SQSharedState) == 17416);
