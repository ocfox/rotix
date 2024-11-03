{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    ;
  cfg = config.services.mosdns;
  configFormat = pkgs.formats.yaml { };
  configFile = configFormat.generate "mosdns.yaml" cfg.config;
in
{
  options.services.mosdns = {
    enable = mkEnableOption "mosdns service";
    package = mkPackageOption pkgs "mosdns" { default = [ "mosdns" ]; };
    config = mkOption {
      type = configFormat.type;
      default = { };
      description = "The configuration attribute set.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mosdns = {
      description = "mosdns Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [ configFile ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/mosdns start -c ${configFile}";
      };
    };

    environment.systemPackages = [ cfg.package ];
  };
}
