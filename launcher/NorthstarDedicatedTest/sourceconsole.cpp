#include "pch.h"
#include "convar.h"
#include "sourceconsole.h"
#include "sourceinterface.h"
#include "concommand.h"
#include "hookutils.h"
#include "dedicated.h"

SourceInterface<CGameConsole>* g_SourceGameConsole;

void ConCommand_toggleconsole(const CCommand& arg)
{
	if ((*g_SourceGameConsole)->IsConsoleVisible())
		(*g_SourceGameConsole)->Hide();
	else
		(*g_SourceGameConsole)->Activate();
}

typedef void (*OnCommandSubmittedType)(CConsoleDialog* consoleDialog, const char* pCommand);
OnCommandSubmittedType onCommandSubmittedOriginal;
void OnCommandSubmittedHook(CConsoleDialog* consoleDialog, const char* pCommand)
{
	consoleDialog->m_pConsolePanel->Print("] ");
	consoleDialog->m_pConsolePanel->Print(pCommand);
	consoleDialog->m_pConsolePanel->Print("\n");

	// todo: call the help command in the future

	onCommandSubmittedOriginal(consoleDialog, pCommand);
}

// called from sourceinterface.cpp in client createinterface hooks, on GameClientExports001
void InitialiseConsoleOnInterfaceCreation()
{
	(*g_SourceGameConsole)->Initialize();

	auto consoleLogger = std::make_shared<SourceConsoleSink>();
	consoleLogger->set_pattern("[%l] %v");

	spdlog::default_logger()->sinks().push_back(consoleLogger);

	// hook OnCommandSubmitted so we print inputted commands
	HookEnabler hook;
	ENABLER_CREATEHOOK(
		hook, (void*)((*g_SourceGameConsole)->m_pConsole->m_vtable->OnCommandSubmitted), &OnCommandSubmittedHook,
		reinterpret_cast<LPVOID*>(&onCommandSubmittedOriginal));
}

void InitialiseSourceConsole(HMODULE baseAddress)
{
	if (IsDedicated())
		return;

	g_SourceGameConsole = new SourceInterface<CGameConsole>("client.dll", "GameConsole004");
	RegisterConCommand("toggleconsole", ConCommand_toggleconsole, "toggles the console", FCVAR_NONE);
}

// logging stuff

SourceConsoleSink::SourceConsoleSink()
{
	logColours.emplace(spdlog::level::trace, SourceColor(0, 255, 255, 255));
	logColours.emplace(spdlog::level::debug, SourceColor(0, 255, 255, 255));
	logColours.emplace(spdlog::level::info, SourceColor(255, 255, 255, 255));
	logColours.emplace(spdlog::level::warn, SourceColor(255, 255, 0, 255));
	logColours.emplace(spdlog::level::err, SourceColor(255, 0, 0, 255));
	logColours.emplace(spdlog::level::critical, SourceColor(255, 0, 0, 255));
	logColours.emplace(spdlog::level::off, SourceColor(0, 0, 0, 0));
}

void SourceConsoleSink::sink_it_(const spdlog::details::log_msg& msg)
{
	if (!(*g_SourceGameConsole)->m_bInitialized)
		return;

	spdlog::memory_buf_t formatted;
	spdlog::sinks::base_sink<std::mutex>::formatter_->format(msg, formatted);
	(*g_SourceGameConsole)
		->m_pConsole->m_pConsolePanel->ColorPrint(logColours[msg.level], fmt::to_string(formatted).c_str()); // todo needs colour support
}

void SourceConsoleSink::flush_() {}