#include "pch.h"
#include "context.h"

const char* GetContextName(ScriptContex context)
{
	if (context == ScriptContex::CLIENT)
		return "CLIENT";
	else if (context == ScriptContex::SERVER)
		return "SERVER";
	else if (context == ScriptContex::UI)
		return "UI";
	
	return "";
}