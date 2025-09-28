{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      utils,
      rust-overlay,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
          crossSystem = {
            config = "x86_64-w64-mingw32";
            libc = "msvcrt";
          };
          config.allowUnsupportedSystem = true;
        };

        toolchain = (pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml);
      in
      {
        formatter = (import nixpkgs { inherit system; }).nixfmt-rfc-style;

        packages = {
          discordrpc =
            pkgs.callPackage
              (
                {
                  lib,
                  rustPlatform,
                  rust-bin,
                }:
                rustPlatform.buildRustPackage (final: {
                  name = "DiscordRPC";
                  version = "14.0.0";

                  rustToolchain = rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
                  nativeBuildInputs = [
                    (rust-bin.fromRustupToolchainFile ./rust-toolchain.toml)
                  ];

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
                rust-bin = rust-overlay.lib.mkRustBin { } pkgs.buildPackages;
              };

          default = self.packages.${system}.discordrpc;
        };

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            windows.mingw_w64_headers
            # windows.mcfgthreads
            windows.pthreads
            toolchain
          ];

          nativeBuildInputs = [
            toolchain
          ];
        };
      }
    );
}
