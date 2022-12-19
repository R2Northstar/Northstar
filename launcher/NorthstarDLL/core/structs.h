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

// Based on: https://stackoverflow.com/questions/11632219/c-preprocessor-macro-specialisation-based-on-an-argument
// Yes, this is hacky, but it works quite well actually
// This basically makes sure that when the offset is 0x0, no padding field gets generated
#define OFFSET_0x0 ()

#define IIF(c) CONCAT2(IIF_, c)
#define IIF_0(t, ...) __VA_ARGS__
#define IIF_1(t, ...) t

#define PROBE(x) x, 1
#define MSVC_VA_ARGS_WORKAROUND(define, args) define args
#define CHECK(...) MSVC_VA_ARGS_WORKAROUND(CHECK_N, (__VA_ARGS__, 0))
#define DO_PROBE(offset) PROBE_PROXY(OFFSET_##offset) // concatenate prefix with offset
#define PROBE_PROXY(...) PROBE_PRIMITIVE(__VA_ARGS__) // expand arguments
#define PROBE_PRIMITIVE(x) PROBE_COMBINE_##x // merge
#define PROBE_COMBINE_(...) PROBE(~) // if merge successful, expand to probe

#define CHECK_N(x, n, ...) n

#define IS_0(offset) CHECK(DO_PROBE(offset))

#define FIELD(offset, signature) IIF(IS_0(offset))(STRUCT_FIELD_NOOFFSET, STRUCT_FIELD_OFFSET)(offset, signature)
#define FIELDS FIELD

//clang-format on
