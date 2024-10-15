#![deny(non_snake_case)]

use rrplug::mid::squirrel::sqvm_to_context;
use rrplug::prelude::*;
use rrplug::{
    bindings::squirrelclasstypes::ScriptContext, call_sq_function, high::squirrel::compile_string,
};
use std::ptr::NonNull;
use std::{
    ops::DerefMut,
    time::{SystemTime, UNIX_EPOCH},
};

use crate::presense_bindings::{GameState, GameStateStruct, SVGameState, UIPresenceStruct};

// heartbeat for pulling presence
pub fn run_presence_updates(sqvm: NonNull<HSquirrelVM>) {
    let sq_functions = SQFUNCTIONS.client.wait();

    if let Err(err) = compile_string(
        sqvm,
        sq_functions,
        true,
        r#"
    thread void function() {
        wait 1
        for(;;) {
            FetchPresence()
            wait 1
        }
    }()
    "#,
    ) {
        err.log()
    };
}

// "Localize_001" is a thing

/// function to pull presence from the sqvm since in runframe it's impossibke to get the output of a function back
#[rrplug::sqfunction(VM = "UI | CLIENT", ExportName = "FetchPresence")]
pub fn fetch_presence() -> Result<(), String> {
    let plugin = crate::PLUGIN.wait();
    let mut presence_lock = plugin.presence_data.lock();
    let (cl_presence, ui_presence) = presence_lock.deref_mut();
    let context = unsafe { sqvm_to_context(sqvm) };

    match context {
        ScriptContext::CLIENT => {
            if let Err(err) = call_sq_function!(
                sqvm,
                sq_functions,
                "DiscordRPC_GenerateGameState",
                cl_presence.clone()
            ) {
                #[cfg(debug_assertions)]
                log::warn!("DiscordRPC_GenerateGameState call failed : {err}");
                #[cfg(not(debug_assertions))]
                drop(err);
            } else {
                *cl_presence =
                    GameStateStruct::get_from_sqvm(sqvm, SQFUNCTIONS.client.wait(), unsafe {
                        sqvm.as_ref()._stackbase
                    });
            }
        }
        ScriptContext::UI => {
            match call_sq_function!(
                sqvm,
                sq_functions,
                "DiscordRPC_GenerateUIPresence",
                ui_presence.clone()
            ) {
                Err(err) => {
                    #[cfg(debug_assertions)]
                    log::warn!("DiscordRPC_GenerateUIPresence call failed : {err}");
                    #[cfg(not(debug_assertions))]
                    drop(err);
                }
                Ok(_) => {
                    *ui_presence =
                        UIPresenceStruct::get_from_sqvm(sqvm, SQFUNCTIONS.client.wait(), unsafe {
                            sqvm.as_ref()._stackbase
                        });
                }
            }
        }
        _ => {}
    }

    on_presence_updated(plugin, cl_presence, ui_presence);

    Ok(())
}

/// receives presence updates here
fn on_presence_updated(
    plugin: &crate::DiscordRpcPlugin,
    cl_presence: &GameStateStruct,
    ui_presence: &UIPresenceStruct,
) {
    let mut activity = plugin.activity.lock();

    if activity.last_state != ui_presence.game_state {
        activity.start = Some(
            SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .unwrap_or_default()
                .as_secs() as i64,
        );
        activity.last_state = ui_presence.game_state;
    }

    match ui_presence.game_state {
        GameState::Loading => {
            activity.party = None;
            activity.details = "".to_string();
            activity.state = "Loading...".to_string();
            activity.large_image = Some("northstar".to_string());
            activity.large_text = Some("Titanfall 2 + Northstar".to_string());
            activity.end = None;
        }
        GameState::MainMenu => {
            activity.party = None;
            activity.details = "Main Menu".to_string();
            activity.state = "On Main Menu".to_string();
            activity.large_image = Some("northstar".to_string());
            activity.large_text = Some("Titanfall 2 + Northstar".to_string());
            activity.end = None;
        }
        GameState::Lobby => {
            activity.party = Some((
                cl_presence.current_players.try_into().unwrap_or_default(),
                cl_presence.max_players.try_into().unwrap_or_default(),
            ));
            activity.details = "Lobby".to_string();
            activity.state = "In the Lobby".to_string();
            activity.large_image = Some("northstar".to_string());
            activity.large_text = Some("Titanfall 2 + Northstar".to_string());
            activity.end = None;
        }
        GameState::InGame => {
            let map_displayname = cl_presence.map_displayname.clone();

            activity.party = Some((
                cl_presence.current_players.try_into().unwrap_or_default(),
                cl_presence.max_players.try_into().unwrap_or_default(),
            ));
            map_displayname.clone_into(&mut activity.details);
            map_displayname.clone_into(&mut activity.state);
            activity.large_image = Some(cl_presence.map.clone());
            activity.large_text = Some(map_displayname);
            activity.small_image = Some("northstar".to_string());
            activity.small_text = Some("Titanfall 2 + Northstar".to_string());
            if cl_presence.playlist == "campaign" {
                activity.party = None;
                activity.end = None;
            } else if cl_presence.playlist == "fd" {
                cl_presence
                    .playlist_displayname
                    .clone_into(&mut activity.state);
                if cl_presence.fd_wavenumber == -1 {
                    activity.details = "On Wave Break".to_string();
                } else {
                    activity.details = format!(
                        "Wave: {} of {}",
                        cl_presence.fd_wavenumber, cl_presence.fd_totalwaves
                    );
                }
            } else {
                cl_presence
                    .playlist_displayname
                    .clone_into(&mut activity.state);
                activity.details = format!(
                    "Score: {} - {} (First to {})",
                    cl_presence.own_score, cl_presence.other_highest_score, cl_presence.max_score,
                );

                if activity.end.is_none() {
                    let current_time = SystemTime::now()
                        .duration_since(UNIX_EPOCH)
                        .unwrap_or_default()
                        .as_secs() as i64;
                    let ig_end = cl_presence.time_end.ceil() as i64;
                    activity.end = Some(current_time + ig_end);
                }
            }
            // This will override previous details established whenever server is not in the Playing gamestate, so friends can see at which stage a match currently is
            if cl_presence.servergamestate != SVGameState::Playing {
                activity.details = match cl_presence.servergamestate {
                    SVGameState::WaitingForPlayers => "Waiting Players to Load",
                    SVGameState::PickLoadout => "Titan Selection",
                    SVGameState::Prematch => "Match Starting",
                    SVGameState::SuddenDeath => "In Sudden Death",
                    SVGameState::SwitchingSides => "Switching Sides",
                    SVGameState::WinnerDetermined => "Winner Determined",
                    SVGameState::Epilogue => "In Epilogue",
                    SVGameState::Postmatch => "Match Ending",
                    _ => "",
                }
                .to_string();
            }
        }
    };
}
