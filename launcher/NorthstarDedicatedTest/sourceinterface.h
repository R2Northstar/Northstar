#pragma once
#include <string>

// literally just copied from ttf2sdk definition
typedef void* (*CreateInterfaceFn)(const char* pName, int* pReturnCode);

template<typename T> class SourceInterface
{
private:
    T* m_interface;

public:
    SourceInterface(const std::string& moduleName, const std::string& interfaceName);

    T* operator->() const
    {
        return m_interface;
    }

    operator T* () const
    {
        return m_interface;
    }
};
