#ifndef ILOGGING_H
#define ILOGGING_H

#include <stdint.h>

#define SYS_VERSION "NSSys001"

enum class LogLevel : int
{
	INFO = 0,
	WARN,
	ERR,
};

class ISys
{
public:
	virtual void Log(int64_t unused, LogLevel level, char* msg) = 0;
	virtual void Unload(int64_t unused) = 0;
	virtual void Reload(int64_t unused) = 0;
};

#endif
