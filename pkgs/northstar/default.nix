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
    install -d -m 755 $out
    install -d -m 755 $out/bin/x64_dedi
    install -d -m 755 $out/R2Northstar
    install -d -m 755 $out/R2Northstar/mods/
    install -d -m 755 $out/R2Northstar/plugins
    install -d -m 755 $out/R2Northstar/mods/Northstar.CustomServers/mod/maps

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
  '';

  meta = {
    description = finalAttr.pname;
    homepage = "https://northstar.tf/";
    license = lib.licenses.mit;
  };
})
