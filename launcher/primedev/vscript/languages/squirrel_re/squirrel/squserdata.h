#pragma once

#include "vscript/languages/squirrel_re/include/squirrel.h"
#include "vscript/languages/squirrel_re/squirrel/sqobject.h"

// NOTE [Fifty]: Variable sized struct
struct SQUserData : public SQDelegable
{
	int size;
	char padding1[4];
	void* (*releasehook)(void* val, int size);
	long long typeId;
	char data[1];
};
static_assert(sizeof(SQUserData) == 88); // [Fifty]: Game allocates 87 + size (passed to the function)
