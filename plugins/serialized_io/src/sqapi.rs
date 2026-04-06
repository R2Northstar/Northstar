use rrplug::{
    bindings::squirreldatatypes::{SQObject, SQObjectType, SQString},
    high::{
        UnsafeHandle, engine_sync,
        squirrel::{SQHandle, SuspendThread},
        squirrel_traits::SQVMName,
    },
    mid::{squirrel::sqvm_to_context, utils::from_char_ptr},
    prelude::*,
};
use shared::{
    squtils::{SQOutParam, get_generation, try_get_sqvm_with_generation},
    utils::get_from_sq_string,
};
use std::{fs, ptr::NonNull, thread};

use crate::{
    runtime_registration::{self, sqname_to_slot_index},
    sqtypes::TypedType,
    utils::{SQValueTyped, get_json_from_obj, sanitize_file},
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
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPSerialize")]
pub fn serialize_obj(obj: SQObject) -> Result<String, String> {
    let typed = get_func_slot_index(sqvm, sq_functions)?;

    serde_json::to_string(&get_json_from_obj(&obj, &typed)?).map_err(|err| err.to_string())
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPSerialize")]
pub fn deserialize_string(obj: SQHandle<SQString>) -> Result<SQValueTyped<'static>, String> {
    let typed = get_func_slot_index(sqvm, sq_functions)?;

    // less copies :)
    let string = get_from_sq_string(obj.get()).ok_or("the passed object wasn't a utf8 string")?;

    Ok(SQValueTyped(
        serde_json::from_str(string).map_err(|err| err.to_string())?,
        typed,
    ))
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPLoadFileAsync")]
pub fn load_file_async(
    file: SQHandle<SQString>,
    out_param: SQOutParam<SQValueTyped<'static>>,
    out_error: SQOutParam<String>,
) -> Option<SuspendThread<()>> {
    let file = match get_from_sq_string(file.get())
        .ok_or_else(|| "non utf8 string possibly".to_string())
        .and_then(sanitize_file)
    {
        Ok(file) => file,
        Err(err) => {
            out_error.set_out_var(err, sqvm, sq_functions);
            return None;
        }
    };
    let typed = get_func_slot_index(sqvm, sq_functions).unwrap_or({
        TypedType::FullType(crate::sqtypes::CompositeSQObjectType::Single(
            SQObjectType::OT_STRING,
        ))
    });

    let context = unsafe { sqvm_to_context(sqvm) };
    let generation = get_generation(context);

    let (suspend, Some(resume)) = SuspendThread::new_both(sqvm) else {
        out_error.set_out_var(
            "this function was called without SpinOff()".to_string(),
            sqvm,
            sq_functions,
        );
        return None;
    };

    let resume = unsafe { UnsafeHandle::new(resume) };
    let out_param = unsafe { UnsafeHandle::new(out_param) };
    let out_error = unsafe { UnsafeHandle::new(out_error) };
    thread::spawn(move || {
        let read_result = fs::read_to_string(file).map_err(|err| err.to_string());
        _ = engine_sync::async_execute(AsyncEngineMessage::run_func(move |token| {
            let Some(sqvm) = try_get_sqvm_with_generation(generation, context, token) else {
                log::warn!("called load file async on wrong generation");
                return;
            };

            let string = match read_result {
                Ok(string) => string,
                Err(err) => {
                    out_error.take().set_out_var(err, sqvm, sq_functions);
                    resume.take().resume(());
                    return;
                }
            };

            out_param.take().set_out_var(
                SQValueTyped(
                    match serde_json::from_str(&string).map_err(|err| err.to_string()) {
                        Ok(json) => json,
                        Err(err) => {
                            out_error.take().set_out_var(err, sqvm, sq_functions);
                            resume.take().resume(());
                            return;
                        }
                    },
                    typed,
                ),
                sqvm,
                sq_functions,
            );
            resume.take().resume(());
        }))
    });

    Some(suspend)
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPSaveFileAsync")]
pub fn save_file_async(
    file: SQHandle<SQString>,
    contents: SQObject,
    out_error: SQOutParam<String>,
) -> Option<SuspendThread<()>> {
    let file = match get_from_sq_string(file.get())
        .ok_or_else(|| "non utf8 string possibly".to_string())
        .and_then(sanitize_file)
    {
        Ok(file) => file,
        Err(err) => {
            out_error.set_out_var(err, sqvm, sq_functions);
            return None;
        }
    };
    let typed = get_func_slot_index(sqvm, sq_functions).unwrap_or({
        TypedType::FullType(crate::sqtypes::CompositeSQObjectType::Single(
            SQObjectType::OT_STRING,
        ))
    });

    let context = unsafe { sqvm_to_context(sqvm) };
    let generation = get_generation(context);

    let (suspend, Some(resume)) = SuspendThread::new_both(sqvm) else {
        out_error.set_out_var(
            "this function was called without SpinOff()".to_string(),
            sqvm,
            sq_functions,
        );
        return None;
    };

    let resume = unsafe { UnsafeHandle::new(resume) };
    let out_error = unsafe { UnsafeHandle::new(out_error) };
    let contents = unsafe { UnsafeHandle::new(contents) };
    thread::spawn(move || {
        let maybe_err = crate::utils::get_json_from_obj(contents.get(), &typed)
            .and_then(|value| serde_json::to_string(&value).map_err(|err| err.to_string()))
            .and_then(|serialized_value| {
                fs::write(file, serialized_value.as_bytes()).map_err(|err| err.to_string())
            })
            .err();
        _ = engine_sync::async_execute(AsyncEngineMessage::run_func(move |token| {
            let Some(sqvm) = try_get_sqvm_with_generation(generation, context, token) else {
                log::warn!("called load file async on wrong generation");
                return;
            };

            if let Some(err) = maybe_err {
                out_error.take().set_out_var(err, sqvm, sq_functions);
            }
            resume.take().resume(());
        }))
    });

    Some(suspend)
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPLoadFile")]
pub fn load_file(
    file: SQHandle<SQString>,
    out_param: SQOutParam<SQValueTyped<'static>>,
) -> Option<String> {
    let file = match get_from_sq_string(file.get())
        .ok_or_else(|| "non utf8 string possibly".to_string())
        .and_then(sanitize_file)
    {
        Ok(file) => file,
        Err(err) => return Some(err),
    };

    let typed = get_func_slot_index(sqvm, sq_functions).unwrap_or({
        TypedType::FullType(crate::sqtypes::CompositeSQObjectType::Single(
            SQObjectType::OT_STRING,
        ))
    });

    let contents = match fs::read_to_string(file).map_err(|err| err.to_string()) {
        Ok(contents) => contents,
        Err(err) => return Some(err),
    };

    out_param.set_out_var(
        SQValueTyped(
            match serde_json::from_str(&contents).map_err(|err| err.to_string()) {
                Ok(value) => value,
                Err(err) => return Some(err),
            },
            typed,
        ),
        sqvm,
        sq_functions,
    );
    None
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPSaveFile")]
pub fn save_file(file: SQHandle<SQString>, contents: SQObject) -> Option<String> {
    let file = match get_from_sq_string(file.get())
        .ok_or_else(|| "non utf8 string possibly".to_string())
        .and_then(sanitize_file)
    {
        Ok(file) => file,
        Err(err) => return Some(err),
    };

    let typed = get_func_slot_index(sqvm, sq_functions).unwrap_or({
        TypedType::FullType(crate::sqtypes::CompositeSQObjectType::Single(
            SQObjectType::OT_STRING,
        ))
    });

    crate::utils::get_json_from_obj(&contents, &typed)
        .and_then(|value| serde_json::to_string(&value).map_err(|err| err.to_string()))
        .and_then(|serialized_value| {
            fs::write(file, serialized_value.as_bytes()).map_err(|err| err.to_string())
        })
        .err()
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPDeleteFile")]
pub fn delete_file(file: SQHandle<SQString>) -> Option<String> {
    get_from_sq_string(file.get())
        .ok_or_else(|| "non utf8 string possibly".to_string())
        .and_then(sanitize_file)
        .and_then(|file| fs::remove_file(file).map_err(|err| err.to_string()))
        .err()
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPDoesFileExist")]
pub fn does_file_exist(file: SQHandle<SQString>) -> bool {
    get_from_sq_string(file.get())
        .ok_or_else(|| "non utf8 string possibly".to_string())
        .and_then(sanitize_file)
        .map(|file| file.exists())
        .unwrap_or_default()
}

#[rrplug::sqfunction(VM = "CLIENT | SERVER | UI", ExportName = "BPGetFileSize")]
pub fn get_file_size(_file: SQHandle<SQString>) -> i32 {
    // stub
    0
}

fn get_func_slot_index(
    sqvm: NonNull<HSquirrelVM>,
    sq_functions: &SquirrelFunctions,
) -> Result<TypedType<'static>, String> {
    sqname_to_slot_index(
        &get_func_name(sqvm, sq_functions)
            .map_err(|err| format!("couldn't find the native closure's name : {err}"))?,
        unsafe { sqvm_to_context(sqvm) },
    )
    .ok_or_else(|| "this function only works when registered in InitScript".to_string())
    .and_then(|index| {
        let slots = runtime_registration::ALLOCATED_TYPE_SLOTS.lock();
        Ok(slots
            .get(index)
            .and_then(|slot| slot.as_ref())
            .ok_or("slot was somehow invalid")?
            .0
            .clone())
    })
}

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
        Ok(from_char_ptr(
            stack_info
                ._name
                .as_ref()
                .ok_or("no name found for this native function")?,
        ))
    }
}
