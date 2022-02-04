#include "pch.h"
#include "languagehooks.h"
#include "gameutils.h"
#include "dedicated.h"
#include <filesystem>
#include <regex>

namespace fs = std::filesystem;

typedef char* (*GetGameLanguageType)();
char* GetGameLanguage();

typedef LANGID (*Tier0_DetectDefaultLanguageType)();

GetGameLanguageType GetGameLanguageOriginal;

bool CheckLangAudioExists(char* lang)
{
	std::string path{"r2\\sound\\general_"};
	path += lang;
	path += ".mstr";
	return fs::exists(path);
}

std::vector<std::string> file_list(fs::path dir, std::regex ext_pattern)
{
	std::vector<std::string> result;

	if (!fs::exists(dir) || !fs::is_directory(dir))
		return result;

	using iterator = fs::directory_iterator;

	const iterator end;
	for (iterator iter{dir}; iter != end; ++iter)
	{
		const std::string filename = iter->path().filename().string();
		std::smatch matches;
		if (fs::is_regular_file(*iter) && std::regex_match(filename, matches, ext_pattern))
		{
			result.push_back(std::move(matches.str(1)));
		}
	}

	return result;
}

std::string GetAnyInstalledAudioLanguage()
{
	for (const auto& lang : file_list("r2\\sound\\", std::regex(".*?general_([a-z]+)_patch_1\\.mstr")))
		if (lang != "general" || lang != "")
			return lang;
	return "NO LANGUAGE DETECTED";
}

char* GetGameLanguageHook()
{
	auto tier0Handle = GetModuleHandleA("tier0.dll");
	auto Tier0_DetectDefaultLanguageType = GetProcAddress(tier0Handle, "Tier0_DetectDefaultLanguage");
	char* ingameLang1 = (char*)tier0Handle + 0xA9B60; // one of the globals we need to override if overriding lang (size: 256)
	bool& canOriginDictateLang = *(bool*)((char*)tier0Handle + 0xA9A90);

	const char* forcedLanguage;
	if (CommandLine()->CheckParm("-language", &forcedLanguage))
	{
		if (!CheckLangAudioExists((char*)forcedLanguage))
		{
			spdlog::info(
				"User tried to force the language (-language) to \"{}\", but audio for this language doesn't exist and the game is bound "
				"to error, falling back to next option...",
				forcedLanguage);
		}
		else
		{
			spdlog::info("User forcing the language (-language) to: {}", forcedLanguage);
			strncpy(ingameLang1, forcedLanguage, 256);
			return ingameLang1;
		}
	}

	canOriginDictateLang = true; // let it try
	{
		auto lang = GetGameLanguageOriginal();
		if (!CheckLangAudioExists(lang))
		{
			if (strcmp(lang, "russian") !=
				0) // don't log for "russian" since it's the default and that means Origin detection just didn't change it most likely
				spdlog::info(
					"Origin detected language \"{}\", but we do not have audio for it installed, falling back to the next option", lang);
		}
		else
		{
			spdlog::info("Origin detected language: {}", lang);
			return lang;
		}
	}

	Tier0_DetectDefaultLanguageType(); // force the global in tier0 to be populated with language inferred from user's system rather than
									   // defaulting to Russian
	canOriginDictateLang = false;	   // Origin has no say anymore, we will fallback to user's system setup language
	auto lang = GetGameLanguageOriginal();
	spdlog::info("Detected system language: {}", lang);
	if (!CheckLangAudioExists(lang))
	{
		spdlog::warn("Caution, audio for this language does NOT exist. You might want to override your game language with -language "
					 "command line option.");
		auto lang = GetAnyInstalledAudioLanguage();
		spdlog::warn("Falling back to the first installed audio language: {}", lang.c_str());
		strncpy(ingameLang1, lang.c_str(), 256);
		return ingameLang1;
	}

	return lang;
}

void InitialiseTier0LanguageHooks(HMODULE baseAddress)
{
	if (IsDedicated())
		return;

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0xF560, &GetGameLanguageHook, reinterpret_cast<LPVOID*>(&GetGameLanguageOriginal));
}