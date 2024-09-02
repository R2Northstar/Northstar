#pragma once

#include "vscript/languages/squirrel_re/include/squirrel.h"
#include "vscript/languages/squirrel_re/squirrel/sqobject.h"

struct alignas(8) SQTable : public SQDelegable
{
	struct _HashNode
	{
		SQObject val;
		SQObject key;
		_HashNode* next;
	};

	_HashNode* _nodes;
	int _numOfNodes;
	int size;
	int field_48;
	int _usedNodes;
};
static_assert(sizeof(SQTable) == 80);
