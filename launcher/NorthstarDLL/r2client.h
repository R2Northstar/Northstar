#pragma once

// use the R2 namespace for game funcs
namespace R2
{
	extern char* g_pLocalPlayerUserID;
	extern char* g_pLocalPlayerOriginToken;

	typedef void* (*GetBaseLocalClientType)();
	extern GetBaseLocalClientType GetBaseLocalClient;
} // namespace R2
