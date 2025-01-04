use core::slice;
use rrplug::{
    high::squirrel_traits::{GetFromSquirrelVm, PushToSquirrelVm, SQVMName},
    mid::{source_alloc::SOURCE_ALLOC, utils::from_char_ptr},
    prelude::*,
};
use serde::{Deserialize, Serialize};
use std::alloc::{GlobalAlloc, Layout};

use crate::{
    bindings::*,
    serde_ext::{
        deserialize_arr, deserialize_cstr_array, deserialize_vector3, serialize_arr,
        serialize_cstr_array, serialize_vector3,
    },
};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct SavedRecordedAnimation {
    #[serde(serialize_with = "serialize_arr")]
    #[serde(deserialize_with = "deserialize_arr")]
    pub unknown_0: [i32; 44],
    #[serde(serialize_with = "serialize_arr")]
    #[serde(deserialize_with = "deserialize_arr")]
    pub unknown_b0: [u8; 64],
    #[serde(serialize_with = "serialize_cstr_array")]
    #[serde(deserialize_with = "deserialize_cstr_array")]
    pub sequences: [*const i8; 47],
    #[serde(serialize_with = "serialize_arr")]
    #[serde(deserialize_with = "deserialize_arr")]
    pub unknown_268: [i32; 34],
    #[serde(serialize_with = "serialize_vector3")]
    #[serde(deserialize_with = "deserialize_vector3")]
    pub origin: Vector3,
    #[serde(serialize_with = "serialize_vector3")]
    #[serde(deserialize_with = "deserialize_vector3")]
    pub angles: Vector3,
    pub frames: Vec<RecordedAnimationFrame>,
    pub layers: Vec<RecordedAnimationLayer>,
}

impl From<RecordedAnimation> for SavedRecordedAnimation {
    fn from(value: RecordedAnimation) -> Self {
        SavedRecordedAnimation {
            unknown_0: value.unknown_0,
            unknown_b0: value.unknown_b0,
            sequences: value.sequences,
            unknown_268: value.unknown_268,
            origin: value.origin,
            angles: value.angles,
            frames: Vec::from(unsafe {
                slice::from_raw_parts(value.frames, value.frame_count as usize)
            }),
            layers: Vec::from(unsafe {
                slice::from_raw_parts(value.layers, value.layer_count as usize)
            }),
        }
    }
}

impl TryInto<RecordedAnimation> for SavedRecordedAnimation {
    type Error = &'static str;

    fn try_into(self) -> Result<RecordedAnimation, Self::Error> {
        // const FRAMES: usize = 3000;
        // const LAYERS: usize = FRAMES;

        // self.frames
        //     .extend((0..FRAMES - self.frames.len()).map(|_| RecordedAnimationFrame::default()));
        // self.layers
        //     .extend((0..LAYERS - self.layers.len()).map(|_| RecordedAnimationLayer::default()));

        Ok(RecordedAnimation {
            unknown_0: self.unknown_0,
            unknown_b0: self.unknown_b0,
            sequences: self.sequences,
            unknown_268: self.unknown_268,
            origin: self.origin,
            angles: self.angles,
            frame_count: self.frames.len() as u32,
            layer_count: self.layers.len() as u32,
            frames: allocate_with_source_alloc(self.frames),
            layers: allocate_with_source_alloc(self.layers),
            loaded_index: 0,
            index: 0,
            not_refcounted: false,
            refcount: 1,
        })
    }
}

impl TryInto<&'static mut RecordedAnimation> for SavedRecordedAnimation {
    type Error = &'static str;

    fn try_into(self) -> Result<&'static mut RecordedAnimation, Self::Error> {
        let recording = unsafe {
            (RECORDING_FUNCTIONS.wait().new_recorded_animation)()
                .as_mut()
                .unwrap_unchecked()
        };

        recording.unknown_0 = self.unknown_0;
        recording.unknown_b0 = self.unknown_b0;
        recording.sequences = self.sequences;
        recording.unknown_268 = self.unknown_268;
        recording.origin = self.origin;
        recording.angles = self.angles;
        recording.frame_count = self.frames.len() as u32;
        recording.layer_count = self.layers.len() as u32;
        self.frames
            .into_iter()
            .enumerate()
            .for_each(|(i, frame)| unsafe { *recording.frames.add(i) = frame });
        self.layers
            .into_iter()
            .enumerate()
            .for_each(|(i, layer)| unsafe { *recording.layers.add(i) = layer });
        recording.loaded_index = 0;
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
            self.index = *(recording_functions.created_recorded_anim_count).cast::<i32>();
            *(recording_functions.created_recorded_anim_count)
                .as_mut()
                .unwrap_unchecked() += 1;

            let buf = SOURCE_ALLOC.alloc(Layout::new::<Self>()).cast::<Self>();
            buf.write(self);
            (recording_functions.insert_anim_in_loaded_list)(buf.cast_const());

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
            .for_each(|(i, thing)| *buf.add(i) = thing);

        buf
    }
}

pub unsafe fn into_c_str(seq: String) -> *mut u8 {
    let ptr =
        SOURCE_ALLOC.alloc(Layout::array::<u8>(seq.len() + 1).expect("should be a correct array"));

    ptr.write_bytes(1, seq.len());
    std::ptr::copy_nonoverlapping(seq.as_ptr(), ptr, seq.len());
    ptr.add(seq.len()).write(b'\0');
    ptr
}
