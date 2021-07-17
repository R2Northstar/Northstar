#pragma once

enum Context
{
	SERVER,
	CLIENT,
	UI,
	NONE
};

const char* GetContextName(Context context);