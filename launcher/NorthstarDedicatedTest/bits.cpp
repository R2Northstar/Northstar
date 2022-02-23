//=============================================================================//
//
// Purpose: look for NANs, infinities, and underflows.
//
//=============================================================================//

#include "pch.h"
#include "bits.h"

//-----------------------------------------------------------------------------
// This follows the ANSI/IEEE 754-1985 standard
//-----------------------------------------------------------------------------
unsigned long& FloatBits(float& f) { return *reinterpret_cast<unsigned long*>(&f); }

unsigned long const& FloatBits(float const& f) { return *reinterpret_cast<unsigned long const*>(&f); }

float BitsToFloat(unsigned long i) { return *reinterpret_cast<float*>(&i); }

bool IsFinite(float f) { return ((FloatBits(f) & 0x7F800000) != 0x7F800000); }

unsigned long FloatAbsBits(float f) { return FloatBits(f) & 0x7FFFFFFF; }

float FloatMakePositive(float f) { return fabsf(f); }

float FloatNegate(float f)
{
	return -f; // BitsToFloat( FloatBits(f) ^ 0x80000000 );
}
