#include "config/profile.h"
#include "dedicated/dedicated.h"
#include <string>

std::string GetNorthstarPrefix()
{
	return NORTHSTAR_FOLDER_PREFIX;
}

void InitialiseNorthstarPrefix()
{
	char* clachar = strstr(GetCommandLineA(), "-profile=");
	if (clachar)
	{
		std::string cla = std::string(clachar);
		if (strncmp(cla.substr(9, 1).c_str(), "\"", 1))
		{
			int space = cla.find(" ");
			std::string dirname = cla.substr(9, space - 9);
			NORTHSTAR_FOLDER_PREFIX = dirname;
		}
		else
		{
			std::string quote = "\"";
			int quote1 = cla.find(quote);
			int quote2 = (cla.substr(quote1 + 1)).find(quote);
			std::string dirname = cla.substr(quote1 + 1, quote2);
			NORTHSTAR_FOLDER_PREFIX = dirname;
		}
	}
	else
	{
		NORTHSTAR_FOLDER_PREFIX = "R2Northstar";
	}

	// set the console title to show the current profile
	// dont do this on dedi as title contains useful information on dedi and setting title breaks it as well
	if (!IsDedicatedServer())
		SetConsoleTitleA((std::string("NorthstarLauncher | ") + NORTHSTAR_FOLDER_PREFIX).c_str());
}
