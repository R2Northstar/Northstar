use core::slice;
use std::alloc::{GlobalAlloc, Layout};

use high::squirrel_traits::{GetFromSquirrelVm, PushToSquirrelVm, SQVMName};
use mid::{
    source_alloc::{IMemAlloc, SOURCE_ALLOC},
    utils::from_char_ptr,
};
use rrplug::prelude::*;
use serde::{Deserialize, Serialize};

use crate::bindings::*;

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct SavedRecordedAnimation {
    pub unknown_0: Vec<i32>,
    pub unknown_b0: Vec<u8>,
    pub sequences: Vec<String>,
    pub unknown_268: Vec<i32>,
    pub origin: [f32; 3],
    pub angles: [f32; 3],
    pub frames: Vec<RecordedAnimationFrame>,
    pub layers: Vec<RecordedAnimationLayer>,
    pub frame_count: u32,
    pub layer_count: u32,
    pub loaded_index: u64,
    pub index: i32,
}

impl From<RecordedAnimation> for SavedRecordedAnimation {
    fn from(value: RecordedAnimation) -> Self {
        let save = SavedRecordedAnimation {
            unknown_0: value.unknown_0.to_vec(),
            unknown_b0: value.unknown_b0.to_vec(),
            sequences: value
                .sequences
                .iter()
                .copied()
                .take_while(|ptr| !ptr.is_null())
                .map(|ptr| unsafe { from_char_ptr(ptr) })
                .collect(),
            unknown_268: value.unknown_268.to_vec(),
            origin: [value.origin.x, value.origin.y, value.origin.z],
            angles: [value.angles.x, value.angles.y, value.angles.z],
            frames: Vec::from(unsafe {
                slice::from_raw_parts(value.frames, value.frame_count as usize)
            }),
            layers: Vec::from(unsafe {
                slice::from_raw_parts(value.layers, value.layer_count as usize)
            }),
            frame_count: value.frame_count,
            layer_count: value.layer_count,
            loaded_index: value.loaded_index,
            index: value.index,
        };

        save
    }
}

impl TryInto<RecordedAnimation> for SavedRecordedAnimation {
    type Error = &'static str;

    fn try_into(mut self) -> Result<RecordedAnimation, Self::Error> {
        self.sequences
            .extend((0..47 - self.sequences.len()).map(|_| String::new()));

        assert_eq!(self.frame_count, self.frames.len() as u32);
        assert_eq!(self.layer_count, self.layers.len() as u32);

        let alloc = SOURCE_ALLOC.get_underlying_alloc();

        Ok(RecordedAnimation {
            unknown_0: self
                .unknown_0
                .try_into()
                .map_err(|_| "unknown_0 had a mismatched size")?,

            unknown_b0: self
                .unknown_b0
                .try_into()
                .map_err(|_| "unknown_b0 had a mismatched size")?,
            sequences: self
                .sequences
                .into_iter()
                .map(|seq| {
                    if seq.is_empty() {
                        std::ptr::null()
                    } else {
                        unsafe {
                            let ptr = alloc.Alloc(seq.len() + 1) as *mut u8;

                            std::ptr::copy_nonoverlapping(seq.as_ptr(), ptr, seq.len());
                            ptr.add(seq.len()).write(b'\0');

                            ptr
                        }
                    }
                })
                .map(|ptr| ptr.cast::<i8>())
                .collect::<Vec<_>>()
                .try_into()
                .map_err(|_| "sequences had a mismatched size")?,
            unknown_268: self
                .unknown_268
                .try_into()
                .map_err(|_| "unknown_268 had a mismatched size")?,
            origin: self.origin.into(),
            angles: self.angles.into(),
            frames: allocate_with_source_alloc(self.frames, alloc),
            layers: allocate_with_source_alloc(self.layers, alloc),
            frame_count: self.frame_count,
            layer_count: self.layer_count,
            loaded_index: self.loaded_index,
            index: self.index,
            not_refcounted: false,
            refcount: 1,
        })
    }
}

impl PushToSquirrelVm for RecordedAnimation {
    fn push_to_sqvm(self, sqvm: std::ptr::NonNull<HSquirrelVM>, _sqfunctions: &SquirrelFunctions) {
        unsafe {
            let buf = SOURCE_ALLOC.alloc(Layout::new::<Self>()).cast::<Self>();
            buf.write(self);

            (RECORDING_FUNCTIONS.wait().sq_pushrecordedanimation)(sqvm.as_ptr(), buf)
        }
    }
}

impl GetFromSquirrelVm for &mut RecordedAnimation {
    fn get_from_sqvm(
        sqvm: std::ptr::NonNull<HSquirrelVM>,
        _sqfunctions: &'static SquirrelFunctions,
        stack_pos: i32,
    ) -> Self {
        unsafe {
            (RECORDING_FUNCTIONS.wait().sq_getrecordedanimation)(sqvm.as_ptr(), stack_pos)
                .as_mut()
                .expect("RecordedAnimation should exist")
        }
    }

    fn get_from_sqvm_internal(
        sqvm: std::ptr::NonNull<HSquirrelVM>,
        sqfunctions: &'static SquirrelFunctions,
        stack_pos: &mut i32,
    ) -> Self {
        *stack_pos += 2;
        Self::get_from_sqvm(sqvm, sqfunctions, 2)
    }
}

impl SQVMName for &mut RecordedAnimation {
    fn get_sqvm_name() -> String {
        "userdata".to_string()
    }
}

fn allocate_with_source_alloc<T>(vec: Vec<T>, alloc: &IMemAlloc) -> *mut T {
    unsafe {
        let buf = alloc.Alloc(vec.len() * std::mem::size_of::<T>()) as *mut T;

        vec.into_iter()
            .enumerate()
            .for_each(|(i, thing)| buf.add(i).write(thing));

        buf
    }
}
