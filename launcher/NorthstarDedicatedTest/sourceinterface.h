#pragma once
#include <string>

// literally just copied from ttf2sdk definition
typedef void* (*CreateInterfaceFn)(const char* pName, int* pReturnCode);

template <typename T> class SourceInterface
{
  private:
	T* m_interface;

  public:
	SourceInterface(const std::string& moduleName, const std::string& interfaceName)
	{
		HMODULE handle = GetModuleHandleA(moduleName.c_str());
		CreateInterfaceFn createInterface = (CreateInterfaceFn)GetProcAddress(handle, "CreateInterface");
		m_interface = (T*)createInterface(interfaceName.c_str(), NULL);
		if (m_interface == nullptr)
			spdlog::error("Failed to call CreateInterface for %s in %s", interfaceName, moduleName);
	}

	T* operator->() const { return m_interface; }

	operator T*() const { return m_interface; }
};

// functions for interface creation callbacks
void InitialiseInterfaceCreationHooks();