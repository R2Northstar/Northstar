#include "pch.h"
#include "latencyflex.h"
#include "hookutils.h"
#include "convar.h"

typedef void (*OnRenderStartType)();
OnRenderStartType OnRenderStart;

ConVar* Cvar_r_latencyflex;

HMODULE m_lfxModule {};
typedef void (*PFN_lfx_WaitAndBeginFrame)();
PFN_lfx_WaitAndBeginFrame m_lfx_WaitAndBeginFrame {};

void OnRenderStartHook()
{
	// Sleep before next frame as needed to reduce latency.
	if (Cvar_r_latencyflex->GetInt())
	{
		if (m_lfx_WaitAndBeginFrame)
		{
			m_lfx_WaitAndBeginFrame();
		}
	}

	OnRenderStart();
}

void InitialiseLatencyFleX(HMODULE baseAddress)
{
	// Connect to the LatencyFleX service
	// LatencyFleX is an open source vendor agnostic replacement for Nvidia Reflex input latency reduction technology.
	// https://ishitatsuyuki.github.io/post/latencyflex/
	const auto lfxModuleName = "latencyflex_layer.dll";
	const auto lfxModuleNameFallback = "latencyflex_wine.dll";
	auto useFallbackEntrypoints = false;

	// Load LatencyFleX library.
	m_lfxModule = ::LoadLibraryA(lfxModuleName);
	if (m_lfxModule == nullptr && ::GetLastError() == ERROR_MOD_NOT_FOUND)
	{
		spdlog::info("LFX: Primary LatencyFleX library not found, trying fallback.");

		m_lfxModule = ::LoadLibraryA(lfxModuleNameFallback);
		if (m_lfxModule == nullptr)
		{
			if (::GetLastError() == ERROR_MOD_NOT_FOUND)
			{
				spdlog::info("LFX: Fallback LatencyFleX library not found.");
			}
			else
			{
				spdlog::info("LFX: Error loading fallback LatencyFleX library - Code: {}", ::GetLastError());
			}

			return;
		}

		useFallbackEntrypoints = true;
	}
	else if (m_lfxModule == nullptr)
	{
		spdlog::info("LFX: Error loading primary LatencyFleX library - Code: {}", ::GetLastError());
		return;
	}

	m_lfx_WaitAndBeginFrame = reinterpret_cast<PFN_lfx_WaitAndBeginFrame>(reinterpret_cast<void*>(
		GetProcAddress(m_lfxModule, !useFallbackEntrypoints ? "lfx_WaitAndBeginFrame" : "winelfx_WaitAndBeginFrame")));

	spdlog::info("LFX: Initialized.");

	Cvar_r_latencyflex = new ConVar("r_latencyflex", "1", FCVAR_ARCHIVE, "Whether or not to use LatencyFleX input latency reduction.");

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x1952C0, &OnRenderStartHook, reinterpret_cast<LPVOID*>(&OnRenderStart));
}