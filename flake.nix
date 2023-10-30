{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, nixpkgs-master, nixos-hardware, home-manager, ... }: {
    nixosModules = {
      declarativeHome = { ... }: {
        # big thank you to https://determinate.systems/posts/declarative-gnome-configuration-with-nixos !!!
        imports = [ home-manager.nixosModules.home-manager ];
        config = {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        };
      };
      # theres probably a better way to do this lol
      overlays = ./overlays;
    };
    nixosConfigurations."foxbox" = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        pkgs-master = nixpkgs-master.legacyPackages.${system};
      };
      modules = with self.nixosModules; [
        overlays
        ./machines/foxbox
        nixos-hardware.nixosModules.lenovo-thinkpad-e14-intel
        declarativeHome
        ./users/chfour
      ];
    };
  };
}
