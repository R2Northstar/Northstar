#ifndef ILOGGING_H
#define ILOGGING_H

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
	virtual void Log(HMODULE handle, LogLevel level, char* msg) = 0;
	virtual void Unload(HMODULE handle) = 0;
	virtual void Reload(HMODULE handle) = 0;
};

#endif
