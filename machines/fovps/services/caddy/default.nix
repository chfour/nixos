{ pkgs, website, ... }:

{
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
    "eeep.ee".extraConfig = let
      websitePath = builtins.toString website.website.out;
    in ''
      import errors

      # lol
      redir /nixos /nixos/ permanent
      handle_path /nixos/* {
        redir * https://github.com/chfour/nixos/tree/main{uri}
      }

      # the usual
      root * ${websitePath}
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
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];
}
