#pragma once

#include <iostream>
#include <string>
#include <vector>
#include <windows.h>
#include <psapi.h>

namespace Utils
{
	std::vector<uint8_t> StringPatternToBytes(const char* szInput);
    std::vector<int> PatternToBytes(const char* szInput);
    std::pair<std::vector<uint8_t>, std::string> PatternToMaskedBytes(const char* szInput);
    std::vector<int> StringToBytes(const char* szInput, bool bNullTerminator);
    std::pair<std::vector<uint8_t>, std::string> StringToMaskedBytes(const char* szInput, bool bNullTerminator);
}

typedef const unsigned char* rsig_t;
