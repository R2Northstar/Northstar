use mid::northstar::NORTHSTAR_DATA;
use rrplug::prelude::*;
use std::{fs, io::Write, path::PathBuf};

use crate::{bindings::RecordedAnimation, recording_impl::SavedRecordedAnimation, NS_DIR};

#[allow(unused)]
const USER_DATA_ID: u64 = 18444492235241160706;

pub fn register_sq_function() {
    register_sq_functions(save_recorded_animation);
    register_sq_functions(read_recorded_animation);
    register_sq_functions(unload_thyself);
    register_sq_functions(pipe_recording);
}

#[rrplug::sqfunction(VM = "SERVER", ExportName = "RSaveRecordedAnimation")]
fn save_recorded_animation(recording: &mut RecordedAnimation, name: String) -> Result<(), String> {
    let org = recording.clone();
    let recording: SavedRecordedAnimation = recording.clone().into();

    fs::File::create(name_to_path(name.clone())?)
        .map_err(|err| err.to_string())?
        .write_all(&bincode::serialize(&recording).map_err(|err| err.to_string())?)
        .map_err(|err| err.to_string())?;

    assert_eq!(
        org,
        bincode::deserialize::<SavedRecordedAnimation>(
            &fs::read(name_to_path(name)?).map_err(|err| err.to_string())?,
        )
        .map_err(|err| err.to_string())?
        .try_into()
        .map_err(|err: &str| err.to_string())?
    );

    Ok(())
}

#[rrplug::sqfunction(VM = "SERVER", ExportName = "RReadRecordedAnimation")]
fn read_recorded_animation(name: String) -> Result<&'static mut RecordedAnimation, String> {
    bincode::deserialize::<SavedRecordedAnimation>(
        &fs::read(name_to_path(name)?).map_err(|err| err.to_string())?,
    )
    .map_err(|err| err.to_string())?
    .try_into()
    .map_err(|err: &str| err.to_string())
}

#[rrplug::sqfunction(VM = "SERVER", ExportName = "RPipeRecordedAnimation")]
fn pipe_recording(recording: &'static mut RecordedAnimation) -> &'static mut RecordedAnimation {
    log::info!("org");
    for i in 0..recording.frame_count as usize {
        log::info!("{:?}", unsafe {
            recording.frames.add(i).as_ref().unwrap_unchecked().gap_38
        });
    }

    let recording_copy: SavedRecordedAnimation = recording.clone().into();
    let recording_copy: &mut RecordedAnimation = recording_copy.try_into().unwrap();

    log::info!("copy");
    for i in 0..recording_copy.frame_count as usize {
        log::info!("{:?}", unsafe {
            recording_copy
                .frames
                .add(i)
                .as_ref()
                .unwrap_unchecked()
                .gap_38
        });
    }

    assert_eq!(recording, recording_copy);

    recording_copy
}

#[rrplug::sqfunction(VM = "SERVER", ExportName = "RUnload")]
fn unload_thyself() {
    unsafe {
        NORTHSTAR_DATA
            .wait()
            .sys()
            .unload(NORTHSTAR_DATA.wait().handle())
    }
}

fn name_to_path(name: impl ToString) -> Result<PathBuf, String> {
    let name = name.to_string();
    if name
        .chars()
        .any(|c| !c.is_alphanumeric() && c != '_' && c != '-')
    {
        return Err(
            "name didn't pass the filter, should be a only have alphanumeric values, _ or -"
                .to_string(),
        );
    }

    let mut path = NS_DIR
        .get()
        .expect("NS_DIR should be init")
        .join("recordings")
        .join(name);
    path.set_extension("anim");

    Ok(path)
}
