// use fs_extra::dir::get_size;
use rrplug::{
    bindings::squirreldatatypes::{SQObject, SQObjectType, SQVector},
    high::squirrel_traits::{GetFromSQObject, PushToSquirrelVm, SQVMName},
    prelude::*,
};
use serde_json::{Map as JsonMap, Number as JsonNumber, Value as JsonValue};
use std::{path::PathBuf, ptr::slice_from_raw_parts};

use crate::{
    PLUGIN,
    sqtypes::{CompositeSQObjectType, TypedType},
};

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

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SQValueTyped<'a>(pub JsonValue, pub TypedType<'a>);

#[derive(Debug, Clone, PartialEq, PartialOrd, Ord, Eq)]
pub struct SQNull;

impl SQVMName for SQValueTyped<'_> {
    fn get_sqvm_name() -> String {
        "var".to_string()
    }
}

impl<'a> PushToSquirrelVm for SQValueTyped<'a> {
    fn push_to_sqvm(self, sqvm: std::ptr::NonNull<HSquirrelVM>, sqfunctions: &SquirrelFunctions) {
        let SQValueTyped(value, ty) = self;

        match &ty {
            TypedType::Enum(name, fields) if let JsonValue::Object(map) = &value => {
                if let Some(JsonValue::String(field)) = map.get(name) {
                    if let Some(&enumeration) = fields.get(field) {
                        enumeration.push_to_sqvm(sqvm, sqfunctions);
                    } else {
                        log::warn!(
                            "while deserializing: enum {name}; the field {field} is not valid"
                        )
                    }
                } else {
                    log::warn!("while deserializing: enum {name} it's missing in {value:?}")
                }
            }
            TypedType::Enum(name, _) => {
                SQNull.push_to_sqvm(sqvm, sqfunctions);
                log::warn!("while deserializing: enum {name}; {value} is not of type Object");
            }

            TypedType::Struct(name, fields) => {
                if let JsonValue::Object(mut map) = value
                    && fields.iter().all(|(field, _)| map.contains_key(field))
                {
                    unsafe {
                        (sqfunctions.sq_pushnewstructinstance)(sqvm.as_ptr(), map.len() as i32)
                    };

                    fields
                        .iter()
                        .enumerate()
                        .for_each(|(i, (field, field_ty))| {
                            SQValueTyped(
                                map.remove(field)
                                    .expect("checked invariant got broken somehow"),
                                TypedType::RefFullType(field_ty),
                            )
                            .push_to_sqvm(sqvm, sqfunctions);
                            unsafe { _ = (sqfunctions.sq_sealstructslot)(sqvm.as_ptr(), i as i32) }
                        });
                } else {
                    SQNull.push_to_sqvm(sqvm, sqfunctions);
                    log::warn!(
                        "while deserializing: struct {name} found a value which is not of type Object or not all fields are present"
                    );
                }
            }

            &TypedType::RefFullType(sq_ty) | TypedType::FullType(sq_ty) => match sq_ty {
                CompositeSQObjectType::Single(sq_ty) => match sq_ty {
                    SQObjectType::OT_VECTOR
                        if let JsonValue::Array(vector) = &value
                            && vector
                                .iter()
                                .all(|f| matches!(f, JsonValue::Number(num) if num.is_f64()))
                            && vector.len() == 3 =>
                    {
                        Vector3::from(
                            *vector
                                .iter()
                                .filter_map(|f| f.as_f64())
                                .map(|f| f as f32)
                                .collect::<Vec<f32>>()
                                .as_array::<3>()
                                .expect("checked invariant got broken somehow"),
                        )
                        .push_to_sqvm(sqvm, sqfunctions);
                    }
                    SQObjectType::OT_NULL => {
                        SQNull.push_to_sqvm(sqvm, sqfunctions);
                    }
                    SQObjectType::OT_BOOL
                        if let Some(boolean) = value
                            .as_bool()
                            .or_else(|| value.as_str().and_then(|b| b.parse().ok())) =>
                    {
                        boolean.push_to_sqvm(sqvm, sqfunctions);
                    }
                    SQObjectType::OT_INTEGER
                        if let Some(int) = value
                            .as_i64()
                            .or_else(|| value.as_str().and_then(|b| b.parse().ok())) =>
                    {
                        (int as i32).push_to_sqvm(sqvm, sqfunctions);
                    }
                    SQObjectType::OT_FLOAT
                        if let Some(int) = value
                            .as_f64()
                            .or_else(|| value.as_str().and_then(|b| b.parse().ok())) =>
                    {
                        (int as f32).push_to_sqvm(sqvm, sqfunctions);
                    }
                    SQObjectType::OT_ASSET | SQObjectType::OT_STRING
                        if let Some(string) = value.as_str() =>
                    {
                        string.push_to_sqvm(sqvm, sqfunctions);
                    }

                    SQObjectType::OT_VECTOR
                    | SQObjectType::OT_BOOL
                    | SQObjectType::OT_INTEGER
                    | SQObjectType::OT_FLOAT
                    | SQObjectType::OT_STRING
                    | SQObjectType::OT_ASSET => {
                        SQNull.push_to_sqvm(sqvm, sqfunctions);
                        log::warn!("while deserializing: expected {sq_ty:?} found something else")
                    }
                    SQObjectType::OT_TABLE | SQObjectType::OT_ARRAY | SQObjectType::OT_STRUCT => {
                        SQNull.push_to_sqvm(sqvm, sqfunctions);
                        log::warn!("while deserializing: found illegal untyped type {sq_ty:?}")
                    }
                    SQObjectType::OT_THREAD
                    | SQObjectType::OT_CLOSURE
                    | SQObjectType::OT_USERPOINTER
                    | SQObjectType::OT_NATIVECLOSURE
                    | SQObjectType::OT_FUNCPROTO
                    | SQObjectType::OT_CLASS
                    | SQObjectType::OT_WEAKREF
                    | SQObjectType::OT_USERDATA
                    | SQObjectType::OT_INSTANCE
                    | SQObjectType::OT_ENTITY => {
                        SQNull.push_to_sqvm(sqvm, sqfunctions);
                        log::warn!("while deserializing: reached an invalid push operation")
                    }
                    _ => log::warn!("while deserializing: reached an unreachable push operation"),
                },
                CompositeSQObjectType::Array(base) => {
                    if let JsonValue::Array(values) = value {
                        values
                            .into_iter()
                            .map(|value| SQValueTyped(value, TypedType::RefFullType(base.as_ref())))
                            .collect::<Vec<_>>()
                            .push_to_sqvm(sqvm, sqfunctions)
                    } else {
                        SQNull.push_to_sqvm(sqvm, sqfunctions);
                        log::warn!(
                            "while deserializing: tried pushing a non array object for an array type"
                        );
                    }
                }
                CompositeSQObjectType::ArraySized(base, size) => {
                    if let JsonValue::Array(values) = value
                        && values.len() == *size
                    {
                        values
                            .into_iter()
                            .map(|value| SQValueTyped(value, TypedType::RefFullType(base.as_ref())))
                            .collect::<Vec<_>>()
                            .push_to_sqvm(sqvm, sqfunctions)
                    } else {
                        SQNull.push_to_sqvm(sqvm, sqfunctions);
                        log::warn!(
                            "while deserializing: tried pushing a non array object for an array type or the size is not right"
                        );
                    }
                }
                CompositeSQObjectType::Table(key_ty, value_ty) => {
                    if let JsonValue::Object(map) = value {
                        unsafe { (sqfunctions.sq_newtable)(sqvm.as_ptr()) };

                        map.into_iter().for_each(|(key, value)| {
                            SQValueTyped(
                                JsonValue::String(key),
                                TypedType::RefFullType(key_ty.as_ref()),
                            )
                            .push_to_sqvm(sqvm, sqfunctions);
                            SQValueTyped(value, TypedType::RefFullType(value_ty.as_ref()))
                                .push_to_sqvm(sqvm, sqfunctions);
                            unsafe { _ = (sqfunctions.sq_newslot)(sqvm.as_ptr(), -3, false as u32) }
                        });
                    } else {
                        SQNull.push_to_sqvm(sqvm, sqfunctions);
                        log::warn!(
                            "while deserializing: tried pushing a non object for a table type or couldn't get types for the table"
                        );
                    }
                }
                CompositeSQObjectType::Nullable(base) => {
                    if let JsonValue::Null = &value {
                        SQNull.push_to_sqvm(sqvm, sqfunctions);
                    } else {
                        SQValueTyped(value, TypedType::RefFullType(base.as_ref()))
                            .push_to_sqvm(sqvm, sqfunctions);
                    }
                }
                CompositeSQObjectType::PossibleStructRef(_) => {
                    SQNull.push_to_sqvm(sqvm, sqfunctions);
                    log::warn!("while deserializing: found an unsealed struct")
                }
                CompositeSQObjectType::Struct(name, fields) => {
                    if let JsonValue::Object(mut map) = value
                        && fields.iter().all(|(field, _)| map.contains_key(field))
                    {
                        unsafe {
                            (sqfunctions.sq_pushnewstructinstance)(sqvm.as_ptr(), map.len() as i32)
                        };

                        fields
                            .iter()
                            .enumerate()
                            .for_each(|(i, (field, field_ty))| {
                                SQValueTyped(
                                    map.remove(field)
                                        .expect("checked invariant got broken somehow"),
                                    TypedType::RefFullType(field_ty),
                                )
                                .push_to_sqvm(sqvm, sqfunctions);
                                unsafe {
                                    _ = (sqfunctions.sq_sealstructslot)(sqvm.as_ptr(), i as i32)
                                }
                            });
                    } else {
                        SQNull.push_to_sqvm(sqvm, sqfunctions);
                        log::warn!(
                            "while deserializing: struct {name} found a value which is not of type Object or not all fields are present"
                        );
                    }
                }
            },
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

    if let Some(parent) = dir.join(file).parent()
        && parent != dir
    {
        return Err("you left the data folder".to_string());
    }

    // if get_size("local_mod_data").map_err(|err| err.to_string())? > MAX_FILE_SIZE {
    //     return Err("data folder too larger".to_string());
    // }

    let mut file = dir.join(file);
    file.set_extension("json");
    Ok(file)
}

pub fn get_json_from_obj(obj: &SQObject, ty: &TypedType) -> Result<JsonValue, String> {
    let value = match obj._Type {
        SQObjectType::OT_VECTOR if ty.is_of(obj._Type) => {
            let vector = unsafe { *(obj as *const SQObject).cast::<SQVector>() };

            JsonValue::Array(vec![
                JsonValue::Number(
                    JsonNumber::from_f64(vector.x as f64)
                        .ok_or_else(|| "vector.x is not finite".to_string())?,
                ),
                JsonValue::Number(
                    JsonNumber::from_f64(vector.y as f64)
                        .ok_or_else(|| "vector.y is not finite".to_string())?,
                ),
                JsonValue::Number(
                    JsonNumber::from_f64(vector.z as f64)
                        .ok_or_else(|| "vector.z is not finite".to_string())?,
                ),
            ])
        }
        SQObjectType::OT_NULL if ty.is_of(obj._Type) => JsonValue::Null,
        SQObjectType::OT_BOOL if ty.is_of(obj._Type) => {
            let obj = get_handle!(obj, SQBool)?;
            JsonValue::Bool(*obj.get() == 1)
        }
        SQObjectType::OT_INTEGER
            if ty.is_of(obj._Type)
                && let TypedType::Enum(_, fields) = ty
                && let Ok(obj) = get_handle!(obj, SQInteger)
                && let Some((field, _)) =
                    fields.iter().find(|(_, value)| **value == *obj.get()) =>
        {
            JsonValue::String(field.clone())
        }
        SQObjectType::OT_INTEGER if ty.is_of(obj._Type) => {
            let obj = get_handle!(obj, SQInteger)?;
            JsonValue::Number(JsonNumber::from_i128(*obj.get() as i128).ok_or_else(|| {
                "number could not get represented as a number for some reason".to_string()
            })?)
        }
        SQObjectType::OT_FLOAT if ty.is_of(obj._Type) => {
            let obj = get_handle!(obj, SQFloat)?;
            JsonValue::Number(
                JsonNumber::from_f64(*obj.get() as f64)
                    .ok_or_else(|| "float is not finite".to_string())?,
            )
        }
        SQObjectType::OT_ARRAY
            if ty.is_of(obj._Type)
                && let TypedType::FullType(
                    CompositeSQObjectType::Array(base) | CompositeSQObjectType::ArraySized(base, _),
                )
                | TypedType::RefFullType(
                    CompositeSQObjectType::Array(base) | CompositeSQObjectType::ArraySized(base, _),
                ) = &ty =>
        {
            let obj = get_handle!(obj, SQArray)?;
            let array = obj.get();

            JsonValue::Array(
                unsafe { slice_from_raw_parts(array._values, array._usedSlots as usize).as_ref() }
                    .ok_or("poor array")?
                    .iter()
                    .map(|obj| get_json_from_obj(obj, &TypedType::RefFullType(base.as_ref())))
                    .collect::<Result<Vec<_>, String>>()?,
            )
        }
        SQObjectType::OT_CLOSURE => {
            return Err("cannot do closure".to_string());
        }
        SQObjectType::OT_NATIVECLOSURE => {
            return Err("cannot do userdata".to_string());
        }
        SQObjectType::OT_STRING | SQObjectType::OT_ASSET if ty.is_of(obj._Type) => {
            let obj = get_handle!(obj, SQString)?;
            let string = obj.get();

            JsonValue::String(
                String::from_utf8_lossy(unsafe {
                    slice_from_raw_parts(string._val.as_ptr().cast::<u8>(), string.length as usize)
                        .as_ref()
                        .ok_or_else(|| "null pointer :skull:".to_string())?
                })
                .into_owned(),
            )
        }
        SQObjectType::OT_STRUCT
            if ty.is_of(obj._Type)
                && let TypedType::FullType(CompositeSQObjectType::Struct(_, fields))
                | TypedType::RefFullType(CompositeSQObjectType::Struct(_, fields))
                | TypedType::Struct(_, fields) = &ty =>
        {
            let obj = get_handle!(obj, SQStructInstance)?;
            let instance = obj.get();

            JsonValue::Object(JsonMap::from_iter(
                unsafe {
                    slice_from_raw_parts(instance.data.as_ptr(), instance.size as usize).as_ref()
                }
                .ok_or("poor struct")?
                .iter()
                .zip(fields.iter())
                .map(|(obj, ty)| {
                    Ok((
                        ty.0.to_owned(),
                        get_json_from_obj(obj, &TypedType::RefFullType(&ty.1))?,
                    ))
                })
                .collect::<Result<Vec<_>, String>>()?,
            ))
        }
        // TODO: figure if node.next is important
        SQObjectType::OT_TABLE
            if ty.is_of(obj._Type)
                && let TypedType::FullType(CompositeSQObjectType::Table(key, value))
                | TypedType::RefFullType(CompositeSQObjectType::Table(key, value)) = &ty =>
        {
            let obj = get_handle!(obj, SQTable)?;
            let table = obj.get();

            JsonValue::Object(JsonMap::from_iter(
                unsafe { slice_from_raw_parts(table._nodes.cast_const(), 0).as_ref() }
                    .ok_or("poor table")?
                    .iter()
                    .filter(|node| node.key._Type != SQObjectType::OT_NULL)
                    .map(|node| {
                        Ok((
                            get_string_from_obj(node.key, &TypedType::RefFullType(key.as_ref()))?,
                            get_json_from_obj(&node.val, &TypedType::RefFullType(value.as_ref()))?,
                        ))
                    })
                    .collect::<Result<Vec<_>, String>>()?,
            ))
        }
        SQObjectType::OT_USERDATA => {
            return Err("cannot do userdata".to_string());
        }
        SQObjectType::OT_INSTANCE => {
            return Err("cannot do instance".to_string());
        }
        SQObjectType::OT_ENTITY => {
            return Err("cannot do userdata".to_string());
        }
        SQObjectType::OT_WEAKREF => {
            return Err("cannot do userdata".to_string());
        }
        SQObjectType::OT_THREAD => {
            return Err("cannot do thread".to_string());
        }
        SQObjectType::OT_FUNCPROTO => {
            return Err("cannot do func proto".to_string());
        }
        SQObjectType::OT_CLASS => {
            return Err("cannot do userdata".to_string());
        }

        sq_ty
            if matches!(
                sq_ty,
                SQObjectType::OT_VECTOR
                    | SQObjectType::OT_NULL
                    | SQObjectType::OT_BOOL
                    | SQObjectType::OT_INTEGER
                    | SQObjectType::OT_FLOAT
                    | SQObjectType::OT_ARRAY
                    | SQObjectType::OT_STRING
                    | SQObjectType::OT_STRUCT
                    | SQObjectType::OT_TABLE
            ) =>
        {
            return Err(format!("type error: got {sq_ty:?} expected {ty:?}"));
        }
        ty => return Err(format!("cannot process {ty:?}")),
    };

    Ok(value)
}

fn get_string_from_obj(obj: SQObject, sq_ty: &TypedType<'_>) -> Result<String, String> {
    match sq_ty {
        TypedType::Enum(_, _) => Err("can't stringify an enum".to_string()),
        TypedType::Struct(_, _) => Err("can't stringify a struct".to_string()),
        TypedType::FullType(ty) | &TypedType::RefFullType(ty) => match ty {
            CompositeSQObjectType::Single(ty) => match ty {
                SQObjectType::OT_VECTOR => {
                    Err("well I can't trivially parse out a vector".to_string())?
                }
                SQObjectType::OT_BOOL => Ok(bool::get_from_sqobject(&obj).to_string()),
                SQObjectType::OT_INTEGER => Ok(i32::get_from_sqobject(&obj).to_string()),
                SQObjectType::OT_FLOAT => Ok(f32::get_from_sqobject(&obj).to_string()),
                SQObjectType::OT_STRING | SQObjectType::OT_ASSET => {
                    Ok(String::get_from_sqobject(&obj))
                }
                ty => Err(format!("can't stringify {ty:?}"))?,
            },
            CompositeSQObjectType::Array(_) => Err("can't stringify an array".to_string()),
            CompositeSQObjectType::ArraySized(_, _) => Err("can't stringify an array".to_string()),
            CompositeSQObjectType::Table(_, _) => Err("can't stringify an table".to_string()),
            CompositeSQObjectType::Nullable(_) => Err("can't stringify an table".to_string()),
            CompositeSQObjectType::PossibleStructRef(_) | CompositeSQObjectType::Struct(_, _) => {
                Err("can't stringify an a struct".to_string())
            }
        },
    }
}
