use std::{
    sync::Mutex,
    time::{SystemTime, UNIX_EPOCH},
};

use discord_sdk::{
    activity::{ActivityBuilder, Assets},
    user::User,
    wheel::UserState,
    wheel::Wheel,
    Discord, DiscordApp, Subscriptions,
};
use rrplug::prelude::*;
use rrplug::wrappers::presence::{GamePresence, GameStateEnum};
use tokio::runtime::Runtime;

/// the discord app's id, taken from older v1 discord rpc
const APP_ID: i64 = 941428101429231617;

#[derive(Debug, Default, Clone)]
struct ActivityData {
    party: (u32, u32),
    details: String,
    state: String,
    large_image: Option<String>,
    large_text: Option<String>,
    small_image: Option<String>,
    small_text: Option<String>,
    end: i64,
    start: i64,
}

pub struct Client {
    pub discord: Discord,
    pub user: User,
    pub wheel: Wheel,
}

#[derive(Debug)]
struct DiscordRpc {
    activity: Option<Mutex<ActivityData>>,
}

impl Plugin for DiscordRpc {
    fn new() -> Self {
        Self { activity: None }
    }

    fn initialize(&mut self, _: &PluginData) {
        self.activity = Some(Mutex::new(ActivityData {
            large_image: Some("northstar".to_string()),
            state: "Loading...".to_string(),
            ..Default::default()
        }));
    }

    fn main(&self) {
        let runtime = match Runtime::new() {
            Ok(rt) => rt,
            Err(err) => {
                log::error!("failed to create a runtime; {:?}", err);
                return;
            }
        };
        runtime.block_on(async_main());
    }
    
    /// receives presence updates here
    fn on_presence_updated(&self, presence: &GamePresence) {
        let mut activity = match self.activity.as_ref().unwrap().try_lock() {
            Ok(a) => a,
            Err(_) => return,
        };

        match presence.get_state().unwrap() {
            GameStateEnum::InGame => {}
            _ => {
                let start = SystemTime::now();
                let since_the_epoch = start.duration_since(UNIX_EPOCH).unwrap(); // there is no way this fails
                activity.start = since_the_epoch.as_secs() as i64;
            }
        };

        match presence.get_state().unwrap() {
            GameStateEnum::Loading => {
                activity.party = (0, 0);
                activity.details = "".to_string();
                activity.state = "Loading...".to_string();
                activity.large_image = Some("northstar".to_string());
                activity.large_text = Some("Titanfall 2 + Northstar".to_string());
            }
            GameStateEnum::MainMenu => {
                activity.party = (0, 0);
                activity.details = "Main Menu".to_string();
                activity.state = "On Main Menu".to_string();
                activity.large_image = Some("northstar".to_string());
                activity.large_text = Some("Titanfall 2 + Northstar".to_string());
            }
            GameStateEnum::Lobby => {
                activity.party = (0, 0);
                activity.details = "Lobby".to_string();
                activity.state = "In the Lobby".to_string();
                activity.large_image = Some("northstar".to_string());
                activity.large_text = Some("Titanfall 2 + Northstar".to_string());
            }
            GameStateEnum::InGame => {
                let map_displayname = presence.get_map_displayname();

                activity.party = (
                    presence
                        .get_current_players()
                        .try_into()
                        .unwrap_or_default(),
                    presence.get_max_players().try_into().unwrap_or_default(),
                );
                activity.details = map_displayname.clone();
                activity.state = map_displayname.clone();
                activity.large_image = Some(presence.get_map());
                activity.large_text = Some(map_displayname);
                activity.small_image = Some("northstar".to_string());
                activity.small_text = Some("Titanfall 2 + Northstar".to_string());
                if presence.get_playlist() == "campaign" {
                    activity.party = (0, 0);
                    activity.end = 0;
                } else {
                    activity.state = presence.get_playlist_displayname();
                    activity.details = format!(
                        "Score: {} - {} (First to {})",
                        presence.get_own_score(),
                        presence.get_other_highest_score(),
                        presence.get_max_score()
                    );

                    let current_time = SystemTime::now()
                        .duration_since(UNIX_EPOCH)
                        .unwrap_or_default()
                        .as_secs() as i64;
                    let ig_end = presence.get_timestamp_end() as i64;
                    activity.end = current_time + ig_end;
                }
            }
        };
    }
}

entry!(DiscordRpc);

async fn async_main() {
    let activity = PLUGIN.wait().activity.as_ref().unwrap();

    let client = match make_client(Subscriptions::ACTIVITY).await {
        Ok(c) => c,
        Err(_) => {
            log::error!("Is your discord running?");
            return;
        }
    };

    match client.discord.clear_activity().await {
        Ok(_) => log::info!("cleared activity"),
        Err(err) => log::error!("coudln't clear activity because of {:?}", err),
    }

    loop {
        let data = activity.lock().unwrap().clone();
        
        // updates presence here
        if let Err(err) = client
            .discord
            .update_activity(
                ActivityBuilder::default()
                    .details(data.details)
                    .state(data.state)
                    .assets(Assets {
                        large_image: data.large_image,
                        large_text: data.large_text,
                        small_image: data.small_image,
                        small_text: data.small_text,
                    })
                    .start_timestamp(if data.start == 0 { 1 } else { data.start })
                    .end_timestamp(data.end),
            )
            .await
        {
            log::info!("failed to updated discord activity; {err}");
            #[cfg(not(debug_assertions))]
            return;
        }

        wait(1000);
    }
}

/// discord connection init sourced from https://github.com/EmbarkStudios/discord-sdk/blob/d311db749b7e11cc55cb1a9d7bfd9a95cfe61fd1/examples-shared/src/lib.rs#L16
pub async fn make_client(subs: Subscriptions) -> Result<Client, ()> {
    let (wheel, handler) = Wheel::new(Box::new(|err| {
        log::warn!("encountered an error {err:?}; shouldn't be fatal");
    }));

    let mut user = wheel.user();

    let discord = match Discord::new(DiscordApp::PlainId(APP_ID), subs, Box::new(handler)) {
        Ok(d) => d,
        Err(_) => {
            log::error!("unable to create discord client");
            Err(())?
        }
    };

    log::info!("waiting for handshake...");
    user.0.changed().await.unwrap();

    let user = match &*user.0.borrow() {
        UserState::Connected(user) => user.clone(),
        UserState::Disconnected(err) => {
            log::error!("failed to connect to Discord: {}", err);
            Err(())?
        }
    };

    log::info!("connected to Discord, local user is {:#?}", user);

    Ok(Client {
        discord,
        user,
        wheel,
    })
}
