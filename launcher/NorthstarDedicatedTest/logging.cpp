#include "pch.h"
#include "logging.h"
#include "context.h"
#include "dedicated.h"
#include <vector>
#include <iostream>
#include <chrono>

std::vector<LoggingSink> loggingSinks;

void Log(Context context, char* fmt, ...)
{
	va_list args;
	va_start(args, fmt);

	Log(context, fmt, args);
	va_end(args);
}

void Log(Context context, char* fmt, va_list args)
{
	char buf[1024];
	vsnprintf_s(buf, _TRUNCATE, fmt, args);

	for (LoggingSink& sink : loggingSinks)
		sink(context, fmt);
}

void AddLoggingSink(LoggingSink sink)
{
	loggingSinks.push_back(sink);
}

// default logging sink
void DefaultLoggingSink(Context context, char* message)
{
	time_t now = time(0);
	tm* localTime = localtime(&now);
	char timeBuf[10];
	strftime(timeBuf, sizeof(timeBuf), "%X", localTime);
	
	std::cout << "[" << timeBuf << "] ";
	if (context != NONE)
		std::cout << "[" << GetContextName(context) << "] ";

	std::cout << message;

	if (!IsDedicated())
	{

	}
}