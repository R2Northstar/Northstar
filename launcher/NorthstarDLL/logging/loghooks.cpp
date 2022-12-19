#include "pch.h"
#include "logging.h"
#include "loghooks.h"
#include "core/convar/convar.h"
#include "core/convar/concommand.h"
#include "core/math/bitbuf.h"
#include "config/profile.h"
#include "core/tier0.h"
#include "squirrel/squirrel.h"
#include <iomanip>
#include <sstream>

AUTOHOOK_INIT()

ConVar* Cvar_spewlog_enable;
ConVar* Cvar_cl_showtextmsg;

enum class TextMsgPrintType_t
{
	HUD_PRINTNOTIFY = 1,
	HUD_PRINTCONSOLE,
	HUD_PRINTTALK,
	HUD_PRINTCENTER
};

class ICenterPrint
{
  public:
	virtual void ctor() = 0;
	virtual void Clear(void) = 0;
	virtual void ColorPrint(int r, int g, int b, int a, wchar_t* text) = 0;
	virtual void ColorPrint(int r, int g, int b, int a, char* text) = 0;
	virtual void Print(wchar_t* text) = 0;
	virtual void Print(char* text) = 0;
	virtual void SetTextColor(int r, int g, int b, int a) = 0;
};

enum class SpewType_t
{
	SPEW_MESSAGE = 0,

	SPEW_WARNING,
	SPEW_ASSERT,
	SPEW_ERROR,
	SPEW_LOG,

	SPEW_TYPE_COUNT
};

const std::unordered_map<SpewType_t, const char*> PrintSpewTypes = {
	{SpewType_t::SPEW_MESSAGE, "SPEW_MESSAGE"},
	{SpewType_t::SPEW_WARNING, "SPEW_WARNING"},
	{SpewType_t::SPEW_ASSERT, "SPEW_ASSERT"},
	{SpewType_t::SPEW_ERROR, "SPEW_ERROR"},
	{SpewType_t::SPEW_LOG, "SPEW_LOG"}};

// these are used to define the base text colour for these things
const std::unordered_map<SpewType_t, spdlog::level::level_enum> PrintSpewLevels = {
	{SpewType_t::SPEW_MESSAGE, spdlog::level::level_enum::info},
	{SpewType_t::SPEW_WARNING, spdlog::level::level_enum::warn},
	{SpewType_t::SPEW_ASSERT, spdlog::level::level_enum::err},
	{SpewType_t::SPEW_ERROR, spdlog::level::level_enum::err},
	{SpewType_t::SPEW_LOG, spdlog::level::level_enum::info}};

const std::unordered_map<SpewType_t, const char> PrintSpewTypes_Short = {
	{SpewType_t::SPEW_MESSAGE, 'M'},
	{SpewType_t::SPEW_WARNING, 'W'},
	{SpewType_t::SPEW_ASSERT, 'A'},
	{SpewType_t::SPEW_ERROR, 'E'},
	{SpewType_t::SPEW_LOG, 'L'}};

ICenterPrint* pInternalCenterPrint = NULL;

// clang-format off
AUTOHOOK(TextMsg, client.dll + 0x198710,
void,, (BFRead* msg))
// clang-format on
{
	TextMsgPrintType_t msg_dest = (TextMsgPrintType_t)msg->ReadByte();

	char text[256];
	msg->ReadString(text, sizeof(text));

	if (!Cvar_cl_showtextmsg->GetBool())
		return;

	switch (msg_dest)
	{
	case TextMsgPrintType_t::HUD_PRINTCENTER:
		pInternalCenterPrint->Print(text);
		break;

	default:
		spdlog::warn("Unimplemented TextMsg type {}! printing to console", msg_dest);
		[[fallthrough]];

	case TextMsgPrintType_t::HUD_PRINTCONSOLE:
		auto endpos = strlen(text);
		if (text[endpos - 1] == '\n')
			text[endpos - 1] = '\0'; // cut off repeated newline

		spdlog::info(text);
		break;
	}
}

// clang-format off
AUTOHOOK(Hook_fprintf, engine.dll + 0x51B1F0,
int,, (void* const stream, const char* const format, ...))
// clang-format on
{
	va_list va;
	va_start(va, format);

	SQChar buf[1024];
	int charsWritten = vsnprintf_s(buf, _TRUNCATE, format, va);

	if (charsWritten > 0)
	{
		if (buf[charsWritten - 1] == '\n')
			buf[charsWritten - 1] = '\0';
		NS::log::NATIVE_EN->info("{}", buf);
	}

	va_end(va);
	return 0;
}

// clang-format off
AUTOHOOK(ConCommand_echo, engine.dll + 0x123680,
void,, (const CCommand& arg))
// clang-format on
{
	if (arg.ArgC() >= 2)
		NS::log::echo->info("{}", arg.ArgS());
}

// clang-format off
AUTOHOOK(EngineSpewFunc, engine.dll + 0x11CA80,
void, __fastcall, (void* pEngineServer, SpewType_t type, const char* format, va_list args))
// clang-format on
{
	if (!Cvar_spewlog_enable->GetBool())
		return;

	const char* typeStr = PrintSpewTypes.at(type);
	char formatted[2048] = {0};
	bool bShouldFormat = true;

	// because titanfall 2 is quite possibly the worst thing to yet exist, it sometimes gives invalid specifiers which will crash
	// ttf2sdk had a way to prevent them from crashing but it doesnt work in debug builds
	// so we use this instead
	for (int i = 0; format[i]; i++)
	{
		if (format[i] == '%')
		{
			switch (format[i + 1])
			{
			// this is fucking awful lol
			case 'd':
			case 'i':
			case 'u':
			case 'x':
			case 'X':
			case 'f':
			case 'F':
			case 'g':
			case 'G':
			case 'a':
			case 'A':
			case 'c':
			case 's':
			case 'p':
			case 'n':
			case '%':
			case '-':
			case '+':
			case ' ':
			case '#':
			case '*':
			case '0':
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				break;

			default:
			{
				bShouldFormat = false;
				break;
			}
			}
		}
	}

	if (bShouldFormat)
		vsnprintf(formatted, sizeof(formatted), format, args);
	else
		spdlog::warn("Failed to format {} \"{}\"", typeStr, format);

	auto endpos = strlen(formatted);
	if (formatted[endpos - 1] == '\n')
		formatted[endpos - 1] = '\0'; // cut off repeated newline

	NS::log::NATIVE_SV->log(PrintSpewLevels.at(type), "{}", formatted);
}

// used for printing the output of status
// clang-format off
AUTOHOOK(Status_ConMsg, engine.dll + 0x15ABD0,
void,, (const char* text, ...))
// clang-format on
{
	char formatted[2048];
	va_list list;

	va_start(list, text);
	vsprintf_s(formatted, text, list);
	va_end(list);

	auto endpos = strlen(formatted);
	if (formatted[endpos - 1] == '\n')
		formatted[endpos - 1] = '\0'; // cut off repeated newline

	spdlog::info(formatted);
}

// clang-format off
AUTOHOOK(CClientState_ProcessPrint, engine.dll + 0x1A1530, 
bool,, (void* thisptr, uintptr_t msg))
// clang-format on
{
	char* text = *(char**)(msg + 0x20);

	auto endpos = strlen(text);
	if (text[endpos - 1] == '\n')
		text[endpos - 1] = '\0'; // cut off repeated newline

	spdlog::info(text);
	return true;
}

ON_DLL_LOAD_RELIESON("engine.dll", EngineSpewFuncHooks, ConVar, (CModule module))
{
	AUTOHOOK_DISPATCH_MODULE(engine.dll)

	Cvar_spewlog_enable = new ConVar("spewlog_enable", "1", FCVAR_NONE, "Enables/disables whether the engine spewfunc should be logged");
}

ON_DLL_LOAD_CLIENT_RELIESON("client.dll", ClientPrintHooks, ConVar, (CModule module))
{
	AUTOHOOK_DISPATCH_MODULE(client.dll)

	Cvar_cl_showtextmsg = new ConVar("cl_showtextmsg", "1", FCVAR_NONE, "Enable/disable text messages printing on the screen.");
	pInternalCenterPrint = module.Offset(0x216E940).As<ICenterPrint*>();
}
