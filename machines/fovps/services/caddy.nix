{ ... }:

{
  services.caddy.enable = true;
  services.caddy.virtualHosts = {
    "eeep.ee" = {
      extraConfig = ''
        respond "test hello world!\n" 200
      '';
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
