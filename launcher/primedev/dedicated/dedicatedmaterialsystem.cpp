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

	if (CommandLine()->CheckParm("-noshaderapi"))
	{
		// Initializes the texture/sampler cache, default bindings, and HBAO context.
		// Keep the software-side resource tables, but skip their D3D-backed initialization.
		module.Offset(0x29590).Patch("C3 90 90 90 90");

		// Initializes the transient vertex/index streaming-buffer pools.
		// Keep the surrounding ShaderAPI state initialization, but do not allocate or map D3D buffers.
		module.Offset(0x19BE0).Patch("C3 90 90 90 90");

		// Initializes GPU query pools and renderer-owned scratch textures/buffers.
		// These resources have no software consumers on a dedicated server and require a D3D device.
		module.Offset(0x2C000).Patch("C3 90 90 90 90");

		// Initializes the shader-set global constant buffers and sampler-state table.
		// Shader-set RPak registration remains active; only its global D3D resources are omitted.
		module.Offset(0x505D0).Patch("C3 90 90 90 90");

		// RPak "txtr" asset load callback.
		// Parse and register the texture metadata, then skip D3D texture and shader-resource-view creation.
		module.Offset(0x2B28).Patch("E9 5A 02 00 00");

		// RPak "matl" asset constructor callback.
		// Construct and register the CMaterialGlue asset without its D3D constant buffer.
		module.Offset(0x50AD4).Patch("EB 48");

		// RPak "shdr" asset load callback for pixel, vertex, geometry, and compute shaders.
		// Keep the shader assets registered without creating their D3D shader objects.
		module.Offset(0x2850).Patch("C3 90 90 90 90");

		// These three functions create blend, depth-stencil, and rasterizer states respectively.
		// Preserve the shader-set state caches while returning null D3D handles for these GPU-only objects.
		module.Offset(0x33350).Patch("33 C0 C3 90 90 90 90 90 90");
		module.Offset(0x33430).Patch("33 C0 C3 90");
		module.Offset(0x33520).Patch("33 C0 C3 90");

		// Decompresses dynamic .vcs bytecode and creates the requested D3D shader variants.
		// Treat the bytecode as loaded successfully because no caller on the dedicated server consumes the D3D objects.
		module.Offset(0x30D00).Patch("B8 01 00 00 00 C3 90");

		// Maps and updates the two global shader-set constant buffers.
		// Skip these uploads because the shader-set resource initializer deliberately leaves both buffers uncreated.
		module.Offset(0x50BF0).Patch("C3 90 90");

		// These three functions are the 1D, 2D, and 3D runtime texture hardware constructors.
		// Keep the caller-created texture IDs and metadata without creating D3D textures or views.
		module.Offset(0x274C0).Patch("C3 90 90 90 90");
		module.Offset(0x277C0).Patch("C3 90 90 90 90");
		module.Offset(0x28020).Patch("C3 90 90");

		// Rebuilds and binds the GPU buffer containing lightmap-page data.
		// Preserve the CPU lightmap tables maintained by its caller, but skip creation and binding of this GPU-only buffer.
		module.Offset(0x22150).Patch("C3 90 90 90 90");

		// Tests the active device feature level against D3D_FEATURE_LEVEL_10_0.
		// Report the low-capability path without querying the null D3D device.
		module.Offset(0x11E80).Patch("B0 01 C3 90");

		// Likely the ShaderAPI/ShaderDevice SetMode path from Source SDK.
		// Keep window/mode bookkeeping and interface setup, but skip swap-chain and device-resource initialization.
		module.Offset(0x16CC5).Patch("E9 0C 01 00 00 90 90 90 90 90 90");

		// Likely InitClientRenderTargets: creates the water, camera, shadow, and frame render targets.
		// Dedicated servers do not need the named render-target set or its render-context bindings.
		module.Offset(0x95EF0).Patch("C3 90 90 90 90");

		// Likely CMaterialSystem::CreateStandardTextures: creates black, white, flat-normal, and debug textures.
		// Leave this standard/debug texture set uninitialized on a null device; do not set its initialized flag or run shutdown releases.
		module.Offset(0x594B0).Patch("C3 90 90");

		// Likely the ShaderAPI state-cache shutdown/reset path.
		// Skip its three hardware-state unbinds on the null ShaderAPI interface, then retain all CPU cache clearing and guarded releases.
		module.Offset(0x33C3A).Patch("EB 3D 90 90 90 90 90");

		// Shuts down the transient vertex/index streaming-buffer pools omitted above.
		// None of its GPU resources or backing containers were constructed, so its unguarded releases must also be omitted.
		module.Offset(0x1A1B0).Patch("C3 90 90 90 90");
	}

	// CMaterialSystem::FindMaterial
	// make the game always use the error material
	module.Offset(0x5F0F1).Patch("E9 34 03 00");
}
