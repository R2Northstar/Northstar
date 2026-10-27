#pragma once
#include "vscript/languages/squirrel_re/squirrel/sqvm.h"
#include <cstddef>
#include <vector>
#include <optional>
#include <future>
#include <mutex>

class SQThreadSlot
{
private:
	friend class SquirrelThreads;

	size_t slot;

	explicit SQThreadSlot(size_t slot)
		: slot(slot)
	{
	}

public:
	// if not slot is allocated then it means that this wasn't called from a squirrel thread
	template <ScriptContext context> static auto CreateSlot(SQVM* sqvm) -> std::optional<SQThreadSlot>;

	template <ScriptContext context> static auto PushFailureReason(SQVM* sqvm) -> SQRESULT;

	SQThreadSlot(SQThreadSlot&& other);

	~SQThreadSlot();
};

class SquirrelThreads
{
private:
	friend class SQThreadSlot;

	// the two optional types represent a state of the slot being empty, the slot being "registered", and finally the slot being populate by
	// a future
	std::vector<std::optional<std::optional<SQThreadSlot>>> m_activeThreads;
	std::mutex lock;

	template <ScriptContext context> auto CheckThreadSafety(SQVM* sqvm) -> bool;
	template <ScriptContext context> auto CreateSlot(SQVM* sqvm) -> size_t;
	template <ScriptContext context> auto PopulateSlot(SQVM* sqvm, SQThreadSlot slot);
	auto DropSlot(size_t slot) -> void;

public:
	// the sqvm is used as a basic proof of being in squirrel function

	// has to be ran as the last thing in a native squirrel function
	template <ScriptContext context> auto CreateThread(SQVM* sqvm, SQThreadSlot slot, std::future<SQObject> future) -> void;
	auto Pop();
};

class SQThreadData
{
public:
	std::future<SQObject> future;
	ScriptContext context;

	SQThreadData(std::future<SQObject> future, ScriptContext context)
		: future(std::move(future))
		, context(context)
	{
	}

	SQThreadData(SQThreadData&& other);
};
