#include "pch.h"
#include "squirrel/squirrel.h"

#include "rapidjson/error/en.h"
#include "rapidjson/document.h"
#include "rapidjson/writer.h"
#include "rapidjson/stringbuffer.h"

#ifdef _MSC_VER
#undef GetObject // fuck microsoft developers
#endif

template <ScriptContext context> void
DecodeJsonArray(HSquirrelVM* sqvm, rapidjson::GenericValue<rapidjson::UTF8<char>, rapidjson::MemoryPoolAllocator<SourceAllocator>>* arr)
{
	g_pSquirrel<context>->newarray(sqvm, 0);

	for (auto& itr : arr->GetArray())
	{
		switch (itr.GetType())
		{
		case rapidjson::kObjectType:
			DecodeJsonTable<context>(sqvm, &itr);
			g_pSquirrel<context>->arrayappend(sqvm, -2);
			break;
		case rapidjson::kArrayType:
			DecodeJsonArray<context>(sqvm, &itr);
			g_pSquirrel<context>->arrayappend(sqvm, -2);
			break;
		case rapidjson::kStringType:
			g_pSquirrel<context>->pushstring(sqvm, itr.GetString(), -1);
			g_pSquirrel<context>->arrayappend(sqvm, -2);
			break;
		case rapidjson::kTrueType:
		case rapidjson::kFalseType:
			g_pSquirrel<context>->pushbool(sqvm, itr.GetBool());
			g_pSquirrel<context>->arrayappend(sqvm, -2);
			break;
		case rapidjson::kNumberType:
			if (itr.IsDouble() || itr.IsFloat())
				g_pSquirrel<context>->pushfloat(sqvm, itr.GetFloat());
			else
				g_pSquirrel<context>->pushinteger(sqvm, itr.GetInt());
			g_pSquirrel<context>->arrayappend(sqvm, -2);
			break;
		}
	}
}

template <ScriptContext context> void
DecodeJsonTable(HSquirrelVM* sqvm, rapidjson::GenericValue<rapidjson::UTF8<char>, rapidjson::MemoryPoolAllocator<SourceAllocator>>* obj)
{
	g_pSquirrel<context>->newtable(sqvm);

	for (auto itr = obj->MemberBegin(); itr != obj->MemberEnd(); itr++)
	{
		switch (itr->value.GetType())
		{
		case rapidjson::kObjectType:
			g_pSquirrel<context>->pushstring(sqvm, itr->name.GetString(), -1);
			DecodeJsonTable<context>(
				sqvm, (rapidjson::GenericValue<rapidjson::UTF8<char>, rapidjson::MemoryPoolAllocator<SourceAllocator>>*)&itr->value);
			g_pSquirrel<context>->newslot(sqvm, -3, false);
			break;
		case rapidjson::kArrayType:
			g_pSquirrel<context>->pushstring(sqvm, itr->name.GetString(), -1);
			DecodeJsonArray<context>(
				sqvm, (rapidjson::GenericValue<rapidjson::UTF8<char>, rapidjson::MemoryPoolAllocator<SourceAllocator>>*)&itr->value);
			g_pSquirrel<context>->newslot(sqvm, -3, false);
			break;
		case rapidjson::kStringType:
			g_pSquirrel<context>->pushstring(sqvm, itr->name.GetString(), -1);
			g_pSquirrel<context>->pushstring(sqvm, itr->value.GetString(), -1);

			g_pSquirrel<context>->newslot(sqvm, -3, false);
			break;
		case rapidjson::kTrueType:
		case rapidjson::kFalseType:
			g_pSquirrel<context>->pushstring(sqvm, itr->name.GetString(), -1);
			g_pSquirrel<context>->pushbool(sqvm, itr->value.GetBool());
			g_pSquirrel<context>->newslot(sqvm, -3, false);
			break;
		case rapidjson::kNumberType:
			if (itr->value.IsDouble() || itr->value.IsFloat())
			{
				g_pSquirrel<context>->pushstring(sqvm, itr->name.GetString(), -1);
				g_pSquirrel<context>->pushfloat(sqvm, itr->value.GetFloat());
			}
			else
			{
				g_pSquirrel<context>->pushstring(sqvm, itr->name.GetString(), -1);
				g_pSquirrel<context>->pushinteger(sqvm, itr->value.GetInt());
			}
			g_pSquirrel<context>->newslot(sqvm, -3, false);
			break;
		}
	}
}

template <ScriptContext context> void EncodeJSONTable(
	SQTable* table,
	rapidjson::GenericValue<rapidjson::UTF8<char>, rapidjson::MemoryPoolAllocator<SourceAllocator>>* obj,
	rapidjson::MemoryPoolAllocator<SourceAllocator>& allocator)
{
	for (int i = 0; i < table->_numOfNodes; i++)
	{
		tableNode* node = &table->_nodes[i];
		if (node->key._Type == OT_STRING)
		{
			rapidjson::GenericValue<rapidjson::UTF8<char>, rapidjson::MemoryPoolAllocator<SourceAllocator>> newObj(rapidjson::kObjectType);
			rapidjson::GenericValue<rapidjson::UTF8<char>, rapidjson::MemoryPoolAllocator<SourceAllocator>> newArray(rapidjson::kArrayType);

			switch (node->val._Type)
			{
			case OT_STRING:
				obj->AddMember(
					rapidjson::StringRef(node->key._VAL.asString->_val), rapidjson::StringRef(node->val._VAL.asString->_val), allocator);
				break;
			case OT_INTEGER:
				obj->AddMember(rapidjson::StringRef(node->key._VAL.asString->_val), node->val._VAL.asInteger, allocator);
				break;
			case OT_FLOAT:
				obj->AddMember(rapidjson::StringRef(node->key._VAL.asString->_val), node->val._VAL.asFloat, allocator);
				break;
			case OT_BOOL:
				if (node->val._VAL.asInteger)
				{
					obj->AddMember(rapidjson::StringRef(node->key._VAL.asString->_val), true, allocator);
				}
				else
				{
					obj->AddMember(rapidjson::StringRef(node->key._VAL.asString->_val), false, allocator);
				}
				break;
			case OT_TABLE:
				EncodeJSONTable<context>(node->val._VAL.asTable, &newObj, allocator);
				obj->AddMember(rapidjson::StringRef(node->key._VAL.asString->_val), newObj, allocator);
				break;
			case OT_ARRAY:
				EncodeJSONArray<context>(node->val._VAL.asArray, &newArray, allocator);
				obj->AddMember(rapidjson::StringRef(node->key._VAL.asString->_val), newArray, allocator);
				break;
			default:
				spdlog::warn("SQ_EncodeJSON: squirrel type {} not supported", SQTypeNameFromID(node->val._Type));
				break;
			}
		}
	}
}

template <ScriptContext context> void EncodeJSONArray(
	SQArray* arr,
	rapidjson::GenericValue<rapidjson::UTF8<char>, rapidjson::MemoryPoolAllocator<SourceAllocator>>* obj,
	rapidjson::MemoryPoolAllocator<SourceAllocator>& allocator)
{
	for (int i = 0; i < arr->_usedSlots; i++)
	{
		SQObject* node = &arr->_values[i];

		rapidjson::GenericValue<rapidjson::UTF8<char>, rapidjson::MemoryPoolAllocator<SourceAllocator>> newObj(rapidjson::kObjectType);
		rapidjson::GenericValue<rapidjson::UTF8<char>, rapidjson::MemoryPoolAllocator<SourceAllocator>> newArray(rapidjson::kArrayType);

		switch (node->_Type)
		{
		case OT_STRING:
			obj->PushBack(rapidjson::StringRef(node->_VAL.asString->_val), allocator);
			break;
		case OT_INTEGER:
			obj->PushBack(node->_VAL.asInteger, allocator);
			break;
		case OT_FLOAT:
			obj->PushBack(node->_VAL.asFloat, allocator);
			break;
		case OT_BOOL:
			if (node->_VAL.asInteger)
				obj->PushBack(rapidjson::StringRef("true"), allocator);
			else
				obj->PushBack(rapidjson::StringRef("false"), allocator);
			break;
		case OT_TABLE:
			EncodeJSONTable<context>(node->_VAL.asTable, &newObj, allocator);
			obj->PushBack(newObj, allocator);
			break;
		case OT_ARRAY:
			EncodeJSONArray<context>(node->_VAL.asArray, &newArray, allocator);
			obj->PushBack(newArray, allocator);
			break;
		default:
			spdlog::info("SQ encode Json type {} not supported", SQTypeNameFromID(node->_Type));
		}
	}
}

ADD_SQFUNC(
	"table",
	DecodeJSON,
	"string json, bool fatalParseErrors = false",
	"converts a json string to a squirrel table",
	ScriptContext::UI | ScriptContext::CLIENT | ScriptContext::SERVER)
{
	const char* pJson = g_pSquirrel<context>->getstring(sqvm, 1);
	const bool bFatalParseErrors = g_pSquirrel<context>->getbool(sqvm, 2);

	rapidjson_document doc;
	doc.Parse(pJson);
	if (doc.HasParseError())
	{
		g_pSquirrel<context>->newtable(sqvm);

		std::string sErrorString = fmt::format(
			"Failed parsing json file: encountered parse error \"{}\" at offset {}",
			GetParseError_En(doc.GetParseError()),
			doc.GetErrorOffset());

		if (bFatalParseErrors)
			g_pSquirrel<context>->raiseerror(sqvm, sErrorString.c_str());
		else
			spdlog::warn(sErrorString);

		return SQRESULT_NOTNULL;
	}

	DecodeJsonTable<context>(sqvm, (rapidjson::GenericValue<rapidjson::UTF8<char>, rapidjson::MemoryPoolAllocator<SourceAllocator>>*)&doc);
	return SQRESULT_NOTNULL;
}

ADD_SQFUNC(
	"string",
	EncodeJSON,
	"table data",
	"converts a squirrel table to a json string",
	ScriptContext::UI | ScriptContext::CLIENT | ScriptContext::SERVER)
{
	rapidjson_document doc;
	doc.SetObject();

	// temp until this is just the func parameter type
	HSquirrelVM* vm = (HSquirrelVM*)sqvm;
	SQTable* table = vm->_stackOfCurrentFunction[1]._VAL.asTable;
	EncodeJSONTable<context>(table, &doc, doc.GetAllocator());

	rapidjson::StringBuffer buffer;
	rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
	doc.Accept(writer);
	const char* pJsonString = buffer.GetString();

	g_pSquirrel<context>->pushstring(sqvm, pJsonString, -1);
	return SQRESULT_NOTNULL;
}
