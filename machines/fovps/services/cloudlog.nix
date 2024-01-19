{ pkgs, lib, config, ... }:

let
  domain = "cl.yip.eeep.ee";
  cfg = config.services.cloudlog;
in
{
  services.cloudlog.enable = true;
  services.mysql.package = pkgs.mariadb; # idk lol thats the example
  services.cloudlog.database.createLocally = true;
  
  services.cloudlog.extraConfig = ''
    $config['base_url'] = "//${domain}";
    include('${cfg.dataDir}/secrets.php');
  '';
  systemd.tmpfiles.rules = [
    "f ${cfg.dataDir}/secrets.php 0700 ${cfg.user} ${config.services.nginx.group}"
    # unsafe path transition /assets -> /assets/{json,qslcard}
    "d ${cfg.dataDir}/assets      0750 ${cfg.user} ${config.services.nginx.group} - -"
  ];
  
  # cursed
  services.nginx.user = config.services.caddy.user;
  services.nginx.group = config.services.caddy.group;
  # LET ME USE MY OWN SERVER DAMMIT
  #services.cloudlog.virtualHost = null;
  services.nginx.enable = lib.mkForce false;

  services.caddy.enable = true;
  # https://tenor.com/view/fire-writing-gif-24533171
  services.caddy.virtualHosts.${domain}.extraConfig = let
    socket = config.services.phpfpm.pools.cloudlog.socket;
  in ''
    #log {
    #  output stdout
    #}
    encode zstd gzip
    root * ${config.services.nginx.virtualHosts.${cfg.virtualHost}.root}
    php_fastcgi unix/${socket} {
      #capture_stderr
    }
    file_server
  '';
  #services.cloudlog.poolConfig = {
  #  pm = "dynamic";
  #  "pm.max_children" = 32;
  #  "pm.max_requests" = 500;
  #  "pm.max_spare_servers" = 4;
  #  "pm.min_spare_servers" = 2;
  #  "pm.start_servers" = 2;
  #  "catch_workers_output" = "yes";
  #  "php_admin_flag[log_errors]" = "on";
  #  "php_flag[display_errors]" = "on";
  #};
}
