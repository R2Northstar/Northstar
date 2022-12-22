#pragma once
#include "pch.h"
#include "core/sourceinterface.h"
#include "spdlog/sinks/base_sink.h"
#include <map>

class EditablePanel
{
  public:
	virtual ~EditablePanel() = 0;
	unsigned char unknown[0x2B0];
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

extern SourceInterface<CGameConsole>* g_pSourceGameConsole;

// spdlog logger
class SourceConsoleSink : public CustomSink
{
  private:
	std::map<spdlog::level::level_enum, SourceColor> m_LogColours = {
		{spdlog::level::trace, NS::Colors::TRACE.ToSourceColor()},
		{spdlog::level::debug, NS::Colors::DEBUG.ToSourceColor()},
		{spdlog::level::info, NS::Colors::INFO.ToSourceColor()},
		{spdlog::level::warn, NS::Colors::WARN.ToSourceColor()},
		{spdlog::level::err, NS::Colors::ERR.ToSourceColor()},
		{spdlog::level::critical, NS::Colors::CRIT.ToSourceColor()},
		{spdlog::level::off, NS::Colors::OFF.ToSourceColor()}};

  protected:
	void custom_sink_it_(const custom_log_msg& msg);
	void sink_it_(const spdlog::details::log_msg& msg) override;
	void flush_() override;
};

void InitialiseConsoleOnInterfaceCreation();
