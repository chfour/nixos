{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./services
    ./networking.nix
  ];

  networking.hostName = "fovps";
  
  boot.tmp.cleanOnBoot = true;

  nix.gc = {
    automatic = true;
    dates = "Mon 3:00";
    randomizedDelaySec = "2h";
    options = "--delete-older-than 14d";
  };

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

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    # dont need that anyways + remote nixos-rebuild with remote sudo cant ask for password lol
  };

  services.openssh.enable = true;
  
  environment.systemPackages = with pkgs; [
    micro
    wget
    htop
  ];

  system.stateVersion = "23.05";
}
