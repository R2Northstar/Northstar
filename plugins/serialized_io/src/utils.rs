// use fs_extra::dir::get_size;
use ron::{value::F32, Map, Number, Value};
use rrplug::{
    bindings::squirreldatatypes::{SQObject, SQObjectType, SQVector},
    high::squirrel_traits::{PushToSquirrelVm, SQVMName},
    prelude::*,
};
use std::{path::PathBuf, ptr::slice_from_raw_parts};

use crate::PLUGIN;

macro_rules! get_handle {
    ($obj:expr, $ty:ident) => {{
        ::rrplug::high::squirrel::SQHandle::<::rrplug::bindings::squirreldatatypes::$ty>::try_new(
            ($obj).clone(),
        )
        .map_err(|_| format!("not a {} somehow", stringify!($ty)))
    }};
}

#[allow(unused)]
const MAX_FILE_SIZE: u64 = 50000000;

#[derive(Debug, Clone, PartialEq, PartialOrd, Ord, Eq)]
pub struct SQValue(pub Value);

#[derive(Debug, Clone, PartialEq, PartialOrd, Ord, Eq)]
pub struct SQNull;

impl SQVMName for SQValue {
    fn get_sqvm_name() -> String {
        "var".to_string()
    }
}

impl PushToSquirrelVm for SQValue {
    fn push_to_sqvm(self, sqvm: std::ptr::NonNull<HSquirrelVM>, sqfunctions: &SquirrelFunctions) {
        let SQValue(value) = self;

        let map_to_vector = |map: &Map| {
            map.iter()
                .map(|(_, value)| match value {
                    Value::Number(Number::F32(F32(float))) => Some(*float),
                    _ => None,
                })
                .collect::<Option<Vec<_>>>()
        };

        let test_for_struct = |map: &Map| {
            map.iter().zip((0..map.len()).map(|i| i.to_string())).all(|((left, _), rigth)| matches!(left, Value::String(string) if string == rigth.as_str()))
        };
        match value {
            Value::Bool(b) => b.push_to_sqvm(sqvm, sqfunctions),
            Value::Char(c) => c.to_string().push_to_sqvm(sqvm, sqfunctions),
            Value::Map(map)
                if map.iter().zip(["x", "y", "z"]).all(
                    |((left, _), rigth)| matches!(left, Value::String(string) if string == rigth),
                ) && let Some(v) = map_to_vector(&map)
                    && v.len() == 3 =>
            {
                Vector3::new(v[0], v[1], v[2]).push_to_sqvm(sqvm, sqfunctions);
            }
            Value::Map(map) if test_for_struct(&map) && !map.is_empty() => {
                unsafe { (sqfunctions.sq_pushnewstructinstance)(sqvm.as_ptr(), map.len() as i32) };

                map.into_iter().enumerate().for_each(|(i, (_, value))| {
                    SQValue(value).push_to_sqvm(sqvm, sqfunctions);
                    unsafe { _ = (sqfunctions.sq_sealstructslot)(sqvm.as_ptr(), i as i32) }
                });
            }
            // todo add tables
            Value::Map(map) => {
                unsafe { (sqfunctions.sq_newtable)(sqvm.as_ptr()) };

                map.into_iter().for_each(|(key, value)| {
                    SQValue(key).push_to_sqvm(sqvm, sqfunctions);
                    SQValue(value).push_to_sqvm(sqvm, sqfunctions);
                    unsafe { _ = (sqfunctions.sq_newslot)(sqvm.as_ptr(), -3, false as u32) }
                });
            }
            Value::Number(Number::I32(number)) => number.push_to_sqvm(sqvm, sqfunctions),
            Value::Number(Number::F32(float)) => float.0.push_to_sqvm(sqvm, sqfunctions),
            Value::Number(number) => (number.into_f64() as f32).push_to_sqvm(sqvm, sqfunctions),
            Value::Option(None) => SQNull.push_to_sqvm(sqvm, sqfunctions),
            Value::Option(Some(value)) => SQValue(*value).push_to_sqvm(sqvm, sqfunctions),
            Value::String(string) => string.push_to_sqvm(sqvm, sqfunctions),
            Value::Bytes(_items) => panic!("idk what to with bytes tbh"),
            Value::Seq(values) => values
                .into_iter()
                .map(SQValue)
                .collect::<Vec<_>>()
                .push_to_sqvm(sqvm, sqfunctions),
            Value::Unit => ().push_to_sqvm(sqvm, sqfunctions), // null possibly?
        }
    }
}

impl SQVMName for SQNull {
    fn get_sqvm_name() -> String {
        "var".to_string()
    }
}

impl PushToSquirrelVm for SQNull {
    fn push_to_sqvm(self, sqvm: std::ptr::NonNull<HSquirrelVM>, sqfunctions: &SquirrelFunctions) {
        unsafe { (sqfunctions.sq_pushnull)(sqvm.as_ptr()) }
    }
}

pub fn sanitize_file(file: &str) -> Result<PathBuf, String> {
    if file.contains('\\') || file.contains('/') || file.contains("..") {
        return Err("illegal char".to_string());
    }

    let dir = PLUGIN.wait().file_dir.as_path();

    if !file
        .chars()
        .all(|char| char.is_alphabetic() || char == '_' || char == '-')
    {
        return Err("illegal char 2".to_string());
    }

    if let Some(parent) = dir.join(file).parent() {
        if parent != dir {
            return Err("you left the data folder".to_string());
        }
    }

    // if get_size("local_mod_data").map_err(|err| err.to_string())? > MAX_FILE_SIZE {
    //     return Err("data folder too larger".to_string());
    // }

    Ok(dir.join(file))
}

pub fn get_value_from_obj(obj: &SQObject) -> Result<Value, String> {
    let value = match obj._Type {
        SQObjectType::OT_VECTOR => {
            let vector = unsafe { *(obj as *const SQObject).cast::<SQVector>() };

            Value::Map(Map::from_iter(
                [vector.x, vector.y, vector.z]
                    .map(|value| Value::Number(Number::F32(F32(value))))
                    .into_iter()
                    .zip(["x", "y", "z"].map(str::to_string)),
            ))
        }
        SQObjectType::OT_NULL => Value::Option(None),
        SQObjectType::OT_BOOL => {
            let obj = get_handle!(obj, SQBool)?;
            Value::Bool(*obj.get() == 1)
        }
        SQObjectType::OT_INTEGER => {
            let obj = get_handle!(obj, SQInteger)?;
            Value::Number(Number::I32(*obj.get()))
        }
        SQObjectType::OT_FLOAT => {
            let obj = get_handle!(obj, SQFloat)?;
            Value::Number(Number::F32(F32::new(*obj.get())))
        }
        SQObjectType::OT_ARRAY => {
            let obj = get_handle!(obj, SQArray)?;
            let array = obj.get();

            Value::Seq(
                unsafe { slice_from_raw_parts(array._values, array._usedSlots as usize).as_ref() }
                    .ok_or("poor array")?
                    .iter()
                    .map(get_value_from_obj)
                    .collect::<Result<Vec<_>, String>>()?,
            )
        }
        SQObjectType::OT_CLOSURE => {
            return Err("cannot do closure".to_string());
        }
        SQObjectType::OT_NATIVECLOSURE => {
            return Err("cannot do userdata".to_string());
        }
        SQObjectType::OT_STRING => {
            let obj = get_handle!(obj, SQString)?;
            let string = obj.get();

            Value::String(
                String::from_utf8_lossy(unsafe {
                    slice_from_raw_parts(string._val.as_ptr().cast::<u8>(), string.length as usize)
                        .as_ref()
                        .ok_or_else(|| "null pointer :skull:".to_string())?
                })
                .into_owned(),
            )
        }
        SQObjectType::OT_THREAD => {
            return Err("cannot do thread".to_string());
        }
        SQObjectType::OT_FUNCPROTO => {
            return Err("cannot do funcproto".to_string());
        }
        SQObjectType::OT_CLASS => {
            return Err("cannot do userdata".to_string());
        }
        SQObjectType::OT_STRUCT => {
            let obj = get_handle!(obj, SQStructInstance)?;
            let instance = obj.get();

            Value::Map(Map::from_iter(
                unsafe {
                    slice_from_raw_parts(instance.data.as_ptr(), instance.size as usize).as_ref()
                }
                .ok_or("poor struct")?
                .iter()
                .zip(0..instance.size)
                .map(|(obj, i)| Ok((i.to_string(), get_value_from_obj(obj)?)))
                .collect::<Result<Vec<_>, String>>()?,
            ))
        }
        SQObjectType::OT_WEAKREF => {
            return Err("cannot do userdata".to_string());
        }
        // TODO: figure if node.next is important
        SQObjectType::OT_TABLE => {
            let obj = get_handle!(obj, SQTable)?;
            let table = obj.get();

            Value::Map(Map::from_iter(
                unsafe { slice_from_raw_parts(table._nodes.cast_const(), 0).as_ref() }
                    .ok_or("poor table")?
                    .iter()
                    .filter(|node| node.key._Type != SQObjectType::OT_NULL)
                    .map(|node| {
                        Ok((
                            get_value_from_obj(&node.key)?,
                            get_value_from_obj(&node.val)?,
                        ))
                    })
                    .collect::<Result<Vec<_>, String>>()?,
            ))
        }
        SQObjectType::OT_USERDATA => {
            return Err("cannot do userdata".to_string());
        }
        SQObjectType::OT_INSTANCE => {
            return Err("cannot do intance".to_string());
        }
        SQObjectType::OT_ENTITY => {
            return Err("cannot do userdata".to_string());
        }
        ty => return Err(format!("cannot proccess {ty:?}")),
    };

    Ok(value)
}
