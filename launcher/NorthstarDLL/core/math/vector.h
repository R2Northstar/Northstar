#pragma once

union Vector3
{
	struct
	{
		float x;
		float y;
		float z;
	};

	float raw[3];

	Vector3() : x(0), y(0), z(0) {}
	Vector3(float x, float y, float z) : x(x), y(y), z(z) {}
	Vector3(float* pRawFloats) // assumes float[3] => vector
	{
		memcpy(raw, pRawFloats, sizeof(this));
	}

	void MakeValid()
	{
		for (auto& fl : raw)
			if (isnan(fl))
				fl = 0;
	}

	// todo: more operators maybe
	bool operator==(const Vector3& other)
	{
		return x == other.x && y == other.y && z == other.z;
	}
};

union QAngle
{
	struct
	{
		float x;
		float y;
		float z;
		float w;
	};

	float raw[4];

	// todo: more operators maybe
	bool operator==(const QAngle& other)
	{
		return x == other.x && y == other.y && z == other.z && w == other.w;
	}
};
