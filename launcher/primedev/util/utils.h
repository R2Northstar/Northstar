#pragma once

void RemoveAsciiControlSequences(char* str, bool allow_color_codes);

class ScopeGuard
{
public:
	auto operator=(ScopeGuard&) = delete;
	ScopeGuard(ScopeGuard&) = delete;

	ScopeGuard(std::function<void()> callback) : m_callback(callback) {}
	~ScopeGuard()
	{
		m_callback();
	}
	void Dismiss()
	{
		m_callback = [] {};
	}

private:
	std::function<void()> m_callback;
};
