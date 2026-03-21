#pragma once
#include "logging/logging.h"
#include "core/convar/convar.h"

class CBaseClient;

extern void (*CGameClient__ClientPrintf)(CBaseClient* pClient, const char* fmt, ...);

class DedicatedServerLogToClientSink : public CustomSink
{
protected:
	void custom_sink_it_(const custom_log_msg& msg) override;
	void sink_it_(const spdlog::details::log_msg& msg) override;
	void flush_() override;
};
