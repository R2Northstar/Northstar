{
  lib,
  zip,
  stdenv,
  northstar,
  version,
}:
let
in
stdenv.mkDerivation (finalAttr: {
  pname = "NorthstarZipped";
  inherit version;

  src = northstar;

  noUnpack = true;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    mkdir -p $TMPDIR/northstar

    cp -r $src/. $TMPDIR/northstar/
    chmod -R u+rwX $TMPDIR/northstar

    cd $TMPDIR/northstar
    ${lib.getExe zip} -r $out/Northstar.release.v${finalAttr.version}.zip .
  '';

  meta = {
    description = finalAttr.pname;
    homepage = "https://northstar.tf/";
    license = lib.licenses.mit;
  };
})
