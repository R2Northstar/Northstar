#include <ctype.h>
#include "utils.h"

bool skip_valid_ansi_csi_sgr(char*& str)
{
	if (*str++ != '\x1B')
		return false;
	if (*str++ != '[') // CSI
		return false;
	for (char* c = str; *c; c++)
	{
		if (*c >= '0' && *c <= '9')
			continue;
		if (*c == ';' || *c == ':')
			continue;
		if (*c == 'm') // SGR
			break;
		return false;
	}
	return true;
}

void NS::Utils::RemoveAsciiControlSequences(char* str, bool allow_color_codes)
{
	for (char *pc = str, c = *pc; c = *pc; pc++)
	{
		// skip UTF-8 characters
		int bytesToSkip = 0;
		if ((c & 0xE0) == 0xC0)
			bytesToSkip = 1; // skip 2-byte UTF-8 sequence
		else if ((c & 0xF0) == 0xE0)
			bytesToSkip = 2; // skip 3-byte UTF-8 sequence
		else if ((c & 0xF8) == 0xF0)
			bytesToSkip = 3; // skip 4-byte UTF-8 sequence
		else if ((c & 0xFC) == 0xF8)
			bytesToSkip = 4; // skip 5-byte UTF-8 sequence
		else if ((c & 0xFE) == 0xFC)
			bytesToSkip = 5; // skip 6-byte UTF-8 sequence

		bool invalid = false;
		char* orgpc = pc;
		for (int i = 0; i < bytesToSkip; i++)
		{
			char next = pc[1];

			// valid UTF-8 part
			if ((next & 0xC0) == 0x80)
			{
				pc++;
				continue;
			}

			// invalid UTF-8 part or encountered \0
			invalid = true;
			break;
		}
		if (invalid)
		{
			// erase the whole "UTF-8" sequence
			for (char* x = orgpc; x <= pc; x++)
				if (*x != '\0')
					*x = ' ';
				else
					break;
		}
		if (bytesToSkip > 0)
			continue; // this byte was already handled as UTF-8

		// an invalid control character or an UTF-8 part outside of UTF-8 sequence
		if ((iscntrl(c) && c != '\n' && c != '\r' && c != '\x1B') || (c & 0x80) != 0)
		{
			*pc = ' ';
			continue;
		}

		if (c == '\x1B') // separate handling for this escape sequence...
			if (allow_color_codes && skip_valid_ansi_csi_sgr(pc)) // ...which we allow for color codes...
				pc--;
			else // ...but remove it otherwise
				*pc = ' ';
	}
}
