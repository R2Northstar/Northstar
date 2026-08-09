{
  lib,
  pkgs,
  launcher,
  mods,
  discordrpc,
  plugins,
  northstar-stubs,
  northstar-navs,
  version,
}:
let
in
pkgs.stdenv.mkDerivation (finalAttr: {
  pname = "Northstar";
  inherit version;

  src = ../.;

  noUnpack = true;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    mkdir -p $out/bin/x64_dedi
    mkdir -p $out/R2Northstar
    mkdir -p $out/R2Northstar/mods/
    mkdir -p $out/R2Northstar/plugins
    mkdir -p $out/R2Northstar/mods/Northstar.CustomServers/mod/maps

    cp -r ${discordrpc}/bin/* $out/R2Northstar/plugins/
    cp -r ${plugins}/bin/* $out/R2Northstar/plugins/
    cp -r ${mods}/* $out/R2Northstar/mods/
    cp -r ${launcher}/* $out/
    cp -r ${northstar-stubs}/bin/* $out/bin/x64_dedi
    cp -r ${northstar-navs}/* $out/R2Northstar/mods/Northstar.CustomServers/mod/maps
    mv $out/Northstar.dll $out/R2Northstar/Northstar.dll
    mv $out/Northstar.pdb $out/R2Northstar/Northstar.pdb

    cp -r ${../../release/LEGAL.txt} $out/R2Northstar/LEGAL.txt
    cp -r ${../../release/r2ds.bat} $out/r2ds.bat

    # make everything writable for the end user
    chmod -R u+w "$out"
  '';

  meta = {
    description = finalAttr.pname;
    homepage = "https://northstar.tf/";
    license = lib.licenses.mit;
  };
})
