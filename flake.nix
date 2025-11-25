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
      homeManager = { ... }: {
        imports = [ home-manager.nixosModules.home-manager ];
        config = {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        };
      };
      lix = { ... }: {
        config = {
          nixpkgs.overlays = [ (final: prev: {
            # this is what the lix nixos module does
            nixVersions = prev.nixVersions // {
              stable = final.lixPackageSets.stable.lix;
              stable_upstream = prev.nixVersions.stable;
            };
          }) ];
        };
      };
      defaults = { ... }: {
        config = {
          nixpkgs.config.allowUnfree = true;
          nix.settings = {
            experimental-features = [ "nix-command" "flakes" ];
            auto-optimise-store = true;
          };
          environment.stub-ld.enable = false; # 24.05
        };
      };
    };
    nixosConfigurations = {
      foxbox = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          pkgs-master = nixpkgs-master.legacyPackages.${system};
        };
        modules = with self.nixosModules; [
          defaults lix homeManager
          ./machines/foxbox
          nixos-hardware.nixosModules.lenovo-thinkpad-e14-intel
          ./users/chfour
        ];
      };
      fovps = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = with self.nixosModules; [
          defaults lix homeManager
          ./machines/fovps
          ./users/chfour
        ];
      };
    };
  };
}
