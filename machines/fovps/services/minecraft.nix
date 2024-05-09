{ pkgs, ... }:

{
  services.minecraft-ex.enable = true;
  services.minecraft-ex = {
    eula = true;
    declarative = true;
    dataDir = "/var/lib/minecraft";
    openFirewall = true;
    jvmOpts = "-Xmx4096M -Xms2048M";
    package = pkgs.papermc.overrideAttrs (old: rec {
      version = "1.20.6-36";
      src = pkgs.fetchurl {
        url = "https://api.papermc.io/v2/projects/paper/versions/1.20.6/builds/36/downloads/paper-${version}.jar";
        hash = "sha256-QvmH9nIyfnG6silRZsMjp0nByl4E4dQqTFskKq0gJEY=";
      };
    });
    serverProperties = {
      motd = "bajo jajo";
      difficulty = 2;
      gamemode = 0;
      online-mode = false;
      white-list = true;
      view-distance = 20;

      enable-rcon = true;
      "rcon.password" = "hunter2";
    };
  };
}
