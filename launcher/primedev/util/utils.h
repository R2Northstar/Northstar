#pragma once

void RemoveAsciiControlSequences(char* str, bool allow_color_codes);

template <typename T> class ScopeGuard
{
public:
	auto operator=(ScopeGuard&) = delete;
	ScopeGuard(ScopeGuard&) = delete;

	ScopeGuard(T callback) : m_callback(callback) {}
	~ScopeGuard()
	{
		if (!m_dismissed)
			m_callback();
	}
	void Dismiss() { m_dismissed = true; }

private:
	bool m_dismissed = false;
	T m_callback;
};
