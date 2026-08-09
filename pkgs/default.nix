{
  self,
  pkgs,
  mods,
  launcher,
  discordrpc,
  plugins,
  system,
  version,
  ...
}:
let
  getPackage = pkg: self.packages.${system}.${pkg};
  listToPackages =
    list:
    builtins.listToAttrs (
      map (name: {
        name = name;
        value = getPackage name;
      }) list
    );
in
{
  launcher = launcher.packages.${system}.default.overrideAttrs (final: {
    version = version + ".0";
    __intentionallyOverridingVersion = true;
  });
  mods = pkgs.callPackage ./mods { inherit mods version; };
  discordrpc = discordrpc.packages.${system}.default;
  plugins = plugins.packages.${system}.default;
  northstar-stubs = pkgs.callPackage ./northstar-stubs { };
  northstar-navs = pkgs.callPackage ./northstar-navs { };
  northstar = pkgs.callPackage ./northstar (
    {
      inherit
        version
        ;
    }
    // listToPackages [
      "launcher"
      "mods"
      "discordrpc"
      "plugins"
      "northstar-stubs"
      "northstar-navs"
    ]
  );
}
