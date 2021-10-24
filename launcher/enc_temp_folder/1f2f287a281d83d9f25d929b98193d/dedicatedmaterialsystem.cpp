#pragma once
#include "pch.h"
#include "dedicated.h"
#include "dedicatedmaterialsystem.h"
#include "hookutils.h"

void InitialiseDedicatedMaterialSystem(HMODULE baseAddress)
{
	if (!IsDedicated())
		return;

	//while (!IsDebuggerPresent())
	//	Sleep(100);
	
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

	if (DisableDedicatedWindowCreation())
	{
		{
			// materialsystem rpak type registrations
			char* ptr = (char*)baseAddress + 0x22B5;
			TempReadWrite rw(ptr);

			// nop a call that crashes, not needed on dedi
			*ptr = 0x90;
			*(ptr + 1) = (char)0x90;
			*(ptr + 2) = (char)0x90;
			*(ptr + 3) = (char)0x90;
			*(ptr + 4) = (char)0x90;
		}

		// these don't work, they cause game to hang on loading
		{
			// materialsystem rpak type: texture
			char* ptr = (char*)baseAddress + 0x2B00;
			TempReadWrite rw(ptr);

			// make it return 0
			// mov rax,0
			*ptr = 0x48;
			*(ptr + 1) = (char)0xB8;
			*(ptr + 2) = (char)0x00;
			*(ptr + 3) = (char)0x00;
			*(ptr + 4) = (char)0x00;
			*(ptr + 5) = (char)0x00;
			*(ptr + 6) = (char)0x00;
			*(ptr + 7) = (char)0x00;
			*(ptr + 8) = (char)0x00;
			*(ptr + 9) = (char)0x00;

			// ret
			*(ptr + 10) = (char)0xC3;
		}

		{
			// materialsystem rpak type: material
			char* ptr = (char*)baseAddress + 0x50AA0;
			TempReadWrite rw(ptr);

			// make it return 0
			// mov rax,0
			*ptr = 0x48;
			*(ptr + 1) = (char)0xB8;
			*(ptr + 2) = (char)0x00;
			*(ptr + 3) = (char)0x00;
			*(ptr + 4) = (char)0x00;
			*(ptr + 5) = (char)0x00;
			*(ptr + 6) = (char)0x00;
			*(ptr + 7) = (char)0x00;
			*(ptr + 8) = (char)0x00;
			*(ptr + 9) = (char)0x00;

			// ret
			*(ptr + 10) = (char)0xC3;
		}

		{
			// materialsystem rpak type: shader
			char* ptr = (char*)baseAddress + 0x2850;
			TempReadWrite rw(ptr);

			// make it return 0
			// mov rax,0
			*ptr = 0x48;
			*(ptr + 1) = (char)0xB8;
			*(ptr + 2) = (char)0x00;
			*(ptr + 3) = (char)0x00;
			*(ptr + 4) = (char)0x00;
			*(ptr + 5) = (char)0x00;
			*(ptr + 6) = (char)0x00;
			*(ptr + 7) = (char)0x00;
			*(ptr + 8) = (char)0x00;
			*(ptr + 9) = (char)0x00;

			// ret
			*(ptr + 10) = (char)0xC3;
		}

		{
			// some renderthread stuff
			char* ptr = (char*)baseAddress + 0x8C10;
			TempReadWrite rw(ptr);

			// call => nop
			*ptr = (char)0x90;
			*(ptr + 1) = (char)0x90;
		}
	}
}

// rpak pain
struct RpakTypeDefinition
{
	int64_t magic;
	char* longName;

	// more fields but they don't really matter for what we use them for
};

typedef void*(*RegisterRpakTypeType)(RpakTypeDefinition* rpakStruct, unsigned int a1, unsigned int a2);
RegisterRpakTypeType RegisterRpakType;

typedef void(*RegisterMaterialSystemRpakTypes)();

void* RegisterRpakTypeHook(RpakTypeDefinition* rpakStruct, unsigned int a1, unsigned int a2)
{
	// make sure this prints right
	char magicName[5];
	memcpy(magicName, &rpakStruct->magic, 4);
	magicName[4] = 0;

	spdlog::info("rpak type {} {} registered {} {}", magicName, rpakStruct->longName, a1, a2);

	// reregister rpak types that aren't registered on a windowless dedi
	if (IsDedicated() && DisableDedicatedWindowCreation() && rpakStruct->magic == 0x64636C72) // rlcd, this one is registered last
		((RegisterMaterialSystemRpakTypes)((char*)GetModuleHandleA("materialsystem_dx11.dll") + 0x22A0))(); // slightly hellish call

	return RegisterRpakType(rpakStruct, a1, a2);
}

void InitialiseDedicatedRtechGame(HMODULE baseAddress)
{
	spdlog::info("InitialiseDedicatedRtechGame");

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)GetModuleHandleA("rtech_game.dll") + 0x7BE0, &RegisterRpakTypeHook, reinterpret_cast<LPVOID*>(&RegisterRpakType));

	if (!IsDedicated())
		return;


}