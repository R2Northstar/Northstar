{
  description = "Northstar Nightly Builds";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    mods = {
      url = "github:R2Northstar/NorthstarMods";
      flake = false;
    };
    launcher = {
      url = "git+https://github.com/R2Northstar/NorthstarLauncher.git?submodules=1&rev=1b0ce15673a0027b21639746fd74d4f7da1e504d";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "";
    };
    discordrpc = {
      url = "github:R2Northstar/NorthstarDiscordRPC";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plugins = {
      url = "github:R2Northstar/NorthstarPlugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      utils,
      mods,
      launcher,
      discordrpc,
      plugins,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixfmt-tree;

        packages = {
          default = self.packages.${system}.northstar;
        }
        // import ./pkgs {
          inherit
            self
            pkgs
            mods
            launcher
            discordrpc
            plugins
            system
            ;
          version = self.version;
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.act
          ];
        };
      }
    )
    // {
      version = "1.13.11";
    };
}
