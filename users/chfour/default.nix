{ config, pkgs, lib, ... }:

{
  home-manager.users.chfour = ./home.nix;

  users.groups = {
    chfour = { gid = 1000; };
  };
  
  users.users."chfour" = {
    isNormalUser = true;
    description = "chfour";
    shell = pkgs.zsh;
    group = "chfour";
    extraGroups = [ "wheel" "plugdev" "dialout" ] ++ (lib.optional config.networking.networkmanager.enable "networkmanager");

    openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICOvi+wFazV5fN/piUQ0OM84W71TOuedHcAOsT/oRP55'' ];
  };

  programs.zsh.enable = true; # todo: get rid of this if possible
  environment.shells = with pkgs; [ zsh ];
}
