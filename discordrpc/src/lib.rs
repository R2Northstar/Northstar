#![allow(non_snake_case)]

use discord_sdk::activity::Secrets;
use parking_lot::Mutex;
use rrplug::prelude::*;
use rrplug::{bindings::plugin_abi::PluginColor, interfaces::manager::register_interface};
use tokio::runtime::Runtime;

use crate::{
    discord::async_main,
    invite_handler::InviteHandler,
    presence::run_presence_updates,
    presense_bindings::{GameState, GameStateStruct, UIPresenceStruct},
};

pub(crate) mod discord;
pub(crate) mod invite_handler;
pub(crate) mod presence;
pub(crate) mod presense_bindings;

#[deny(non_snake_case)]
#[derive(Debug, Default, Clone)]
#[doc = "struct for all the possible information on the rpc"]
pub struct ActivityData {
    party: Option<(u32, u32)>,
    details: String,
    state: String,
    large_image: Option<String>,
    large_text: Option<String>,
    small_image: Option<String>,
    small_text: Option<String>,
    end: Option<i64>,
    start: Option<i64>,
    last_state: GameState,
    secrets: Secrets,
}

#[deny(non_snake_case)]
pub struct DiscordRpcPlugin {
    pub activity: Mutex<ActivityData>,
    pub presence_data: Mutex<(GameStateStruct, UIPresenceStruct)>,
}

#[deny(non_snake_case)]
impl Plugin for DiscordRpcPlugin {
    const PLUGIN_INFO: PluginInfo = PluginInfo::new_with_color(
        c"DISCORDRPC",
        c"DSCRD-RPC",
        c"DISCORDRPC",
        PluginContext::CLIENT,
        PluginColor {
            red: 114,
            green: 137,
            blue: 218,
        },
    );

    fn new(_: bool) -> Self {
        register_sq_functions(presence::fetch_presence);

        unsafe { register_interface("InviteHandler001", InviteHandler::new()) };

        let activity = Mutex::new(ActivityData {
            large_image: Some("northstar".to_string()),
            state: "Loading...".to_string(),
            ..Default::default()
        });

        std::thread::spawn(|| match Runtime::new() {
            Ok(rt) => rt.block_on(async_main()),
            Err(err) => {
                log::error!("failed to create a runtime; {:?}", err);
            }
        });

        Self {
            activity,
            presence_data: Mutex::new((GameStateStruct::default(), UIPresenceStruct::default())),
        }
    }

    fn on_sqvm_created(&self, sqvm_handle: &CSquirrelVMHandle, _: EngineToken) {
        match sqvm_handle.get_context() {
            ScriptContext::CLIENT | ScriptContext::UI => {
                run_presence_updates(unsafe { sqvm_handle.get_sqvm().take() })
            }
            _ => {}
        }
    }
}

entry!(DiscordRpcPlugin);
