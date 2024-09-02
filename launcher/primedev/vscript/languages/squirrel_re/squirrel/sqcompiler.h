#pragma once

#include "vscript/languages/squirrel_re/include/squirrel.h"
#include "vscript/languages/squirrel_re/squirrel/sqlexer.h"

struct SQCompiler
{
	BYTE gap0[4];
	int _token;
	BYTE gap_8[8];
	SQObject object_10;
	SQLexer lexer;
	int64_t qword90;
	int64_t qword98;
	BYTE gapA0[280];
	bool bFatalError;
	BYTE gap1B9[143];
	int64_t qword248;
	int64_t qword250;
	int64_t qword258;
	int64_t qword260;
	BYTE gap268[280];
	HSQUIRRELVM pSQVM;
	unsigned char gap_288[8];
};
static_assert(sizeof(SQCompiler) == 0x390);
