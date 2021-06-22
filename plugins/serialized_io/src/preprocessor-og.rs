use retour::GenericDetour;
use rrplug::{bindings::squirreldatatypes::CSquirrelVM, prelude::*};
use std::{
    mem::transmute,
    sync::{LazyLock, OnceLock},
};
use windows_sys::Win32::System::LibraryLoader::GetModuleHandleA;

static PATTERN: LazyLock<patterns::Pattern> = LazyLock::new(|| {
    "55 41 57 41 56 41 55 41 54 56 57 53 48 81 ec 58 03 00 00 48 8d ac 24 80 00 00 00 0f 29 b5 c0 02 00 00 48 c7 85 b8 02 00".parse().unwrap()
});

type CsquirrelVmInitType =
    extern "C" fn(csqvm: *mut CSquirrelVM, actual_context: ScriptContext, time: f32);
type CsquirrelVmInitHookType = GenericDetour<CsquirrelVmInitType>;

static CSQUIRREL_VM_INIT_HOOK_0: OnceLock<CsquirrelVmInitHookType> = OnceLock::new();
static CSQUIRREL_VM_INIT_HOOK_1: OnceLock<CsquirrelVmInitHookType> = OnceLock::new();

pub fn init_hooks() {
    unsafe {
        let Some(northstar) = (GetModuleHandleA(c"Northstar.dll".as_ptr().cast::<u8>())
            as *const u8)
            .as_ref()
            .map(|module| &*std::ptr::slice_from_raw_parts(module, i32::MAX as usize))
        else {
            log::warn!("couldn't find northstar.dll");
            return;
        };

        for i in PATTERN.matches(&northstar[0..]).take(2) {
            log::info!("function found at {0:X}", i);

            let (store, detour): (&OnceLock<CsquirrelVmInitHookType>, CsquirrelVmInitType) =
                match CSQUIRREL_VM_INIT_HOOK_0.get() {
                    Some(_) => (&CSQUIRREL_VM_INIT_HOOK_1, hook_csquirrel_vm_init_hook_1),
                    None => (&CSQUIRREL_VM_INIT_HOOK_0, hook_csquirrel_vm_init_hook_0),
                };

            let Ok(_) = store.set(
                GenericDetour::new(
                    transmute::<*const u8, CsquirrelVmInitType>(
                        northstar.get(i).expect("unlikely") as *const u8,
                    ),
                    detour,
                )
                .expect("hooking CSQUIRREL_VM_INIT_HOOK should not fail imo"),
            ) else {
                log::error!("could not hook CSQUIRREL_VM_INIT_HOOK");
                continue;
            };

            _ = store.wait().enable();
        }
    }
}

extern "C" fn hook_csquirrel_vm_init_hook_1(
    csqvm: *mut CSquirrelVM,
    actual_context: ScriptContext,
    time: f32,
) {
    hook_csquirrel_vm_init_hook(CSQUIRREL_VM_INIT_HOOK_1.wait(), csqvm, actual_context, time)
}
extern "C" fn hook_csquirrel_vm_init_hook_0(
    csqvm: *mut CSquirrelVM,
    actual_context: ScriptContext,
    time: f32,
) {
    hook_csquirrel_vm_init_hook(CSQUIRREL_VM_INIT_HOOK_0.wait(), csqvm, actual_context, time)
}
fn hook_csquirrel_vm_init_hook(
    org: &CsquirrelVmInitHookType,
    csqvm: *mut CSquirrelVM,
    actual_context: ScriptContext,
    time: f32,
) {
    log::info!("yeahssssssssssssssssss : {actual_context}");
    org.call(csqvm, actual_context, time);
}
