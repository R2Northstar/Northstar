#include "pch.h"
#include "crashhandler.h"
#include "dedicated/dedicated.h"
#include "config/profile.h"
#include "util/version.h"
#include "mods/modmanager.h"

#include <minidumpapiset.h>

HANDLE hExceptionFilter;

std::shared_ptr<ExceptionLog> storedException {};

#define RUNTIME_EXCEPTION 3765269347
// clang format did this :/
std::map<int, std::string> ExceptionNames = {
	{EXCEPTION_ACCESS_VIOLATION, "Access Violation"},			{EXCEPTION_IN_PAGE_ERROR, "Access Violation"},
	{EXCEPTION_ARRAY_BOUNDS_EXCEEDED, "Array bounds exceeded"}, {EXCEPTION_DATATYPE_MISALIGNMENT, "Datatype misalignment"},
	{EXCEPTION_FLT_DENORMAL_OPERAND, "Denormal operand"},		{EXCEPTION_FLT_DIVIDE_BY_ZERO, "Divide by zero (float)"},
	{EXCEPTION_FLT_INEXACT_RESULT, "Inexact float result"},		{EXCEPTION_FLT_INVALID_OPERATION, "Invalid operation"},
	{EXCEPTION_FLT_OVERFLOW, "Numeric overflow (float)"},		{EXCEPTION_FLT_STACK_CHECK, "Stack check"},
	{EXCEPTION_FLT_UNDERFLOW, "Numeric underflow (float)"},		{EXCEPTION_ILLEGAL_INSTRUCTION, "Illegal instruction"},
	{EXCEPTION_INT_DIVIDE_BY_ZERO, "Divide by zero (int)"},		{EXCEPTION_INT_OVERFLOW, "Numeric overfloat (int)"},
	{EXCEPTION_INVALID_DISPOSITION, "Invalid disposition"},		{EXCEPTION_NONCONTINUABLE_EXCEPTION, "Non-continuable exception"},
	{EXCEPTION_PRIV_INSTRUCTION, "Priviledged instruction"},	{EXCEPTION_STACK_OVERFLOW, "Stack overflow"},
	{RUNTIME_EXCEPTION, "Uncaught runtime exception:"},
};

void PrintExceptionLog(ExceptionLog& exc)
{
	// General crash message
	spdlog::error("Northstar version: {}", version);
	spdlog::error("Northstar has crashed! a minidump has been written and exception info is available below:");
	if (g_pModManager)
	{
		spdlog::error("Loaded mods: ");
		for (const auto& mod : g_pModManager->m_LoadedMods)
		{
			if (mod.m_bEnabled)
			{
				spdlog::error("{} {}", mod.Name, mod.Version);
			}
		}
	}
	spdlog::error(exc.cause);
	// If this was a runtime error, print the message
	if (exc.runtimeInfo.length() != 0)
		spdlog::error("\"{}\"", exc.runtimeInfo);
	spdlog::error("At: {} + {}", exc.trace[0].name, exc.trace[0].relativeAddress);
	spdlog::error("");
	spdlog::error("Stack trace:");

	// Generate format string for stack trace
	std::stringstream formatString;
	formatString << "    {:<" << exc.longestModuleNameLength + 2 << "} {:<" << exc.longestRelativeAddressLength << "} {}";
	std::string guide = fmt::format(formatString.str(), "Module Name", "Offset", "Full Address");
	std::string line(guide.length() + 2, '-');
	spdlog::error(guide);
	spdlog::error(line);

	for (const auto& module : exc.trace)
		spdlog::error(formatString.str(), module.name, module.relativeAddress, module.address);

	// Print dump of most CPU registers
	spdlog::error("");
	for (const auto& reg : exc.registerDump)
		spdlog::error(reg);

	if (!IsDedicatedServer())
		MessageBoxA(
			0,
			"Northstar has crashed! Crash info can be found in R2Northstar/logs",
			"Northstar has crashed!",
			MB_ICONERROR | MB_OK | MB_SYSTEMMODAL);
}

std::string GetExceptionName(ExceptionLog& exc)
{
	const DWORD exceptionCode = exc.exceptionRecord.ExceptionCode;
	auto name = ExceptionNames[exceptionCode];
	if (exceptionCode == EXCEPTION_ACCESS_VIOLATION || exceptionCode == EXCEPTION_IN_PAGE_ERROR)
	{
		std::stringstream returnString;
		returnString << name << ": ";

		auto exceptionInfo0 = exc.exceptionRecord.ExceptionInformation[0];
		auto exceptionInfo1 = exc.exceptionRecord.ExceptionInformation[1];

		if (!exceptionInfo0)
			returnString << "Attempted to read from: 0x" << (void*)exceptionInfo1;
		else if (exceptionInfo0 == 1)
			returnString << "Attempted to write to: 0x" << (void*)exceptionInfo1;
		else if (exceptionInfo0 == 8)
			returnString << "Data Execution Prevention (DEP) at: 0x" << (void*)std::hex << exceptionInfo1;
		else
			returnString << "Unknown access violation at: 0x" << (void*)exceptionInfo1;
		return returnString.str();
	}
	return name;
}

// Custom formatter for the Xmm registers
template <> struct fmt::formatter<M128A> : fmt::formatter<string_view>
{
	template <typename FormatContext> auto format(const M128A& obj, FormatContext& ctx)
	{
		// Masking the top and bottom half of the long long
		int v1 = obj.Low & INT_MAX;
		int v2 = obj.Low >> 32;
		int v3 = obj.High & INT_MAX;
		int v4 = obj.High >> 32;
		return fmt::format_to(
			ctx.out(),
			"[ {:G}, {:G}, {:G}, {:G}], [ 0x{:x}, 0x{:x}, 0x{:x}, 0x{:x} ]",
			*reinterpret_cast<float*>(&v1),
			*reinterpret_cast<float*>(&v2),
			*reinterpret_cast<float*>(&v3),
			*reinterpret_cast<float*>(&v4),
			v1,
			v2,
			v3,
			v4);
	}
};

void GenerateTrace(ExceptionLog& exc, bool skipErrorHandlingFrames = true, int numSkipFrames = 0)
{

	MODULEINFO crashedModuleInfo;
	GetModuleInformation(GetCurrentProcess(), exc.crashedModule, &crashedModuleInfo, sizeof(crashedModuleInfo));

	char crashedModuleFullName[MAX_PATH];
	GetModuleFileNameExA(GetCurrentProcess(), exc.crashedModule, crashedModuleFullName, MAX_PATH);
	char* crashedModuleName = strrchr(crashedModuleFullName, '\\') + 1;

	DWORD64 crashedModuleOffset = ((DWORD64)exc.exceptionRecord.ExceptionAddress) - ((DWORD64)crashedModuleInfo.lpBaseOfDll);

	PVOID framesToCapture[62];
	int frames = RtlCaptureStackBackTrace(0, 62, framesToCapture, NULL);
	bool haveSkippedErrorHandlingFrames = false;

	for (int i = 0; i < frames; i++)
	{

		HMODULE backtraceModuleHandle;
		GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, static_cast<LPCSTR>(framesToCapture[i]), &backtraceModuleHandle);

		char backtraceModuleFullName[MAX_PATH];
		GetModuleFileNameExA(GetCurrentProcess(), backtraceModuleHandle, backtraceModuleFullName, MAX_PATH);
		char* backtraceModuleName = strrchr(backtraceModuleFullName, '\\') + 1;

		if (!haveSkippedErrorHandlingFrames)
		{
			if (!strncmp(backtraceModuleFullName, crashedModuleFullName, MAX_PATH) &&
				!strncmp(backtraceModuleName, crashedModuleName, MAX_PATH))
			{
				haveSkippedErrorHandlingFrames = true;
			}
			else
			{
				continue;
			}
		}

		if (numSkipFrames > 0)
		{
			numSkipFrames--;
			continue;
		}

		void* actualAddress = (void*)framesToCapture[i];
		void* relativeAddress = (void*)(uintptr_t(actualAddress) - uintptr_t(backtraceModuleHandle));
		std::string s_moduleName {backtraceModuleName};
		std::string s_relativeAddress {fmt::format("{}", relativeAddress)};
		// These are used for formatting later on
		if (s_moduleName.length() > exc.longestModuleNameLength)
		{
			exc.longestModuleNameLength = s_moduleName.length();
		}
		if (s_relativeAddress.length() > exc.longestRelativeAddressLength)
		{
			exc.longestRelativeAddressLength = s_relativeAddress.length();
		}

		exc.trace.push_back(BacktraceModule {s_moduleName, s_relativeAddress, fmt::format("{}", actualAddress)});
	}

	CONTEXT* exceptionContext = &exc.contextRecord;

	exc.registerDump.push_back(fmt::format("Flags: 0b{0:b}", exceptionContext->ContextFlags));
	exc.registerDump.push_back(fmt::format("RIP: 0x{0:x}", exceptionContext->Rip));
	exc.registerDump.push_back(fmt::format("CS : 0x{0:x}", exceptionContext->SegCs));
	exc.registerDump.push_back(fmt::format("DS : 0x{0:x}", exceptionContext->SegDs));
	exc.registerDump.push_back(fmt::format("ES : 0x{0:x}", exceptionContext->SegEs));
	exc.registerDump.push_back(fmt::format("SS : 0x{0:x}", exceptionContext->SegSs));
	exc.registerDump.push_back(fmt::format("FS : 0x{0:x}", exceptionContext->SegFs));
	exc.registerDump.push_back(fmt::format("GS : 0x{0:x}", exceptionContext->SegGs));

	exc.registerDump.push_back(fmt::format("RAX: 0x{0:x}", exceptionContext->Rax));
	exc.registerDump.push_back(fmt::format("RBX: 0x{0:x}", exceptionContext->Rbx));
	exc.registerDump.push_back(fmt::format("RCX: 0x{0:x}", exceptionContext->Rcx));
	exc.registerDump.push_back(fmt::format("RDX: 0x{0:x}", exceptionContext->Rdx));
	exc.registerDump.push_back(fmt::format("RSI: 0x{0:x}", exceptionContext->Rsi));
	exc.registerDump.push_back(fmt::format("RDI: 0x{0:x}", exceptionContext->Rdi));
	exc.registerDump.push_back(fmt::format("RBP: 0x{0:x}", exceptionContext->Rbp));
	exc.registerDump.push_back(fmt::format("RSP: 0x{0:x}", exceptionContext->Rsp));
	exc.registerDump.push_back(fmt::format("R8 : 0x{0:x}", exceptionContext->R8));
	exc.registerDump.push_back(fmt::format("R9 : 0x{0:x}", exceptionContext->R9));
	exc.registerDump.push_back(fmt::format("R10: 0x{0:x}", exceptionContext->R10));
	exc.registerDump.push_back(fmt::format("R11: 0x{0:x}", exceptionContext->R11));
	exc.registerDump.push_back(fmt::format("R12: 0x{0:x}", exceptionContext->R12));
	exc.registerDump.push_back(fmt::format("R13: 0x{0:x}", exceptionContext->R13));
	exc.registerDump.push_back(fmt::format("R14: 0x{0:x}", exceptionContext->R14));
	exc.registerDump.push_back(fmt::format("R15: 0x{0:x}", exceptionContext->R15));

	exc.registerDump.push_back(fmt::format("Xmm0 : {}", exceptionContext->Xmm0));
	exc.registerDump.push_back(fmt::format("Xmm1 : {}", exceptionContext->Xmm1));
	exc.registerDump.push_back(fmt::format("Xmm2 : {}", exceptionContext->Xmm2));
	exc.registerDump.push_back(fmt::format("Xmm3 : {}", exceptionContext->Xmm3));
	exc.registerDump.push_back(fmt::format("Xmm4 : {}", exceptionContext->Xmm4));
	exc.registerDump.push_back(fmt::format("Xmm5 : {}", exceptionContext->Xmm5));
	exc.registerDump.push_back(fmt::format("Xmm6 : {}", exceptionContext->Xmm6));
	exc.registerDump.push_back(fmt::format("Xmm7 : {}", exceptionContext->Xmm7));
	exc.registerDump.push_back(fmt::format("Xmm8 : {}", exceptionContext->Xmm8));
	exc.registerDump.push_back(fmt::format("Xmm9 : {}", exceptionContext->Xmm9));
	exc.registerDump.push_back(fmt::format("Xmm10: {}", exceptionContext->Xmm10));
	exc.registerDump.push_back(fmt::format("Xmm11: {}", exceptionContext->Xmm11));
	exc.registerDump.push_back(fmt::format("Xmm12: {}", exceptionContext->Xmm12));
	exc.registerDump.push_back(fmt::format("Xmm13: {}", exceptionContext->Xmm13));
	exc.registerDump.push_back(fmt::format("Xmm14: {}", exceptionContext->Xmm14));
	exc.registerDump.push_back(fmt::format("Xmm15: {}", exceptionContext->Xmm15));
}

void CreateMiniDump(EXCEPTION_POINTERS* exceptionInfo)
{
	time_t time = std::time(nullptr);
	tm currentTime = *std::localtime(&time);
	std::stringstream stream;
	stream << std::put_time(&currentTime, (GetNorthstarPrefix() + "/logs/nsdump%Y-%m-%d %H-%M-%S.dmp").c_str());

	auto hMinidumpFile = CreateFileA(stream.str().c_str(), GENERIC_WRITE, FILE_SHARE_READ, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
	if (hMinidumpFile)
	{
		MINIDUMP_EXCEPTION_INFORMATION dumpExceptionInfo;
		dumpExceptionInfo.ThreadId = GetCurrentThreadId();
		dumpExceptionInfo.ExceptionPointers = exceptionInfo;
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

long GenerateExceptionLog(EXCEPTION_POINTERS* exceptionInfo)
{
	storedException->exceptionRecord = *exceptionInfo->ExceptionRecord;
	storedException->contextRecord = *exceptionInfo->ContextRecord;
	const DWORD exceptionCode = exceptionInfo->ExceptionRecord->ExceptionCode;

	void* exceptionAddress = exceptionInfo->ExceptionRecord->ExceptionAddress;

	storedException->cause = GetExceptionName(*storedException);

	HMODULE crashedModuleHandle;
	GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, static_cast<LPCSTR>(exceptionAddress), &crashedModuleHandle);

	storedException->crashedModule = crashedModuleHandle;

	// When encountering a runtime exception, we store the exception to be displayed later
	// We then have to return EXCEPTION_CONTINUE_SEARCH so that our runtime handler may be called
	// This might possibly cause some issues if client and server are crashing at the same time, but honestly i don't care
	if (exceptionCode == RUNTIME_EXCEPTION)
	{
		GenerateTrace(*storedException, false, 2);
		storedException = storedException;
		return EXCEPTION_CONTINUE_SEARCH;
	}

	GenerateTrace(*storedException, true, 0);
	CreateMiniDump(exceptionInfo);
	PrintExceptionLog(*storedException);
	return EXCEPTION_EXECUTE_HANDLER;
}

long __stdcall ExceptionFilter(EXCEPTION_POINTERS* exceptionInfo)
{
	if (!IsDebuggerPresent())
	{
		// Check if we are capable of handling this type of exception
		if (ExceptionNames.find(exceptionInfo->ExceptionRecord->ExceptionCode) == ExceptionNames.end())
			return EXCEPTION_CONTINUE_SEARCH;
		if (exceptionInfo->ExceptionRecord->ExceptionCode == RUNTIME_EXCEPTION)
		{
			storedException = std::make_shared<ExceptionLog>();
			storedException->exceptionRecord = *exceptionInfo->ExceptionRecord;
			storedException->contextRecord = *exceptionInfo->ContextRecord;
		}
		else
		{
			CreateMiniDump(exceptionInfo);
			return GenerateExceptionLog(exceptionInfo);
		}
	}

	return EXCEPTION_EXECUTE_HANDLER;
}

void RuntimeExceptionHandler()
{
	auto ptr = std::current_exception();
	if (ptr)
	{
		try
		{
			// This is to generate an actual std::exception object that we can then inspect
			std::rethrow_exception(ptr);
		}
		catch (std::exception& e)
		{
			storedException->runtimeInfo = e.what();
		}
		catch (...)
		{
			storedException->runtimeInfo = "Unknown runtime exception type";
		}
		EXCEPTION_POINTERS test {};
		test.ContextRecord = &storedException->contextRecord;
		test.ExceptionRecord = &storedException->exceptionRecord;
		CreateMiniDump(&test);
		GenerateExceptionLog(&test);
		PrintExceptionLog(*storedException);
		exit(-1);
	}
	else
	{
		spdlog::error(
			"std::current_exception() returned nullptr while being handled by RuntimeExceptionHandler. This should never happen!");
		std::abort();
	}
}

BOOL WINAPI ConsoleHandlerRoutine(DWORD eventCode)
{
	switch (eventCode)
	{
	case CTRL_CLOSE_EVENT:
		// User closed console, shut everything down
		spdlog::info("Exiting due to console close...");
		RemoveCrashHandler();
		exit(EXIT_SUCCESS);
		return FALSE;
	}

	return TRUE;
}

void InitialiseCrashHandler()
{
	hExceptionFilter = AddVectoredExceptionHandler(TRUE, ExceptionFilter);
	SetConsoleCtrlHandler(ConsoleHandlerRoutine, true);
	std::set_terminate(RuntimeExceptionHandler);
}

void RemoveCrashHandler()
{
	RemoveVectoredExceptionHandler(hExceptionFilter);
}
