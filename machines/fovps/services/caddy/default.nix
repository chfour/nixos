{ pkgs, config, website, ... }:

let
  websiteDest = "${config.services.caddy.dataDir}/website";
  websitePath = builtins.toString website.website.out;

  disallowedAgents = [
    # https://git.madhouse-project.org/iocaine/nam-shub-of-enki/src/branch/main/org/module
    # https://momenticmarketing.com/blog/ai-search-crawlers-bots
    # https://darkvisitors.com/agents
    # ironically, https://www.amazon.com/robots.txt
    # and https://radar.cloudflare.com/en-us/bots/directory?category=AI_CRAWLER&kind=all
    # https://donotsta.re/objects/4ff43b3e-2a56-48f1-870b-48353cd90801
    # > DON’T LET YOUR DREAMS STAY DREAMS!
    "Google-Extended" "Google-CloudVertexBot" "Gemini-Deep-Research"
    "GoogleOther" "Google-NotebookLM" "GoogleAgent"
    "FacebookBot" "meta-externalagent" "meta-externalfetcher"
    "facebookexternalhit" "facebookcatalog"
    "anthropic" "Claude-Web" "Claude-SearchBot" "Claude-User" "ClaudeBot"
    "OpenAI" "GPTBot" "ChatGPT-User" "OAI-SearchBot" "ChatGPT Agent"
    "PerplexityBot" "Perplexity-User"
    "MistralAI-User"
    "amazon" "NovaAct" # "Amazonbot" "amazon-kendra"
    "Applebot-Extended"
    "DuckAssistBot" "Copilot" "BingBot" "LinkedInBot"
    "Bytespider"
    "PetalBot" "PanguBot" # these are from huawei
    "omgili" "webzio" # "Webzio-Extended"
    "Anchor Browser" "Awario" "LinerBot" "factset_spyderbot" "magpie-crawler"
    "CCBot" "YouBot" "Diffbot" "cohere-ai" "Novellum" "EchoboxBot" "WARDBot"
    "Sidetrade indexer bot" "TimpiBot" "semrush" "Scrapy" "Devin"
    "babbar.tech" "barkrowler" "BLEXBot" "DotBot" "ICC-Crawler" "Cotoyogi"
    "ahrefs" "DataForSeoBot" "ImagesiftBot" "EtaoSpider" "QualifiedBot"
    "MJ12Bot" "dataforseo-bot" "bigsur.ai" "Datenbank Crawler" "netEstate"
    "LivelapBot"
    "Firefox/72.0" "Arc/"
    "Kangaroo Bot" # fucking crazy lmao
    # "Nexus 5X Build/MMB29P"
    # apparently that also blocks normal googlebot. oops!
  ];
in {
  services.caddy.enable = true;
  services.caddy.extraConfig = let
    agentsRegex = with pkgs; "(?i)" + lib.strings.escape [ "'" "\\" ]
      (builtins.concatStringsSep "|" (
        builtins.map (lib.strings.escapeRegex) disallowedAgents));
  in ''
    (bots) {
      @bots <<CEL
        header_regexp('User-Agent', '${agentsRegex}')
        || header({'x-firefox-ai': '1'})
        CEL
      handle @bots {
        header X-Fuck-Off "PLEASE do!"
        redir https://nbg1-speed.hetzner.com/10GB.bin?BALLS permanent
      }
    }
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
          ${websitePath}/var/www/ ${websiteDest}

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
