#include "core/convar/convar.h"
#include "sourceconsole.h"
#include "core/tier1.h"
#include "core/convar/concommand.h"
#include "util/printcommands.h"

CGameConsole* g_pGameConsole;

void ConCommand_toggleconsole(const CCommand& arg)
{
	NOTE_UNUSED(arg);
	if (g_pGameConsole->IsConsoleVisible())
		g_pGameConsole->Hide();
	else
		g_pGameConsole->Activate();
}

void ConCommand_showconsole(const CCommand& arg)
{
	NOTE_UNUSED(arg);
	g_pGameConsole->Activate();
}

void ConCommand_hideconsole(const CCommand& arg)
{
	NOTE_UNUSED(arg);
	g_pGameConsole->Hide();
}

void SourceConsoleSink::custom_sink_it_(const custom_log_msg& msg)
{
	if (!g_pGameConsole->m_bInitialized)
		return;

	spdlog::memory_buf_t formatted;
	spdlog::sinks::base_sink<std::mutex>::formatter_->format(msg, formatted);

	// get message string
	std::string str = fmt::to_string(formatted);

	SourceColor levelColor = m_LogColours[msg.level];
	std::string name {msg.logger_name.begin(), msg.logger_name.end()};

	g_pGameConsole->m_pConsole->m_pConsolePanel->ColorPrint(msg.origin->SRCColor, ("[" + name + "]").c_str());
	g_pGameConsole->m_pConsole->m_pConsolePanel->Print(" ");
	g_pGameConsole->m_pConsole->m_pConsolePanel->ColorPrint(levelColor, ("[" + std::string(level_names[msg.level]) + "]").c_str());
	g_pGameConsole->m_pConsole->m_pConsolePanel->Print(" ");
	g_pGameConsole->m_pConsole->m_pConsolePanel->Print(fmt::to_string(formatted).c_str());
}

void SourceConsoleSink::sink_it_(const spdlog::details::log_msg& msg)
{
	NOTE_UNUSED(msg);
	throw std::runtime_error("sink_it_ called on SourceConsoleSink with pure log_msg. This is an error!");
}

void SourceConsoleSink::flush_() {}

// clang-format off
HOOK(OnCommandSubmittedHook, OnCommandSubmitted, 
void, __fastcall, (CConsoleDialog* consoleDialog, const char* pCommand))
// clang-format on
{
	consoleDialog->m_pConsolePanel->Print("] ");
	consoleDialog->m_pConsolePanel->Print(pCommand);
	consoleDialog->m_pConsolePanel->Print("\n");

	TryPrintCvarHelpForCommand(pCommand);

	OnCommandSubmitted(consoleDialog, pCommand);
}

// called from sourceinterface.cpp in client createinterface hooks, on GameClientExports001
void InitialiseConsoleOnInterfaceCreation()
{
	g_pGameConsole->Initialize();
	// hook OnCommandSubmitted so we print inputted commands
	OnCommandSubmittedHook.Dispatch((LPVOID)g_pGameConsole->m_pConsole->m_vtable->OnCommandSubmitted);

	auto consoleSink = std::make_shared<SourceConsoleSink>();
	if (g_bSpdLog_UseAnsiColor)
		consoleSink->set_pattern("%v"); // no need to include the level in the game console, the text colour signifies it anyway
	else
		consoleSink->set_pattern("[%n] [%l] %v"); // no colour, so we should show the level for colourblind people
	RegisterCustomSink(consoleSink);
}

ON_DLL_LOAD_CLIENT_RELIESON("client.dll", SourceConsole, ConCommand, (CModule module))
{
	g_pGameConsole = Sys_GetFactoryPtr("client.dll", "GameConsole004").RCast<CGameConsole*>();

	RegisterConCommand("toggleconsole", ConCommand_toggleconsole, "Show/hide the console.", FCVAR_DONTRECORD);
	RegisterConCommand("showconsole", ConCommand_showconsole, "Show the console.", FCVAR_DONTRECORD);
	RegisterConCommand("hideconsole", ConCommand_hideconsole, "Hide the console.", FCVAR_DONTRECORD);
}
