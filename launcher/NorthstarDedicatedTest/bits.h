#pragma once

unsigned long& FloatBits(float& f);
unsigned long const& FloatBits(float const& f);
float BitsToFloat(unsigned long i);
bool IsFinite(float f);
unsigned long FloatAbsBits(float f);

#define FLOAT32_NAN_BITS (std::uint32_t)0x7FC00000 // NaN!
#define FLOAT32_NAN BitsToFloat(FLOAT32_NAN_BITS)
