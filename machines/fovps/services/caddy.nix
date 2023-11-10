{ pkgs, ... }:
let
  websiteSource = pkgs.fetchFromGitHub {
    owner = "chfour";
    repo = "website-static";
    rev = "c27c5fc110cae32a143d021e54506a71843007af";
    hash = "sha256-1k+KOZDEi3J81HUYx0kY9V2QyRyZylk5kYwW3extM9I=";
  };
in
{
  services.caddy.enable = true;
  services.caddy.virtualHosts = {
    "eeep.ee".extraConfig = ''
      root * ${websiteSource}
      encode zstd gzip
      file_server
    '';
    


  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
