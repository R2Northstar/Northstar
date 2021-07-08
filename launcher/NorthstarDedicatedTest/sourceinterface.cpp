#include "pch.h"
#include "sourceinterface.h"
#include <string>
#include "tier0.h"

template<typename T> SourceInterface<T>::SourceInterface(const std::string& moduleName, const std::string& interfaceName)
{
    HMODULE handle = GetModuleHandleA(moduleName.c_str());
    CreateInterfaceFn createInterface = (CreateInterfaceFn)GetProcAddress(handle, interfaceName.c_str());
    m_interface = (T*)createInterface(interfaceName.c_str(), NULL);
    if (m_interface == nullptr)
        Error("Failed to call CreateInterface for %s in %s", interfaceName, moduleName);
}