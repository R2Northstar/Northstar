#pragma once
#include "plugin_abi.h"

int getServerInfoChar(char* out_buf, size_t out_buf_len, ServerInfoType var);
int getServerInfoInt(int* out_ptr, ServerInfoType var);
int getServerInfoBool(bool* out_ptr, ServerInfoType var);

int getGameStateChar(char* out_buf, size_t out_buf_len, GameStateInfoType var);
int getGameStateInt(int* out_ptr, GameStateInfoType var);
int getGameStateBool(bool* out_ptr, GameStateInfoType var);

int getPlayerInfoChar(char* out_buf, size_t out_buf_len, PlayerInfoType var);
int getPlayerInfoInt(int* out_ptr, PlayerInfoType var);
int getPlayerInfoBool(bool* out_ptr, PlayerInfoType var);

void initGameState();
void* getPluginObject(PluginObject var);
