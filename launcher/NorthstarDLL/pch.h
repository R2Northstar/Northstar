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

#include "core/structs.h"
#include "core/math/color.h"
#include "spdlog/spdlog.h"
#include "logging/logging.h"
#include "MinHook.h"
#include "libcurl/include/curl/curl.h"
#include "core/hooks.h"
#include "memory.h"

template <typename ReturnType, typename... Args> ReturnType CallVFunc(int index, void* thisPtr, Args... args)
{
	return (*reinterpret_cast<ReturnType(__fastcall***)(void*, Args...)>(thisPtr))[index](thisPtr, args...);
}

template <typename T, size_t index, typename... Args> constexpr T CallVFunc_Alt(void* classBase, Args... args) noexcept
{
	return ((*(T(__thiscall***)(void*, Args...))(classBase))[index])(classBase, args...);
}

#define STR_HASH(s) (std::hash<std::string>()(s))

// Example usage: M_VMETHOD(int, GetEntityIndex, 8, (CBaseEntity* ent), (this, ent))
#define M_VMETHOD(returnType, name, index, args, argsRaw)                                                                                  \
	FORCEINLINE returnType name args noexcept                                                                                              \
	{                                                                                                                                      \
		return CallVFunc_Alt<returnType, index> argsRaw;                                                                                   \
	}

#endif
