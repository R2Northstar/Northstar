#include "pch.h"
#include "miscserverfixes.h"
#include "hookutils.h"

#include "NSMem.h"

void InitialiseMiscServerFixes(HMODULE baseAddress)
{
	uintptr_t ba = (uintptr_t)baseAddress;

	// ret at the start of the concommand GenerateObjFile as it can crash servers
	{
		NSMem::BytePatch(ba + 0x38D920, "C3");
	}

	// nop out call to VGUI shutdown since it crashes the game when quitting from the console
	{
		NSMem::NOP(ba + 0x154A96, 5);
	}

	// ret at the start of CServerGameClients::ClientCommandKeyValues as it has no benefit and is forwarded to client (i.e. security issue)
	// this prevents the attack vector of client=>server=>client, however server=>client also has clientside patches
	{
		NSMem::BytePatch(ba + 0x153920, "C3");
	}
}

typedef unsigned int(__fastcall* CLZSS__SafeUncompressType)(
	void* self, const unsigned char* pInput, unsigned char* pOutput, unsigned int unBufSize);
CLZSS__SafeUncompressType CLZSS__SafeUncompress;

struct lzss_header_t
{
	unsigned int id;
	unsigned int actualSize;
};

static constexpr int LZSS_LOOKSHIFT = 4;

// Rewrite of CLZSS::SafeUncompress to fix a vulnerability where malicious compressed payloads could cause the decompressor to try to read
// out of the bounds of the output buffer.
static unsigned int CLZSS__SafeUncompressHook(void* self, const unsigned char* pInput, unsigned char* pOutput, unsigned int unBufSize)
{
	unsigned int totalBytes = 0;
	int getCmdByte = 0;
	int cmdByte = 0;

	lzss_header_t header = *(lzss_header_t*)pInput;

	if (pInput == NULL)
	{
		return 0;
	}
	if (header.id != 0x53535a4c)
	{
		return 0;
	}
	if (header.actualSize == 0)
	{
		return 0;
	}
	if (header.actualSize > unBufSize)
	{
		return 0;
	}

	pInput += sizeof(lzss_header_t);

	for (;;)
	{
		if (!getCmdByte)
		{
			cmdByte = *pInput++;
		}
		getCmdByte = (getCmdByte + 1) & 0x07;

		if (cmdByte & 0x01)
		{
			int position = *pInput++ << LZSS_LOOKSHIFT;
			position |= (*pInput >> LZSS_LOOKSHIFT);
			position += 1;
			int count = (*pInput++ & 0x0F) + 1;
			if (count == 1)
			{
				break;
			}

			// Ensure reference chunk exists entirely within our buffer
			if (position > totalBytes)
			{
				return 0;
			}

			totalBytes += count;
			if (totalBytes > unBufSize)
			{
				return 0;
			}

			unsigned char* pSource = pOutput - position;
			for (int i = 0; i < count; i++)
			{
				*pOutput++ = *pSource++;
			}
		}
		else
		{
			totalBytes++;
			if (totalBytes > unBufSize)
			{
				return 0;
			}
			*pOutput++ = *pInput++;
		}
		cmdByte = cmdByte >> 1;
	}

	if (totalBytes != header.actualSize)
	{
		return 0;
	}

	return totalBytes;

	return 0;
}

void InitialiseMiscEngineServerFixes(HMODULE baseAddress)
{
	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x432a10, &CLZSS__SafeUncompressHook, reinterpret_cast<LPVOID*>(&CLZSS__SafeUncompress));
}
