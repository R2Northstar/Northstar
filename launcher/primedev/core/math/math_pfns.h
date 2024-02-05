#pragma once

inline float FastSqrt(float x)
{
	__m128 root = _mm_sqrt_ss(_mm_load_ss(&x));
	return *(reinterpret_cast<float*>(&root));
}
