{
  lib,
  pkgs,
  fetchzip,
}:
let
in
pkgs.stdenv.mkDerivation (finalAttr: {
  pname = "NorthstarNavs";
  version = "v4";

  src = fetchzip {
    url = "https://github.com/R2Northstar/NorthstarNavs/archive/refs/tags/${finalAttr.version}.zip";
    hash = "sha256-e3f+cScOga5oD+qT0irh/ccPdx7gHnliQBfPgf+/NFM=";
  };

  noUnpack = true;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out

    cp -r ${finalAttr.src}/graphs $out
    cp -r ${finalAttr.src}/navmesh $out
  '';

  meta = {
    description = finalAttr.pname;
    homepage = "https://northstar.tf/";
    license = lib.licenses.mit;
  };
})
