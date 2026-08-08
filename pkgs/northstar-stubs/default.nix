{
  lib,
  pkgs,
  fetchzip,
}:
let
in
pkgs.stdenv.mkDerivation (finalAttr: {
  pname = "NorthstarStubs";
  version = "v1";

  src = fetchzip {
    url = "https://github.com/R2Northstar/NorthstarStubs/releases/download/${finalAttr.version}/NorthstarStubs.zip";
    hash = "sha256-NgChtI2jmbTwqsdT1bgjO+rbj17icSaSR4DvwM/0WDU=";    
    stripRoot=false;
  };

  noUnpack = true;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin

    cp -r ${finalAttr.src}/* $out/bin
  '';

  meta = {
    description = finalAttr.pname;
    homepage = "https://northstar.tf/";
    license = lib.licenses.mit;
  };
})
