static void (*Studio_ReloadModels)(__int64 a1, unsigned int a2) = nullptr;
static uintptr_t model_loader;
static uint8_t* g_VpkMode;

void ConCommand_reload_models(const CCommand& args)
{
	uint8_t prevVpkMode = *g_VpkMode;
	*g_VpkMode = 0; // need to set to zero to disable file cache temporarily
	Studio_ReloadModels(model_loader, 2);
	*g_VpkMode = prevVpkMode;
};

ON_DLL_LOAD("filesystem_stdio.dll", FileSystemModels, (CModule module))
{
	g_VpkMode = module.Offset(0xe5aa9).RCast<uint8_t*>();
}

ON_DLL_LOAD_CLIENT_RELIESON("engine.dll", EngineModels, ConCommand, (CModule module))
{
	model_loader = module.Offset(0x7c4c20);
	module.Offset(0xCF024).Patch({0xEB, 0x0E});
	Studio_ReloadModels = module.Offset(0xCEEF0).RCast<decltype(Studio_ReloadModels)>();
	RegisterConCommand("reload_models", ConCommand_reload_models, "reload all models", FCVAR_CLIENTDLL);
}
