use rrplug::prelude::*;
use std::{path::PathBuf, sync::OnceLock};

pub static NS_DIR: OnceLock<PathBuf> = OnceLock::new();

pub struct Ranim;

mod bindings;
mod recording_impl;

mod sqapi;

impl Plugin for Ranim {
    const PLUGIN_INFO: PluginInfo =
        PluginInfo::new(c"ranim", c"RAINANIM0", c"RANIM", PluginContext::all());

    fn new(_reloaded: bool) -> Self {
        sqapi::register_sq_function();

        let profile = std::env::args()
            .find(|arg| arg.starts_with("-profile"))
            .and_then(|profile| {
                profile
                    .split_once('=')
                    .map(|(_, profile)| profile.to_string())
            })
            .unwrap_or_else(|| "R2Northstar".to_string());

        log::info!("using profile {profile}");

        let mut ns_path = std::env::current_exe().expect("should have a path to the current exe");
        ns_path.pop();
        _ = NS_DIR.set(ns_path.join(profile));
        _ = std::fs::create_dir(NS_DIR.get().unwrap());

        Self {}
    }
    fn on_dll_load(
        &self,
        _engine_data: Option<&EngineData>,
        dll_ptr: &DLLPointer,
        _engine_token: EngineToken,
    ) {
        use bindings::{RecordingFunctions, RECORDING_FUNCTIONS};
        unsafe { RecordingFunctions::try_init(dll_ptr, &RECORDING_FUNCTIONS) }
    }

    fn on_reload_request(&self) -> reloading::ReloadResponse {
        // SAFETY: aiming for this to be safe aka not leak anything
        unsafe { reloading::ReloadResponse::allow_reload() }
    }
}

entry!(Ranim);
