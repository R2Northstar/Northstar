#pragma once

#include <intrin.h>
#include <cstddef>
#include <stdint.h>
#include <cmath>

typedef unsigned int assetHandle;

struct RuiGlobals
{
	BYTE gap_0[60];
	float localPlayerPos[3];
	BYTE gap_48[72];
	uint64_t qword_90;
	float currentTime;
	BYTE gap_9C[4];
	int dword_A0;
	int isConsole;
	int dword_A8;
	int dword_AC;
	int dword_B0;
	int dword_B4;
	float float_B8;
	float float_BC;
	float float_C0;
	int dword_C4;
	float float_C8;
	float float_CC;
	DWORD dword_D0;
	DWORD dword_D4;
	DWORD dword_D8;
	DWORD dword_DC;
	float float_E0;
	DWORD dword_E4;
};

struct RuiInstance
{
	void* header; // original type RuiHeader
	float canvasWidth;
	float canvasHeight;
	float canvasWidthRatio;
	float canvasHeightRatio;
	void* v1; // original type struct_v1
	__int64 createTimeStamp;
	BYTE byte_28;
	BYTE error;
	BYTE gap_2A[14];
	void* pvoid_38; // original type ruiUnknown2
	char dataValues[1];
};

struct RuiFunctions_t
{
	void(__fastcall* setNoRender)(RuiInstance* a1);
	void(__fastcall* setError)(RuiInstance* a1);
	void(__fastcall* SetErrorWithReason)(RuiInstance* a1, const char* a2);
	__m128*(__fastcall* GetTransformSize)(RuiInstance* a1);
	__m128(__fastcall* GetTextSize)(RuiInstance* a1, unsigned int a2);
	__m128(__fastcall* unknown_5)(RuiInstance* a1, int a2, int a3);
	void(__fastcall* executeTransform)(RuiInstance* a1, int a2);
	const char* (*printf)(RuiInstance* a1, const char* format, ...);
	const char* (*localize)(RuiInstance* a1, const char* format, ...);
	const char*(__fastcall* toUpper)(RuiInstance* a1, const char* a2);
	__m128(__fastcall* unknown_10)(__m128* a1);
	__m128(__fastcall* unknown_11)(float a1);
	float(__fastcall* randomFloat)(RuiInstance* a1);
	__int64(__fastcall* unknown_13)(__int64 a1, __int64 a2, __m128* a3);
	__m128(__fastcall* unknown_14)(__int64 a1);
	int(__fastcall* LoadAsset)(RuiInstance* a1, const char* assetPath);
	const char*(__fastcall* unknown_16)(RuiInstance* a1, int a2);
	float(__fastcall* unknown_17)(RuiInstance* a1, __int64 a2, float a3);
	__m128(__fastcall* unknown_18)(__int64 a1, __int64 a2, float a3);
	__m128(__fastcall* unknown_19)(__int64 a1, __int64 a2, __int64 a3);
	__m128(__fastcall* unknown_20)(__int64 a1, __int64 a2, __int64 a3);
};
