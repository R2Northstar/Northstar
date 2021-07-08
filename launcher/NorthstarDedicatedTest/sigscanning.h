#pragma once
#include <string>

// note: sigscanning is only really intended to be used for resolving stuff like shared function definitions
// we mostly use raw function addresses for stuff

void* FindSignature(std::string dllName, const char* sig, const char* mask);