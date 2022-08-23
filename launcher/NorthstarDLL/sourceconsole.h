#pragma once
#include "pch.h"
#include "sourceinterface.h"
#include "spdlog/sinks/base_sink.h"
#include <map>

class EditablePanel
{
  public:
	virtual ~EditablePanel() = 0;
	unsigned char unknown[0x2B0];
};

struct SourceColor
{
	unsigned char R;
	unsigned char G;
	unsigned char B;
	unsigned char A;

	SourceColor(unsigned char r, unsigned char g, unsigned char b, unsigned char a)
	{
		R = r;
		G = g;
		B = b;
		A = a;
	}

	SourceColor()
	{
		R = 0;
		G = 0;
		B = 0;
		A = 0;
	}
};

class IConsoleDisplayFunc
{
  public:
	virtual void ColorPrint(const SourceColor& clr, const char* pMessage) = 0;
	virtual void Print(const char* pMessage) = 0;
	virtual void DPrint(const char* pMessage) = 0;
};

class CConsolePanel : public EditablePanel, public IConsoleDisplayFunc
{
};

class CConsoleDialog
{
  public:
	struct VTable
	{
		void* unknown[298];
		void (*OnCommandSubmitted)(CConsoleDialog* consoleDialog, const char* pCommand);
	};

	VTable* m_vtable;
	unsigned char unknown[0x398];
	CConsolePanel* m_pConsolePanel;
};

class CGameConsole
{
  public:
	virtual ~CGameConsole() = 0;

	// activates the console, makes it visible and brings it to the foreground
	virtual void Activate() = 0;

	virtual void Initialize() = 0;

	// hides the console
	virtual void Hide() = 0;

	// clears the console
	virtual void Clear() = 0;

	// return true if the console has focus
	virtual bool IsConsoleVisible() = 0;

	virtual void SetParent(int parent) = 0;

	bool m_bInitialized;
	CConsoleDialog* m_pConsole;
};

extern SourceInterface<CGameConsole>* g_SourceGameConsole;

// spdlog logger
class SourceConsoleSink : public spdlog::sinks::base_sink<std::mutex>
{
  private:
	std::map<spdlog::level::level_enum, SourceColor> logColours;

  public:
	SourceConsoleSink();

  protected:
	void sink_it_(const spdlog::details::log_msg& msg) override;
	void flush_() override;
};

void InitialiseSourceConsole(HMODULE baseAddress);
void InitialiseConsoleOnInterfaceCreation();