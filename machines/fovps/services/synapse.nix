{ config, pkgs, lib, ... }:

with builtins;
let
  domain = "eeep.ee";
  synapsePort = 8008; # todo: unix socket maybe?

  synapse = config.services.matrix-synapse;
  synapseUnit = config.systemd.services.matrix-synapse.serviceConfig;
in
{
  services.matrix-synapse.enable = true;
  services.matrix-synapse.withJemalloc = true; # hell why not

  services.matrix-synapse.settings = {
    server_name = domain;
    enableRegistrationScript = true;

    max_upload_size = "200M";

    # automatically created
    registration_shared_secret_path = "${synapse.dataDir}/.env.synapse-reg";
  };

  #services.coturn = {
  #  enable = true;
  #  use-auth-secret = true;
  #  static-auth-secret-file = "";
  #};

  services.matrix-synapse.settings.database.name = "psycopg2";
  services.postgresql = let args = synapse.settings.database.args; in {
    enable = true;
    initdbArgs = [ "--locale=C" "--encoding=UTF8" ];
    ensureDatabases = [ args.database ];
    ensureUsers = [ { name = args.user; ensureDBOwnership = true; } ];
  };

  services.matrix-synapse.settings.listeners = [
    {
      bind_addresses = [ "127.0.0.1" ];
      port = synapsePort;
      resources = [
        { compress = false; names = [ "client" "federation" ]; }
      ];
      tls = false;
      type = "http";
      x_forwarded = true;
    }
  ];
  services.caddy.enable = true;
  services.caddy.virtualHosts."${domain}".extraConfig = ''
    reverse_proxy /_matrix/* localhost:${toString synapsePort}
    reverse_proxy /_synapse/client/* localhost:${toString synapsePort}
  '';
  services.caddy.virtualHosts."https://${domain}:8448".extraConfig = ''
    reverse_proxy /_matrix/* localhost:${toString synapsePort}
    respond / "Balls" 200
  '';
  networking.firewall.allowedTCPPorts = [ 8448 ];
  networking.firewall.allowedUDPPorts = [ 8448 ];
}
