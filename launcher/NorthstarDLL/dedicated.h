#pragma once

bool IsDedicatedServer();

void InitialiseDedicated(HMODULE moduleAddress);
void InitialiseDedicatedOrigin(HMODULE baseAddress);
void InitialiseDedicatedServerGameDLL(HMODULE baseAddress);
