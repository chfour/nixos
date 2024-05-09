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
      minecraft = ./modules/minecraft.nix;
      
      declarativeHome = { ... }: {
        # big thank you to https://determinate.systems/posts/declarative-gnome-configuration-with-nixos !!!
        imports = [ home-manager.nixosModules.home-manager ];
        config = {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        };
      };
      defaults = { ... }: {
        nixpkgs.config.allowUnfree = true;
        nix.settings = {
          experimental-features = [ "nix-command" "flakes" ];
          auto-optimise-store = true;
        };
        environment.stub-ld.enable = false; # 24.05
      };
      # theres probably a better way to do this lol
      overlays = ./overlays;
    };
    nixosConfigurations = {
      "foxbox" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          pkgs-master = nixpkgs-master.legacyPackages.${system};
        };
        modules = with self.nixosModules; [
          overlays defaults
          ./machines/foxbox
          nixos-hardware.nixosModules.lenovo-thinkpad-e14-intel
          declarativeHome ./users/chfour
        ];
      };
      "fovps" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = with self.nixosModules; [
          overlays defaults
          ./machines/fovps
          declarativeHome ./users/chfour
          minecraft
        ];
      };
    };
  };
}
