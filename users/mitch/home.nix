{ pkgs, lib, osConfig, config, ... }:

{
  # kinda ugly
  imports = (if osConfig.services.xserver.desktopManager.gnome.enable then [ ./env-gnome.nix ] else []);
  
  home.username = "mitch";
  home.homeDirectory = "/home/mitch";


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
    enable = true;
    package = pkgs.vscodium;
    
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      #ms-python.python # DEBUGPY WHY MUST YOU BE SO *STUPID*
    ];

    userSettings = {
      "editor.fontFamily" = "\'Terminus (TTF)\', \'Droid Sans Mono\', \'monospace\', monospace";
      "editor.fontSize" = 16;
      "workbench.colorTheme" = "Monokai";
      "editor.cursorBlinking" = "phase";
    };
  };

  xdg.userDirs.enable = true;
  
  services.mpd = {
    enable = true;
    network.startWhenNeeded = true;
    
    # holy shit :sob:
    extraConfig = ''
      ${lib.strings.optionalString osConfig.services.pipewire.enable ''audio_output {
        type "pipewire"
        name "PipeWire"
      }''}
    '';
  };

  home.packages = with pkgs; [
    tree file usbutils pciutils
    
    firefox
    keepassxc
    (discord-canary.override {
      withOpenASAR = true;
    })
    helvum
    inkscape gimp
    obs-studio
    prismlauncher
    #cnping
    beets yt-dlp
    mat2

    btop
    git jq
    hyfetch
    ffmpeg imagemagick
    mpv sox
    sqlite-interactive
    platformio
  
    sdrpp
    rtl-sdr
    gpredict
    #chirp # lol lmao
  ] ++ (if config.services.mpd.enable then [ pkgs.mpdevil ] else []);
  
  programs.home-manager.enable = true;
  home.stateVersion = "23.05";
}
