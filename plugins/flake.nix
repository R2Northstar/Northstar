{
  description = "A collection of plugins for northstar";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-win.url = "github:nixos/nixpkgs/24.11";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-win,
      flake-utils,
      rust-overlay,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        native-pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };
        # TODO: remove this shitty system and replace it with msvc or a proper cross setup with mingw
        pkgs = import nixpkgs-win {
          inherit system;
          overlays = [ (import rust-overlay) ];
          crossSystem = {
            config = "x86_64-w64-mingw32";
            libc = "msvcrt";
          };
          config.microsoftVisualStudioLicenseAccepted = true;
        };
        toolchain = (pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./toolchain.toml);
      in
      {
        formatter = native-pkgs.nixfmt-tree;
        packages =
          let
            version = "0.1.0";
          in
          let
            mkPluginBuildType =
              plugin: buildType:
              pkgs.callPackage ./nix/plugins.nix {
                rust-bin = rust-overlay.lib.mkRustBin { } pkgs.buildPackages;
                inherit plugin version buildType;
              };
            mkPlugin = plugin: mkPluginBuildType plugin "release";
          in
          {
            ranim = mkPlugin "ranim";
            serialized-io = mkPlugin "serialized_io";
            default = native-pkgs.symlinkJoin {
              name = "plugins";
              paths = with self.packages.${system}; [
                ranim
                serialized-io
              ];
            };
            all = native-pkgs.symlinkJoin {
              name = "plugins";
              paths = with self.packages.${system}; [
                ranim
                serialized-io
              ];
            };
          };

        devShells = {
          win-shell = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              toolchain
              pkg-config
            ];

            buildInputs = with pkgs; [
              windows.mingw_w64_headers
              windows.pthreads
            ];
          };

          default = self.devShells.${system}.win-shell;
        };

        nix.settings = {
          substituters = [
            "https://cache.nixos.org/"
          ];
          trusted-public-keys = [
          ];
        };
      }
    );
}
