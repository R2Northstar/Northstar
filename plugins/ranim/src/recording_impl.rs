use core::slice;

use mid::{
    source_alloc::{IMemAlloc, SOURCE_ALLOC},
    utils::from_char_ptr,
};
use rrplug::prelude::*;
use serde::{Deserialize, Serialize};

use crate::bindings::*;

#[derive(Deserialize, Serialize)]
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
        let alloc = SOURCE_ALLOC.get_underlying_alloc();

        let save = SavedRecordedAnimation {
            unknown_0: value.unknown_0.to_vec(),
            unknown_b0: value.unknown_b0.to_vec(),
            sequences: value
                .sequences
                .iter()
                .copied()
                .take_while(|ptr| !ptr.is_null())
                .map(|ptr| unsafe {
                    let s = from_char_ptr(ptr);
                    alloc.Free(ptr.cast_mut().cast());
                    s
                })
                .collect(),
            unknown_268: value.unknown_0.to_vec(),
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

        unsafe {
            alloc.Free(value.frames.cast());
            alloc.Free(value.layers.cast());
        }

        save
    }
}

impl TryInto<RecordedAnimation> for SavedRecordedAnimation {
    type Error = &'static str;

    fn try_into(mut self) -> Result<RecordedAnimation, Self::Error> {
        self.sequences.reserve_exact(self.sequences.len() - 47);
        self.sequences.fill(String::new());

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
            not_refcounted: true,
            refcount: 0,
        })
    }
}

impl Drop for RecordedAnimation {
    fn drop(&mut self) {
        // allocates extra stuff but I am too lazy lol
        let _drop: SavedRecordedAnimation = self.clone().into();
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
