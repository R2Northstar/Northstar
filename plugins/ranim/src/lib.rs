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

        // TODO: parse cmd and get ns folder

        Self {}
    }

    fn on_reload_request(&self) -> reloading::ReloadResponse {
        // SAFETY: aiming for this to be safe aka not leak anything
        unsafe { reloading::ReloadResponse::allow_reload() }
    }
}

entry!(Ranim);
