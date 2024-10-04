{ config, ... }:

let
  domain = "eeep.ee";
  
  caddy = config.services.caddy;
  prosody = config.services.prosody;

  acmeCA = builtins.head (lib.lists.drop 2 (lib.strings.splitString "/" caddy.acmeCA)); # get domain only
  certPath = "${caddy.dataDir}/.local/share/caddy/certificates/${acmeCA}/${domain}/";
in
{
  services.prosody.enable = true;

  

  services.prosody.virtualHosts.${domain} = {
    domain = domain;
    enable = true;
  };
  
  services.caddy.enable = true;
  services.caddy.virtualHosts.${domain} = {}; # should do it...?
  
  # can't specify certs directly because caddy writes everything with mode 700
  # so let's bodge it (or well this *is* what prosody recommends (https://prosody.im/doc/letsencrypt))
  # but caddy doesn't have such hooks soooooo:
  systemd.paths.prosody-cert-copy = {
    description = "Automatically import certs into Prosody";
    after = [ "caddy.service" ];
    requiredBy = [ "caddy.service" ];
    
    pathConfig = {
      PathChanged = certPath;
      Unit = "prosody-cert-copy.service";
    };
  };
  systemd.services.prosody-cert-copy = {
    description = "Import certs into Prosody";
    script = "${prosody.package}/bin/prosodyctl --root cert import ${certPath}";
  };
}
