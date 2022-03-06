#pragma once
#include "pch.h"

struct vgui_Color
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a;
};

class vgui_BaseRichText;

class CHudChat
{
  public:
	static CHudChat** allHuds;

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

class LocalChatWriter
{
  public:
	enum Context
	{
		NetworkContext = 0,
		GameContext = 1
	};
	enum SwatchColor
	{
		MainTextColor,
		SameTeamNameColor,
		EnemyTeamNameColor,
		NetworkNameColor
	};

	explicit LocalChatWriter(Context context);

	// Custom chat writing with ANSI escape codes
	void Write(const char* str);
	void WriteLine(const char* str);

	// Low-level RichText access
	void InsertChar(wchar_t ch);
	void InsertText(const char* str);
	void InsertText(const wchar_t* str);
	void InsertColorChange(vgui_Color color);
	void InsertSwatchColorChange(SwatchColor color);

  private:
	Context m_context;

	const char* ApplyAnsiEscape(const char* escape);
	void InsertDefaultFade();
};

void InitialiseLocalChatWriter(HMODULE baseAddress);
