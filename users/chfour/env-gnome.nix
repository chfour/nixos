{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    ptyxis
    #gnome.gnome-terminal
    #blackbox-terminal # this thing keeps crashing and has generally started to piss me off
  ];

  programs.gnome-shell = {
    enable = true;
    extensions = builtins.map (p: { package = p; }) (with pkgs.gnomeExtensions; [
      appindicator
      runcat
      blur-my-shell
      caffeine
      fullscreen-notifications
    ]);
  };

  dconf.settings = let
    appShortcuts = [
      rec { name = command; binding = "<Super>Return"; command = "ptyxis --new-window"; }
      rec { name = command; binding = "<Super>period"; command = "gnome-characters"; }
    ];
  in {
    # apps
    "org/gnome/Ptyxis" = {
      use-system-font = false;
      font-name = "Terminus 10";
      restore-window-size = false;
      default-columns = 80; default-rows = 24;
      restore-session = false;

      default-profile-uuid = "00000000000000000000000000000000";
      profile-uuids = [ "00000000000000000000000000000000" ];
    };
    "org/gnome/Ptyxis/Profiles/00000000000000000000000000000000" = {
      palette = "gnome";
      preserve-directory = "always"; # needed for open-any-terminal
    };
    "com/github/stunkymonkey/nautilus-open-any-terminal" = {
      terminal = "ptyxis";
    };

    "org/gnome/TextEditor" = {
      restore-session = false;
      highlight-current-line = true;
      use-system-font = false;
      custom-font = "Terminus 11";
    };

    # don't try to suspend while plugged in
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
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

    "org/gnome/desktop/interface" = {
      # gtk4 theme/scheme (i also set the gtk3 theme later)
      color-scheme = "prefer-dark";

      accent-color = "slate";

      show-battery-percentage = true;
    };

    # enable minimize, maximize buttons
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":appmenu,minimize,close";
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
    "org/gnome/desktop/wm/keybindings" = {
      switch-windows = [ "<Alt>Tab" ];
      switch-windows-backward = [ "<Shift><Alt>Tab" ];
      switch-applications = [ "<Super>Tab" ];
      switch-applications-backward = [ "<Shift><Super>Tab" ];
    };

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
      package = pkgs.stdenv.mkDerivation rec {
        pname = "adw-gtk3";
        version = src.version;
        src = pkgs.adw-gtk3;
        installPhase = ''
          mkdir -p $out
          cp -r * $out/
          # ensure only the gtk3 theme is there (the gtk4 one seems to be breaking things)
          rm -rf $out/share/themes/*/gtk-4.0
        '';
      };
    };

    # buggy?
    #cursorTheme = {
    #  name = "Vanilla-DMZ";
    #  package = pkgs.vanilla-dmz;
    #};
  };
}
