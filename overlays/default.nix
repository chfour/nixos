{ lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      sdrpp = super.sdrpp.overrideAttrs (old: {
        src = super.fetchFromGitHub {
          owner = "AlexandreRouma";
          repo = "SDRPlusPlus";
          rev = "15ad065feb4052a711181ae7fc8e82e8d119e4df";
          hash = "sha256-ewjDMbHbsRIV9pn3cvNb0ccF36nVOzwES1oBphlDxkA=";
        };
        buildInputs = old.buildInputs ++ (with pkgs; [ zstd ]);
      });
    })
    (self: super: {
      sdrpp = super.sdrpp.override { weather_sat_decoder = false; };
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
