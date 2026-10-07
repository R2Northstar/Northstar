{
  stdenvNoCC,
  launcher,
  fetchFromGitHub,
  lib,
  llvmPackages,

  perl,
  pkg-config,
  git,
}:
let
  inherit (launcher) cross mkBuildDir;

  # we need this since flakes cannot cope with submodules
  # these need to matched up with the submodule commit hashes
  zlib = fetchFromGitHub {
    owner = "R2Northstar";
    repo = "zlib";
    rev = "9f0f2d4f9f1f28be7e16d8bf3b4e9d4ada70aa9f";
    hash = "sha256-PL6lH7I4qGduaVTR1pGfXUjpZp41kUERvGrqERmSoNQ=";
  };
  libcurl = fetchFromGitHub {
    owner = "curl";
    repo = "curl";
    rev = "801bd5138ce31aa0d906fa4e2eabfc599d74e793";
    hash = "sha256-4w15NHw3D+YBuK02ZIZqvGaWgyQVc61MZ34pkLu0Oug=";
    name = "curl";
  };
  minhook = fetchFromGitHub {
    owner = "TsudaKageyu";
    repo = "minhook";
    rev = "0f25a2449b3cf878bcbdbf91b693c38149ecf029";
    hash = "sha256-ncA9yX4jojesIc0P8+PUHQvCScaS3zNXnAodWwpuxVY=";
    name = "minhook";
  };
  minizip = fetchFromGitHub {
    owner = "zlib-ng";
    repo = "minizip-ng";
    rev = "680d6f1dcf9de99fc033b54975a1dfff10be2b6b";
    hash = "sha256-3bCGZupdJWcwp2d+XeqKZG3GxzXFm1UftV/PiN0u5iA=";
    name = "minizip-ng";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "NorthstarLauncher";
  # version should be in the format "0.0.0" or things migth break
  # if it needs to change update the version code in postPatch
  version = "0.0.0"; # TODO: get a some action to update the version

  src = lib.fileset.toSource {
    root = ../launcher;
    fileset = lib.fileset.unions [
      ../launcher/primedev
      ../launcher/CMakeSettings.json
      ../launcher/CMakeLists.txt
    ];
  };

  nativeBuildInputs = [
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
      versionSeq = (lib.strings.splitString "." finalAttrs.version);
      versionAt = index: builtins.elemAt versionSeq index;
      isDev = finalAttrs.version == "0.0.0"; # 1 = dev, 0 = not dev
      versionQuadruplet = "${versionAt 0},${versionAt 1},${versionAt 2},${
        if isDev then
          "1"
        else if builtins.length versionSeq > 3 then
          versionAt 3
        else
          "0"
      }";
    in
    ''
      rm -rf primedev/thirdparty/libcurl
      cp -r ${libcurl} primedev/thirdparty/libcurl
      chmod -R u+w primedev/thirdparty/libcurl

      rm -rf primedev/thirdparty/minhook
      cp -r ${minhook} primedev/thirdparty/minhook
      chmod -R u+w primedev/thirdparty/minhook

      rm -rf primedev/thirdparty/minizip
      cp -r ${minizip} primedev/thirdparty/minizip
      chmod -R u+w primedev/thirdparty/minizip

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
    maintainers = [ "cat_or_not" ];
  };
})
