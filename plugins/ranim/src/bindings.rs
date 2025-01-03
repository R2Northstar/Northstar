use rrplug::prelude::*;
use serde::{Deserialize, Serialize};
use std::os::raw::c_char;

#[repr(C)]
#[derive(Clone, Deserialize, Serialize)]
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
#[derive(Clone, Deserialize, Serialize)]
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
#[derive(Clone)]
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
