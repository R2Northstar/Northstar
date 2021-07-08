#pragma once
#include "context.h"

typedef void(*LoggingSink)(Context context, char* fmt);

void Log(Context context, char* fmt, ...);
void Log(Context context, char* fmt, va_list args);
void AddLoggingSink(LoggingSink sink);

// default logging sink
void DefaultLoggingSink(Context context, char* message);