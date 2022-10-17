#pragma once
#include "pch.h"
#include "color.h"

class vgui_BaseRichText;

class CHudChat
{
  public:
	static CHudChat** allHuds;

	char unknown1[720];

	Color m_sameTeamColor;
	Color m_enemyTeamColor;
	Color m_mainTextColor;
	Color m_networkNameColor;

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
	void InsertColorChange(Color color);
	void InsertSwatchColorChange(SwatchColor color);

  private:
	Context m_context;

	const char* ApplyAnsiEscape(const char* escape);
	void InsertDefaultFade();
};
