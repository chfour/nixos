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
    (bots) {
      # https://donotsta.re/objects/4ff43b3e-2a56-48f1-870b-48353cd90801
      # > DON’T LET YOUR DREAMS STAY DREAMS!
      @bots header_regexp User-Agent "GPTBot|ChatGPT-User|Google-Extended|CCBot|PerplexityBot|anthropic-ai|Claude-Web|ClaudeBot|Amazonbot|FacebookBot|Applebot-Extended|semrush|barkrowler|PetalBot|meta-externalagent|meta-externalfetcher|facebookexternalhit|facebookcatalog|Firefox/72\.0|babbar\.tech|BLEXBot|DotBot|ahrefs|DataForSeoBot|ImagesiftBot|Nexus 5X Build/MMB29P|Arc/|MJ12Bot|dataforseo-bot|MJ12bot"
      handle @bots {
        header X-Fuck-Off "PLEASE do!"
        redir https://nbg1-speed.hetzner.com/10GB.bin?BALLS permanent
      }
    }
  '';
  services.caddy.virtualHosts = {
    "eeep.ee".extraConfig = ''
      import errors
      import bots

      root * ${websiteDest}
      encode zstd gzip
      file_server
    '';

    "files.eeep.ee".extraConfig = ''
      import errors
      import bots

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
        ${pkgs.lib.getExe pkgs.rsync} -r --copy-links --delete \
          ${websitePath}/ ${websiteDest}

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
