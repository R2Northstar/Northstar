#pragma once

// Note: this file is tier1/interface.h in primedev, but given that tier0 is yet to be split
// I am following the existing "pattern" and putting this here

#include "memory.h"

#define CREATEINTERFACE_PROCNAME "CreateInterface"

typedef void* (*CreateInterfaceFn)(const char* pName, int* pReturnCode);

CMemoryAddress Sys_GetFactoryPtr(const std::string& svModuleName, const std::string& svFact);
