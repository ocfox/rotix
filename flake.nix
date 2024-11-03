{
  description = "Rotix -- NixOS as a router";

  inputs = {
    geosite = {
      url = "github:v2fly/domain-list-community/release";
      flake = false;
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, geosite }:
    {
      nixosModules.default = import ./. { inherit geosite; };
    };
}
