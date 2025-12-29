{ pkgs, config, ... }:

# TODO: maybe make this into a module or sth
let
  source = "github:chfour/website3#website";
  dataDir = "/var/lib/website";
  user = config.services.caddy.user;
  group = config.services.caddy.group;
in {
  systemd.tmpfiles.rules = [
    "d ${dataDir}/     0755 ${user} ${group} - -"
    "f ${dataDir}/etag 0755 ${user} ${group} -"
    "L /nix/var/nix/gcroots/website - - - - ${dataDir}/current"
  ];
  services.caddy.virtualHosts = {
    "eeep.ee".extraConfig = ''
      import errors
      import bots

      handle {
        root * ${dataDir}/current/var/www
        encode zstd gzip
        header {
          -Last-modified
          import ${dataDir}/etag
        }
        file_server
      }
    '';
  };
  systemd.services.update-website = let
    updater-unpriv = pkgs.writeShellApplication {
      name = "website-updater-unpriv";
      runtimeInputs = [ config.nix.package ];
      text = ''
        cd "${dataDir}"
        # build
        rm -f next
        nix build "${source}".out --out-link next
        nextPath="$(readlink next)"

        # if the link target is the same (no changes) then exit, theres nothing to do
        [ -e current ] &&
          [ "$nextPath" = "$(readlink current)" ] &&
          rm next && exit

        # atomically swap
        mv -T next current
        echo 'Etag "\"'"''${nextPath##*/}"'\""' > ${dataDir}/etag
      '';
    };
  in {
    description = "Fully Automated Luxury Gay Space Communism";

    # Behavior of oneshot is similar to simple; however, the
    # service manager will consider the unit up after the main
    # process exits. It will then start follow-up units.
    before = [ "caddy.service" ];
    wantedBy = [ "caddy.service" ];

    path = [ pkgs.sudo config.systemd.package ];
    script = ''
      sudo -u ${user} -g ${group} \
        ${updater-unpriv}/bin/website-updater-unpriv

      # reload bc etag changed
      systemctl is-active --quiet caddy.service &&
        systemctl reload --no-block caddy.service || true
    '';
    # --no-block because it seems systemd blocks
    # the reload until this service finishes...
    # so it deadlocks here if caddy is running
    # it's also fine because we only change Etag
    # which shouldn't have any syntax errors...
    # so it's not really our problem if something
    # shits the bed
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
    };
    startAt = "05,17:00";
  };
  systemd.timers.update-website = {
    timerConfig.RandomizedOffsetSec = "5h";
  };
}
