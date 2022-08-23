#pragma once

bool IsDedicated();

void InitialiseDedicated(HMODULE moduleAddress);
void InitialiseDedicatedOrigin(HMODULE baseAddress);
void InitialiseDedicatedServerGameDLL(HMODULE baseAddress);