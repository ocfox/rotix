{
  config,
  lib,
  ...
}:
let
  cfg = config.rotix;
  inherit (lib) mkIf;
in
{
  config = {
    systemd.network = {

      networks."${cfg.interface.onu}" = {
        # ONU上联接口 / 仅用于管理ONU
        name = cfg.interface.onu;
        networkConfig.DHCP = "yes";
        dhcpV4Config = {
          UseRoutes = false;
          UseDNS = false;
        };
        dhcpV6Config.WithoutRA = mkIf (cfg.onlineMode == "dhcp") "solicit";
      };

      networks."${cfg.interface.pppoe}" = mkIf cfg.pppoe.enable {
        name = cfg.interface.pppoe;
        networkConfig = {
          DHCP = "ipv6"; # 需要先接收到包含 M Flag 的 RA 才会尝试 DHCP-PD
          KeepConfiguration = "static"; # 防止清除 PPPD 通过 IPCP 获取的 IPV4 地址
        };
        dhcpV6Config = {
          WithoutRA = "solicit"; # 允许上游 RA 没有 M Flag 时启用 DHCP-PD
          UseDNS = false;
          UseAddress = false; # 无法获得到地址时需要
        };
        routes = [
          { Gateway = "0.0.0.0"; } # v4默认路由, 因为v4不是networkd管理的，所以仅在reconfigure时工作
          { Gateway = "::"; } # v6默认路由
        ];
      };
    };

    # pppd
    services.pppd = mkIf cfg.pppoe.enable {
      enable = true;
      peers.edpnet = {
        enable = true;
        config = ''
          plugin pppoe.so ${cfg.pppoe.interface}

          name "${cfg.pppoe.username}"
          password "${cfg.pppoe.password}"

          ifname ${cfg.interface.pppoe}

          usepeerdns
          defaultroute  # v4默认路由
        '';
      };
    };
  };
}
