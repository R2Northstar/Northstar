#pragma once

#include "bits.h"
#include "math_pfns.h"

#include <cmath>

#define DEG2RAD(a) (a) * (3.14159265358979323846f / 180.0f)
#define RAD2DEG(a) (a) * (180.0f / 3.14159265358979323846f)

class Vector3
{
public:
	float x, y, z;

	Vector3(float _x, float _y, float _z) : x(_x), y(_y), z(_z) {}
	Vector3(float _f) : x(_f), y(_f), z(_f) {}
	Vector3() : x(0.0f), y(0.0f), z(0.0f) {}

	inline bool IsValid() { return IsFinite(x) && IsFinite(y) && IsFinite(z); }

	inline void Init(float fX = 0.0f, float fY = 0.0f, float fZ = 0.0f)
	{
		x = fX;
		y = fY;
		z = fZ;
	}

	inline float Length() { return FastSqrt(x * x + y * y + z * z); }

	inline float DistTo(const Vector3& vOther)
	{
		Vector3 vDelta;
		vDelta.x = vOther.x - x;
		vDelta.y = vOther.y - y;
		vDelta.z = vOther.z - z;

		return vDelta.Length();
	}

	float Dot(const Vector3& vOther) const { return x * vOther.x + y * vOther.y + z * vOther.z; }

	// Cross product between two vectors.
	Vector3 Cross(const Vector3& vOther) const;

	void Normalize();

	bool operator==(const Vector3& v) const;
	bool operator!=(const Vector3& v) const;

	FORCEINLINE Vector3& operator+=(const Vector3& v);
	FORCEINLINE Vector3& operator-=(const Vector3& v);
	FORCEINLINE Vector3& operator*=(const Vector3& v);
	FORCEINLINE Vector3& operator*=(float s);
	FORCEINLINE Vector3& operator/=(const Vector3& v);
	FORCEINLINE Vector3& operator/=(float s);
	FORCEINLINE Vector3& operator+=(float fl); ///< broadcast add
	FORCEINLINE Vector3& operator-=(float fl);

	// arithmetic operations
	Vector3 operator-(void) const;

	Vector3 operator+(const Vector3& v) const;
	Vector3 operator-(const Vector3& v) const;
	Vector3 operator*(const Vector3& v) const;
	Vector3 operator/(const Vector3& v) const;
	Vector3 operator*(float fl) const;
	Vector3 operator/(float fl) const;
};

FORCEINLINE void VectorAdd(const Vector3& a, const Vector3& b, Vector3& result);
FORCEINLINE void VectorSubtract(const Vector3& a, const Vector3& b, Vector3& result);
FORCEINLINE void VectorMultiply(const Vector3& a, float b, Vector3& result);
FORCEINLINE void VectorMultiply(const Vector3& a, const Vector3& b, Vector3& result);
FORCEINLINE void VectorDivide(const Vector3& a, float b, Vector3& result);
FORCEINLINE void VectorDivide(const Vector3& a, const Vector3& b, Vector3& result);

inline bool Vector3::operator==(const Vector3& src) const
{
	return (src.x == x) && (src.y == y) && (src.z == z);
}

inline bool Vector3::operator!=(const Vector3& src) const
{
	return (src.x != x) || (src.y != y) || (src.z != z);
}

FORCEINLINE Vector3& Vector3::operator+=(const Vector3& v)
{
	x += v.x;
	y += v.y;
	z += v.z;
	return *this;
}

FORCEINLINE Vector3& Vector3::operator-=(const Vector3& v)
{
	x -= v.x;
	y -= v.y;
	z -= v.z;
	return *this;
}

FORCEINLINE Vector3& Vector3::operator*=(float fl)
{
	x *= fl;
	y *= fl;
	z *= fl;
	return *this;
}

FORCEINLINE Vector3& Vector3::operator*=(const Vector3& v)
{
	x *= v.x;
	y *= v.y;
	z *= v.z;
	return *this;
}

// this ought to be an opcode.
FORCEINLINE Vector3& Vector3::operator+=(float fl)
{
	x += fl;
	y += fl;
	z += fl;
	return *this;
}

FORCEINLINE Vector3& Vector3::operator-=(float fl)
{
	x -= fl;
	y -= fl;
	z -= fl;
	return *this;
}

FORCEINLINE Vector3& Vector3::operator/=(float fl)
{
	float oofl = 1.0f / fl;
	x *= oofl;
	y *= oofl;
	z *= oofl;
	return *this;
}

FORCEINLINE Vector3& Vector3::operator/=(const Vector3& v)
{
	x /= v.x;
	y /= v.y;
	z /= v.z;
	return *this;
}

inline Vector3 Vector3::operator-(void) const
{
	return Vector3(-x, -y, -z);
}

inline Vector3 Vector3::operator+(const Vector3& v) const
{
	Vector3 res;
	VectorAdd(*this, v, res);
	return res;
}

inline Vector3 Vector3::operator-(const Vector3& v) const
{
	Vector3 res;
	VectorSubtract(*this, v, res);
	return res;
}

inline Vector3 Vector3::operator*(float fl) const
{
	Vector3 res;
	VectorMultiply(*this, fl, res);
	return res;
}

inline Vector3 Vector3::operator*(const Vector3& v) const
{
	Vector3 res;
	VectorMultiply(*this, v, res);
	return res;
}

inline Vector3 Vector3::operator/(float fl) const
{
	Vector3 res;
	VectorDivide(*this, fl, res);
	return res;
}

inline Vector3 Vector3::operator/(const Vector3& v) const
{
	Vector3 res;
	VectorDivide(*this, v, res);
	return res;
}

inline Vector3 operator*(float fl, const Vector3& v)
{
	return v * fl;
}

inline Vector3 Vector3::Cross(const Vector3& vOther) const
{
	return Vector3(y * vOther.z - z * vOther.y, z * vOther.x - x * vOther.z, x * vOther.y - y * vOther.x);
}

inline void Vector3::Normalize()
{
	float fLen = Length();
	x /= fLen;
	y /= fLen;
	z /= fLen;
}

inline Vector3 StringToVector(char* pString)
{
	Vector3 vRet;

	int length = 0;
	while (pString[length])
	{
		if ((pString[length] == '<') || (pString[length] == '>'))
			pString[length] = '\0';
		length++;
	}

	int startOfFloat = 1;
	int currentIndex = 1;

	while (pString[currentIndex] && (pString[currentIndex] != ','))
		currentIndex++;
	pString[currentIndex] = '\0';
	vRet.x = std::stof(&pString[startOfFloat]);
	startOfFloat = ++currentIndex;

	while (pString[currentIndex] && (pString[currentIndex] != ','))
		currentIndex++;
	pString[currentIndex] = '\0';
	vRet.y = std::stof(&pString[startOfFloat]);
	startOfFloat = ++currentIndex;

	while (pString[currentIndex] && (pString[currentIndex] != ','))
		currentIndex++;
	pString[currentIndex] = '\0';
	vRet.z = std::stof(&pString[startOfFloat]);
	startOfFloat = ++currentIndex;

	return vRet;
}

FORCEINLINE void VectorAdd(const Vector3& a, const Vector3& b, Vector3& c)
{
	c.x = a.x + b.x;
	c.y = a.y + b.y;
	c.z = a.z + b.z;
}

FORCEINLINE void VectorSubtract(const Vector3& a, const Vector3& b, Vector3& c)
{
	c.x = a.x - b.x;
	c.y = a.y - b.y;
	c.z = a.z - b.z;
}

FORCEINLINE void VectorMultiply(const Vector3& a, float b, Vector3& c)
{
	c.x = a.x * b;
	c.y = a.y * b;
	c.z = a.z * b;
}

FORCEINLINE void VectorMultiply(const Vector3& a, const Vector3& b, Vector3& c)
{
	c.x = a.x * b.x;
	c.y = a.y * b.y;
	c.z = a.z * b.z;
}

FORCEINLINE void VectorDivide(const Vector3& a, float b, Vector3& c)
{
	float oob = 1.0f / b;
	c.x = a.x * oob;
	c.y = a.y * oob;
	c.z = a.z * oob;
}

FORCEINLINE void VectorDivide(const Vector3& a, const Vector3& b, Vector3& c)
{
	c.x = a.x / b.x;
	c.y = a.y / b.y;
	c.z = a.z / b.z;
}

class QAngle
{
public:
	float x;
	float y;
	float z;

	QAngle(float _x, float _y, float _z) : x(_x), y(_y), z(_z) {}
	QAngle(float _f) : x(_f), y(_f), z(_f) {}
	QAngle() : x(0.0f), y(0.0f), z(0.0f) {}

	Vector3 GetNormal() const;

	// todo: more operators maybe
	bool operator==(const QAngle& other) { return x == other.x && y == other.y && z == other.z; }
};

inline Vector3 QAngle::GetNormal() const
{
	Vector3 ret(cos(DEG2RAD(y)), sin(DEG2RAD(y)), -sin(DEG2RAD(x)));
	return ret;
}
