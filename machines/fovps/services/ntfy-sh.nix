{ pkgs, config, ... }:

let
  domain = "ntfy.yip.eeep.ee";
  
  ntfy = config.services.ntfy-sh;
in
{
  services.ntfy-sh.enable = true;

  services.ntfy-sh.settings = {
    base-url = "https://${domain}";
    behind-proxy = true;
    auth-default-access = "deny-all"; # sorry
  };
  systemd.services.ntfy-sh.postStart = ''
    # unifiedpush write-only access for everyone
    ${ntfy.package}/bin/ntfy access '*' 'up*' write-only
  '';

  services.caddy.enable = true;
  services.caddy.virtualHosts."https://${domain}".extraConfig = ''
    reverse_proxy * ${ntfy.settings.listen-http}
  '';
}
