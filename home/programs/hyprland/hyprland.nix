{
  config,
  lib,
  ...
}: let
  monitors = lib.mkOption "monitors hyprland";
in {
  options = {
    hyprland = {
      monitors = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };
    };
  };

  config.wayland.windowManager.hyprland = {
    enable = true;

    systemd.enableXdgAutostart = true;

    settings = {
      ###################
      ### MY PROGRAMS ###
      ###################

      # See https://wiki.hyprland.org/Configuring/Keywords/

      # Set programs that you use
      "$terminal" = "kitty";
      "$fileManager" = "dolphin";
      "$menu" = "rofi -show-icons -markup -show drun -modes drun";
      # See https://wiki.hyprland.org/Configuring/Keywords/
      "$mainMod" = "SUPER"; # Sets "Windows" key as main modifier

      monitor = config.hyprland.monitors;

      #################
      ### AUTOSTART ###
      #################

      # Autostart necessary processes (like notifications daemons, status bars, etc.)
      # Or execute your favorite apps at launch like this:

      # Authentication Agent
      #exec-once = /usr/lib/polkit-kde-authentication-agent-1

      exec = [
        #        "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        #        "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        #        "dbus-update-activation-environment --systemd --all"

        ("" + ./random-wallpaper.sh)
        #        "xrdb -merge ~/.Xresources"
      ];

      exec-once = [
        # Lock immidiately on start, as we don't have a greeter
        ("" + ./idle/lock.sh)
      ];

      #############################
      ### ENVIRONMENT VARIABLES ###
      #############################

      # See https://wiki.hyprland.org/Configuring/Environment-variables/

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "XCURSOR_SIZE,24"
        #        "XDG_SESSION_TYPE,wayland"
        #        "XDG_MENU_PREFIX,arch-"
        "XKB_DEFAULT_OPTIONS,caps:super"
        "XKB_DEFAULT_LAYOUT,gb"
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "QT_QPA_PLATFORM,wayland-egl"
        "QT_STYLE_OVERRIDE,gtk2"
        "SDL_VIDEODRIVER,wayland"
        "MOZ_USE_XINPUT2,1"
      ];

      #####################
      ### LOOK AND FEEL ###
      #####################
      # Refer to https://wiki.hyprland.org/Configuring/Variables/

      # https://wiki.hyprland.org/Configuring/Variables/#general
      general = {
        gaps_in = 5;
        gaps_out = 0;

        border_size = 2;

        # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
        "col.active_border" = "rgba(ff30c7ee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(5959b4aa)";

        # Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false;

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;

        layout = "dwindle";
      };

      # https://wiki.hyprland.org/Configuring/Variables/#decoration
      decoration = {
        rounding = 5;

        # Change transparency of focused and unfocused windows
        active_opacity = 1.0;
        inactive_opacity = 1.0;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        # https://wiki.hyprland.org/Configuring/Variables/#blur
        blur = {
          enabled = true;
          size = 5;
          passes = 2;

          vibrancy = 0.1696;
        };
      };

      # https://wiki.hyprland.org/Configuring/Variables/#animations
      animations = {
        enabled = true;

        # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 4, myBezier"
          "windowsOut, 1, 4, default, popin 80%"
          "border, 1, 4, default"
          "borderangle, 1, 3, default"
          "fade, 1, 3, default"
          "workspaces, 1, 3, default"
        ];
      };

      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      dwindle = {
        pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true; # You probably want this
      };

      # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      master = {
        new_status = "master";
      };

      # https://wiki.hyprland.org/Configuring/Variables/#misc
      misc = {
        force_default_wallpaper = -1; # Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = false; # If true disables the random hyprland logo / anime girl background. :(
      };

      #############
      ### INPUT ###
      #############

      # https://wiki.hyprland.org/Configuring/Variables/#input
      input = {
        kb_layout = "gb";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = 1;

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

        touchpad = {
          natural_scroll = true;
        };
      };

      # https://wiki.hyprland.org/Configuring/Variables/#gestures
      gestures = {
        workspace_swipe = true;
      };

      # Example per-device config
      # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      ####################
      ### KEYBINDINGSS ###
      ####################

      bind =
        [
          ## Basics // Start a Terminal // <Super> Q ##
          "$mainMod, Q, exec, $terminal"
          ## Basics // Kill focused window // <Super> C ##
          "$mainMod, C, killactive,"

          ## Basics // Exit Hypr // <Super> M ##
          ("$mainMod, M, exec, " + ./confirm-before-exit.sh + " exit")
          ## Basics // Shut Down // <Super> <Shift> M ##
          ("$mainMod SHIFT, M, exec, " + ./confirm-before-exit.sh + " poweroff")
          ## Basics // Reboot // <Super> <Ctrl> M ##
          ("$mainMod CTRL, M, exec, " + ./confirm-before-exit.sh + " reboot")

          ## Basics // File Manager // <Super> E ##
          "$mainMod, E, exec, $fileManager"
          "$mainMod, V, togglefloating,"

          ## Basics // Start Launcher // <Super> R ##
          "$mainMod, R, exec, $menu"

          "$mainMod, P, pseudo," # dwindle
          "$mainMod, J, togglesplit," # dwindle

          # Move focus with mainMod + arrow keys
          ## Navigate // Change Focus // <Super> ↑ ↓ ← → ##
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          # Move windows between monitors
          ## Navigate // Move Window to Monitor // <Super> <Ctrl> ← → ##
          "$mainMod CTRL, right, movewindow, mon:1"
          "$mainMod CTRL, left, movewindow, mon:0"

          # Fullscreen and floating
          ## Navigate // Move Window to Floating // <Super> <Shift> F ##
          "$mainMod SHIFT, F, togglefloating,"
          ## Navigate // Move Window to Fullscreen // <Super> F ##
          "$mainMod , F, fullscreen"

          # Swap window tiles
          ## Navigate // Swap the Focused Window // <Super> <Shift> ↑ ↓ ← → ##
          "$mainMod SHIFT, left, swapwindow, l"
          "$mainMod SHIFT, down, swapwindow, d"
          "$mainMod SHIFT, up, swapwindow, u"
          "$mainMod SHIFT, right, swapwindow, r"

          # Move windows
          ## Navigate // Move the Focused Window // <Super> <Ctrl> <Shift> ↑ ↓ ← → ##
          "$mainMod CTRL SHIFT, left, movewindow, l"
          "$mainMod CTRL SHIFT, down, movewindow, d"
          "$mainMod CTRL SHIFT, up, movewindow, u"
          "$mainMod CTRL SHIFT, right, movewindow, r"

          # Example special workspace (scratchpad)
          ## Navigate // Show Scratchpad // <Super> S ##
          "$mainMod, S, togglespecialworkspace, magic"
          ## Navigate // Move Window to Scratchpad // <Super> <Shift> S ##
          "$mainMod SHIFT, S, movetoworkspace, special:magic"

          # Screenshot
          #bind = SHIFT, 107, exec, ~/.config/hypr/scripts/screenshot/captureAll.sh
          ## Navigate // Printscreen area to Clipboard // <PrtSc> ##
          ", 107, exec, hyprshot -m region"

          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"

          # Session management
          "$mainMod, L, exec, hyprlock"
          "CTRL, Escape, exec, gnome-system-monitor"

          "$mainMod, T, togglegroup"
        ]
        ++ (
          # Workspaces
          builtins.concatLists (
            builtins.genList (workspace: [
              # Switch workspaces with mainMod + [0-9]
              ## Workspaces // Switch to Workspace // <Super> [0-9] ##
              "$mainMod, ${toString workspace}, workspace, ${toString workspace}"

              # Move active window to a workspace with mainMod + SHIFT + [0-9]
              ## Navigate // Move Focused Window to Workspace // <Super> <Shift> [0-9] ##
              "$mainMod SHIFT, ${toString workspace}, movetoworkspace, ${toString workspace}"

              # Move active workspace to a monitor
              "$mainMod CONTROL, ${toString workspace}, exec, hyprctl dispatch moveworkspacetomonitor ${toString workspace} $(hyprctl activewindow | egrep \"monitor: [[:digit:]]+\" | egrep -o \"[[:digit:]]+\") && hyprctl dispatch workspace ${toString workspace}"
            ])
            9
          )
        );

      bindm = [
        # Move/resize windows with mainMod + LMB/RMB and dragging
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindl = [
        # Session management
        ",switch:Lid Switch, exec, hyprlock"

        ",XF86AudioMute,         exec, pactl set-sink-mute   @DEFAULT_SINK@ toggle && pacat /home/jacob/.local/share/Steam/steamui/sounds/deck_ui_volume.wav"
        ",XF86AudioMicMute,      exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"
      ];

      bindel = [
        ("     ,XF86AudioRaiseVolume, exec, " + ./volume.sh + " 5%+")
        ("     ,XF86AudioLowerVolume, exec, " + ./volume.sh + " 5%-")
        ("SHIFT,XF86AudioRaiseVolume, exec, " + ./volume.sh + " 1%+")
        ("SHIFT,XF86AudioLowerVolume, exec, " + ./volume.sh + " 1%-")

        "     ,XF86MonBrightnessUp,   exec, brightnessctl s 5%+ -m | grep -oP '\\d*(?=%)' > /run/user/1000/wob.sock"
        "     ,XF86MonBrightnessDown, exec, brightnessctl s 5%- -m | grep -oP '\\d*(?=%)' > /run/user/1000/wob.sock"
        "SHIFT,XF86MonBrightnessUp,   exec, brightnessctl s 1%+ -m | grep -oP '\\d*(?=%)' > /run/user/1000/wob.sock"
        "SHIFT,XF86MonBrightnessDown, exec, brightnessctl s 1%- -m | grep -oP '\\d*(?=%)' > /run/user/1000/wob.sock"
      ];

      ##############################
      ### WINDOWS AND WORKSPACES ###
      ##############################

      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
      # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

      windowrulev2 = [
        "suppressevent maximize, class:.*" # You'll probably like this.

        "workspace 1,class:kitty"

        "workspace 2, class:firefox"

        "workspace 3,title:^(.*)(VSCodium)$"
        "workspace 3,   class:^jetbrains-.*$"
        "noinitialfocus,class:^jetbrains-.*$,floating:1" # ,title:^win\d*$
        #"dimaround,     class:^jetbrains-.*$,floating:1"
        #"minsize 300 400,class:^jetbrains-.*$"

        "workspace 5,title:^(Cinny)(.*)$"
        "workspace 5,title:^(.*)(Discord)$"
        "workspace 5,title:^Discord Updater$"
        "workspace 5,title:^(Element)(.*)$"
      ];

      debug = {
        disable_logs = false;
      };
    };
  };
}

# bind = $mainMod, 0&1&2&3&4&5&6&7&8&9, exec, echo 1 > $XDG_RUNTIME_DIR/sov.sock
# bind = $mainMod, 1, exec, echo 1 > $XDG_RUNTIME_DIR/sov.sock
# bindr = $mainMod, 0&1&2&3&4&5&6&7&8&9, exec, echo 0 > $XDG_RUNTIME_DIR/sov.sock
# bindr = $mainMod, 1, exec, echo 0 > $XDG_RUNTIME_DIR/sov.sock
