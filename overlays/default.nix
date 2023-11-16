{ lib, pkgs, pkgs-master, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      sdrpp = super.sdrpp.overrideAttrs (old: {
        src = super.fetchFromGitHub {
          owner = "AlexandreRouma";
          repo = "SDRPlusPlus";
          rev = "794d6ff5acf66d5da7fb7fceba7b952c95305960";
          hash = "sha256-usP5WUXxIJkr/y4X8TXioJKamY17RRfMnwVHRUotKZk=";
        };
        buildInputs = old.buildInputs ++ (with pkgs; [ zstd ]);
      });
    })
    (self: super: {
      sdrpp = super.sdrpp.override { weather_sat_decoder = false; m17_decoder = true; };
    })
    (self: super: {
      cnping = super.cnping.overrideAttrs (old: {
        version = "unstable-2023-05-11";
        src = super.fetchFromGitHub {
          owner = "cntools";
          repo = "cnping";
          rev = "f62db84a5dbc049c0b19c7eba72bb3f8b76cb3f7";
          sha256 = "sha256-lp/d4NPhstf0fg0uDx7Q5jSKoz/ikY7BYnIU6+a/OGI=";
          fetchSubmodules = true;
        };
      });
    })

    #(self: super: {
    #  # this didn't work it complained about click when building
    #  # sent in an update request
    #  platformio = super.platformio.override {
    #    platformio-core = super.platformio-core.overrideAttrs (old: rec {
    #      version = "6.1.11";
    #      src = super.fetchFromGitHub {
    #        owner = "platformio";
    #        repo = "platformio-core";
    #        rev = "v${version}";
    #        sha256 = "sha256-NR4UyAt8q5sUGtz1Sy6E8Of7y9WrH9xpcAWzLBeDQmo=";
    #      };
    #      patches = [ ./pio-fix-searchpath.patch ./pio-use-local-spdx-license-list.patch ];
    #    });
    #  };
    #})
    
    #(self: super: {
    #  # so that's broken, let's revert it to the version in 23.05
    #  python3 = super.python3.override {
    #    packageOverrides = pyself: pysuper: {
    #      debugpy = pysuper.debugpy.overridePythonAttrs (old: rec {
    #        version = "1.6.7";
    #        src = super.fetchFromGitHub {
    #          owner = "microsoft";
    #          repo = "debugpy";
    #          rev = "refs/tags/v${version}";
    #          hash = "sha256-porQTFvcLaIkvhWPM4vWR0ohlcFRkRwSLpQJNg25Tj4=";
    #        };
    #      });
    #    };
    #  };
    #  #python310Packages = super.recurseIntoAttrs (python310.pkgs);
    #})
  ];
}
