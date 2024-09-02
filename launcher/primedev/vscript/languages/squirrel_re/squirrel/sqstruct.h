#pragma once

#include "vscript/languages/squirrel_re/include/squirrel.h"
#include "vscript/languages/squirrel_re/squirrel/sqobject.h"

struct SQStructDef : public SQCollectable
{
	SQObjectType _nameType;
	SQString* _name;
	unsigned char gap_38[16];
	SQObjectType _variableNamesType;
	SQTable* _variableNames;
	unsigned char gap_[32];
};
static_assert(sizeof(SQStructDef) == 128);

// NOTE [Fifty]: Variable sized struct
struct SQStructInstance : public SQCollectable
{
	unsigned int size;
	BYTE gap_34[4];
	SQObject data[1];
};
static_assert(sizeof(SQStructInstance) == 72);
