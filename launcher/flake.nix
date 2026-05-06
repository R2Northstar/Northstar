{
  description = "NorthstarLauncher - MSVC cross build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-24-11.url = "github:NixOS/nixpkgs/24.11"; # needed for clang-format-16

    flake-utils.url = "github:numtide/flake-utils";

    treefmt-nix.url = "github:numtide/treefmt-nix";

    self.submodules = true; # flakes don't copy submodles by default so we need this
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-24-11,
      flake-utils,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ ];
          config = {
            allowUnsupportedSystem = true;
            allowUnfree = true;
            microsoftVisualStudioLicenseAccepted = true;
          };
        };

        cross = pkgs.pkgsCross.x86_64-windows;

        toolchainHelper = rec {
          base = cross.windows.sdk;
          arch = "x64";
          MSVC_INCLUDE = "${base}/crt/include";
          MSVC_LIB = "${base}/crt/lib";
          WINSDK_INCLUDE = "${base}/sdk/Include";
          WINSDK_LIB = "${base}/sdk/Lib";
          mkArgs = args: builtins.concatStringsSep " " args;
          linker = mkArgs [
            "/manifest:no"
            "-libpath:${MSVC_LIB}"
            "-libpath:${WINSDK_LIB}/ucrt/${arch}"
            "-libpath:${WINSDK_LIB}/um/${arch}"
            "-libpath:${WINSDK_LIB}/${arch}"
            "-libpath:${MSVC_LIB}/${arch}"
          ];
          compiler = mkArgs [
            "/vctoolsdir ${cross.windows.sdk}/crt"
            "/winsdkdir ${cross.windows.sdk}/sdk"
            "/EHs" # this for exceptions
            "-D_CRT_SECURE_NO_WARNINGS" # disables warnings about unsafe functions
            "--target=x86_64-windows-msvc" # set target just to be sure
            "-fms-compatibility-version=19.11" # emulate a specific msvc version, idk what version it is but works
            "-imsvc ${MSVC_INCLUDE}"
            "-imsvc ${WINSDK_INCLUDE}/ucrt"
            "-imsvc ${WINSDK_INCLUDE}/shared"
            "-imsvc ${WINSDK_INCLUDE}/um"
            "-imsvc ${WINSDK_INCLUDE}/winrt"
          ];
        };

        toolchainFile =
          let
            inherit (toolchainHelper)
              linker
              compiler
              WINSDK_INCLUDE
              WINSDK_LIB
              MSVC_INCLUDE
              MSVC_LIB
              ;

          in
          pkgs.writeText "WindowsToolchain.cmake" ''
            set(CMAKE_SYSTEM_NAME Windows)
            set(CMAKE_SYSTEM_VERSION 10.0)
            set(CMAKE_SYSTEM_PROCESSOR x86_64)
            set(IS_NIX_ENV 1) # for a check somewhere down the line (in one of the CMakeList.cmake)

            set(CMAKE_C_COMPILER "clang-cl")
            set(CMAKE_CXX_COMPILER "clang-cl")
            set(CMAKE_AR "llvm-lib")
            set(CMAKE_LINKER "lld-link")
            set(CMAKE_RC_COMPILER "llvm-rc")

            set(CMAKE_C_FLAGS "${compiler}")
            set(CMAKE_CXX_FLAGS "${compiler}")
            set(CMAKE_EXE_LINKER_FLAGS "${linker}")

            set(CMAKE_C_STANDARD_LIBRARIES "${compiler}")
            set(CMAKE_CXX_STANDARD_LIBRARIES "${compiler}")
            set(CMAKE_SHARED_LINKER_FLAGS "${linker}")
            set(CMAKE_MODULE_LINKER_FLAGS "${linker}")

            set(CMAKE_C_COMPILER_WORKS 1)
            set(CMAKE_CXX_COMPILER_WORKS 1)

            message(STATUS "MSVC_LIB: ${MSVC_LIB}")
            message(STATUS "WINSDK_LIB: ${WINSDK_LIB}")

            include_directories(${MSVC_INCLUDE})
            include_directories(${WINSDK_INCLUDE}/ucrt)
            include_directories(${WINSDK_INCLUDE}/shared)
            include_directories(${WINSDK_INCLUDE}/um)
            include_directories(${WINSDK_INCLUDE}/winrt)

            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded")

            set(CMAKE_VERBOSE_MAKEFILE ON)
          '';

        mkBuildDir = /* bash */ "cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${toolchainFile} -DCMAKE_POLICY_VERSION_MINIMUM=3.5";
        mkBuildDirShell = mkBuildDir + " -DCMAKE_EXPORT_COMPILE_COMMANDS=1";

        lib = pkgs.lib;

        # Eval the treefmt modules from ./treefmt.nix
        treefmtEval =
          pkgs:
          treefmt-nix.lib.evalModule pkgs (
            { ... }:
            {
              # Used to find the project root
              projectRootFile = "flake.nix";

              # Add formaters for some other langs
              programs.clang-format.enable = true;
              programs.cmake-format.enable = true;
              programs.nixfmt.enable = true;

              # settings
              settings.formatter.clang-format = {
                package = nixpkgs-24-11.legacyPackages.${system}.llvmPackages_16.clang-tools;
                command = "${nixpkgs-24-11.legacyPackages.${system}.llvmPackages_16.clang-tools}/bin/clang-format";
                options = [
                  "-i"
                  "--style=file"
                ];
                excludes = [
                  "primedev/include/**"
                  "primedev/thirdparty/**"
                  "primedev/wsockproxy/**"
                  "primedev/dllmain.cpp"
                  "primedev/ns_version.h"
                  "primedev/pch.h"
                  "primedev/resource1.h"
                ];
              };
            }
          );
      in
      {
        # for `nix fmt`
        formatter = (treefmtEval pkgs).config.build.wrapper;
        # for `nix flake check`
        checks = {
          formatting = (treefmtEval pkgs).config.build.check self;
        };

        packages = {
          northstar = pkgs.stdenv.mkDerivation (finalAttrs: {
            pname = "NorthstarLauncher";
            # version should be in the format "0.0.0" or things migth break
            # if it needs to change update the version code in postPatch
            version = "0.0.0"; # TODO: get a some action to update the version

            src = self;

            nativeBuildInputs = with pkgs; [
              cross.buildPackages.cmake
              cross.buildPackages.ninja
              llvmPackages.clang-unwrapped
              llvmPackages.bintools-unwrapped
              perl
              pkg-config
              git
            ];

            buildInputs = [
              # cross.zlib # TODO: need upstream fixes for this # but also northstar is vendoring zlib so let it vendor it self
              cross.windows.sdk
            ];

            dontUseCmakeConfigure = true;
            phases = [
              "unpackPhase"
              "patchPhase"
              "postPatch"
              "buildPhase"
              "installPhase"
            ];

            postPatch =
              let
                zlib = pkgs.fetchFromGitHub {
                  owner = "R2Northstar";
                  repo = "zlib";
                  rev = "9f0f2d4f9f1f28be7e16d8bf3b4e9d4ada70aa9f";
                  hash = "sha256-PL6lH7I4qGduaVTR1pGfXUjpZp41kUERvGrqERmSoNQ=";
                };
                versionSeq = (lib.strings.splitString "." finalAttrs.version);
                versionAt = index: builtins.elemAt versionSeq index;
                isDev = finalAttrs.version == "0.0.0"; # 1 = dev, 0 = not dev
                versionQuadruplet = "${versionAt 0},${versionAt 1},${versionAt 2},${
                  if isDev then
                    "1"
                  else if builtins.length > 3 then
                    versionAt 3
                  else
                    "0"
                }";
              in
              ''
                mkdir -p $TMPDIR/cloned
                zlib_src=$TMPDIR/cloned/zlib

                cp -r ${zlib} "$zlib_src"

                chmod +rw "$zlib_src"

                substituteInPlace primedev/thirdparty/minizip/CMakeLists.txt \
                  --replace "clone_repo(zlib https://github.com/madler/zlib)" "
                  set(ZLIB_SOURCE_DIR $zlib_src)
                  set(ZLIB_BINARY_DIR $zlib_src)
                  	"

                substituteInPlace primedev/ns_version.h \
                  --replace "#define NORTHSTAR_VERSION 0,0,0,1" "#define NORTHSTAR_VERSION ${versionQuadruplet}"
                substituteInPlace primedev/resources.rc \
                  --replace "DEV" "${finalAttrs.version}"
                substituteInPlace primedev/primelauncher/resources.rc \
                  --replace "DEV" "${finalAttrs.version}"
              '';

            buildPhase = ''
              mkdir -p build

              ${mkBuildDir}

              cmake --build build/
            '';

            installPhase = ''
              mkdir -p $out
              cp -r build/game/* $out
            '';

            meta = {
              description = "Northstar launcher";
              homepage = "https://northstar.tf/";
              license = lib.licenses.mit;
              mainProgram = "NorthstarLauncher";
              platforms = [ "x86_64-linux" ];
              maintainers = [ ];
            };
          });
          default = self.packages.${system}.northstar;
        };

        devShells = {
          no-auto-build = pkgs.mkShellNoCC {
            nativeBuildInputs = with pkgs; [
              cross.buildPackages.cmake
              cross.buildPackages.ninja
              llvmPackages.clang-unwrapped
              llvmPackages.bintools-unwrapped
              perl
              cross.zlib
              pkg-config

              # this helpful for testing the dev shell so I am not removing this yet
              (pkgs.writeShellScriptBin "rebuild-ns" ''
                rm -rf build/
                mkdir -p build

                ${mkBuildDirShell}
                cmake --build build/
              '')
              (pkgs.writeShellScriptBin "generate-build-ns" mkBuildDirShell)
            ];

            buildInputs = [
              cross.windows.sdk
            ];

            shellHook = /* bash */ ''
              cp -f ${pkgs.writeText ".clangd" ''
                CompileFlags:
                  CompilationDatabase: "build"
              ''} .clangd
              echo "Northstar shell init"
              echo "    generate-build-ns: generate build files for cmake"
            '';
          };
          default = self.devShells.${system}.no-auto-build;
        };
      }
    );
}
