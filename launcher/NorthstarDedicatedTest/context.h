#pragma once

enum class ScriptContex : int
{
	SERVER,
	CLIENT,
	UI,
	NONE
};

const char* GetContextName(ScriptContex context);