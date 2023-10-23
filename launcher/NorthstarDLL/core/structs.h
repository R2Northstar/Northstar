#pragma once
//clang-format off
// About this file:
// This file contains several macros used to define reversed structs
// The reason we use these macros is to make it easier to update existing structs
// when new fields are reversed
// This means we dont have to manually add padding, and recalculate when updating

// Technical note:
// While functionally, these structs act like a regular struct, they are actually
// defined as unions with anonymous structs in them.
// This means that each field is essentially an offset into a union.
// We acknowledge that this goes against C++'s active-member guideline for unions
// However, this is not such a big deal here as these structs will not be constructed

// Usage:
// To use these macros, define a struct like so:
/*
OFFSET_STRUCT(Name)
{
	STRUCT_SIZE(0x100)		// Total in-memory struct size
	FIELD(0x0, int field)	// offset, signature
}
*/

#define OFFSET_STRUCT(name) union name
#define STRUCT_SIZE(size) char __size[size];
#define STRUCT_FIELD_OFFSET(offset, signature)                                                                                             \
	struct                                                                                                                                 \
	{                                                                                                                                      \
		char CONCAT2(pad, __LINE__)[offset];                                                                                               \
		signature;                                                                                                                         \
	};

// Special case for a 0-offset field
#define STRUCT_FIELD_NOOFFSET(offset, signature) signature;

// Just puts two tokens next to each other, but
// allows us to force the preprocessor to do another pass
#define FX(f, x) f x

// Macro used to detect if the given offset is 0 or not
#define TEST_0 ,
// MSVC does no preprocessing of integer literals.
// On other compilers `0x0` gets processed into `0`
#define TEST_0x0 ,

// Concats the first and third argument and drops everything else
// Used with preprocessor expansion in later passes to move the third argument to the fourth and change the value
#define ZERO_P_I(a, b, c, ...) a##c

// We use FX to prepare to use ZERO_P_I.
// The right block contains 3 arguments:
// NIF_
// CONCAT2(TEST_, offset)
// 1
//
// If offset is not 0 (or 0x0) the preprocessor replaces
// it with nothing and the third argument stays 1
//
// If the offset is 0, TEST_0 expands to , and 1 becomes the fourth argument
//
// With those arguments we call ZERO_P_I and the first and third arugment get concat.
// We either end up with:
// NIF_ (if offset is 0) or
// NIF_1 (if offset is not 0)
#define IF_ZERO(m) FX(ZERO_P_I, (NIF_, CONCAT2(TEST_, m), 1))

// These macros are used to branch after we processed if the offset is zero or not
#define NIF_(t, ...) t
#define NIF_1(t, ...) __VA_ARGS__

// FIELD(S), generates an anonymous struct when a non 0 offset is given, otherwise just a signature
#define FIELD(offset, signature) IF_ZERO(offset)(STRUCT_FIELD_NOOFFSET, STRUCT_FIELD_OFFSET)(offset, signature)
#define FIELDS FIELD

//clang-format on
