{
  plugin,
  version,
  buildType ? "release",
  lib,
  rustPlatform,
  pkgs,
  rust-bin,
}:
let
  cargoLock = (import ./cargo_lock.nix { });
in
rustPlatform.buildRustPackage {
  name = plugin;
  inherit version;

  src = ../.;

  inherit buildType;
  rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ../toolchain.toml;

  nativeBuildInputs = [
    (rust-bin.fromRustupToolchainFile ../toolchain.toml)
    pkgs.pkg-config
  ];

  meta = {
    description = "${plugin} is a plugin for northstar";
    homepage = "https://github.com/R2Northstar/NorthstarPlugins";
    license = lib.licenses.mit;
    maintainers = [ "cat_or_not" ];
  };

  inherit cargoLock;
}
