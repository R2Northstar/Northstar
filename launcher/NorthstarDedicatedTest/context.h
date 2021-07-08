#pragma once

enum Context
{
	NONE,
	CLIENT,
	SERVER,
	UI // this is used exclusively in scripts
};

const char* GetContextName(Context context);