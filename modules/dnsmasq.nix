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

  config = mkIf cfg.enable {
    services.resolved.enable = false;
    services.dnsmasq = {
      enable = true;
      settings =
        let
          inherit (config.rotix.interfaces) br-lan;
        in
        {
          server = if cfg.mosdns.enable then [ "127.0.0.53" ] else cfg.dns;
          no-resolv = true;
          expand-hosts = true;
          # Interface bind
          interface = [
            br-lan
          ];
          bind-dynamic = true;
          interface-name = "${br-lan}";
          # Cache
          cache-size = 8192;
          # Pervent reverse DNS lookups for local hosts
          bogus-priv = true;
          # Allows returning different results to different interfaces
          # For an authoritative server, when encountering a CNAME, only the corresponding domain name needs to be returned
          # For a recursive resolver, when encountering a CNAME, it needs to return both the domain name and the result (or only the result?)
          # Since DNSMASQ both acts as an authoritative server/recursive resolver, It needs to be allowed to return different results for different interfaces.
          localise-queries = true; # 关闭此选项似乎会导致包含在 auth-zone 的 CNAME 在非 auth-server 绑定的接口也不返回实际 IP, 尚不清楚成因
          # DHCP
          dhcp-authoritative = true;
          dhcp-broadcast = "tag:needs-broadcast";
          dhcp-ignore-names = "tag:dhcp_bogus_hostname";
          dhcp-range = [
            # lan
            "set:${br-lan},10.0.1.0,10.0.254.255" # Reserve 10.0.0.0/24 & 10.0.255.0/24
            "set:${br-lan},::fff,::ffff,constructor:${br-lan},ra-names"
          ];
          read-ethers = true;
        };
    };
  };
}
