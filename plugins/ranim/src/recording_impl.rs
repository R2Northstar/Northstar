use core::slice;
use rrplug::{
    high::squirrel_traits::{GetFromSquirrelVm, PushToSquirrelVm, SQVMName},
    mid::{source_alloc::SOURCE_ALLOC, utils::str_from_char_ptr},
    prelude::*,
};
use std::{
    alloc::{GlobalAlloc, Layout},
    mem,
    ops::Not,
    ptr,
};

use crate::bindings::*;

impl From<RecordedAnimation> for Vec<u8> {
    fn from(value: RecordedAnimation) -> Self {
        bytemuck::bytes_of(&value)
            .iter()
            .copied()
            .chain(
                unsafe { slice::from_raw_parts_mut(value.frames, value.frame_count as usize) }
                    .iter()
                    .flat_map(bytemuck::bytes_of)
                    .copied(),
            )
            .chain(
                unsafe { slice::from_raw_parts_mut(value.layers, value.layer_count as usize) }
                    .iter()
                    .flat_map(bytemuck::bytes_of)
                    .copied(),
            )
            .chain(value.sequences.iter().flat_map(|ptr| {
                let str = ptr
                    .is_null()
                    .not()
                    .then(|| unsafe { str_from_char_ptr(*ptr) })
                    .flatten()
                    .unwrap_or_default()
                    .len();
                bytemuck::bytes_of(&str)
                    .iter()
                    .copied()
                    .chain(unsafe {
                        ptr.is_null()
                            .not()
                            .then(|| str_from_char_ptr(*ptr))
                            .flatten()
                            .unwrap_or_default()
                            .as_bytes()
                            .to_vec()
                    })
                    .collect::<Vec<_>>()
            }))
            .collect()
    }
}

impl TryFrom<Vec<u8>> for &'static mut RecordedAnimation {
    type Error = String;

    fn try_from(val: Vec<u8>) -> Result<Self, Self::Error> {
        let val = &mut val.as_slice();
        let recording = unsafe {
            (RECORDING_FUNCTIONS.wait().new_recorded_animation)()
                .as_mut()
                .unwrap_unchecked()
        };

        let recording_from_bytes = bytemuck::try_from_bytes::<RecordedAnimation>(drain_array(
            val,
            mem::size_of::<RecordedAnimation>(),
        ))
        .map_err(|err| format!("{err:?} at recording"))?;

        unsafe { ptr::write(recording, *recording_from_bytes) };

        if let Some(Err(err)) = (0..recording.frame_count as usize)
            .map(|i| unsafe {
                *recording.frames.add(i) = *bytemuck::try_from_bytes::<RecordedAnimationFrame>(
                    drain_array(val, mem::size_of::<RecordedAnimationFrame>()),
                )?;

                Ok::<_, bytemuck::PodCastError>(())
            })
            .find(|r| r.is_err())
        {
            Err(err).map_err(|err| format!("{err:?} at frame"))?
        }

        if let Some(Err(err)) = (0..recording.layer_count as usize)
            .map(|i| unsafe {
                *recording.layers.add(i) = *bytemuck::try_from_bytes::<RecordedAnimationLayer>(
                    drain_array(val, mem::size_of::<RecordedAnimationLayer>()),
                )?;

                Ok::<_, bytemuck::PodCastError>(())
            })
            .find(|r| r.is_err())
        {
            Err(err).map_err(|err| format!("{err:?} at layer"))?
        }

        if let Some(Err(err)) = recording
            .sequences
            .iter_mut()
            .enumerate()
            .map(|(i, sequence)| {
                let sequence_size = *bytemuck::try_from_bytes::<usize>(
                    drain_array(val, mem::size_of::<usize>())
                        .to_vec()
                        .as_slice(),
                )
                .map_err(|err| format!("{err:?} at sequences {i}"))?;
                *sequence = unsafe {
                    into_c_str(
                        str::from_utf8(drain_array(val, sequence_size))
                            .expect("all sequences should be utf8")
                            .to_owned(),
                    )
                    .cast_const()
                    .cast()
                };

                Ok::<_, String>(())
            })
            .find(|r| r.is_err())
        {
            Err(err)?
        }

        Ok(recording)
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

pub unsafe fn into_c_str(seq: String) -> *mut u8 {
    let ptr =
        SOURCE_ALLOC.alloc(Layout::array::<u8>(seq.len() + 1).expect("should be a correct array"));

    ptr.write_bytes(1, seq.len());
    std::ptr::copy_nonoverlapping(seq.as_ptr(), ptr, seq.len());
    ptr.add(seq.len()).write(b'\0');
    ptr
}

fn drain_array<'a, T>(array: &mut &'a [T], amount: usize) -> &'a [T] {
    let return_value = &array[..amount];
    *array = &array[amount..];
    return_value
}
