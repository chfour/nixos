{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];
  
  networking.hostName = "foxbox";

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "C.UTF-8";
    LC_IDENTIFICATION = "C.UTF-8";
    LC_MEASUREMENT = "C.UTF-8";
    LC_MONETARY = "C.UTF-8";
    LC_NAME = "C.UTF-8";
    LC_NUMERIC = "C.UTF-8";
    LC_PAPER = "C.UTF-8";
    LC_TELEPHONE = "C.UTF-8";
    LC_TIME = "C.UTF-8";
  };
  services.xserver = {
    layout = "pl";
    xkbVariant = "";
  };
  console.keyMap = "pl2";

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "fzf" "colored-man-pages" ];
      theme = "af-magic";
      customPkgs = with pkgs; [
        nix-zsh-completions
      ];
    };
  };
  environment.shells = with pkgs; [ zsh ];
  
  programs.steam.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  hardware.rtl-sdr.enable = true;

  programs.adb.enable = true;

  #services.flatpak.enable = true; # ugh
  
  environment.systemPackages = with pkgs; [
    micro wl-clipboard
    curlHTTP3
    wget fzf
    cnping # this has to be here because security.wrappers.*
    htop
    
    pinentry-curses # gnupg weirdness
    virt-manager
    wine
  ];

  #programs.cnping.enable = true; # so that does not, in fact, work
  security.wrappers.cnping = {
    source = "${pkgs.cnping}/bin/cnping";
    owner = "root"; group = "root";
    capabilities = "cap_net_raw+ep";
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      liberation_ttf
      terminus_font
      terminus_font_ttf
      fira
      unifont
      twitter-color-emoji # the non-svg variant cuz that didnt work
    ];
    fontconfig.defaultFonts = {
      # wow this is so much simpler than on arch holy shit
      emoji = [ "Twitter Color Emoji" ];
    };
  };

  environment.variables = {
    # teehee
    SUDO_PROMPT = "[sudo] programming socks required beyond this point: ";
  };

  
  services.xserver.enable = true;
  
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      # hell naw to automount and autorun
      # (like ???what this isnt windows)
      [org.gnome.desktop.media-handling]
      automount=false
      automount-open=false
      autorun-never=true

      # exclude node_modules from tracker
      # seriously DID MAKING IT A DOT-DIR
      # NEVER COME ACROSS THEIR MINDS CMON
      [org.freedesktop.Tracker.Miner.Files]
      ignored-directories-with-content='node_modules'
    '';
    extraGSettingsOverridePackages = with pkgs; [
      gnome.gnome-shell
      tracker-miners
    ];
  };
  environment.gnome.excludePackages = with pkgs; [
    gnome.geary gnome-tour gnome.gnome-contacts
    gnome.gnome-music gnome-photos
    gnome-console # important!! bring your own terminal emulator
  ];
  
  services.printing = {
    enable = true;
    drivers = with pkgs; [ hplip ];
  };
  services.avahi.enable = true;
  services.avahi.nssmdns = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
    wireplumber.enable = true;
  };
  
  networking.networkmanager.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    #qemu.runAsRoot = false;
    #qemu.swtpm.enable = true;
  };
  virtualisation.spiceUSBRedirection.enable = true; # right.

  # :nerd: :nerd:
  networking.firewall.enable = false;

  system.stateVersion = "23.05";
}
