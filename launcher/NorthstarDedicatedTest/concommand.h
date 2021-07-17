#pragma once
#include "convar.h"

// taken from ttf2sdk
class ConCommand
{
    unsigned char               unknown[0x68];
public:
    virtual	void    			EngineDestructor(void) {}
    virtual	bool				IsCommand(void) const { return false; }
    virtual bool				IsFlagSet(int flag) { return false; }
    virtual void				AddFlags(int flags) {}
    virtual void				RemoveFlags(int flags) {}
    virtual int					GetFlags() const { return 0; }
    virtual const char* GetName(void) const { return nullptr; }
    virtual const char* GetHelpText(void) const { return nullptr; }
    virtual bool				IsRegistered(void) const { return false; }
    // NOTE: there are more virtual methods here
    // NOTE: Not using the engine's destructor here because it doesn't do anything useful for us
};

// From Source SDK
class CCommand
{
public:
    CCommand() = delete;

    int64_t ArgC() const;
    const char** ArgV() const;
    const char* ArgS() const;					// All args that occur after the 0th arg, in string form
    const char* GetCommandString() const;		// The entire command in string form, including the 0th arg
    const char* operator[](int nIndex) const;	// Gets at arguments
    const char* Arg(int nIndex) const;		// Gets at arguments

    static int MaxCommandLength();

private:
    enum
    {
        COMMAND_MAX_ARGC = 64,
        COMMAND_MAX_LENGTH = 512,
    };

    int64_t		m_nArgc;
    int64_t		m_nArgv0Size;
    char    	m_pArgSBuffer[COMMAND_MAX_LENGTH];
    char	    m_pArgvBuffer[COMMAND_MAX_LENGTH];
    const char* m_ppArgv[COMMAND_MAX_ARGC];
};

inline int CCommand::MaxCommandLength()
{
    return COMMAND_MAX_LENGTH - 1;
}

inline int64_t CCommand::ArgC() const
{
    return m_nArgc;
}

inline const char** CCommand::ArgV() const
{
    return m_nArgc ? (const char**)m_ppArgv : NULL;
}

inline const char* CCommand::ArgS() const
{
    return m_nArgv0Size ? &m_pArgSBuffer[m_nArgv0Size] : "";
}

inline const char* CCommand::GetCommandString() const
{
    return m_nArgc ? m_pArgSBuffer : "";
}

inline const char* CCommand::Arg(int nIndex) const
{
    // FIXME: Many command handlers appear to not be particularly careful
    // about checking for valid argc range. For now, we're going to
    // do the extra check and return an empty string if it's out of range
    if (nIndex < 0 || nIndex >= m_nArgc)
        return "";
    return m_ppArgv[nIndex];
}

inline const char* CCommand::operator[](int nIndex) const
{
    return Arg(nIndex);
}

void RegisterConCommand(const char* name, void(*callback)(const CCommand&), const char* helpString, int flags);
void InitialiseConCommands(HMODULE baseAddress);