#pragma once

void InitialiseClientSquirrel(HMODULE baseAddress);
void InitialiseServerSquirrel(HMODULE baseAddress);

// stolen from ttf2sdk: sqvm types
typedef float SQFloat;
typedef long SQInteger;
typedef unsigned long SQUnsignedInteger;
typedef char SQChar;

typedef SQUnsignedInteger SQBool;
typedef SQInteger SQRESULT;

template<Context context> class SquirrelManager
{
public:
	void* sqvm;

public:
	SquirrelManager();
};

extern SquirrelManager<CLIENT>* g_ClientSquirrelManager;
extern SquirrelManager<SERVER>* g_ServerSquirrelManager;
extern SquirrelManager<UI>* g_UISquirrelManager;