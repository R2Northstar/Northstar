#include "crashhandler.h"
#include "config/profile.h"
#include "dedicated/dedicated.h"
#include "util/version.h"
#include "mods/modmanager.h"
#include "plugins/plugins.h"

#include <minidumpapiset.h>

#define CRASHHANDLER_MAX_FRAMES 32
#define CRASHHANDLER_GETMODULEHANDLE_FAIL "GetModuleHandleExA failed!"

//-----------------------------------------------------------------------------
// Purpose: Vectored exception callback
//-----------------------------------------------------------------------------
LONG WINAPI ExceptionFilter(EXCEPTION_POINTERS* pExceptionInfo)
{
	g_pCrashHandler->Lock();

	g_pCrashHandler->SetExceptionInfos(pExceptionInfo);

	// Check if we should handle this
	// NOTE [Fifty]: This gets called before even a try{} catch() {} can handle an exception
	//               we don't handle these unless "-crash_handle_all" is passed as a launch arg
	if (!g_pCrashHandler->IsExceptionFatal() && !g_pCrashHandler->GetAllFatal())
	{
		g_pCrashHandler->Unlock();
		return EXCEPTION_CONTINUE_SEARCH;
	}

	// Don't run if a debbuger is attached
	if (IsDebuggerPresent())
	{
		g_pCrashHandler->Unlock();
		return EXCEPTION_CONTINUE_SEARCH;
	}

	// Prevent recursive calls
	if (g_pCrashHandler->GetState())
	{
		g_pCrashHandler->Unlock();
		ExitProcess(1);
	}

	g_pCrashHandler->SetState(true);

	// Needs to be called first as we use the members this sets later on
	g_pCrashHandler->SetCrashedModule();

	// Format
	g_pCrashHandler->FormatException();
	g_pCrashHandler->FormatCallstack();
	g_pCrashHandler->FormatRegisters();
	g_pCrashHandler->FormatLoadedMods();
	g_pCrashHandler->FormatLoadedPlugins();
	g_pCrashHandler->FormatModules();

	// Flush
	NS::log::FlushLoggers();

	// Write minidump
	g_pCrashHandler->WriteMinidump();

	// Show message box
	g_pCrashHandler->ShowPopUpMessage();

	g_pCrashHandler->Unlock();

	// We showed the "Northstar has crashed" message box
	// make sure we terminate
	if (!g_pCrashHandler->IsExceptionFatal())
		ExitProcess(1);

	return EXCEPTION_EXECUTE_HANDLER;
}

//-----------------------------------------------------------------------------
// Purpose: console control signal handler
//-----------------------------------------------------------------------------
BOOL WINAPI ConsoleCtrlRoutine(DWORD dwCtrlType)
{
	// NOTE [Fifty]: When closing the process by closing the console we don't want
	//               to trigger the crash handler so we remove it
	switch (dwCtrlType)
	{
	case CTRL_CLOSE_EVENT:
		spdlog::info("Exiting due to console close...");
		delete g_pCrashHandler;
		g_pCrashHandler = nullptr;
		std::exit(EXIT_SUCCESS);
		return TRUE;
	}

	return FALSE;
}

//-----------------------------------------------------------------------------
// Purpose: Constructor
//-----------------------------------------------------------------------------
CCrashHandler::CCrashHandler()
	: m_hExceptionFilter(nullptr)
	, m_pExceptionInfos(nullptr)
	, m_bHasSetConsolehandler(false)
	, m_bAllExceptionsFatal(false)
	, m_bHasShownCrashMsg(false)
	, m_bState(false)
{
	Init();
}

//-----------------------------------------------------------------------------
// Purpose: Destructor
//-----------------------------------------------------------------------------
CCrashHandler::~CCrashHandler()
{
	Shutdown();
}

//-----------------------------------------------------------------------------
// Purpose: Initilazes crash handler
//-----------------------------------------------------------------------------
void CCrashHandler::Init()
{
	m_hExceptionFilter = AddVectoredExceptionHandler(TRUE, ExceptionFilter);
	m_bHasSetConsolehandler = SetConsoleCtrlHandler(ConsoleCtrlRoutine, TRUE);
}

//-----------------------------------------------------------------------------
// Purpose: Shutdowns crash handler
//-----------------------------------------------------------------------------
void CCrashHandler::Shutdown()
{
	if (m_hExceptionFilter)
	{
		RemoveVectoredExceptionHandler(m_hExceptionFilter);
		m_hExceptionFilter = nullptr;
	}

	if (m_bHasSetConsolehandler)
	{
		SetConsoleCtrlHandler(ConsoleCtrlRoutine, FALSE);
	}
}

//-----------------------------------------------------------------------------
// Purpose: Sets the exception info
//-----------------------------------------------------------------------------
void CCrashHandler::SetExceptionInfos(EXCEPTION_POINTERS* pExceptionPointers)
{
	m_pExceptionInfos = pExceptionPointers;
}
//-----------------------------------------------------------------------------
// Purpose: Sets the exception stirngs for message box
//-----------------------------------------------------------------------------
void CCrashHandler::SetCrashedModule()
{
	LPCSTR pCrashAddress = static_cast<LPCSTR>(m_pExceptionInfos->ExceptionRecord->ExceptionAddress);
	HMODULE hCrashedModule;
	if (!GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, pCrashAddress, &hCrashedModule))
	{
		m_svCrashedModule = CRASHHANDLER_GETMODULEHANDLE_FAIL;
		m_svCrashedOffset = "";

		DWORD dwErrorID = GetLastError();
		if (dwErrorID != 0)
		{
			LPSTR pszBuffer;
			DWORD dwSize = FormatMessageA(
				FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
				NULL,
				dwErrorID,
				MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
				(LPSTR)&pszBuffer,
				0,
				NULL);

			if (dwSize > 0)
			{
				m_svError = pszBuffer;
				LocalFree(pszBuffer);
			}
		}

		return;
	}

	// Get module filename
	CHAR szCrashedModulePath[MAX_PATH];
	GetModuleFileNameExA(GetCurrentProcess(), hCrashedModule, szCrashedModulePath, sizeof(szCrashedModulePath));

	const CHAR* pszCrashedModuleFileName = strrchr(szCrashedModulePath, '\\') + 1;

	// Get relative address
	LPCSTR pModuleBase = reinterpret_cast<LPCSTR>(pCrashAddress - reinterpret_cast<LPCSTR>(hCrashedModule));

	m_svCrashedModule = pszCrashedModuleFileName;
	m_svCrashedOffset = fmt::format("{:#x}", reinterpret_cast<DWORD64>(pModuleBase));
}

//-----------------------------------------------------------------------------
// Purpose: Gets the exception null terminated stirng
//-----------------------------------------------------------------------------

const CHAR* CCrashHandler::GetExceptionString() const
{
	return GetExceptionString(m_pExceptionInfos->ExceptionRecord->ExceptionCode);
}

//-----------------------------------------------------------------------------
// Purpose: Gets the exception null terminated stirng
//-----------------------------------------------------------------------------
const CHAR* CCrashHandler::GetExceptionString(DWORD dwExceptionCode) const
{
	// clang-format off
	switch (dwExceptionCode)
	{
	case EXCEPTION_ACCESS_VIOLATION:         return "EXCEPTION_ACCESS_VIOLATION";
	case EXCEPTION_DATATYPE_MISALIGNMENT:    return "EXCEPTION_DATATYPE_MISALIGNMENT";
	case EXCEPTION_BREAKPOINT:               return "EXCEPTION_BREAKPOINT";
	case EXCEPTION_SINGLE_STEP:              return "EXCEPTION_SINGLE_STEP";
	case EXCEPTION_ARRAY_BOUNDS_EXCEEDED:    return "EXCEPTION_ARRAY_BOUNDS_EXCEEDED";
	case EXCEPTION_FLT_DENORMAL_OPERAND:     return "EXCEPTION_FLT_DENORMAL_OPERAND";
	case EXCEPTION_FLT_DIVIDE_BY_ZERO:       return "EXCEPTION_FLT_DIVIDE_BY_ZERO";
	case EXCEPTION_FLT_INEXACT_RESULT:       return "EXCEPTION_FLT_INEXACT_RESULT";
	case EXCEPTION_FLT_INVALID_OPERATION:    return "EXCEPTION_FLT_INVALID_OPERATION";
	case EXCEPTION_FLT_OVERFLOW:             return "EXCEPTION_FLT_OVERFLOW";
	case EXCEPTION_FLT_STACK_CHECK:          return "EXCEPTION_FLT_STACK_CHECK";
	case EXCEPTION_FLT_UNDERFLOW:            return "EXCEPTION_FLT_UNDERFLOW";
	case EXCEPTION_INT_DIVIDE_BY_ZERO:       return "EXCEPTION_INT_DIVIDE_BY_ZERO";
	case EXCEPTION_INT_OVERFLOW:             return "EXCEPTION_INT_OVERFLOW";
	case EXCEPTION_PRIV_INSTRUCTION:         return "EXCEPTION_PRIV_INSTRUCTION";
	case EXCEPTION_IN_PAGE_ERROR:            return "EXCEPTION_IN_PAGE_ERROR";
	case EXCEPTION_ILLEGAL_INSTRUCTION:      return "EXCEPTION_ILLEGAL_INSTRUCTION";
	case EXCEPTION_NONCONTINUABLE_EXCEPTION: return "EXCEPTION_NONCONTINUABLE_EXCEPTION";
	case EXCEPTION_STACK_OVERFLOW:           return "EXCEPTION_STACK_OVERFLOW";
	case EXCEPTION_INVALID_DISPOSITION:      return "EXCEPTION_INVALID_DISPOSITION";
	case EXCEPTION_GUARD_PAGE:               return "EXCEPTION_GUARD_PAGE";
	case EXCEPTION_INVALID_HANDLE:           return "EXCEPTION_INVALID_HANDLE";
	case 3765269347:                         return "RUNTIME_EXCEPTION";
	}
	// clang-format on
	return "UNKNOWN_EXCEPTION";
}

//-----------------------------------------------------------------------------
// Purpose: Returns true if exception is known
//-----------------------------------------------------------------------------
bool CCrashHandler::IsExceptionFatal() const
{
	return IsExceptionFatal(m_pExceptionInfos->ExceptionRecord->ExceptionCode);
}

//-----------------------------------------------------------------------------
// Purpose: Returns true if exception is known
//-----------------------------------------------------------------------------
bool CCrashHandler::IsExceptionFatal(DWORD dwExceptionCode) const
{
	// clang-format off
	switch (dwExceptionCode)
	{
	case EXCEPTION_ACCESS_VIOLATION:
	case EXCEPTION_DATATYPE_MISALIGNMENT:
	case EXCEPTION_BREAKPOINT:
	case EXCEPTION_SINGLE_STEP:
	case EXCEPTION_ARRAY_BOUNDS_EXCEEDED:
	case EXCEPTION_FLT_DENORMAL_OPERAND:
	case EXCEPTION_FLT_DIVIDE_BY_ZERO:
	case EXCEPTION_FLT_INEXACT_RESULT:
	case EXCEPTION_FLT_INVALID_OPERATION:
	case EXCEPTION_FLT_OVERFLOW:
	case EXCEPTION_FLT_STACK_CHECK:
	case EXCEPTION_FLT_UNDERFLOW:
	case EXCEPTION_INT_DIVIDE_BY_ZERO:
	case EXCEPTION_INT_OVERFLOW:
	case EXCEPTION_PRIV_INSTRUCTION:
	case EXCEPTION_IN_PAGE_ERROR:
	case EXCEPTION_ILLEGAL_INSTRUCTION:
	case EXCEPTION_NONCONTINUABLE_EXCEPTION:
	case EXCEPTION_STACK_OVERFLOW:
	case EXCEPTION_INVALID_DISPOSITION:
	case EXCEPTION_GUARD_PAGE:
	case EXCEPTION_INVALID_HANDLE:
		return true;
	}
	// clang-format on
	return false;
}

//-----------------------------------------------------------------------------
// Purpose: Shows a message box
//-----------------------------------------------------------------------------
void CCrashHandler::ShowPopUpMessage()
{
	if (m_bHasShownCrashMsg)
		return;

	m_bHasShownCrashMsg = true;

	if (!IsDedicatedServer())
	{
		std::string svMessage = fmt::format(
			"Northstar has crashed! Crash info can be found at {}/logs!\n\n{}\n{} + {}",
			GetNorthstarPrefix(),
			GetExceptionString(),
			m_svCrashedModule,
			m_svCrashedOffset);

		MessageBoxA(GetForegroundWindow(), svMessage.c_str(), "Northstar has crashed!", MB_ICONERROR | MB_OK);
	}
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCrashHandler::FormatException()
{
	spdlog::error("-------------------------------------------");
	spdlog::error("Northstar has crashed!");
	spdlog::error("\tVersion: {}", version);
	if (!m_svError.empty())
	{
		spdlog::info("\tEncountered an error when gathering crash information!");
		spdlog::info("\tWinApi Error: {}", m_svError.c_str());
	}
	spdlog::error("\t{}", GetExceptionString());

	DWORD dwExceptionCode = m_pExceptionInfos->ExceptionRecord->ExceptionCode;
	if (dwExceptionCode == EXCEPTION_ACCESS_VIOLATION || dwExceptionCode == EXCEPTION_IN_PAGE_ERROR)
	{
		ULONG_PTR uExceptionInfo0 = m_pExceptionInfos->ExceptionRecord->ExceptionInformation[0];
		ULONG_PTR uExceptionInfo1 = m_pExceptionInfos->ExceptionRecord->ExceptionInformation[1];

		if (!uExceptionInfo0)
			spdlog::error("\tAttempted to read from: {:#x}", uExceptionInfo1);
		else if (uExceptionInfo0 == 1)
			spdlog::error("\tAttempted to write to: {:#x}", uExceptionInfo1);
		else if (uExceptionInfo0 == 8)
			spdlog::error("\tData Execution Prevention (DEP) at: {:#x}", uExceptionInfo1);
		else
			spdlog::error("\tUnknown access violation at: {:#x}", uExceptionInfo1);
	}

	spdlog::error("\tAt: {} + {}", m_svCrashedModule, m_svCrashedOffset);
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCrashHandler::FormatCallstack()
{
	spdlog::error("Callstack:");

	PVOID pFrames[CRASHHANDLER_MAX_FRAMES];

	int iFrames = RtlCaptureStackBackTrace(0, CRASHHANDLER_MAX_FRAMES, pFrames, NULL);

	// Above call gives us frames after the crash occured, we only want to print the ones starting from where
	// the exception was called
	bool bSkipExceptionHandlingFrames = true;

	// We ran into an error when getting the offset, just print all frames
	if (m_svCrashedOffset.empty())
		bSkipExceptionHandlingFrames = false;

	for (int i = 0; i < iFrames; i++)
	{
		const CHAR* pszModuleFileName;

		LPCSTR pAddress = static_cast<LPCSTR>(pFrames[i]);
		HMODULE hModule;
		if (!GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, pAddress, &hModule))
		{
			pszModuleFileName = CRASHHANDLER_GETMODULEHANDLE_FAIL;
			// If we fail here it's too late to do any damage control
		}
		else
		{
			CHAR szModulePath[MAX_PATH];
			GetModuleFileNameExA(GetCurrentProcess(), hModule, szModulePath, sizeof(szModulePath));
			pszModuleFileName = strrchr(szModulePath, '\\') + 1;
		}

		// Get relative address
		LPCSTR pCrashOffset = reinterpret_cast<LPCSTR>(pAddress - reinterpret_cast<LPCSTR>(hModule));
		std::string svCrashOffset = fmt::format("{:#x}", reinterpret_cast<DWORD64>(pCrashOffset));

		// Should we log this frame
		if (bSkipExceptionHandlingFrames)
		{
			if (m_svCrashedModule == pszModuleFileName && m_svCrashedOffset == svCrashOffset)
			{
				bSkipExceptionHandlingFrames = false;
			}
			else
			{
				continue;
			}
		}

		// Log module + offset
		spdlog::error("\t{} + {:#x}", pszModuleFileName, reinterpret_cast<DWORD64>(pCrashOffset));
	}
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCrashHandler::FormatFlags(const CHAR* pszRegister, DWORD nValue)
{
	spdlog::error("\t{}: {:#b}", pszRegister, nValue);
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCrashHandler::FormatIntReg(const CHAR* pszRegister, DWORD64 nValue)
{
	spdlog::error("\t{}: {:#x}", pszRegister, nValue);
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCrashHandler::FormatFloatReg(const CHAR* pszRegister, M128A nValue)
{
	DWORD nVec[4] = {
		static_cast<DWORD>(nValue.Low & UINT_MAX),
		static_cast<DWORD>(nValue.Low >> 32),
		static_cast<DWORD>(nValue.High & UINT_MAX),
		static_cast<DWORD>(nValue.High >> 32)};

	spdlog::error(
		"\t{}: [ {:G}, {:G}, {:G}, {:G} ]; [ {:#x}, {:#x}, {:#x}, {:#x} ]",
		pszRegister,
		static_cast<float>(nVec[0]),
		static_cast<float>(nVec[1]),
		static_cast<float>(nVec[2]),
		static_cast<float>(nVec[3]),
		nVec[0],
		nVec[1],
		nVec[2],
		nVec[3]);
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCrashHandler::FormatRegisters()
{
	spdlog::error("Registers:");

	PCONTEXT pContext = m_pExceptionInfos->ContextRecord;

	FormatFlags("Flags:", pContext->ContextFlags);

	FormatIntReg("Rax", pContext->Rax);
	FormatIntReg("Rcx", pContext->Rcx);
	FormatIntReg("Rdx", pContext->Rdx);
	FormatIntReg("Rbx", pContext->Rbx);
	FormatIntReg("Rsp", pContext->Rsp);
	FormatIntReg("Rbp", pContext->Rbp);
	FormatIntReg("Rsi", pContext->Rsi);
	FormatIntReg("Rdi", pContext->Rdi);
	FormatIntReg("R8 ", pContext->R8);
	FormatIntReg("R9 ", pContext->R9);
	FormatIntReg("R10", pContext->R10);
	FormatIntReg("R11", pContext->R11);
	FormatIntReg("R12", pContext->R12);
	FormatIntReg("R13", pContext->R13);
	FormatIntReg("R14", pContext->R14);
	FormatIntReg("R15", pContext->R15);
	FormatIntReg("Rip", pContext->Rip);

	FormatFloatReg("Xmm0 ", pContext->Xmm0);
	FormatFloatReg("Xmm1 ", pContext->Xmm1);
	FormatFloatReg("Xmm2 ", pContext->Xmm2);
	FormatFloatReg("Xmm3 ", pContext->Xmm3);
	FormatFloatReg("Xmm4 ", pContext->Xmm4);
	FormatFloatReg("Xmm5 ", pContext->Xmm5);
	FormatFloatReg("Xmm6 ", pContext->Xmm6);
	FormatFloatReg("Xmm7 ", pContext->Xmm7);
	FormatFloatReg("Xmm8 ", pContext->Xmm8);
	FormatFloatReg("Xmm9 ", pContext->Xmm9);
	FormatFloatReg("Xmm10", pContext->Xmm10);
	FormatFloatReg("Xmm11", pContext->Xmm11);
	FormatFloatReg("Xmm12", pContext->Xmm12);
	FormatFloatReg("Xmm13", pContext->Xmm13);
	FormatFloatReg("Xmm14", pContext->Xmm14);
	FormatFloatReg("Xmm15", pContext->Xmm15);
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCrashHandler::FormatLoadedMods()
{
	if (g_pModManager)
	{
		spdlog::error("Enabled mods:");
		for (const Mod& mod : g_pModManager->m_LoadedMods)
		{
			if (!mod.m_bEnabled)
				continue;

			spdlog::error("\t{}", mod.Name);
		}

		spdlog::error("Disabled mods:");
		for (const Mod& mod : g_pModManager->m_LoadedMods)
		{
			if (mod.m_bEnabled)
				continue;

			spdlog::error("\t{}", mod.Name);
		}
	}
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCrashHandler::FormatLoadedPlugins()
{
	if (g_pPluginManager)
	{
		spdlog::error("Loaded Plugins:");
		for (const Plugin& plugin : g_pPluginManager->m_vLoadedPlugins)
		{
			spdlog::error("\t{}", plugin.name);
		}
	}
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCrashHandler::FormatModules()
{
	spdlog::error("Loaded modules:");
	HMODULE hModules[1024];
	DWORD cbNeeded;

	if (EnumProcessModules(GetCurrentProcess(), hModules, sizeof(hModules), &cbNeeded))
	{
		for (DWORD i = 0; i < (cbNeeded / sizeof(HMODULE)); i++)
		{
			CHAR szModulePath[MAX_PATH];
			if (GetModuleFileNameExA(GetCurrentProcess(), hModules[i], szModulePath, sizeof(szModulePath)))
			{
				const CHAR* pszModuleFileName = strrchr(szModulePath, '\\') + 1;
				spdlog::error("\t{}", pszModuleFileName);
			}
		}
	}
}

//-----------------------------------------------------------------------------
// Purpose: Writes minidump to disk
//-----------------------------------------------------------------------------
void CCrashHandler::WriteMinidump()
{
	time_t time = std::time(nullptr);
	tm currentTime = *std::localtime(&time);
	std::stringstream stream;
	stream << std::put_time(&currentTime, (GetNorthstarPrefix() + "/logs/nsdump%Y-%m-%d %H-%M-%S.dmp").c_str());

	HANDLE hMinidumpFile = CreateFileA(stream.str().c_str(), GENERIC_WRITE, FILE_SHARE_READ, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
	if (hMinidumpFile)
	{
		MINIDUMP_EXCEPTION_INFORMATION dumpExceptionInfo;
		dumpExceptionInfo.ThreadId = GetCurrentThreadId();
		dumpExceptionInfo.ExceptionPointers = m_pExceptionInfos;
		dumpExceptionInfo.ClientPointers = false;

		MiniDumpWriteDump(
			GetCurrentProcess(),
			GetCurrentProcessId(),
			hMinidumpFile,
			MINIDUMP_TYPE(MiniDumpWithIndirectlyReferencedMemory | MiniDumpScanMemory),
			&dumpExceptionInfo,
			nullptr,
			nullptr);
		CloseHandle(hMinidumpFile);
	}
	else
		spdlog::error("Failed to write minidump file {}!", stream.str());
}

//-----------------------------------------------------------------------------
CCrashHandler* g_pCrashHandler = nullptr;
