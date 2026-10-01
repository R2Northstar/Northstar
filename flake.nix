{
  description = "A collection of plugins for northstar";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    clang-16-nixpkgs.url = "github:NixOS/nixpkgs/24.11"; # needed for clang-format-16

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      clang-16-nixpkgs,
      rust-overlay,
      treefmt-nix,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
      ];
      eachSystem = nixpkgs.lib.genAttrs systems;

      perSystem = eachSystem (system: rec {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
          config = {
            allowUnsupportedSystem = true;
            allowUnfree = true;
            microsoftVisualStudioLicenseAccepted = true;
          };
        };
        plugins = {
          pkgs-cross = pkgs.pkgsCross.mingwW64;
          toolchain = (pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./plugins/rust-toolchain.toml);
        };
        launcher = pkgs.callPackage ./nix/launcher-toolchain.nix { };
      });

      # Eval the treefmt modules from treefmt.nix
      treefmtEval = eachSystem (
        system: pkgs:
        treefmt-nix.lib.evalModule pkgs (
          { ... }:
          {
            # Used to find the project root
            projectRootFile = "flake.nix";

            # Add formaters for some other langs
            programs.clang-format.enable = true;
            programs.cmake-format.enable = true;
            programs.nixfmt.enable = true;
            programs.rustfmt.enable = true;

            # settings
            settings.formatter.rustfmt.package = perSystem.${system}.plugins.toolchain;
            settings.formatter.clang-format = {
              package = clang-16-nixpkgs.legacyPackages.${system}.llvmPackages_16.clang-tools;
              command = "${
                clang-16-nixpkgs.legacyPackages.${system}.llvmPackages_16.clang-tools
              }/bin/clang-format";
              options = [
                "-i"
                "--style=file"
              ];
              excludes = [
                "launcher/primedev/include/**"
                "launcher/primedev/thirdparty/**"
                "launcher/primedev/wsockproxy/**"
                "launcher/primedev/dllmain.cpp"
                "launcher/primedev/ns_version.h"
                "launcher/primedev/pch.h"
                "launcher/primedev/resource1.h"
              ];
            };
          }
        )
      );
    in
    {
      formatter = eachSystem (
        system: (treefmtEval.${system} perSystem.${system}.pkgs).config.build.wrapper
      );

      packages = eachSystem (
        system:
        with perSystem.${system};
        let
          version = "1.31.13";
          mkPluginBuildType =
            plugin: buildType:
            plugins.pkgs-cross.callPackage ./nix/plugins.nix {
              inherit plugin version buildType;
              toolchain =
                plugins.pkgs-cross.pkgsBuildHost.rust-bin.nightly."${
                  (nixpkgs.lib.last (
                    builtins.split "nightly-" (fromTOML (builtins.readFile ./plugins/rust-toolchain.toml))
                    .toolchain.channel
                  ))
                }".default;
            };
          mkPlugin = plugin: mkPluginBuildType plugin "release";
        in
        {
          ranim = mkPlugin "ranim";
          serialized-io = mkPlugin "serialized_io";
          discordrpc = mkPlugin "discordrpc";
          plugins = pkgs.symlinkJoin {
            name = "plugins";
            paths = with self.packages.${system}; [
              ranim
              serialized-io
              discordrpc
            ];
          };
          launcher = pkgs.callPackage ./nix/launcher.nix { inherit launcher; };
        }
      );

      devShells = eachSystem (
        system: with perSystem.${system}; {
          plugins = plugins.pkgs-cross.mkShell {
            nativeBuildInputs = with pkgs; [
              plugins.toolchain
              pkg-config
            ];

            buildInputs =
              let
                inherit (plugins.pkgs-cross) windows;
              in
              [
                windows.mingw_w64_headers
                windows.pthreads
              ];
          };

          launcher = pkgs.mkShellNoCC {
            nativeBuildInputs = with pkgs; [
              launcher.cross.buildPackages.cmake
              launcher.cross.buildPackages.ninja
              llvmPackages.clang-unwrapped
              llvmPackages.bintools-unwrapped
              perl
              cross.zlib
              pkg-config

              # this helpful for testing the dev shell so I am not removing this yet
              (pkgs.writeShellScriptBin "rebuild-ns" ''
                rm -rf build/
                mkdir -p build

                ${launcher.mkBuildDirShell}
                cmake --build build/
              '')
              (pkgs.writeShellScriptBin "generate-build-ns" launcher.mkBuildDirShell)
            ];

            buildInputs = [
              launcher.cross.windows.sdk
            ];

            shellHook = /* bash */ ''
              cp -f ${pkgs.writeText ".clangd" ''
                CompileFlags:
                  CompilationDatabase: "build"
              ''} launcher/.clangd
              echo "Northstar shell init"
              echo "    generate-build-ns: generate build files for cmake"
            '';
          };
        }
      );

      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.check self;
      });
    };
}
