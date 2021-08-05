#ifndef PCH_H
#define PCH_H

#define WIN32_LEAN_AND_MEAN
#define _CRT_SECURE_NO_WARNINGS
#define RAPIDJSON_NOMEMBERITERATORCLASS // need this for rapidjson
#define NOMINMAX // this too

// add headers that you want to pre-compile here
#include <Windows.h>
#include "logging.h"
#include "include/MinHook.h"
#include "spdlog/spdlog.h"

#endif