#pragma once

class CShaderGlue
{
public:
	void* vftable;
};

struct ShaderGlue_inner
{
	const char* name;
	uint64_t flagsMaybe;

	uint16_t resourceBindingSlot;
	uint16_t textureInputCount;
	int16_t shadowSamplerCount;
	uint16_t unkBindingSlot;
	uint16_t unkBindingCount;

	uint8_t bytes_22[6];

	uint64_t unk3[4];

	void* vertexShader;
	void* pixelShader;
};

struct ShaderGlue
{
	void* vtable;
	ShaderGlue_inner inner;
};
