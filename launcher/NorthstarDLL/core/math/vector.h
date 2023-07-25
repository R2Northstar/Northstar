#include <cmath>

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

	void MakeValid()
	{
		for (auto& fl : raw)
			if (std::isnan(fl))
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
