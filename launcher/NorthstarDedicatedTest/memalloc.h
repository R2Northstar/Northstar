#pragma once

#include "include/rapidjson/document.h"
//#include "include/rapidjson/allocators.h"

extern "C" void* _malloc_base(size_t size);
extern "C" void* _calloc_base(size_t const count, size_t const size);
extern "C" void* _realloc_base(void* block, size_t size);
extern "C" void* _recalloc_base(void* const block, size_t const count, size_t const size);
extern "C" void _free_base(void* const block);
extern "C" char* _strdup_base(const char* src);

void* operator new(size_t n);
void operator delete(void* p);

// void* malloc(size_t n);

class SourceAllocator
{
  public:
	static const bool kNeedFree = true;
	void* Malloc(size_t size)
	{
		if (size) // behavior of malloc(0) is implementation defined.
			return _malloc_base(size);
		else
			return NULL; // standardize to returning NULL.
	}
	void* Realloc(void* originalPtr, size_t originalSize, size_t newSize)
	{
		(void)originalSize;
		if (newSize == 0)
		{
			_free_base(originalPtr);
			return NULL;
		}
		return _realloc_base(originalPtr, newSize);
	}
	static void Free(void* ptr)
	{
		_free_base(ptr);
	}
};

typedef rapidjson::GenericDocument<rapidjson::UTF8<>, rapidjson::MemoryPoolAllocator<SourceAllocator>, SourceAllocator> rapidjson_document;
// typedef rapidjson::GenericDocument<rapidjson::UTF8<>, SourceAllocator, SourceAllocator> rapidjson_document;
// typedef rapidjson::Document rapidjson_document;
// using MyDocument = rapidjson::GenericDocument<rapidjson::UTF8<>, MemoryAllocator>;
// using rapidjson_document = rapidjson::GenericDocument<rapidjson::UTF8<>, SourceAllocator, SourceAllocator>;
