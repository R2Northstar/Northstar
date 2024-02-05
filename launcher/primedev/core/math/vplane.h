#pragma once

typedef int SideType;

// Used to represent sides of things like planes.
#define SIDE_FRONT 0
#define SIDE_BACK 1
#define SIDE_ON 2

#define VP_EPSILON 0.01f

class VPlane
{
public:
	VPlane();
	VPlane(const Vector3& vNormal, float dist);
	VPlane(const Vector3& vPoint, const QAngle& ang);

	void Init(const Vector3& vNormal, float dist);

	// Return the distance from the point to the plane.
	float DistTo(const Vector3& vVec) const;

	// Copy.
	VPlane& operator=(const VPlane& thePlane);

	// Returns SIDE_ON, SIDE_FRONT, or SIDE_BACK.
	// The epsilon for SIDE_ON can be passed in.
	SideType GetPointSide(const Vector3& vPoint, float sideEpsilon = VP_EPSILON) const;

	// Returns SIDE_FRONT or SIDE_BACK.
	SideType GetPointSideExact(const Vector3& vPoint) const;

	// Get a point on the plane (normal*dist).
	Vector3 GetPointOnPlane() const;

	// Snap the specified point to the plane (along the plane's normal).
	Vector3 SnapPointToPlane(const Vector3& vPoint) const;

public:
	Vector3 m_Normal;
	float m_Dist;
};

//-----------------------------------------------------------------------------
// Inlines.
//-----------------------------------------------------------------------------
inline VPlane::VPlane() {}

inline VPlane::VPlane(const Vector3& vNormal, float dist)
{
	m_Normal = vNormal;
	m_Dist = dist;
}

inline VPlane::VPlane(const Vector3& vPoint, const QAngle& ang)
{
	m_Normal = ang.GetNormal();
	m_Dist = vPoint.x * m_Normal.x + vPoint.y * m_Normal.y + vPoint.z * m_Normal.z;
}

inline void VPlane::Init(const Vector3& vNormal, float dist)
{
	m_Normal = vNormal;
	m_Dist = dist;
}

inline float VPlane::DistTo(const Vector3& vVec) const
{
	return vVec.Dot(m_Normal) - m_Dist;
}

inline VPlane& VPlane::operator=(const VPlane& thePlane)
{
	m_Normal = thePlane.m_Normal;
	m_Dist = thePlane.m_Dist;
	return *this;
}

inline Vector3 VPlane::GetPointOnPlane() const
{
	return m_Normal * m_Dist;
}

inline Vector3 VPlane::SnapPointToPlane(const Vector3& vPoint) const
{
	return vPoint - m_Normal * DistTo(vPoint);
}

inline SideType VPlane::GetPointSide(const Vector3& vPoint, float sideEpsilon) const
{
	float fDist;

	fDist = DistTo(vPoint);
	if (fDist >= sideEpsilon)
		return SIDE_FRONT;
	else if (fDist <= -sideEpsilon)
		return SIDE_BACK;
	else
		return SIDE_ON;
}

inline SideType VPlane::GetPointSideExact(const Vector3& vPoint) const
{
	return DistTo(vPoint) > 0.0f ? SIDE_FRONT : SIDE_BACK;
}
