{ pkgsCross, writeText }:
let
  cross = pkgsCross.x86_64-windows;
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
in

rec {
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
    writeText "WindowsToolchain.cmake" ''
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

  inherit cross;
}
