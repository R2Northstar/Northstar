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