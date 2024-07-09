#include "moddownloader.h"
#include "util/utils.h"
#include <rapidjson/fwd.h>
#include <mz_strm_mem.h>
#include <mz.h>
#include <mz_strm.h>
#include <mz_zip.h>
#include <mz_compat.h>
#include <thread>
#include <future>
#include <bcrypt.h>
#include <winternl.h>
#include <fstream>

ModDownloader* g_pModDownloader;

ModDownloader::ModDownloader()
{
	spdlog::info("Mod downloader initialized");

	// Initialise mods list URI
	char* clachar = strstr(GetCommandLineA(), CUSTOM_MODS_URL_FLAG);
	if (clachar)
	{
		std::string url;
		size_t iFlagStringLength = strlen(CUSTOM_MODS_URL_FLAG);
		std::string cla = std::string(clachar);
		if (strncmp(cla.substr(iFlagStringLength, 1).c_str(), "\"", 1))
		{
			size_t space = cla.find(" ");
			url = cla.substr(iFlagStringLength, space - iFlagStringLength);
		}
		else
		{
			std::string quote = "\"";
			size_t quote1 = cla.find(quote);
			size_t quote2 = (cla.substr(quote1 + 1)).find(quote);
			url = cla.substr(quote1 + 1, quote2);
		}
		spdlog::info("Found custom verified mods URL in command line argument: {}", url);
		modsListUrl = strdup(url.c_str());
	}
	else
	{
		spdlog::info("Custom verified mods URL not found in command line arguments, using default URL.");
		modsListUrl = strdup(DEFAULT_MODS_LIST_URL);
	}
}

size_t WriteToString(void* ptr, size_t size, size_t count, void* stream)
{
	((std::string*)stream)->append((char*)ptr, 0, size * count);
	return size * count;
}

void ModDownloader::FetchModsListFromAPI()
{
	std::thread requestThread(
		[this]()
		{
			CURLcode result;
			CURL* easyhandle;
			rapidjson::Document verifiedModsJson;
			std::string url = modsListUrl;

			curl_global_init(CURL_GLOBAL_ALL);
			easyhandle = curl_easy_init();
			std::string readBuffer;

			// Fetching mods list from GitHub repository
			curl_easy_setopt(easyhandle, CURLOPT_CUSTOMREQUEST, "GET");
			curl_easy_setopt(easyhandle, CURLOPT_TIMEOUT, 30L);
			curl_easy_setopt(easyhandle, CURLOPT_URL, url.c_str());
			curl_easy_setopt(easyhandle, CURLOPT_FAILONERROR, 1L);
			curl_easy_setopt(easyhandle, CURLOPT_WRITEDATA, &readBuffer);
			curl_easy_setopt(easyhandle, CURLOPT_WRITEFUNCTION, WriteToString);
			result = curl_easy_perform(easyhandle);
			ScopeGuard cleanup([&] { curl_easy_cleanup(easyhandle); });

			if (result == CURLcode::CURLE_OK)
			{
				spdlog::info("Mods list successfully fetched.");
			}
			else
			{
				spdlog::error("Fetching mods list failed: {}", curl_easy_strerror(result));
				return;
			}

			// Load mods list into local state
			spdlog::info("Loading mods configuration...");
			verifiedModsJson.Parse(readBuffer);
			for (auto i = verifiedModsJson.MemberBegin(); i != verifiedModsJson.MemberEnd(); ++i)
			{
				// Format testing
				if (!i->value.HasMember("DependencyPrefix") || !i->value.HasMember("Versions"))
				{
					spdlog::warn("Verified mods manifesto format is unrecognized, skipping loading.");
					return;
				}

				std::string name = i->name.GetString();
				std::string dependency = i->value["DependencyPrefix"].GetString();

				std::unordered_map<std::string, VerifiedModVersion> modVersions;
				rapidjson::Value& versions = i->value["Versions"];
				assert(versions.IsArray());
				for (auto& attribute : versions.GetArray())
				{
					assert(attribute.IsObject());
					// Format testing
					if (!attribute.HasMember("Version") || !attribute.HasMember("Checksum"))
					{
						spdlog::warn("Verified mods manifesto format is unrecognized, skipping loading.");
						return;
					}

					std::string version = attribute["Version"].GetString();
					std::string checksum = attribute["Checksum"].GetString();
					modVersions.insert({version, {.checksum = checksum}});
				}

				VerifiedModDetails modConfig = {.dependencyPrefix = dependency, .versions = modVersions};
				verifiedMods.insert({name, modConfig});
				spdlog::info("==> Loaded configuration for mod \"" + name + "\"");
			}

			spdlog::info("Done loading verified mods list.");
		});
	requestThread.detach();
}

size_t WriteData(void* ptr, size_t size, size_t nmemb, FILE* stream)
{
	size_t written;
	written = fwrite(ptr, size, nmemb, stream);
	return written;
}

int ModDownloader::ModFetchingProgressCallback(
	void* ptr, curl_off_t totalDownloadSize, curl_off_t finishedDownloadSize, curl_off_t totalToUpload, curl_off_t nowUploaded)
{
	NOTE_UNUSED(totalToUpload);
	NOTE_UNUSED(nowUploaded);
	if (totalDownloadSize != 0 && finishedDownloadSize != 0)
	{
		ModDownloader* instance = static_cast<ModDownloader*>(ptr);
		auto currentDownloadProgress = roundf(static_cast<float>(finishedDownloadSize) / totalDownloadSize * 100);
		instance->modState.progress = finishedDownloadSize;
		instance->modState.total = totalDownloadSize;
		instance->modState.ratio = currentDownloadProgress;
	}

	return 0;
}

std::optional<fs::path> ModDownloader::FetchModFromDistantStore(std::string_view modName, std::string_view modVersion)
{
	// Retrieve mod prefix from local mods list, or use mod name as mod prefix if bypass flag is set
	std::string modPrefix = strstr(GetCommandLineA(), VERIFICATION_FLAG) ? modName.data() : verifiedMods[modName.data()].dependencyPrefix;
	// Build archive distant URI
	std::string archiveName = std::format("{}-{}.zip", modPrefix, modVersion.data());
	std::string url = STORE_URL + archiveName;
	spdlog::info(std::format("Fetching mod archive from {}", url));

	// Download destination
	std::filesystem::path downloadPath = std::filesystem::temp_directory_path() / archiveName;
	spdlog::info(std::format("Downloading archive to {}", downloadPath.generic_string()));

	// Update state
	modState.state = DOWNLOADING;

	// Download the actual archive
	bool failed = false;
	FILE* fp = fopen(downloadPath.generic_string().c_str(), "wb");
	CURLcode result;
	CURL* easyhandle;
	easyhandle = curl_easy_init();

	curl_easy_setopt(easyhandle, CURLOPT_URL, url.data());
	curl_easy_setopt(easyhandle, CURLOPT_FAILONERROR, 1L);

	// abort if slower than 30 bytes/sec during 10 seconds
	curl_easy_setopt(easyhandle, CURLOPT_LOW_SPEED_TIME, 10L);
	curl_easy_setopt(easyhandle, CURLOPT_LOW_SPEED_LIMIT, 30L);

	curl_easy_setopt(easyhandle, CURLOPT_WRITEDATA, fp);
	curl_easy_setopt(easyhandle, CURLOPT_WRITEFUNCTION, WriteData);
	curl_easy_setopt(easyhandle, CURLOPT_NOPROGRESS, 0L);
	curl_easy_setopt(easyhandle, CURLOPT_XFERINFOFUNCTION, ModDownloader::ModFetchingProgressCallback);
	curl_easy_setopt(easyhandle, CURLOPT_XFERINFODATA, this);
	result = curl_easy_perform(easyhandle);
	ScopeGuard cleanup(
		[&]
		{
			curl_easy_cleanup(easyhandle);
			fclose(fp);
		});

	if (result == CURLcode::CURLE_OK)
	{
		spdlog::info("Mod archive successfully fetched.");
		return std::optional<fs::path>(downloadPath);
	}
	else
	{
		spdlog::error("Fetching mod archive failed: {}", curl_easy_strerror(result));
		return std::optional<fs::path>();
	}
}

bool ModDownloader::IsModLegit(fs::path modPath, std::string_view expectedChecksum)
{
	if (strstr(GetCommandLineA(), VERIFICATION_FLAG))
	{
		spdlog::info("Bypassing mod verification due to flag set up.");
		return true;
	}

	// Update state
	modState.state = CHECKSUMING;

	NTSTATUS status;
	BCRYPT_ALG_HANDLE algorithmHandle = NULL;
	BCRYPT_HASH_HANDLE hashHandle = NULL;
	std::vector<uint8_t> hash;
	DWORD hashLength = 0;
	DWORD resultLength = 0;
	std::stringstream ss;

	constexpr size_t bufferSize {1 << 12};
	std::vector<char> buffer(bufferSize, '\0');
	std::ifstream fp(modPath.generic_string(), std::ios::binary);

	ScopeGuard cleanup(
		[&]
		{
			if (NULL != hashHandle)
			{
				BCryptDestroyHash(hashHandle); // Handle to hash/MAC object which needs to be destroyed
			}

			if (NULL != algorithmHandle)
			{
				BCryptCloseAlgorithmProvider(
					algorithmHandle, // Handle to the algorithm provider which needs to be closed
					0); // Flags
			}
		});

	// Open an algorithm handle
	// This sample passes BCRYPT_HASH_REUSABLE_FLAG with BCryptAlgorithmProvider(...) to load a provider which supports reusable hash
	status = BCryptOpenAlgorithmProvider(
		&algorithmHandle, // Alg Handle pointer
		BCRYPT_SHA256_ALGORITHM, // Cryptographic Algorithm name (null terminated unicode string)
		NULL, // Provider name; if null, the default provider is loaded
		BCRYPT_HASH_REUSABLE_FLAG); // Flags; Loads a provider which supports reusable hash
	if (!NT_SUCCESS(status))
	{
		modState.state = MOD_CORRUPTED;
		return false;
	}

	// Obtain the length of the hash
	status = BCryptGetProperty(
		algorithmHandle, // Handle to a CNG object
		BCRYPT_HASH_LENGTH, // Property name (null terminated unicode string)
		(PBYTE)&hashLength, // Address of the output buffer which recieves the property value
		sizeof(hashLength), // Size of the buffer in bytes
		&resultLength, // Number of bytes that were copied into the buffer
		0); // Flags
	if (!NT_SUCCESS(status))
	{
		modState.state = MOD_CORRUPTED;
		return false;
	}

	// Create a hash handle
	status = BCryptCreateHash(
		algorithmHandle, // Handle to an algorithm provider
		&hashHandle, // A pointer to a hash handle - can be a hash or hmac object
		NULL, // Pointer to the buffer that recieves the hash/hmac object
		0, // Size of the buffer in bytes
		NULL, // A pointer to a key to use for the hash or MAC
		0, // Size of the key in bytes
		0); // Flags
	if (!NT_SUCCESS(status))
	{
		modState.state = MOD_CORRUPTED;
		return false;
	}

	// Hash archive content
	if (!fp.is_open())
	{
		spdlog::error("Unable to open archive.");
		modState.state = FAILED_READING_ARCHIVE;
		return false;
	}
	fp.seekg(0, fp.beg);
	while (fp.good())
	{
		fp.read(buffer.data(), bufferSize);
		std::streamsize bytesRead = fp.gcount();
		if (bytesRead > 0)
		{
			status = BCryptHashData(hashHandle, (PBYTE)buffer.data(), bytesRead, 0);
			if (!NT_SUCCESS(status))
			{
				modState.state = MOD_CORRUPTED;
				return false;
			}
		}
	}

	hash = std::vector<uint8_t>(hashLength);

	// Obtain the hash of the message(s) into the hash buffer
	status = BCryptFinishHash(
		hashHandle, // Handle to the hash or MAC object
		hash.data(), // A pointer to a buffer that receives the hash or MAC value
		hashLength, // Size of the buffer in bytes
		0); // Flags
	if (!NT_SUCCESS(status))
	{
		modState.state = MOD_CORRUPTED;
		return false;
	}

	// Convert hash to string using bytes raw values
	ss << std::hex << std::setfill('0');
	for (int i = 0; i < hashLength; i++)
	{
		ss << std::hex << std::setw(2) << static_cast<int>(hash.data()[i]);
	}

	spdlog::info("Expected checksum: {}", expectedChecksum.data());
	spdlog::info("Computed checksum: {}", ss.str());
	return expectedChecksum.compare(ss.str()) == 0;
}

bool ModDownloader::IsModAuthorized(std::string_view modName, std::string_view modVersion)
{
	if (strstr(GetCommandLineA(), VERIFICATION_FLAG))
	{
		spdlog::info("Bypassing mod verification due to flag set up.");
		return true;
	}

	if (!verifiedMods.contains(modName.data()))
	{
		return false;
	}

	std::unordered_map<std::string, VerifiedModVersion> versions = verifiedMods[modName.data()].versions;
	return versions.count(modVersion.data()) != 0;
}

int GetModArchiveSize(unzFile file, unz_global_info64 info)
{
	int totalSize = 0;

	for (int i = 0; i < info.number_entry; i++)
	{
		char zipFilename[256];
		unz_file_info64 fileInfo;
		unzGetCurrentFileInfo64(file, &fileInfo, zipFilename, sizeof(zipFilename), NULL, 0, NULL, 0);

		totalSize += fileInfo.uncompressed_size;

		if ((i + 1) < info.number_entry)
		{
			unzGoToNextFile(file);
		}
	}

	// Reset file pointer for archive extraction
	unzGoToFirstFile(file);

	return totalSize;
}

void ModDownloader::ExtractMod(fs::path modPath)
{
	unzFile file;
	std::string name;
	fs::path modDirectory;

	file = unzOpen(modPath.generic_string().c_str());
	ScopeGuard cleanup(
		[&]
		{
			if (unzClose(file) != MZ_OK)
			{
				spdlog::error("Failed closing mod archive after extraction.");
			}
		});

	if (file == NULL)
	{
		spdlog::error("Cannot open archive located at {}.", modPath.generic_string());
		modState.state = FAILED_READING_ARCHIVE;
		return;
	}

	unz_global_info64 gi;
	int status;
	status = unzGetGlobalInfo64(file, &gi);
	if (status != UNZ_OK)
	{
		spdlog::error("Failed getting information from archive (error code: {})", status);
		modState.state = FAILED_READING_ARCHIVE;
		return;
	}

	// Update state
	modState.state = EXTRACTING;
	modState.total = GetModArchiveSize(file, gi);
	modState.progress = 0;

	// Mod directory name (removing the ".zip" fom the archive name)
	name = modPath.filename().string();
	name = name.substr(0, name.length() - 4);
	modDirectory = GetRemoteModFolderPath() / name;

	for (int i = 0; i < gi.number_entry; i++)
	{
		char zipFilename[256];
		unz_file_info64 fileInfo;
		status = unzGetCurrentFileInfo64(file, &fileInfo, zipFilename, sizeof(zipFilename), NULL, 0, NULL, 0);

		// Extract file
		{
			std::error_code ec;
			fs::path fileDestination = modDirectory / zipFilename;
			spdlog::info("=> {}", fileDestination.generic_string());

			// Create parent directory if needed
			if (!std::filesystem::exists(fileDestination.parent_path()))
			{
				spdlog::info("Parent directory does not exist, creating it.", fileDestination.generic_string());
				if (!std::filesystem::create_directories(fileDestination.parent_path(), ec) && ec.value() != 0)
				{
					spdlog::error("Parent directory ({}) creation failed.", fileDestination.parent_path().generic_string());
					modState.state = FAILED_WRITING_TO_DISK;
					return;
				}
			}

			// If current file is a directory, create directory...
			if (fileDestination.generic_string().back() == '/')
			{
				// Create directory
				if (!std::filesystem::create_directory(fileDestination, ec) && ec.value() != 0)
				{
					spdlog::error("Directory creation failed: {}", ec.message());
					modState.state = FAILED_WRITING_TO_DISK;
					return;
				}
			}
			// ...else create file
			else
			{
				// Ensure file is in zip archive
				if (unzLocateFile(file, zipFilename, 0) != UNZ_OK)
				{
					spdlog::error("File \"{}\" was not found in archive.", zipFilename);
					modState.state = FAILED_READING_ARCHIVE;
					return;
				}

				// Create file
				const int bufferSize = 8192;
				void* buffer;
				int err = UNZ_OK;
				FILE* fout = NULL;

				// Open zip file to prepare its extraction
				status = unzOpenCurrentFile(file);
				if (status != UNZ_OK)
				{
					spdlog::error("Could not open file {} from archive.", zipFilename);
					modState.state = FAILED_READING_ARCHIVE;
					return;
				}

				// Create destination file
				fout = fopen(fileDestination.generic_string().c_str(), "wb");
				if (fout == NULL)
				{
					spdlog::error("Failed creating destination file.");
					modState.state = FAILED_WRITING_TO_DISK;
					return;
				}

				// Allocate memory for buffer
				buffer = (void*)malloc(bufferSize);
				if (buffer == NULL)
				{
					spdlog::error("Error while allocating memory.");
					modState.state = FAILED_WRITING_TO_DISK;
					return;
				}

				// Extract file to destination
				do
				{
					err = unzReadCurrentFile(file, buffer, bufferSize);
					if (err < 0)
					{
						spdlog::error("error {} with zipfile in unzReadCurrentFile", err);
						break;
					}
					if (err > 0)
					{
						if (fwrite(buffer, (unsigned)err, 1, fout) != 1)
						{
							spdlog::error("error in writing extracted file\n");
							err = UNZ_ERRNO;
							break;
						}
					}

					// Update extraction stats
					modState.progress += bufferSize;
					modState.ratio = roundf(static_cast<float>(modState.progress) / modState.total * 100);
				} while (err > 0);

				if (err != UNZ_OK)
				{
					spdlog::error("An error occurred during file extraction (code: {})", err);
					modState.state = FAILED_WRITING_TO_DISK;
					return;
				}
				err = unzCloseCurrentFile(file);
				if (err != UNZ_OK)
				{
					spdlog::error("error {} with zipfile in unzCloseCurrentFile", err);
				}

				// Cleanup
				if (fout)
					fclose(fout);
			}
		}

		// Go to next file
		if ((i + 1) < gi.number_entry)
		{
			status = unzGoToNextFile(file);
			if (status != UNZ_OK)
			{
				spdlog::error("Error while browsing archive files (error code: {}).", status);
				return;
			}
		}
	}
}

void ModDownloader::DownloadMod(std::string modName, std::string modVersion)
{
	// Check if mod can be auto-downloaded
	if (!IsModAuthorized(std::string_view(modName), std::string_view(modVersion)))
	{
		spdlog::warn("Tried to download a mod that is not verified, aborting.");
		return;
	}

	std::thread requestThread(
		[this, modName, modVersion]()
		{
			fs::path archiveLocation;

			ScopeGuard cleanup(
				[&]
				{
					try
					{
						remove(archiveLocation);
					}
					catch (const std::exception& a)
					{
						spdlog::error("Error while removing downloaded archive: {}", a.what());
					}

					modState.state = DONE;
					spdlog::info("Done downloading {}.", modName);
				});

			// Download mod archive
			std::string expectedHash = verifiedMods[modName].versions[modVersion].checksum;
			std::optional<fs::path> fetchingResult = FetchModFromDistantStore(std::string_view(modName), std::string_view(modVersion));
			if (!fetchingResult.has_value())
			{
				spdlog::error("Something went wrong while fetching archive, aborting.");
				modState.state = MOD_FETCHING_FAILED;
				return;
			}
			archiveLocation = fetchingResult.value();
			if (!IsModLegit(archiveLocation, std::string_view(expectedHash)))
			{
				spdlog::warn("Archive hash does not match expected checksum, aborting.");
				modState.state = MOD_CORRUPTED;
				return;
			}

			// Extract downloaded mod archive
			ExtractMod(archiveLocation);
		});

	requestThread.detach();
}

ON_DLL_LOAD_RELIESON("engine.dll", ModDownloader, (ConCommand), (CModule module))
{
	g_pModDownloader = new ModDownloader();
	g_pModDownloader->FetchModsListFromAPI();
}

ADD_SQFUNC(
	"bool", NSIsModDownloadable, "string name, string version", "", ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	g_pSquirrel<context>->newarray(sqvm, 0);

	const SQChar* modName = g_pSquirrel<context>->getstring(sqvm, 1);
	const SQChar* modVersion = g_pSquirrel<context>->getstring(sqvm, 2);

	bool result = g_pModDownloader->IsModAuthorized(modName, modVersion);
	g_pSquirrel<context>->pushbool(sqvm, result);

	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("void", NSDownloadMod, "string name, string version", "", ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	const SQChar* modName = g_pSquirrel<context>->getstring(sqvm, 1);
	const SQChar* modVersion = g_pSquirrel<context>->getstring(sqvm, 2);
	g_pModDownloader->DownloadMod(modName, modVersion);

	return SQRESULT_NOTNULL;
}

ADD_SQFUNC("ModInstallState", NSGetModInstallState, "", "", ScriptContext::SERVER | ScriptContext::CLIENT | ScriptContext::UI)
{
	g_pSquirrel<context>->pushnewstructinstance(sqvm, 4);

	// state
	g_pSquirrel<context>->pushinteger(sqvm, g_pModDownloader->modState.state);
	g_pSquirrel<context>->sealstructslot(sqvm, 0);

	// progress
	g_pSquirrel<context>->pushinteger(sqvm, g_pModDownloader->modState.progress);
	g_pSquirrel<context>->sealstructslot(sqvm, 1);

	// total
	g_pSquirrel<context>->pushinteger(sqvm, g_pModDownloader->modState.total);
	g_pSquirrel<context>->sealstructslot(sqvm, 2);

	// ratio
	g_pSquirrel<context>->pushfloat(sqvm, g_pModDownloader->modState.ratio);
	g_pSquirrel<context>->sealstructslot(sqvm, 3);

	return SQRESULT_NOTNULL;
}
