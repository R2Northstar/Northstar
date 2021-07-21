#include "pch.h"
#include "logging.h"
#include "context.h"
#include "sourceconsole.h"
#include "spdlog/sinks/basic_file_sink.h"
#include <iomanip>
#include <sstream>

void InitialiseLogging()
{
	AllocConsole();
	freopen("CONOUT$", "w", stdout);

	spdlog::default_logger()->set_pattern("[%H:%M:%S] [%l] %v");
	spdlog::flush_on(spdlog::level::info);

	// generate log file, format should be nslog%d-%m-%Y %H-%M-%S.txt in gamedir/R2Northstar/logs
	time_t time = std::time(nullptr);
	tm currentTime = *std::localtime(&time);
	std::stringstream stream;
	stream << std::put_time(&currentTime, "R2Northstar/logs/nslog%d-%m-%Y %H-%M-%S.txt");

	spdlog::default_logger()->sinks().push_back(std::make_shared<spdlog::sinks::basic_file_sink_mt>(stream.str(), false));
}