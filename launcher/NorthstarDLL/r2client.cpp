#include "pch.h"
#include "r2client.h"

using namespace R2;

// use the R2 namespace for game funcs
namespace R2
{
	char* g_pLocalPlayerUserID;
	char* g_pLocalPlayerOriginToken;
	GetBaseLocalClientType GetBaseLocalClient;
} // namespace R2

ON_DLL_LOAD("engine.dll", R2EngineClient, (CModule module))
{
	g_pLocalPlayerUserID = module.Offset(0x13F8E688).As<char*>();
	g_pLocalPlayerOriginToken = module.Offset(0x13979C80).As<char*>();

	GetBaseLocalClient = module.Offset(0x78200).As<GetBaseLocalClientType>();
}
