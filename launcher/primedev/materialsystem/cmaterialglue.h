#pragma once

#include "materialsystem/cshaderglue.h"
#include <d3d11.h>
class RpakTextureHeader // Expected size: 0x130
{
public:
	uint64_t guid;
	const char* name;
	uint16_t width;
	uint16_t height;
	int16_t depth;
	uint16_t dxgiFormat;
	uint32_t dataSize;
	uint8_t compressionType;
	uint8_t optStreamedMipCount;
	uint8_t arraySize;
	uint8_t layerCount;
	uint8_t mipFlags;
	uint8_t permanentMipCount;
	uint8_t streamedMipCount;
	uint8_t unk[13];
	int64_t numPixels;
	uint16_t unknownWord38;
	uint8_t unknownByte3A;
	uint8_t unknownByte3B;
	uint32_t unknownDword3C;
	uint32_t unknownDword40;
	uint32_t unknownDword44;
	float transform[16];
	uint64_t unknownQword88;
	uint64_t unknownQword90;
	uint32_t unknownArray98[16];
	uint32_t unknownArrayD8[16];
	ID3D11Resource* d3d11Resource;
	ID3D11ShaderResourceView* shaderResourceView;
	uint8_t unknownByte128;
	uint8_t padding[7];
};

struct CBufUberStatic // sizeof = 0xE0
{
	float c_uv1RotScaleX[2]; // 0x00
	float c_uv1RotScaleY[2]; // 0x08
	float c_uv1Translate[2]; // 0x10
	float c_uv2RotScaleX[2]; // 0x18
	float c_uv2RotScaleY[2]; // 0x20
	float c_uv2Translate[2]; // 0x28
	float c_uv3RotScaleX[2]; // 0x30
	float c_uv3RotScaleY[2]; // 0x38
	float c_uv3Translate[2]; // 0x40
	float c_uvDistortionIntensity[2]; // 0x48
	float c_uvDistortion2Intensity[2]; // 0x50
	float c_fogColorFactor; // 0x58
	float c_layerBlendRamp; // 0x5C
	float c_albedoTint[3]; // 0x60
	float c_opacity; // 0x6C
	float c_useAlphaModulateSpecular; // 0x70
	float c_alphaEdgeFadeExponent; // 0x74
	float c_alphaEdgeFadeInner; // 0x78
	float c_alphaEdgeFadeOuter; // 0x7C
	float c_useAlphaModulateEmissive; // 0x80
	float c_emissiveEdgeFadeExponent; // 0x84
	float c_emissiveEdgeFadeInner; // 0x88
	float c_emissiveEdgeFadeOuter; // 0x8C
	float c_alphaDistanceFadeScale; // 0x90
	float c_alphaDistanceFadeBias; // 0x94
	float c_alphaTestReference; // 0x98
	float c_aspectRatioMulV; // 0x9C
	float c_emissiveTint[3]; // 0xA0
	float c_shadowBias; // 0xAC
	float c_tsaaDepthAlphaThreshold; // 0xB0
	float c_tsaaMotionAlphaThreshold; // 0xB4
	float c_tsaaMotionAlphaRamp; // 0xB8
	uint32_t c_tsaaResponsiveFlag; // 0xBC
	float c_dofOpacityLuminanceScale; // 0xC0
	float c_glitchStrength; // 0xC4
	float c_padding[2]; // 0xC8
	float c_perfGloss; // 0xD0
	float c_perfSpecColor[3]; // 0xD4
};

class CMaterialGlue;

class CMaterialGlue_short
{
public:
	uint64_t guid;
	const char* name;
	uint64_t* surfaceProps[2];
	CMaterialGlue* DepthShadow_ref;
	CMaterialGlue* DepthPrepass_ref;
	CMaterialGlue* DepthVSM_ref;
	CMaterialGlue* Colpass_ref;
	uint8_t gap_50[64];
	ShaderGlue* shaderSet;
	RpakTextureHeader** textureHandles;
	RpakTextureHeader** streamingTextures;
	int16_t streamingTextureCount;
	uint8_t samplersIndices[4];
	int16_t unknown;
	uint8_t gap_B0[12];
	uint16_t unknownWord[2];
	uint32_t flags;
	uint32_t flags2;
	uint16_t width;
	uint16_t height;
	uint8_t gap_CC[2];
	uint16_t word_CE;
	void** pointer_D0;
	CBufUberStatic* cbufUberStatic;
	ID3D11Buffer* buffer;
	uint32_t* atlasBufferIndices;
	uint32_t dword_F0;
	uint8_t gap_F4[12];
};

class CMaterialGlue
{
public:
	void* m_pVFTable;
	char m_unk[8];
	CMaterialGlue_short material;
};
