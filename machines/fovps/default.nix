{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "fovps";
  
  boot.tmp.cleanOnBoot = true;

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "C.UTF-8";
    LC_IDENTIFICATION = "C.UTF-8";
    LC_MEASUREMENT = "C.UTF-8";
    LC_MONETARY = "C.UTF-8";
    LC_NAME = "C.UTF-8";
    LC_NUMERIC = "C.UTF-8";
    LC_PAPER = "C.UTF-8";
    LC_TELEPHONE = "C.UTF-8";
    LC_TIME = "C.UTF-8";
  };

  systemd.network.enable = true;
  networking.useDHCP = false;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "ens18";
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = true;
    };
  };

  services.openssh.enable = true;
  
  environment.systemPackages = with pkgs; [
    micro
    wget
    htop
  ];

  system.stateVersion = "23.05";
}
