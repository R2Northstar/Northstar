#include "utils.h"

namespace Utils
{
	//----------------------------------------------------------------------------------------
	// Purpose: For converting a string pattern to an array of bytes. Doesnt support wildcards
	//----------------------------------------------------------------------------------------
	std::vector<uint8_t> StringPatternToBytes(const char* szInput)
	{
		const char* pszPatternStart = const_cast<char*>(szInput);
		const char* pszPatternEnd = pszPatternStart + strlen(szInput);
		std::vector<uint8_t> vBytes;

		for (const char* pszCurrentByte = pszPatternStart; pszCurrentByte < pszPatternEnd; ++pszCurrentByte)
		{
			vBytes.push_back(strtoul(pszCurrentByte, const_cast<char**>(&pszCurrentByte), 16));
		}
		return vBytes;
	};

    //----------------------------------------------------------------------------------------
    // Purpose: For converting a string pattern with wildcards to an array of bytes.
    //----------------------------------------------------------------------------------------
    std::vector<int> PatternToBytes(const char* szInput)
    {
        const char* pszPatternStart = const_cast<char*>(szInput);
        const char* pszPatternEnd = pszPatternStart + strlen(szInput);
        std::vector<int> vBytes;

        for (const char* pszCurrentByte = pszPatternStart; pszCurrentByte < pszPatternEnd; ++pszCurrentByte)
        {
            if (*pszCurrentByte == '?')
            {
                ++pszCurrentByte;
                if (*pszCurrentByte == '?')
                {
                    ++pszCurrentByte; // Skip double wildcard.
                }
                vBytes.push_back(-1); // Push the byte back as invalid.
            }
            else
            {
                vBytes.push_back(strtoul(pszCurrentByte, const_cast<char**>(&pszCurrentByte), 16));
            }
        }
        return vBytes;
    };

    //----------------------------------------------------------------------------------------
    // Purpose: For converting a string pattern with wildcards to an array of bytes and mask.
    //----------------------------------------------------------------------------------------
    std::pair<std::vector<uint8_t>, std::string> PatternToMaskedBytes(const char* szInput)
    {
        const char* pszPatternStart = const_cast<char*>(szInput);
        const char* pszPatternEnd = pszPatternStart + strlen(szInput);

        std::vector<uint8_t> vBytes;
        std::string svMask;

        for (const char* pszCurrentByte = pszPatternStart; pszCurrentByte < pszPatternEnd; ++pszCurrentByte)
        {
            if (*pszCurrentByte == '?')
            {
                ++pszCurrentByte;
                if (*pszCurrentByte == '?')
                {
                    ++pszCurrentByte; // Skip double wildcard.
                }
                vBytes.push_back(0); // Push the byte back as invalid.
                svMask += '?';
            }
            else
            {
                vBytes.push_back(uint8_t(strtoul(pszCurrentByte, const_cast<char**>(&pszCurrentByte), 16)));
                svMask += 'x';
            }
        }
        return make_pair(vBytes, svMask);
    };

    //----------------------------------------------------------------------------------------
    // Purpose: For converting a string to an array of bytes.
    //----------------------------------------------------------------------------------------
    std::vector<int> StringToBytes(const char* szInput, bool bNullTerminator)
    {
        const char* pszStringStart = const_cast<char*>(szInput);
        const char* pszStringEnd = pszStringStart + strlen(szInput);
        std::vector<int> vBytes;

        for (const char* pszCurrentByte = pszStringStart; pszCurrentByte < pszStringEnd; ++pszCurrentByte)
        {
            // Dereference character and push back the byte.
            vBytes.push_back(*pszCurrentByte);
        }

        if (bNullTerminator)
        {
            vBytes.push_back('\0');
        }
        return vBytes;
    };

    //----------------------------------------------------------------------------------------
    // Purpose: For converting a string to an array of masked bytes.
    //----------------------------------------------------------------------------------------
    std::pair<std::vector<uint8_t>, std::string> StringToMaskedBytes(const char* szInput, bool bNullTerminator)
    {
        const char* pszStringStart = const_cast<char*>(szInput);
        const char* pszStringEnd = pszStringStart + strlen(szInput);
        std::vector<uint8_t> vBytes;
        std::string svMask;

        for (const char* pszCurrentByte = pszStringStart; pszCurrentByte < pszStringEnd; ++pszCurrentByte)
        {
            // Dereference character and push back the byte.
            vBytes.push_back(*pszCurrentByte);
            svMask += 'x';
        }

        if (bNullTerminator)
        {
            vBytes.push_back(0x0);
            svMask += 'x';
        }
        return make_pair(vBytes, svMask);
    };
}
