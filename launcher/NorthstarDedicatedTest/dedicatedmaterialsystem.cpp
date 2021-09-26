#pragma once
#include "pch.h"
#include "dedicated.h"
#include "dedicatedmaterialsystem.h"
#include "hookutils.h"

void InitialiseDedicatedMaterialSystem(HMODULE baseAddress)
{
	if (!IsDedicated())
		return;
	
	// not using these for now since they're related to nopping renderthread/gamewindow i.e. very hard
	//{
	//	// function that launches renderthread
	//	char* ptr = (char*)baseAddress + 0x87047;
	//	TempReadWrite rw(ptr);
	//
	//	// make it not launch renderthread
	//	*ptr = (char)0x90;
	//	*(ptr + 1) = (char)0x90;
	//	*(ptr + 2) = (char)0x90;
	//	*(ptr + 3) = (char)0x90;
	//	*(ptr + 4) = (char)0x90;
	//	*(ptr + 5) = (char)0x90;
	//}
	//
	//{
	//	// some function that waits on renderthread job
	//	char* ptr = (char*)baseAddress + 0x87d00;
	//	TempReadWrite rw(ptr);
	//
	//	// return immediately
	//	*ptr = (char)0xC3;
	//}

	{
		// CMaterialSystem::FindMaterial
		char* ptr = (char*)baseAddress + 0x5F0F1;
		TempReadWrite rw(ptr);

		// make the game always use the error material
		*ptr = 0xE9;
		*(ptr + 1) = (char)0x34;
		*(ptr + 2) = (char)0x03;
		*(ptr + 3) = (char)0x00;
	}
}