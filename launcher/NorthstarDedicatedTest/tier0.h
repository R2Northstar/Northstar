#pragma once
#include "pch.h"

// get exported tier0 by name 
void* ResolveTier0Function(const char* name);

// actual function defs
// would've liked to resolve these at compile time, but we load before tier0 so not really possible
void Error(const char* fmt, ...);