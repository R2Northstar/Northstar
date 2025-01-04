use rrplug::{offset_functions, prelude::*};
use serde::{Deserialize, Serialize};
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
#[derive(Debug, Clone, Default, Deserialize, Serialize, PartialEq, Eq)]
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
#[derive(Debug, Clone, Default, Deserialize, Serialize, PartialEq, Eq)]
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
    pub unk_43: bool,
}

#[repr(C)]
#[derive(Debug, Clone)]
pub struct RecordedAnimation {
    pub unknown_0: [i32; 44],
    pub unknown_b0: [u8; 64],
    pub sequences: [*const c_char; 47],
    pub unknown_268: [i32; 34],
    pub origin: Vector3,
    pub angles: Vector3,
    pub frames: *mut RecordedAnimationFrame,
    pub layers: *mut RecordedAnimationLayer,
    pub frame_count: u32,
    pub layer_count: u32,
    pub loaded_index: u64,
    pub index: i32,
    pub not_refcounted: bool,
    pub refcount: u8,
}

impl PartialEq for RecordedAnimation {
    fn eq(&self, other: &Self) -> bool {
        self.unknown_0 == other.unknown_0
            && self.unknown_b0 == other.unknown_b0
            && self.unknown_268 == other.unknown_268
            && self.origin == other.origin
            && self.angles == other.angles
            && unsafe {
                slice::from_raw_parts(self.frames, self.frame_count as usize)
                    == slice::from_raw_parts(other.frames, other.frame_count as usize)
                    && slice::from_raw_parts(self.layers, self.layer_count as usize)
                        == slice::from_raw_parts(other.layers, other.layer_count as usize)
            }
            && self.frame_count == other.frame_count
            && self.layer_count == other.layer_count
            && self.loaded_index == other.loaded_index
    }
}

static _ASSERT_RECORDED_ANIMATION_LAYER: () = assert!(size_of::<RecordedAnimationLayer>() == 0x24);
static _ASSERT_RECORDED_ANIMATION_FRAME: () = assert!(size_of::<RecordedAnimationFrame>() == 0x44);
static _ASSERT_RECORDED_ANIMATION: () = assert!(size_of::<RecordedAnimation>() == 0x330);
