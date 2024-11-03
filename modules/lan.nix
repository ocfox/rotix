{ config, lib, ... }:
let
  cfg = config.rotix;
  inherit (lib) mkIf;
  inherit (cfg.interfaces)
    downstream
    lan
    br-lan
    direct
    ;
in
{
  config = mkIf cfg.enable {
    systemd.network = {
      networks."${downstream}" = {
        name = downstream;
        networkConfig = {
          LinkLocalAddressing = "no";
          VLAN = [
            lan
            direct
          ];
        };
        linkConfig = {
          RequiredForOnline = false;
          MTUBytes = "9000";
        };
      };
      ## VLANs
      netdevs."${lan}" = {
        netdevConfig = {
          Kind = "vlan";
          Name = lan;
        };
        vlanConfig.Id = 1;
      };
      netdevs."${direct}" = {
        netdevConfig = {
          Kind = "vlan";
          Name = direct;
        };
        vlanConfig.Id = 2;
      };

      netdevs."${br-lan}".netdevConfig = {
        Kind = "bridge";
        Name = br-lan;
      };
      networks."${lan}" = {
        name = lan;
        networkConfig = {
          Bridge = br-lan;
          LinkLocalAddressing = "no";
        };
      };
      networks."${direct}" = {
        name = direct;
        networkConfig = {
          Bridge = br-lan;
          LinkLocalAddressing = "no";
        };
      };
      networks."${br-lan}" = {
        name = br-lan;
        networkConfig = {
          Address = [
            "10.0.0.1/16"
            "fd23:3333:3333::1/64"
          ];
          DHCPPrefixDelegation = true; # 自动选择第一个有 PD 的链路, 并获得子网前缀
          IPv6SendRA = true;
          IPv6AcceptRA = false; # 接受来自下游的 RA 是不必要的
        };
        ipv6SendRAConfig = {
          Managed = true;
          OtherInformation = true;
        };
        dhcpPrefixDelegationConfig.Token = "::1";
      };
    };
  };
}
