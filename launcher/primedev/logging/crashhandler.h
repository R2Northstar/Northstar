#pragma once

#include <mutex>

//-----------------------------------------------------------------------------
// Purpose: Exception handling
//-----------------------------------------------------------------------------
class CCrashHandler
{
public:
	CCrashHandler();
	~CCrashHandler();

	void Init();
	void Shutdown();

	void Lock()
	{
		m_Mutex.lock();
	}

	void Unlock()
	{
		m_Mutex.unlock();
	}

	void SetState(bool bState)
	{
		m_bState = bState;
	}

	bool GetState() const
	{
		return m_bState;
	}

	void SetAllFatal(bool bState)
	{
		m_bAllExceptionsFatal = bState;
	}

	bool GetAllFatal() const
	{
		return m_bAllExceptionsFatal;
	}

	//-----------------------------------------------------------------------------
	// Exception helpers
	//-----------------------------------------------------------------------------
	void SetExceptionInfos(EXCEPTION_POINTERS* pExceptionPointers);

	void SetCrashedModule();

	const CHAR* GetExceptionString() const;
	const CHAR* GetExceptionString(DWORD dwExceptionCode) const;

	bool IsExceptionFatal() const;
	bool IsExceptionFatal(DWORD dwExceptionCode) const;

	//-----------------------------------------------------------------------------
	// Formatting
	//-----------------------------------------------------------------------------
	void ShowPopUpMessage();

	void FormatException();
	void FormatCallstack();
	void FormatFlags(const CHAR* pszRegister, DWORD nValue);
	void FormatIntReg(const CHAR* pszRegister, DWORD64 nValue);
	void FormatFloatReg(const CHAR* pszRegister, M128A nValue);
	void FormatRegisters();
	void FormatLoadedMods();
	void FormatLoadedPlugins();
	void FormatModules();

	//-----------------------------------------------------------------------------
	// Minidump
	//-----------------------------------------------------------------------------
	void WriteMinidump();

private:
	PVOID m_hExceptionFilter;
	EXCEPTION_POINTERS* m_pExceptionInfos;

	bool m_bHasSetConsolehandler;
	bool m_bAllExceptionsFatal;
	bool m_bHasShownCrashMsg;
	bool m_bState;

	std::string m_svCrashedModule;
	std::string m_svCrashedOffset;

	std::string m_svError;

	std::mutex m_Mutex;
};

extern CCrashHandler* g_pCrashHandler;
