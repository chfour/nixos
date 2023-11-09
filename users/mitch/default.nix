{ config, pkgs, lib, ... }:

{
  home-manager.users.mitch = ./home.nix;
  
  users.users."mitch" = {
    isNormalUser = true;
    description = "mitch";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "plugdev" "dialout" ] ++ (lib.optional config.networking.networkmanager.enable "networkmanager");

    openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICOvi+wFazV5fN/piUQ0OM84W71TOuedHcAOsT/oRP55 michaleklitwin@gmail.com'' ];
  };

  programs.zsh.enable = true; # todo: get rid of this if possible
  environment.shells = with pkgs; [ zsh ];
}
