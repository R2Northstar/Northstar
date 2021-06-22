{
  description = "A collection of plugins for northstar";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      eachSystem = nixpkgs.lib.genAttrs systems;

      perSystem = eachSystem (system: rec {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };
        pkgs-cross = pkgs.pkgsCross.mingwW64;
        toolchain = (pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml);
      });
    in
    {
      formatter = eachSystem (system: perSystem.${system}.pkgs.nixfmt-tree);

      packages = eachSystem (
        system:
        with perSystem.${system};
        let
          version = "0.1.0";
          mkPluginBuildType =
            plugin: buildType:
            pkgs-cross.callPackage ./nix/plugins.nix {
              inherit plugin version buildType;
              toolchain = pkgs-cross.pkgsBuildHost.rust-bin.nightly."${ (nixpkgs.lib.last (builtins.split "nightly-" (fromTOML (builtins.readFile ./rust-toolchain.toml)).toolchain.channel))}".default;
            };
          mkPlugin = plugin: mkPluginBuildType plugin "release";
        in
        {
          ranim = mkPlugin "ranim";
          serialized-io = mkPlugin "serialized_io";
          default = pkgs.symlinkJoin {
            name = "plugins";
            paths = with self.packages.${system}; [
              ranim
              serialized-io
            ];
          };
          all = pkgs.symlinkJoin {
            name = "plugins";
            paths = with self.packages.${system}; [
              ranim
              serialized-io
            ];
          };
        }
      );

      devShells = eachSystem (
        system: with perSystem.${system}; {
          win-shell = pkgs-cross.mkShell {
            nativeBuildInputs = with pkgs; [
              toolchain
              pkg-config
            ];

            buildInputs = with pkgs-cross; [
              windows.mingw_w64_headers
              windows.pthreads
            ];
          };

          default = self.devShells.${system}.win-shell;
        }
      );
    };
}
