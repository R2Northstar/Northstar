#include "pch.h"
#include "logging.h"
#include "sourceconsole.h"
#include "spdlog/sinks/basic_file_sink.h"
#include "hookutils.h"
#include <iomanip>
#include <sstream>

void InitialiseLogging()
{
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
}