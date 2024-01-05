{ pkgs, lib, ... }:

{
  home.packages = with pkgs.gnomeExtensions; [
    appindicator
    runcat
    blur-my-shell
    caffeine
  ] ++ (with pkgs; [
    gnome.gnome-terminal
    #blackbox-terminal # this thing keeps crashing and has generally started to piss me off
  ]);
  
  dconf.settings = let
    appShortcuts = [
      rec { name = command; binding = "<Super>Return"; command = "gnome-terminal"; }
      rec { name = command; binding = "<Super>period"; command = "gnome-characters"; }
    ];
  in {
    # extension prefs
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "runcat@kolesnikov.se" # run lil fella!!! also features eepy
        "blur-my-shell@aunetx" # blur pretty,, pretty blur ................
        "caffeine@patapon.info"
      ];
    };

    "org/gnome/shell/extensions/appindicator" = {
      tray-pos = "right";
    };
    
    "org/gnome/shell/extensions/runcat" = {
      idle-threshold = 5; # give them some eepy time
      displaying-items = "character-and-percentage";
    };
    
    "org/gnome/shell/extensions/blur-my-shell" = {
      brightness = 1.0;
      sigma = 30; # strength
      color-and-noise = false; # performance equals very yes
      hacks-level = 0; # "highest performance" option
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
    };
    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      # overview background
      blur = true;
      style-components = 0; # do not style
      customize = true;
      brightness = 0.60;
      sigma = 30;
    };
    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
      blur = true;
    };
    "org/gnome/shell/extensions/blur-my-shell/screenshot" = {
      # screenshotter window selector
      blur = true;
    };
    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      blur = false;
    };
    
    # set the gtk4 theme/scheme (i also set the gtk3 theme later)
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    # enable minimize, maximize buttons
    "org/gnome/desktop/wm/preferences" = {
      button-layout=":appmenu,minimize,close";
    };

    # wm tweaks
    "org/gnome/mutter" = {
      edge-tiling = true;
      dynamic-workspaces = true;
    };
    "org/gnome/desktop/wm/preferences" = {
      resize-with-right-button = true;
    };
    "org/gnome/desktop/interface" = {
      enable-hot-corners = true;
    };

    # input
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      natural-scroll = false;
    };
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      speed = 0.22;
    };
    "org/gnome/desktop/input-sources" = {
      # set the compose key to scrollock
      # i have no idea what the terminate: thing does
      # pressing it doesn't seem to do anything
      xkb-options = ["terminate:ctrl_alt_bksp" "lv3:ralt_switch" "compose:sclk"];
    };
    
    # shortcuts
    "org/gnome/settings-daemon/plugins/media-keys" = {
      home = [ "<Super>e" ];
      custom-keybindings = lib.lists.imap0 (i: v: "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${builtins.toString i}/") appShortcuts;
    };
  } // builtins.listToAttrs (lib.lists.imap0 (i: v: ({ name = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${builtins.toString i}"; value = v; })) appShortcuts); # still kinda ugly lol

  gtk = {
    enable = true;

    # gtk3 theme
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    
    cursorTheme = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
    };
  };
}
