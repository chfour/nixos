{ config, ... }:

let
  domain = "vw.yip.eeep.ee";
in {
  services.vaultwarden.enable = true;
  services.vaultwarden.environmentFile = "/var/"
  services.vaultwarden.config = {
    DOMAIN = domain;
        
    ROCKET_ADDRESS = "127.0.0.1";
    ROCKET_PORT = 8801;

    PUSH_ENABLED = false;
  };
  services.caddy.enable = true;
  services.caddy.virtualHosts.${domain}.extraConfig = let
    vwcfg = config.services.vaultwarden.config;
  in ''
    encode zstd gzip
    reverse_proxy * localhost:${vwcfg.ROCKET_PORT}
  '';
}
