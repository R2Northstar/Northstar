#pragma once
#include <vector>

typedef void (*SqAutoBindFunc)();

class SquirrelAutoBindContainer
{
  public:
	std::vector<std::function<void()>> clientSqAutoBindFuncs;
	std::vector<std::function<void()>> serverSqAutoBindFuncs;
};

extern SquirrelAutoBindContainer* g_pSqAutoBindContainer;

class __squirrelautobind;

#define ADD_SQFUNC(returnType, funcName, argTypes, helpText, runOnContext)                                                                 \
	template <ScriptContext context> SQRESULT CONCAT2(Script_, funcName)(HSquirrelVM * sqvm);                                              \
	namespace                                                                                                                              \
	{                                                                                                                                      \
		__squirrelautobind CONCAT2(__squirrelautobind, __LINE__)(                                                                          \
			[]()                                                                                                                           \
			{                                                                                                                              \
				if constexpr (runOnContext & ScriptContext::UI)                                                                            \
					g_pSquirrel<ScriptContext::UI>->AddFuncRegistration(                                                                   \
						returnType, __STR(funcName), argTypes, helpText, CONCAT2(Script_, funcName) < ScriptContext::UI >);                \
				if constexpr (runOnContext & ScriptContext::CLIENT)                                                                        \
					g_pSquirrel<ScriptContext::CLIENT>->AddFuncRegistration(                                                               \
						returnType, __STR(funcName), argTypes, helpText, CONCAT2(Script_, funcName) < ScriptContext::CLIENT >);            \
			},                                                                                                                             \
			[]()                                                                                                                           \
			{                                                                                                                              \
				if constexpr (runOnContext & ScriptContext::SERVER)                                                                        \
					g_pSquirrel<ScriptContext::SERVER>->AddFuncRegistration(                                                               \
						returnType, __STR(funcName), argTypes, helpText, CONCAT2(Script_, funcName) < ScriptContext::SERVER >);            \
			});                                                                                                                            \
	}                                                                                                                                      \
	template <ScriptContext context> SQRESULT CONCAT2(Script_, funcName)(HSquirrelVM * sqvm)

#define REPLACE_SQFUNC(funcName, runOnContext)                                                                                             \
	template <ScriptContext context> SQRESULT CONCAT2(Script_, funcName)(HSquirrelVM * sqvm);                                              \
	namespace                                                                                                                              \
	{                                                                                                                                      \
		__squirrelautobind CONCAT2(__squirrelautobind, __LINE__)(                                                                          \
			[]()                                                                                                                           \
			{                                                                                                                              \
				if constexpr (runOnContext & ScriptContext::UI)                                                                            \
					g_pSquirrel<ScriptContext::UI>->AddFuncOverride(__STR(funcName), CONCAT2(Script_, funcName) < ScriptContext::UI >);    \
				if constexpr (runOnContext & ScriptContext::CLIENT)                                                                        \
					g_pSquirrel<ScriptContext::CLIENT>->AddFuncOverride(                                                                   \
						__STR(funcName), CONCAT2(Script_, funcName) < ScriptContext::CLIENT >);                                            \
			},                                                                                                                             \
			[]()                                                                                                                           \
			{                                                                                                                              \
				if constexpr (runOnContext & ScriptContext::SERVER)                                                                        \
					g_pSquirrel<ScriptContext::SERVER>->AddFuncOverride(                                                                   \
						__STR(funcName), CONCAT2(Script_, funcName) < ScriptContext::SERVER >);                                            \
			});                                                                                                                            \
	}                                                                                                                                      \
	template <ScriptContext context> SQRESULT CONCAT2(Script_, funcName)(HSquirrelVM * sqvm)

class __squirrelautobind
{
  public:
	__squirrelautobind() = delete;

	__squirrelautobind(std::function<void()> clientAutoBindFunc, std::function<void()> serverAutoBindFunc)
	{
		// Bit hacky but we can't initialise this normally since this gets run automatically on load
		if (g_pSqAutoBindContainer == nullptr)
			g_pSqAutoBindContainer = new SquirrelAutoBindContainer();

		g_pSqAutoBindContainer->clientSqAutoBindFuncs.push_back(clientAutoBindFunc);
		g_pSqAutoBindContainer->serverSqAutoBindFuncs.push_back(serverAutoBindFunc);
	}
};
