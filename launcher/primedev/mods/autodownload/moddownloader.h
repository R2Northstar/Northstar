namespace fs = std::filesystem;

class ModDownloader
{
private:
	const char* VERIFICATION_FLAG = "-disablemodverification";
	const char* CUSTOM_MODS_URL_FLAG = "-customverifiedurl=";
	const char* STORE_URL = "https://gcdn.thunderstore.io/live/repository/packages/";
	const char* DEFAULT_MODS_LIST_URL = "https://raw.githubusercontent.com/R2Northstar/VerifiedMods/main/verified-mods.json";
	char* modsListUrl;

	struct VerifiedModVersion
	{
		std::string checksum;
	};
	struct VerifiedModDetails
	{
		std::string dependencyPrefix;
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
	 * If something went wrong during archive download, this will return an empty
	 * optional object.
	 *
	 * @param modName name of the mod to be downloaded
	 * @param modVersion version of the mod to be downloaded
	 * @returns location of the downloaded archive
	 */
	std::optional<fs::path> FetchModFromDistantStore(std::string_view modName, std::string_view modVersion);

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
	 * This extracts a downloaded mod archive from its original location to the
	 * current game profile, in the remote mods folder.
	 *
	 * @param modPath location of the downloaded archive
	 * @returns nothing
	 */
	void ExtractMod(fs::path modPath);

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
		// Normal installation process
		DOWNLOADING,
		CHECKSUMING,
		EXTRACTING,
		DONE, // Everything went great, mod can be used in-game

		// Errors
		FAILED, // Generic error message, should be avoided as much as possible
		FAILED_READING_ARCHIVE,
		FAILED_WRITING_TO_DISK,
		MOD_FETCHING_FAILED,
		MOD_CORRUPTED, // Downloaded archive checksum does not match verified hash
		NO_DISK_SPACE_AVAILABLE,
		NOT_FOUND // Mod is not currently being auto-downloaded
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
