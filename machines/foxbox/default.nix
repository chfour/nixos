{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../_common/env-gnome.nix
  ];
  
  networking.hostName = "foxbox";

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
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };
  console.keyMap = "pl2";
  
  programs.steam.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.pcscd.enable = true;

  hardware.rtl-sdr.enable = true;

  services.udev.packages = [
    (pkgs.writeTextDir "/etc/udev/rules.d/usbasp.rules" ''
      # USBasp
      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", MODE="0666", GROUP="dialout"
    '')
    (pkgs.writeTextDir "/etc/udev/rules.d/fx2lafw.rules" ''
      # aliexpress logic analyzer
      ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="608c", MODE="0666", GROUP="dialout"
    '')
  ];

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
  
  services.printing = {
    enable = true;
    drivers = with pkgs; [ hplip ];
  };
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;

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
