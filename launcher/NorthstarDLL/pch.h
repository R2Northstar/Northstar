#ifndef PCH_H
#define PCH_H

#define WIN32_LEAN_AND_MEAN
#define _CRT_SECURE_NO_WARNINGS
#define RAPIDJSON_NOMEMBERITERATORCLASS // need this for rapidjson
#define NOMINMAX // this too
#define _WINSOCK_DEPRECATED_NO_WARNINGS // temp because i'm very lazy and want to use inet_addr, remove later
#define RAPIDJSON_HAS_STDSTRING 1

// add headers that you want to pre-compile here
#include "core/memalloc.h"

#include <windows.h>
#include <psapi.h>
#include <set>
#include <map>
#include <filesystem>
#include <sstream>

namespace fs = std::filesystem;

// clang-format off
#define assert_msg(exp, msg) assert((exp, msg))
//clang-format on

#include "core/macros.h"

#include "core/structs.h"
#include "core/math/color.h"
#include "spdlog/spdlog.h"
#include "logging/logging.h"
#include "MinHook.h"
#include "libcurl/include/curl/curl.h"
#include "core/hooks.h"
#include "core/memory.h"

#endif
