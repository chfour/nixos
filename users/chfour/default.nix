{ config, pkgs, ... }:

{
  home-manager.users.chfour = ./home.nix;
  
  users.users.chfour = {
    isNormalUser = true;
    description = "chfour";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "plugdev" "dialout" "adbusers" ];
  };
}
