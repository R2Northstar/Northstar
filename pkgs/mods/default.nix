{
  lib,
  jq,
  stdenv,
  mods,
  version,
}:
let
in
stdenv.mkDerivation (finalAttr: {
  pname = "NorthstarMods";
  inherit version;

  src = mods;

  noUnpack = true;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    mkdir -p $TMPDIR

    cp -r $src/* $out
    chmod -R u+w "$out"

    ${lib.getExe jq} ".Version = \"${version}\"" $out/Northstar.Client/mod.json > $TMPDIR/mod.json.tmp
    rm $out/Northstar.Client/mod.json
    mv $TMPDIR/mod.json.tmp $out/Northstar.Client/mod.json

    ${lib.getExe jq} ".Version = \"${version}\"" $out/Northstar.Custom/mod.json > $TMPDIR/mod.json.tmp
    rm $out/Northstar.Custom/mod.json
    mv $TMPDIR/mod.json.tmp $out/Northstar.Custom/mod.json

    ${lib.getExe jq} ".Version = \"${version}\"" $out/Northstar.CustomServers/mod.json > $TMPDIR/mod.json.tmp
    rm $out/Northstar.CustomServers/mod.json
    mv $TMPDIR/mod.json.tmp $out/Northstar.CustomServers/mod.json
  '';

  meta = {
    description = finalAttr.pname;
    homepage = "https://northstar.tf/";
    license = lib.licenses.mit;
  };
})
