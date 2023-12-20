#pragma once
#include "plugin_abi.h"

#include <queue>
#include <mutex>

enum PluginDataRequestType
{
	END = 0,
};

union PluginRespondDataCallable
{
	// Empty for now
	void* UNUSED;
};

class PluginDataRequest
{
public:
	PluginDataRequestType type;
	PluginRespondDataCallable func;
	PluginDataRequest(PluginDataRequestType type, PluginRespondDataCallable func) : type(type), func(func) {}
};

class PluginCommunicationHandler
{
public:
	void RunFrame();
	void PushRequest(PluginDataRequestType type, PluginRespondDataCallable func);

public:
	std::queue<PluginDataRequest> requestQueue = {};
	std::mutex requestMutex;

	PluginEngineData m_sEngineData {};
};

void InformPluginsDLLLoad(fs::path dllPath, void* address);
extern PluginCommunicationHandler* g_pPluginCommunicationhandler;
