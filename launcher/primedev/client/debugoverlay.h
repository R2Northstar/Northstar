#pragma once

// Render Line
inline void (*RenderLine)(const Vector3& v1, const Vector3& v2, Color c, bool bZBuffer);

// Render box
inline void (*RenderBox)(
	const Vector3& vOrigin, const QAngle& angles, const Vector3& vMins, const Vector3& vMaxs, Color c, bool bZBuffer, bool bInsideOut);

// Render wireframe box
inline void (*RenderWireframeBox)(
	const Vector3& vOrigin, const QAngle& angles, const Vector3& vMins, const Vector3& vMaxs, Color c, bool bZBuffer, bool bInsideOut);

// Render swept box
inline void (*RenderWireframeSweptBox)(
	const Vector3& vStart, const Vector3& vEnd, const QAngle& angles, const Vector3& vMins, const Vector3& vMaxs, Color c, bool bZBuffer);

// Render Triangle
inline void (*RenderTriangle)(const Vector3& p1, const Vector3& p2, const Vector3& p3, Color c, bool bZBuffer);

// Render Axis
inline void (*RenderAxis)(const Vector3& vOrigin, float flScale, bool bZBuffer);

// I dont know
inline void (*RenderUnknown)(const Vector3& vUnk, float flUnk, bool bUnk);

// Render Sphere
inline void (*RenderSphere)(const Vector3& vCenter, float flRadius, int nTheta, int nPhi, Color c, bool bZBuffer);
