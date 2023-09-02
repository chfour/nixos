{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, nixos-hardware, home-manager, ... }: {
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
    nixosConfigurations."foxbox" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
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
