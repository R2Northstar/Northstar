#include "pch.h"
#include "logCompression.h"
#include <fstream>
#include <string>
#include <iostream>
#include <filesystem>
#include "configurables.h"
#include "zlib/gzip/compress.hpp"
#include "zlib/gzip/config.hpp"
#include <zlib.h>

#define CHUNK 16384

namespace fs = std::filesystem;
using namespace std;

bool compressFile(const fs::path path)
{
	// read log file
	string filename(path.string());
	cout << "Compressing : '" + filename + "'" << endl;
	ifstream input(filename, ios_base::binary);
	if (!input.is_open())
	{
		cerr << "Could not open : '" + filename + "'" << endl;
		return false;
	}
	string log_data((istreambuf_iterator<char>(input.rdbuf())), istreambuf_iterator<char>());
	input.close();
	// compress log file
	string compressed_data = gzip::compress(log_data.data(), log_data.size());
	// write log file gzip
	ofstream output(filename + ".gz", ios::out | ios::binary);
	if (!output)
	{
		cerr << "Could not write : '" + filename + "'" << endl;
		return false;
	}
	output.write(compressed_data.c_str(), compressed_data.size());
	output.close();
	// delete log file
	remove(path);
	if (std::ifstream(path))
	{
		cerr << "Error deleting : '%s'" + filename + "'" << endl;
		return false;
	}
	return true;
}

void CompressLogFiles()
{
	string path = GetNorthstarPrefix() + "/logs";
	for (const auto& entry : fs::directory_iterator(path))
	{
		fs::path link = entry.path();
		string extension = link.extension().string();
		if (extension == ".txt" || extension == ".dmp")
		{
			compressFile(link);
		}
	}
}