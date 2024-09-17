#include "dedicated.h"
#include "core/tier0.h"

static HRESULT(__stdcall* o_pD3D11CreateDevice)(
	void* pAdapter,
	int DriverType,
	HMODULE Software,
	UINT Flags,
	int* pFeatureLevels,
	UINT FeatureLevels,
	UINT SDKVersion,
	void** ppDevice,
	int* pFeatureLevel,
	void** ppImmediateContext) = nullptr;
static HRESULT __stdcall h_D3D11CreateDevice(
	void* pAdapter,
	int DriverType,
	HMODULE Software,
	UINT Flags,
	int* pFeatureLevels,
	UINT FeatureLevels,
	UINT SDKVersion,
	void** ppDevice,
	int* pFeatureLevel,
	void** ppImmediateContext)
{
	// note: this is super duper temp pretty much just messing around with it
	// does run surprisingly well on dedi for a software driver tho if you ignore the +1gb ram usage at times, seems like dedi doesn't
	// really call gpu much even with renderthread still being a thing will be using this hook for actual d3d stubbing and stuff later

	// note: this has been succeeded by the d3d11 and gfsdk stubs, and is only being kept around for posterity and as a fallback option
	if (CommandLine()->CheckParm("-softwared3d11"))
		DriverType = 5; // D3D_DRIVER_TYPE_WARP

	return o_pD3D11CreateDevice(
		pAdapter, DriverType, Software, Flags, pFeatureLevels, FeatureLevels, SDKVersion, ppDevice, pFeatureLevel, ppImmediateContext);
}

ON_DLL_LOAD_DEDI("materialsystem_dx11.dll", DedicatedServerMaterialSystem, (CModule module))
{
	o_pD3D11CreateDevice = module.Offset(0xD9A0E).RCast<decltype(o_pD3D11CreateDevice)>();
	HookAttach(&(PVOID&)o_pD3D11CreateDevice, (PVOID)h_D3D11CreateDevice);

	// CMaterialSystem::FindMaterial
	// make the game always use the error material
	module.Offset(0x5F0F1).Patch("E9 34 03 00");
}
