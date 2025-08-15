{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.3-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    website.url = "github:chfour/website3/main";
  };

  outputs = { self, nixpkgs, nixpkgs-master, lix-module, nixos-hardware, home-manager, website, ... }: {
    nixosModules = {
      declarativeHome = { ... }: {
        imports = [ home-manager.nixosModules.home-manager ];
        config = {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        };
      };
      defaults = { ... }: {
        imports = [ lix-module.nixosModules.default ];
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
      "foxbox" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          pkgs-master = nixpkgs-master.legacyPackages.${system};
        };
        modules = with self.nixosModules; [
          defaults
          ./machines/foxbox
          nixos-hardware.nixosModules.lenovo-thinkpad-e14-intel
          declarativeHome ./users/chfour
        ];
      };
      "fovps" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          website = website.packages.${system};
        };
        modules = with self.nixosModules; [
          defaults
          ./machines/fovps
          declarativeHome ./users/chfour
        ];
      };
    };
  };
}
