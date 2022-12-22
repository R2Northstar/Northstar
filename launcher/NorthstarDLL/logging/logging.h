#pragma once
#include "pch.h"
#include "spdlog/sinks/base_sink.h"
#include "spdlog/logger.h"
#include "squirrel/squirrel.h"
#include "core/math/color.h"

void CreateLogFiles();
void InitialiseLogging();
void InitialiseConsole();

class ColoredLogger;

struct custom_log_msg : spdlog::details::log_msg
{
  public:
	custom_log_msg(ColoredLogger* origin, spdlog::details::log_msg msg) : origin(origin), spdlog::details::log_msg(msg) {}

	ColoredLogger* origin;
};

class CustomSink : public spdlog::sinks::base_sink<std::mutex>
{
  public:
	void custom_log(const custom_log_msg& msg);
	virtual void custom_sink_it_(const custom_log_msg& msg)
	{
		throw std::runtime_error("Pure virtual call to CustomSink::custom_sink_it_");
	}
};

class ColoredLogger : public spdlog::logger
{
  public:
	std::string ANSIColor;
	SourceColor SRCColor;

	std::vector<std::shared_ptr<CustomSink>> custom_sinks_;

	ColoredLogger(std::string name, Color color, bool first = false) : spdlog::logger(*spdlog::default_logger())
	{
		name_ = std::move(name);
		if (!first)
		{
			custom_sinks_ = dynamic_pointer_cast<ColoredLogger>(spdlog::default_logger())->custom_sinks_;
		}

		ANSIColor = color.ToANSIColor();
		SRCColor = color.ToSourceColor();
	}

	void sink_it_(const spdlog::details::log_msg& msg)
	{
		custom_log_msg custom_msg {this, msg};

		// Ugh
		for (auto& sink : sinks_)
		{
			SPDLOG_TRY
			{
				sink->log(custom_msg);
			}
			SPDLOG_LOGGER_CATCH()
		}

		for (auto& sink : custom_sinks_)
		{
			SPDLOG_TRY
			{
				sink->custom_log(custom_msg);
			}
			SPDLOG_LOGGER_CATCH()
		}

		if (should_flush_(custom_msg))
		{
			flush_();
		}
	}
};

namespace NS::log
{
	// Squirrel
	extern std::shared_ptr<ColoredLogger> SCRIPT_UI;
	extern std::shared_ptr<ColoredLogger> SCRIPT_CL;
	extern std::shared_ptr<ColoredLogger> SCRIPT_SV;

	// Native code
	extern std::shared_ptr<ColoredLogger> NATIVE_UI;
	extern std::shared_ptr<ColoredLogger> NATIVE_CL;
	extern std::shared_ptr<ColoredLogger> NATIVE_SV;
	extern std::shared_ptr<ColoredLogger> NATIVE_EN;

	// File system
	extern std::shared_ptr<ColoredLogger> fs;
	// RPak
	extern std::shared_ptr<ColoredLogger> rpak;
	// Echo
	extern std::shared_ptr<ColoredLogger> echo;

	extern std::shared_ptr<ColoredLogger> NORTHSTAR;
}; // namespace NS::log

void RegisterCustomSink(std::shared_ptr<CustomSink> sink);

inline bool g_bSpdLog_UseAnsiColor = true;

// Could maybe use some different names here, idk
static const char* level_names[] {"trac", "dbug", "info", "warn", "errr", "crit", "off"};

// spdlog logger, for cool colour things
class ExternalConsoleSink : public CustomSink
{
  private:
	std::map<spdlog::level::level_enum, std::string> m_LogColours = {
		{spdlog::level::trace, NS::Colors::TRACE.ToANSIColor()},
		{spdlog::level::debug, NS::Colors::DEBUG.ToANSIColor()},
		{spdlog::level::info, NS::Colors::INFO.ToANSIColor()},
		{spdlog::level::warn, NS::Colors::WARN.ToANSIColor()},
		{spdlog::level::err, NS::Colors::ERR.ToANSIColor()},
		{spdlog::level::critical, NS::Colors::CRIT.ToANSIColor()},
		{spdlog::level::off, NS::Colors::OFF.ToANSIColor()}};

	std::string default_color = "\033[39;49m";

  protected:
	void sink_it_(const spdlog::details::log_msg& msg) override;
	void custom_sink_it_(const custom_log_msg& msg);
	void flush_() override;
};
