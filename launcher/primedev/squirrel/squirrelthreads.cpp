#include "squirrelthreads.h"
#include "squirrel.h"
#include "vscript/languages/squirrel_re/include/squirrel.h"
#include "vscript/languages/squirrel_re/squirrel/sqobject.h"
#include "vscript/languages/squirrel_re/squirrel/sqvm.h"
#include <future>
#include <optional>

template <ScriptContext context> auto SQThreadSlot::CreateSlot(SQVM* sqvm) -> std::optional<SQThreadSlot>
{
	SQThreadSlot(g_pSquirrel[context]->m_threads.CreateSlot<context>(sqvm));
}

template <ScriptContext context> auto SQThreadSlot::PushFailureReason(SQVM* sqvm) -> SQRESULT
{
	g_pSquirrel[context]->raiseerror(sqvm, "Cannot suspend thread from within code function calls");
	return SQRESULT_ERROR;
}

template <ScriptContext context> auto SquirrelThreads::CreateThread(SQVM* sqvm, SQThreadSlot slot, std::future<SQObject> future) -> void
{
	this->m_activeThreads[slot.slot]->emplace(std::make_optional(SQThreadData(future, slot)));
}

template <ScriptContext context> auto SquirrelThreads::PopulateSlot(SQVM* sqvm, SQThreadSlot slot)
{
	this->m_activeThreads[slot.slot]->emplace(std::make_optional(SQThreadData(future, slot)));
}

template <ScriptContext context> auto SquirrelThreads::PopulateSlot(SQVM* sqvm, SQThreadSlot slot) {}

ON_DLL_LOAD_RELIESON("server.dll", ServerSquirrel, ConCommand, (CModule module)) {}
