#include "pch.h"
#include "crashhandler.h"
#include "dedicated.h"
#include "nsprefix.h"

#include <minidumpapiset.h>

HANDLE hExceptionFilter;

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
		exceptionCause << "Cause: ";
		switch (exceptionCode)
		{
		case EXCEPTION_ACCESS_VIOLATION:
		case EXCEPTION_IN_PAGE_ERROR:
		{
			exceptionCause << "Access Violation" << std::endl;

			auto exceptionInfo0 = exceptionInfo->ExceptionRecord->ExceptionInformation[0];
			auto exceptionInfo1 = exceptionInfo->ExceptionRecord->ExceptionInformation[1];

			if (!exceptionInfo0)
				exceptionCause << "Attempted to read from: 0x" << (void*)exceptionInfo1;
			else if (exceptionInfo0 == 1)
				exceptionCause << "Attempted to write to: 0x" << (void*)exceptionInfo1;
			else if (exceptionInfo0 == 8)
				exceptionCause << "Data Execution Prevention (DEP) at: 0x" << (void*)std::hex << exceptionInfo1;
			else
				exceptionCause << "Unknown access violation at: 0x" << (void*)exceptionInfo1;

			break;
		}
		case EXCEPTION_ARRAY_BOUNDS_EXCEEDED:
			exceptionCause << "Array bounds exceeded";
			break;
		case EXCEPTION_DATATYPE_MISALIGNMENT:
			exceptionCause << "Datatype misalignment";
			break;
		case EXCEPTION_FLT_DENORMAL_OPERAND:
			exceptionCause << "Denormal operand";
			break;
		case EXCEPTION_FLT_DIVIDE_BY_ZERO:
			exceptionCause << "Divide by zero (float)";
			break;
		case EXCEPTION_INT_DIVIDE_BY_ZERO:
			exceptionCause << "Divide by zero (int)";
			break;
		case EXCEPTION_FLT_INEXACT_RESULT:
			exceptionCause << "Inexact result";
			break;
		case EXCEPTION_FLT_INVALID_OPERATION:
			exceptionCause << "Invalid operation";
			break;
		case EXCEPTION_FLT_OVERFLOW:
		case EXCEPTION_INT_OVERFLOW:
			exceptionCause << "Numeric overflow";
			break;
		case EXCEPTION_FLT_UNDERFLOW:
			exceptionCause << "Numeric underflow";
			break;
		case EXCEPTION_FLT_STACK_CHECK:
			exceptionCause << "Stack check";
			break;
		case EXCEPTION_ILLEGAL_INSTRUCTION:
			exceptionCause << "Illegal instruction";
			break;
		case EXCEPTION_INVALID_DISPOSITION:
			exceptionCause << "Invalid disposition";
			break;
		case EXCEPTION_NONCONTINUABLE_EXCEPTION:
			exceptionCause << "Noncontinuable exception";
			break;
		case EXCEPTION_PRIV_INSTRUCTION:
			exceptionCause << "Priviledged instruction";
			break;
		case EXCEPTION_STACK_OVERFLOW:
			exceptionCause << "Stack overflow";
			break;
		default:
			exceptionCause << "Unknown";
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

		DWORD64 crashedModuleOffset = ((DWORD64)exceptionAddress) - ((DWORD64)crashedModuleInfo.lpBaseOfDll);
		CONTEXT* exceptionContext = exceptionInfo->ContextRecord;

		spdlog::error("Northstar has crashed! a minidump has been written and exception info is available below:");
		spdlog::error(exceptionCause.str());
		spdlog::error("At: {} + {}", crashedModuleName, (void*)crashedModuleOffset);

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

			void* actualAddress = (void*)framesToCapture[i];
			void* relativeAddress = (void*)(uintptr_t(actualAddress) - uintptr_t(backtraceModuleHandle));

			spdlog::error("    {} + {} ({})", backtraceModuleName, relativeAddress, actualAddress);
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

		if (!IsDedicatedServer())
			MessageBoxA(
				0, "Northstar has crashed! Crash info can be found in R2Northstar/logs", "Northstar has crashed!", MB_ICONERROR | MB_OK);
	}

	logged = true;
	return EXCEPTION_EXECUTE_HANDLER;
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
}

void RemoveCrashHandler()
{
	RemoveVectoredExceptionHandler(hExceptionFilter);
}
