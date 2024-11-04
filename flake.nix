{
  description = "Rotix -- NixOS as a router";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    geosite = {
      url = "github:v2fly/domain-list-community/release";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake = {
        nixosModules.default = import ./. inputs;
      };
    };
}
