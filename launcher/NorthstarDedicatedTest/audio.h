#pragma once

#include <vector>
#include <filesystem>
#include <regex>

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
	EventOverrideData(const std::string&, const fs::path&);
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
	bool TryLoadAudioOverride(const fs::path&);
	void ClearAudioOverrides();

	std::unordered_map<std::string, std::shared_ptr<EventOverrideData>> m_loadedAudioOverrides = {};
	std::unordered_map<std::string, std::shared_ptr<EventOverrideData>> m_loadedAudioOverridesRegex = {};
};

extern CustomAudioManager g_CustomAudioManager;

void InitialiseMilesAudioHooks(HMODULE baseAddress);