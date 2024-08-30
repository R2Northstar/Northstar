#include "engine/r2engine.h"

// this is called from  when our connection is rejected, this is the only case we're hooking this for
static void (*o_pCOM_ExplainDisconnection)(bool a1, const char* fmt, ...) = nullptr;
static void h_COM_ExplainDisconnection(bool a1, const char* fmt, ...)
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

	return o_pCOM_ExplainDisconnection(a1, "%s", buf);
}

ON_DLL_LOAD_CLIENT("engine.dll", RejectConnectionFixes, (CModule module))
{
	o_pCOM_ExplainDisconnection = module.Offset(0x1342F0).RCast<decltype(o_pCOM_ExplainDisconnection)>();
	HookAttach(&(PVOID&)o_pCOM_ExplainDisconnection, (PVOID)h_COM_ExplainDisconnection);
}
