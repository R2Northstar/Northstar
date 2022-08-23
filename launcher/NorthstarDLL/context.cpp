#include "pch.h"
#include "context.h"

const char* GetContextName(ScriptContext context)
{
	if (context == ScriptContext::CLIENT)
		return "CLIENT";
	else if (context == ScriptContext::SERVER)
		return "SERVER";
	else if (context == ScriptContext::UI)
		return "UI";

	return "";
}