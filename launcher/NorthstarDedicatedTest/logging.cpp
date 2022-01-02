#include "pch.h"
#include "logging.h"
#include "sourceconsole.h"
#include "spdlog/sinks/basic_file_sink.h"
#include "hookutils.h"
#include "gameutils.h"
#include "dedicated.h"
#include <iomanip>
#include <sstream>
#include <Psapi.h>
#include <minidumpapiset.h>

long __stdcall ExceptionFilter(EXCEPTION_POINTERS* exceptionInfo)
{
	static bool logged = false;
	if (logged)
		return EXCEPTION_CONTINUE_SEARCH;

	if (!IsDebuggerPresent())
	{
		const DWORD exceptionCode = exceptionInfo->ExceptionRecord->ExceptionCode;
		if (exceptionCode != EXCEPTION_ACCESS_VIOLATION && exceptionCode != EXCEPTION_ARRAY_BOUNDS_EXCEEDED &&
			exceptionCode != EXCEPTION_DATATYPE_MISALIGNMENT && exceptionCode != EXCEPTION_FLT_DENORMAL_OPERAND &&
			exceptionCode != EXCEPTION_FLT_DIVIDE_BY_ZERO && exceptionCode != EXCEPTION_FLT_INEXACT_RESULT &&
			exceptionCode != EXCEPTION_FLT_INVALID_OPERATION && exceptionCode != EXCEPTION_FLT_OVERFLOW &&
			exceptionCode != EXCEPTION_FLT_STACK_CHECK && exceptionCode != EXCEPTION_FLT_UNDERFLOW &&
			exceptionCode != EXCEPTION_ILLEGAL_INSTRUCTION && exceptionCode != EXCEPTION_IN_PAGE_ERROR &&
			exceptionCode != EXCEPTION_INT_DIVIDE_BY_ZERO && exceptionCode != EXCEPTION_INT_OVERFLOW &&
			exceptionCode != EXCEPTION_INVALID_DISPOSITION && exceptionCode != EXCEPTION_NONCONTINUABLE_EXCEPTION &&
			exceptionCode != EXCEPTION_PRIV_INSTRUCTION && exceptionCode != EXCEPTION_STACK_OVERFLOW)
			return EXCEPTION_CONTINUE_SEARCH;

		std::stringstream exceptionCause;
		switch (exceptionCode)
		{
		case EXCEPTION_ACCESS_VIOLATION:
		case EXCEPTION_IN_PAGE_ERROR:
		{
			exceptionCause << "Cause: Access Violation" << std::endl;

			auto exceptionInfo0 = exceptionInfo->ExceptionRecord->ExceptionInformation[0];
			auto exceptionInfo1 = exceptionInfo->ExceptionRecord->ExceptionInformation[1];

			if (!exceptionInfo0)
				exceptionCause << "Attempted to read from: 0x" << std::setw(8) << std::setfill('0') << std::hex << exceptionInfo1;
			else if (exceptionInfo0 == 1)
				exceptionCause << "Attempted to write to: 0x" << std::setw(8) << std::setfill('0') << std::hex << exceptionInfo1;
			else if (exceptionInfo0 == 8)
				exceptionCause << "Data Execution Prevention (DEP) at: 0x" << std::setw(8) << std::setfill('0') << std::hex << exceptionInfo1;
			else
				exceptionCause << "Unknown access violation at: 0x" << std::setw(8) << std::setfill('0') << std::hex << exceptionInfo1;

			break;
		}
		case EXCEPTION_ARRAY_BOUNDS_EXCEEDED:
			exceptionCause << "Cause: Array bounds exceeded";
			break;
		case EXCEPTION_DATATYPE_MISALIGNMENT:
			exceptionCause << "Cause: Datatype misalignment";
			break;
		case EXCEPTION_FLT_DENORMAL_OPERAND:
			exceptionCause << "Cause: Denormal operand";
			break;
		case EXCEPTION_FLT_DIVIDE_BY_ZERO:
		case EXCEPTION_INT_DIVIDE_BY_ZERO:
			exceptionCause << "Cause: Divide by zero";
			break;
		case EXCEPTION_FLT_INEXACT_RESULT:
			exceptionCause << "Cause: Inexact result";
			break;
		case EXCEPTION_FLT_INVALID_OPERATION:
			exceptionCause << "Cause: invalid operation";
			break;
		case EXCEPTION_FLT_OVERFLOW:
		case EXCEPTION_INT_OVERFLOW:
			exceptionCause << "Cause: Numeric overflow";
			break;
		case EXCEPTION_FLT_UNDERFLOW:
			exceptionCause << "Cause: Numeric underflow";
			break;
		case EXCEPTION_FLT_STACK_CHECK:
			exceptionCause << "Cause: Stack check";
			break;
		case EXCEPTION_ILLEGAL_INSTRUCTION:
			exceptionCause << "Cause: Illegal instruction";
			break;
		case EXCEPTION_INVALID_DISPOSITION:
			exceptionCause << "Cause: Invalid disposition";
			break;
		case EXCEPTION_NONCONTINUABLE_EXCEPTION:
			exceptionCause << "Cause: Noncontinuable exception";
			break;
		case EXCEPTION_PRIV_INSTRUCTION:
			exceptionCause << "Cause: Priv instruction";
			break;
		case EXCEPTION_STACK_OVERFLOW:
			exceptionCause << "Cause: Stack overflow";
			break;
		default:
			exceptionCause << "Cause: Unknown";
			break;
		}

		void* exceptionAddress = exceptionInfo->ExceptionRecord->ExceptionAddress;

		HMODULE crashedModuleHandle;
		GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, static_cast<LPCSTR>(exceptionAddress), &crashedModuleHandle);

		MODULEINFO crashedModuleInfo;
		GetModuleInformation(GetCurrentProcess(), crashedModuleHandle, &crashedModuleInfo, sizeof(crashedModuleInfo));

		char crashedModuleFullName[MAX_PATH];
		GetModuleFileNameExA(GetCurrentProcess(), crashedModuleHandle, crashedModuleFullName, MAX_PATH);
		char* crashedModuleName = strrchr(crashedModuleFullName, '\\') + 1;

		DWORD crashedModuleOffset = ((DWORD)exceptionAddress) - ((DWORD)crashedModuleInfo.lpBaseOfDll);
		CONTEXT* exceptionContext = exceptionInfo->ContextRecord;

		spdlog::error("Northstar has crashed! a minidump has been written and exception info is available below:");
		spdlog::error(exceptionCause.str());
		spdlog::error("At: {} + {}", crashedModuleName, (void*)crashedModuleOffset);

		PVOID framesToCapture[62];
		int frames = RtlCaptureStackBackTrace(0, 62, framesToCapture, NULL);
		for (int i = 0; i < frames; i++)
		{
			HMODULE backtraceModuleHandle;
			GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, static_cast<LPCSTR>(framesToCapture[i]), &backtraceModuleHandle);

			char backtraceModuleFullName[MAX_PATH];
			GetModuleFileNameExA(GetCurrentProcess(), backtraceModuleHandle, backtraceModuleFullName, MAX_PATH);
			char* backtraceModuleName = strrchr(backtraceModuleFullName, '\\') + 1;

			spdlog::error("    {} + {}", backtraceModuleName, (void*)framesToCapture[i]);
		}

		spdlog::error("RAX: 0x{0:x}", exceptionContext->Rax);
		spdlog::error("RBX: 0x{0:x}", exceptionContext->Rbx);
		spdlog::error("RCX: 0x{0:x}", exceptionContext->Rcx);
		spdlog::error("RDX: 0x{0:x}", exceptionContext->Rdx);
		spdlog::error("RSI: 0x{0:x}", exceptionContext->Rsi);
		spdlog::error("RDI: 0x{0:x}", exceptionContext->Rdi);
		spdlog::error("RBP: 0x{0:x}", exceptionContext->Rbp);
		spdlog::error("RSP: 0x{0:x}", exceptionContext->Rsp);
		spdlog::error("R8: 0x{0:x}", exceptionContext->R8);
		spdlog::error("R9: 0x{0:x}", exceptionContext->R9);
		spdlog::error("R10: 0x{0:x}", exceptionContext->R10);
		spdlog::error("R11: 0x{0:x}", exceptionContext->R11);
		spdlog::error("R12: 0x{0:x}", exceptionContext->R12);
		spdlog::error("R13: 0x{0:x}", exceptionContext->R13);
		spdlog::error("R14: 0x{0:x}", exceptionContext->R14);
		spdlog::error("R15: 0x{0:x}", exceptionContext->R15);

		time_t time = std::time(nullptr);
		tm currentTime = *std::localtime(&time);
		std::stringstream stream;
		stream << std::put_time(&currentTime, "R2Northstar/logs/nsdump%d-%m-%Y %H-%M-%S.dmp");

		auto hMinidumpFile = CreateFileA(stream.str().c_str(), GENERIC_WRITE, FILE_SHARE_READ, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
		if (hMinidumpFile)
		{
			MINIDUMP_EXCEPTION_INFORMATION dumpExceptionInfo;
			dumpExceptionInfo.ThreadId = GetCurrentThreadId();
			dumpExceptionInfo.ExceptionPointers = exceptionInfo;
			dumpExceptionInfo.ClientPointers = false;

			MiniDumpWriteDump(GetCurrentProcess(), GetCurrentProcessId(), hMinidumpFile, MINIDUMP_TYPE(MiniDumpWithIndirectlyReferencedMemory | MiniDumpScanMemory), &dumpExceptionInfo, nullptr, nullptr);
			CloseHandle(hMinidumpFile);
		}
		else
			spdlog::error("Failed to write minidump file {}!", stream.str());

		if (!IsDedicated())
			MessageBoxA(0, "Northstar has crashed! A crash log and dump can be found in R2Northstar/logs", "Northstar has crashed!", MB_ICONERROR | MB_OK);

	}

	logged = true;
	return EXCEPTION_EXECUTE_HANDLER;
}


void InitialiseLogging()
{
	AddVectoredExceptionHandler(TRUE, ExceptionFilter);

	AllocConsole();
	freopen("CONOUT$", "w", stdout);

	spdlog::default_logger()->set_pattern("[%H:%M:%S] [%l] %v");
	spdlog::flush_on(spdlog::level::info);

	// log file stuff
	// generate log file, format should be nslog%d-%m-%Y %H-%M-%S.txt in gamedir/R2Northstar/logs
	// todo: might be good to delete logs that are too old
	time_t time = std::time(nullptr);
	tm currentTime = *std::localtime(&time);
	std::stringstream stream;
	stream << std::put_time(&currentTime, "R2Northstar/logs/nslog%d-%m-%Y %H-%M-%S.txt");

	// create logger
	spdlog::default_logger()->sinks().push_back(std::make_shared<spdlog::sinks::basic_file_sink_mt>(stream.str(), false));
}

ConVar* Cvar_spewlog_enable;

enum SpewType_t
{
	SPEW_MESSAGE = 0,
	SPEW_WARNING,
	SPEW_ASSERT,
	SPEW_ERROR,
	SPEW_LOG,
	SPEW_TYPE_COUNT
};

typedef void(*EngineSpewFuncType)();
EngineSpewFuncType EngineSpewFunc;

void EngineSpewFuncHook(void* engineServer, SpewType_t type, const char* format, va_list args)
{
	if (!Cvar_spewlog_enable->m_nValue)
		return;

	const char* typeStr;
	switch (type)
	{
		case SPEW_MESSAGE:
		{
			typeStr = "SPEW_MESSAGE";
			break;
		}

		case SPEW_WARNING:
		{
			typeStr = "SPEW_WARNING";
			break;
		}

		case SPEW_ASSERT:
		{
			typeStr = "SPEW_ASSERT";
			break;
		}

		case SPEW_ERROR:
		{
			typeStr = "SPEW_ERROR";
			break;
		}

		case SPEW_LOG:
		{
			typeStr = "SPEW_LOG";
			break;
		}

		default:
		{
			typeStr = "SPEW_UNKNOWN";
			break;
		}
	}

	char formatted[2048];
	bool shouldFormat = true;

	// because titanfall 2 is quite possibly the worst thing to yet exist, it sometimes gives invalid specifiers which will crash
	// ttf2sdk had a way to prevent them from crashing but it doesnt work in debug builds
	// so we use this instead
	for (int i = 0; format[i]; i++)
	{
		if (format[i] == '%')
		{
			switch (format[i + 1])
			{
				// this is fucking awful lol
				case 'd':
				case 'i':
				case 'u':
				case 'x':
				case 'X':
				case 'f':
				case 'F':
				case 'g':
				case 'G':
				case 'a':
				case 'A':
				case 'c':
				case 's':
				case 'p':
				case 'n':
				case '%':
				case '-':
				case '+':
				case ' ':
				case '#':
				case '*':
				case '0':
				case '1':
				case '2':
				case '3':
				case '4':
				case '5':
				case '6':
				case '7':
				case '8':
				case '9':
					break;
				
				default:
				{
					shouldFormat = false;
					break;
				}
			}
		}
	}

	if (shouldFormat)
		vsnprintf(formatted, sizeof(formatted), format, args);
	else
	{
		spdlog::warn("Failed to format {} \"{}\"", typeStr, format);
	}

	spdlog::info("[SERVER {}] {}", typeStr, formatted);
}

void InitialiseEngineSpewFuncHooks(HMODULE baseAddress)
{
	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x11CA80, EngineSpewFuncHook, reinterpret_cast<LPVOID*>(&EngineSpewFunc));

	Cvar_spewlog_enable = RegisterConVar("spewlog_enable", "1", FCVAR_NONE, "Enables/disables whether the engine spewfunc should be logged");
}