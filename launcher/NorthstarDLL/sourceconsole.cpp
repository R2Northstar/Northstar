#include "pch.h"
#include "convar.h"
#include "sourceconsole.h"
#include "sourceinterface.h"
#include "concommand.h"
#include "printcommand.h"

SourceInterface<CGameConsole>* g_pSourceGameConsole;

void ConCommand_toggleconsole(const CCommand& arg)
{
	if ((*g_pSourceGameConsole)->IsConsoleVisible())
		(*g_pSourceGameConsole)->Hide();
	else
		(*g_pSourceGameConsole)->Activate();
}

void ConCommand_showconsole(const CCommand& arg)
{
	(*g_pSourceGameConsole)->Activate();
}

void ConCommand_hideconsole(const CCommand& arg)
{
	(*g_pSourceGameConsole)->Hide();
}

void SourceConsoleSink::sink_it_(const spdlog::details::log_msg& msg)
{
	if (!(*g_pSourceGameConsole)->m_bInitialized)
		return;

	spdlog::memory_buf_t formatted;
	spdlog::sinks::base_sink<std::mutex>::formatter_->format(msg, formatted);
	(*g_pSourceGameConsole)->m_pConsole->m_pConsolePanel->ColorPrint(m_LogColours[msg.level], fmt::to_string(formatted).c_str());
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
	(*g_pSourceGameConsole)->Initialize();
	// hook OnCommandSubmitted so we print inputted commands
	OnCommandSubmittedHook.Dispatch((*g_pSourceGameConsole)->m_pConsole->m_vtable->OnCommandSubmitted);

	auto consoleLogger = std::make_shared<SourceConsoleSink>();
	consoleLogger->set_pattern("[%l] %v");
	spdlog::default_logger()->sinks().push_back(consoleLogger);
}

ON_DLL_LOAD_CLIENT_RELIESON("client.dll", SourceConsole, ConCommand, (CModule module))
{
	g_pSourceGameConsole = new SourceInterface<CGameConsole>("client.dll", "GameConsole004");

	RegisterConCommand("toggleconsole", ConCommand_toggleconsole, "Show/hide the console.", FCVAR_DONTRECORD);
	RegisterConCommand("showconsole", ConCommand_showconsole, "Show the console.", FCVAR_DONTRECORD);
	RegisterConCommand("hideconsole", ConCommand_hideconsole, "Hide the console.", FCVAR_DONTRECORD);
}
