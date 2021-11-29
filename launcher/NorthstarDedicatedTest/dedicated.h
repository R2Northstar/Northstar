#pragma once

bool IsDedicated();
bool DisableDedicatedWindowCreation();

void InitialiseDedicated(HMODULE moduleAddress);
void InitialiseDedicatedOrigin(HMODULE baseAddress);
void InitialiseDedicatedServerGameDLL(HMODULE baseAddress);