#include "materialsystem/cmaterialglue.h"

CMaterialGlue* (*GetMaterialAtCrossHair)();

static void(__fastcall* o_pCC_mat_crosshair_printmaterial_f)(const CCommand& args) = nullptr;
static void __fastcall h_CC_mat_crosshair_printmaterial_f(const CCommand& args)
{
	CMaterialGlue* pMat = GetMaterialAtCrossHair();

	if (!pMat)
	{
		spdlog::error("Not looking at a material!");
		return;
	}

	std::function<void(CMaterialGlue * pGlue, const char* szName)> fnPrintGlue = [](CMaterialGlue* pGlue, const char* szName)
	{
		spdlog::info("|-----------------------------------------------");

		if (!pGlue)
		{
			spdlog::info("├ No reference material for {}", szName);
			return;
		}

		spdlog::info("├ {}", szName);
		spdlog::info("│├── GUID: {:#x}", pGlue->material.guid);
		spdlog::info("│└── Name: {}", pGlue->material.name);
	};

	spdlog::info("────────────────────────────────────────────────────────────");
	spdlog::info("┌ Name: {}", pMat->material.name);
	spdlog::info("├ GUID: {:#x}", pMat->material.guid);
	spdlog::info("├ Width : {}", pMat->material.width);
	spdlog::info("├ Height: {}", pMat->material.height);
	spdlog::info("├ Shaderset: {}", pMat->material.shaderSet->inner.name);

	fnPrintGlue(pMat->material.DepthShadow_ref, "DepthShadow");
	fnPrintGlue(pMat->material.DepthPrepass_ref, "DepthPrepass");
	fnPrintGlue(pMat->material.DepthVSM_ref, "DepthVSM");
	fnPrintGlue(pMat->material.Colpass_ref, "Colpass");

	if (pMat && pMat->material.shaderSet && pMat->material.shaderSet->inner.textureInputCount >= 1 && pMat->material.textureHandles)
	{
		spdlog::info("├ Textures");
		for (size_t slot = 0; slot < pMat->material.shaderSet->inner.textureInputCount + 1; ++slot)
		{
			RpakTextureHeader* currentTexture = pMat->material.textureHandles[slot];

			if (currentTexture && currentTexture->name)
			{
				if (slot == pMat->material.shaderSet->inner.textureInputCount)
					spdlog::info("│└[{}][{:#x}]{}", slot, currentTexture->guid, currentTexture->name);
				else
					spdlog::info("│├[{}][{:#x}]{}", slot, currentTexture->guid, currentTexture->name);
			}
		}
	}
	spdlog::info("├ Glueflags: {:#x}", pMat->material.flags);
	spdlog::info("└ Glueflags2: {:#x}", pMat->material.flags2);
	spdlog::info("────────────────────────────────────────────────────────────");
}

ON_DLL_LOAD("engine.dll", GlMatSysIFace, (CModule module))
{
	o_pCC_mat_crosshair_printmaterial_f = module.Offset(0xB3C40).RCast<decltype(o_pCC_mat_crosshair_printmaterial_f)>();
	HookAttach(&(PVOID&)o_pCC_mat_crosshair_printmaterial_f, (PVOID)h_CC_mat_crosshair_printmaterial_f);

	GetMaterialAtCrossHair = module.Offset(0xB37D0).RCast<CMaterialGlue* (*)()>();
}
