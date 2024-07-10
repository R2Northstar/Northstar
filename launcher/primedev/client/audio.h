#pragma once

#include <vector>
#include <filesystem>
#include <regex>
#include <shared_mutex>

namespace fs = std::filesystem;

enum class AudioSelectionStrategy
{
	INVALID = -1,
	SEQUENTIAL,
	RANDOM
};

class EventOverrideData
{
public:
	EventOverrideData(const std::string&, const fs::path&, const std::vector<std::string>& registeredEvents);
	EventOverrideData();

public:
	bool LoadedSuccessfully = false;

	std::vector<std::string> EventIds = {};
	std::vector<std::pair<std::string, std::regex>> EventIdsRegex = {};

	std::vector<std::pair<size_t, std::unique_ptr<uint8_t[]>>> Samples = {};

	AudioSelectionStrategy Strategy = AudioSelectionStrategy::SEQUENTIAL;
	size_t CurrentIndex = 0;

	bool EnableOnLoopedSounds = false;
};

class CustomAudioManager
{
public:
	bool TryLoadAudioOverride(const fs::path&, std::string modName);
	void ClearAudioOverrides();

	std::shared_mutex m_loadingMutex;
	std::unordered_map<std::string, std::shared_ptr<EventOverrideData>> m_loadedAudioOverrides = {};
	std::unordered_map<std::string, std::shared_ptr<EventOverrideData>> m_loadedAudioOverridesRegex = {};
};

extern CustomAudioManager g_CustomAudioManager;
