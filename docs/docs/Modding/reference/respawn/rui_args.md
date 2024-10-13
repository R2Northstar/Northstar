# RUI Arguments Dump

*The following list has been taken from the Northstar Discord where it was originally uploaded by Spoon*

```
struct ruiDataStruct_ability_hud
{
  BYTE gap_0[32];
  char* hintText;
  float hintTime;
  int isHighlighted;
  int isTitan;
  int isVisible;
  int isReverseCharge;
  int isReverseReady;
  float chargeFracAlert;
  float chargeFracAlertSpeed;
  float chargeFracAlertScale;
  float chargeFracCaution;
  char* hudIcon;
  float chargeFrac;
  float useFrac;
  float chargeMaxFrac;
  float minFireFrac;
  int segments;
  int xPos;
  int yPos;
  float readyFrac;
  float dryfireFrac;
  float refillRate;
  int AbilityMeta__wasPulsing;
  float AbilityMeta__pulseStartTime;
  float AbilityMeta__lastChargeTime;
  BYTE gap_8c[128];
};

struct ruiDataStruct_ability_hud_ammo
{
  BYTE gap_0[24];
  float startTime;
  int isVisible;
  int isOffhand;
  int xPos;
  int yPos;
  BYTE gap_28[4];
  char* icon;
  BYTE gap_38[20];
};

struct ruiDataStruct_acgs_redline
{
  BYTE gap_0[72];
  int ammo;
  int clipSize;
  float vis;
  BYTE gap_54[156];
};

struct ruiDataStruct_advocate_message
{
  BYTE gap_0[32];
  char* messageText;
  char* signatureText;
  BYTE gap_30[16];
};

struct ruiDataStruct_aitdm_score_splash
{
  BYTE gap_0[28];
  float startTime;
  float updateTime;
  int pointValue;
  int pointStack;
  int earnedPointValue;
  int earnedPointStack;
  int comboNum;
  int deposit;
  int stolen;
  float banksOpen;
  float preBankPhase;
  int uploading;
  float comboTimeStart;
  float comboTimeEnd;
  float duration;
  float fadeInDuration;
  int tickDownRate;
  int lastPoints;
  int lastEarned;
  float lastTimeHadCenterPoints;
  float lastTimePopped;
  BYTE gap_70[16];
};

struct ruiDataStruct_ajax_cockpit_base
{
  BYTE gap_0[216];
  float shieldFrac;
  float healthFrac;
  char* titanInfo1;
  char* titanInfo2;
  char* titanInfo3;
  float playerOrigin[3];
  float playerEyeAngles[3];
  float dashFrac;
  int numDashSegments;
  int numHealthSegments;
  float duration;
  int isDoomed;
  int isEjecting;
  int ejectIsAllowed;
  float startFlashGreenTime;
  float cockpitColor;
  float ejectManualTimeOut;
  float ejectButtonTimeOut;
  float ejectManualStartTime;
  float ejectButtonPressTime;
  int ejectButtonCount;
  float spinnerCurrRot;
  float lastPlayerOrigin[3];
  float playerVel;
  float cgCurrent;
  BYTE gap_160[296];
};

struct ruiDataStruct_ajax_cockpit_insturment1
{
  BYTE gap_0[16];
  float playerEyeAngles[3];
  float dashFrac;
  int numDashSegments;
  int isDoomed;
  float spinnerRot;
  BYTE gap_2c[16];
};

struct ruiDataStruct_ajax_cockpit_lost_health_segment
{
  BYTE gap_0[20];
  float newHealthFrac;
  float oldHealthFrac;
  float startTime;
  int numHealthSegments;
  int isDoomed;
  BYTE gap_28[32];
};

struct ruiDataStruct_ajax_cockpit_lower
{
  BYTE gap_0[72];
  char* ejectPrompt;
  float dashFrac;
  float playerEyeAngles[3];
  int numDashSegments;
  int isDoomed;
  float cockpitColor;
  int hasUnlimitedDash;
  int isEjecting;
  float lastDashFrac;
  float lastDashFillTime;
  BYTE gap_7c[116];
};

struct ruiDataStruct_alternator_ammo_counter
{
  BYTE gap_0[28];
  int ammo;
  int clipSize;
  float vis;
  BYTE gap_28[48];
};

struct ruiDataStruct_alternator_reticle
{
  BYTE gap_0[28];
  float vis;
  BYTE gap_20[28];
};

struct ruiDataStruct_ammo_counter
{
  BYTE gap_0[72];
  char* hintText;
  float maxMagAmmo;
  float maxStockpileAmmo;
  float clipAmmoFrac;
  float remainingAmmoFrac;
  float lifetimeShots;
  float ammoRegenRate;
  int isVisible;
  int isTitan;
  int isWeaponAmped;
  int isHighlighted;
  char* hudIcon;
  char* secondaryHudIcon;
  char* tertiaryHudIcon;
  int numPips;
  int numFilledPips;
  int holdHintVisible;
  float holdWeaponSwapTime;
  float holdTime;
  float tapPingTime;
  BYTE gap_a8[128];
};

struct ruiDataStruct_ammo_counter_test
{
  BYTE gap_0[64];
  int ammo;
  int clipSize;
  int clipCount;
  BYTE gap_4c[76];
};

struct ruiDataStruct_ammo_full_flyout
{
  BYTE gap_0[72];
  float startTime;
  float duration;
  float pos[3];
  float anchorOffset[3];
  char* title;
  char* descriptionText;
  float minDist;
  float maxDist;
  BYTE gap_80[64];
};

struct ruiDataStruct_ammo_status_hint
{
  BYTE gap_0[40];
  float lowAmmoFrac;
  float ammoFrac;
  float remainingAmmoFrac;
  float readyToFireFrac;
  float reloadingFrac;
  int isVisible;
  int wasPulsing;
  float pulseStartTime;
  BYTE gap_48[32];
};

struct ruiDataStruct_announcement_center
{
  BYTE gap_0[56];
  float eventColor[3];
  float startTime;
  float duration;
  BYTE gap_48[4];
  char* messageText;
  char* messageSubText;
  char* iconImage;
  BYTE gap_68[144];
};

struct ruiDataStruct_announcement_center_sp
{
  BYTE gap_0[56];
  float eventColor[3];
  float startTime;
  float duration;
  BYTE gap_48[4];
  char* messageText;
  char* messageSubText;
  char* iconImage;
  BYTE gap_68[152];
};

struct ruiDataStruct_announcement_center_sweep
{
  BYTE gap_0[56];
  float eventColor[3];
  float startTime;
  float duration;
  BYTE gap_48[4];
  char* messageText;
  char* messageSubText;
  char* iconImage;
  BYTE gap_68[72];
};

struct ruiDataStruct_announcement_checkpoint_sp
{
  BYTE gap_0[40];
  float startTime;
  float duration;
  char* messageText;
  char* messageSubText;
  float eventColor[3];
  BYTE gap_40[4];
  char* iconImage;
  BYTE gap_58[32];
};

struct ruiDataStruct_announcement_quick
{
  BYTE gap_0[52];
  float eventColor[3];
  float startTime;
  float duration;
  char* messageText;
  char* messageSubText;
  char* iconImage;
  BYTE gap_60[80];
};

struct ruiDataStruct_announcement_quick_sp
{
  BYTE gap_0[56];
  float eventColor[3];
  float startTime;
  float duration;
  BYTE gap_48[4];
  char* messageText;
  char* messageSubText;
  char* iconImage;
  BYTE gap_68[72];
};

struct ruiDataStruct_announcement_results
{
  BYTE gap_0[56];
  float eventColor[3];
  float startTime;
  float duration;
  BYTE gap_48[4];
  char* messageText;
  char* messageSubText;
  char* iconImage;
  BYTE gap_68[76];
};

struct ruiDataStruct_aog_ammo_counter
{
  BYTE gap_0[12];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_1c[24];
};

struct ruiDataStruct_aog_ammo_counter_lstar
{
  BYTE gap_0[12];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_1c[24];
};

struct ruiDataStruct_aog_multi_reticles
{
  BYTE gap_0[40];
  int ammo;
  int clipSize;
  float vis;
  int clipCount;
  BYTE gap_38[92];
};

struct ruiDataStruct_aog_multi_reticles_lstar
{
  BYTE gap_0[40];
  int ammo;
  int clipSize;
  float vis;
  int clipCount;
  BYTE gap_38[92];
};

struct ruiDataStruct_arctool_panel
{
  BYTE gap_0[48];
  int ammo;
  int clipSize;
  float vis;
  float chargeFrac;
  float readyFrac;
  BYTE gap_44[76];
};

struct ruiDataStruct_arc_launcher_reticle
{
  BYTE gap_0[84];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_64[144];
};

struct ruiDataStruct_arrow_button_down
{
  BYTE gap_0[20];
  int isFocused;
  BYTE gap_18[12];
};

struct ruiDataStruct_arrow_button_left
{
  BYTE gap_0[12];
  int isFocused;
  BYTE gap_10[16];
};

struct ruiDataStruct_arrow_button_left_small
{
  BYTE gap_0[16];
  int isFocused;
  BYTE gap_14[12];
};

struct ruiDataStruct_arrow_button_left_tall
{
  BYTE gap_0[16];
  int isFocused;
  BYTE gap_14[12];
};

struct ruiDataStruct_arrow_button_right
{
  BYTE gap_0[12];
  int isFocused;
  BYTE gap_10[16];
};

struct ruiDataStruct_arrow_button_right_small
{
  BYTE gap_0[16];
  int isFocused;
  BYTE gap_14[12];
};

struct ruiDataStruct_arrow_button_right_tall
{
  BYTE gap_0[16];
  int isFocused;
  BYTE gap_14[12];
};

struct ruiDataStruct_arrow_button_up
{
  BYTE gap_0[20];
  int isFocused;
  BYTE gap_18[12];
};

struct ruiDataStruct_atcoop_cost_hint
{
  BYTE gap_0[40];
  char* costAmountString;
  int isVisible;
  float pos[3];
  char* weaponTextString;
  char* costTextString;
  int canAfford;
  BYTE gap_54[36];
};

struct ruiDataStruct_atcoop_locker_marker
{
  BYTE gap_0[40];
  float pos[3];
  float altPos1[3];
  float altPos2[3];
  int pointValue;
  char* title;
  char* identifier;
  int pointStack;
  float areaRadius;
  float banksOpen;
  float startTime;
  float endTime;
  int canAfford;
  char* lockerImage;
  float lastZoneChangeTime;
  float lastTransitionBasis;
  int wasInZone;
  BYTE gap_8c[68];
};

struct ruiDataStruct_atcoop_score_splash
{
  BYTE gap_0[64];
  float startTime;
  float updateTime;
  int pointValue;
  int pointStack;
  int earnedPointValue;
  int earnedPointStack;
  int totalPointValue;
  int totalPointStack;
  int comboNum;
  int deposit;
  int stolen;
  float banksOpen;
  float preBankPhase;
  int uploading;
  float comboTimeStart;
  float comboTimeEnd;
  float duration;
  float fadeInDuration;
  int tickDownRate;
  int lastBonusAdded;
  int lastBonusAddedIncrement;
  int lastPoints;
  int lastEarned;
  int pointsLastFrame;
  float lastTimeHadPoints;
  float lastTimeHadCenterPoints;
  float lastTimePopped;
  float lastTimeCenterPopped;
  float lastDotReset;
  float lastTimeBonusAdded;
  float initialPos[2];
  int earningsDeposited;
  BYTE gap_c4[60];
};

struct ruiDataStruct_at_bank_marker
{
  BYTE gap_0[56];
  char* identifier;
  float pos[3];
  float altPos1[3];
  float altPos2[3];
  int pointValue;
  char* title;
  int pointStack;
  float areaRadius;
  float banksOpen;
  float startTime;
  float endTime;
  float lastZoneChangeTime;
  float lastTransitionBasis;
  int wasInZone;
  BYTE gap_90[56];
};

struct ruiDataStruct_at_camp_marker
{
  BYTE gap_0[72];
  float progressFrac;
  float pos[3];
  float altPos1[3];
  float altPos2[3];
  char* title;
  char* identifier;
  int numLeft;
  float areaRadius;
  char* waveEnemyIcon1;
  char* waveEnemyIcon2;
  char* waveEnemyIcon3;
  char* waveEnemyIcon4;
  char* waveEnemyIcon5;
  int waveEnemyCount1;
  int waveEnemyCount2;
  int waveEnemyCount3;
  int waveEnemyCount4;
  int waveEnemyCount5;
  int isTitan;
  float lastZoneChangeTime;
  float lastTransitionBasis;
  int wasInZone;
  BYTE gap_d4[148];
};

struct ruiDataStruct_at_most_wanted
{
  BYTE gap_0[60];
  int goldPlayerReward;
  char* goldPlayer;
  char* silverPlayer;
  char* bronzePlayer;
  int silverPlayerReward;
  int bronzePlayerReward;
  BYTE gap_60[40];
};

struct ruiDataStruct_at_score_popup
{
  BYTE gap_0[28];
  int scoreVal;
  float startTime;
  float pos[3];
  float driftDir[2];
  float randomFloat;
  int hitType;
  int showNormalPoints;
  BYTE gap_44[28];
};

struct ruiDataStruct_at_score_splash
{
  BYTE gap_0[64];
  float startTime;
  float updateTime;
  int pointValue;
  int pointStack;
  int earnedPointValue;
  int earnedPointStack;
  int totalPointValue;
  int totalPointStack;
  int comboNum;
  int deposit;
  int stolen;
  float banksOpen;
  float preBankPhase;
  int uploading;
  float comboTimeStart;
  float comboTimeEnd;
  float duration;
  float fadeInDuration;
  int tickDownRate;
  int lastBonusAdded;
  int lastBonusAddedIncrement;
  int lastPoints;
  int lastEarned;
  int pointsLastFrame;
  float lastTimeHadPoints;
  float lastTimeHadCenterPoints;
  float lastTimePopped;
  float lastTimeCenterPopped;
  float lastDotReset;
  float lastTimeBonusAdded;
  float initialPos[2];
  int earningsDeposited;
  BYTE gap_c4[68];
};

struct ruiDataStruct_at_wave_intro
{
  BYTE gap_0[56];
  char* titleText;
  char* bgImage;
  char* iconImage;
  float startFadeInTime;
  float startFadeOutTime;
  char* itemText;
  int pointValue;
  int listPos;
  float offset[2];
  int visible;
  BYTE gap_74[44];
};

struct ruiDataStruct_b3wing_ammo_counter
{
  BYTE gap_0[32];
  int ammo;
  int clipSize;
  int clipCount;
  float readyToFireFrac;
  float chargeFrac;
  int isReloading;
  int isActive;
  int inCooldown;
  float pChargeFrac;
  BYTE gap_44[36];
};

struct ruiDataStruct_basic_border_box
{
  BYTE gap_0[16];
  float backgroundColor[4];
  BYTE gap_20[4];
};

struct ruiDataStruct_basic_float_text
{
  BYTE gap_0[20];
  float pos[3];
  char* floatText;
  int isVisible;
  BYTE gap_2c[28];
};

struct ruiDataStruct_basic_image
{
  BYTE gap_0[12];
  float basicImageColor[3];
  float basicImageAlpha;
  BYTE gap_18[4];
  char* basicImage;
  BYTE gap_28[4];
};

struct ruiDataStruct_basic_image_add
{
  BYTE gap_0[12];
  float basicImageColor[3];
  float basicImageAlpha;
  BYTE gap_18[4];
  char* basicImage;
  BYTE gap_28[4];
};

struct ruiDataStruct_basic_image_premul
{
  BYTE gap_0[12];
  float basicImageColor[3];
  float basicImageAlpha;
  BYTE gap_18[4];
  char* basicImage;
  BYTE gap_28[4];
};

struct ruiDataStruct_basic_menu_image
{
  BYTE gap_0[12];
  float basicImageColor[3];
  float basicImageAlpha;
  BYTE gap_18[4];
  char* basicImage;
  BYTE gap_28[8];
};

struct ruiDataStruct_battery_flyout
{
  BYTE gap_0[72];
  float color[3];
  float startTime;
  float duration;
  float pos[3];
  float underlineHeight;
  float underlineWidth;
  char* titleText;
  int isVisible;
  int isGenerator;
  int inCinematic;
  BYTE gap_84[60];
};

struct ruiDataStruct_battery_hud
{
  BYTE gap_0[44];
  int batteryCount;
  char* batteryHint;
  char* hudIcon;
  BYTE gap_40[16];
};

struct ruiDataStruct_battery_overhead_indicator_hud
{
  BYTE gap_0[24];
  float offsetY;
  float pos[3];
  char* imageName;
  float startTime;
  int shouldFadeOut;
  float titanHealth;
  float titanHealthThreshold;
  BYTE gap_40[24];
};

struct ruiDataStruct_big_button_hint
{
  BYTE gap_0[28];
  float msgPos[2];
  float msgFontSize;
  float startTime;
  float duration;
  float msgColor[4];
  char* msgText;
  char* msgTextPC;
  float msgAlpha;
  BYTE gap_54[12];
};

struct ruiDataStruct_bind_label
{
  BYTE gap_0[32];
  char* labelText;
};

struct ruiDataStruct_bleedout_timer
{
  BYTE gap_0[56];
  float endTime;
  float progressTime;
  char* text;
  BYTE gap_48[20];
};

struct ruiDataStruct_bleedout_wounded_marker
{
  BYTE gap_0[44];
  float pos[3];
  float altPos1[3];
  float altPos2[3];
  char* title;
  char* identifier;
  int showTimer;
  int numLeft;
  float areaRadius;
  float startTime;
  float endTime;
  BYTE gap_74[68];
};

struct ruiDataStruct_boost_activation_costs
{
  BYTE gap_0[28];
  float textHeight;
  char* labelText;
  char* icon;
  int activationCost;
  BYTE gap_34[12];
};

struct ruiDataStruct_boost_store_activation_costs
{
  BYTE gap_0[56];
  char* lockedText;
  char* labelText;
  char* additionalText;
  BYTE gap_50[16];
};

struct ruiDataStruct_boost_store_button
{
  BYTE gap_0[64];
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  int isBuyable;
  char* buttonImage;
  char* buttonIcon;
  int cost;
  int creditsAvailable;
  float fadeStartTime;
  float fadeEndTime;
  float targetAlpha;
  float mAlpha;
  int isFirstTime;
  BYTE gap_80[4];
  float firstWallTime;
  BYTE gap_8c[116];
};

struct ruiDataStruct_boost_store_header
{
  BYTE gap_0[40];
};

struct ruiDataStruct_boost_timed_effect_hud
{
  BYTE gap_0[32];
  float endTime;
  BYTE gap_24[12];
};

struct ruiDataStruct_buddy_titan_low_power
{
  BYTE gap_0[72];
  float color[3];
  float startTime;
  float pos[3];
  float msgAlpha;
  char* titleText;
  char* descriptionText;
  int isVisible;
  BYTE gap_7c[64];
};

struct ruiDataStruct_burn_card_button
{
  BYTE gap_0[68];
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  char* buttonImage;
  int cost;
  int creditsAvailable;
  float fadeStartTime;
  float fadeEndTime;
  float targetAlpha;
  float mAlpha;
  int isFirstTime;
  BYTE gap_78[4];
  float firstWallTime;
  BYTE gap_84[84];
};

struct ruiDataStruct_button_checkbox
{
  BYTE gap_0[28];
  int isFocused;
  int isSelected;
  BYTE gap_24[16];
};

struct ruiDataStruct_callsign_basic
{
  BYTE gap_0[64];
  float cardAlpha;
  int layoutType;
  char* playerName;
  char* playerLevel;
  char* cardImage;
  char* iconImage;
  char* cardGenImage;
  int isLobbyCard;
  float CallSignCard__randFloat;
  float CallSignCard__initTime;
  BYTE gap_7c[160];
};

struct ruiDataStruct_callsign_bottom_center
{
  BYTE gap_0[76];
  float posData[3];
  char* playerName;
  char* eventText;
  float startTime;
  float endTime;
  char* playerLevel;
  char* cardImage;
  char* iconImage;
  char* cardGenImage;
  int layoutType;
  float randomRotate;
  int isFriendly;
  int showTeamGlow;
  float CallSignCard__initTime;
  BYTE gap_a0[4];
  float CallSignCard__randFloat;
  BYTE gap_ac[152];
};

struct ruiDataStruct_callsign_card_button
{
  BYTE gap_0[84];
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  char* cardImage;
  int layoutType;
  int cost;
  int creditsAvailable;
  float fadeStartTime;
  float fadeEndTime;
  float targetAlpha;
  float mAlpha;
  int isFirstTime;
  float firstWallTime;
  BYTE gap_90[4];
  float CallSignImage__initTime;
  BYTE gap_98[4];
  float CallSignImage__randFloat;
  BYTE gap_a4[148];
};

struct ruiDataStruct_callsign_icon_button
{
  BYTE gap_0[64];
  float mAlpha;
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  char* iconImage;
  int cost;
  int creditsAvailable;
  float fadeStartTime;
  float fadeEndTime;
  float targetAlpha;
  int isFirstTime;
  float firstWallTime;
  BYTE gap_7c[84];
};

struct ruiDataStruct_callsign_icon_store
{
  BYTE gap_0[20];
  int isFocused;
  char* iconImage;
  int isFirstTime;
  BYTE gap_20[4];
  float firstWallTime;
  BYTE gap_2c[20];
};

struct ruiDataStruct_callsign_left
{
  BYTE gap_0[88];
  float posData[3];
  float startTime;
  char* playerName;
  float glowColor[4];
  char* eventText;
  float endTime;
  int layoutType;
  char* playerLevel;
  char* cardImage;
  char* iconImage;
  char* cardGenImage;
  char* eventImage;
  float randomRotate;
  int isFriendly;
  int showTeamGlow;
  float CallSignCard__randFloat;
  float CallSignCard__initTime;
  BYTE gap_cc[140];
};

struct ruiDataStruct_callsign_right
{
  BYTE gap_0[88];
  float posData[3];
  float startTime;
  char* playerName;
  float glowColor[4];
  char* eventText;
  float endTime;
  int layoutType;
  char* playerLevel;
  char* cardImage;
  char* iconImage;
  char* cardGenImage;
  char* eventImage;
  float randomRotate;
  int isFriendly;
  int showTeamGlow;
  float CallSignCard__randFloat;
  float CallSignCard__initTime;
  BYTE gap_cc[144];
};

struct ruiDataStruct_callsign_spectator_bottom_right
{
  BYTE gap_0[84];
  float posData[3];
  float glowColor[4];
  char* playerName;
  char* eventText;
  float startTime;
  float endTime;
  char* playerLevel;
  char* cardImage;
  char* iconImage;
  char* cardGenImage;
  int layoutType;
  float randomRotate;
  char* eventImage;
  int isFriendly;
  int showTeamGlow;
  float CallSignCard__initTime;
  BYTE gap_c0[4];
  float CallSignCard__randFloat;
  BYTE gap_cc[136];
};

struct ruiDataStruct_camo_button
{
  BYTE gap_0[68];
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  int cost;
  char* buttonImage;
  int creditsAvailable;
  int isFirstTime;
  float firstWallTime;
  BYTE gap_6c[100];
};

struct ruiDataStruct_car_smg_ammo_counter
{
  BYTE gap_0[36];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_34[60];
};

struct ruiDataStruct_car_smg_ammo_counter_small
{
  BYTE gap_0[56];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_48[72];
};

struct ruiDataStruct_circle_timer
{
  BYTE gap_0[36];
  float startTime;
  float endTime;
  BYTE gap_28[4];
  float imageColor[4];
  char* imageName;
  char* messageText;
  BYTE gap_50[24];
};

struct ruiDataStruct_circular_stat
{
  BYTE gap_0[48];
  float barFrac;
  float extensionFrac;
  char* valueText;
  int isPositive;
  BYTE gap_40[4];
  char* titleText;
  BYTE gap_50[32];
};

struct ruiDataStruct_cockpit_console_text_bottom_right
{
  BYTE gap_0[24];
  float msgFontSize;
  float msgPos[2];
  float msgAlpha;
  char* msgText;
  float msgColor[4];
  char* msgAlign;
  int lineNum;
  int maxLines;
  float lineHoldtime;
  int autoMove;
  int initialized;
  int currentLineNum;
  float startTime;
  BYTE gap_64[28];
};

struct ruiDataStruct_cockpit_console_text_center
{
  BYTE gap_0[24];
  float msgColor[3];
  float msgFontSize;
  float thicken;
  float msgPos[2];
  float msgAlpha;
  char* msgText;
  char* msgText2;
  char* msgAlign;
  int lineNum;
  int maxLines;
  float lineHoldtime;
  int autoMove;
  int initialized;
  int currentLineNum;
  float startTime;
  BYTE gap_6c[28];
};

struct ruiDataStruct_cockpit_console_text_top_left
{
  BYTE gap_0[24];
  float msgColor[3];
  float msgFontSize;
  float thicken;
  float msgPos[2];
  float msgAlpha;
  char* msgText;
  char* msgText2;
  char* msgAlign;
  int lineNum;
  int maxLines;
  float lineHoldtime;
  int autoMove;
  int initialized;
  int currentLineNum;
  float startTime;
  BYTE gap_6c[36];
};

struct ruiDataStruct_cockpit_console_text_top_right
{
  BYTE gap_0[24];
  float msgColor[3];
  float msgFontSize;
  float thicken;
  float msgPos[2];
  float msgAlpha;
  char* msgText;
  char* msgText2;
  char* msgAlign;
  int lineNum;
  int maxLines;
  float lineHoldtime;
  int autoMove;
  int initialized;
  int currentLineNum;
  float startTime;
  BYTE gap_6c[28];
};

struct ruiDataStruct_cockpit_text
{
  BYTE gap_0[24];
  float msgPos[2];
  float msgColor[4];
  float msgAlpha;
  float msgFontSize;
  int isVisible;
  BYTE gap_38[4];
  char* msgText;
  BYTE gap_48[16];
};

struct ruiDataStruct_combo_button_large
{
  BYTE gap_0[24];
  int isExpanded;
  int isFocused;
  int isDisabled;
  int isLocked;
  int isNew;
  int isNewMail;
  int hasPurchase;
  BYTE gap_30[4];
  char* buttonText;
  int wasFocused;
  BYTE gap_40[4];
  float focusChangeTime;
  BYTE gap_4c[100];
};

struct ruiDataStruct_combo_header_large
{
  BYTE gap_0[72];
  int isFocused;
  int isSelected;
  int isNew;
  int hasPurchase;
  char* titleText;
  int isTitleTint;
  BYTE gap_64[44];
};

struct ruiDataStruct_combo_select_button
{
  BYTE gap_0[32];
  int isFocused;
  int isSelected;
  int isLocked;
  int isNew;
  char* buttonText;
  BYTE gap_38[56];
};

struct ruiDataStruct_contact_preference_text
{
  BYTE gap_0[24];
  char* labelText;
  BYTE gap_20[8];
};

struct ruiDataStruct_controller_description
{
  BYTE gap_0[40];
  char* description;
  BYTE gap_30[16];
};

struct ruiDataStruct_controller_disconnected_gradient
{
  BYTE gap_0[16];
};

struct ruiDataStruct_controller_disconnected_image
{
  BYTE gap_0[16];
};

struct ruiDataStruct_controller_disconnected_message
{
  BYTE gap_0[32];
};

struct ruiDataStruct_controller_layout
{
  BYTE gap_0[208];
  char* leftTriggerText;
  char* leftTriggerPilotText;
  char* leftTriggerTitanText;
  char* leftBumperText;
  char* leftBumperPilotText;
  char* leftBumperTitanText;
  char* leftStickText;
  char* dpadUpTitanText;
  char* dpadDownPilotText;
  char* dpadDownTitanText;
  char* dpadLeftPilotText;
  char* dpadLeftTitanText;
  char* dpadRightTitanText;
  char* rightTriggerText;
  char* rightBumperText;
  char* rightBumperPilotText;
  char* rightBumperTitanText;
  char* yButtonText;
  char* yButtonPilotText;
  char* yButtonTitanText;
  char* bButtonText;
  char* bButtonPilotText;
  char* bButtonTitanText;
  char* aButtonText;
  char* aButtonPilotText;
  char* aButtonTitanText;
  char* xButtonText;
  char* xButtonPilotText;
  char* xButtonTitanText;
  char* rightStickText;
  int showDiffBits;
  int stickLayout;
  int isPS4;
  int customButtonsActive;
  float initTime;
  BYTE gap_1d4[580];
};

struct ruiDataStruct_control_options_description
{
  BYTE gap_0[72];
  char* description;
  BYTE gap_50[16];
};

struct ruiDataStruct_conversation
{
  BYTE gap_0[40];
  float startTime;
  float timer;
  char* text1;
  char* text2;
  float introDuration;
  float textRemoveDuration;
  int choice1Available;
  int choice2Available;
  int choice1WasSelected;
  int choice2WasSelected;
  float choiceMadeTime;
  float choiceDuration;
  int choiceMade;
  int numChoices;
  BYTE gap_68[160];
};

struct ruiDataStruct_core_hint
{
  BYTE gap_0[36];
  float coreFrac;
  float lastHintUpdateTime;
  float lastCoreFrac;
  float lastDisplayedDelta;
  BYTE gap_34[12];
};

struct ruiDataStruct_cosmetic_button
{
  BYTE gap_0[20];
  int isVisible;
  int isFocused;
  int isNew;
  char* buttonImage;
  char* camoImage;
  float fadeStartTime;
  float fadeEndTime;
  float targetAlpha;
  float mAlpha;
  int isLocked;
  int creditsAvailable;
  int isFirstTime;
  BYTE gap_48[4];
  float firstWallTime;
  BYTE gap_54[44];
};

struct ruiDataStruct_cp_hardpoint_hud
{
  BYTE gap_0[36];
  float pos[3];
  int hardpointId;
  int viewerHardpointId;
  int viewerTeam;
  int cappingTeam;
  int hardpointTeamRelation;
  int hardpointState;
  float progressFrac;
  int isVisible;
  BYTE gap_50[92];
};

struct ruiDataStruct_cp_hardpoint_marker
{
  BYTE gap_0[32];
  float pos[3];
  int hardpointId;
  int viewerHardpointId;
  int viewerTeam;
  int cappingTeam;
  int hardpointTeamRelation;
  int hardpointState;
  float progressFrac;
  int isVisible;
  int isTitan;
  float widget_0__lastActiveChangeTime;
  float widget_0__lastTransitionBasis;
  int widget_0__wasActive;
  BYTE gap_5c[116];
};

struct ruiDataStruct_cq_hardpoint_hud
{
  BYTE gap_0[36];
  float pos[3];
  int hardpointId;
  int viewerHardpointId;
  int viewerTeam;
  int cappingTeam;
  int hardpointTeamRelation;
  int hardpointState;
  float progressFrac;
  int isVisible;
  BYTE gap_50[92];
};

struct ruiDataStruct_cq_hardpoint_marker
{
  BYTE gap_0[32];
  float pos[3];
  int hardpointId;
  int viewerHardpointId;
  int viewerTeam;
  int cappingTeam;
  int hardpointTeamRelation;
  int hardpointState;
  float progressFrac;
  int isVisible;
  int isTitan;
  float widget_0__lastActiveChangeTime;
  float widget_0__lastTransitionBasis;
  int widget_0__wasActive;
  BYTE gap_5c[116];
};

struct ruiDataStruct_credits_actor_char
{
  BYTE gap_0[56];
  char* actor;
  char* line2;
  char* character;
  char* preface;
  float startTime;
  float xPos;
  float yPos;
  BYTE gap_64[12];
};

struct ruiDataStruct_credits_available
{
  BYTE gap_0[56];
  char* nameText;
  char* levelText;
  char* nextLevelText;
  char* callsignIcon;
  int credits;
  int numLevelPips;
  int filledLevelPips;
  int isPVE;
  int pveCredits;
  int isCompact;
  char* pveTitle;
  int lastCredits;
  int lastDisplayCredits;
  float lastCreditChangeTime;
  BYTE gap_80[4];
  float initTime;
  BYTE gap_8c[380];
};

struct ruiDataStruct_credits_company_logo
{
  BYTE gap_0[36];
  float startTime;
  char* line1;
  BYTE gap_30[8];
};

struct ruiDataStruct_credits_helmet_readout
{
  BYTE gap_0[28];
  float readoutAlpha;
  char* readout;
};

struct ruiDataStruct_credits_name
{
  BYTE gap_0[24];
  char* name;
  float startTime;
  float xPos;
  BYTE gap_28[8];
};

struct ruiDataStruct_credits_name_double
{
  BYTE gap_0[32];
  char* name1;
  char* name2;
  float startTime;
  BYTE gap_34[8];
};

struct ruiDataStruct_credits_name_right
{
  BYTE gap_0[24];
  char* name;
  float startTime;
  float xPos;
  BYTE gap_28[8];
};

struct ruiDataStruct_credits_name_triple
{
  BYTE gap_0[32];
  char* name1;
  char* name2;
  char* name3;
  float startTime;
  BYTE gap_3c[12];
};

struct ruiDataStruct_credits_subtitle_name
{
  BYTE gap_0[36];
  float startTime;
  char* subTitle;
  char* name;
  float xPos;
  BYTE gap_3c[16];
};

struct ruiDataStruct_credits_title
{
  BYTE gap_0[36];
  float startTime;
  char* title;
  float xPos;
  BYTE gap_34[8];
};

struct ruiDataStruct_crosshair_40mm
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_48[48];
};

struct ruiDataStruct_crosshair_40mm_burst
{
  BYTE gap_0[32];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  float chargeFrac;
  int clipAmmo;
  BYTE gap_58[80];
};

struct ruiDataStruct_crosshair_alternator
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_48[40];
};

struct ruiDataStruct_crosshair_arc
{
  BYTE gap_0[28];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  BYTE gap_48[28];
};

struct ruiDataStruct_crosshair_charge_rifle
{
  BYTE gap_0[36];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  float chargeFrac;
  float readyFrac;
  BYTE gap_5c[44];
};

struct ruiDataStruct_crosshair_circle
{
  BYTE gap_0[16];
  float adjustedSpread;
  float adsFrac;
  int isActive;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_44[32];
};

struct ruiDataStruct_crosshair_circle2
{
  BYTE gap_0[16];
  float adjustedSpread;
  float adsFrac;
  int isActive;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_44[32];
};

struct ruiDataStruct_crosshair_circle2_small
{
  BYTE gap_0[16];
  float adjustedSpread;
  float adsFrac;
  int isActive;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_44[32];
};

struct ruiDataStruct_crosshair_dot
{
  BYTE gap_0[16];
  float adjustedSpread;
  float adsFrac;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_3c[36];
};

struct ruiDataStruct_crosshair_esmoke
{
  BYTE gap_0[36];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  BYTE gap_50[32];
};

struct ruiDataStruct_crosshair_firestar
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  BYTE gap_44[32];
};

struct ruiDataStruct_crosshair_flight_core
{
  BYTE gap_0[32];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_50[32];
};

struct ruiDataStruct_crosshair_frag
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  BYTE gap_44[44];
};

struct ruiDataStruct_crosshair_frag2
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  BYTE gap_44[44];
};

struct ruiDataStruct_crosshair_grapple
{
  BYTE gap_0[24];
  float adsFrac;
  int isGrappleInRange;
  int inCooldown;
  int ammo;
  int clipSize;
  float chargeFrac;
  float ammoFrac;
  float crosshairMovementX;
  float crosshairMovementY;
  BYTE gap_3c[12];
};

struct ruiDataStruct_crosshair_grapple_charge
{
  BYTE gap_0[20];
  int isSprinting;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  float chargeStartTime;
  float chargeMaxTime;
  BYTE gap_38[56];
};

struct ruiDataStruct_crosshair_gravstar
{
  BYTE gap_0[36];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  BYTE gap_50[32];
};

struct ruiDataStruct_crosshair_grenade_launcher
{
  BYTE gap_0[16];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_40[48];
};

struct ruiDataStruct_crosshair_grenade_launcher2
{
  BYTE gap_0[16];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_40[48];
};

struct ruiDataStruct_crosshair_heat_shield
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  float chargeFrac;
  float readyFrac;
  BYTE gap_50[52];
};

struct ruiDataStruct_crosshair_ion
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_48[40];
};

struct ruiDataStruct_crosshair_ladder
{
  BYTE gap_0[16];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_40[32];
};

struct ruiDataStruct_crosshair_leadwall
{
  BYTE gap_0[16];
  float adjustedSpread;
  float adsFrac;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_3c[36];
};

struct ruiDataStruct_crosshair_lstar
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_48[40];
};

struct ruiDataStruct_crosshair_mastiff
{
  BYTE gap_0[16];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_40[32];
};

struct ruiDataStruct_crosshair_mine
{
  BYTE gap_0[20];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  BYTE gap_40[36];
};

struct ruiDataStruct_crosshair_mozambique
{
  BYTE gap_0[16];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_40[48];
};

struct ruiDataStruct_crosshair_ordnance
{
  BYTE gap_0[24];
  float adsFrac;
  int isGrappleInRange;
  int inCooldown;
  int ammo;
  int clipSize;
  float chargeFrac;
  float ammoFrac;
  float regenRate;
  float dryfireTime;
  float crosshairMovementX;
  float crosshairMovementY;
  BYTE gap_44[48];
};

struct ruiDataStruct_crosshair_phase_charge
{
  BYTE gap_0[48];
  int isSprinting;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  float chargeStartTime;
  float chargeMaxTime;
  BYTE gap_54[36];
};

struct ruiDataStruct_crosshair_plus
{
  BYTE gap_0[12];
  float adjustedSpread;
  float adsFrac;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_38[152];
};

struct ruiDataStruct_crosshair_pulse_blade
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  BYTE gap_44[32];
};

struct ruiDataStruct_crosshair_quad_rocket
{
  BYTE gap_0[20];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_44[60];
};

struct ruiDataStruct_crosshair_rearm
{
  BYTE gap_0[40];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  float chargeFrac;
  float readyFrac;
  BYTE gap_60[24];
};

struct ruiDataStruct_crosshair_satchel
{
  BYTE gap_0[20];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  BYTE gap_40[40];
};

struct ruiDataStruct_crosshair_scorch
{
  BYTE gap_0[20];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_44[60];
};

struct ruiDataStruct_crosshair_shotgun
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_48[40];
};

struct ruiDataStruct_crosshair_smart_pistol
{
  BYTE gap_0[16];
  float playerFov;
  float smartFov;
  int isLocked;
  int isVisible;
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_50[108];
};

struct ruiDataStruct_crosshair_smr
{
  BYTE gap_0[16];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_40[48];
};

struct ruiDataStruct_crosshair_sniper_amped
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_48[40];
};

struct ruiDataStruct_crosshair_square
{
  BYTE gap_0[16];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_40[40];
};

struct ruiDataStruct_crosshair_tactical
{
  BYTE gap_0[32];
  float adsFrac;
  int isGrappleInRange;
  int inCooldown;
  int ammo;
  int clipSize;
  float chargeFrac;
  float ammoFrac;
  float dryfireTime;
  float crosshairMovementX;
  float crosshairMovementY;
  BYTE gap_48[72];
};

struct ruiDataStruct_crosshair_test
{
  BYTE gap_0[56];
  float adjustedSpread;
  float adsFrac;
  int isSprinting;
  int isReloading;
  int isFiring;
  float teamColor[3];
  BYTE gap_58[76];
};

struct ruiDataStruct_crosshair_titan_predator_close_range
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_48[40];
};

struct ruiDataStruct_crosshair_titan_predator_long_range
{
  BYTE gap_0[12];
  float adjustedSpread;
  float adsFrac;
  int isSprinting;
  int isReloading;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  BYTE gap_30[148];
};

struct ruiDataStruct_crosshair_titan_predator_power_shot_close
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  BYTE gap_40[36];
};

struct ruiDataStruct_crosshair_titan_predator_power_shot_long
{
  BYTE gap_0[16];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  float readyFrac;
  BYTE gap_44[48];
};

struct ruiDataStruct_crosshair_titan_sniper
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  float chargeFrac;
  float readyFrac;
  BYTE gap_50[92];
};

struct ruiDataStruct_crosshair_tracker_rockets
{
  BYTE gap_0[32];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_50[32];
};

struct ruiDataStruct_crosshair_tri
{
  BYTE gap_0[28];
  float adjustedSpread;
  float adsFrac;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  int isFiring;
  int isAmped;
  float crosshairMovementX;
  float crosshairMovementY;
  BYTE gap_4c[68];
};

struct ruiDataStruct_crosshair_turret
{
  BYTE gap_0[20];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  int clipAmmo;
  int clipSize;
  BYTE gap_4c[56];
};

struct ruiDataStruct_crosshair_vortex
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  float chargeFrac;
  float readyFrac;
  BYTE gap_50[52];
};

struct ruiDataStruct_crosshair_wingman
{
  BYTE gap_0[24];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_48[48];
};

struct ruiDataStruct_crosshair_wingman_n
{
  BYTE gap_0[16];
  float adjustedSpread;
  float adsFrac;
  int isFiring;
  int isSprinting;
  int isReloading;
  int isGrappleInRange;
  float teamColor[3];
  float crosshairMovementX;
  float crosshairMovementY;
  int isAmped;
  BYTE gap_40[32];
};

struct ruiDataStruct_cro_threat_front
{
  BYTE gap_0[64];
  float zoomFrac;
  int ammo;
  int clipSize;
  BYTE gap_4c[52];
};

struct ruiDataStruct_ctf_flag_marker
{
  BYTE gap_0[40];
  float pos[3];
  int flagStateFlags;
  int teamRelation;
  int playerIsCarrying;
  int hardpointId;
  int viewerHardpointId;
  int viewerTeam;
  int cappingTeam;
  int hardpointTeamRelation;
  int hardpointState;
  float progressFrac;
  int isVisible;
  int pingLocation;
  float pingFrequency;
  float lastPos[3];
  float lastPosUpdateTime;
  float widget_0__lastActiveChangeTime;
  float widget_0__lastTransitionBasis;
  int widget_0__wasActive;
  BYTE gap_84[92];
};

struct ruiDataStruct_ctf_flag_return
{
  BYTE gap_0[56];
  float endTime;
  float flagReturnTime;
  char* returnFlagText;
  BYTE gap_48[20];
};

struct ruiDataStruct_ctf_home_marker
{
  BYTE gap_0[40];
  float pos[3];
  int flagStateFlags;
  int teamRelation;
  int playerIsCarrying;
  int hardpointId;
  int viewerHardpointId;
  int viewerTeam;
  int cappingTeam;
  int hardpointTeamRelation;
  int hardpointState;
  float progressFrac;
  int isVisible;
  float widget_0__lastActiveChangeTime;
  float widget_0__lastTransitionBasis;
  int widget_0__wasActive;
  BYTE gap_6c[100];
};

struct ruiDataStruct_customization_description
{
  BYTE gap_0[48];
};

struct ruiDataStruct_customization_label
{
  BYTE gap_0[40];
  char* itemName;
  char* itemType;
  BYTE gap_38[24];
};

struct ruiDataStruct_customization_pack_button
{
  BYTE gap_0[36];
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  int isOwned;
  char* buttonText;
  int isFirstTime;
  BYTE gap_40[4];
  float firstWallTime;
  BYTE gap_4c[64];
};

struct ruiDataStruct_customization_titan_icon
{
  BYTE gap_0[12];
  int rowFocused;
  char* buttonImageHl;
  char* buttonImageDim;
  BYTE gap_20[4];
};

struct ruiDataStruct_damage_flyout
{
  BYTE gap_0[16];
  int damage;
  float duration;
  float startTime;
  float pos[3];
  float randomFloat;
  int hitType;
  BYTE gap_30[40];
};

struct ruiDataStruct_damage_indicator
{
  BYTE gap_0[16];
  float startTime;
  float vecToDamage2D[3];
  float camVec2D[3];
  float duration;
  float sideDot;
  float damageOrigin[3];
  int attackerType;
  BYTE gap_44[20];
};

struct ruiDataStruct_dataknife_lower_panel
{
  BYTE gap_0[36];
  float hackStartTime;
  float hackEndTime;
  float stageDuration;
  float currentStageDuration;
  int stageCounter;
  float animFade;
  float delayTime;
  BYTE gap_40[88];
};

struct ruiDataStruct_dataknife_middle_panel
{
  BYTE gap_0[16];
  float hackStartTime;
  float hackEndTime;
  float stageDuration;
  float currentStageDuration;
  int stageCounter;
  float animFade;
  float delayTime;
  BYTE gap_2c[24];
};

struct ruiDataStruct_dataknife_upper_panel
{
  BYTE gap_0[64];
  float hackStartTime;
  float hackEndTime;
  float stageDuration;
  float nData1;
  float nData2;
  float nData3;
  float accStageTime;
  float currentStageDuration;
  int stageCounter;
  float errorTimer;
  float animFade;
  float delayTime;
  float winCondition;
  float winRotate;
  float winFade;
  float errorCondition;
  int CounterWidget1__finalDigit;
  int CounterWidget2__finalDigit;
  int CounterWidget3__finalDigit;
  BYTE gap_8c[308];
};

struct ruiDataStruct_death_hint_mp
{
  BYTE gap_0[52];
  float bgColor[3];
  float bgAlpha;
  float startTime;
  char* hintText;
  BYTE gap_50[24];
};

struct ruiDataStruct_death_hint_sp
{
  BYTE gap_0[52];
  float bgColor[3];
  float bgAlpha;
  float startTime;
  char* hintText;
  BYTE gap_50[24];
};

struct ruiDataStruct_death_icons
{
  BYTE gap_0[16];
  float startTime;
  float pos[3];
  float sizeMin;
  float sizeMax;
  char* deathImage;
  int killReplayOnly;
  BYTE gap_34[16];
};

struct ruiDataStruct_dialog_grid_pager_title
{
  BYTE gap_0[16];
  float fontSize;
  float style1Color[3];
  float style2Color[3];
  float style3Color[3];
  char* messageText;
  float style1FontScale;
  float style2FontScale;
  float style3FontScale;
  int showLockStatus;
  int isLocked;
  BYTE gap_54[36];
};

struct ruiDataStruct_dialog_message_area
{
  BYTE gap_0[24];
  float style1Color[3];
  float style2Color[3];
  float style3Color[3];
  float style1FontScale;
  char* messageText;
  float style2FontScale;
  float style3FontScale;
  BYTE gap_50[24];
};

struct ruiDataStruct_dialog_message_area_large
{
  BYTE gap_0[24];
  float style1Color[3];
  float style2Color[3];
  float style3Color[3];
  float style1FontScale;
  char* messageText;
  float style2FontScale;
  float style3FontScale;
  BYTE gap_50[24];
};

struct ruiDataStruct_dialog_spinner
{
  BYTE gap_0[28];
  int isVisible;
  float initTime;
  BYTE gap_24[12];
};

struct ruiDataStruct_dialog_titan_properties
{
  BYTE gap_0[24];
  char* messageText;
  float style1Color[3];
  float style2Color[3];
  float style3Color[3];
  float style1FontScale;
  float style2FontScale;
  float style3FontScale;
  BYTE gap_50[72];
};

struct ruiDataStruct_diamond_reticle_front
{
  BYTE gap_0[24];
  float vis;
  BYTE gap_1c[56];
};

struct ruiDataStruct_diamond_reticle_mid
{
  BYTE gap_0[24];
  float vis;
  BYTE gap_1c[36];
};

struct ruiDataStruct_diamond_reticle_rear
{
  BYTE gap_0[28];
  float vis;
  BYTE gap_20[28];
};

struct ruiDataStruct_disembarking_progress
{
  BYTE gap_0[56];
  float startTime;
  float endTime;
  BYTE gap_40[8];
};

struct ruiDataStruct_don_panel_marker
{
  BYTE gap_0[52];
  float pos[3];
  char* identifier;
  float altPos1[3];
  float altPos2[3];
  char* title;
  int playerTeam;
  float isActive;
  float areaRadius;
  int isVisible;
  float lastZoneChangeTime;
  float lastTransitionBasis;
  int wasInZone;
  BYTE gap_84[44];
};

struct ruiDataStruct_doubletake_ammo_counter
{
  BYTE gap_0[36];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_34[48];
};

struct ruiDataStruct_doubletake_reticle_doublev
{
  BYTE gap_0[36];
  float vis;
  int ammo;
  int clipSize;
  int clipCount;
  BYTE gap_34[52];
};

struct ruiDataStruct_double_jump_calibration
{
  BYTE gap_0[52];
  float startTime;
  float targetProgress;
  float startProgress;
  int wallrunStatus;
  int initialized;
  float currentProgress;
  BYTE gap_4c[32];
};

struct ruiDataStruct_dpad_button_medium
{
  BYTE gap_0[68];
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  int isDisabled;
  int showBG;
  char* buttonImage;
  int cost;
  int creditsAvailable;
  int isFirstTime;
  BYTE gap_70[4];
  float firstWallTime;
  BYTE gap_7c[116];
};

struct ruiDataStruct_dpad_comms
{
  BYTE gap_0[56];
  int selectedIndex;
  int showEmojis0;
  char* title0;
  char* title1;
  char* title2;
  char* title3;
  char* icon0;
  char* icon1;
  char* icon2;
  char* icon3;
  char* dpadImage;
  int showEmojis1;
  int showEmojis2;
  int showEmojis3;
  float startTime;
  float startDieTime;
  float countdownTime;
  BYTE gap_a0[216];
};

struct ruiDataStruct_dpad_comms_cockpit
{
  BYTE gap_0[28];
  float startTime;
  float startDieTime;
  int numIcons;
  char* emoji1;
  char* emoji2;
  char* emoji3;
  BYTE gap_40[28];
};

struct ruiDataStruct_dpad_comms_marker
{
  BYTE gap_0[20];
  float entPos[3];
  float startTime;
  float startDieTime;
  int isTitan;
  int numIcons;
  char* emoji1;
  char* emoji2;
  char* emoji3;
  BYTE gap_48[60];
};

struct ruiDataStruct_drawtext_default
{
  BYTE gap_0[12];
  float blend;
  float color[4];
  char* text;
  float pos[2];
  float height;
  float rcpActualRes[2];
  BYTE gap_3c[12];
};

struct ruiDataStruct_dropped_weapon_bt_loadout_flyout
{
  BYTE gap_0[88];
  float startTime;
  float hideDuration;
  char* titleText;
  char* icon;
  float hideStartTime;
  BYTE gap_74[20];
};

struct ruiDataStruct_dropped_weapon_flyout
{
  BYTE gap_0[80];
  float color[3];
  float startTime;
  float duration;
  float pos[3];
  float underlineHeight;
  float worldOffsetY;
  char* currentLevel;
  char* titleText;
  char* descriptionText;
  char* icon;
  int isOffhandWeapon;
  int inCinematic;
  float hideDuration;
  float hideStartTime;
  char* mod1;
  char* mod2;
  char* mod3;
  char* mod4;
  BYTE gap_c8[56];
};

struct ruiDataStruct_dropship_intro_coliseum_loadouts
{
  BYTE gap_0[100];
  float gameStartTime;
  char* playerName;
  char* pilotLoadoutName;
  char* titanLoadoutName;
  char* burnCard;
  char* playerLevel;
  char* cardImage;
  char* iconImage;
  char* cardGenImage;
  int layoutType;
  int doubleXPCount;
  char* weaponImage;
  char* tacticalImage;
  char* titanImage;
  char* burnCardImage;
  int doubleXPAvailable;
  int doubleXPStatus;
  float burnCardAlpha;
  float CallSignCard__randFloat;
  float CallSignCard__initTime;
  BYTE gap_e0[4];
  float DoubleXP__doubleXPChangeTime;
  float DoubleXP__lastDoubleXPStatus;
  BYTE gap_f0[184];
};

struct ruiDataStruct_dropship_intro_countdown
{
  BYTE gap_0[32];
  float gameStartTime;
  BYTE gap_24[28];
};

struct ruiDataStruct_dropship_intro_jumping
{
  BYTE gap_0[84];
  float fadeStartTime;
  char* factionTitle;
  float gameStartTime;
  BYTE gap_60[4];
  char* factionImage;
  char* introMessage;
  BYTE gap_78[84];
};

struct ruiDataStruct_dropship_intro_loadouts
{
  BYTE gap_0[128];
  char* playerName;
  float gameStartTime;
  int layoutType;
  char* pilotLoadoutName;
  char* titanLoadoutName;
  char* burnCard;
  char* playerLevel;
  char* cardImage;
  char* iconImage;
  char* cardGenImage;
  char* weaponImage;
  char* tacticalImage;
  char* titanImage;
  char* burnCardImage;
  int doubleXPCount;
  int doubleXPAvailable;
  int doubleXPStatus;
  float burnCardAlpha;
  float CallSignCard__initTime;
  BYTE gap_f8[4];
  float CallSignCard__randFloat;
  float DoubleXP__doubleXPChangeTime;
  float DoubleXP__lastDoubleXPStatus;
  BYTE gap_10c[300];
};

struct ruiDataStruct_dropship_intro_pilot_loadouts
{
  BYTE gap_0[128];
  char* playerName;
  float gameStartTime;
  int layoutType;
  char* pilotLoadoutName;
  char* titanLoadoutName;
  char* burnCard;
  char* playerLevel;
  char* cardImage;
  char* iconImage;
  char* cardGenImage;
  char* weaponImage;
  char* tacticalImage;
  char* titanImage;
  char* burnCardImage;
  int doubleXPCount;
  int doubleXPAvailable;
  int doubleXPStatus;
  float burnCardAlpha;
  float CallSignCard__initTime;
  BYTE gap_f8[4];
  float CallSignCard__randFloat;
  float DoubleXP__doubleXPChangeTime;
  float DoubleXP__lastDoubleXPStatus;
  BYTE gap_10c[276];
};

struct ruiDataStruct_dropship_intro_titan_loadouts
{
  BYTE gap_0[72];
  float gameStartTime;
  int layoutType;
  char* pilotLoadoutName;
  char* titanLoadoutName;
  char* burnCard;
  char* playerName;
  char* playerLevel;
  char* cardImage;
  char* iconImage;
  char* cardGenImage;
  char* weaponImage;
  char* tacticalImage;
  char* titanImage;
  char* burnCardImage;
  int doubleXPCount;
  int doubleXPAvailable;
  int doubleXPStatus;
  float burnCardAlpha;
  float DoubleXP__doubleXPChangeTime;
  float DoubleXP__lastDoubleXPStatus;
  BYTE gap_c8[72];
};

struct ruiDataStruct_earn_meter
{
  BYTE gap_0[88];
  char* buttonHintText;
  int meterMode;
  float lastEarnChangeTime;
  float lastOwnChangeTime;
  float ownedFrac;
  float earnedFrac;
  float rewardFrac;
  float earnedStartFrac;
  float ownedStartFrac;
  char* goalBuildingIcon;
  char* goalReadyIcon;
  int goalState;
  int goalSubState;
  char* rewardBuildingIcon;
  char* rewardReadyIcon;
  char* rewardString;
  int rewardState;
  float lastHintTime;
  int isPetDoomed;
  float fillAnimDuration;
  float lastAliveTime;
  BYTE gap_c4[180];
};

struct ruiDataStruct_epg_ammo_counter
{
  BYTE gap_0[64];
  int ammo;
  int clipSize;
  float vis;
  BYTE gap_4c[48];
};

struct ruiDataStruct_faction_button
{
  BYTE gap_0[104];
  char* subText;
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  int cost;
  char* buttonImage;
  int creditsAvailable;
  float numSegments;
  float filledSegments;
  float fadeStartTime;
  float fadeEndTime;
  float targetAlpha;
  float mAlpha;
  int isFirstTime;
  float firstWallTime;
  BYTE gap_b4[412];
};

struct ruiDataStruct_fd_gamesummary
{
  BYTE gap_0[112];
  char* playerName0;
  char* playerAward0;
  char* awardData0;
  char* playerAwardSubtext0;
  char* playerName1;
  char* playerAward1;
  char* awardData1;
  char* playerAwardSubtext1;
  char* playerName2;
  char* playerAward2;
  char* awardData2;
  char* playerAwardSubtext2;
  char* playerName3;
  char* playerAward3;
  char* awardData3;
  char* playerAwardSubtext3;
  int numPlayers;
  float startTime;
  char* playerAwardImage0;
  char* playerAwardImage1;
  char* playerAwardImage2;
  char* playerAwardImage3;
  float endTime;
  BYTE gap_11c[100];
};

struct ruiDataStruct_fd_scoreboard
{
  BYTE gap_0[20];
  int isVisible;
  BYTE gap_18[4];
};

struct ruiDataStruct_fd_scoreboard_data
{
  BYTE gap_0[76];
  int isVisible;
  char* icon0;
  char* icon1;
  char* icon2;
  char* icon3;
  char* icon4;
  char* icon5;
  char* icon6;
  char* icon7;
  char* icon8;
  char* emptyIcon0;
  char* emptyIcon1;
  char* emptyIcon2;
  char* emptyIcon3;
  char* emptyIcon4;
  char* emptyIcon5;
  char* emptyIcon6;
  char* emptyIcon7;
  char* emptyIcon8;
  int count0;
  int count1;
  int count2;
  int count3;
  int count4;
  int count5;
  int count6;
  int count7;
  int count8;
  int difficulty;
  char* waveString;
  BYTE gap_110[160];
};

struct ruiDataStruct_fd_score_splash
{
  BYTE gap_0[32];
  float startTime;
  float updateTime;
  int pointValue;
  int pointStack;
  int comboNum;
  int deposit;
  int stolen;
  float banksOpen;
  float preBankPhase;
  int uploading;
  float comboTimeStart;
  float comboTimeEnd;
  float duration;
  float fadeInDuration;
  int tickDownRate;
  int lastBonusAdded;
  int lastBonusAddedIncrement;
  int lastPoints;
  int pointsLastFrame;
  float lastTimeHadPoints;
  float lastTimeHadCenterPoints;
  float lastTimePopped;
  float lastTimeCenterPopped;
  float lastTimeBonusAdded;
  float initialPos[2];
  BYTE gap_88[40];
};

struct ruiDataStruct_fd_wave_intro
{
  BYTE gap_0[60];
  float startFadeInTime;
  char* titleText;
  char* bgImage;
  char* iconImage;
  float startFadeOutTime;
  int pointValue;
  char* itemText;
  int listPos;
  float offset[2];
  int visible;
  BYTE gap_78[48];
};

struct ruiDataStruct_floating_holotext
{
  BYTE gap_0[68];
  float length;
  char* textTop;
  char* txtCopyText1;
  char* txtCopyText2;
  char* txtCopyText3;
  float height;
  BYTE gap_6c[36];
};

struct ruiDataStruct_floating_holotext_large
{
  BYTE gap_0[68];
  float length;
  char* textTop;
  char* txtCopyText1;
  char* txtCopyText2;
  char* txtCopyText3;
  float height;
  BYTE gap_6c[36];
};

struct ruiDataStruct_flyout_generic
{
  BYTE gap_0[72];
  float color[3];
  float startTime;
  float pos[3];
  float offset[3];
  char* titleText;
  char* descriptionText;
  float msgAlpha;
  int isVisible;
  BYTE gap_88[64];
};

struct ruiDataStruct_footer_button
{
  BYTE gap_0[28];
  int isFocused;
  char* buttonText;
  BYTE gap_28[40];
};

struct ruiDataStruct_fra_battery_icon
{
  BYTE gap_0[20];
  float pos[3];
  char* imageName;
  int isVisible;
  float startTime;
  BYTE gap_30[32];
};

struct ruiDataStruct_friendly_fire_warning
{
  BYTE gap_0[52];
  float startTime;
  float fadeInDuration;
  float fadeOutDuration;
  BYTE gap_40[8];
};

struct ruiDataStruct_friend_button
{
  BYTE gap_0[28];
  int isVisible;
  int isFocused;
  int isLocked;
  char* buttonText;
  int isFirstTime;
  BYTE gap_30[4];
  float firstWallTime;
  BYTE gap_3c[60];
};

struct ruiDataStruct_fw_base_marker
{
  BYTE gap_0[28];
  float titleFontSize;
  float alpha;
  float pos[3];
  float distMin;
  float distMax;
  float sizeMin;
  float sizeMax;
  char* imageName;
  int clampToEdge;
  float fadeOutAlpha;
  float nearFadeDistMin;
  float nearFadeDistMax;
  float farFadeDistMin;
  float farFadeDistMax;
  float offsetY;
  float startFadeTime;
  char* title;
  float health;
  float distance;
  int isVisible;
  BYTE gap_7c[60];
};

struct ruiDataStruct_fw_base_portrait
{
  BYTE gap_0[44];
  float portraitColor[3];
  int isVisible;
  int listPos;
  char* imageName;
  float startTime;
  int pointValue;
  int alertLevel;
  int totalNum;
  float startFadeOutTime;
  float xStartTime;
  float health;
  int wasVisible;
  float visChangeStartTime;
  BYTE gap_6c[52];
};

struct ruiDataStruct_fw_camp_marker
{
  BYTE gap_0[36];
  float progressFrac;
  float pos[3];
  int numLeft;
  char* title;
  char* identifier;
  float areaRadius;
  int alertLevel;
  int isVisible;
  float lastZoneChangeTime;
  float lastTransitionBasis;
  int wasInZone;
  BYTE gap_60[40];
};

struct ruiDataStruct_fw_camp_portrait
{
  BYTE gap_0[48];
  float portraitColor[3];
  int isVisible;
  char* imageName;
  int listPos;
  float startTime;
  int pointValue;
  int alertLevel;
  int totalNum;
  float startFadeOutTime;
  float xStartTime;
  int myTeam;
  float healthFrac;
  int wasVisible;
  float visChangeStartTime;
  BYTE gap_74[72];
};

struct ruiDataStruct_fw_objective_text
{
  BYTE gap_0[28];
  float objectiveFontSize;
  int isVisible;
  BYTE gap_20[4];
  char* objective;
  BYTE gap_30[8];
};

struct ruiDataStruct_fw_site_marker
{
  BYTE gap_0[40];
  float pos[3];
  int isVisible;
  int turretStateFlags;
  int viewerBatteryCount;
  int viewerTeam;
  int teamRelation;
  BYTE gap_48[56];
};

struct ruiDataStruct_g2a4_ammo_counter
{
  BYTE gap_0[88];
  float vis;
  int ammo;
  int clipSize;
  int clipCount;
  BYTE gap_68[256];
};

struct ruiDataStruct_g2a4_sights
{
  BYTE gap_0[32];
  float vis;
  BYTE gap_24[72];
};

struct ruiDataStruct_gamemode_coliseum_intro
{
  BYTE gap_0[92];
  float startTime;
  char* playerName0;
  char* playerName1;
  float endTime;
  int layoutType0;
  char* playerLevel0;
  char* cardImage0;
  char* iconImage0;
  char* cardGenImage0;
  int streak0;
  int wins0;
  int losses0;
  int layoutType1;
  char* playerLevel1;
  char* cardImage1;
  char* iconImage1;
  char* cardGenImage1;
  int streak1;
  int wins1;
  int losses1;
  float CallSignCard0__randFloat;
  float CallSignCard0__initTime;
  BYTE gap_d8[4];
  float CallSignCard1__initTime;
  BYTE gap_e0[4];
  float CallSignCard1__randFloat;
  BYTE gap_ec[308];
};

struct ruiDataStruct_gamemode_coliseum_tickets
{
  BYTE gap_0[36];
  float startTime;
  float startTicketFade;
  float duration;
  int numTickets;
  BYTE gap_34[28];
};

struct ruiDataStruct_gamepad_bindlist_button
{
  BYTE gap_0[32];
  float startTime;
  BYTE gap_20[4];
  int isVisible;
  int isFocused;
  int isSelected;
  int alignedRight;
  char* commandLabelCommon;
  char* commandLabelSpecific;
  char* iconText;
  int isNonDefault;
  BYTE gap_54[68];
};

struct ruiDataStruct_gamestate_info
{
  BYTE gap_0[76];
  float endTime;
  char* statusText;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  char* roundText;
  char* factionImage;
  int friendlyPlayerStatusType1;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  BYTE gap_b8[428];
};

struct ruiDataStruct_gamestate_info_at
{
  BYTE gap_0[136];
  float campProgress1;
  float campProgress2;
  float campProgress3;
  float endTime;
  char* statusText;
  float teamBonus[2];
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  char* factionImage;
  int campVisible1;
  int campVisible2;
  int campVisible3;
  int campBoss1;
  int campBoss2;
  int campBoss3;
  int isInZone;
  int friendlyPlayerStatusType1;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  BYTE gap_11c[524];
};

struct ruiDataStruct_gamestate_info_atcoop
{
  BYTE gap_0[104];
  float campProgress1;
  float campProgress2;
  float campProgress3;
  float endTime;
  char* waveNumber;
  char* statusText;
  float teamBonus[2];
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  char* roundText;
  char* factionImage;
  int campVisible1;
  int campVisible2;
  int campVisible3;
  int campBoss1;
  int campBoss2;
  int campBoss3;
  int isInZone;
  int friendlyPlayerStatusType1;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  BYTE gap_10c[244];
};

struct ruiDataStruct_gamestate_info_coliseum
{
  BYTE gap_0[72];
  char* roundText;
  float endTime;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  char* statusText;
  int maxTeamPlayers;
  int friendlyPlayerStatusType1;
  char* factionImage;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  BYTE gap_b4[52];
};

struct ruiDataStruct_gamestate_info_cp
{
  BYTE gap_0[92];
  float endTime;
  char* statusText;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  char* factionImage;
  int friendlyPlayerStatusType1;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  int friendlyChevronState;
  int enemyChevronState;
  BYTE gap_c8[512];
};

struct ruiDataStruct_gamestate_info_cq
{
  BYTE gap_0[64];
  char* statusText;
  float endTime;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  int friendlyPlayerStatusType1;
  char* factionImage;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  int friendlyChevronState;
  int enemyChevronState;
  BYTE gap_ac[20];
};

struct ruiDataStruct_gamestate_info_ctf
{
  BYTE gap_0[64];
  float endTime;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  char* statusText;
  int maxTeamPlayers;
  int ctfFlags;
  char* factionImage;
  char* enemyCarrierName;
  char* friendlyCarrierName;
  int friendlyPlayerStatusType1;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  char* roundText;
  BYTE gap_c0[128];
};

struct ruiDataStruct_gamestate_info_ctf_alt
{
  BYTE gap_0[96];
  float endTime;
  float teamBonus[2];
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  char* statusText;
  char* roundText;
  int maxTeamPlayers;
  int ctfFlags;
  char* factionImage;
  char* enemyCarrierName;
  char* friendlyCarrierName;
  int friendlyPlayerStatusType1;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  int flagsVisible;
  BYTE gap_ec[460];
};

struct ruiDataStruct_gamestate_info_fd
{
  BYTE gap_0[116];
  float friendlyHealth;
  float friendlyShield;
  float endTime;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  char* statusText;
  int difficulty;
  int friendlyPlayerStatusType1;
  char* factionImage;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  float harvesterShieldBoostTime;
  char* statusTextAdd;
  char* roundText;
  float waveStatus;
  float nextWaveStartTime;
  int currentWave;
  int maxWaves;
  int restartsRemaining;
  int hasRestarted;
  int showStatusTextAdd;
  int totalAI;
  int remainingAI;
  int waveState;
  int isReady;
  float lastShieldDamageTime;
  float lastHealthDamageTime;
  float lastFriendlyHealth;
  float lastFriendlyShield;
  int lastIsWaveBreak;
  float lastWaveBreakChangeTime;
  int allyStatus1__prevStatusType;
  float allyStatus1__titanDieTime;
  int allyStatus2__prevStatusType;
  float allyStatus2__titanDieTime;
  int allyStatus3__prevStatusType;
  float allyStatus3__titanDieTime;
  int allyStatus4__prevStatusType;
  float allyStatus4__titanDieTime;
  BYTE gap_12c[148];
};

struct ruiDataStruct_gamestate_info_ffa
{
  BYTE gap_0[68];
  float endTime;
  char* statusText;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  char* factionImage;
  char* friendlyPlayerCardImage;
  char* enemyPlayerCardImage;
  int friendlyPlayerStatusType1;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  int enemyPlayerStatusType9;
  int enemyPlayerStatusType10;
  int enemyPlayerStatusType11;
  int enemyPlayerStatusType12;
  int enemyPlayerStatusType13;
  int enemyPlayerStatusType14;
  int enemyPlayerStatusType15;
  BYTE gap_b8[128];
};

struct ruiDataStruct_gamestate_info_fra
{
  BYTE gap_0[68];
  float endTime;
  char* statusText;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  char* factionImage;
  char* friendlyPlayerCardImage;
  char* enemyPlayerCardImage;
  int friendlyPlayerStatusType1;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  int enemyPlayerStatusType9;
  int enemyPlayerStatusType10;
  int enemyPlayerStatusType11;
  int enemyPlayerStatusType12;
  int enemyPlayerStatusType13;
  int enemyPlayerStatusType14;
  int enemyPlayerStatusType15;
  BYTE gap_b8[128];
};

struct ruiDataStruct_gamestate_info_fw
{
  BYTE gap_0[128];
  float endTime;
  float leftTeamScore;
  float rightTeamScore;
  float friendlyShield;
  float enemyShield;
  int maxTeamScore;
  char* statusText;
  char* statusTextAdd;
  int maxTeamPlayers;
  int friendlyPlayerStatusType1;
  char* factionImage;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  int threatLevel;
  int enemyThreatLevel;
  BYTE gap_fc[460];
};

struct ruiDataStruct_gamestate_info_fw_health
{
  BYTE gap_0[24];
  float enemyHealthStartFrac;
  float enemyHealthEndFrac;
  float enemyShieldStartFrac;
  float enemyShieldEndFrac;
  float friendlyHealthStartFrac;
  float friendlyHealthEndFrac;
  float friendlyShieldStartFrac;
  float friendlyShieldEndFrac;
  float startTime;
  BYTE gap_3c[20];
};

struct ruiDataStruct_gamestate_info_lts
{
  BYTE gap_0[72];
  char* roundText;
  float endTime;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  int friendlyPlayerStatusType1;
  char* statusText;
  char* factionImage;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  int allyStatus1__prevStatusType;
  float allyStatus1__titanDieTime;
  int allyStatus2__prevStatusType;
  float allyStatus2__titanDieTime;
  int allyStatus3__prevStatusType;
  float allyStatus3__titanDieTime;
  int allyStatus4__prevStatusType;
  float allyStatus4__titanDieTime;
  int allyStatus5__prevStatusType;
  float allyStatus5__titanDieTime;
  int allyStatus6__prevStatusType;
  float allyStatus6__titanDieTime;
  int allyStatus7__prevStatusType;
  float allyStatus7__titanDieTime;
  int allyStatus8__prevStatusType;
  float allyStatus8__titanDieTime;
  int enemyStatus1__prevStatusType;
  float enemyStatus1__titanDieTime;
  int enemyStatus2__prevStatusType;
  float enemyStatus2__titanDieTime;
  int enemyStatus3__prevStatusType;
  float enemyStatus3__titanDieTime;
  int enemyStatus4__prevStatusType;
  float enemyStatus4__titanDieTime;
  int enemyStatus5__prevStatusType;
  float enemyStatus5__titanDieTime;
  int enemyStatus6__prevStatusType;
  float enemyStatus6__titanDieTime;
  int enemyStatus7__prevStatusType;
  float enemyStatus7__titanDieTime;
  int enemyStatus8__prevStatusType;
  float enemyStatus8__titanDieTime;
  BYTE gap_134[168];
};

struct ruiDataStruct_gamestate_info_lts_bomb
{
  BYTE gap_0[76];
  float endTime;
  char* roundText;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  char* statusText;
  char* factionImage;
  float bombTime;
  int friendlyPlayerStatusType1;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  int bombPlanted;
  int bombStatus;
  BYTE gap_c0[4];
  char* bombPlantedImage;
  BYTE gap_d0[112];
};

struct ruiDataStruct_gamestate_info_mfd
{
  BYTE gap_0[92];
  float endTime;
  char* statusText;
  char* friendlyMarkName;
  char* enemyMarkName;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  char* factionImage;
  int isFriendlyMarked;
  int isEnemyMarked;
  int friendlyPlayerStatusType1;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  BYTE gap_d8[420];
};

struct ruiDataStruct_gamestate_info_ps
{
  BYTE gap_0[72];
  char* statusText;
  float endTime;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  int friendlyPlayerStatusType1;
  char* factionImage;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  BYTE gap_ac[52];
};

struct ruiDataStruct_gamestate_info_pve_sandbox
{
  BYTE gap_0[80];
  float endTime;
  int isInZone;
  char* factionImage;
  int segmentCount;
  int segmentCurrentIndex;
  int segmentCurrentGoal;
  int goalCounter;
  int goalCounterTarget;
  float targetTime;
  char* statusText;
  float campProgress1;
  float campProgress2;
  float campProgress3;
  int campVisible1;
  int campVisible2;
  int campVisible3;
  int campBoss1;
  int campBoss2;
  int campBoss3;
  int friendlyPlayerStatusType1;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int segmentLatestGoal;
  float timeTurnedNotStarted;
  float timeTurnedActive;
  float timeTurnedComplete;
  int goalCounterLatest;
  float timeUpdatedGoalCounter;
  BYTE gap_cc[572];
};

struct ruiDataStruct_gamestate_info_raid
{
  BYTE gap_0[92];
  float friendlyBombAlpha;
  float enemyBombAlpha;
  float endTime;
  char* statusText;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  char* factionImage;
  float bombTime;
  int friendlyPlayerStatusType1;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  int bombPlanted;
  int bombStatus;
  float friendlyBombEndTime;
  char* bombPlantedImage;
  float enemyBombEndTime;
  float bombDetonationTime;
  BYTE gap_e8[116];
};

struct ruiDataStruct_gamestate_info_speedball
{
  BYTE gap_0[88];
  char* roundText;
  char* statusText;
  float endTime;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  int friendlyPlayerStatusType1;
  char* factionImage;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  int teamRelation;
  int isCarried;
  int isVisible;
  int allyStatus1__prevStatusType;
  float allyStatus1__titanDieTime;
  int allyStatus2__prevStatusType;
  float allyStatus2__titanDieTime;
  int allyStatus3__prevStatusType;
  float allyStatus3__titanDieTime;
  int allyStatus4__prevStatusType;
  float allyStatus4__titanDieTime;
  int allyStatus5__prevStatusType;
  float allyStatus5__titanDieTime;
  int allyStatus6__prevStatusType;
  float allyStatus6__titanDieTime;
  int allyStatus7__prevStatusType;
  float allyStatus7__titanDieTime;
  int allyStatus8__prevStatusType;
  float allyStatus8__titanDieTime;
  int enemyStatus1__prevStatusType;
  float enemyStatus1__titanDieTime;
  int enemyStatus2__prevStatusType;
  float enemyStatus2__titanDieTime;
  int enemyStatus3__prevStatusType;
  float enemyStatus3__titanDieTime;
  int enemyStatus4__prevStatusType;
  float enemyStatus4__titanDieTime;
  int enemyStatus5__prevStatusType;
  float enemyStatus5__titanDieTime;
  int enemyStatus6__prevStatusType;
  float enemyStatus6__titanDieTime;
  int enemyStatus7__prevStatusType;
  float enemyStatus7__titanDieTime;
  int enemyStatus8__prevStatusType;
  float enemyStatus8__titanDieTime;
  BYTE gap_150[216];
};

struct ruiDataStruct_gamestate_info_stack
{
  BYTE gap_0[96];
  char* statusText;
  float endTime;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  int friendlyPlayerStatusType1;
  char* factionImage;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  BYTE gap_c4[408];
};

struct ruiDataStruct_gamestate_roundbased_info
{
  BYTE gap_0[76];
  float endTime;
  char* statusText;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  int maxTeamPlayers;
  char* roundText;
  char* factionImage;
  int friendlyPlayerStatusType1;
  int friendlyPlayerStatusType2;
  int friendlyPlayerStatusType3;
  int friendlyPlayerStatusType4;
  int friendlyPlayerStatusType5;
  int friendlyPlayerStatusType6;
  int friendlyPlayerStatusType7;
  int friendlyPlayerStatusType8;
  int enemyPlayerStatusType1;
  int enemyPlayerStatusType2;
  int enemyPlayerStatusType3;
  int enemyPlayerStatusType4;
  int enemyPlayerStatusType5;
  int enemyPlayerStatusType6;
  int enemyPlayerStatusType7;
  int enemyPlayerStatusType8;
  BYTE gap_b8[40];
};

struct ruiDataStruct_gamestate_turret_info_fw
{
  BYTE gap_0[32];
  float endTime;
  float leftTeamScore;
  float rightTeamScore;
  int maxTeamScore;
  char* statusText;
  int maxTeamPlayers;
  int viewTeam;
  int turretStateFlags1;
  int turretStateFlags2;
  int turretStateFlags3;
  int turretStateFlags4;
  int turretStateFlags5;
  int turretStateFlags6;
  int turretStateFlags7;
  int turretStateFlags8;
  int turretStateFlags9;
  BYTE gap_64[396];
};

struct ruiDataStruct_gamma_hint_label
{
  BYTE gap_0[24];
  char* labelText;
  BYTE gap_20[8];
};

struct ruiDataStruct_gamma_slider
{
  BYTE gap_0[24];
  float sliderFrac;
  BYTE gap_1c[12];
};

struct ruiDataStruct_gauntlet_hud
{
  BYTE gap_0[132];
  float startTime;
  int runFinished;
  float finalTime;
  float bestTime;
  int numEnemies;
  int enemiesKilled;
  float enemiesMissedTimePenalty;
  int useMetric;
  float playerPos[3];
  float lastPlayerSpeed;
  float lastPlayerPos[3];
  float lastFrameTime;
  BYTE gap_c4[76];
};

struct ruiDataStruct_gauntlet_leaderboard
{
  BYTE gap_0[108];
  float entry0Time;
  char* entry0Name;
  char* entry1Name;
  char* entry2Name;
  char* entry3Name;
  char* entry4Name;
  char* entry5Name;
  char* entry6Name;
  char* entry7Name;
  char* entry8Name;
  char* entry9Name;
  float entry1Time;
  float entry2Time;
  float entry3Time;
  float entry4Time;
  float entry5Time;
  float entry6Time;
  float entry7Time;
  float entry8Time;
  float entry9Time;
  int activeEntryIdx;
  int highlightNameIdx;
  BYTE gap_ec[660];
};

struct ruiDataStruct_gauntlet_results_display
{
  BYTE gap_0[292];
  float startTime;
  int runFinished;
  float finalTime;
  float bestTime;
  int numEnemies;
  int enemiesKilled;
  float enemiesMissedTimePenalty;
  float avgSpeed;
  float topSpeed;
  float highSpeedPercent;
  int highSpeedKills;
  char* tipString;
  float tipResetTime;
  BYTE gap_15c[244];
};

struct ruiDataStruct_gauntlet_splash
{
  BYTE gap_0[68];
  float duration;
  char* message;
  int initialized;
  float startTime;
  float slideInDuration;
  float slideInEndTime;
  float holdEndTime;
  float slideOutEndTime;
  BYTE gap_68[16];
};

struct ruiDataStruct_gauntlet_starting_line
{
  BYTE gap_0[40];
  char* displayText;
  BYTE gap_30[8];
};

struct ruiDataStruct_genup_button
{
  BYTE gap_0[32];
  float startTime;
  BYTE gap_20[4];
  int isVisible;
  int isFocused;
  int isSelected;
  BYTE gap_30[4];
  char* buttonText;
  BYTE gap_40[40];
};

struct ruiDataStruct_grenade_threat_indicator
{
  BYTE gap_0[28];
  float startTime;
  float damageRadius;
  float pos[3];
  BYTE gap_30[16];
};

struct ruiDataStruct_grid_spinner
{
  BYTE gap_0[16];
  int isVisible;
  BYTE gap_10[4];
  float initTime;
  BYTE gap_1c[12];
};

struct ruiDataStruct_happyhour_label
{
  BYTE gap_0[40];
  char* happyHourHintString;
  char* labelText;
  int happyHourMeritCount;
  int remainingMeritCount;
  int isHappyHour;
  BYTE gap_40[4];
  float initTime;
  BYTE gap_4c[20];
};

struct ruiDataStruct_harvester_damage_report
{
  BYTE gap_0[124];
  float startTime;
  float endTime;
  int damage0;
  char* icon0;
  char* icon1;
  char* icon2;
  char* name0;
  char* name1;
  char* name2;
  int damage1;
  int damage2;
  float time0;
  float time1;
  float time2;
  BYTE gap_c8[4];
  char* retryString;
  char* tip;
  BYTE gap_e0[144];
};

struct ruiDataStruct_harvester_shield_hud
{
  BYTE gap_0[64];
  int batteryCount;
  BYTE gap_44[20];
};

struct ruiDataStruct_harvester_shield_use
{
  BYTE gap_0[28];
  float startTime;
  float duration;
  BYTE gap_20[4];
  char* title;
  char* icon;
  BYTE gap_38[24];
};

struct ruiDataStruct_hcog_lower
{
  BYTE gap_0[76];
  float vis;
  int ammo;
  int clipSize;
  BYTE gap_58[128];
};

struct ruiDataStruct_hcog_upper
{
  BYTE gap_0[12];
  float vis;
  int ammo;
  int clipSize;
  BYTE gap_18[24];
};

struct ruiDataStruct_helmet_border
{
  BYTE gap_0[40];
  float tacticalHintTime;
  float ordnanceHintTime;
  float weaponHintTime;
  float startTime;
  BYTE gap_38[24];
};

struct ruiDataStruct_helmet_reboot
{
  BYTE gap_0[12];
  float startTime;
  BYTE gap_10[4];
};

struct ruiDataStruct_helmet_scanning_percentbar
{
  BYTE gap_0[52];
  float startTime;
  float fadeInDuration;
  float stage1Duration;
  float stage2Duration;
  BYTE gap_40[4];
  char* stage1Text;
  char* stage2Text;
  char* stage3TextTop;
  char* stage3TextBottom;
  BYTE gap_68[32];
};

struct ruiDataStruct_hemlok_bfr_ammo_counter
{
  BYTE gap_0[148];
  int ammo;
  int clipSize;
  int clipCount;
  BYTE gap_a0[184];
};

struct ruiDataStruct_hemlok_esaw_ammo_counter
{
  BYTE gap_0[160];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_b0[48];
};

struct ruiDataStruct_hint_display
{
  BYTE gap_0[28];
  float hintTextSize;
  float color1[3];
  float colorStyle2[3];
  float altColorStyle3[3];
  float endTime;
  char* hintText;
  float fadeTime;
  BYTE gap_50[4];
  char* hintImage;
  BYTE gap_60[8];
};

struct ruiDataStruct_hit_indicator
{
  BYTE gap_0[24];
  float startTime;
  int hitType;
  char* fgImage;
  char* bgImage;
  char* bgImageCrit;
  char* fgImageMin;
  char* bgImageMin;
  BYTE gap_48[40];
};

struct ruiDataStruct_holo_scope
{
  BYTE gap_0[120];
  float vis;
  int ammo;
  int clipSize;
  int clipCount;
  BYTE gap_88[144];
};

struct ruiDataStruct_hunted_asset_timer
{
  BYTE gap_0[56];
  float endTime;
  float progressTime;
  char* text;
  BYTE gap_48[20];
};

struct ruiDataStruct_hunted_objective
{
  BYTE gap_0[84];
  float startTime;
  float endTime;
  float pos[3];
  char* objectiveTitleText;
  char* objectiveText;
  float fadeInDuration;
  float fadeOutDuration;
  float blingDuration;
  int showAll;
  int showDist;
  int showButtonHint;
  int showLine;
  int showMarker;
  int isHuntedTeam;
  float additionalKilometers;
  float pingFrequency;
  float lastPos[3];
  float lastPosUpdateTime;
  BYTE gap_b4[64];
};

struct ruiDataStruct_hunted_wounded_marker
{
  BYTE gap_0[44];
  float pos[3];
  float altPos1[3];
  float altPos2[3];
  char* title;
  char* identifier;
  int numLeft;
  float areaRadius;
  float startTime;
  float endTime;
  BYTE gap_70[64];
};

struct ruiDataStruct_ingame_double_xp
{
  BYTE gap_0[104];
  int isVisible;
  int doubleXPStatus;
  char* scoreMeritText;
  int matchScoreMerit;
  int matchCompleteMerit;
  int matchWinMerit;
  int matchEvacMerit;
  int weaponMeritCount;
  int titanMeritCount;
  int happyHourMerits;
  int meritCount;
  float DoubleXP__doubleXPChangeTime;
  float DoubleXP__lastDoubleXPStatus;
  BYTE gap_a0[400];
};

struct ruiDataStruct_inventory_hud
{
  BYTE gap_0[32];
  char* hintText;
  float hintTime;
  int isHighlighted;
  int isTitan;
  int isVisible;
  int isReverseCharge;
  float chargeFracAlert;
  float chargeFracAlertSpeed;
  float chargeFracAlertScale;
  float chargeFracCaution;
  float chargeFrac;
  char* hudIcon;
  float useFrac;
  float chargeMaxFrac;
  float minFireFrac;
  int segments;
  int xPos;
  int yPos;
  float readyFrac;
  float dryfireFrac;
  float refillRate;
  float iconSizeScale[2];
  int AbilityMeta__wasPulsing;
  float AbilityMeta__pulseStartTime;
  float AbilityMeta__lastChargeTime;
  BYTE gap_90[128];
};

struct ruiDataStruct_invite_to_network_label
{
  BYTE gap_0[32];
  char* labelText;
  BYTE gap_28[8];
};

struct ruiDataStruct_in_world_minimap_base
{
  BYTE gap_0[24];
  char* mapImage;
  float mapCorner[3];
  float mapScale;
  float displayDist;
  BYTE gap_34[4];
};

struct ruiDataStruct_in_world_minimap_border
{
  BYTE gap_0[48];
  char* basicImage;
  char* logo;
  BYTE gap_40[16];
};

struct ruiDataStruct_in_world_minimap_object
{
  BYTE gap_0[16];
  float displayDist;
  float mapCorner[3];
  float mapScale;
  float objectPos[3];
  float objectAngles[3];
  float iconColor[3];
  char* defaultIcon;
  char* clampedDefaultIcon;
  int objectFlags;
  int customState;
  int useTeamColor;
  int showOnMinimapOnFire;
  float lastFireTime;
  float sonarDetectedFrac;
  BYTE gap_70[32];
};

struct ruiDataStruct_in_world_minimap_player
{
  BYTE gap_0[16];
  float displayDist;
  float mapCorner[3];
  float mapScale;
  float objectPos[3];
  float objectAngles[3];
  float lastFireTime;
  int isLocalPlayer;
  int objectFlags;
  int customState;
  float sonarDetectedFrac;
  float maphackDetectedFrac;
  BYTE gap_54[32];
};

struct ruiDataStruct_ion_energy_bar
{
  BYTE gap_0[36];
  float baseColor[3];
  float energyMax;
  float energy;
  float energyNeededRatio;
  float energyNeededFlashStartTime;
  float criticalHitFlashStartTime;
  BYTE gap_44[36];
};

struct ruiDataStruct_item_details
{
  BYTE gap_0[76];
  float progressFrac;
  char* nameText;
  char* descText;
  char* descTextArg;
  char* unlockText;
  char* progressText;
  int progressVisible;
  int skipDesc;
  BYTE gap_80[48];
};

struct ruiDataStruct_item_details_narrow
{
  BYTE gap_0[48];
  char* nameText;
  char* descText;
  char* unlockText;
  char* progressText;
  int progressVisible;
  int skipDesc;
  float progressFrac;
  BYTE gap_5c[28];
};

struct ruiDataStruct_killdeath_info
{
  BYTE gap_0[36];
  float startTime;
  float updateTime;
  float messageOffsetScale;
  char* messageText;
  int isBigText;
  float duration;
  BYTE gap_40[72];
};

struct ruiDataStruct_kill_replay_overlay
{
  BYTE gap_0[140];
  float startTime;
  char* killerName;
  char* killerLevel;
  int showKillerInfo;
  int showKillerWeaponInfo;
  char* cardImage;
  char* iconImage;
  char* cardGenImage;
  int layoutType;
  float killerHealthFrac;
  char* killerWeaponImage;
  char* killerWeaponName;
  float killerWeaponAspectRatio[2];
  char* killReplayTitleText;
  float CallSignCard__initTime;
  BYTE gap_e8[4];
  float CallSignCard__randFloat;
  BYTE gap_f4[172];
};

struct ruiDataStruct_knb_subject_button
{
  BYTE gap_0[52];
  int isVisible;
  float startTime;
  BYTE gap_38[4];
  int isFocused;
  int isSelected;
  int isNew;
  int showThinBorder;
  char* buttonText;
  BYTE gap_58[56];
};

struct ruiDataStruct_knowledgebase_panel
{
  BYTE gap_0[68];
  float initTime;
  char* headerText;
  char* messageText;
  float startTime;
  float initTimeTrigger;
  float initTimeWallTime;
  BYTE gap_60[4];
  float startTimeTrigger;
  BYTE gap_68[4];
  float startTimeWallTime;
  BYTE gap_74[116];
};

struct ruiDataStruct_knowledgebase_panel_main
{
  BYTE gap_0[52];
  float initTime;
  char* messageText;
  float startTime;
  int isNew;
  float initTimeTrigger;
  float startTimeTrigger;
  float initTimeWallTime;
  BYTE gap_50[4];
  float startTimeWallTime;
  BYTE gap_5c[52];
};

struct ruiDataStruct_kraber_ammo_counter
{
  BYTE gap_0[40];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_38[76];
};

struct ruiDataStruct_large_button
{
  BYTE gap_0[28];
  int isVisible;
  float startTime;
  BYTE gap_20[4];
  int isFocused;
  int isSelected;
  char* buttonText;
  BYTE gap_38[32];
};

struct ruiDataStruct_letter_box
{
  BYTE gap_0[16];
  float hideStartTime;
  BYTE gap_14[12];
};

struct ruiDataStruct_level_up
{
  BYTE gap_0[48];
  char* messageText;
  float startTime;
  float duration;
  float eventColor[3];
  BYTE gap_4c[92];
};

struct ruiDataStruct_loadout_button_large
{
  BYTE gap_0[88];
  char* subText;
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  int isDisabled;
  char* buttonImage;
  int cost;
  int creditsAvailable;
  float numSegments;
  float filledSegments;
  int isFirstTime;
  BYTE gap_90[4];
  float firstWallTime;
  BYTE gap_9c[452];
};

struct ruiDataStruct_loadout_button_medium
{
  BYTE gap_0[60];
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  int isDisabled;
  int cost;
  char* buttonImage;
  int creditsAvailable;
  int isFirstTime;
  float firstWallTime;
  BYTE gap_6c[108];
};

struct ruiDataStruct_loadout_button_small
{
  BYTE gap_0[68];
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  int isDisabled;
  int cost;
  char* buttonImage;
  int creditsAvailable;
  int isFirstTime;
  float firstWallTime;
  BYTE gap_74[108];
};

struct ruiDataStruct_loadout_button_small_no_background
{
  BYTE gap_0[68];
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  int isDisabled;
  int cost;
  char* buttonImage;
  int creditsAvailable;
  int isFirstTime;
  float firstWallTime;
  BYTE gap_74[108];
};

struct ruiDataStruct_loadout_image_large
{
  BYTE gap_0[16];
  char* buttonImage;
  BYTE gap_18[4];
};

struct ruiDataStruct_loadout_image_medium
{
  BYTE gap_0[16];
  char* buttonImage;
  BYTE gap_18[4];
};

struct ruiDataStruct_loadout_label
{
  BYTE gap_0[16];
  char* labelText;
  BYTE gap_18[8];
};

struct ruiDataStruct_loadout_selection_button
{
  BYTE gap_0[72];
  char* buttonText;
  int isVisible;
  int isFocused;
  int isSelected;
  int isLocked;
  int isNew;
  int cost;
  int creditsAvailable;
  int isFirstTime;
  float firstWallTime;
  BYTE gap_74[124];
};

struct ruiDataStruct_loadscreen_detent
{
  BYTE gap_0[32];
  char* detentText;
  float displayTime;
  BYTE gap_2c[20];
};

struct ruiDataStruct_loadscreen_game_mode_info
{
  BYTE gap_0[28];
  float loadscreenAlpha;
  char* bulletPointText1;
  char* bulletPointText2;
  char* bulletPointText3;
  char* bulletPointText4;
  char* bulletPointText5;
  BYTE gap_48[40];
};

struct ruiDataStruct_loadscreen_sp_log
{
  BYTE gap_0[60];
  int isLeft;
  char* spLogLoc;
  char* spLogTitleLoc;
  float loadscreenAlpha;
  BYTE gap_54[60];
};

struct ruiDataStruct_lockon_hud
{
  BYTE gap_0[36];
  int isVisible;
  char* lockMessage;
  float lockEndTime;
  int isSonar;
  int northLock;
  int southLock;
  int westLock;
  int eastLock;
  BYTE gap_48[124];
};

struct ruiDataStruct_lstar_screens
{
  BYTE gap_0[92];
  int clipAmmo;
  int clipSize;
  int lifetimeShots;
  float ammoFrac;
  int isFiring;
  int isCooling;
  int isReloading;
  int isAmped;
  float lastDryFireTime;
  BYTE gap_80[156];
};

struct ruiDataStruct_lstar_screens_rcee
{
  BYTE gap_0[156];
  float lastDryFireTime;
  BYTE gap_a0[68];
};

struct ruiDataStruct_mail_box
{
  BYTE gap_0[20];
  float startTime;
  char* newMessage;
  char* oldMessage;
  int direction;
  float savedGameTime;
  float useStartTime;
  BYTE gap_34[16];
};

struct ruiDataStruct_mainmenu_active_profile
{
  BYTE gap_0[32];
  char* labelText;
};

struct ruiDataStruct_main_menu_install_progress
{
  BYTE gap_0[72];
  float installProgress;
  BYTE gap_4c[60];
};

struct ruiDataStruct_map_select_button
{
  BYTE gap_0[100];
  float mAlpha;
  float specialAlpha;
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  int isDisabled;
  int doubleXP;
  char* itemImage;
  char* title;
  float fadeStartTime;
  float fadeEndTime;
  float targetAlpha;
  int cost;
  int creditsAvailable;
  int specialObjectCount;
  char* specialObjectIcon;
  int bigPresentation;
  int enabledPlaylistCount;
  char* playlistNoteName;
  float playlistNoteBounceTime;
  int playlistNoteBounceUp;
  int isFirstTime;
  float lastFadeStartTime;
  float firstWallTime;
  BYTE gap_d8[4];
  float noteWallTime;
  BYTE gap_e0[4];
  float noteGameTime;
  BYTE gap_ec[148];
};

struct ruiDataStruct_mash_hint_text
{
  BYTE gap_0[28];
  float msgPos[2];
  float msgAlpha;
  int isVisible;
  float msgFontSizeMin;
  float msgColor[4];
  char* msgText;
  float msgFontSizeMax;
  BYTE gap_4c[12];
};

struct ruiDataStruct_mastiff_ammo_counter
{
  BYTE gap_0[56];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_48[80];
};

struct ruiDataStruct_mastiff_horseshoe
{
  BYTE gap_0[32];
  float vis;
  BYTE gap_24[48];
};

struct ruiDataStruct_matchmaking_status
{
  BYTE gap_0[64];
  float backgroundColor[4];
  char* statusText;
  float startTime;
  float timerEndTime;
  int timerHasText;
  int statusHasText;
  int iconVisible;
  int statusVisible;
  int timerVisible;
  int useServerTime;
  float initTime;
  BYTE gap_78[4];
  float lastStartTime;
  BYTE gap_84[36];
};

struct ruiDataStruct_matchmaking_status_big
{
  BYTE gap_0[84];
  int playlistCount;
  char* statusText;
  char* bulletPointText1;
  char* bulletPointText2;
  char* bulletPointText3;
  char* bulletPointText4;
  char* bulletPointText5;
  char* playlistIcon0;
  char* playlistIcon1;
  char* playlistIcon2;
  char* playlistIcon3;
  char* playlistIcon4;
  char* playlistIcon5;
  char* playlistIcon6;
  char* playlistIcon7;
  char* playlistIcon8;
  BYTE gap_d0[120];
};

struct ruiDataStruct_matchmaking_status_compact
{
  BYTE gap_0[64];
  float backgroundColor[4];
  char* statusText;
  float startTime;
  float timerEndTime;
  int timerHasText;
  int statusHasText;
  int iconVisible;
  int statusVisible;
  int timerVisible;
  int useServerTime;
  float initTime;
  BYTE gap_78[4];
  float lastStartTime;
  BYTE gap_84[36];
};

struct ruiDataStruct_medal_award
{
  BYTE gap_0[32];
  float startTime;
  float slottedTime;
  float moveUpStartTime;
  int medalOffset;
  int medalCount;
  BYTE gap_30[4];
  char* medalText;
  char* scoreText;
  char* medalImage;
  BYTE gap_50[32];
};

struct ruiDataStruct_medal_award_alt
{
  BYTE gap_0[32];
  char* scoreText;
  float startTime;
  float slottedTime;
  float moveUpStartTime;
  int medalOffset;
  int medalCount;
  BYTE gap_38[4];
  char* medalText;
  char* medalImage;
  BYTE gap_50[48];
};

struct ruiDataStruct_medal_award_crosshair
{
  BYTE gap_0[36];
  float startTime;
  char* medalText;
  char* scoreText;
  char* medalImage;
  BYTE gap_40[24];
};

struct ruiDataStruct_medal_stat
{
  BYTE gap_0[40];
  char* statValue;
  char* statText;
  char* statImage;
  BYTE gap_40[8];
};

struct ruiDataStruct_medium_button
{
  BYTE gap_0[28];
  int isVisible;
  float startTime;
  BYTE gap_20[4];
  int isFocused;
  int isSelected;
  char* buttonText;
  BYTE gap_38[32];
};

struct ruiDataStruct_menu_button_small
{
  BYTE gap_0[32];
  int isFocused;
  int isSelected;
  int isLocked;
  int isNew;
  char* buttonText;
  BYTE gap_38[60];
};

struct ruiDataStruct_menu_inbox_button
{
  BYTE gap_0[28];
  int isVisible;
  float startTime;
  BYTE gap_20[4];
  int isFocused;
  int isSelected;
  char* buttonText;
  char* labelText;
  BYTE gap_40[32];
};

struct ruiDataStruct_menu_inbox_label
{
  BYTE gap_0[32];
  float startTime;
  BYTE gap_20[4];
  char* labelText;
  BYTE gap_30[8];
};

struct ruiDataStruct_menu_inbox_loot
{
  BYTE gap_0[40];
  int doubleXPCount;
  int coliseumTicketCount;
  BYTE gap_30[40];
};

struct ruiDataStruct_menu_inbox_recent_unlock
{
  BYTE gap_0[36];
  float unlockAlpha;
  float unlockImageRatio[2];
  char* unlockImage;
  char* unlockTitle;
  char* unlockCategory;
  char* unlockParentTitle;
  int unlockImageAtlas;
  BYTE gap_54[36];
};

struct ruiDataStruct_meter_hint
{
  BYTE gap_0[36];
  float ownedFrac;
  float earnedFrac;
  float lastHintUpdateTime;
  float lastBestFrac;
  float lastDisplayedDelta;
  BYTE gap_38[16];
};

struct ruiDataStruct_mfd_target_marker
{
  BYTE gap_0[40];
  float pos[3];
  int teamRelation;
  int playerIsMarked;
  int isMarked;
  float progressFrac;
  int isVisible;
  int pingLocation;
  float pingFrequency;
  char* markedIcon;
  float widget_0__lastActiveChangeTime;
  float widget_0__lastTransitionBasis;
  int widget_0__wasActive;
  BYTE gap_64[68];
};

struct ruiDataStruct_mgl_sights
{
  BYTE gap_0[28];
  float vis;
  BYTE gap_20[32];
};

struct ruiDataStruct_minimap_area
{
  BYTE gap_0[40];
  char* areaImage;
  char* centerImage;
  float playerPos[3];
  float playerAngles[3];
  float displayDist;
  float radiusScale;
  float objectRadius;
  float objectPos[3];
  float objectAngles[3];
  int objectFlags;
  int customState;
  float minimapZoomScale;
  float minimapSizeScale;
  BYTE gap_84[76];
};

struct ruiDataStruct_minimap_base
{
  BYTE gap_0[36];
  float playerPos[3];
  char* mapImage;
  float playerAngles[3];
  float mapCorner[3];
  float mapScale;
  float displayDist;
  float minimapZoomScale;
  float minimapSizeScale;
  BYTE gap_60[40];
};

struct ruiDataStruct_minimap_fw_battery
{
  BYTE gap_0[24];
  float displayDist;
  float playerPos[3];
  float playerAngles[3];
  float objectPos[3];
  float objectAngles[3];
  int batteryCount;
  float batteryCarried;
  int objectFlags;
  int customState;
  int useTeamColor;
  float minimapZoomScale;
  float minimapSizeScale;
  BYTE gap_68[52];
};

struct ruiDataStruct_minimap_fw_build_site
{
  BYTE gap_0[24];
  float displayDist;
  float playerPos[3];
  float playerAngles[3];
  float objectPos[3];
  float objectAngles[3];
  int batteryCount;
  int objectFlags;
  int customState;
  int useTeamColor;
  float minimapZoomScale;
  float minimapSizeScale;
  BYTE gap_64[52];
};

struct ruiDataStruct_minimap_fw_camp
{
  BYTE gap_0[24];
  char* areaImage;
  char* centerImage;
  float playerPos[3];
  float playerAngles[3];
  float displayDist;
  float radiusScale;
  float objectRadius;
  float objectPos[3];
  float objectAngles[3];
  int alertLevel;
  int objectFlags;
  int customState;
  float minimapZoomScale;
  float minimapSizeScale;
  BYTE gap_78[76];
};

struct ruiDataStruct_minimap_indicator
{
  BYTE gap_0[32];
  int indicatorId;
  float minimapZoomScale;
  float minimapSizeScale;
  float lastIndicatorChangeTime;
  int lastIndicatorId;
  BYTE gap_34[52];
};

struct ruiDataStruct_minimap_jammer_layer
{
  BYTE gap_0[28];
  int isFriendly;
  char* layerImage;
  float playerPos[3];
  float playerAngles[3];
  float mapCorner[3];
  float mapScale;
  float displayDist;
  int customState;
  float scriptAlphaVar;
  float startTime;
  float minimapZoomScale;
  float minimapSizeScale;
  BYTE gap_68[56];
};

struct ruiDataStruct_minimap_layer
{
  BYTE gap_0[16];
  float scriptAlphaVar;
  int isFriendly;
  char* layerImage;
  float playerPos[3];
  float playerAngles[3];
  float mapCorner[3];
  float mapScale;
  float displayDist;
  int customState;
  float minimapZoomScale;
  float minimapSizeScale;
  BYTE gap_58[40];
};

struct ruiDataStruct_minimap_mortar_spectre
{
  BYTE gap_0[24];
  float arcPercent;
  float playerPos[3];
  char* bgImage;
  char* centerImage;
  char* clampedImage;
  float playerAngles[3];
  float displayDist;
  float radiusScale;
  float objectPos[3];
  float objectAngles[3];
  int objectFlags;
  int customState;
  float minimapZoomScale;
  float minimapSizeScale;
  int useOverrideColor;
  float overrideColor[4];
  BYTE gap_90[76];
};

struct ruiDataStruct_minimap_object
{
  BYTE gap_0[24];
  float displayDist;
  float playerPos[3];
  float playerAngles[3];
  float objectPos[3];
  float objectAngles[3];
  float iconColor[3];
  char* defaultIcon;
  char* clampedDefaultIcon;
  int objectFlags;
  int customState;
  int useTeamColor;
  int showOnMinimapOnFire;
  int overrideTitanIcon;
  float lastFireTime;
  float sonarDetectedFrac;
  float minimapZoomScale;
  float minimapSizeScale;
  BYTE gap_8c[56];
};

struct ruiDataStruct_minimap_obj_area
{
  BYTE gap_0[24];
  char* areaImage;
  char* centerImage;
  char* clampedImage;
  float playerPos[3];
  float playerAngles[3];
  float displayDist;
  float radiusScale;
  float objectRadius;
  float objectPos[3];
  float objectAngles[3];
  int objectFlags;
  int customState;
  float minimapZoomScale;
  float minimapSizeScale;
  int useOverrideColor;
  float overrideColor[4];
  BYTE gap_90[76];
};

struct ruiDataStruct_minimap_ping
{
  BYTE gap_0[16];
  float objColor[3];
  float playerPos[3];
  char* areaImage;
  char* centerImage;
  char* clampedImage;
  float playerAngles[3];
  float displayDist;
  float radiusScale;
  float objectRadius;
  float objectPos[3];
  float objectAngles[3];
  int objectFlags;
  int customState;
  float minimapZoomScale;
  float minimapSizeScale;
  float startTime;
  float endTime;
  int reverse;
  BYTE gap_8c[28];
};

struct ruiDataStruct_minimap_player
{
  BYTE gap_0[24];
  float displayDist;
  float playerPos[3];
  float playerAngles[3];
  float objectPos[3];
  float objectAngles[3];
  float lastFireTime;
  int objectFlags;
  int customState;
  float sonarDetectedFrac;
  float maphackDetectedFrac;
  float minimapZoomScale;
  float minimapSizeScale;
  BYTE gap_68[40];
};

struct ruiDataStruct_minimap_pve_targetnpc
{
  BYTE gap_0[24];
  float displayDist;
  float playerPos[3];
  float playerAngles[3];
  float objectPos[3];
  float objectAngles[3];
  float iconColor[3];
  char* defaultIcon;
  char* clampedDefaultIcon;
  int objectFlags;
  int customState;
  int useTeamColor;
  int showOnMinimapOnFire;
  float lastFireTime;
  float sonarDetectedFrac;
  float minimapZoomScale;
  float minimapSizeScale;
  BYTE gap_88[56];
};

struct ruiDataStruct_minimap_wedges
{
  BYTE gap_0[64];
  float playerPos[3];
  float playerAngles[3];
  float distances[3];
  float scriptInverseAlphaVar;
  float lastFireTimeCenter;
  float lastFireTimeMid0;
  float lastFireTimeMid1;
  float lastFireTimeMid2;
  float lastFireTimeMid3;
  float lastFireTimeMid4;
  float lastFireTimeMid5;
  float lastFireTimeMid6;
  float lastFireTimeMid7;
  float lastFireTimeOuter0;
  float lastFireTimeOuter1;
  float lastFireTimeOuter2;
  float lastFireTimeOuter3;
  float lastFireTimeOuter4;
  float lastFireTimeOuter5;
  float lastFireTimeOuter6;
  float lastFireTimeOuter7;
  float minimapZoomScale;
  float minimapSizeScale;
  int isVisible;
  BYTE gap_b8[140];
};

struct ruiDataStruct_minimap_you
{
  BYTE gap_0[20];
  float minimapZoomScale;
  float minimapSizeScale;
  int objectFlags;
  int customState;
  BYTE gap_24[4];
};

struct ruiDataStruct_mission_select_button
{
  BYTE gap_0[80];
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  int blueLionCount;
  char* itemImage;
  int blueLionTotal;
  int finishedMaster;
  int showMaster;
  BYTE gap_78[4];
  char* title;
  int isFirstTime;
  BYTE gap_88[4];
  float firstWallTime;
  BYTE gap_94[68];
};

struct ruiDataStruct_mixtape_checklist_button
{
  BYTE gap_0[44];
  int isVisible;
  float startTime;
  BYTE gap_30[4];
  int isFocused;
  int isSelected;
  char* buttonText;
  int isChecked;
  int isLocked;
  char* checkImage;
  BYTE gap_58[80];
};

struct ruiDataStruct_mixtape_checklist_image
{
  BYTE gap_0[28];
  int isVisible;
  char* abbreviation;
  float startTime;
  BYTE gap_28[4];
  int isChecked;
  int isLocked;
  char* checkImage;
  BYTE gap_40[28];
};

struct ruiDataStruct_mixtape_checklist_small_button
{
  BYTE gap_0[36];
  int isVisible;
  float startTime;
  BYTE gap_28[4];
  int isFocused;
  int isSelected;
  int isMuted;
  int isGlowing;
  int isChecked;
  int isLocked;
  char* checkImage;
  char* abbreviation;
  BYTE gap_58[88];
};

struct ruiDataStruct_mk6_ammo_counter
{
  BYTE gap_0[104];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_78[108];
};

struct ruiDataStruct_mobility_ghost_hint
{
  BYTE gap_0[56];
  float startTime;
  float fadeInDuration;
  float stage1Duration;
  float stage2Duration;
  BYTE gap_48[32];
};

struct ruiDataStruct_networkmode_label
{
  BYTE gap_0[32];
  char* labelText;
  BYTE gap_28[8];
};

struct ruiDataStruct_new_bt_loadout_flyout
{
  BYTE gap_0[64];
  float color[3];
  float startTime;
  float duration;
  float pos[3];
  float underlineHeight;
  float underlineWidth;
  char* titleText;
  char* descriptionText;
  int isVisible;
  BYTE gap_7c[60];
};

struct ruiDataStruct_notification_box
{
  BYTE gap_0[16];
  float backgroundColor[4];
  float stripeColor[4];
  BYTE gap_30[8];
};

struct ruiDataStruct_number_stat
{
  BYTE gap_0[40];
  char* valueText;
  char* titleText;
  BYTE gap_38[8];
};

struct ruiDataStruct_obituary_crawl
{
  BYTE gap_0[36];
  float string1Color[3];
  float string2Color[3];
  float startTime;
  float updateTime;
  int offset;
  char* attackerName;
  char* attackerPetName;
  char* attackerLocalizedString;
  char* victimName;
  char* victimPetName;
  char* victimLocalizedString;
  char* weaponLocalizedName;
  char* weaponLocalizedString;
  int hasAttackerPetName;
  int hasVictimPetName;
  float duration;
  BYTE gap_94[44];
};

struct ruiDataStruct_obituary_crawl_earnmeter
{
  BYTE gap_0[44];
  float string1Color[3];
  char* localizedString;
  float string2Color[3];
  float startTime;
  float updateTime;
  int offset;
  char* entityName;
  float duration;
  BYTE gap_64[8];
};

struct ruiDataStruct_obituary_crawl_generic
{
  BYTE gap_0[36];
  float string1Color[3];
  float string2Color[3];
  float startTime;
  float updateTime;
  int offset;
  char* entityName;
  char* localizedString;
  float duration;
  BYTE gap_5c[44];
};

struct ruiDataStruct_obituary_crawl_generic_center
{
  BYTE gap_0[32];
  float string1Color[3];
  float string2Color[3];
  float startTime;
  float updateTime;
  int offset;
  float duration;
  char* entityName;
  char* localizedString;
  BYTE gap_58[40];
};

struct ruiDataStruct_obituary_crawl_localized
{
  BYTE gap_0[40];
  char* obitString;
  float string1Color[3];
  float string2Color[3];
  float string3Color[3];
  float backgroundColor[3];
  float backgroundAlpha;
  float startTime;
  float updateTime;
  int offset;
  float duration;
  BYTE gap_74[64];
};

struct ruiDataStruct_objective_hint
{
  BYTE gap_0[32];
};

struct ruiDataStruct_openinvite_countdown
{
  BYTE gap_0[28];
  float timeLeft;
  float maxTime;
  BYTE gap_24[20];
};

struct ruiDataStruct_openinvite_join_button
{
  BYTE gap_0[32];
  int isFocused;
  BYTE gap_20[4];
  char* buttonText;
  BYTE gap_30[32];
};

struct ruiDataStruct_openinvite_player
{
  BYTE gap_0[24];
  char* playerImage;
  char* basicImage;
  float basicImageColor[3];
  float basicImageAlpha;
  int hasPlayer;
  int isViewPlayer;
  int isEnabled;
  int hadPlayer;
  float startTime;
  BYTE gap_48[4];
  float Spinner__startTime;
  BYTE gap_54[136];
};

struct ruiDataStruct_overhead_icon_ellipse
{
  BYTE gap_0[16];
  float arcPercent;
  float pos[3];
  char* iconBG;
  char* icon;
  int isVisible;
  float iconSize[2];
  int showClampArrow;
  int pinToEdge;
  BYTE gap_44[44];
};

struct ruiDataStruct_overhead_icon_evac
{
  BYTE gap_0[44];
  float pos[3];
  char* icon;
  int isVisible;
  float finishTime;
  char* statusText;
  BYTE gap_50[32];
};

struct ruiDataStruct_overhead_icon_generic
{
  BYTE gap_0[16];
  float pos[3];
  int isVisible;
  char* icon;
  float iconSize[2];
  int showClampArrow;
  int pinToEdge;
  BYTE gap_38[40];
};

struct ruiDataStruct_overhead_icon_objective
{
  BYTE gap_0[16];
  float pos[3];
  int isVisible;
  char* icon;
  float iconSize[2];
  int showClampArrow;
  int pinToEdge;
  float startPos[2];
  float startTime;
  float fadeTime;
  BYTE gap_48[40];
};

struct ruiDataStruct_overhead_icon_pet_titan
{
  BYTE gap_0[16];
  float pos[3];
  int isVisible;
  char* icon;
  int lastClampedState;
  float lastClampedChangeTime;
  BYTE gap_30[16];
};

struct ruiDataStruct_overhead_icon_ping
{
  BYTE gap_0[16];
  float iconColor[3];
  float pos[3];
  char* icon;
  int isVisible;
  float iconSize[2];
  int pinToEdge;
  float startTime;
  float duration;
  float scale;
  float startPos[2];
  float startFlyTime;
  float fadeTime;
  BYTE gap_5c[16];
};

struct ruiDataStruct_p2011_ammo_counter
{
  BYTE gap_0[76];
  int ammo;
  int clipSize;
  int clipCount;
  float readyToFireFrac;
  float chargeFrac;
  int isReloading;
  int isActive;
  int inCooldown;
  float pChargeFrac;
  BYTE gap_70[80];
};

struct ruiDataStruct_p2011_green_sights
{
  BYTE gap_0[16];
  float vis;
  BYTE gap_14[44];
};

struct ruiDataStruct_pathchooser_background
{
  BYTE gap_0[104];
  char* headerText;
  char* promptText0;
  char* promptText1;
  char* promptText2;
  char* promptText3;
  char* promptText4;
  char* promptText5;
  char* banner0;
  char* banner1;
  char* banner2;
  char* banner3;
  char* banner4;
  char* banner5;
  char* iconTextGP0;
  char* iconTextGP1;
  char* iconTextGP2;
  char* iconTextGP3;
  char* iconTextGP4;
  char* iconTextGP5;
  char* iconTextKB0;
  char* iconTextKB1;
  char* iconTextKB2;
  char* iconTextKB3;
  char* iconTextKB4;
  char* iconTextKB5;
  int isLocked0;
  int isLocked1;
  int isLocked2;
  int isLocked3;
  int isLocked4;
  int isLocked5;
  int choiceIndex;
  float initTime;
  float choiceTime;
  float initTimeTrigger;
  float initTimeWallTime;
  BYTE gap_15c[532];
};

struct ruiDataStruct_pilot_overhead
{
  BYTE gap_0[32];
  float healthFrac;
  float pos[3];
  char* playerName;
  float tempOffset[3];
  float friendly;
  float lastVisibleTime;
  int inCrosshairRange;
  BYTE gap_50[84];
};

struct ruiDataStruct_pilot_speedometer
{
  BYTE gap_0[44];
  float startTime;
  int useMetric;
  float playerPos[3];
  float lastPlayerSpeed;
  float lastPlayerPos[3];
  float lastFrameTime;
  float fadeOutStartTime;
  BYTE gap_58[32];
};

struct ruiDataStruct_playlist_button
{
  BYTE gap_0[112];
  float specialAlpha;
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  int isDisabled;
  int doubleXP;
  char* itemImage;
  char* title;
  float fadeStartTime;
  float fadeEndTime;
  float targetAlpha;
  float mAlpha;
  int cost;
  int creditsAvailable;
  int specialObjectCount;
  int bigPresentation;
  char* specialObjectIcon;
  int enabledPlaylistCount;
  float playlistNoteBounceTime;
  char* playlistNoteName;
  int playlistNoteBounceUp;
  int isFirstTime;
  float firstWallTime;
  BYTE gap_e0[4];
  float lastFadeStartTime;
  float noteGameTime;
  float noteWallTime;
  BYTE gap_f4[164];
};

struct ruiDataStruct_postgame_block_display
{
  BYTE gap_0[52];
  float initTime;
  float startTime;
  float endTime;
  float panelColor[4];
  float leaveTime;
  float posOffset;
  int meritType;
  int totalPips;
  int numPips;
  float pipTime;
  float imageRatio[2];
  char* unlockImage;
  char* unlockTitle;
  char* unlockSideText;
  char* unlockTriggers;
  float triggerTime;
  BYTE gap_90[4];
  float initWallTime;
  BYTE gap_9c[64];
};

struct ruiDataStruct_postgame_earned_merit_display
{
  BYTE gap_0[32];
  float heightOffset;
  float initTime;
  float startTime;
  float holdTime;
  float panelColor[4];
  float moveTime;
  float fadeTime;
  int meritCount;
  int posOffset;
  int meritType;
  float endTime;
  int isPVE;
  BYTE gap_58[4];
  float initWallTime;
  BYTE gap_64[36];
};

struct ruiDataStruct_postgame_fd_level_up_display
{
  BYTE gap_0[132];
  float initTime;
  char* newRank;
  float startTime;
  float endTime;
  char* unlockTitle1;
  char* unlockCategory1;
  char* unlockParentTitle1;
  char* unlockImage1;
  float unlockImageRatio1[2];
  int unlockImageLayer1;
  float unlockImageRatio2[2];
  int unlockImageLayer2;
  char* unlockTitle2;
  char* unlockCategory2;
  char* unlockParentTitle2;
  char* unlockImage2;
  char* unlockTitle3;
  char* unlockCategory3;
  char* unlockParentTitle3;
  char* unlockImage3;
  float unlockImageRatio3[2];
  int unlockImageLayer3;
  BYTE gap_118[4];
  float initWallTime;
  BYTE gap_124[192];
};

struct ruiDataStruct_postgame_generic_level_up_display
{
  BYTE gap_0[124];
  float initTime;
  char* newRank;
  char* titleText;
  char* unlockParentTitle1;
  float startTime;
  float endTime;
  char* rankImage;
  float rankImageRatio[2];
  char* unlockTitle1;
  char* unlockCategory1;
  char* unlockImage1;
  float unlockImageRatio1[2];
  int unlockImageLayer1;
  float unlockImageRatio2[2];
  int unlockImageLayer2;
  char* unlockTitle2;
  char* unlockCategory2;
  char* unlockParentTitle2;
  char* unlockImage2;
  char* unlockTitle3;
  char* unlockCategory3;
  char* unlockParentTitle3;
  char* unlockImage3;
  float unlockImageRatio3[2];
  int unlockImageLayer3;
  BYTE gap_128[4];
  float initWallTime;
  BYTE gap_134[180];
};

struct ruiDataStruct_postgame_merit_bar_display
{
  BYTE gap_0[192];
  char* endingLevelString;
  float initTime;
  float startTime;
  float panelColor[4];
  float endTime;
  int totalPips;
  int numPips;
  int currentGen;
  char* startingLevelString;
  int startingLevel;
  int endingLevel;
  char* unlockItem1;
  char* unlockItem2;
  char* unlockItem3;
  int unlockImageLayer;
  int unlockItemOwned;
  char* unlockImage;
  char* unlockTitle;
  char* unlockCategory;
  float earnTime;
  int isPVE;
  int pveCredits;
  int pveCreditsLastMatch;
  int oneToOne;
  float imageRatio[2];
  BYTE gap_14c[4];
  char* summaryTitle;
  char* summarySubTitle;
  float initWallTime;
  BYTE gap_16c[356];
};

struct ruiDataStruct_postgame_player_level_up_display
{
  BYTE gap_0[132];
  float initTime;
  char* newRank;
  float startTime;
  float endTime;
  char* unlockTitle1;
  char* unlockCategory1;
  char* unlockParentTitle1;
  char* unlockImage1;
  float unlockImageRatio1[2];
  int unlockImageLayer1;
  float unlockImageRatio2[2];
  int unlockImageLayer2;
  char* unlockTitle2;
  char* unlockCategory2;
  char* unlockParentTitle2;
  char* unlockImage2;
  char* unlockTitle3;
  char* unlockCategory3;
  char* unlockParentTitle3;
  char* unlockImage3;
  float unlockImageRatio3[2];
  int unlockImageLayer3;
  BYTE gap_118[4];
  float initWallTime;
  BYTE gap_124[188];
};

struct ruiDataStruct_postgame_progression_display
{
  BYTE gap_0[64];
  float initTime;
  float startTime;
  float endTime;
  int lastUnlockedIndex;
  char* progressionTitle;
  char* unlockTitle1;
  char* unlockImage1;
  char* unlockCategory1;
  char* unlockTitle2;
  char* unlockImage2;
  char* unlockCategory2;
  char* unlockTitle3;
  char* unlockImage3;
  char* unlockCategory3;
  char* unlockTitle4;
  char* unlockImage4;
  char* unlockCategory4;
  char* unlockTitle5;
  char* unlockImage5;
  char* unlockCategory5;
  char* unlockTitle6;
  char* unlockImage6;
  char* unlockCategory6;
  char* unlockTitle7;
  char* unlockImage7;
  char* unlockCategory7;
  float initWallTime;
  BYTE gap_104[284];
};

struct ruiDataStruct_postgame_progress_display
{
  BYTE gap_0[8];
  char* progressImage;
  float progressImageWidth;
  float progressImageHeight;
  char* reward1Image;
  float reward1ImageWidth;
  float reward1ImageHeight;
  float barSegments;
};

struct ruiDataStruct_postgame_scoreboard_background
{
  BYTE gap_0[24];
};

struct ruiDataStruct_postgame_scoreboard_column_titles
{
  BYTE gap_0[28];
  int numColumns;
  char* title1;
  char* title2;
  char* title3;
  char* title4;
  BYTE gap_40[32];
};

struct ruiDataStruct_postgame_scoreboard_mode_and_map
{
  BYTE gap_0[24];
  char* mode;
  char* map;
  BYTE gap_28[8];
};

struct ruiDataStruct_postgame_scoreboard_row
{
  BYTE gap_0[28];
  int isVisible;
  char* playerName;
  int isFocused;
  int isEmpty;
  int relationship;
  int numColumns;
  char* playerIcon;
  int playerScore1;
  int playerScore2;
  int playerScore3;
  int playerScore4;
  BYTE gap_50[104];
};

struct ruiDataStruct_postgame_scoreboard_teamdisplay
{
  BYTE gap_0[28];
  int isVisible;
  char* logo;
  int score;
  BYTE gap_2c[12];
};

struct ruiDataStruct_postgame_unlocks_display
{
  BYTE gap_0[64];
  float initTime;
  float startTime;
  float endTime;
  float unlockImageRatio1[2];
  int unlockImageLayer1;
  char* unlockTitle1;
  char* unlockImage1;
  char* unlockCategory1;
  char* unlockTitle2;
  char* unlockImage2;
  float unlockImageRatio2[2];
  int unlockImageLayer2;
  float unlockImageRatio3[2];
  int unlockImageLayer3;
  char* unlockCategory2;
  char* unlockTitle3;
  char* unlockImage3;
  char* unlockCategory3;
  char* unlockTitle4;
  char* unlockImage4;
  float unlockImageRatio4[2];
  int unlockImageLayer4;
  float unlockImageRatio5[2];
  int unlockImageLayer5;
  char* unlockCategory4;
  char* unlockTitle5;
  char* unlockImage5;
  char* unlockCategory5;
  char* unlockTitle6;
  char* unlockImage6;
  float unlockImageRatio6[2];
  int unlockImageLayer6;
  BYTE gap_118[4];
  char* unlockCategory6;
  float initWallTime;
  BYTE gap_12c[252];
};

struct ruiDataStruct_prime_titan_bg
{
  BYTE gap_0[16];
  char* bgImage;
  BYTE gap_18[4];
};

struct ruiDataStruct_prime_titan_description
{
  BYTE gap_0[48];
};

struct ruiDataStruct_pro_screen_panel
{
  BYTE gap_0[52];
  int proValue;
  int proOwnedByPlayer;
  BYTE gap_3c[28];
};

struct ruiDataStruct_pulse_lmg_panel1
{
  BYTE gap_0[60];
  float vis;
  int isInCooldown;
  float readyToFireFrac;
  float chargeFrac;
  int isReloading;
  int inCooldown;
  int isActive;
  float pChargeFrac;
  BYTE gap_5c[148];
};

struct ruiDataStruct_pulse_lmg_panel2
{
  BYTE gap_0[140];
  int ammo;
  int clipSize;
  int clipCount;
  float readyToFireFrac;
  float chargeFrac;
  int isReloading;
  int isActive;
  int isInCooldown;
  float pchargeFrac;
  BYTE gap_b0[168];
};

struct ruiDataStruct_pve_hardpoint_marker
{
  BYTE gap_0[44];
  float pos[3];
  int hardpointId;
  int isActive;
  int hardpointState;
  int isContested;
  float progressFrac;
  int isVisible;
  int isTitan;
  float widget_0__lastActiveChangeTime;
  float widget_0__lastTransitionBasis;
  int widget_0__wasActive;
  BYTE gap_60[80];
};

struct ruiDataStruct_pve_matchcandy_hud
{
  BYTE gap_0[40];
  int matchCandyBase;
  int matchCandy256;
  int lastCandy;
  int lastCandyWasGood;
  float lastTimeGotCandy;
  BYTE gap_3c[28];
};

struct ruiDataStruct_pve_matchchallenge_hud
{
  BYTE gap_0[44];
  int challengeType;
  char* challengeProgress;
  char* challengeText;
  int challengeTarget;
  int matchCandyBase;
  int matchCandy256;
  int lastCandy;
  int lastCandyWasGood;
  float lastTimeGotCandy;
  BYTE gap_58[24];
};

struct ruiDataStruct_pve_tacticals_desc_panel
{
  BYTE gap_0[108];
  int showButtonPress;
  char* descText;
  char* headerText;
  char* promptText;
  int showPromptForPC;
  BYTE gap_88[4];
  char* descIconImage;
  BYTE gap_98[24];
};

struct ruiDataStruct_pve_tacticals_main_button
{
  BYTE gap_0[20];
  int isVisible;
  int isFocused;
  int isSelected;
  int isLocked;
  int hasPurchase;
  int isComplete;
  BYTE gap_28[4];
  char* bannerImage;
  float initTime;
  BYTE gap_38[4];
  float randFloat;
  BYTE gap_44[96];
};

struct ruiDataStruct_pve_tacticals_subbackground_panel
{
  BYTE gap_0[52];
  int isVisible;
  char* headerText;
  char* descText;
  char* promptText;
  int unlockedBits;
  int canBuyBits;
  int isSetComplete;
  BYTE gap_5c[152];
};

struct ruiDataStruct_pve_tacticals_sub_button
{
  BYTE gap_0[20];
  int isVisible;
  int isFocused;
  int isSelected;
  int isLocked;
  int hasPurchase;
  int isSetComplete;
  BYTE gap_28[4];
  char* iconImage;
  float initTime;
  BYTE gap_38[4];
  float randFloat;
  BYTE gap_44[100];
};

struct ruiDataStruct_r101_ammo_counter
{
  BYTE gap_0[56];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_48[124];
};

struct ruiDataStruct_r101_sights
{
  BYTE gap_0[32];
  int ammo;
  int clipSize;
  float vis;
  BYTE gap_2c[80];
};

struct ruiDataStruct_r97_ammo_counter
{
  BYTE gap_0[80];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_60[68];
};

struct ruiDataStruct_r97_reticle
{
  BYTE gap_0[36];
  int ammo;
  int clipSize;
  float vis;
  int clipCount;
  BYTE gap_34[48];
};

struct ruiDataStruct_raid_arming_bomb
{
  BYTE gap_0[44];
  float endTime;
  char* returnFlagText;
  float bombArmingTime;
  BYTE gap_3c[12];
};

struct ruiDataStruct_raid_bomb_icon
{
  BYTE gap_0[40];
  char* bombTimerString;
  char* imageName;
  int isVisible;
  int isBombTimerVisible;
  float endTime;
  float pos[3];
  char* bombSiteHintString;
  char* contestedString;
  float areaRadius;
  float meterAlpha;
  int armed;
  int disarming;
  int contested;
  int teamRelation;
  float timeRemaining;
  float savedProgress;
  float lastZoneChangeTime;
  float lastTransitionBasis;
  int wasInZone;
  BYTE gap_8c[100];
};

struct ruiDataStruct_re45_ammo_counter
{
  BYTE gap_0[60];
  int ammo;
  int clipSize;
  int clipCount;
  float readyToFireFrac;
  float chargeFrac;
  int isReloading;
  int isActive;
  int inCooldown;
  float pChargeFrac;
  float vis;
  BYTE gap_64[68];
};

struct ruiDataStruct_re45_diopter
{
  BYTE gap_0[40];
  float vis;
  BYTE gap_2c[48];
};

struct ruiDataStruct_ready_info
{
  BYTE gap_0[36];
  float startTime;
  char* messageText;
  float duration;
  BYTE gap_30[4];
  char* readyIcon;
  BYTE gap_40[24];
};

struct ruiDataStruct_ready_up_box
{
  BYTE gap_0[32];
  int isVisible;
  int isReady;
  float startTime;
  float endTime;
  int lastIsReady;
  float lastIsReadyChangeTime;
  BYTE gap_38[32];
};

struct ruiDataStruct_red_dot_basic
{
  BYTE gap_0[36];
  int ammo;
  int clipSize;
  float vis;
  int clipCount;
  BYTE gap_34[12];
};

struct ruiDataStruct_reserve_button_small
{
  BYTE gap_0[32];
  int isFocused;
  int isSelected;
  int isLocked;
  int isNew;
  char* buttonText;
  int isPC;
  BYTE gap_3c[36];
};

struct ruiDataStruct_respawn_hint
{
  BYTE gap_0[28];
  int isVisible;
  int isTitanAvailable;
  int isTitanAlive;
  int shouldShowSkipReplay;
  float nextSpawnTime;
  char* titanSpawnAsText;
  BYTE gap_38[48];
};

struct ruiDataStruct_reticle_quads_test
{
  BYTE gap_0[92];
};

struct ruiDataStruct_rodeo_alert
{
  BYTE gap_0[56];
  float windowStartFrac;
  int isTitan;
  char* buttonHint;
  float startTime;
  float startDelay;
  float drainDuration;
  float windowEndFrac;
  float pressTime;
  float enemyPressFrac;
  float pressFrac;
  float totalDuration;
  BYTE gap_68[128];
};

struct ruiDataStruct_rodeo_display
{
  BYTE gap_0[48];
  char* statusText;
  char* playerName;
  float healthFrac;
  float shieldFrac;
  char* pilotGaveBattery;
  char* youGaveBattery;
  float startTime;
  float batteryGivenStartTime;
  char* statusIcon;
  int healthPerSection;
  int maxHealth;
  int isEnemy;
  int isCockpit;
  int isDoomed;
  int isUsingLargeMinimap;
  BYTE gap_80[192];
};

struct ruiDataStruct_rspn101_dmr_ammo_counter
{
  BYTE gap_0[40];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_38[76];
};

struct ruiDataStruct_sa3_ammo_counter
{
  BYTE gap_0[52];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_44[80];
};

struct ruiDataStruct_sa3_crosshair
{
  BYTE gap_0[36];
  float vis;
  BYTE gap_28[28];
};

struct ruiDataStruct_scoreboard_background
{
  BYTE gap_0[24];
  float fadeInStartTime;
  float fadeOutStartTime;
  BYTE gap_20[8];
};

struct ruiDataStruct_scoreboard_footer
{
  BYTE gap_0[24];
  char* footerText;
  float startFadeTime;
  float fadeInStartTime;
  float fadeOutStartTime;
  BYTE gap_2c[4];
};

struct ruiDataStruct_scoreboard_logo
{
  BYTE gap_0[16];
  char* logo;
  float fadeInStartTime;
  float fadeOutStartTime;
  BYTE gap_20[8];
};

struct ruiDataStruct_scoreboard_overlay_at
{
  BYTE gap_0[76];
  float campProgressFrac;
  char* campIdText;
  int campIndex;
  int campIsBoss;
  int campVisible;
  int waveEnemyCount1;
  char* waveEnemyIcon1;
  char* waveEnemyIcon2;
  char* waveEnemyIcon3;
  char* waveEnemyIcon4;
  char* waveEnemyIcon5;
  int waveEnemyCount2;
  int waveEnemyCount3;
  int waveEnemyCount4;
  int waveEnemyCount5;
  BYTE gap_a0[140];
};

struct ruiDataStruct_scoreboard_overlay_legend_at
{
  BYTE gap_0[60];
  float campProgressFrac;
  char* campIdText;
  int campIsBoss;
  int campVisible;
  char* legendIcon1;
  char* legendIcon2;
  char* legendIcon3;
  char* legendIcon4;
  char* legendIcon5;
  char* legendIcon6;
  int legendScore1;
  int legendScore2;
  int legendScore3;
  int legendScore4;
  int legendScore5;
  int legendScore6;
  BYTE gap_98[96];
};

struct ruiDataStruct_scoreboard_ping
{
  BYTE gap_0[24];
  int ping;
  float fadeInStartTime;
  float fadeOutStartTime;
  BYTE gap_24[28];
};

struct ruiDataStruct_scoreboard_ping_fd
{
  BYTE gap_0[24];
  float iconColor[3];
  float startTime;
  float duration;
  float scale;
  BYTE gap_30[8];
};

struct ruiDataStruct_scoreboard_ping_icon
{
  BYTE gap_0[32];
};

struct ruiDataStruct_scoreboard_postmatch_top3
{
  BYTE gap_0[80];
  char* playerName0;
  char* playerRank0;
  char* playerName1;
  char* playerRank1;
  char* playerName2;
  char* playerRank2;
  float gameStartTime;
  int layoutType0;
  char* playerLevel0;
  char* cardImage0;
  char* iconImage0;
  char* cardGenImage0;
  float cardScale0;
  int isFriendly0;
  char* playerLevel1;
  char* cardImage1;
  char* iconImage1;
  char* cardGenImage1;
  int layoutType1;
  float cardScale1;
  int isFriendly1;
  int layoutType2;
  char* playerLevel2;
  char* cardImage2;
  char* iconImage2;
  char* cardGenImage2;
  float cardScale2;
  int isFriendly2;
  float CallSignCard0__initTime;
  BYTE gap_108[4];
  float CallSignCard0__randFloat;
  float CallSignCard1__randFloat;
  float CallSignCard1__initTime;
  BYTE gap_118[4];
  float CallSignCard2__initTime;
  BYTE gap_120[4];
  float CallSignCard2__randFloat;
  BYTE gap_12c[436];
};

struct ruiDataStruct_scoreboard_postmatch_top3_pc
{
  BYTE gap_0[80];
  char* playerName0;
  char* playerRank0;
  char* playerName1;
  char* playerRank1;
  char* playerName2;
  char* playerRank2;
  float gameStartTime;
  int layoutType0;
  char* playerLevel0;
  char* cardImage0;
  char* iconImage0;
  char* cardGenImage0;
  float cardScale0;
  int isFriendly0;
  char* playerLevel1;
  char* cardImage1;
  char* iconImage1;
  char* cardGenImage1;
  int layoutType1;
  float cardScale1;
  int isFriendly1;
  int layoutType2;
  char* playerLevel2;
  char* cardImage2;
  char* iconImage2;
  char* cardGenImage2;
  float cardScale2;
  int isFriendly2;
  float CallSignCard0__initTime;
  BYTE gap_108[4];
  float CallSignCard0__randFloat;
  float CallSignCard1__randFloat;
  float CallSignCard1__initTime;
  BYTE gap_118[4];
  float CallSignCard2__initTime;
  BYTE gap_120[4];
  float CallSignCard2__randFloat;
  BYTE gap_12c[436];
};

struct ruiDataStruct_scoreboard_row_mp
{
  BYTE gap_0[40];
  float bgColor[3];
  float selectedAlpha;
  float textColor[3];
  int playerScore1;
  char* playerName;
  char* playerStatus;
  int playerScore2;
  int playerScore3;
  int playerScore4;
  int playerScore1NumDigits;
  int playerScore2NumDigits;
  int playerScore3NumDigits;
  int playerScore4NumDigits;
  float bgAlpha;
  int numScoreColumns;
  int micState;
  char* playerCard;
  float fadeInStartTime;
  float fadeOutStartTime;
  char* extraIcon0;
  char* extraIcon1;
  char* extraIcon2;
  char* extraIcon3;
  char* extraIcon4;
  char* extraIcon5;
  BYTE gap_c0[120];
};

struct ruiDataStruct_scoreboard_subtitle_mp
{
  BYTE gap_0[28];
  float fadeInStartTime;
  char* desc;
  float fadeOutStartTime;
  BYTE gap_2c[12];
};

struct ruiDataStruct_scoreboard_team_score
{
  BYTE gap_0[24];
  int score;
  float fadeInStartTime;
  float fadeOutStartTime;
  BYTE gap_24[12];
};

struct ruiDataStruct_scoreboard_title_mp
{
  BYTE gap_0[28];
  float fadeInStartTime;
  char* gameType;
  char* mapName;
  float fadeOutStartTime;
  BYTE gap_34[12];
};

struct ruiDataStruct_score_header
{
  BYTE gap_0[48];
  char* playerScore1Header;
  char* playerScore2Header;
  char* playerScore3Header;
  char* playerScore4Header;
  int playerScore1NumDigits;
  int playerScore2NumDigits;
  int playerScore3NumDigits;
  int playerScore4NumDigits;
  int numScoreColumns;
  int winningTeamIsFriendly;
  float fadeInStartTime;
  float fadeOutStartTime;
  BYTE gap_70[128];
};

struct ruiDataStruct_screen_fade
{
  BYTE gap_0[12];
  float fadeColor[3];
  float fadeAlpha;
  BYTE gap_1c[4];
};

struct ruiDataStruct_service_status
{
  BYTE gap_0[40];
  int isVisible;
  BYTE gap_28[4];
  char* messageText;
  BYTE gap_38[16];
};

struct ruiDataStruct_shoulder_navigation_shortcut
{
  BYTE gap_0[24];
  char* labelText;
  BYTE gap_20[8];
};

struct ruiDataStruct_skip_label
{
  BYTE gap_0[16];
  float initTime;
  float startTime;
  float lastInitTime;
  BYTE gap_18[4];
  float initWallTime;
  BYTE gap_24[20];
};

struct ruiDataStruct_skyway_cockpit_temperature
{
  BYTE gap_0[40];
  float msgColor[3];
  float msgFontSize;
  float thicken;
  float msgPos[2];
  float msgAlpha;
  char* msgText;
  char* msgText2;
  char* msgAlign;
  int lineNum;
  int maxLines;
  float lineHoldtime;
  int autoMove;
  int initialized;
  int currentLineNum;
  float startTime;
  BYTE gap_7c[32];
};

struct ruiDataStruct_skyway_injector_screen
{
  BYTE gap_0[60];
  int phaseNum;
  BYTE gap_40[48];
};

struct ruiDataStruct_small_button_important
{
  BYTE gap_0[32];
  float startTime;
  BYTE gap_20[4];
  int isVisible;
  int isFocused;
  int isSelected;
  BYTE gap_30[4];
  char* buttonText;
  BYTE gap_40[40];
};

struct ruiDataStruct_smart_core
{
  BYTE gap_0[44];
  int isLocked;
  char* killCountText;
  char* remainingTime;
  float pos[3];
  float offset[3];
  float unlockedColor[3];
  float lockedColor[3];
  float smartCoreStatus;
  float zoomFrac;
  int hasCloseRangeAmmo;
  BYTE gap_7c[88];
};

struct ruiDataStruct_smr_ammo_counter
{
  BYTE gap_0[12];
  int ammo;
  int clipSize;
  int clipCount;
  BYTE gap_18[20];
};

struct ruiDataStruct_softball_ammo_counter
{
  BYTE gap_0[40];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_38[76];
};

struct ruiDataStruct_spectator_hud
{
  BYTE gap_0[44];
  float startTime;
  float firstPersonSpectateEnabled;
  float shouldShowPlayerSpectatingText;
  char* playerName;
  char* switchViewString;
  float posData[3];
  float roundWinningKillReplayAlpha;
  BYTE gap_58[40];
};

struct ruiDataStruct_speedball_flag_marker
{
  BYTE gap_0[40];
  float pos[3];
  int flagStateFlags;
  int teamRelation;
  int playerIsCarrying;
  int isCarried;
  float progressFrac;
  int isVisible;
  int pingLocation;
  float pingFrequency;
  float lastPos[3];
  float lastPosUpdateTime;
  float widget_0__lastActiveChangeTime;
  float widget_0__lastTransitionBasis;
  int widget_0__wasActive;
  BYTE gap_70[88];
};

struct ruiDataStruct_spitfire_ammo_counter
{
  BYTE gap_0[100];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_74[68];
};

struct ruiDataStruct_spitfire_crosshair
{
  BYTE gap_0[36];
  float vis;
  BYTE gap_28[28];
};

struct ruiDataStruct_spotlight_button_large
{
  BYTE gap_0[36];
  int isFocused;
  char* titleText;
  char* detailsText;
  char* buttonImage;
  int lastFocusState;
  BYTE gap_40[4];
  float focusedStartTime;
  BYTE gap_4c[28];
};

struct ruiDataStruct_spotlight_button_small
{
  BYTE gap_0[28];
  int isFocused;
  char* titleText;
  char* buttonImage;
  char* detailsText;
  int lastFocusState;
  BYTE gap_38[4];
  float focusedStartTime;
  BYTE gap_44[28];
};

struct ruiDataStruct_spotting
{
  BYTE gap_0[16];
  float startTime;
  float pos[3];
  float offset[3];
  float sizeMin;
  float sizeMax;
  BYTE gap_30[4];
  char* spottingImage;
  BYTE gap_40[16];
};

struct ruiDataStruct_sp_blackscreen
{
  BYTE gap_0[16];
  float alpha;
  BYTE gap_14[4];
};

struct ruiDataStruct_sp_boss_intro
{
  BYTE gap_0[24];
  float xAlign;
  float titleAlpha;
  char* portraitImage;
  char* weaponImage;
  char* hintText1;
  char* hintText2;
  char* hintText3;
  char* hintText4;
  char* pilotName;
  char* weaponName;
  char* titanName;
  float bg1Alpha;
  float text1Alpha;
  float image1Alpha;
  float bg2Alpha;
  float text2Alpha;
  float image2Alpha;
  BYTE gap_80[8];
};

struct ruiDataStruct_sp_difficulty_select
{
  BYTE gap_0[48];
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  BYTE gap_40[4];
  char* itemImage;
  char* title;
  int isFirstTime;
  BYTE gap_58[4];
  float firstWallTime;
  BYTE gap_64[52];
};

struct ruiDataStruct_sp_introscreen
{
  BYTE gap_0[60];
  float fadeTime;
  char* messageText;
  char* quoteText;
  char* quoteSource;
  float textFadeTime;
  float textFadeDelay;
  float quoteFadeTime;
  float quoteFadeDelay;
  float bgFadeTime;
  float bgFadeDelay;
  BYTE gap_70[64];
};

struct ruiDataStruct_sp_level_title
{
  BYTE gap_0[76];
  float fadeTime;
  char* txtLine1;
  char* txtLine2;
  char* txtLine3;
  char* devLine;
  float color1[3];
  float startTime;
  BYTE gap_80[48];
};

struct ruiDataStruct_sp_loadout_weapon_image
{
  BYTE gap_0[16];
  char* weaponImage;
  BYTE gap_18[4];
};

struct ruiDataStruct_sp_objective
{
  BYTE gap_0[84];
  float startTime;
  float endTime;
  float pos[3];
  char* objectiveTitleText;
  char* objectiveText;
  float fadeInDuration;
  float fadeOutDuration;
  float blingDuration;
  int showButtonHint;
  int showLine;
  int showMarker;
  float additionalKilometers;
  BYTE gap_94[68];
};

struct ruiDataStruct_sp_onscreen_hint
{
  BYTE gap_0[44];
  float msgPixelHeight;
  float duration;
  int hasLocStringKBM;
  char* locStringGamepad;
  char* locStringKBM;
  char* stringArg1;
  char* stringArg2;
  int weaponFlyoutOnscreen;
  int displayCentered;
  int forceFadeOut;
  int adsFade;
  float startTime;
  float endTime;
  float fadeInEndTime;
  float fadeOutStartTime;
  BYTE gap_78[48];
};

struct ruiDataStruct_start_match_button
{
  BYTE gap_0[32];
  float startTime;
  BYTE gap_20[4];
  int isVisible;
  int isFocused;
  int isSelected;
  BYTE gap_30[4];
  char* buttonText;
  BYTE gap_40[40];
};

struct ruiDataStruct_stats_background
{
  BYTE gap_0[20];
};

struct ruiDataStruct_stats_button
{
  BYTE gap_0[24];
  int isVisible;
  int isFocused;
  int isSelected;
  int isDisabled;
  char* buttonText;
  BYTE gap_30[32];
};

struct ruiDataStruct_stats_line_background
{
  BYTE gap_0[20];
};

struct ruiDataStruct_stats_line_background_bottom
{
  BYTE gap_0[20];
};

struct ruiDataStruct_stats_next_unlock
{
  BYTE gap_0[44];
  float unlockImageSize[2];
  BYTE gap_2c[4];
  char* unlockName;
  char* unlockImage;
  BYTE gap_48[24];
};

struct ruiDataStruct_stat_box_a
{
  BYTE gap_0[40];
  char* statValue;
  char* statText;
  BYTE gap_38[4];
};

struct ruiDataStruct_stat_box_b
{
  BYTE gap_0[40];
  char* statValue;
  char* statText;
  BYTE gap_38[4];
};

struct ruiDataStruct_stat_box_c
{
  BYTE gap_0[40];
  char* statValue;
  char* statText;
  BYTE gap_38[4];
};

struct ruiDataStruct_store_bundle_description
{
  BYTE gap_0[72];
  char* headerText;
  char* primeText;
  char* customizationText;
  char* camoText;
  char* callsignText;
  char* primeImage;
  char* customizationImage;
  char* camoImage;
  char* callsignImage;
  BYTE gap_90[20];
};

struct ruiDataStruct_store_button_bundle
{
  BYTE gap_0[64];
  float fontSize;
  int isVisible;
  char* price;
  int isFocused;
  int isSelected;
  int isLocked;
  int isNew;
  int isComingSoon;
  int isOwned;
  char* buttonText;
  char* primeImage;
  char* focusedImage;
  int priceAvailable;
  int creditsAvailable;
  int isFirstTime;
  BYTE gap_88[4];
  float firstWallTime;
  BYTE gap_94[148];
};

struct ruiDataStruct_store_button_front
{
  BYTE gap_0[72];
  float fontSize;
  int isVisible;
  int isFocused;
  int isSelected;
  int isLocked;
  int isNew;
  int isComingSoon;
  float cornerHeight;
  char* buttonText;
  char* bgImage;
  char* focusedImage;
  char* price;
  int isOwned;
  int creditsAvailable;
  int isFirstTime;
  BYTE gap_90[4];
  float firstWallTime;
  BYTE gap_9c[116];
};

struct ruiDataStruct_store_button_prime
{
  BYTE gap_0[64];
  float fontSize;
  int isVisible;
  char* price;
  int isFocused;
  int isSelected;
  int isLocked;
  int isNew;
  int isComingSoon;
  int isOwned;
  char* buttonText;
  char* primeImage;
  char* focusedImage;
  int priceAvailable;
  int creditsAvailable;
  int isFirstTime;
  BYTE gap_88[4];
  float firstWallTime;
  BYTE gap_94[148];
};

struct ruiDataStruct_store_buy_button
{
  BYTE gap_0[80];
  char* price;
  int isFocused;
  int isSelected;
  int isOwned;
  int priceAvailable;
  int isFirstTime;
  BYTE gap_68[4];
  float firstWallTime;
  BYTE gap_74[104];
};

struct ruiDataStruct_store_callsign_description
{
  BYTE gap_0[48];
};

struct ruiDataStruct_store_camo_description
{
  BYTE gap_0[48];
};

struct ruiDataStruct_store_hidden_titan
{
  BYTE gap_0[24];
  char* titanPreview;
  BYTE gap_20[4];
};

struct ruiDataStruct_store_label
{
  BYTE gap_0[24];
  char* buttonText;
  BYTE gap_20[8];
};

struct ruiDataStruct_store_title
{
  BYTE gap_0[48];
};

struct ruiDataStruct_store_title_bg
{
  BYTE gap_0[48];
};

struct ruiDataStruct_suit_button
{
  BYTE gap_0[68];
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  char* buttonImage;
  int cost;
  int creditsAvailable;
  int isFirstTime;
  BYTE gap_68[4];
  float firstWallTime;
  BYTE gap_74[108];
};

struct ruiDataStruct_super_rodeo_hud
{
  BYTE gap_0[48];
  int batteryCount;
  BYTE gap_34[20];
};

struct ruiDataStruct_tab_button
{
  BYTE gap_0[24];
  int isVisible;
  int isFocused;
  int isSelected;
  BYTE gap_20[4];
  char* buttonText;
  BYTE gap_30[32];
};

struct ruiDataStruct_tab_button_wide
{
  BYTE gap_0[28];
  int isVisible;
  int isFocused;
  int isSelected;
  char* buttonText;
  BYTE gap_30[32];
};

struct ruiDataStruct_targetinfo_cockpit_name
{
  BYTE gap_0[28];
  int tiFlags;
  char* targetTitle;
  float worldPos[3];
  float worldPosEyeDist;
  float lastVisibleTime;
  float lastCrosshairTargetTime;
  char* targetName;
  char* targetBossName;
  char* targetClanName;
  int maxHealth;
  float healthFrac;
  float shieldFrac;
  float damageComboLatestUpdateTime;
  float damageComboStartHealthFrac;
  BYTE gap_6c[16];
};

struct ruiDataStruct_targetinfo_debug
{
  BYTE gap_0[36];
  float healthLossHistory0[3];
  float healthLossHistory1[3];
  float healthLossHistory2[3];
  float healthLossHistory3[3];
  float healthLossHistory4[3];
  int tiFlags;
  float worldPos[3];
  float worldPosEyeDist;
  float lastVisibleTime;
  float lastCrosshairTargetTime;
  int maxHealth;
  char* targetName;
  char* targetTitle;
  char* targetBossName;
  char* targetClanName;
  char* targetIcon;
  float healthFrac;
  float shieldFrac;
  float damageComboLatestUpdateTime;
  float damageComboStartHealthFrac;
  BYTE gap_b8[196];
};

struct ruiDataStruct_targetinfo_megaturret_bounty
{
  BYTE gap_0[84];
  float healthFrac;
  float damageComboStartHealthFrac;
  int tiFlags;
  char* targetTitle;
  float worldPos[3];
  float worldPosEyeDist;
  float lastVisibleTime;
  float lastCrosshairTargetTime;
  char* targetBossName;
  float damageComboLatestUpdateTime;
  BYTE gap_8c[300];
};

struct ruiDataStruct_targetinfo_megaturret_fw
{
  BYTE gap_0[88];
  float healthFrac;
  float damageComboStartHealthFrac;
  char* targetTitle;
  int tiFlags;
  float worldPos[3];
  float worldPosEyeDist;
  float lastVisibleTime;
  float lastCrosshairTargetTime;
  float damageComboLatestUpdateTime;
  char* targetBossName;
  BYTE gap_90[312];
};

struct ruiDataStruct_targetinfo_npc_basic
{
  BYTE gap_0[32];
  char* targetTitle;
  char* targetBossName;
  int tiFlags;
  float worldPos[3];
  float worldPosEyeDist;
  float lastVisibleTime;
  float lastCrosshairTargetTime;
  float healthFrac;
  BYTE gap_50[40];
};

struct ruiDataStruct_targetinfo_npc_hackable
{
  BYTE gap_0[32];
  char* targetTitle;
  char* targetBossName;
  int tiFlags;
  float worldPos[3];
  float worldPosEyeDist;
  float lastVisibleTime;
  float lastCrosshairTargetTime;
  float healthFrac;
  BYTE gap_50[40];
};

struct ruiDataStruct_targetinfo_pilot
{
  BYTE gap_0[40];
  char* targetName;
  char* targetTitle;
  int tiFlags;
  float worldPos[3];
  float worldPosEyeDist;
  float lastVisibleTime;
  float lastCrosshairTargetTime;
  int maxHealth;
  char* targetBossName;
  char* targetClanName;
  float healthFrac;
  float shieldFrac;
  float damageComboLatestUpdateTime;
  float damageComboStartHealthFrac;
  char* targetIcon;
  float healthLossHistory0[3];
  float healthLossHistory1[3];
  float healthLossHistory2[3];
  float healthLossHistory3[3];
  float healthLossHistory4[3];
  BYTE gap_bc[96];
};

struct ruiDataStruct_targetinfo_reaper_bounty
{
  BYTE gap_0[80];
  float healthFrac;
  float damageComboStartHealthFrac;
  char* targetTitle;
  int tiFlags;
  float worldPos[3];
  float worldPosEyeDist;
  float lastVisibleTime;
  float lastCrosshairTargetTime;
  float damageComboLatestUpdateTime;
  char* targetBossName;
  BYTE gap_88[296];
};

struct ruiDataStruct_targetinfo_remote_turret
{
  BYTE gap_0[52];
  int tiFlags;
  char* targetTitle;
  char* targetBossName;
  float worldPos[3];
  float worldPosEyeDist;
  float lastVisibleTime;
  float lastCrosshairTargetTime;
  char* targetName;
  char* targetClanName;
  int maxHealth;
  float healthFrac;
  float shieldFrac;
  float damageComboLatestUpdateTime;
  float damageComboStartHealthFrac;
  BYTE gap_84[80];
};

struct ruiDataStruct_targetinfo_s2s_shipname
{
  BYTE gap_0[28];
  int tiFlags;
  float worldPos[3];
  int isVisible;
  int team;
  BYTE gap_30[4];
  char* titleText;
  float lastVisibleUpdateTime;
  float lastFadeBasis;
  int wasVisible;
  BYTE gap_4c[28];
};

struct ruiDataStruct_targetinfo_soldier_bounty
{
  BYTE gap_0[24];
  char* targetTitle;
  int tiFlags;
  float worldPos[3];
  float worldPosEyeDist;
  float lastVisibleTime;
  float lastCrosshairTargetTime;
  float healthFrac;
  char* targetBossName;
  BYTE gap_48[36];
};

struct ruiDataStruct_targetinfo_spectre_bounty
{
  BYTE gap_0[40];
  char* targetTitle;
  char* targetBossName;
  int tiFlags;
  float worldPos[3];
  float worldPosEyeDist;
  float lastVisibleTime;
  float lastCrosshairTargetTime;
  float healthFrac;
  BYTE gap_58[36];
};

struct ruiDataStruct_targetinfo_stalker_bounty
{
  BYTE gap_0[24];
  char* targetTitle;
  int tiFlags;
  float worldPos[3];
  float worldPosEyeDist;
  float lastVisibleTime;
  float lastCrosshairTargetTime;
  float healthFrac;
  char* targetBossName;
  BYTE gap_48[36];
};

struct ruiDataStruct_targetinfo_titan
{
  BYTE gap_0[40];
  float healthLossHistory0[3];
  float healthLossHistory1[3];
  float healthLossHistory2[3];
  float healthLossHistory3[3];
  float healthLossHistory4[3];
  float shieldFrac;
  int tiFlags;
  float worldPos[3];
  float worldPosEyeDist;
  float lastVisibleTime;
  float lastCrosshairTargetTime;
  int maxHealth;
  char* targetName;
  char* targetTitle;
  char* targetBossName;
  char* targetClanName;
  char* targetIcon;
  float healthFrac;
  float damageComboLatestUpdateTime;
  float damageComboStartHealthFrac;
  BYTE gap_bc[348];
};

struct ruiDataStruct_targetinfo_titan_bounty
{
  BYTE gap_0[36];
  float healthFrac;
  float damageComboStartHealthFrac;
  int tiFlags;
  char* targetTitle;
  float worldPos[3];
  float worldPosEyeDist;
  float lastVisibleTime;
  float lastCrosshairTargetTime;
  char* targetBossName;
  int maxHealth;
  float shieldFrac;
  float damageComboLatestUpdateTime;
  BYTE gap_64[340];
};

struct ruiDataStruct_targetinfo_titan_sp
{
  BYTE gap_0[60];
  float healthLossHistory0[3];
  float healthLossHistory1[3];
  float healthLossHistory2[3];
  float healthLossHistory3[3];
  float healthLossHistory4[3];
  float shieldFrac;
  int tiFlags;
  char* targetTitle;
  float worldPos[3];
  float worldPosEyeDist;
  float lastVisibleTime;
  float lastCrosshairTargetTime;
  char* targetName;
  char* targetBossName;
  char* targetClanName;
  char* targetIcon;
  int maxHealth;
  float healthFrac;
  float damageComboLatestUpdateTime;
  float damageComboStartHealthFrac;
  BYTE gap_d0[356];
};

struct ruiDataStruct_team_money_transfer
{
  BYTE gap_0[32];
  float depositUpdateTime;
  float withdrawUpdateTime;
  float lastDepositTime;
  BYTE gap_28[4];
  float lastWithdrawTime;
  BYTE gap_30[4];
  float lastDepositUpdateTime;
  float lastWithdrawUpdateTime;
  float Deposit1__randomSpeedOffset;
  float Deposit1__randomDelay;
  float Deposit1__randomAttackRange[2];
  float Deposit2__randomSpeedOffset;
  float Deposit2__randomDelay;
  float Deposit2__randomAttackRange[2];
  float Deposit3__randomSpeedOffset;
  float Deposit3__randomDelay;
  float Deposit3__randomAttackRange[2];
  float Deposit4__randomSpeedOffset;
  float Deposit4__randomDelay;
  float Deposit4__randomAttackRange[2];
  float Deposit5__randomSpeedOffset;
  float Deposit5__randomDelay;
  float Deposit5__randomAttackRange[2];
  float Withdraw1__randomSpeedOffset;
  float Withdraw1__randomDelay;
  float Withdraw1__randomAttackRange[2];
  float Withdraw2__randomSpeedOffset;
  float Withdraw2__randomDelay;
  float Withdraw2__randomAttackRange[2];
  float Withdraw3__randomSpeedOffset;
  float Withdraw3__randomDelay;
  float Withdraw3__randomAttackRange[2];
  float Withdraw4__randomSpeedOffset;
  float Withdraw4__randomDelay;
  float Withdraw4__randomAttackRange[2];
  float Withdraw5__randomSpeedOffset;
  float Withdraw5__randomDelay;
  float Withdraw5__randomAttackRange[2];
  BYTE gap_e0[200];
};

struct ruiDataStruct_team_reserve_label
{
  BYTE gap_0[28];
  int creditsAmount;
  char* labelText;
  BYTE gap_28[24];
};

struct ruiDataStruct_team_titan_selection
{
  BYTE gap_0[80];
  float leftTeamScore;
  float rightTeamScore;
  int showOverMenu;
  int showScore;
  int isVisible;
  BYTE gap_64[28];
};

struct ruiDataStruct_team_titan_select_button
{
  BYTE gap_0[60];
  int isVisible;
  int isFocused;
  int isSelected;
  int isNew;
  int isLocked;
  int isDisabled;
  int cost;
  char* buttonImage;
  int creditsAvailable;
  int isFirstTime;
  float firstWallTime;
  BYTE gap_6c[100];
};

struct ruiDataStruct_team_titan_select_ready
{
  BYTE gap_0[56];
  int isReady;
  int timer;
  float startTime;
  BYTE gap_40[4];
  int wasReady;
  BYTE gap_4c[16];
};

struct ruiDataStruct_team_titan_template
{
  BYTE gap_0[36];
  float textColor[3];
  char* playerName;
  char* titanName;
  float baseColor[3];
  int hidden;
  char* titanImage;
  char* kitImage;
  char* kit2Image;
  float xOffset;
  int showOverMenu;
  int isVisible;
  BYTE gap_74[20];
};

struct ruiDataStruct_test_button
{
  BYTE gap_0[32];
  float startTime;
  BYTE gap_20[4];
  int isVisible;
  int isFocused;
  int isSelected;
  int isLocked;
  int showButtonPrompt;
  float textColorOverride[3];
  char* buttonText;
  BYTE gap_50[48];
};

struct ruiDataStruct_tf2_vertical_line
{
  BYTE gap_0[24];
  float basicImageColor[3];
  float basicImageAlpha;
  BYTE gap_28[4];
};

struct ruiDataStruct_titanfall_timer
{
  BYTE gap_0[40];
  float playerPos[3];
  float pos[3];
  float impactTime;
  int isVisible;
  int lastVisibleState;
  float lastVisibleChangeTime;
  BYTE gap_50[24];
};

struct ruiDataStruct_titanfall_timer_world
{
  BYTE gap_0[84];
  float playerPos[3];
  float pos[3];
  float impactTime;
  int isVisible;
  int lastVisibleState;
  float lastVisibleChangeTime;
  BYTE gap_7c[20];
};

struct ruiDataStruct_titan_difficulty_display
{
  BYTE gap_0[12];
  int numPips;
  int numFilledPips;
  BYTE gap_14[24];
};

struct ruiDataStruct_titan_level_display
{
  BYTE gap_0[28];
  int numPips;
  int numFilledPips;
  BYTE gap_24[80];
};

struct ruiDataStruct_titan_level_up
{
  BYTE gap_0[32];
  float startTime;
  BYTE gap_20[4];
  char* levelupText;
  BYTE gap_30[16];
};

struct ruiDataStruct_titan_protocol_text
{
  BYTE gap_0[16];
  char* displayString;
  char* stringArg1;
  char* stringArg2;
  int lineNum;
  float startTime;
  float endTime;
  float fontAdjust;
  float xOffset;
  int shouldDie;
  BYTE gap_40[24];
};

struct ruiDataStruct_titan_protocol_text_center
{
  BYTE gap_0[28];
  float msgColor[3];
  char* displayString;
  int lineNum;
  float startTime;
  float endTime;
  float fontAdjust;
  float xOffset;
  int shouldDie;
  float msgAlpha;
  BYTE gap_4c[28];
};

struct ruiDataStruct_titan_protocol_text_garbled
{
  BYTE gap_0[32];
  float msgColor[3];
  int lineNum;
  char* displayString;
  float startTime;
  float endTime;
  float fontAdjust;
  float xOffset;
  int shouldDie;
  float msgAlpha;
  BYTE gap_50[40];
};

struct ruiDataStruct_titan_xp_added
{
  BYTE gap_0[28];
  float numSegments;
  float filledSegments;
  float startTime;
  char* text;
  BYTE gap_30[336];
};

struct ruiDataStruct_tone_tracker_hud
{
  BYTE gap_0[32];
  float offset[3];
  int count;
  float pos[3];
  float sizeMin;
  float sizeMax;
  int isVisible;
  float startTime;
  float fadeOutStartTime;
  int oldCount;
  float changeStartTime0;
  float changeStartTime1;
  float changeStartTime2;
  BYTE gap_60[64];
};

struct ruiDataStruct_tracker_reticle
{
  BYTE gap_0[52];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_44[36];
};

struct ruiDataStruct_training_install_progress
{
  BYTE gap_0[88];
  float installProgress;
  BYTE gap_5c[60];
};

struct ruiDataStruct_training_simpod_shutdown_screen
{
  BYTE gap_0[64];
  int blinkOn;
  float blinkStartTime;
  float blinkHoldEndTime;
  float blinkEndTime;
  BYTE gap_50[40];
};

struct ruiDataStruct_turret_hud_status
{
  BYTE gap_0[60];
  int index;
  int killCount;
  int isOnline;
  float pulseStartTime;
  float pulseEndTime;
  int wasOnline;
  BYTE gap_54[44];
};

struct ruiDataStruct_turret_kill_tracker
{
  BYTE gap_0[48];
  float pos[3];
  int killCount;
  int isOnline;
  BYTE gap_44[44];
};

struct ruiDataStruct_turret_report
{
  BYTE gap_0[64];
  float bgcolor[3];
  float startTime;
  char* hintText;
  float timeAlive;
  int scoreEarned;
  int killsEarned;
  BYTE gap_64[140];
};

struct ruiDataStruct_twopin_test
{
  BYTE gap_0[112];
  float color[3];
  float alpha;
  float goodcolor[3];
  float badcolor[3];
  BYTE gap_98[28];
};

struct ruiDataStruct_unlock_details
{
  BYTE gap_0[72];
  float progressFrac;
  int skipDesc;
  char* nameText;
  char* descText;
  char* progressText;
  char* unlockText;
  BYTE gap_70[32];
};

struct ruiDataStruct_unlock_req_label
{
  BYTE gap_0[24];
  char* buttonText;
  BYTE gap_20[8];
};

struct ruiDataStruct_variable_zoom_crosshair
{
  BYTE gap_0[68];
  int ammo;
  int clipSize;
  float vis;
  int clipCount;
  BYTE gap_54[20];
};

struct ruiDataStruct_vinson_bar
{
  BYTE gap_0[16];
  int ammo;
  int clipSize;
  float vis;
  BYTE gap_1c[20];
};

struct ruiDataStruct_vinson_sights
{
  BYTE gap_0[32];
  float vis;
  BYTE gap_24[68];
};

struct ruiDataStruct_volt_ammo_counter
{
  BYTE gap_0[56];
  float vis;
  int ammo;
  int clipSize;
  BYTE gap_44[80];
};

struct ruiDataStruct_volt_sights
{
  BYTE gap_0[60];
  int ammo;
  int clipSize;
  float vis;
  BYTE gap_48[52];
};

struct ruiDataStruct_w1128_ammo_counter
{
  BYTE gap_0[56];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_48[80];
};

struct ruiDataStruct_w1128_upper_ammo_counter
{
  BYTE gap_0[16];
  int ammo;
  int clipSize;
  int clipCount;
  float vis;
  BYTE gap_20[24];
};

struct ruiDataStruct_waveform
{
  BYTE gap_0[104];
  float tintColor[3];
  float soundStartTime;
  char* speakerName;
  float soundDuration;
  float fadeOutDuration;
  char* bgImage;
  int hasMugshot;
  int hasConnectingLine;
  float connectingLineOffset[3];
  float connectingLineWorldPos[3];
  float level;
  int intercepting;
  int isMP;
  BYTE gap_bc[76];
};

struct ruiDataStruct_wave_announcement
{
  BYTE gap_0[56];
  float startTime;
  float endTime;
  char* waveTitle;
  int numFilledPips;
  int numPips;
  char* subTitle;
  BYTE gap_58[152];
};

struct ruiDataStruct_weapon_flyout
{
  BYTE gap_0[88];
  float color[3];
  float startTime;
  char* titleText;
  char* descriptionText;
  float duration;
  float pos[3];
  float offset[3];
  float underlineHeight;
  float underlineWidth;
  int numPips;
  char* currentLevel;
  int numFilledPips;
  int showWeaponXP;
  char* mod1;
  char* mod2;
  char* mod3;
  char* mod4;
  BYTE gap_d0[152];
};

struct ruiDataStruct_weapon_level_up
{
  BYTE gap_0[48];
  char* weaponName;
  float startTime;
  int isTitan;
  char* weaponLevelAndGen;
  char* weaponImage;
  BYTE gap_50[72];
};

struct ruiDataStruct_weapon_xp_added
{
  BYTE gap_0[24];
  int isTitan;
  float numSegments;
  float filledSegments;
  float startTime;
  char* text;
  BYTE gap_30[336];
};

struct ruiDataStruct_whats_new
{
  BYTE gap_0[68];
  int isVisible;
  char* line1Text;
  char* line2Text;
  char* line3Text;
  BYTE gap_60[36];
};

struct ruiDataStruct_wide_button
{
  BYTE gap_0[24];
  int isVisible;
  int isFocused;
  int isSelected;
  int isDisabled;
  char* buttonText;
  BYTE gap_30[32];
};

struct ruiDataStruct_wilds_battery_tracker
{
  BYTE gap_0[28];
  float startTime;
  float alpha;
  float pos[3];
  float targetValue;
  float capValue;
  float decryptDuration;
  float fadeOutStart;
  int shouldDie;
  BYTE gap_44[76];
};

struct ruiDataStruct_wilds_title_letterbox
{
  BYTE gap_0[20];
};

struct ruiDataStruct_wilds_title_screen
{
  BYTE gap_0[20];
  float startTitleTime;
  float startFadeTime;
  float showRespawn;
  float hideRespawn;
  float showTitanfall;
  float hideTitanfall;
  BYTE gap_2c[32];
};

struct ruiDataStruct_zipline_flyout
{
  BYTE gap_0[56];
  float usePos[3];
  BYTE gap_44[24];
};
```