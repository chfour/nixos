{ pkgs, lib, osConfig, config, ... }:

let
  isGui = osConfig.services.xserver.enable;
in {
  # not ugly anymore
  imports = builtins.concatLists [
    (lib.optional osConfig.services.xserver.desktopManager.gnome.enable ./env-gnome.nix)
  ];
  
  home.username = "mitch";
  home.homeDirectory = "/home/mitch";

  home.sessionVariables = {
    EDITOR = "micro";
  };

  programs.zsh = {
    enable = true;
    history.size = 50000;
    oh-my-zsh = {
      enable = true;
      custom = "${./omz-custom}";
      plugins = [ "git" "fzf" "colored-man-pages" ];
      theme = "af-magic";
    };
    syntaxHighlighting.enable = true;
  };
  
  programs.git = {
    enable = true;
    
    userName = "chfour";
    userEmail = "chfourchfour@protonmail.com";
    
    signing.signByDefault = true;
    signing.key = "BD2EC4C0608DED53";

    extraConfig = {
      commit.verbose = true;
      init.defaultBranch = "main";
    };
  };

  programs.vscode = {
    enable = isGui;
    package = pkgs.vscodium;
    
    extensions = with pkgs.vscode-extensions; [
      pkief.material-icon-theme
      jnoortheen.nix-ide
      ms-python.python # DEBUGPY WHY MUST YOU BE SO *STUPID* (sometimes)
      #ms-vscode.cpptools # :troll:
      llvm-vs-code-extensions.vscode-clangd
    #] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    #  {
    #    name = "platformio-ide";
    #    publisher = "platformio";
    #    version = "3.3.1";
    #    sha256 = "sha256-fIQCG3S5CnqoZFAlwbDG740Z/nIFMQRAYY5/LnRNMSo=";
    #  }
    ];

    userSettings = {
      "editor.fontFamily" = "\'Terminus (TTF)\', \'Droid Sans Mono\', \'monospace\', monospace";
      "editor.fontSize" = 16;
      "workbench.colorTheme" = "Monokai";
      "workbench.iconTheme" = "material-icon-theme";
      "files.eol" = "\n";
      "editor.cursorBlinking" = "phase";
      "clangd.path" = (lib.getOutput "bin" pkgs.clang-tools.overrideAttrs (old: { clang = pkgs.clang_multi; })) + "/bin/clangd"; # i guess?
      #"clangd.arguments" = [ "-I${lib.getOutput "bin" pkgs.pkgsi686Linux.gcc-unwrapped}/include/" ]; # no worky i thought it would
      #"platformio-ide.customPATH" = lib.makeBinPath (with pkgs; [ python311.withPackages (p: with p; [ platformio-core ]) platformio ]);
      #"platformio-ide.useBuiltinPIOCore" = false;
      #"platformio-ide.useBuiltinPython" = false;
      #"platformio-ide.pioHomeServerHttpPort" = 8008;
      #"C_Cpp.intelliSenseEngine" = "disabled";
      #"C_Cpp.default.compilerPath" = (lib.getOutput "bin" pkgs.clang_16) + "/bin/clang";
      # yea so all that didnt work
    };
  };

  xdg.userDirs.enable = isGui;
  
  services.mpd = {
    enable = isGui;
    network.startWhenNeeded = true;
    
    # holy shit :sob:
    extraConfig = ''
      ${lib.strings.optionalString osConfig.services.pipewire.enable ''audio_output {
        type "pipewire"
        name "PipeWire"
      }''}
    '';
  };

  home.packages = builtins.concatLists (with pkgs; [
    [ # universal
      btop
      micro
      tree file usbutils pciutils
      jq ffmpeg_6-full imagemagick
      sqlite-interactive

      fzf
      
      hyfetch
      
      mat2
      yt-dlp
    ]
    (lib.optionals isGui [ # stuff i use on desktops
      firefox
      keepassxc
      # (discord-canary.override { withOpenASAR = true; })
      vesktop
      helvum
      inkscape gimp
      obs-studio
      prismlauncher
      mpv sox
      platformio
    
      sdrpp
      rtl-sdr
      gpredict
      #chirp # lol lmao
    ])
    (lib.optional config.services.mpd.enable mpdevil)    
  ]);
  
  programs.home-manager.enable = true;
  home.stateVersion = "23.05";
}
