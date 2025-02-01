{ pkgs, config, website, ... }:

let
  websiteDest = "${config.services.caddy.dataDir}/website";
  websitePath = builtins.toString website.website.out;
in {
  services.caddy.enable = true;
  services.caddy.extraConfig = ''
    (errors) {
      handle_errors {
      	@custom_err file /{err.status_code}.html /err.html
      	handle @custom_err {
      		rewrite * {file_match.relative}
      		file_server
      	}
      	respond "{err.status_code} {err.status_text}
" # caddy why
      }
    }
  '';
  services.caddy.virtualHosts = {
    "eeep.ee".extraConfig = ''
      import errors

      # lol
      redir /nixos /nixos/ permanent
      handle_path /nixos/* {
        redir * https://github.com/chfour/nixos/tree/main{uri}
      }

      root * ${websiteDest}
      encode zstd gzip
      file_server
    '';

    "files.eeep.ee".extraConfig = ''
      import errors

      root * /srv/pub
      encode zstd gzip
      file_server {
        browse ${./browsetemplate.html}
      }
    '';
  };

  system.activationScripts = {
    copyWebsite = {
      text = ''
        # epic hack hacky hackk
        mkdir -p ${websiteDest}
        cp -r ${websitePath}/* ${websiteDest}
        pushd ${websiteDest} && comm -z -13 \
          <(find ${websitePath} -mindepth 1 -printf '%P\0' | sort -z) \
          <(find . -mindepth 1 -printf '%P\0' | sort -z) \
          | xargs -0 rm -rf; popd
        # :trol:
        ${pkgs.lib.getExe pkgs.gnused} -i \
          's|/nix/store/VERY5p3c14lsecretv4luereplaceme0-chfour-website|${websitePath}|' \
          ${websiteDest}/index.html
      '';
      deps = [];
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];
}
