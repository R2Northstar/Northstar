#pragma once

enum class ScriptContext : int
{
	SERVER,
	CLIENT,
	UI,
	NONE
};

const char* GetContextName(ScriptContext context);