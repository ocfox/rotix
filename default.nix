{
  lib,
  config,
  ...
}:
let
  cfg = config.rotix;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    mkDefault
    types
    ;
in
{
  imports = [
    ./modules
  ];

  options.rotix = {
    enable = mkEnableOption "Rotix, nix router module";

    interfaces = {
      upstream = mkOption {
        type = types.str;
        example = "enp14s0";
        description = "Physic network interface, used such as pppoe";
      };

      downstream = mkOption {
        type = types.str;
        example = "enp78s0";
        description = "Physic network interface, used such as DHCP server, lan ...";
      };

      pppoe = mkOption {
        type = types.str;
        default = "pppoe-wan";
      };

      lan = mkOption {
        type = types.str;
        default = "lan";
      };

      br-lan = mkOption {
        type = types.str;
        default = "br-lan";
      };

      onu = mkOption {
        type = types.str;
        default = cfg.interfaces.upstream;
      };

      wan = mkOption {
        type = types.str;
        default = if cfg.onlineMode == "pppoe" then cfg.interfaces.pppoe else cfg.interfaces.onu;
      };
    };

    mosdns.enable = mkEnableOption "use mosdns configured by rotix";

    dns = mkOption {
      type = types.listOf types.str;
      default = [ "1.1.1.1" ];
      description = "udp dns servers used by dnsmasq (don't need if use mosdns)";
    };

    onlineMode = mkOption {
      type = types.enum [
        "dhcp"
        "pppoe"
      ];
      description = "upstream network link mode, dhcp or pppoe";
    };

    dae = {
      enable = mkEnableOption "dae configure by rotix";
      nodes = mkOption {
        type = types.str;
        example = ''
          node1: 'vmess://LINK'
          node2: 'vless://LINK'
        '';
        description = "proxy nodes for dae";
      };
    };

    pppoe = {
      enable = cfg.onlineMode == "pppoe";
      interface = mkOption {
        type = types.str;
        default = cfg.interfaces.upstream;
        defaultText = lib.literalExpression "config.rotix.interfaces.upstream";
        description = "interface for PPPoE";
      };

      username = mkOption {
        type = types.str;
        description = "ISP PPPoE username";
      };

      password = mkOption {
        type = types.str;
        description = "ISP PPPoE password";
      };
    };

  };

  config = mkIf cfg.enable {
    rotix.mosdns.enable = mkDefault true;
  };
}
