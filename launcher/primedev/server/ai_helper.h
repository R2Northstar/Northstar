#pragma once

#include "server/ai_navmesh.h"

dtNavMesh* GetNavMeshForHull(int nHull);

class CAI_Helper
{
public:
	void DrawNavmeshPolys(dtNavMesh* pNavMesh = nullptr);
};

inline CAI_Helper* g_pAIHelper = nullptr;
