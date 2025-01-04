use core::slice;
use rrplug::{
    high::squirrel_traits::{GetFromSquirrelVm, PushToSquirrelVm, SQVMName},
    mid::{source_alloc::SOURCE_ALLOC, utils::from_char_ptr},
    prelude::*,
};
use serde::{Deserialize, Serialize};
use std::alloc::{GlobalAlloc, Layout};

use crate::bindings::*;

#[derive(Clone, Debug, Default, Deserialize, Serialize)]
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
}

impl From<RecordedAnimation> for SavedRecordedAnimation {
    fn from(value: RecordedAnimation) -> Self {
        SavedRecordedAnimation {
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
        }
    }
}

impl TryInto<RecordedAnimation> for SavedRecordedAnimation {
    type Error = &'static str;

    fn try_into(mut self) -> Result<RecordedAnimation, Self::Error> {
        const FRAMES: usize = 3000;
        const LAYERS: usize = FRAMES;
        const SEQUENCES: usize = 47;

        self.sequences
            .extend((0..SEQUENCES - self.sequences.len()).map(|_| String::new()));
        self.frames
            .extend((0..FRAMES - self.frames.len()).map(|_| RecordedAnimationFrame::default()));
        self.layers
            .extend((0..LAYERS - self.layers.len()).map(|_| RecordedAnimationLayer::default()));

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
                        log::info!("sequence: {seq}");
                        unsafe {
                            let ptr =
                                SOURCE_ALLOC.get_underlying_alloc().Alloc(seq.len() + 1) as *mut u8;

                            ptr.write_bytes(1, seq.len());
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
            frames: allocate_with_source_alloc(self.frames),
            layers: allocate_with_source_alloc(self.layers),
            frame_count: self.frame_count,
            layer_count: self.layer_count,
            loaded_index: self.loaded_index,
            index: 0,
            not_refcounted: false,
            refcount: 1,
        })
    }
}

impl TryInto<&'static mut RecordedAnimation> for SavedRecordedAnimation {
    type Error = &'static str;

    fn try_into(mut self) -> Result<&'static mut RecordedAnimation, Self::Error> {
        let recording = unsafe {
            (RECORDING_FUNCTIONS.wait().new_recorded_animation)()
                .as_mut()
                .unwrap_unchecked()
        };
        self.sequences
            .extend((0..47 - self.sequences.len()).map(|_| String::new()));

        assert_eq!(self.frame_count, self.frames.len() as u32);
        assert_eq!(self.layer_count, self.layers.len() as u32);

        recording.unknown_0 = self
            .unknown_0
            .try_into()
            .map_err(|_| "unknown_0 had a mismatched size")?;
        recording.unknown_b0 = self
            .unknown_b0
            .try_into()
            .map_err(|_| "unknown_b0 had a mismatched size")?;
        recording.sequences = self
            .sequences
            .into_iter()
            .map(|seq| {
                if seq.is_empty() {
                    std::ptr::null()
                } else {
                    log::info!("sequence: {seq}");
                    unsafe {
                        let ptr =
                            SOURCE_ALLOC.get_underlying_alloc().Alloc(seq.len() + 1) as *mut u8;

                        ptr.write_bytes(1, seq.len());
                        std::ptr::copy_nonoverlapping(seq.as_ptr(), ptr, seq.len());
                        ptr.add(seq.len()).write(b'\0');

                        ptr
                    }
                }
            })
            .map(|ptr| ptr.cast::<i8>())
            .collect::<Vec<_>>()
            .try_into()
            .map_err(|_| "sequences had a mismatched size")?;
        recording.unknown_268 = self
            .unknown_268
            .try_into()
            .map_err(|_| "unknown_268 had a mismatched size")?;
        recording.origin = self.origin.into();
        recording.angles = self.angles.into();
        self.frames
            .into_iter()
            .enumerate()
            .for_each(|(i, frame)| unsafe { recording.frames.add(i).write(frame) });
        self.layers
            .into_iter()
            .enumerate()
            .for_each(|(i, layer)| unsafe { recording.layers.add(i).write(layer) });
        recording.frame_count = self.frame_count;
        recording.layer_count = self.layer_count;
        recording.loaded_index = self.loaded_index;
        recording.index = 0;
        recording.not_refcounted = false;
        recording.refcount = 1;

        Ok(recording)
    }
}

impl PushToSquirrelVm for RecordedAnimation {
    fn push_to_sqvm(
        mut self,
        sqvm: std::ptr::NonNull<HSquirrelVM>,
        _sqfunctions: &SquirrelFunctions,
    ) {
        let recording_functions = RECORDING_FUNCTIONS.wait();
        unsafe {
            *(recording_functions.created_recorded_anim_count)
                .as_mut()
                .unwrap_unchecked() += 1;
            self.index = *(recording_functions.created_recorded_anim_count).cast::<i32>();

            let buf = SOURCE_ALLOC.alloc(Layout::new::<Self>()).cast::<Self>();
            buf.write(self);

            log::info!("{:#?}", buf.as_ref().unwrap_unchecked());

            buf.as_ref()
                .unwrap_unchecked()
                .sequences
                .iter()
                .copied()
                .enumerate()
                .filter(|(_, ptr)| !ptr.is_null())
                .map(|(i, ptr)| (i, from_char_ptr(ptr)))
                .for_each(|(i, str)| log::info!("{i} sequence pushed with {str}"));

            (recording_functions.insert_anim_in_loaded_list)(buf.cast_const());
            (recording_functions.sq_pushrecordedanimation)(sqvm.as_ptr(), buf)
        }
    }
}

impl PushToSquirrelVm for &mut RecordedAnimation {
    fn push_to_sqvm(self, sqvm: std::ptr::NonNull<HSquirrelVM>, _sqfunctions: &SquirrelFunctions) {
        unsafe { (RECORDING_FUNCTIONS.wait().sq_pushrecordedanimation)(sqvm.as_ptr(), self) }
    }
}

impl GetFromSquirrelVm for &mut RecordedAnimation {
    fn get_from_sqvm(
        sqvm: std::ptr::NonNull<HSquirrelVM>,
        _sqfunctions: &'static SquirrelFunctions,
        stack_pos: i32,
    ) -> Self {
        unsafe {
            // this stack_pos + 1 is weird; actual respawn moment
            (RECORDING_FUNCTIONS.wait().sq_getrecordedanimation)(sqvm.as_ptr(), stack_pos + 1)
                .as_mut()
                .expect("RecordedAnimation should exist")
        }
    }
}

impl SQVMName for &mut RecordedAnimation {
    fn get_sqvm_name() -> String {
        "userdata".to_string()
    }
}

impl SQVMName for RecordedAnimation {
    fn get_sqvm_name() -> String {
        "userdata".to_string()
    }
}

fn allocate_with_source_alloc<T>(vec: Vec<T>) -> *mut T {
    unsafe {
        let buf = SOURCE_ALLOC.alloc(Layout::array::<T>(vec.len()).expect("skill issue")) as *mut T;

        vec.into_iter()
            .enumerate()
            .for_each(|(i, thing)| buf.add(i).write(thing));

        buf
    }
}
