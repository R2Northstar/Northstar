use rrplug::{
    bindings::squirreldatatypes::SQObject,
    high::{squirrel::SuspendThread, squirrel_traits::SQVMName},
    prelude::*,
};
use std::fs;

use crate::utils::{sanitize_file, SQValue};

// it is used
#[allow(unused)]
struct PlaylistRotationDefinition;

impl SQVMName for PlaylistRotationDefinition {
    fn get_sqvm_name() -> String {
        stringify!(PlaylistRotationDefinition).to_string()
    }
}

pub fn register_api_functions() {
    register_sq_functions(load_file_async);
    register_sq_functions(load_file);
    register_sq_functions(save_file);
    register_sq_functions(does_file_exist);
    register_sq_functions(delete_file);
    register_sq_functions(type_pun);
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPLoadFileAsync")]
pub fn load_file_async(file: String) -> Result<SuspendThread<SQObject>, String> {
    let _file = sanitize_file(&file)?;

    Err("stub".to_string())
    // Ok(SuspendThread::new_with_store(sqvm, |resume| {
    //     thread::spawn(|| {
    //         resume.
    //     })
    // }))
}

// tmp
#[rrplug::sqfunction(
    VM = "CLIENT | SERVER | UI",
    ExportName = "BPTypePun",
    ReturnOverwrite = "Vec<PlaylistRotationDefinition>"
)]
pub fn type_pun(obj: SQObject) -> SQObject {
    obj
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPLoadFile")]
pub fn load_file(file: String) -> Result<SQValue, String> {
    let file = sanitize_file(&file)?;

    let string = fs::read_to_string(file).map_err(|err| err.to_string())?;
    ron::from_str(&string)
        .map(SQValue)
        .map_err(|err| err.to_string())
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPSaveFile")]
pub fn save_file(file: String, contents: SQObject) -> Result<bool, String> {
    let file = sanitize_file(&file)?;

    let value = crate::utils::get_value_from_obj(&contents)?;
    let serialized_value: String = ron::to_string(&value).map_err(|err| err.to_string())?;

    // async?
    Ok(fs::write(file, serialized_value.as_bytes()).is_ok())
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPDeleteFile")]
pub fn delete_file(file: String) -> Result<bool, String> {
    let file = sanitize_file(&file)?;

    Ok(fs::remove_file(file).map_err(|err| err.to_string()).is_ok())
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPDoesFileExist")]
pub fn does_file_exist(_file: String) -> bool {
    // stub
    true
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPGetFileSize")]
pub fn get_file_size(_file: String) -> i32 {
    // stub
    0
}
