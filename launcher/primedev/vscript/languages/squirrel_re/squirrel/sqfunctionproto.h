#pragma once

#include "vscript/languages/squirrel_re/include/squirrel.h"
#include "vscript/languages/squirrel_re/squirrel/sqobject.h"

// NOTE [Fifty]: Variable sized struct
struct alignas(8) SQFunctionProto : public SQCollectable
{
	void* pointer_30;
	SQObjectType _fileNameType;
	SQString* _fileName;
	SQObjectType _funcNameType;
	SQString* _funcName;
	SQObject obj_58;
	unsigned char gap_68[12];
	int _stacksize;
	unsigned char gap_78[48];
	int nParameters;
	unsigned char gap_AC[60];
	int nDefaultParams;
	unsigned char gap_EC[200];
};
// TODO [Fifty]: Find out the size of the base struct
static_assert(offsetof(SQFunctionProto, _fileName) == 0x40); // Sanity this check for now
