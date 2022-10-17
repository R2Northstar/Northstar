#pragma once

// use the R2 namespace for game funxcs
namespace R2
{
	enum class HostState_t
	{
		HS_NEW_GAME = 0,
		HS_LOAD_GAME,
		HS_CHANGE_LEVEL_SP,
		HS_CHANGE_LEVEL_MP,
		HS_RUN,
		HS_GAME_SHUTDOWN,
		HS_SHUTDOWN,
		HS_RESTART,
	};

	struct CHostState
	{
	  public:
		HostState_t m_iCurrentState;
		HostState_t m_iNextState;

		float m_vecLocation[3];
		float m_angLocation[3];

		char m_levelName[32];
		char m_mapGroupName[32];
		char m_landmarkName[32];
		char m_saveName[32];
		float m_flShortFrameTime; // run a few one-tick frames to avoid large timesteps while loading assets

		bool m_activeGame;
		bool m_bRememberLocation;
		bool m_bBackgroundLevel;
		bool m_bWaitingForConnection;
		bool m_bLetToolsOverrideLoadGameEnts; // During a load game, this tells Foundry to override ents that are selected in Hammer.
		bool m_bSplitScreenConnect;
		bool m_bGameHasShutDownAndFlushedMemory; // This is false once we load a map into memory, and set to true once the map is unloaded
												 // and all memory flushed
		bool m_bWorkshopMapDownloadPending;
	};

	extern CHostState* g_pHostState;
} // namespace R2
