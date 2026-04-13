use retour::static_detour;
use rrplug::{
    bindings::squirreldatatypes::CSquirrelVM,
    high::filesystem,
    mid::squirrel::{manually_register_sq_functions, sqvm_to_context},
    prelude::*,
};
use sqparse::ast::{GlobalDefinition, GlobalStatement, StatementType};
use std::{
    ffi::{CStr, c_void},
    mem::{MaybeUninit, transmute},
    path::PathBuf,
    ptr::NonNull,
};

use crate::{
    rson_parser::{Rson, load_rson},
    runtime_registration::register_typed_function,
    sqtypes::{add_enum, add_struct, get_type, seal_structs},
};

static_detour! {
    static Server_CSquirrelVM_InitGcMaybe: unsafe extern "C" fn(*mut CSquirrelVM, *mut HSquirrelVM, u32, usize);
    static Client_CSquirrelVM_InitGcMaybe: unsafe extern "C" fn(*mut CSquirrelVM, *mut HSquirrelVM, u32, usize);
}

pub fn init_hooks(dll: &DLLPointer) {
    unsafe {
        match dll.which_dll() {
            WhichDll::Client => {
                Client_CSquirrelVM_InitGcMaybe
                    .initialize(
                        transmute::<
                            *const c_void,
                            unsafe extern "C" fn(*mut CSquirrelVM, *mut HSquirrelVM, u32, usize),
                        >(dll.offset(0x44df0)),
                        hook_csquirrel_vm_init_gc_client,
                    )
                    .expect("cannot initialize Client_CSquirrelVM_InitGcMaybe")
                    .enable()
                    .expect("cannot hook Client_CSquirrelVM_InitGcMaybe");
            }

            WhichDll::Server => {
                Server_CSquirrelVM_InitGcMaybe
                    .initialize(
                        transmute::<
                            *const c_void,
                            unsafe extern "C" fn(
                                *mut rrplug::bindings::squirreldatatypes::CSquirrelVM,
                                *mut rrplug::prelude::HSquirrelVM,
                                u32,
                                usize,
                            ),
                        >(dll.offset(0x44d90)),
                        hook_csquirrel_vm_init_gc_server,
                    )
                    .expect("cannot initialize Server_CSquirrelVM_InitGcMaybe")
                    .enable()
                    .expect("cannot hook Server_CSquirrelVM_InitGcMaybe");
            }
            _ => {}
        }
    }
}

fn hook_csquirrel_vm_init_gc_client(
    csqvm: *mut CSquirrelVM,
    sqvm: *mut HSquirrelVM,
    unk1: u32,
    unk2: usize,
) {
    unsafe { Client_CSquirrelVM_InitGcMaybe.call(csqvm, sqvm, unk1, unk2) };
    hook_csquirrel_vm_init_gc(csqvm, sqvm, unk1, unk2)
}
fn hook_csquirrel_vm_init_gc_server(
    csqvm: *mut CSquirrelVM,
    sqvm: *mut HSquirrelVM,
    unk1: u32,
    unk2: usize,
) {
    unsafe { Server_CSquirrelVM_InitGcMaybe.call(csqvm, sqvm, unk1, unk2) };
    hook_csquirrel_vm_init_gc(csqvm, sqvm, unk1, unk2)
}
fn hook_csquirrel_vm_init_gc(
    csqvm: *mut CSquirrelVM,
    _sqvm: *mut HSquirrelVM,
    _unk1: u32,
    _unk2: usize,
) {
    _ = mid::squirrel::SQFUNCTIONS.try_init(); // make sure all functions exist
    _ = unsafe { manually_register_sq_functions(&mut *csqvm, &register_type_pun()) };
}

#[rrplug::sqfunction(VM = "SERVER | UI | CLIENT", ExportName = "BPRegisterType")]
fn register_type_pun(ty: String) -> Result<(), String> {
    let file = get_calling_file(sqvm, sq_functions)
        .ok_or_else(|| "file not found for this call".to_string())?;

    let context = unsafe { sqvm_to_context(sqvm) };
    for err in register_file(context, file).err().into_iter().flatten() {
        log::warn!("failed to add file to struct cache : {err}");
    }
    for s in seal_structs(context) {
        (s != ty)
            .then_some(())
            .ok_or_else(|| format!("{ty} couldn't get reflected properly; the struct was missing referenced structs; refer to logs"))?;
        log::warn!("{s} was missing some other struct; therefore it will dropped")
    }

    let Some(typed) = get_type(&ty, context) else {
        return Err(format!(
            "{ty} couldn't get reflected properly; refer to logs"
        ));
    };

    if register_typed_function(sqvm, typed, context).is_none() {
        Err(format!(
            "could not register type {}; possibly would help reading logs as to why; possibly not sealed",
            ty
        ))
    } else {
        Ok(())
    }
}

fn get_calling_file(
    mut sqvm: NonNull<HSquirrelVM>,
    sq_functions: &SquirrelFunctions,
) -> Option<PathBuf> {
    if 1 > unsafe { sqvm.as_ref()._callstacksize } {
        return None;
    }

    let stack_info = unsafe {
        let mut stack_info = MaybeUninit::uninit();
        (sq_functions.sq_stackinfos)(
            sqvm.as_mut(),
            1,
            stack_info.as_mut_ptr(),
            sqvm.as_ref()._callstacksize,
        );
        stack_info.assume_init()
    };

    if stack_info._sourceName.is_null() {
        return None;
    }

    let path = PathBuf::from("scripts")
        .join("vscripts")
        .join(PathBuf::from(
            unsafe { CStr::from_ptr(stack_info._sourceName) }
                .to_string_lossy()
                .to_string()
                .replace('/', "//")
                .to_lowercase(),
        ));
    Some(path.normalize_lexically().unwrap_or(path))
}

pub fn populate_rson_cache(context: ScriptContext) {
    let extra_print = crate::PLUGIN.wait().extra_print;

    if let Some(Rson(rson)) = load_rson() {
        for file in rson
            .into_iter()
            .filter(|(vm, _)| vm.contains_context(context))
            .flat_map(|(_, files)| files.into_iter())
        {
            for err in register_file(context, file).err().into_iter().flatten() {
                if extra_print {
                    log::warn!("{err}");
                }
            }
        }
    }
    for s in seal_structs(context) {
        if extra_print {
            log::warn!("{s} was missing some other struct; therefore it will dropped")
        }
    }
}

fn register_file(context: ScriptContext, file: PathBuf) -> Result<(), Vec<String>> {
    let squirrel_code = filesystem::open(&file)
        .map_err(|_| {
            vec![format!(
                "couldn't find file the source file {} in fs",
                file.display()
            )]
        })?
        .to_string();

    let tokens = sqparse::tokenize(&squirrel_code, sqparse::Flavor::SquirrelRespawn)
        .map_err(|err| vec![format!("{err:?}")])?;
    let ast = sqparse::parse(&tokens).map_err(|err| vec![format!("{err:?}")])?;

    let errors = ast
        .statements
        .iter()
        .filter_map(|stmt| match &stmt.ty {
            StatementType::StructDefinition(s) => Some(s),
            StatementType::Global(GlobalStatement {
                global: _,
                definition: GlobalDefinition::Struct(s),
            }) => Some(s),
            _ => None,
        })
        .map(|s| add_struct(context, s))
        .chain(
            ast.statements
                .iter()
                .filter_map(|stmt| match &stmt.ty {
                    StatementType::EnumDefinition(s) => Some(s),
                    StatementType::Global(GlobalStatement {
                        global: _,
                        definition: GlobalDefinition::Enum(s),
                    }) => Some(s),
                    _ => None,
                })
                .map(|s| add_enum(context, s)),
        )
        .filter_map(|maybe_err| maybe_err.err())
        .collect::<Vec<_>>();

    if errors.is_empty() {
        Ok(())
    } else {
        Err(errors)
    }
}
