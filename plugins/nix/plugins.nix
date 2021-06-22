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

    src = ../.;

    inherit buildType;

    cargoBuildFlags = [
      "--package"
      plugin
    ];

    meta = {
      description = "${plugin} is a plugin for northstar";
      homepage = "https://github.com/R2Northstar/NorthstarPlugins";
      license = lib.licenses.mit;
      maintainers = [ "cat_or_not" ];
    };

    inherit cargoLock;
  }
