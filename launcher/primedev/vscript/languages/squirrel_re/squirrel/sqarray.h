#pragma once

#include "vscript/languages/squirrel_re/include/squirrel.h"
#include "vscript/languages/squirrel_re/squirrel/sqobject.h"

struct SQArray : public SQCollectable
{
	SQObject* _values;
	int _usedSlots;
	int _allocated;
};
static_assert(sizeof(SQArray) == 0x40);
