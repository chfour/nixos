{ config, pkgs, ... }:

{
  home-manager.users.mitch = ./home.nix;
  
  users.users.mitch = {
    isNormalUser = true;
    description = "mitch";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "plugdev" "dialout" "adbusers" ];
  };
}
