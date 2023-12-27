#include "engine/r2engine.h"

AUTOHOOK_INIT()

// this is called from  when our connection is rejected, this is the only case we're hooking this for
// clang-format off
AUTOHOOK(COM_ExplainDisconnection, engine.dll + 0x1342F0,
void,, (bool a1, const char* fmt, ...))
// clang-format on
{
	va_list va;
	va_start(va, fmt);
	char buf[4096];
	vsnprintf_s(buf, 4096, fmt, va);
	va_end(va);

	// slightly hacky comparison, but patching the function that calls this for reject would be worse
	if (!strncmp(fmt, "Connection rejected: ", 21))
	{
		// when COM_ExplainDisconnection is called from engine.dll + 19ff1c for connection rejected, it doesn't
		// call Host_Disconnect, which properly shuts down listen server
		// not doing this gets our client in a pretty weird state so we need to shut it down manually here

		// don't call Cbuf_Execute because we don't need this called immediately
		Cbuf_AddText(Cbuf_GetCurrentPlayer(), "disconnect", cmd_source_t::kCommandSrcCode);
	}

	return COM_ExplainDisconnection(a1, "%s", buf);
}

ON_DLL_LOAD_CLIENT("engine.dll", RejectConnectionFixes, (CModule module))
{
	AUTOHOOK_DISPATCH()
}
