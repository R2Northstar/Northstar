#![feature(if_let_guard, normalize_lexically, slice_as_array)]
use std::{fs, path::PathBuf};

use rrplug::{bindings::plugin_abi::PluginColor, prelude::*};

mod preprocessor;
mod rson_parser;
mod runtime_registration;
mod sqapi;
mod sqtypes;
mod utils;

pub struct SerializedIO {
    file_dir: PathBuf,
    extra_print: bool,
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
        .join("serialized_io");

        _ = fs::create_dir_all(&file_dir);

        let extra_print = std::env::args().any(|arg| arg == "-extra-print");

        Self {
            file_dir,
            extra_print,
        }
    }

    fn on_sqvm_created(&self, sqvm_handle: &CSquirrelVMHandle, _engine_token: EngineToken) {
        preprocessor::populate_rson_cache(sqvm_handle.get_context());
    }

    fn on_sqvm_destroyed(&self, sqvm_handle: &CSquirrelVMHandle, _engine_token: EngineToken) {
        sqtypes::clear_cache(sqvm_handle.get_context());
        runtime_registration::drop_registrations(sqvm_handle.get_context());
    }

    fn on_dll_load(
        &self,
        _engine_data: Option<&EngineData>,
        dll_ptr: &DLLPointer,
        _engine_token: EngineToken,
    ) {
        preprocessor::init_hooks(dll_ptr);
    }
}

entry!(SerializedIO);
