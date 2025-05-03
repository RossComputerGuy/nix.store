{
  description = "The nix store";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    flake-parts,
    ...
  }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;

    perSystem = { pkgs, ... }: {
      packages = let
        inherit (pkgs) lib;

        mkProducts = lib.genAttrs [
          "necklace"
        ];

        products = mkProducts (product: pkgs.runCommand product {} ''
          cp -r ${./products/${product}} $out
        '');
      in products // {
        default = pkgs.runCommand "catalogue" {} ''
          mkdir -p $out
          ${lib.concatMapAttrsStringSep "\n" (product: drv: "ln -s ${drv} $out/${product}") products}
        '';
      };
    };
  };
}
