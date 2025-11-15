namespace fs = std::filesystem;

class ModDownloader
{
private:
	const char* VERIFICATION_FLAG = "-disablemodverification";
	const char* CUSTOM_MODS_URL_FLAG = "-customverifiedurl=";
	const char* DEFAULT_MODS_LIST_URL = "https://raw.githubusercontent.com/R2Northstar/VerifiedMods/main/verified-mods.json";
	char* modsListUrl;

	enum class VerifiedModPlatform
	{
		Unknown,
		ModWorkshop,
		Thunderstore
	};
	VerifiedModPlatform resolvePlatform(std::string input)
	{
		if (input.compare("thunderstore") == 0)
		{
			return VerifiedModPlatform::Thunderstore;
		}
		if (input.compare("modworkshop") == 0)
		{
			return VerifiedModPlatform::ModWorkshop;
		}
		return VerifiedModPlatform::Unknown;
	}
	struct VerifiedModVersion
	{
		std::string checksum;
		std::string downloadLink;
		VerifiedModPlatform platform;
	};
	struct VerifiedModDetails
	{
		std::unordered_map<std::string, VerifiedModVersion> versions = {};
	};
	std::unordered_map<std::string, VerifiedModDetails> verifiedMods = {};

	/**
	 * Mod archive download callback.
	 *
	 * This function is called by curl as it's downloading the mod archive; this
	 * will retrieve the current `ModDownloader` instance and update its `modState`
	 * member accordingly.
	 */
	static int ModFetchingProgressCallback(
		void* ptr, curl_off_t totalDownloadSize, curl_off_t finishedDownloadSize, curl_off_t totalToUpload, curl_off_t nowUploaded);

	/**
	 * Downloads a mod archive from distant store.
	 *
	 * This rebuilds the URI of the mod archive using both a predefined store URI
	 * and the mod dependency string from the `verifiedMods` variable, or using
	 * input mod name as mod dependency string if bypass flag is set up; fetched
	 * archive is then stored in a temporary location.
	 *
	 *
	 * @param modName name of the mod to be downloaded
	 * @param modVersion version of the mod to be downloaded
	 * @returns tuple containing location of the downloaded archive and whether download completed successfully
	 */
	std::tuple<fs::path, bool> FetchModFromDistantStore(std::string_view modName, VerifiedModVersion modVersion);

	/**
	 * Tells if a mod archive has not been corrupted.
	 *
	 * The mod validation procedure includes computing the SHA256 hash of the final
	 * archive, which is stored in the verified mods list. This hash is used by this
	 * very method to ensure the archive downloaded from the Internet is the exact
	 * same that has been manually verified.
	 *
	 * @param modPath path of the archive to check
	 * @param expectedChecksum checksum the archive should have
	 * @returns whether archive is legit
	 */
	bool IsModLegit(fs::path modPath, std::string_view expectedChecksum);

	/**
	 * Extracts a mod archive to the game folder.
	 *
	 * This extracts a downloaded mod archive from its original location, `modPath`,
	 * to the specified `destinationPath`; the way to decompress the archive is
	 * defined by the `platform` parameter.
	 *
	 * @param modPath location of the downloaded archive
	 * @param destinationPath destination of the extraction
	 * @param platform origin of the downloaded archive
	 * @returns nothing
	 */
	void ExtractMod(fs::path modPath, fs::path destinationPath, VerifiedModPlatform platform);

	/**
	 * Retrieves archive name from input URL.
	 *
	 * Thunderstore and ModWorkshop do not format their URLs the same way:
	 *     - Thunderstore: https://gcdn.thunderstore.io/live/repository/packages/Nyami11-mp_brick-1.0.2.zip
	 *     - ModWorkshop:
	 * https://storage.modworkshop.net/mods/files/46563_156759_CSio1Cd3QVXYRZLd1h6iNu0IPuuaY9ePKGceQD31.zip?filename=em4v.zip
	 *
	 * This takes those differences into account and returns an archive name for
	 * both types of URLs.
	 *
	 * @param url URL from which to extract archive file name
	 * @returns name of the archive to be downloaded
	 */
	std::string GetModArchiveName(std::string url);

public:
	ModDownloader();

	/**
	 * Retrieves the verified mods list from the central authority.
	 *
	 * The Northstar auto-downloading feature does NOT allow automatically installing
	 * all mods for various (notably security) reasons; mods that are candidate to
	 * auto-downloading are rather listed on a GitHub repository
	 * (https://raw.githubusercontent.com/R2Northstar/VerifiedMods/main/verified-mods.json),
	 * which this method gets via a HTTP call to load into local state.
	 *
	 * If list fetching fails, local mods list will be initialized as empty, thus
	 * preventing any mod from being auto-downloaded.
	 *
	 * @returns nothing
	 */
	void FetchModsListFromAPI();

	/**
	 * Checks whether a mod is verified.
	 *
	 * A mod is deemed verified/authorized through a manual validation process that is
	 * described here: https://github.com/R2Northstar/VerifiedMods; in practice, a mod
	 * is considered authorized if their name AND exact version appear in the
	 * `verifiedMods` variable.
	 *
	 * @param modName name of the mod to be checked
	 * @param modVersion version of the mod to be checked, must follow semantic versioning
	 * @returns whether the mod is authorized and can be auto-downloaded
	 */
	bool IsModAuthorized(std::string_view modName, std::string_view modVersion);

	/**
	 * Downloads a given mod from Thunderstore API to local game profile.
	 *
	 * @param modName name of the mod to be downloaded
	 * @param modVersion version of the mod to be downloaded
	 * @returns nothing
	 **/
	void DownloadMod(std::string modName, std::string modVersion);

	enum ModInstallState
	{
		MANIFESTO_FETCHING,

		// Normal installation process
		DOWNLOADING,
		CHECKSUMING,
		EXTRACTING,
		DONE, // Everything went great, mod can be used in-game
		ABORTED, // User cancelled mod install process

		// Errors
		FAILED, // Generic error message, should be avoided as much as possible
		FAILED_READING_ARCHIVE,
		FAILED_WRITING_TO_DISK,
		MOD_FETCHING_FAILED,
		MOD_CORRUPTED, // Downloaded archive checksum does not match verified hash
		NO_DISK_SPACE_AVAILABLE,
		NOT_FOUND, // Mod is not currently being auto-downloaded
		UNKNOWN_PLATFORM
	};

	struct MOD_STATE
	{
		ModInstallState state;
		int progress;
		int total;
		float ratio;
	} modState = {};

	/**
	 * Cancels installation of the mod.
	 *
	 * Prevents installation of the mod currently being installed, no matter the install
	 * progress (downloading, checksuming, extracting), and frees all resources currently
	 * being used in this purpose.
	 *
	 * @returns nothing
	 */
	void CancelDownload();
};
