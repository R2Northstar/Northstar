#![feature(if_let_guard)]
use std::{fs, path::PathBuf};

use rrplug::{bindings::plugin_abi::PluginColor, prelude::*};

mod sqapi;
mod utils;

pub struct SerializedIO {
    file_dir: PathBuf,
}

impl Plugin for SerializedIO {
    const PLUGIN_INFO: PluginInfo = PluginInfo::new_with_color(
        c"serialized_iO",
        c"SERIAL_IO",
        c"SERIALIZEDIO",
        PluginContext::all(),
        PluginColor {
            red: 183,
            green: 65,
            blue: 14,
        },
    );

    fn new(_reloaded: bool) -> Self {
        sqapi::register_api_functions();

        let file_dir = PathBuf::from(
            std::env::args()
                .find(|arg| arg.starts_with("-profile"))
                .and_then(|profile| {
                    profile
                        .split_once('=')
                        .map(|(_, profile)| profile.to_string())
                })
                .unwrap_or_else(|| "R2Northstar".to_string()),
        )
        .join("runtime")
        .join("serilized_io");

        _ = fs::create_dir_all(&file_dir);

        Self { file_dir }
    }

    fn on_dll_load(
        &self,
        _engine_data: Option<&EngineData>,
        _dll_ptr: &DLLPointer,
        _engine_token: EngineToken,
    ) {
    }

    fn on_reload_request(&self) -> reloading::ReloadResponse {
        unsafe { reloading::ReloadResponse::allow_reload() }
    }
}

entry!(SerializedIO);
