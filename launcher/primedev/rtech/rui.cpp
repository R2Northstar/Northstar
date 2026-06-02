#include "rui.h"

struct gamestate_info_ffa_struct
{
	BYTE gap0[68];
	float endTime;
	const char* statusText;
	float leftTeamScore;
	float rightTeamScore;
	DWORD maxTeamScore;
	const char* factionImage;
	const char* friendlyPlayerCardImage;
	const char* enemyPlayerCardImage;
	BYTE gap78[64];
	DWORD whiteAssetHandle;
	DWORD playerCardImageAssetHandle;
	// struct needs to be 8 byte aligned for these
	uint64_t owordC0[2];
	uint64_t owordD0[2];
	uint64_t topColor[2];
	uint64_t bottomColor[2];
	const char* formattedTimeString;
	const char* gameModeName;
	DWORD otherPlayerCardAssetHandle;
	DWORD leftFillAsset;
	DWORD rightFillAsset;
	float leftTeamScoreDiff;
	float otherTeamScoreDiff;
	DWORD factionImageHandle;
	const char* scoreString;
	const char* rightTeamScoreString;
};

using gamestate_info_ffa_t = void(__fastcall*)(RuiFunctions_t*, RuiGlobals*, RuiInstance*, gamestate_info_ffa_struct*);
gamestate_info_ffa_t o_gamestate_info_ffa = nullptr;

void h_gamestate_info_ffa(RuiFunctions_t* funcs, RuiGlobals* globals, RuiInstance* inst, gamestate_info_ffa_struct* data)
{
	static __m128 xmmword_D3C20 = {25.866, 25.866f, 40.000f, 40.000f};
	static __m128 xmmword_D3C40 = {128.000f, 128.000f, 40.000f, 40.f};
	static __m128 xmmword_D3C50 = {200.000f, 200.000f, 40.000f, 40.000f};
	static __m128 xmmword_D4A00 = {1920.000f, 1920.000f, 1080.000f, 1080.000f};
	static __m128 xmmword_D40E0 = {2.000f, 2.000f, 84.000f, 84.000f};
	static __m128 xmmword_D3CE0 = {48.000f, 48.000f, 48.000f, 48.000f};

	static __m128 enemyColor = {1.000f, 0.188f, 0.014f, 1.f};
	static __m128 friendlyColor = {0.095f, 0.309f, 0.708f, 1.f};

	float endTime = data->endTime;
	float timeLeft = endTime - globals->currentTime;
	char* buffer = (char*)alloca(2048);
	strcpy_s(buffer, 2048, data->statusText);
	if (strcmp(buffer, "") == 0)
	{
		strcpy_s(buffer, 2048, "#PL_ffa");
	}

	if (timeLeft < 0.0f || endTime == -1.0e30f)
	{
		data->formattedTimeString = "--:--";
	}
	else if (timeLeft > 30.0f)
	{
		data->formattedTimeString = funcs->printf(inst, "%i:%02i", (unsigned int)((int)timeLeft / 60), (unsigned int)((int)timeLeft % 60));
	}
	else
	{
		data->formattedTimeString = funcs->printf(inst, "%05.2f", timeLeft);
	}

	data->rightFillAsset = funcs->LoadAsset(inst, "rui/hud/gamestate/score_fill_right");
	assetHandle v9 = funcs->LoadAsset(inst, "rui/hud/gamestate/score_fill_right");
	bool teamScoreDiff = data->leftTeamScore < data->rightTeamScore;
	data->leftFillAsset = v9;

	__m128 topColor, bottomColor;
	const char* scoreString;
	const char* v23;
	float otherScore;

	if (teamScoreDiff)
	{
		assetHandle enemyPlayerCardImage_1 = funcs->LoadAsset(inst, data->enemyPlayerCardImage);
		const char* friendlyPlayerCardImage = data->friendlyPlayerCardImage;
		data->playerCardImageAssetHandle = enemyPlayerCardImage_1;
		assetHandle v26 = funcs->LoadAsset(inst, friendlyPlayerCardImage);
		data->otherPlayerCardAssetHandle = v26;
		float v28 = static_cast<float>(data->maxTeamScore);
		if (v28 == 0.0f)
		{
			return (funcs->SetErrorWithReason)(inst, "content\\r2\\ui\\hud\\gamemode_ffa.rui (83,46): divide by zero.\n");
		}

		float rightTeamScore = data->rightTeamScore;
		data->leftTeamScoreDiff = rightTeamScore / v28;
		topColor = enemyColor;
		bottomColor = friendlyColor;
		float v30 = data->leftTeamScore / v28;
		*(__m128*)data->topColor = topColor;
		*(__m128*)data->bottomColor = bottomColor;
		data->otherTeamScoreDiff = v30;
		scoreString = funcs->printf(inst, "%.8g", rightTeamScore);
		otherScore = data->leftTeamScore;
		v23 = "%.8g";
	}
	else
	{
		assetHandle v11 = funcs->LoadAsset(inst, data->friendlyPlayerCardImage);
		const char* enemyPlayerCardImage = data->enemyPlayerCardImage;
		data->playerCardImageAssetHandle = v11;
		assetHandle enemyPlayerCardImageAssetHandle_2 = funcs->LoadAsset(inst, enemyPlayerCardImage);
		data->otherPlayerCardAssetHandle = enemyPlayerCardImageAssetHandle_2;
		float maxTeamScore_1 = static_cast<float>(data->maxTeamScore);
		if (maxTeamScore_1 == 0.0f)
		{
			return (funcs->SetErrorWithReason)(inst, "content\\r2\\ui\\hud\\gamemode_ffa.rui (83,46): divide by zero.\n");
		}

		float leftTeamScore_1 = data->leftTeamScore;
		data->leftTeamScoreDiff = leftTeamScore_1 / maxTeamScore_1;
		topColor = friendlyColor;
		bottomColor = enemyColor;
		float v20 = data->rightTeamScore / maxTeamScore_1;
		*(__m128*)data->topColor = topColor;
		*(__m128*)data->bottomColor = bottomColor;
		data->otherTeamScoreDiff = v20;
		scoreString = funcs->printf(inst, "%.8g", leftTeamScore_1);
		otherScore = data->rightTeamScore;
		v23 = "%.8g";
	}

	data->scoreString = scoreString;
	const char* v31 = funcs->printf(inst, v23, otherScore);
	*(__m128*)data->owordD0 = bottomColor;
	*(__m128*)data->owordC0 = topColor;
	data->rightTeamScoreString = v31;
	data->whiteAssetHandle = funcs->LoadAsset(inst, "white");
	const char* factionImage = data->factionImage;
	data->gameModeName = funcs->localize(inst, buffer);
	data->factionImageHandle = funcs->LoadAsset(inst, factionImage);

	__m128* transformSizes = funcs->GetTransformSize(inst);
	transformSizes[3] = (__m128)xmmword_D3C50;
	funcs->executeTransform(inst, 1);
	transformSizes[4] = (__m128)xmmword_D3C50;
	funcs->executeTransform(inst, 2);
	transformSizes[5] = (__m128)xmmword_D4A00;
	transformSizes[6] = (__m128)xmmword_D40E0;

	__m128 v35;
	v35 = _mm_set_ps(40.0f, 40.0f, 0.0f, 0.0f);
	transformSizes[7] = (__m128)xmmword_D4A00;
	transformSizes[9] = (__m128)xmmword_D3C20;
	transformSizes[8] = (__m128)xmmword_D3C40;
	transformSizes[10] = (__m128)xmmword_D3C20;

	v35 = (funcs->unknown_5)(inst, 3LL, 4LL);
	transformSizes[11] = v35;
	v35 = (funcs->unknown_5)(inst, 4LL, 5LL);
	transformSizes[12] = v35;
	transformSizes[13] = (funcs->GetTextSize)(inst, 42LL);
	transformSizes[14] = (funcs->GetTextSize)(inst, 60LL);
	transformSizes[15] = (funcs->GetTextSize)(inst, 78LL);
	transformSizes[16] = (funcs->GetTextSize)(inst, 348LL);
	transformSizes[17] = (funcs->GetTextSize)(inst, 366LL);
	transformSizes[18] = xmmword_D3CE0;

	return (funcs->executeTransform)(inst, 0x9ELL);
}

ON_DLL_LOAD("ui(11).dll", Rui, (CModule module))
{
	o_gamestate_info_ffa = module.Offset(0x3E8E0).RCast<gamestate_info_ffa_t>();
	HookAttach(&(PVOID&)o_gamestate_info_ffa, (PVOID)h_gamestate_info_ffa);
}
