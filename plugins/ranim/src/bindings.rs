use bytemuck::{Pod, Zeroable};
use mid::utils::str_from_char_ptr;
use rrplug::{offset_functions, prelude::*};
use std::{os::raw::c_char, slice};

offset_functions! {
    RECORDING_FUNCTIONS + RecordingFunctions for WhichDll::Server => {
        sq_getrecordedanimation = unsafe extern "C" fn(*mut HSquirrelVM, i32) -> *mut RecordedAnimation where offset(0x99b30);
        sq_pushrecordedanimation = unsafe extern "C" fn(*mut HSquirrelVM, *mut RecordedAnimation) where offset(0x99c50);
        created_recorded_anim_count = *mut u32 where offset(0xbce630);
        insert_anim_in_loaded_list = unsafe extern "C" fn(*const RecordedAnimation) -> bool where offset(0x99270);
        new_recorded_animation = unsafe extern "C" fn() -> *mut RecordedAnimation where offset(0x996e0);
    }
}

#[repr(C)]
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Pod, Zeroable)]
pub struct RecordedAnimationLayer {
    pub unk_0: i32,
    pub sequence_index: i32,
    pub unk_8: i32,
    pub unk_c: i32,
    pub unk_10: i32,
    pub unk_14: i32,
    pub unk_18: i32,
    pub unk_1c: i32,
    pub unk_20: i32,
}

#[repr(C)]
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Pod, Zeroable)]
pub struct RecordedAnimationFrame {
    pub unk_0: i32,
    pub unk_4: i32,
    pub unk_8: i32,
    pub unk_c: i32,
    pub unk_10: i32,
    pub unk_14: i32,
    pub unk_18: i32,
    pub unk_1c: i32,
    pub sequence_index: i32,
    pub unk_24: i32,
    pub unk_28: i32,
    pub unk_2c: i32,
    pub layer_index: i32,
    pub unk_34: i32,
    pub gap_38: [u8; 11],
    pub unk_43: u8, // was a bool
}

#[repr(C)]
#[derive(Debug, Clone, Copy, Zeroable)]
pub struct RecordedAnimation {
    pub unknown_0: [i32; 44],
    pub unknown_b0: [u8; 64],
    pub sequences: [*const c_char; 47],
    pub unknown_268: [i32; 34],
    pub origin: [f32; 3],
    pub angles: [f32; 3],
    pub frames: *mut RecordedAnimationFrame,
    pub layers: *mut RecordedAnimationLayer,
    pub frame_count: u32,
    pub layer_count: u32,
    pub loaded_index: u64,
    pub index: i32,
    pub not_refcounted: bool,
    pub refcount: u8,
}

unsafe impl Pod for RecordedAnimation {}

static _ASSERT_RECORDED_ANIMATION_LAYER: () = assert!(size_of::<RecordedAnimationLayer>() == 0x24);
static _ASSERT_RECORDED_ANIMATION_FRAME: () = assert!(size_of::<RecordedAnimationFrame>() == 0x44);
#[rustfmt::skip] static _ASSERT_RECORDED_ANIMATION_LAYER_ARR: () = assert!(size_of::<RecordedAnimationLayer>() == size_of::<[u8; 0x24]>());
#[rustfmt::skip] static _ASSERT_RECORDED_ANIMATION_FRAME_ARR: () = assert!(size_of::<RecordedAnimationFrame>() == size_of::<[u8; 0x44]>());
static _ASSERT_RECORDED_ANIMATION: () = assert!(size_of::<RecordedAnimation>() == 0x330);
