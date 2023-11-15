extern crate windres;
use windres::Build;

fn main() {
    Build::new()
        .compile("manifest/Resource.rc")
        .expect("failed to include ressouces in the dll");
}
