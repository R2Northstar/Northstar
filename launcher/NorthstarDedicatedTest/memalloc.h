#pragma once

extern size_t g_iStaticAllocated;

void* operator new(size_t n);
void operator delete(void* p);