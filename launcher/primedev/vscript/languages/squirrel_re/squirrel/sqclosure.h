#pragma once

#include "vscript/languages/squirrel_re/include/squirrel.h"
#include "vscript/languages/squirrel_re/squirrel/sqobject.h"

struct alignas(8) SQClosure : public SQCollectable
{
	SQObject obj_30;
	SQObject _function;
	SQObject* _outervalues;
	unsigned char gap_58[8];
};
static_assert(sizeof(SQClosure) == 96);

struct alignas(8) SQNativeClosure : public SQCollectable
{
	char unknown_30;
	unsigned char padding_34[7];
	long long value_38;
	long long value_40;
	long long value_48;
	long long value_50;
	long long value_58;
	SQObjectType _nameType;
	SQString* _name;
	long long value_70;
	long long value_78;
};
static_assert(sizeof(SQNativeClosure) == 128);
