#pragma once
int GetMaxSaveFolderSize();
bool ContainsInvalidChars(std::string str);

class SaveFileManager
{
  public:
	template <ScriptContext context> void SaveFileAsync(fs::path file, std::string content);
	template <ScriptContext context> int LoadFileAsync(fs::path file);
	template <ScriptContext context> void DeleteFileAsync(fs::path file);
	// Future proofed in that if we ever get multi-threaded SSDs this code will take advantage of them.
	std::mutex fileMutex;

  private:
	int m_iLastRequestHandle = 0;
};
