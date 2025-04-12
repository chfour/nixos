{ pkgs, lib, osConfig, config, ... }:

let
  isGui = osConfig.services.xserver.enable;
in {
  # not ugly anymore
  imports = builtins.concatLists [
    (lib.optional osConfig.services.xserver.desktopManager.gnome.enable ./env-gnome.nix)
  ];

  home.username = "chfour";
  home.homeDirectory = "/home/chfour";

  home.sessionVariables = {
    EDITOR = "micro";
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zsh = {
    enable = true;
    history.size = 50000;
    oh-my-zsh = {
      enable = true;
      custom = "${./omz-custom}";
      plugins = [ "git" "colored-man-pages" ];
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

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        pkief.material-icon-theme
        jnoortheen.nix-ide
        ms-python.python
        #ms-vscode.cpptools # :troll:
        llvm-vs-code-extensions.vscode-clangd
        vadimcn.vscode-lldb
        ms-vscode.cmake-tools twxs.cmake
        arrterian.nix-env-selector
        donjayamanne.githistory
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          publisher = "mesonbuild"; name = "mesonbuild";
          version = "1.22.0";
          sha256 = "xws1dgivQgGIPe3dV7MbfrcHXrmsyYI2Ji5wLViAR6k=";
        }
      ];

      keybindings = [
        { key = "f7"; "command" = "mesonbuild.build"; }
      ];

      userSettings = {
        "editor.fontFamily" = "\'Terminus (TTF)\', \'Droid Sans Mono\', \'monospace\', monospace";
        "editor.fontSize" = 16;
        "editor.minimap.enabled" = false;
        "workbench.colorTheme" = "Monokai";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.startupEditor" = "none";
        "files.eol" = "\n";
        "editor.cursorBlinking" = "phase";
        "clangd.path" = (lib.getOutput "bin" pkgs.clang-tools.overrideAttrs (old: { clang = pkgs.clang_multi; })) + "/bin/clangd"; # i guess?
        "cmake.configureOnOpen" = false;
        "mesonbuild.buildFolder" = "build";
        "mesonbuild.muonPath" = pkgs.muon;
        "mesonbuild.languageServer" = null;
        "mesonbuild.downloadLanguageServer" = false;
      };
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
      jq ffmpeg-full imagemagick
      sqlite-interactive
      fzf
      socat nmap

      hyfetch

      mat2
      yt-dlp
    ]
    (lib.optionals isGui [ # stuff i use on desktops
      firefox
      libreoffice
      keepassxc
      vesktop
      helvum
      inkscape gimp
      blender
      obs-studio
      prismlauncher
      celluloid
      sox
      beets
      zbar # for reading phone hotspot qr codes lol

      sdrpp
      rtl-sdr
      gpredict
      #chirp # lol lmao
      pulseview
      imhex

      # fonts
      noto-fonts
      twitter-color-emoji
      fira
      terminus_font terminus_font_ttf
      monaspace
    ])
    (lib.optionals config.services.mpd.enable [ mpdevil mpc-cli ])
  ]);

  fonts.fontconfig = {
    enable = isGui;
    defaultFonts.emoji = [ "Twitter Color Emoji" ];
  };

  programs.home-manager.enable = true;
  home.stateVersion = "23.05";
}
