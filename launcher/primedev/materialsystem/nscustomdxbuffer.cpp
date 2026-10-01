#include <atomic>
#include <d3d11.h>
#include <map>
#include <mutex>
#include <winternl.h>
#include <cctype>
#include <string>
#include <cstdint>
#include "core/filesystem/rpakfilesystem.h"
#include "cmaterialglue.h"

static ID3D11DeviceContext** DeviceContext;
static ID3D11Device** D3D11Device_14E8DD0;

struct Ns_Constant_Buffer
{
	float data[320];
};

struct MaterialTextureMappings
{

	std::array<uint64_t, 60> slots;
};

AUTOHOOK_INIT()

static Ns_Constant_Buffer NSCustomDXBuffer;
static std::mutex NSCustomDXBufferMutex;

// map to later on associate guid > buffer
static std::map<uint64_t, Ns_Constant_Buffer> NSCustomBuffersPerMaterial = {};
static std::map<uint64_t, MaterialTextureMappings> NSMaterialTextureSlotBindings = {};
static std::unordered_set<uint64_t> NSRegisteredCustomBufferMaterials = {};
static std::unordered_set<uint64_t> NSRegisteredTextureOverrides = {};

AUTOHOOK(SUB_511D0, materialsystem_dx11.dll + 0x511D0, __int64, __fastcall, (__int64 a1, __int64 a2, __int64 a3, CMaterialGlue_short* a4))
{
	CMaterialGlue_short* internal_logic_material = a4;

	int64_t subResult = SUB_511D0(a1, a2, a3, internal_logic_material);

	if (!DeviceContext || !D3D11Device_14E8DD0 || !*DeviceContext || !*D3D11Device_14E8DD0)
		return subResult;

	// bind textures to slots if existing
	if (NSMaterialTextureSlotBindings.contains(internal_logic_material->guid))
	{

		auto& mappings = NSMaterialTextureSlotBindings[internal_logic_material->guid];

		for (size_t slot = 0; slot < mappings.slots.size(); ++slot)
		{
			uint64_t textureGUID = mappings.slots[slot];

			if (textureGUID == 0)
				continue;

			__int64 texturePointer = g_pakLoadApi->GetAssetByHash(textureGUID);
			if (!texturePointer)
				continue;

			RpakTextureHeader* TextureHeader = (RpakTextureHeader*)texturePointer;
			ID3D11ShaderResourceView* TextureSRV = TextureHeader->shaderResourceView;

			if (!TextureSRV)
				continue;

			(*DeviceContext)->PSSetShaderResources(slot, 1, &TextureSRV);
		}
	}

	// bind custom buffer when flag is 0x04089901 in rpak mat
	if (NSRegisteredCustomBufferMaterials.contains(internal_logic_material->guid))
	{

		D3D11_BUFFER_DESC desc {};
		desc.ByteWidth = sizeof(Ns_Constant_Buffer);
		desc.Usage = D3D11_USAGE_DYNAMIC;
		desc.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
		desc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
		desc.StructureByteStride = 0;
		desc.MiscFlags = 0;

		static ID3D11Buffer* resource = nullptr;
		if (!resource)
		{
			if (HRESULT res = (*D3D11Device_14E8DD0)->CreateBuffer(&desc, 0, &resource); !SUCCEEDED(res))
			{
				spdlog::error("Failed to create buffer {:X}", (uint32_t)res);
				return subResult;
			}
		}

		D3D11_MAPPED_SUBRESOURCE mappedSubResource;
		if (!SUCCEEDED((*DeviceContext)->Map(resource, 0, D3D11_MAP_WRITE_DISCARD, 0, &mappedSubResource)))
		{
			spdlog::error("failed to map data");
			return subResult;
		}

		auto pData = (Ns_Constant_Buffer*)mappedSubResource.pData;

		std::lock_guard<std::mutex> lock(NSCustomDXBufferMutex);

		memcpy(pData, &NSCustomBuffersPerMaterial[internal_logic_material->guid], sizeof(Ns_Constant_Buffer));

		(*DeviceContext)->Unmap(resource, 0);
		(*DeviceContext)->PSSetConstantBuffers(4, 1, &resource);
	}
	return subResult;
}

bool isValidMaterialGUID(const std::string& str)
{
	// Must start with "0x" or "0X"
	if (str.size() != 18 || str[0] != '0' || (str[1] != 'x' && str[1] != 'X'))
		return false;

	// Must contain exactly 16 hex digits after 0x
	for (size_t i = 2; i < str.size(); ++i)
	{
		if (!std::isxdigit(static_cast<unsigned char>(str[i])))
			return false;
	}

	return true;
}

SQRESULT NSRegisterCustomDXBufferForGUID(HSQUIRRELVM sqvm)
{

	auto rPakMaterialGUIDString = (g_pSquirrel[ScriptContext::CLIENT]->getstring(sqvm, 1));
	uint64_t rPakMaterialGUID = std::stoull(rPakMaterialGUIDString, nullptr, 16);

	__int64 AssetFromGUID = g_pakLoadApi->GetAssetByHash(rPakMaterialGUID);

	if (!AssetFromGUID)
	{
		g_pSquirrel[ScriptContext::CLIENT]->raiseerror(
			sqvm, fmt::format("Asset with GUID {} Doesnt Exist", rPakMaterialGUIDString).c_str());
		return SQRESULT_ERROR;
	}

	// we need to add 16 to the pointer, matglueshort is matglue without the first 16 bytes. GetAssetByHash returns a pointer to the full
	auto* base = reinterpret_cast<uint8_t*>(AssetFromGUID);
	auto* GUIDMaterialGlue_short = reinterpret_cast<CMaterialGlue_short*>(base + 16);

	if (!NSRegisteredCustomBufferMaterials.contains(GUIDMaterialGlue_short->guid))
	{
		NS::log::SCRIPT_CL->info("Registered GUID: {} to use the NSCustomDXBuffer system", GUIDMaterialGlue_short->guid);

		NSRegisteredCustomBufferMaterials.insert(GUIDMaterialGlue_short->guid);
	}
	else
	{
		NS::log::SCRIPT_CL->warn(
			"Attempted to register GUID: {} to the NSCustomDXBuffer system, GUID was already registered", GUIDMaterialGlue_short->guid);
	}
	return SQRESULT_NULL;
}

SQRESULT NSDeregisterCustomDXBufferForGUID(HSQUIRRELVM sqvm)
{

	auto rPakMaterialGUIDString = (g_pSquirrel[ScriptContext::CLIENT]->getstring(sqvm, 1));
	uint64_t rPakMaterialGUID = std::stoull(rPakMaterialGUIDString, nullptr, 16);

	__int64 AssetFromGUID = g_pakLoadApi->GetAssetByHash(rPakMaterialGUID);

	if (!AssetFromGUID)
	{
		g_pSquirrel[ScriptContext::CLIENT]->raiseerror(
			sqvm, fmt::format("Asset with GUID {} Doesnt Exist", rPakMaterialGUIDString).c_str());
		return SQRESULT_ERROR;
	}

	// we need to add 16 to the pointer, matglueshort is matglue without the first 16 bytes. GetAssetByHash returns a pointer to the full
	auto* base = reinterpret_cast<uint8_t*>(AssetFromGUID);
	auto* GUIDMaterialGlue_short = reinterpret_cast<CMaterialGlue_short*>(base + 16);

	if (NSRegisteredCustomBufferMaterials.contains(GUIDMaterialGlue_short->guid))
	{
		NS::log::SCRIPT_CL->info("Deregistered GUID: {} from the NSCustomDXBuffer system", GUIDMaterialGlue_short->guid);

		NSRegisteredCustomBufferMaterials.erase(GUIDMaterialGlue_short->guid);
	}
	else
	{
		NS::log::SCRIPT_CL->warn(
			"Attempted to deregister GUID: {} from the NSCustomDXBuffer system, GUID was not registered", GUIDMaterialGlue_short->guid);
	}
	return SQRESULT_NULL;
}

SQRESULT NSUpdateCustomDXBufferForGUID(HSQUIRRELVM sqvm)
{

	// get the guid as a string to later conv
	auto rPakMaterialGUIDString = (g_pSquirrel[ScriptContext::CLIENT]->getstring(sqvm, 1));

	std::vector<float> NSCustomBufferVector;
	SQArray* NSCustomBufferDataArray = sqvm->_stackOfCurrentFunction[2]._VAL.asArray;

	for (int vIdx = 0; vIdx < NSCustomBufferDataArray->_usedSlots; ++vIdx)
	{
		if (NSCustomBufferDataArray->_values[vIdx]._Type == OT_FLOAT)
		{
			NSCustomBufferVector.push_back(NSCustomBufferDataArray->_values[vIdx]._VAL.asFloat);
		}
	}

	const std::string& guidString = rPakMaterialGUIDString;

	if (!isValidMaterialGUID(guidString))
	{
		g_pSquirrel[ScriptContext::CLIENT]->raiseerror(
			sqvm, fmt::format("Malformed Material GUID", (NSCustomBufferDataArray->_usedSlots) * 4, sizeof(Ns_Constant_Buffer)).c_str());
		return SQRESULT_ERROR;
	}

	uint64_t rPakMaterialGUID = std::stoull(rPakMaterialGUIDString, nullptr, 16);

	std::lock_guard<std::mutex> lock(NSCustomDXBufferMutex);

	if ((NSCustomBufferDataArray->_usedSlots) * 4 > sizeof(Ns_Constant_Buffer))
	{
		g_pSquirrel[ScriptContext::CLIENT]->raiseerror(
			sqvm,
			fmt::format(
				"Size of Squirrel array exceeds NSCustomDXBuffer size\n\nSquirrel "
				"array in bytes: {}\nNSCustomDXBuffer in bytes: {}",
				(NSCustomBufferDataArray->_usedSlots) * 4,
				sizeof(Ns_Constant_Buffer))
				.c_str());
		return SQRESULT_ERROR;
	}
	for (int vIdx = 0; vIdx < NSCustomBufferVector.size(); ++vIdx)
	{
		// assign buffer to the map using the guid as key
		NSCustomBuffersPerMaterial[rPakMaterialGUID].data[vIdx] = NSCustomBufferVector.at(vIdx);
	}
	return SQRESULT_NULL;
}

SQRESULT NSBindTextureToMaterial(HSQUIRRELVM sqvm)
{

	auto rPakMaterialGUIDString = (g_pSquirrel[ScriptContext::CLIENT]->getstring(sqvm, 1));
	auto rPakTextureGUIDString = (g_pSquirrel[ScriptContext::CLIENT]->getstring(sqvm, 2));
	auto rPakShaderSlotBindingInt = (g_pSquirrel[ScriptContext::CLIENT]->getinteger(sqvm, 3));

	uint64_t rPakMaterialGUID = std::stoull(rPakMaterialGUIDString, nullptr, 16);
	__int64 MatAssetFromGUID = g_pakLoadApi->GetAssetByHash(rPakMaterialGUID);

	if (rPakShaderSlotBindingInt > 60)
	{
		g_pSquirrel[ScriptContext::CLIENT]->raiseerror(sqvm, fmt::format("TextureOverrides only support 30 custom bindings").c_str());
		return SQRESULT_ERROR;
	}

	if (!MatAssetFromGUID)
	{
		g_pSquirrel[ScriptContext::CLIENT]->raiseerror(
			sqvm, fmt::format("Material with GUID {} Doesnt Exist", rPakMaterialGUIDString).c_str());
		return SQRESULT_ERROR;
	}

	auto* base = reinterpret_cast<uint8_t*>(MatAssetFromGUID);
	auto* GUIDMaterialGlue_short = reinterpret_cast<CMaterialGlue_short*>(base + 16);

	if (!rPakTextureGUIDString == 0)
	{
		uint64_t rPakTextureGUID = std::stoull(rPakTextureGUIDString, nullptr, 16);
		__int64 TexAssetFromGUID = g_pakLoadApi->GetAssetByHash(rPakTextureGUID);

		if (!TexAssetFromGUID)
		{
			g_pSquirrel[ScriptContext::CLIENT]->raiseerror(
				sqvm, fmt::format("Texture with GUID {} Doesnt Exist", rPakTextureGUIDString).c_str());
			return SQRESULT_ERROR;
		}
		NSMaterialTextureSlotBindings[GUIDMaterialGlue_short->guid].slots[rPakShaderSlotBindingInt] = rPakTextureGUID;
	}
	else
		NSMaterialTextureSlotBindings[GUIDMaterialGlue_short->guid].slots[rPakShaderSlotBindingInt] = 0;

	return SQRESULT_NULL;
}

ON_DLL_LOAD_CLIENT("materialsystem_dx11.dll", SUB_511D0, (CModule module))
{
	AUTOHOOK_DISPATCH_MODULE(materialsystem_dx11.dll)

	DeviceContext = module.Offset(0x14E8DD8).RCast<ID3D11DeviceContext**>();
	D3D11Device_14E8DD0 = module.Offset(0x14E8DD0).RCast<ID3D11Device**>();

	g_pSquirrel[ScriptContext::CLIENT]->AddFuncRegistration(
		"void",
		"NSUpdateCustomDXBufferForGUID",
		"string rPakMaterialGUID array NSCustomBufferPerMaterialData",
		"",
		NSUpdateCustomDXBufferForGUID);

	g_pSquirrel[ScriptContext::CLIENT]->AddFuncRegistration(
		"void", "NSRegisterCustomDXBufferForGUID", "string rPakMaterialGUID", "", NSRegisterCustomDXBufferForGUID);

	g_pSquirrel[ScriptContext::CLIENT]->AddFuncRegistration(
		"void", "NSDeregisterCustomDXBufferForGUID", "string rPakMaterialGUID", "", NSDeregisterCustomDXBufferForGUID);

	g_pSquirrel[ScriptContext::CLIENT]->AddFuncRegistration(
		"void",
		"NSBindTextureToMaterial",
		"string rPakMaterialGUID string rPakTextureGUID int shaderBindingSlot",
		"",
		NSBindTextureToMaterial);
}
