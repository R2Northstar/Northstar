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

static void (*o_pTextMsg)(BFRead* msg) = nullptr;
static void h_TextMsg(BFRead* msg)
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

static int (*o_pfprintf)(void* const stream, const char* const format, ...) = nullptr;
static int h_fprintf(void* const stream, const char* const format, ...)
{
	NOTE_UNUSED(stream);

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

static void (*o_pConCommand_echo)(const CCommand& arg) = nullptr;
static void h_ConCommand_echo(const CCommand& arg)
{
	if (arg.ArgC() >= 2)
		NS::log::echo->info("{}", arg.ArgS());
}

static void(__fastcall* o_pEngineSpewFunc)(void* pEngineServer, SpewType_t type, const char* format, va_list args) = nullptr;
static void __fastcall h_EngineSpewFunc(void* pEngineServer, SpewType_t type, const char* format, va_list args)
{
	NOTE_UNUSED(pEngineServer);
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
static void (*o_pStatus_ConMsg)(const char* text, ...) = nullptr;
static void h_Status_ConMsg(const char* text, ...)
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

static bool (*o_pCClientState_ProcessPrint)(void* thisptr, uintptr_t msg) = nullptr;
static bool h_CClientState_ProcessPrint(void* thisptr, uintptr_t msg)
{
	NOTE_UNUSED(thisptr);

	char* text = *(char**)(msg + 0x20);

	auto endpos = strlen(text);
	if (text[endpos - 1] == '\n')
		text[endpos - 1] = '\0'; // cut off repeated newline

	spdlog::info(text);
	return true;
}

ON_DLL_LOAD_RELIESON("engine.dll", EngineSpewFuncHooks, ConVar, (CModule module))
{
	o_pfprintf = module.Offset(0x51B1F0).RCast<decltype(o_pfprintf)>();
	HookAttach(&(PVOID&)o_pfprintf, (PVOID)h_fprintf);

	o_pConCommand_echo = module.Offset(0x123680).RCast<decltype(o_pConCommand_echo)>();
	HookAttach(&(PVOID&)o_pConCommand_echo, (PVOID)h_ConCommand_echo);

	o_pEngineSpewFunc = module.Offset(0x11CA80).RCast<decltype(o_pEngineSpewFunc)>();
	HookAttach(&(PVOID&)o_pEngineSpewFunc, (PVOID)h_EngineSpewFunc);

	o_pStatus_ConMsg = module.Offset(0x15ABD0).RCast<decltype(o_pStatus_ConMsg)>();
	HookAttach(&(PVOID&)o_pStatus_ConMsg, (PVOID)h_Status_ConMsg);

	o_pCClientState_ProcessPrint = module.Offset(0x1A1530).RCast<decltype(o_pCClientState_ProcessPrint)>();
	HookAttach(&(PVOID&)o_pCClientState_ProcessPrint, (PVOID)h_CClientState_ProcessPrint);

	Cvar_spewlog_enable = new ConVar("spewlog_enable", "0", FCVAR_NONE, "Enables/disables whether the engine spewfunc should be logged");
}

ON_DLL_LOAD_CLIENT_RELIESON("client.dll", ClientPrintHooks, ConVar, (CModule module))
{
	o_pTextMsg = module.Offset(0x198710).RCast<decltype(o_pTextMsg)>();
	HookAttach(&(PVOID&)o_pTextMsg, (PVOID)h_TextMsg);

	Cvar_cl_showtextmsg = new ConVar("cl_showtextmsg", "1", FCVAR_NONE, "Enable/disable text messages printing on the screen.");
	pInternalCenterPrint = module.Offset(0x216E940).RCast<ICenterPrint*>();
}
