use rrplug::{
    bindings::squirreldatatypes::{SQObject, SQString},
    high::{
        squirrel::{SQHandle, SuspendThread},
        squirrel_traits::SQVMName,
    },
    mid::{squirrel::sqvm_to_context, utils::from_char_ptr},
    prelude::*,
};
use shared::utils::get_from_sq_string;
use std::{fs, ptr::NonNull};

use crate::{
    runtime_registration::{self, sqname_to_slot_index},
    utils::{SQValue, SQValueTyped, get_json_from_obj, sanitize_file},
};

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

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPSerialize")]
pub fn serialize_obj(obj: SQObject) -> Result<String, String> {
    let index = sqname_to_slot_index(
        &get_func_name(sqvm, sq_functions)
            .map_err(|err| format!("couldn't find the native closure's name : {err}"))?,
        unsafe { sqvm_to_context(sqvm) },
    )
    .ok_or("this function only works when registered in InitScript")?;

    let slots = runtime_registration::ALLOCATED_TYPE_SLOTS.lock();
    let slot = slots
        .get(index)
        .and_then(|o| o.as_ref())
        .ok_or("slot for this type hasn't been found")?;

    serde_json::to_string(&get_json_from_obj(&obj, &slot.0)?).map_err(|err| err.to_string())
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPSerialize")]
pub fn deserialize_string(obj: SQObject) -> Result<SQValueTyped<'static>, String> {
    let index = sqname_to_slot_index(
        &get_func_name(sqvm, sq_functions)
            .map_err(|err| format!("couldn't find the native closure's name : {err}"))?,
        unsafe { sqvm_to_context(sqvm) },
    )
    .ok_or("this function only works when registered in InitScript")?;

    let slots = runtime_registration::ALLOCATED_TYPE_SLOTS.lock();
    let slot = slots
        .get(index)
        .and_then(|slot| slot.as_ref())
        .ok_or("slot was somehow invalid")?
        .0
        .clone();

    let string =
        SQHandle::<SQString>::try_new(obj).map_err(|_| "the passed parameter wasn't a string")?;
    let string =
        get_from_sq_string(string.get()).ok_or("the passed object wasn't a utf8 string")?;

    Ok(SQValueTyped(
        serde_json::from_str(string).map_err(|err| err.to_string())?,
        slot,
    ))
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

// fn get_func_name<'a>(
//     sqvm: NonNull<HSquirrelVM>,
//     _: &SquirrelFunctions,
// ) -> Result<&'a str, &'static str> {
//     let call_info = unsafe {
//         sqvm.as_ref()
//             ._stack
//             .add(sqvm.as_ref()._stackbase as usize - 1)
//             .as_ref()
//     }
//     .ok_or("no callstack")?;
//     match call_info._Type {
//         rrplug::bindings::squirreldatatypes::SQObjectType::OT_NATIVECLOSURE => unsafe {
//             get_from_sq_string(
//                 call_info
//                     ._VAL
//                     .asNativeClosure
//                     .as_ref()
//                     .ok_or("no nativefunction")?
//                     ._name
//                     .as_ref()
//                     .ok_or("no name")?,
//             )
//             .ok_or("string failure")
//         },
//         ty => {
//             log::error!("{ty:?}");
//             Err("not a native closure")
//         }
//     }
// }

fn get_func_name(
    mut sqvm: NonNull<HSquirrelVM>,
    sq_functions: &SquirrelFunctions,
) -> Result<String, &'static str> {
    if 1 > unsafe { sqvm.as_ref()._callstacksize } {
        return Err("stack is too small");
    }

    let stack_info = unsafe {
        let mut stack_info = std::mem::MaybeUninit::uninit();
        (sq_functions.sq_stackinfos)(
            sqvm.as_mut(),
            0,
            stack_info.as_mut_ptr(),
            sqvm.as_ref()._callstacksize,
        );
        stack_info.assume_init()
    };

    unsafe {
        let var_name = from_char_ptr(stack_info._name.as_ref().ok_or("no name")?);
        log::info!("{var_name}");
        Ok(var_name)
    }
}
