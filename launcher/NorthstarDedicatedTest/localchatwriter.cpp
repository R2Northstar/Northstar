#include "pch.h"
#include "localchatwriter.h"

class vgui_BaseRichText_vtable;

class vgui_BaseRichText
{
  public:
	vgui_BaseRichText_vtable* vtable;
};

class vgui_BaseRichText_vtable
{
  public:
	char unknown1[1880];

	void(__fastcall* InsertChar)(vgui_BaseRichText* self, wchar_t ch);

	// yes these are swapped from the Source 2013 code, who knows why
	void(__fastcall* InsertStringWide)(vgui_BaseRichText* self, const wchar_t* wszText);
	void(__fastcall* InsertStringAnsi)(vgui_BaseRichText* self, const char* text);

	void(__fastcall* SelectNone)(vgui_BaseRichText* self);
	void(__fastcall* SelectAllText)(vgui_BaseRichText* self);
	void(__fastcall* SelectNoText)(vgui_BaseRichText* self);
	void(__fastcall* CutSelected)(vgui_BaseRichText* self);
	void(__fastcall* CopySelected)(vgui_BaseRichText* self);
	void(__fastcall* SetPanelInteractive)(vgui_BaseRichText* self, bool bInteractive);
	void(__fastcall* SetUnusedScrollbarInvisible)(vgui_BaseRichText* self, bool bInvis);

	void* unknown2;

	void(__fastcall* GotoTextStart)(vgui_BaseRichText* self);
	void(__fastcall* GotoTextEnd)(vgui_BaseRichText* self);

	void* unknown3[3];

	void(__fastcall* SetVerticalScrollbar)(vgui_BaseRichText* self, bool state);
	void(__fastcall* SetMaximumCharCount)(vgui_BaseRichText* self, int maxChars);
	void(__fastcall* InsertColorChange)(vgui_BaseRichText* self, vgui_Color col);
	void(__fastcall* InsertIndentChange)(vgui_BaseRichText* self, int pixelsIndent);
	void(__fastcall* InsertClickableTextStart)(vgui_BaseRichText* self, const char* pchClickAction);
	void(__fastcall* InsertClickableTextEnd)(vgui_BaseRichText* self);
	void(__fastcall* InsertPossibleURLString)(
		vgui_BaseRichText* self, const char* text, vgui_Color URLTextColor, vgui_Color normalTextColor);
	void(__fastcall* InsertFade)(vgui_BaseRichText* self, float flSustain, float flLength);
	void(__fastcall* ResetAllFades)(vgui_BaseRichText* self, bool bHold, bool bOnlyExpired, float flNewSustain);
	void(__fastcall* SetToFullHeight)(vgui_BaseRichText* self);
	int(__fastcall* GetNumLines)(vgui_BaseRichText* self);
};

class CGameSettings
{
  public:
	char unknown1[92];
	int isChatEnabled;
};

// Not sure what this actually refers to but chatFadeLength and chatFadeSustain
// have their value at the same offset
class CGameFloatVar
{
  public:
	char unknown1[88];
	float value;
};

class CHudChat
{
  public:
	char unknown1[720];

	vgui_Color m_sameTeamColor;
	vgui_Color m_enemyTeamColor;
	vgui_Color m_mainTextColor;
	vgui_Color m_networkNameColor;

	char unknown2[12];

	int m_unknownContext;

	char unknown3[8];

	vgui_BaseRichText* m_richText;

	CHudChat* next;
	CHudChat* previous;
};

CGameSettings** gGameSettings;
CGameFloatVar** gChatFadeLength;
CGameFloatVar** gChatFadeSustain;

// Linked list of CHudChats
CHudChat** gHudChatList;

typedef void(__fastcall* ConvertANSIToUnicodeType)(LPCSTR ansi, int ansiCharLength, LPWSTR unicode, int unicodeCharLength);
ConvertANSIToUnicodeType ConvertANSIToUnicode;

LocalChatWriter::SwatchColor swatchColors[4] = {
	LocalChatWriter::MainTextColor,
	LocalChatWriter::SameTeamNameColor,
	LocalChatWriter::EnemyTeamNameColor,
	LocalChatWriter::NetworkNameColor,
};

vgui_Color darkColors[8] = {vgui_Color{0, 0, 0, 255},	   vgui_Color{205, 49, 49, 255},  vgui_Color{13, 188, 121, 255},
							vgui_Color{229, 229, 16, 255}, vgui_Color{36, 114, 200, 255}, vgui_Color{188, 63, 188, 255},
							vgui_Color{17, 168, 205, 255}, vgui_Color{229, 229, 229, 255}};

vgui_Color lightColors[8] = {vgui_Color{102, 102, 102, 255}, vgui_Color{241, 76, 76, 255},	vgui_Color{35, 209, 139, 255},
							 vgui_Color{245, 245, 67, 255},	 vgui_Color{59, 142, 234, 255}, vgui_Color{214, 112, 214, 255},
							 vgui_Color{41, 184, 219, 255},	 vgui_Color{255, 255, 255, 255}};

class AnsiEscapeParser
{
  public:
	explicit AnsiEscapeParser(LocalChatWriter* writer) : m_writer(writer) {}

	void HandleVal(unsigned long val)
	{
		switch (m_next)
		{
		case Next::ControlType:
			m_next = HandleControlType(val);
			break;
		case Next::ForegroundType:
			m_next = HandleForegroundType(val);
			break;
		case Next::Foreground8Bit:
			m_next = HandleForeground8Bit(val);
			break;
		case Next::ForegroundR:
			m_next = HandleForegroundR(val);
			break;
		case Next::ForegroundG:
			m_next = HandleForegroundG(val);
			break;
		case Next::ForegroundB:
			m_next = HandleForegroundB(val);
			break;
		}
	}

  private:
	enum class Next
	{
		ControlType,
		ForegroundType,
		Foreground8Bit,
		ForegroundR,
		ForegroundG,
		ForegroundB
	};

	LocalChatWriter* m_writer;
	Next m_next = Next::ControlType;
	vgui_Color m_expandedColor{0, 0, 0, 0};

	Next HandleControlType(unsigned long val)
	{
		// Reset
		if (val == 0 || val == 39)
		{
			m_writer->InsertSwatchColorChange(LocalChatWriter::MainTextColor);
			return Next::ControlType;
		}

		// Dark foreground color
		if (val >= 30 && val < 38)
		{
			m_writer->InsertColorChange(darkColors[val - 30]);
			return Next::ControlType;
		}

		// Light foreground color
		if (val >= 90 && val < 98)
		{
			m_writer->InsertColorChange(lightColors[val - 90]);
			return Next::ControlType;
		}

		// Game swatch color
		if (val >= 110 && val < 114)
		{
			m_writer->InsertSwatchColorChange(swatchColors[val - 110]);
			return Next::ControlType;
		}

		// Expanded foreground color
		if (val == 38)
		{
			return Next::ForegroundType;
		}

		return Next::ControlType;
	}

	Next HandleForegroundType(unsigned long val)
	{
		// Next values are r,g,b
		if (val == 2)
		{
			m_expandedColor = {0, 0, 0, 255};
			return Next::ForegroundR;
		}
		// Next value is 8-bit swatch color
		if (val == 5)
		{
			return Next::Foreground8Bit;
		}

		// Invalid
		return Next::ControlType;
	}

	Next HandleForeground8Bit(unsigned long val)
	{
		if (val < 8)
		{
			m_writer->InsertColorChange(darkColors[val]);
		}
		else if (val < 16)
		{
			m_writer->InsertColorChange(lightColors[val - 8]);
		}
		else if (val < 232)
		{
			unsigned char code = val - 16;
			unsigned char blue = code % 6;
			unsigned char green = ((code - blue) / 6) % 6;
			unsigned char red = (code - blue - (green * 6)) / 36;
			m_writer->InsertColorChange(
				vgui_Color{(unsigned char)(red * 51), (unsigned char)(green * 51), (unsigned char)(blue * 51), 255});
		}
		else if (val < UCHAR_MAX)
		{
			unsigned char brightness = (val - 232) * 10 + 8;
			m_writer->InsertColorChange(vgui_Color{brightness, brightness, brightness, 255});
		}

		return Next::ControlType;
	}

	Next HandleForegroundR(unsigned long val)
	{
		if (val >= UCHAR_MAX)
			return Next::ControlType;

		m_expandedColor.r = (unsigned char)val;
		return Next::ForegroundG;
	}

	Next HandleForegroundG(unsigned long val)
	{
		if (val >= UCHAR_MAX)
			return Next::ControlType;

		m_expandedColor.g = (unsigned char)val;
		return Next::ForegroundB;
	}

	Next HandleForegroundB(unsigned long val)
	{
		if (val >= UCHAR_MAX)
			return Next::ControlType;

		m_expandedColor.b = (unsigned char)val;
		m_writer->InsertColorChange(m_expandedColor);
		return Next::ControlType;
	}
};

LocalChatWriter::LocalChatWriter(Context context) : m_context(context) {}

void LocalChatWriter::Write(const char* str)
{
	char writeBuffer[256];

	while (true)
	{
		const char* startOfEscape = strstr(str, "\033[");

		if (startOfEscape == NULL)
		{
			// No more escape sequences, write the remaining text and exit
			InsertText(str);
			break;
		}

		if (startOfEscape != str)
		{
			// There is some text before the escape sequence, just print that

			size_t copyChars = startOfEscape - str;
			if (copyChars > 255)
				copyChars = 255;
			strncpy(writeBuffer, str, copyChars);
			writeBuffer[copyChars] = 0;

			InsertText(writeBuffer);
		}

		const char* escape = startOfEscape + 2;
		str = ApplyAnsiEscape(escape);
	}
}

void LocalChatWriter::WriteLine(const char* str)
{
	InsertChar(L'\n');
	InsertSwatchColorChange(MainTextColor);
	Write(str);
}

void LocalChatWriter::InsertChar(wchar_t ch)
{
	for (CHudChat* hud = *gHudChatList; hud != NULL; hud = hud->next)
	{
		if (hud->m_unknownContext != (int)m_context)
			continue;

		hud->m_richText->vtable->InsertChar(hud->m_richText, ch);
	}

	if (ch != L'\n')
	{
		InsertDefaultFade();
	}
}

void LocalChatWriter::InsertText(const char* str)
{
	WCHAR messageUnicode[288];
	ConvertANSIToUnicode(str, -1, messageUnicode, 274);

	for (CHudChat* hud = *gHudChatList; hud != NULL; hud = hud->next)
	{
		if (hud->m_unknownContext != (int)m_context)
			continue;

		hud->m_richText->vtable->InsertStringWide(hud->m_richText, messageUnicode);
	}

	InsertDefaultFade();
}

void LocalChatWriter::InsertText(const wchar_t* str)
{
	for (CHudChat* hud = *gHudChatList; hud != NULL; hud = hud->next)
	{
		if (hud->m_unknownContext != (int)m_context)
			continue;

		hud->m_richText->vtable->InsertStringWide(hud->m_richText, str);
	}

	InsertDefaultFade();
}

void LocalChatWriter::InsertColorChange(vgui_Color color)
{
	for (CHudChat* hud = *gHudChatList; hud != NULL; hud = hud->next)
	{
		if (hud->m_unknownContext != (int)m_context)
			continue;

		hud->m_richText->vtable->InsertColorChange(hud->m_richText, color);
	}
}

static vgui_Color GetHudSwatchColor(CHudChat* hud, LocalChatWriter::SwatchColor swatchColor)
{
	switch (swatchColor)
	{
	case LocalChatWriter::MainTextColor:
		return hud->m_mainTextColor;
	case LocalChatWriter::SameTeamNameColor:
		return hud->m_sameTeamColor;
	case LocalChatWriter::EnemyTeamNameColor:
		return hud->m_enemyTeamColor;
	case LocalChatWriter::NetworkNameColor:
		return hud->m_networkNameColor;
	}
	return vgui_Color{0, 0, 0, 0};
}

void LocalChatWriter::InsertSwatchColorChange(SwatchColor swatchColor)
{
	for (CHudChat* hud = *gHudChatList; hud != NULL; hud = hud->next)
	{
		if (hud->m_unknownContext != (int)m_context)
			continue;
		hud->m_richText->vtable->InsertColorChange(hud->m_richText, GetHudSwatchColor(hud, swatchColor));
	}
}

const char* LocalChatWriter::ApplyAnsiEscape(const char* escape)
{
	AnsiEscapeParser decoder(this);
	while (true)
	{
		char* afterControlType = NULL;
		unsigned long controlType = strtoul(escape, &afterControlType, 10);

		// Malformed cases:
		// afterControlType = NULL: strtoul errored
		// controlType = 0 and escape doesn't actually start with 0: wasn't a number
		if (afterControlType == NULL || (controlType == 0 && escape[0] != '0'))
		{
			return escape;
		}

		decoder.HandleVal(controlType);

		// m indicates the end of the sequence
		if (afterControlType[0] == 'm')
		{
			return afterControlType + 1;
		}

		// : or ; indicates more values remain, anything else is malformed
		if (afterControlType[0] != ':' && afterControlType[0] != ';')
		{
			return afterControlType;
		}

		escape = afterControlType + 1;
	}
}

void LocalChatWriter::InsertDefaultFade()
{
	float fadeLength = 0.f;
	float fadeSustain = 0.f;
	if ((*gGameSettings)->isChatEnabled)
	{
		fadeLength = (*gChatFadeLength)->value;
		fadeSustain = (*gChatFadeSustain)->value;
	}

	for (CHudChat* hud = *gHudChatList; hud != NULL; hud = hud->next)
	{
		if (hud->m_unknownContext != (int)m_context)
			continue;
		hud->m_richText->vtable->InsertFade(hud->m_richText, fadeSustain, fadeLength);
	}
}

bool IsFirstHud(void* hud) { return hud == *gHudChatList; }

void InitialiseLocalChatWriter(HMODULE baseAddress)
{
	gGameSettings = (CGameSettings**)((char*)baseAddress + 0x11BAA48);
	gChatFadeLength = (CGameFloatVar**)((char*)baseAddress + 0x11BAB78);
	gChatFadeSustain = (CGameFloatVar**)((char*)baseAddress + 0x11BAC08);
	gHudChatList = (CHudChat**)((char*)baseAddress + 0x11BA9E8);

	ConvertANSIToUnicode = (ConvertANSIToUnicodeType)((char*)baseAddress + 0x7339A0);
}
