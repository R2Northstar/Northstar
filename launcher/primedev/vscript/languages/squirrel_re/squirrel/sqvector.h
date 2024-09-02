#pragma once

#include "vscript/languages/squirrel_re/include/squirrel.h"

// TODO [Fifty]: Verify size
struct SQVector
{
	SQObjectType _Type;
	float x;
	float y;
	float z;
};
