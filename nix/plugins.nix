{
  plugin,
  version,
  buildType ? "release",
  lib,
  makeRustPlatform,
  toolchain,
}:
let
  cargoLock = (import ./cargo_lock.nix { });
in
(makeRustPlatform {
  cargo = toolchain;
  rustc = toolchain;
}).buildRustPackage
  {
    name = plugin;
    inherit version;

    src = lib.fileset.toSource {
      root = ../plugins;
      fileset = lib.fileset.unions [
        ../plugins/Cargo.toml
        ../plugins/Cargo.lock
        ../plugins/${plugin}
      ];
    };

    inherit buildType;

    cargoBuildFlags = [
      "--package"
      plugin
    ];

    meta = {
      description = "${plugin} is a plugin for northstar";
      homepage = "https://github.com/R2Northstar/Northstar";
      license = lib.licenses.mit;
      maintainers = [ "cat_or_not" ];
    };

    inherit cargoLock;
  }
