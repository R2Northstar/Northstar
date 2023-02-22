#pragma once
#include "logging/logging.h"
#include "core/convar/convar.h"

class DedicatedServerLogToClientSink : public CustomSink
{
  protected:
	void custom_sink_it_(const custom_log_msg& msg);
	void sink_it_(const spdlog::details::log_msg& msg) override;
	void flush_() override;
};
