#include "pch.h"
#include "core/convar/convar.h"

AUTOHOOK_INIT()

ConVar* Cvar_r_latencyflex;

void (*m_winelfx_WaitAndBeginFrame)();

// clang-format off
AUTOHOOK(OnRenderStart, client.dll + 0x1952C0, 
void, __fastcall, ())
// clang-format on
{
	if (Cvar_r_latencyflex->GetBool() && m_winelfx_WaitAndBeginFrame)
		m_winelfx_WaitAndBeginFrame();

	OnRenderStart();
}

ON_DLL_LOAD_CLIENT_RELIESON("client.dll", LatencyFlex, ConVar, (CModule module))
{
	// Connect to the LatencyFleX service
	// LatencyFleX is an open source vendor agnostic replacement for Nvidia Reflex input latency reduction technology.
	// https://ishitatsuyuki.github.io/post/latencyflex/
	HMODULE pLfxModule;

	if (pLfxModule = LoadLibraryA("latencyflex_layer.dll"))
		m_winelfx_WaitAndBeginFrame =
			reinterpret_cast<void (*)()>(reinterpret_cast<void*>(GetProcAddress(pLfxModule, "lfx_WaitAndBeginFrame")));
	else if (pLfxModule = LoadLibraryA("latencyflex_wine.dll"))
		m_winelfx_WaitAndBeginFrame =
			reinterpret_cast<void (*)()>(reinterpret_cast<void*>(GetProcAddress(pLfxModule, "winelfx_WaitAndBeginFrame")));
	else
	{
		spdlog::info("Unable to load LatencyFleX library, LatencyFleX disabled.");
		return;
	}

	AUTOHOOK_DISPATCH()

	spdlog::info("LatencyFleX initialized.");
	Cvar_r_latencyflex = new ConVar("r_latencyflex", "1", FCVAR_ARCHIVE, "Whether or not to use LatencyFleX input latency reduction.");
}
