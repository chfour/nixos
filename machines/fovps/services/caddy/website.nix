{ pkgs, config, website, ... }:

let
  websiteDest = "${config.services.caddy.dataDir}/website";
  websitePath = builtins.toString website.website.out;
in
{
  services.caddy.virtualHosts = {
    "eeep.ee".extraConfig = ''
      import errors
      import bots

      root * ${websiteDest}
      encode zstd gzip
      file_server
    '';
  };
  system.activationScripts = {
    copyWebsite = {
      text = ''
        # epic hack hacky hackk
        mkdir -p ${websiteDest}
        ${pkgs.lib.getExe pkgs.rsync} -r --copy-links --delete \
          ${websitePath}/var/www/ ${websiteDest}

        # :trol:
        ${pkgs.lib.getExe pkgs.gnused} -i \
          's|/nix/store/VERY5p3c14lsecretv4luereplaceme0-chfour-website|${websitePath}|' \
          ${websiteDest}/index.html
      '';
      deps = [];
    };
  };
}
