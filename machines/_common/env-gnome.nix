{ pkgs, ... }:

{
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
      gnome-shell
      tracker-miners
    ];
  };
  environment.gnome.excludePackages = with pkgs; [
    geary gnome-tour gnome-contacts
    gnome-music gnome-photos
    gnome-console # important!! bring your own terminal emulator
    totem
  ];

  #environment.systemPackages = with pkgs; [
  #  nautilus-python
  #  nautilus-open-any-terminal
  #];
  programs.nautilus-open-any-terminal.enable = true;

  # this enables the ozone stuff on wayland for chromium and electron and shit
  environment.variables.NIXOS_OZONE_WL = "1";
}
