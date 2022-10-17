#include "pch.h"
#include "squirrel.h"
#include "rpakfilesystem.h"
#include "convar.h"
#include "dedicated.h"
#include "filesystem.h"
#include "vector.h"
#include "tier0.h"
#include "r2engine.h"
#include <iostream>
#include <sstream>
#include <map>
#include <fstream>
#include <filesystem>

const uint64_t USERDATA_TYPE_DATATABLE = 0xFFF7FFF700000004;
const uint64_t USERDATA_TYPE_DATATABLE_CUSTOM = 0xFFFCFFFC12345678;

enum class DatatableType : int
{
	BOOL = 0,
	INT,
	FLOAT,
	VECTOR,
	STRING,
	ASSET,
	UNK_STRING // unknown but deffo a string type
};

struct ColumnInfo
{
	char* name;
	DatatableType type;
	int offset;
};

struct Datatable
{
	int numColumns;
	int numRows;
	ColumnInfo* columnInfo;
	char* data; // actually data pointer
	int rowInfo;
};

ConVar* Cvar_ns_prefer_datatable_from_disk;

template <ScriptContext context> Datatable* (*SQ_GetDatatableInternal)(HSquirrelVM* sqvm);

struct CSVData
{
	std::string m_sAssetName;
	std::string m_sCSVString;
	char* m_pDataBuf;
	size_t m_nDataBufSize;

	std::vector<char*> columns;
	std::vector<std::vector<char*>> dataPointers;
};

std::unordered_map<std::string, CSVData> CSVCache;

Vector3 StringToVector(char* pString)
{
	Vector3 vRet;

	int length = 0;
	while (pString[length])
	{
		if ((pString[length] == '<') || (pString[length] == '>'))
			pString[length] = '\0';
		length++;
	}

	int startOfFloat = 1;
	int currentIndex = 1;

	while (pString[currentIndex] && (pString[currentIndex] != ','))
		currentIndex++;
	pString[currentIndex] = '\0';
	vRet.x = std::stof(&pString[startOfFloat]);
	startOfFloat = ++currentIndex;

	while (pString[currentIndex] && (pString[currentIndex] != ','))
		currentIndex++;
	pString[currentIndex] = '\0';
	vRet.y = std::stof(&pString[startOfFloat]);
	startOfFloat = ++currentIndex;

	while (pString[currentIndex] && (pString[currentIndex] != ','))
		currentIndex++;
	pString[currentIndex] = '\0';
	vRet.z = std::stof(&pString[startOfFloat]);
	startOfFloat = ++currentIndex;

	return vRet;
}

// var function GetDataTable( asset path )
template <ScriptContext context> SQRESULT SQ_GetDatatable(HSquirrelVM* sqvm)
{
	const char* pAssetName;
	g_pSquirrel<context>->getasset(sqvm, 2, &pAssetName);

	if (strncmp(pAssetName, "datatable/", 10))
	{
		g_pSquirrel<context>->raiseerror(sqvm, fmt::format("Asset \"{}\" doesn't start with \"datatable/\"", pAssetName).c_str());
		return SQRESULT_ERROR;
	}
	else if (!Cvar_ns_prefer_datatable_from_disk->GetBool() && g_pPakLoadManager->LoadFile(pAssetName))
		return g_pSquirrel<context>->m_funcOriginals["GetDataTable"](sqvm);
	// either we prefer disk datatables, or we're loading a datatable that wasn't found in rpak
	else
	{
		std::string sAssetPath(fmt::format("scripts/{}", pAssetName));

		// first, check the cache
		if (CSVCache.find(pAssetName) != CSVCache.end())
		{
			CSVData** pUserdata = g_pSquirrel<context>->createuserdata<CSVData*>(sqvm, sizeof(CSVData*));
			g_pSquirrel<context>->setuserdatatypeid(sqvm, -1, USERDATA_TYPE_DATATABLE_CUSTOM);
			*pUserdata = &CSVCache[pAssetName];

			return SQRESULT_NOTNULL;
		}

		// check files on disk
		// we don't use .rpak as the extension for on-disk datatables, so we need to replace .rpak with .csv in the filename we're reading
		fs::path diskAssetPath("scripts");
		if (fs::path(pAssetName).extension() == ".rpak")
			diskAssetPath /= fs::path(pAssetName).remove_filename() / (fs::path(pAssetName).stem().string() + ".csv");
		else
			diskAssetPath /= fs::path(pAssetName);

		std::string sDiskAssetPath(diskAssetPath.string());
		if ((*R2::g_pFilesystem)->m_vtable2->FileExists(&(*R2::g_pFilesystem)->m_vtable2, sDiskAssetPath.c_str(), "GAME"))
		{
			std::string sTableCSV = R2::ReadVPKFile(sDiskAssetPath.c_str());
			if (!sTableCSV.size())
			{
				g_pSquirrel<context>->raiseerror(sqvm, fmt::format("Datatable \"{}\" is empty", pAssetName).c_str());
				return SQRESULT_ERROR;
			}

			// somewhat shit, but ensure we end with a newline to make parsing easier
			if (sTableCSV[sTableCSV.length() - 1] != '\n')
				sTableCSV += '\n';

			CSVData csv;
			csv.m_sAssetName = pAssetName;
			csv.m_sCSVString = sTableCSV;
			csv.m_nDataBufSize = sTableCSV.size();
			csv.m_pDataBuf = new char[csv.m_nDataBufSize];
			memcpy(csv.m_pDataBuf, &sTableCSV[0], csv.m_nDataBufSize);

			// parse the csv
			// csvs are essentially comma and newline-deliniated sets of strings for parsing, only thing we need to worry about is quoted
			// entries when we parse an element of the csv, rather than allocating an entry for it, we just convert that element to a
			// null-terminated string i.e., store the ptr to the first char of it, then make the comma that delinates it a nullchar

			bool bHasColumns = false;
			bool bInQuotes = false;

			std::vector<char*> vCurrentRow;
			char* pElemStart = csv.m_pDataBuf;
			char* pElemEnd = nullptr;

			for (int i = 0; i < csv.m_nDataBufSize; i++)
			{
				if (csv.m_pDataBuf[i] == '\r' && csv.m_pDataBuf[i + 1] == '\n')
				{
					if (!pElemEnd)
						pElemEnd = csv.m_pDataBuf + i;

					continue; // next iteration can handle the \n
				}

				// newline, end of a row
				if (csv.m_pDataBuf[i] == '\n')
				{
					// shouldn't have newline in string
					if (bInQuotes)
					{
						g_pSquirrel<context>->raiseerror(sqvm, "Unexpected \\n in string");
						return SQRESULT_ERROR;
					}

					// push last entry to current row
					if (pElemEnd)
						*pElemEnd = '\0';
					else
						csv.m_pDataBuf[i] = '\0';

					vCurrentRow.push_back(pElemStart);

					// newline, push last line to csv data and go from there
					if (!bHasColumns)
					{
						bHasColumns = true;
						csv.columns = vCurrentRow;
					}
					else
						csv.dataPointers.push_back(vCurrentRow);

					vCurrentRow.clear();
					// put start of current element at char after newline
					pElemStart = csv.m_pDataBuf + i + 1;
					pElemEnd = nullptr;
				}
				// we're starting or ending a quoted string
				else if (csv.m_pDataBuf[i] == '"')
				{
					// start quoted string
					if (!bInQuotes)
					{
						// shouldn't have quoted strings in column names
						if (!bHasColumns)
						{
							g_pSquirrel<context>->raiseerror(sqvm, "Unexpected \" in column name");
							return SQRESULT_ERROR;
						}

						bInQuotes = true;
						// put start of current element at char after string begin
						pElemStart = csv.m_pDataBuf + i + 1;
					}
					// end quoted string
					else
					{
						pElemEnd = csv.m_pDataBuf + i;
						bInQuotes = false;
					}
				}
				// don't parse commas in quotes
				else if (bInQuotes)
				{
					continue;
				}
				// comma, push new entry to current row
				else if (csv.m_pDataBuf[i] == ',')
				{
					if (pElemEnd)
						*pElemEnd = '\0';
					else
						csv.m_pDataBuf[i] = '\0';

					vCurrentRow.push_back(pElemStart);
					// put start of next element at char after comma
					pElemStart = csv.m_pDataBuf + i + 1;
					pElemEnd = nullptr;
				}
			}

			// add to cache and return
			CSVData** pUserdata = g_pSquirrel<context>->createuserdata<CSVData*>(sqvm, sizeof(CSVData*));
			g_pSquirrel<context>->setuserdatatypeid(sqvm, -1, USERDATA_TYPE_DATATABLE_CUSTOM);
			CSVCache[pAssetName] = csv;
			*pUserdata = &CSVCache[pAssetName];

			return SQRESULT_NOTNULL;
		}
		// the file doesn't exist on disk, check rpak if we haven't already
		else if (Cvar_ns_prefer_datatable_from_disk->GetBool() && g_pPakLoadManager->LoadFile(pAssetName))
			return g_pSquirrel<context>->m_funcOriginals["GetDataTable"](sqvm);
		// the file doesn't exist at all, error
		else
		{
			g_pSquirrel<context>->raiseerror(sqvm, fmt::format("Datatable {} not found", pAssetName).c_str());
			return SQRESULT_ERROR;
		}
	}
}

// int function GetDataTableRowCount( var datatable, string columnName )
template <ScriptContext context> SQRESULT SQ_GetDataTableColumnByName(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableColumnByName"](sqvm);

	CSVData* csv = *pData;
	const char* pColumnName = g_pSquirrel<context>->getstring(sqvm, 2);

	for (int i = 0; i < csv->columns.size(); i++)
	{
		if (!strcmp(csv->columns[i], pColumnName))
		{
			g_pSquirrel<context>->pushinteger(sqvm, i);
			return SQRESULT_NOTNULL;
		}
	}

	// column not found
	g_pSquirrel<context>->pushinteger(sqvm, -1);
	return SQRESULT_NOTNULL;
}

// int function GetDataTableRowCount( var datatable )
template <ScriptContext context> SQRESULT SQ_GetDataTableRowCount(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDatatableRowCount"](sqvm);

	CSVData* csv = *pData;
	g_pSquirrel<context>->pushinteger(sqvm, csv->dataPointers.size());
	return SQRESULT_NOTNULL;
}

// string function GetDataTableString( var datatable, int row, int col )
template <ScriptContext context> SQRESULT SQ_GetDataTableString(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableString"](sqvm);

	CSVData* csv = *pData;
	const int nRow = g_pSquirrel<context>->getinteger(sqvm, 2);
	const int nCol = g_pSquirrel<context>->getinteger(sqvm, 3);
	if (nRow >= csv->dataPointers.size() || nCol >= csv->dataPointers[nRow].size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"row {} and col {} are outside of range row {} and col {}", nRow, nCol, csv->dataPointers.size(), csv->columns.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushstring(sqvm, csv->dataPointers[nRow][nCol], -1);
	return SQRESULT_NOTNULL;
}

// asset function GetDataTableAsset( var datatable, int row, int col )
template <ScriptContext context> SQRESULT SQ_GetDataTableAsset(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableAsset"](sqvm);

	CSVData* csv = *pData;
	const int nRow = g_pSquirrel<context>->getinteger(sqvm, 2);
	const int nCol = g_pSquirrel<context>->getinteger(sqvm, 3);
	if (nRow >= csv->dataPointers.size() || nCol >= csv->dataPointers[nRow].size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"row {} and col {} are outside of range row {} and col {}", nRow, nCol, csv->dataPointers.size(), csv->columns.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushasset(sqvm, csv->dataPointers[nRow][nCol], -1);
	return SQRESULT_NOTNULL;
}

// int function GetDataTableInt( var datatable, int row, int col )
template <ScriptContext context> SQRESULT SQ_GetDataTableInt(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableInt"](sqvm);

	CSVData* csv = *pData;
	const int nRow = g_pSquirrel<context>->getinteger(sqvm, 2);
	const int nCol = g_pSquirrel<context>->getinteger(sqvm, 3);
	if (nRow >= csv->dataPointers.size() || nCol >= csv->dataPointers[nRow].size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"row {} and col {} are outside of range row {} and col {}", nRow, nCol, csv->dataPointers.size(), csv->columns.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushinteger(sqvm, std::stoi(csv->dataPointers[nRow][nCol]));
	return SQRESULT_NOTNULL;
}

// float function GetDataTableFloat( var datatable, int row, int col )
template <ScriptContext context> SQRESULT SQ_GetDataTableFloat(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableFloat"](sqvm);

	CSVData* csv = *pData;
	const int nRow = g_pSquirrel<context>->getinteger(sqvm, 2);
	const int nCol = g_pSquirrel<context>->getinteger(sqvm, 3);
	if (nRow >= csv->dataPointers.size() || nCol >= csv->dataPointers[nRow].size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"row {} and col {} are outside of range row {} and col {}", nRow, nCol, csv->dataPointers.size(), csv->columns.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushfloat(sqvm, std::stof(csv->dataPointers[nRow][nCol]));
	return SQRESULT_NOTNULL;
}

// bool function GetDataTableBool( var datatable, int row, int col )
template <ScriptContext context> SQRESULT SQ_GetDataTableBool(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableBool"](sqvm);

	CSVData* csv = *pData;
	const int nRow = g_pSquirrel<context>->getinteger(sqvm, 2);
	const int nCol = g_pSquirrel<context>->getinteger(sqvm, 3);
	if (nRow >= csv->dataPointers.size() || nCol >= csv->dataPointers[nRow].size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"row {} and col {} are outside of range row {} and col {}", nRow, nCol, csv->dataPointers.size(), csv->columns.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushbool(sqvm, std::stoi(csv->dataPointers[nRow][nCol]));
	return SQRESULT_NOTNULL;
}

// vector function GetDataTableVector( var datatable, int row, int col )
template <ScriptContext context> SQRESULT SQ_GetDataTableVector(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableVector"](sqvm);

	CSVData* csv = *pData;
	const int nRow = g_pSquirrel<context>->getinteger(sqvm, 2);
	const int nCol = g_pSquirrel<context>->getinteger(sqvm, 3);
	if (nRow >= csv->dataPointers.size() || nCol >= csv->dataPointers[nRow].size())
	{
		g_pSquirrel<context>->raiseerror(
			sqvm,
			fmt::format(
				"row {} and col {} are outside of range row {} and col {}", nRow, nCol, csv->dataPointers.size(), csv->columns.size())
				.c_str());
		return SQRESULT_ERROR;
	}

	g_pSquirrel<context>->pushvector(sqvm, StringToVector(csv->dataPointers[nRow][nCol]));
	return SQRESULT_NOTNULL;
}

// int function GetDataTableRowMatchingStringValue( var datatable, int col, string value )
template <ScriptContext context> SQRESULT SQ_GetDataTableRowMatchingStringValue(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableRowMatchingStringValue"](sqvm);

	CSVData* csv = *pData;
	int nCol = g_pSquirrel<context>->getinteger(sqvm, 2);
	const char* pStringVal = g_pSquirrel<context>->getstring(sqvm, 3);
	for (int i = 0; i < csv->dataPointers.size(); i++)
	{
		if (!strcmp(csv->dataPointers[i][nCol], pStringVal))
		{
			g_pSquirrel<context>->pushinteger(sqvm, i);
			return SQRESULT_NOTNULL;
		}
	}

	g_pSquirrel<context>->pushinteger(sqvm, -1);
	return SQRESULT_NOTNULL;
}

// int function GetDataTableRowMatchingAssetValue( var datatable, int col, asset value )
template <ScriptContext context> SQRESULT SQ_GetDataTableRowMatchingAssetValue(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableRowMatchingAssetValue"](sqvm);

	CSVData* csv = *pData;
	int nCol = g_pSquirrel<context>->getinteger(sqvm, 2);
	const char* pStringVal;
	g_pSquirrel<context>->getasset(sqvm, 3, &pStringVal);
	for (int i = 0; i < csv->dataPointers.size(); i++)
	{
		if (!strcmp(csv->dataPointers[i][nCol], pStringVal))
		{
			g_pSquirrel<context>->pushinteger(sqvm, i);
			return SQRESULT_NOTNULL;
		}
	}

	g_pSquirrel<context>->pushinteger(sqvm, -1);
	return SQRESULT_NOTNULL;
}

// int function GetDataTableRowMatchingFloatValue( var datatable, int col, float value )
template <ScriptContext context> SQRESULT SQ_GetDataTableRowMatchingFloatValue(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableRowMatchingFloatValue"](sqvm);

	CSVData* csv = *pData;
	int nCol = g_pSquirrel<context>->getinteger(sqvm, 2);
	const float flFloatVal = g_pSquirrel<context>->getfloat(sqvm, 3);
	for (int i = 0; i < csv->dataPointers.size(); i++)
	{
		if (flFloatVal == std::stof(csv->dataPointers[i][nCol]))
		{
			g_pSquirrel<context>->pushinteger(sqvm, i);
			return SQRESULT_NOTNULL;
		}
	}

	g_pSquirrel<context>->pushinteger(sqvm, -1);
	return SQRESULT_NOTNULL;
}

// int function GetDataTableRowMatchingIntValue( var datatable, int col, int value )
template <ScriptContext context> SQRESULT SQ_GetDataTableRowMatchingIntValue(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableRowMatchingIntValue"](sqvm);

	CSVData* csv = *pData;
	int nCol = g_pSquirrel<context>->getinteger(sqvm, 2);
	const int nIntVal = g_pSquirrel<context>->getinteger(sqvm, 3);
	for (int i = 0; i < csv->dataPointers.size(); i++)
	{
		if (nIntVal == std::stoi(csv->dataPointers[i][nCol]))
		{
			g_pSquirrel<context>->pushinteger(sqvm, i);
			return SQRESULT_NOTNULL;
		}
	}

	g_pSquirrel<context>->pushinteger(sqvm, -1);
	return SQRESULT_NOTNULL;
}

// int function GetDataTableRowMatchingVectorValue( var datatable, int col, vector value )
template <ScriptContext context> SQRESULT SQ_GetDataTableRowMatchingVectorValue(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableRowMatchingVectorValue"](sqvm);

	CSVData* csv = *pData;
	int nCol = g_pSquirrel<context>->getinteger(sqvm, 2);
	const Vector3 vVectorVal = g_pSquirrel<context>->getvector(sqvm, 3);

	for (int i = 0; i < csv->dataPointers.size(); i++)
	{
		if (vVectorVal == StringToVector(csv->dataPointers[i][nCol]))
		{
			g_pSquirrel<context>->pushinteger(sqvm, i);
			return SQRESULT_NOTNULL;
		}
	}

	g_pSquirrel<context>->pushinteger(sqvm, -1);
	return SQRESULT_NOTNULL;
}

// int function GetDataTableRowGreaterThanOrEqualToIntValue( var datatable, int col, int value )
template <ScriptContext context> SQRESULT SQ_GetDataTableRowGreaterThanOrEqualToIntValue(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableRowGreaterThanOrEqualToIntValue"](sqvm);

	CSVData* csv = *pData;
	int nCol = g_pSquirrel<context>->getinteger(sqvm, 2);
	const int nIntVal = g_pSquirrel<context>->getinteger(sqvm, 3);
	for (int i = 0; i < csv->dataPointers.size(); i++)
	{
		if (nIntVal >= std::stoi(csv->dataPointers[i][nCol]))
		{
			spdlog::info("datatable not loaded");
			g_pSquirrel<context>->pushinteger(sqvm, 1);
			return SQRESULT_NOTNULL;
		}
	}

	g_pSquirrel<context>->pushinteger(sqvm, -1);
	return SQRESULT_NOTNULL;
}

// int function GetDataTableRowLessThanOrEqualToIntValue( var datatable, int col, int value )
template <ScriptContext context> SQRESULT SQ_GetDataTableRowLessThanOrEqualToIntValue(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableRowLessThanOrEqualToIntValue"](sqvm);

	CSVData* csv = *pData;
	int nCol = g_pSquirrel<context>->getinteger(sqvm, 2);
	const int nIntVal = g_pSquirrel<context>->getinteger(sqvm, 3);
	for (int i = 0; i < csv->dataPointers.size(); i++)
	{
		if (nIntVal <= std::stoi(csv->dataPointers[i][nCol]))
		{
			g_pSquirrel<context>->pushinteger(sqvm, i);
			return SQRESULT_NOTNULL;
		}
	}

	g_pSquirrel<context>->pushinteger(sqvm, -1);
	return SQRESULT_NOTNULL;
}

// int function GetDataTableRowGreaterThanOrEqualToFloatValue( var datatable, int col, float value )
template <ScriptContext context> SQRESULT SQ_GetDataTableRowGreaterThanOrEqualToFloatValue(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableRowGreaterThanOrEqualToFloatValue"](sqvm);

	CSVData* csv = *pData;
	int nCol = g_pSquirrel<context>->getinteger(sqvm, 2);
	const float flFloatVal = g_pSquirrel<context>->getfloat(sqvm, 3);
	for (int i = 0; i < csv->dataPointers.size(); i++)
	{
		if (flFloatVal >= std::stof(csv->dataPointers[i][nCol]))
		{
			g_pSquirrel<context>->pushinteger(sqvm, i);
			return SQRESULT_NOTNULL;
		}
	}

	g_pSquirrel<context>->pushinteger(sqvm, -1);
	return SQRESULT_NOTNULL;
}

// int function GetDataTableRowLessThanOrEqualToFloatValue( var datatable, int col, float value )
template <ScriptContext context> SQRESULT SQ_GetDataTableRowLessThanOrEqualToFloatValue(HSquirrelVM* sqvm)
{
	CSVData** pData;
	uint64_t typeId;
	g_pSquirrel<context>->getuserdata(sqvm, 2, &pData, &typeId);

	if (typeId != USERDATA_TYPE_DATATABLE_CUSTOM)
		return g_pSquirrel<context>->m_funcOriginals["GetDataTableRowLessThanOrEqualToFloatValue"](sqvm);

	CSVData* csv = *pData;
	int nCol = g_pSquirrel<context>->getinteger(sqvm, 2);
	const float flFloatVal = g_pSquirrel<context>->getfloat(sqvm, 3);
	for (int i = 0; i < csv->dataPointers.size(); i++)
	{
		if (flFloatVal <= std::stof(csv->dataPointers[i][nCol]))
		{
			g_pSquirrel<context>->pushinteger(sqvm, i);
			return SQRESULT_NOTNULL;
		}
	}

	g_pSquirrel<context>->pushinteger(sqvm, -1);
	return SQRESULT_NOTNULL;
}

std::string DataTableToString(Datatable* datatable)
{
	std::string sCSVString;

	// write columns
	bool bShouldComma = false;
	for (int i = 0; i < datatable->numColumns; i++)
	{
		if (bShouldComma)
			sCSVString += ',';
		else
			bShouldComma = true;

		sCSVString += datatable->columnInfo[i].name;
	}

	// write rows
	for (int row = 0; row < datatable->numRows; row++)
	{
		sCSVString += '\n';

		bool bShouldComma = false;
		for (int col = 0; col < datatable->numColumns; col++)
		{
			if (bShouldComma)
				sCSVString += ',';
			else
				bShouldComma = true;

			// output typed data
			ColumnInfo column = datatable->columnInfo[col];
			const void* pUntypedVal = datatable->data + column.offset + row * datatable->rowInfo;
			switch (column.type)
			{
			case DatatableType::BOOL:
			{
				sCSVString += *(bool*)pUntypedVal ? '1' : '0';
				break;
			}

			case DatatableType::INT:
			{
				sCSVString += std::to_string(*(int*)pUntypedVal);
				break;
			}

			case DatatableType::FLOAT:
			{
				sCSVString += std::to_string(*(float*)pUntypedVal);
				break;
			}

			case DatatableType::VECTOR:
			{
				Vector3 pVector((float*)pUntypedVal);
				sCSVString += fmt::format("<{},{},{}>", pVector.x, pVector.y, pVector.z);
				break;
			}

			case DatatableType::STRING:
			case DatatableType::ASSET:
			case DatatableType::UNK_STRING:
			{
				sCSVString += fmt::format("\"{}\"", *(char**)pUntypedVal);
				break;
			}
			}
		}
	}

	return sCSVString;
}

void DumpDatatable(const char* pDatatablePath)
{
	Datatable* pDatatable = (Datatable*)g_pPakLoadManager->LoadFile(pDatatablePath);
	if (!pDatatable)
	{
		spdlog::error("couldn't load datatable {} (rpak containing it may not be loaded?)", pDatatablePath);
		return;
	}

	std::string sOutputPath(fmt::format("{}/scripts/datatable/{}.csv", R2::g_pModName, fs::path(pDatatablePath).stem().string()));
	std::string sDatatableContents(DataTableToString(pDatatable));

	fs::create_directories(fs::path(sOutputPath).remove_filename());
	std::ofstream outputStream(sOutputPath);
	outputStream.write(sDatatableContents.c_str(), sDatatableContents.size());
	outputStream.close();

	spdlog::info("dumped datatable {} {} to {}", pDatatablePath, (void*)pDatatable, sOutputPath);
}

void ConCommand_dump_datatable(const CCommand& args)
{
	if (args.ArgC() < 2)
	{
		spdlog::info("usage: dump_datatable datatable/tablename.rpak");
		return;
	}

	DumpDatatable(args.Arg(1));
}

void ConCommand_dump_datatables(const CCommand& args)
{
	// likely not a comprehensive list, might be missing a couple?
	static const std::vector<const char*> VANILLA_DATATABLE_PATHS = {
		"datatable/burn_meter_rewards.rpak",
		"datatable/burn_meter_store.rpak",
		"datatable/calling_cards.rpak",
		"datatable/callsign_icons.rpak",
		"datatable/camo_skins.rpak",
		"datatable/default_pilot_loadouts.rpak",
		"datatable/default_titan_loadouts.rpak",
		"datatable/faction_leaders.rpak",
		"datatable/fd_awards.rpak",
		"datatable/features_mp.rpak",
		"datatable/non_loadout_weapons.rpak",
		"datatable/pilot_abilities.rpak",
		"datatable/pilot_executions.rpak",
		"datatable/pilot_passives.rpak",
		"datatable/pilot_properties.rpak",
		"datatable/pilot_weapons.rpak",
		"datatable/pilot_weapon_features.rpak",
		"datatable/pilot_weapon_mods.rpak",
		"datatable/pilot_weapon_mods_common.rpak",
		"datatable/playlist_items.rpak",
		"datatable/titans_mp.rpak",
		"datatable/titan_abilities.rpak",
		"datatable/titan_executions.rpak",
		"datatable/titan_fd_upgrades.rpak",
		"datatable/titan_nose_art.rpak",
		"datatable/titan_passives.rpak",
		"datatable/titan_primary_mods.rpak",
		"datatable/titan_primary_mods_common.rpak",
		"datatable/titan_primary_weapons.rpak",
		"datatable/titan_properties.rpak",
		"datatable/titan_skins.rpak",
		"datatable/titan_voices.rpak",
		"datatable/unlocks_faction_level.rpak",
		"datatable/unlocks_fd_titan_level.rpak",
		"datatable/unlocks_player_level.rpak",
		"datatable/unlocks_random.rpak",
		"datatable/unlocks_titan_level.rpak",
		"datatable/unlocks_weapon_level_pilot.rpak",
		"datatable/weapon_skins.rpak",
		"datatable/xp_per_faction_level.rpak",
		"datatable/xp_per_fd_titan_level.rpak",
		"datatable/xp_per_player_level.rpak",
		"datatable/xp_per_titan_level.rpak",
		"datatable/xp_per_weapon_level.rpak",
		"datatable/faction_leaders_dropship_anims.rpak",
		"datatable/score_events.rpak",
		"datatable/startpoints.rpak",
		"datatable/sp_levels.rpak",
		"datatable/community_entries.rpak",
		"datatable/spotlight_images.rpak",
		"datatable/death_hints_mp.rpak",
		"datatable/flightpath_assets.rpak",
		"datatable/earn_meter_mp.rpak",
		"datatable/battle_chatter_voices.rpak",
		"datatable/battle_chatter.rpak",
		"datatable/titan_os_conversations.rpak",
		"datatable/faction_dialogue.rpak",
		"datatable/grunt_chatter_mp.rpak",
		"datatable/spectre_chatter_mp.rpak",
		"datatable/pain_death_sounds.rpak",
		"datatable/caller_ids_mp.rpak"};

	for (const char* datatable : VANILLA_DATATABLE_PATHS)
		DumpDatatable(datatable);
}

template <ScriptContext context> void RegisterDataTableFunctions()
{
	g_pSquirrel<context>->AddFuncOverride("GetDataTable", SQ_GetDatatable<context>);
	g_pSquirrel<context>->AddFuncOverride("GetDataTableColumnByName", SQ_GetDataTableColumnByName<context>);
	g_pSquirrel<context>->AddFuncOverride("GetDatatableRowCount", SQ_GetDataTableRowCount<context>);
	g_pSquirrel<context>->AddFuncOverride("GetDataTableString", SQ_GetDataTableString<context>);
	g_pSquirrel<context>->AddFuncOverride("GetDataTableInt", SQ_GetDataTableInt<context>);
	g_pSquirrel<context>->AddFuncOverride("GetDataTableFloat", SQ_GetDataTableFloat<context>);
	g_pSquirrel<context>->AddFuncOverride("GetDataTableBool", SQ_GetDataTableBool<context>);
	g_pSquirrel<context>->AddFuncOverride("GetDataTableAsset", SQ_GetDataTableAsset<context>);
	g_pSquirrel<context>->AddFuncOverride("GetDataTableVector", SQ_GetDataTableVector<context>);
	g_pSquirrel<context>->AddFuncOverride("GetDataTableRowMatchingStringValue", SQ_GetDataTableRowMatchingStringValue<context>);
	g_pSquirrel<context>->AddFuncOverride("GetDataTableRowMatchingAssetValue", SQ_GetDataTableRowMatchingAssetValue<context>);
	g_pSquirrel<context>->AddFuncOverride("GetDataTableRowMatchingFloatValue", SQ_GetDataTableRowMatchingFloatValue<context>);
	g_pSquirrel<context>->AddFuncOverride("GetDataTableRowMatchingIntValue", SQ_GetDataTableRowMatchingIntValue<context>);
	g_pSquirrel<context>->AddFuncOverride("GetDataTableRowMatchingVectorValue", SQ_GetDataTableRowMatchingVectorValue<context>);
	g_pSquirrel<context>->AddFuncOverride(
		"GetDataTableRowLessThanOrEqualToFloatValue", SQ_GetDataTableRowLessThanOrEqualToFloatValue<context>);
	g_pSquirrel<context>->AddFuncOverride(
		"GetDataTableRowGreaterThanOrEqualToFloatValue", SQ_GetDataTableRowGreaterThanOrEqualToFloatValue<context>);
	g_pSquirrel<context>->AddFuncOverride("GetDataTableRowLessThanOrEqualToIntValue", SQ_GetDataTableRowLessThanOrEqualToIntValue<context>);
	g_pSquirrel<context>->AddFuncOverride(
		"GetDataTableRowGreaterThanOrEqualToFloatValue", SQ_GetDataTableRowGreaterThanOrEqualToIntValue<context>);
}

ON_DLL_LOAD_RELIESON("server.dll", ServerScriptDatatables, ServerSquirrel, (CModule module))
{
	RegisterDataTableFunctions<ScriptContext::SERVER>();

	SQ_GetDatatableInternal<ScriptContext::SERVER> = module.Offset(0x1250f0).As<Datatable* (*)(HSquirrelVM*)>();
}

ON_DLL_LOAD_RELIESON("client.dll", ClientScriptDatatables, ClientSquirrel, (CModule module))
{
	RegisterDataTableFunctions<ScriptContext::CLIENT>();
	RegisterDataTableFunctions<ScriptContext::UI>();

	SQ_GetDatatableInternal<ScriptContext::CLIENT> = module.Offset(0x1C9070).As<Datatable* (*)(HSquirrelVM*)>();
	SQ_GetDatatableInternal<ScriptContext::UI> = SQ_GetDatatableInternal<ScriptContext::CLIENT>;
}

ON_DLL_LOAD_RELIESON("engine.dll", SharedScriptDataTables, ConVar, (CModule module))
{
	Cvar_ns_prefer_datatable_from_disk = new ConVar(
		"ns_prefer_datatable_from_disk",
		IsDedicatedServer() && Tier0::CommandLine()->CheckParm("-nopakdedi") ? "1" : "0",
		FCVAR_NONE,
		"whether to prefer loading datatables from disk, rather than rpak");

	RegisterConCommand("dump_datatables", ConCommand_dump_datatables, "dumps all datatables from a hardcoded list", FCVAR_NONE);
	RegisterConCommand("dump_datatable", ConCommand_dump_datatable, "dump a datatable", FCVAR_NONE);
}
