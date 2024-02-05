#pragma once

#include "core/math/vector.h"

class IClientTools // : public IBaseInterface
{
public:
	virtual void sub_1805E4960() = 0;
	virtual void sub_1805E4B10() = 0;
	virtual void sub_1805E4C50() = 0;
	virtual void sub_1805E5670() = 0;
	virtual void sub_1805E66C0() = 0;
	virtual void sub_1805E5910() = 0;
	virtual void sub_1805E59A0() = 0;
	virtual void sub_1805E6B10() = 0;
	virtual void sub_1805E8580() = 0;
	virtual void sub_1805E59D0() = 0;
	virtual void sub_1805E57B0() = 0;
	virtual void sub_1805E5860() = 0;
	virtual void sub_1805E55A0() = 0;
	virtual void sub_1805E49C0() = 0;
	virtual void sub_1805E7580() = 0;
	virtual void sub_1805E86A0() = 0;
	virtual void sub_1805E69B0() = 0;
	virtual void sub_1805E4D70() = 0; // IClientTools::DrawSprite
	virtual void* GetLocalPlayer() = 0; // return type unknown probably CBasePlayer*
	virtual bool GetLocalPlayerEyePosition(Vector3& org, QAngle& ang, float& fov) = 0;
	virtual void sub_1805E5960() = 0;
	virtual void sub_1805E5650() = 0;
	virtual void sub_1805E5920() = 0;
	virtual void sub_1805E64E0() = 0;
	virtual void sub_1805E63C0() = 0;
	virtual void sub_1805E64C0() = 0;
	virtual void sub_1805E6520() = 0;
	virtual void sub_1805E6770() = 0;
	virtual void sub_1805E67B0() = 0;
	virtual void sub_1805E67F0() = 0;
	virtual void sub_1805E66A0() = 0;
	virtual void sub_1805E6500() = 0;
	virtual void sub_1805E63B0() = 0;
	virtual void sub_1805E54C0() = 0;
	virtual void sub_1805E53E0() = 0;
	virtual void sub_1805E6D70() = 0;
	virtual void sub_1805E50D0() = 0;
	virtual void sub_1805E65C0() = 0;
};
