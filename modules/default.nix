{ ... }:
{
  imports = [
    ./upstream.nix
    ./dnsmasq.nix
    ./mosdns-module.nix
    ./mosdns.nix
    ./nftables.nix
    ./dae.nix
    ./lan.nix
  ];
}
