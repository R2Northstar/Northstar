#![deny(non_snake_case)]

use rrplug::prelude::*;
use rrplug::{
    bindings::squirrelclasstypes::ScriptContext,
    call_sq_function,
    high::{squirrel::compile_string, UnsafeHandle},
};
use std::{
    ops::DerefMut,
    time::{SystemTime, UNIX_EPOCH},
};

use crate::presense_bindings::{GameState, GameStateStruct, UIPresenceStruct};

// heartbeat for pulling presence
pub fn run_presence_updates(sqvm: UnsafeHandle<*mut HSquirrelVM>) {
    let sqvm = *sqvm.get();
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

/// function to pull presence from the sqvm since in runframe it's impossibke to get the output of a function back
#[rrplug::sqfunction(VM = "UI | CLIENT", ExportName = "FetchPresence")]
pub fn fetch_presence() -> Result<(), String> {
    let plugin = crate::PLUGIN.wait();
    let mut presence_lock = plugin.presence_data.lock();
    let (cl_presence, ui_presence) = presence_lock.deref_mut();
    let sqvm = unsafe { sqvm.as_mut().ok_or_else(|| "None sqvm".to_string())? };
    let context = unsafe {
        std::mem::transmute::<_, ScriptContext>(
            sqvm.sharedState
                .as_ref()
                .ok_or_else(|| "None shared state".to_string())?
                .cSquirrelVM
                .as_ref()
                .ok_or_else(|| "None csqvm".to_string())?
                .vmContext,
        )
    };

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
                *cl_presence = GameStateStruct::get_from_sqvm(
                    sqvm,
                    SQFUNCTIONS.client.wait(),
                    sqvm._stackbase,
                );
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
                    *ui_presence = UIPresenceStruct::get_from_sqvm(
                        sqvm,
                        SQFUNCTIONS.client.wait(),
                        sqvm._stackbase,
                    );
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
            activity.party = None;
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
            activity.details = map_displayname.clone();
            activity.state = map_displayname.clone();
            activity.large_image = Some(cl_presence.map.clone());
            activity.large_text = Some(map_displayname);
            activity.small_image = Some("northstar".to_string());
            activity.small_text = Some("Titanfall 2 + Northstar".to_string());
            if cl_presence.playlist == "campaign" {
                activity.party = None;
                activity.end = None;
            } else {
                activity.state = cl_presence.playlist_displayname.clone();
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
        }
    };
}
