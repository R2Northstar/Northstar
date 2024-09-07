#![deny(non_snake_case)]

use std::num::NonZeroU32;

use discord_sdk::{
    activity::{events::ActivityEvent, ActivityBuilder, Assets, JoinRequestReply, PartyPrivacy},
    user::User,
    wheel::UserState,
    wheel::Wheel,
    Discord, DiscordApp, Subscriptions,
};
use rrplug::{mid::utils::try_cstring, prelude::*};
use tokio::sync::broadcast::Receiver;

use crate::{exports::PLUGIN, invite_handler::JOIN_HANDLER_FUNCTION};

/// the discord app's id, taken from older v1 discord rpc
const APP_ID: i64 = 941428101429231617;

/// struct to hold everything required to run discord rpc
#[allow(dead_code)]
pub struct Client {
    pub discord: Discord,
    pub user: User,
    pub wheel: Wheel,
}

/// discord rpc update function
///
///  doesn't run on the titanfall 2 thread since it needs async
pub async fn async_main() {
    let activity = &PLUGIN.wait().activity;

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

    let mut events = client.wheel.activity().0;

    loop {
        let data = activity.lock().clone();

        if let Some(img) = &data.large_image {
            if img.is_empty() {
                log::warn!("img is empty at {:?}", data.last_state);
            }
        }

        let mut activity_builder = ActivityBuilder::default()
            .details(data.details)
            .state(data.state)
            .assets(Assets {
                large_image: data.large_image,
                large_text: data.large_text,
                small_image: data.small_image,
                small_text: data.small_text,
            })
            .secrets(data.secrets);

        if let Some(start) = data.start {
            activity_builder = activity_builder.start_timestamp(if start == 0 { 1 } else { start });
        }
        if let Some(end) = data.end {
            activity_builder = activity_builder.end_timestamp(end);
        }
        if let Some(party) = data.party {
            activity_builder = activity_builder.party(
                "whar",
                Some(party.0.try_into().unwrap_or(NonZeroU32::new(1).unwrap())),
                Some(party.1.try_into().unwrap_or(NonZeroU32::new(1).unwrap())),
                PartyPrivacy::Private,
            );
        }

        // updates presence here
        if let Err(err) = client.discord.update_activity(activity_builder).await {
            log::info!("failed to updated discord activity; {err}");
            #[cfg(not(debug_assertions))]
            return;
        }

        handle_activity_events(&mut events, &client.discord).await;

        wait(1000);
    }
}

async fn handle_activity_events(
    events: &mut Receiver<ActivityEvent>,
    discord: &Discord,
) -> Option<()> {
    match events.try_recv().ok()? {
        ActivityEvent::Join(join) => {
            log::info!("invite proccessing");
            let secret = try_cstring(&join.secret).expect("I like null bytes in my strings cool");
            JOIN_HANDLER_FUNCTION.lock()(secret.as_ptr())
        }
        ActivityEvent::Spectate(_) => log::warn!("spectating cannot be supported!"),
        ActivityEvent::JoinRequest(request) => {
            log::info!("{} joined the party", request.user.username);
            _ = discord
                .send_join_request_reply(request.user.id, JoinRequestReply::Yes)
                .await;
        }
        _ => {}
    }

    None
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

    #[cfg(debug_assertions)]
    log::info!("connected to Discord, local user is {:#?}", user);

    Ok(Client {
        discord,
        user,
        wheel,
    })
}
