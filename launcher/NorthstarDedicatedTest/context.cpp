#include "pch.h"
#include "context.h"

const char* GetContextName(Context context)
{
	if (context == CLIENT)
		return "CLIENT";
	else if (context == SERVER)
		return "SERVER";
	else if (context == UI)
		return "UI";
	
	return "";
}