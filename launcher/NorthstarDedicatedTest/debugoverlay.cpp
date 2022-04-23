#include "pch.h"
#include "debugoverlay.h"
#include "dedicated.h"
#include "cvar.h"

struct Vector3
{
	float x, y, z;
};

struct QAngle
{
	float x, y, z, w;
};

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
	__int64 m_pUnk;
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

// this is in cvar.h, don't need it here
/*class Color
{
  public:
	Color(int r, int g, int b, int a)
	{
		_color[0] = (unsigned char)r;
		_color[1] = (unsigned char)g;
		_color[2] = (unsigned char)b;
		_color[3] = (unsigned char)a;
	}

  private:
	unsigned char _color[4];
};*/

static HMODULE sEngineModule;

typedef void (*DrawOverlayType)(OverlayBase_t* a1);
DrawOverlayType DrawOverlay;

typedef void (*RenderLineType)(Vector3 v1, Vector3 v2, Color c, bool bZBuffer);
static RenderLineType RenderLine;

typedef void (*RenderBoxType)(Vector3 vOrigin, QAngle angles, Vector3 vMins, Vector3 vMaxs, Color c, bool bZBuffer, bool bInsideOut);
static RenderBoxType RenderBox;

static RenderBoxType RenderWireframeBox;

// engine.dll+0xABCB0
void __fastcall DrawOverlayHook(OverlayBase_t* pOverlay)
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

void InitialiseDebugOverlay(HMODULE baseAddress)
{
	if (IsDedicated())
		return;

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0xABCB0, &DrawOverlayHook, reinterpret_cast<LPVOID*>(&DrawOverlay));

	RenderLine = reinterpret_cast<RenderLineType>((char*)baseAddress + 0x192A70);

	RenderBox = reinterpret_cast<RenderBoxType>((char*)baseAddress + 0x192520);

	RenderWireframeBox = reinterpret_cast<RenderBoxType>((char*)baseAddress + 0x193DA0);

	sEngineModule = baseAddress;

	// not in g_pCVar->FindVar by this point for whatever reason, so have to get from memory
	ConVar* Cvar_enable_debug_overlays = (ConVar*)((char*)baseAddress + 0x10DB0990);
	Cvar_enable_debug_overlays->SetValue(false);
	Cvar_enable_debug_overlays->m_pszDefaultValue = (char*)"0";
	Cvar_enable_debug_overlays->AddFlags(FCVAR_CHEAT);
}