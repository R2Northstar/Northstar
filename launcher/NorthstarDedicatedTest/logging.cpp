#include "pch.h"
#include "logging.h"
#include "context.h"
#include "dedicated.h"
#include "sourceconsole.h"
#include <vector>
#include <iostream>
#include <chrono>

void InitialiseLogging()
{
	AllocConsole();
	freopen("CONOUT$", "w", stdout);

	spdlog::default_logger()->set_pattern("[%H:%M:%S] [%l] %v");
}

// default logging sink
void DefaultLoggingSink(Context context, char* message)
{
	time_t now = time(0);
	tm* localTime = localtime(&now);
	char timeBuf[10];
	strftime(timeBuf, sizeof(timeBuf), "%X", localTime);
	
	std::string messageStr;

	messageStr.append("[");
	messageStr.append(timeBuf);
	messageStr.append("] ");

	if (context != NONE)
	{
		messageStr.append("[");
		messageStr.append(GetContextName(context));
		messageStr.append("] ");
	}

	messageStr.append(message);
	std::cout << messageStr;

	// dont need to check dedi since this won't be initialised on dedi anyway
	if ((*g_SourceGameConsole)->m_bInitialized)
		(*g_SourceGameConsole)->m_pConsole->m_pConsolePanel->Print(messageStr.c_str());
}