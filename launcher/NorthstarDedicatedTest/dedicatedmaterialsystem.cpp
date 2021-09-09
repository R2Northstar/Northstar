#pragma once
#include "pch.h"
#include "dedicatedmaterialsystem.h"
#include "hookutils.h"

void InitialiseDedicatedMaterialSystem(HMODULE baseAddress)
{
	{
		// CMaterialSystem::FindMaterial
		char* ptr = (char*)baseAddress + 0x5F0F1;
		TempReadWrite rw(ptr);

		// make the game use the error material
		*ptr = 0xE9;
		*(ptr + 1) = (char)0x34;
		*(ptr + 2) = (char)0x03;
		*(ptr + 3) = (char)0x00;
	}
}