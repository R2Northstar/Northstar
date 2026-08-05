{
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
        system: with perSystem.${system}; {
          discordrpc =
            pkgs-cross.callPackage
              (
                {
                  lib,
                  makeRustPlatform,
                  toolchain,
                }:
                (makeRustPlatform {
                  cargo = toolchain;
                  rustc = toolchain;
                }).buildRustPackage
                  (finalAttrs: {
                    name = "DiscordRPC";
                    version = "14.0.0";

                    src = ./.;

                    meta = {
                      description = "discord rpc impl for northstar";
                      homepage = "https://github.com/R2Northstar/NorthstarDiscordRPC";
                      license = lib.licenses.unlicense;
                      maintainers = [ "cat_or_not" ];
                    };

                    cargoLock = {
                      lockFile = ./Cargo.lock;
                    };
                  })
              )
              {
                inherit toolchain;
              };

          default = self.packages.${system}.discordrpc;
        }
      );

      devShells = eachSystem (
        system: with perSystem.${system}; {
          default = pkgs.mkShell {
            buildInputs = with pkgs-cross; [
              windows.mingw_w64_headers
              windows.mcfgthreads
              windows.pthreads
            ];

            nativeBuildInputs = [
              toolchain
            ];
          };
        }
      );
    };
}
