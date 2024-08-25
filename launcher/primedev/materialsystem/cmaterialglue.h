#pragma once

#include "materialsystem/cshaderglue.h"

class CMaterialGlue
{
public:
	void* m_pVFTable;
	char m_unk[8];

	uint64_t m_GUID;

	const char* m_pszName;
	const char* m_pszSurfaceProp;
	const char* m_pszSurfaceProp2;

	CMaterialGlue* m_pDepthShadow;
	CMaterialGlue* m_pDepthPrepass;
	CMaterialGlue* m_pDepthVSM;
	CMaterialGlue* m_pColPass;

	char gap_50[64];

	CShaderGlue* m_pShaderGlue;
	void** m_pTextureHandles;
	void** m_pStreamingTextures;
	int16_t m_iStreamingTextureCount;
	uint8_t m_iSamplersIndices[4];
	int16_t m_iUnknown0;
	char gap_B0[12];

	int16_t aword_BC[2];
	int32_t flags2;
	int32_t flags3;
	int16_t m_iWidth;
	int16_t m_iHeight;
	int16_t m_iUnknown1;
	int16_t m_iUnknown2;

	void** m_pUnkD3D11Ptr;
	void* m_pD3D11Buffer;
	void* qword_E0;
	void* pointer_E8;

	int32_t dword_F0;
	char gap_F4[12];
};
