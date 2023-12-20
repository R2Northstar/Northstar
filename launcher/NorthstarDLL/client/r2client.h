#pragma once

extern char* g_pLocalPlayerUserID;
extern char* g_pLocalPlayerOriginToken;

typedef void* (*GetBaseLocalClientType)();
extern GetBaseLocalClientType GetBaseLocalClient;
