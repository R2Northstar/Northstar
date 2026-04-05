use std::{collections::HashMap, ptr::NonNull, sync::LazyLock};

use parking_lot::Mutex;
use rrplug::{
    mid::squirrel::{SQFuncInfo, manually_register_sq_functions},
    prelude::*,
};

use crate::{sqapi, sqtypes::TypedType};

const ALLCATED_TYPES_SIZE: usize = 50;
type TypedSlot = (TypedType<'static>, ScriptContext);
pub static ALLOCATED_TYPE_SLOTS: Mutex<[Option<TypedSlot>; ALLCATED_TYPES_SIZE]> =
    Mutex::new([const { None }; 50]);
pub static ALLOCATED_TYPES_MAP: LazyLock<Mutex<HashMap<ScriptContext, HashMap<String, usize>>>> =
    LazyLock::new(|| Mutex::new(HashMap::new()));

pub fn drop_registrations(context: ScriptContext) {
    let mut slots = ALLOCATED_TYPE_SLOTS.lock();
    let mut map_lock = ALLOCATED_TYPES_MAP.lock();
    let map = map_lock.entry(context).or_default();
    slots
        .iter_mut()
        .enumerate()
        .filter(|(_, slot)| {
            slot.as_ref()
                .map(|slot| slot.1 == context)
                .unwrap_or_default()
        })
        .for_each(|(index, slot)| {
            _ = slot.take();
            for key in map
                .iter()
                .filter(|(_, slot_index)| **slot_index == index)
                .map(|(key, _)| key.to_owned())
                .collect::<Vec<_>>()
            {
                _ = map.remove(&key);
            }
        });
}

pub fn sqname_to_slot_index(name: &String, context: ScriptContext) -> Option<usize> {
    ALLOCATED_TYPES_MAP
        .lock()
        .entry(context)
        .or_default()
        .get(name)
        .copied()
}

pub fn register_typed_function(
    sqvm: NonNull<HSquirrelVM>,
    ty: TypedType<'static>,
    context: ScriptContext,
) -> Option<()> {
    let mut slots = ALLOCATED_TYPE_SLOTS.lock();
    let slot = slots.iter().position(|slot| slot.is_none())?;

    let ty_to_sqname = |ty: &TypedType<'static>| {
        to_camel_case(
            ty.sq_name()
                .replace(['<', '>'], "_")
                .replace([' ', '\t', '>'], ""),
        )
        .replace('_', "")
    };

    let serialize_name = format!("BPSerialize{}", ty_to_sqname(&ty));
    let deserialize_name = format!("BPDeserialize{}", ty_to_sqname(&ty));
    let type_pun_name = format!("BPTypePun{}", ty_to_sqname(&ty));

    log::info!("{ty:?} {}", ty.sq_name());

    let mut map_lock = ALLOCATED_TYPES_MAP.lock();
    let map = map_lock.entry(context).or_default();
    if map.get(&serialize_name).is_some() {
        log::warn!("{serialize_name} is already registered");
        return None;
    }
    map.insert(serialize_name.clone(), slot);

    if map.get(&deserialize_name).is_some() {
        log::warn!("{deserialize_name} is already registered");
        return None;
    }
    map.insert(deserialize_name.clone(), slot);

    if map.get(&type_pun_name).is_some() {
        log::warn!("{type_pun_name} is already registered");
        return None;
    }
    map.insert(type_pun_name.clone(), slot);

    unsafe {
        let csqvm = sqvm.as_ref().sharedState.as_ref()?.cSquirrelVM.as_mut()?;
        manually_register_sq_functions(
            csqvm,
            &SQFuncInfo {
                sq_func_name: Box::from(serialize_name),
                types: Box::from(ty.sq_name()),
                ..sqapi::serialize_obj()
            },
        )
        .ok()?;
        manually_register_sq_functions(
            csqvm,
            &SQFuncInfo {
                sq_func_name: Box::from(deserialize_name),
                return_type: Box::from(ty.sq_name()),
                ..sqapi::deserialize_string()
            },
        )
        .ok()?;
        manually_register_sq_functions(
            csqvm,
            &SQFuncInfo {
                sq_func_name: Box::from(type_pun_name),
                return_type: Box::from(ty.sq_name()),
                types: Box::from("var"),
                ..sqapi::type_pun()
            },
        )
        .ok()?;
    }

    slots.get_mut(slot)?.replace((ty, context));

    Some(())
}

fn to_camel_case(s: String) -> String {
    s.get(0..1).map(|s| s.to_uppercase()).unwrap_or_default()
        + &s.chars()
            .zip(s.chars().skip(1))
            .flat_map(|(prev, current)| {
                current
                    .to_uppercase()
                    .filter(move |_| prev == '_')
                    // preserve cases, since this is only needed for snake case like types
                    .chain(Some(current).into_iter().filter(move |_| prev != '_'))
            })
            .collect::<String>()
}
