#include "pch.h"
#include "dedicated/dedicated.h"
#include "core/convar/cvar.h"
#include "core/math/vector.h"

AUTOHOOK_INIT()

enum OverlayType_t
{
	OVERLAY_BOX = 0,
	OVERLAY_SPHERE,
	OVERLAY_LINE,
	OVERLAY_TRIANGLE,
	OVERLAY_SWEPT_BOX,
	OVERLAY_BOX2,
	OVERLAY_CAPSULE
};

struct OverlayBase_t
{
	OverlayBase_t()
	{
		m_Type = OVERLAY_BOX;
		m_nServerCount = -1;
		m_nCreationTick = -1;
		m_flEndTime = 0.0f;
		m_pNextOverlay = NULL;
	}

	OverlayType_t m_Type; // What type of overlay is it?
	int m_nCreationTick; // Duration -1 means go away after this frame #
	int m_nServerCount; // Latch server count, too
	float m_flEndTime; // When does this box go away
	OverlayBase_t* m_pNextOverlay;
	void* m_pUnk;
};

struct OverlayLine_t : public OverlayBase_t
{
	OverlayLine_t()
	{
		m_Type = OVERLAY_LINE;
	}

	Vector3 origin;
	Vector3 dest;
	int r;
	int g;
	int b;
	int a;
	bool noDepthTest;
};

struct OverlayBox_t : public OverlayBase_t
{
	OverlayBox_t()
	{
		m_Type = OVERLAY_BOX;
	}

	Vector3 origin;
	Vector3 mins;
	Vector3 maxs;
	QAngle angles;
	int r;
	int g;
	int b;
	int a;
};

static HMODULE sEngineModule;

typedef void (*RenderLineType)(Vector3 v1, Vector3 v2, Color c, bool bZBuffer);
static RenderLineType RenderLine;
typedef void (*RenderBoxType)(Vector3 vOrigin, QAngle angles, Vector3 vMins, Vector3 vMaxs, Color c, bool bZBuffer, bool bInsideOut);
static RenderBoxType RenderBox;
static RenderBoxType RenderWireframeBox;

// clang-format off
AUTOHOOK(DrawOverlay, engine.dll + 0xABCB0, 
void, __fastcall, (OverlayBase_t * pOverlay))
// clang-format on
{
	EnterCriticalSection((LPCRITICAL_SECTION)((char*)sEngineModule + 0x10DB0A38)); // s_OverlayMutex

	void* pMaterialSystem = *(void**)((char*)sEngineModule + 0x14C675B0);

	switch (pOverlay->m_Type)
	{
	case OVERLAY_LINE:
	{
		OverlayLine_t* pLine = static_cast<OverlayLine_t*>(pOverlay);
		RenderLine(pLine->origin, pLine->dest, Color(pLine->r, pLine->g, pLine->b, pLine->a), pLine->noDepthTest);
	}
	break;
	case OVERLAY_BOX:
	{
		OverlayBox_t* pCurrBox = static_cast<OverlayBox_t*>(pOverlay);
		if (pCurrBox->a > 0)
		{
			RenderBox(
				pCurrBox->origin,
				pCurrBox->angles,
				pCurrBox->mins,
				pCurrBox->maxs,
				Color(pCurrBox->r, pCurrBox->g, pCurrBox->b, pCurrBox->a),
				false,
				false);
		}
		if (pCurrBox->a < 255)
		{
			RenderWireframeBox(
				pCurrBox->origin,
				pCurrBox->angles,
				pCurrBox->mins,
				pCurrBox->maxs,
				Color(pCurrBox->r, pCurrBox->g, pCurrBox->b, 255),
				false,
				false);
		}
	}
	break;
	}
	LeaveCriticalSection((LPCRITICAL_SECTION)((char*)sEngineModule + 0x10DB0A38));
}

ON_DLL_LOAD_CLIENT_RELIESON("engine.dll", DebugOverlay, ConVar, (CModule module))
{
	AUTOHOOK_DISPATCH()

	RenderLine = module.Offset(0x192A70).As<RenderLineType>();
	RenderBox = module.Offset(0x192520).As<RenderBoxType>();
	RenderWireframeBox = module.Offset(0x193DA0).As<RenderBoxType>();
	sEngineModule = reinterpret_cast<HMODULE>(module.m_nAddress);

	// not in g_pCVar->FindVar by this point for whatever reason, so have to get from memory
	ConVar* Cvar_enable_debug_overlays = module.Offset(0x10DB0990).As<ConVar*>();
	Cvar_enable_debug_overlays->SetValue(false);
	Cvar_enable_debug_overlays->m_pszDefaultValue = (char*)"0";
	Cvar_enable_debug_overlays->AddFlags(FCVAR_CHEAT);
}
