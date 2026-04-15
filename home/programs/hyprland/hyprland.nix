{
  config,
  lib,
  pkgs,
  ...
}: let
  random-wallpaper = pkgs.writeShellScript "random-wallpaper.sh" ''
    monitors=$(${lib.getExe' pkgs.hyprland "hyprctl"} monitors | ${lib.getExe' pkgs.gnugrep "grep"} Monitor | ${lib.getExe' pkgs.gawk "awk"} '{print $2}') # get monitors

    for monitor in $monitors; do
      wallpaper=$(find /usr/share/wallpapers/*/contents -type f | shuf -n 1)
      ${lib.getExe' pkgs.hyprland "hyprctl"} hyprpaper preload "$wallpaper"
      ${lib.getExe' pkgs.hyprland "hyprctl"} hyprpaper wallpaper "$monitor,$wallpaper"
    done

    ${lib.getExe' pkgs.coreutils "sleep"} 0.25s # wait for wallpaper to load

    ${lib.getExe' pkgs.hyprland "hyprctl"} hyprpaper unload all # unload old wallpaper
  '';

  confirm-before-exit = pkgs.writeShellScript "confirm-before-exit.sh" ''
    set -euo pipefail
    EXIT_TYPE="$${1:?exit type missing}"

    calculate_width() {
      type_length="$${#1}"

      # make base width depend on the active monitor width
      # base width is a linear equation that maps 1920p to 11 base width and 4k to 3 base width, more or less
      active_monitor_width=$(${lib.getExe' pkgs.hyprland "hyprctl"} -j monitors | ${lib.getExe pkgs.jq} ".[] | select(.id == $(${lib.getExe' pkgs.hyprland "hyprctl"} -j activeworkspace | jq -r .monitorID)) | .width")
      base_width=$(${lib.getExe pkgs.bc} <<<"$active_monitor_width*-0.004+20" | ${lib.getExe' pkgs.gawk "awk"} '{print int($1+0.5)}')

      # this formula is empirical
      # takes the ceil of division by 2 of the length of the type string and adds to base_width
      # the result is the percentage of the maximum width the window has to occupy
      # exit = 13%; reboot = 14%; poweroff = 15%;
      # other modes will scale accordingly
      width=$((base_width + (type_length + 1) / 2))%
      echo $width
    }

    if [[ $EXIT_TYPE == "exit" ]]; then
      EXIT_ACTION="$SCRIPT_DIR"/force-exit.sh
    elif [[ $EXIT_TYPE == "poweroff" ]]; then
      EXIT_ACTION="sudo poweroff"
    elif [[ $EXIT_TYPE == "reboot" ]]; then
      EXIT_ACTION="sudo reboot"
    else
      echo "Action unsupported: $EXIT_TYPE"
      ${lib.getExe pkgs.notify-desktop} "Action unsupported: $EXIT_TYPE"
      exit 1
    fi

    calculated_width=99 #$(calculate_width $EXIT_TYPE)
    echo $calculated_width
    if [[ "$(${lib.getExe pkgs.rofi} -dmenu -p "Confirm $EXIT_TYPE? [y/N]" -theme-str "listview { enabled: false; } window { width: $calculated_width; }" | ${lib.getExe' pkgs.gawk "awk"} '{print tolower($0)}')" == "y" ]]; then
      bash -c "$EXIT_ACTION"
    fi
  '';

  volume = pkgs.writeShellScript "volume.sh" ''
    ${lib.getExe' pkgs.wireplumber "wpctl"} set-volume @DEFAULT_SINK@ $1

    printf %d\\n $(("$(${lib.getExe' pkgs.wireplumber "wpctl"} get-volume @DEFAULT_SINK@ | ${lib.getExe' pkgs.gnugrep "grep"} -Po '(?<=Volume: )\d+\.\d+')" * 100)) >/run/user/1000/wob.sock

    LOCKFILE=/run/user/1000/volume-notify

    ${lib.getExe' pkgs.util-linux "flock"} -n $LOCKFILE ${lib.getExe' pkgs.pipewire "pw-cat"} -p /home/sam/Music/awa.wav
  '';
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
      "$terminal" = lib.getExe pkgs.kitty;
      "$fileManager" = lib.getExe pkgs.yazi;
      "$menu" = "${lib.getExe pkgs.rofi} -show-icons -markup -show drun -modes drun";
      # See https://wiki.hyprland.org/Configuring/Keywords/
      "$mainMod" = "SUPER"; # Sets "Windows" key as main modifier

      monitor = config.hyprland.monitors;

      #################
      ### AUTOSTART ###
      #################

      # Autostart necessary processes (like notifications daemons, status bars, etc.)
      # Or execute your favourite apps at launch like this:

      # Authentication Agent
      #exec-once = /usr/lib/polkit-kde-authentication-agent-1

      exec = [
        #        "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        #        "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        #        "dbus-update-activation-environment --systemd --all"

        "${random-wallpaper}"
        #        "xrdb -merge ~/.Xresources"
      ];

      exec-once = [
        # Lock immediately on start, as we don't have a greeter
        #("" + ./idle/lock.sh)
        "${lib.getExe' pkgs._1password-gui "1password"} --silent"
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

        # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colours
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
      gesture = [
        "3, horizontal, workspace"
      ];
      # gestures = {
      #   workspace_swipe = true;
      # };

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
          "$mainMod, M, exec, ${confirm-before-exit} exit"
          ## Basics // Shut Down // <Super> <Shift> M ##
          "$mainMod SHIFT, M, exec, ${confirm-before-exit} poweroff"
          ## Basics // Reboot // <Super> <Ctrl> M ##
          "$mainMod CTRL, M, exec, ${confirm-before-exit} reboot"

          ## Basics // File Manager // <Super> E ##
          "$mainMod, E, exec, $fileManager"
          "$mainMod, V, togglefloating,"

          ## Basics // Start Launcher // <Super> R ##
          "$mainMod, R, exec, $menu"

          "$mainMod, P, pseudo," # dwindle
          #"$mainMod, J, togglesplit," # dwindle

          # Move focus with mainMod + arrow keys
          ## Navigate // Change Focus // <Super> ↑ ↓ ← → ##
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          # Move windows between monitors
          ## Navigate // Move Window to Monitor // <Super> <Ctrl> ← → ##
          "$mainMod CTRL, left, movecurrentworkspacetomonitor, l"
          "$mainMod CTRL, right, movecurrentworkspacetomonitor, r"
          "$mainMod CTRL, up, movecurrentworkspacetomonitor, u"
          "$mainMod CTRL, down, movecurrentworkspacetomonitor, d"

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
          #", 107, exec, hyprshot -m region"
          ", 107, exec, ${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\" -t png - | ${lib.getExe' pkgs.coreutils "tee"} \"$HOME/Pictures/Screenshots/Screenshots_$(date +%Y%m%d_%H%M%S).png\" | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}"

          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"

          # Session management
          "$mainMod, L, exec, ${lib.getExe pkgs.hyprlock}"
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
              "$mainMod CONTROL, ${toString workspace}, exec, ${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch moveworkspacetomonitor ${toString workspace} $(${lib.getExe' pkgs.hyprland "hyprctrl"} activewindow | ${lib.getExe' pkgs.gnugrep "egrep"} \"monitor: [[:digit:]]+\" | ${lib.getExe' pkgs.gnugrep "egrep"} -o \"[[:digit:]]+\") && ${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch workspace ${toString workspace}"
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
        ",switch:Lid Switch, exec, ${lib.getExe pkgs.hyprlock}"

        ",XF86AudioMute,         exec, ${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_SINK@ toggle && ${lib.getExe' pkgs.pipewire "pw-cat"} /home/jacob/.local/share/Steam/steamui/sounds/deck_ui_volume.wav"
        ",XF86AudioMicMute,      exec, ${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_SOURCE@ toggle"
      ];

      bindel = [
        "     ,XF86AudioRaiseVolume, exec, ${volume} 5%+"
        "     ,XF86AudioLowerVolume, exec, ${volume} 5%-"
        "SHIFT,XF86AudioRaiseVolume, exec, ${volume} 1%+"
        "SHIFT,XF86AudioLowerVolume, exec, ${volume} 1%-"

        "     ,XF86MonBrightnessUp,   exec, ${lib.getExe pkgs.brightnessctl} -e -m s 5%+ | ${lib.getExe' pkgs.gnugrep "grep"} -oP '\\d*(?=%)' > /run/user/1000/wob.sock"
        "     ,XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} -e -m s 5%- | ${lib.getExe' pkgs.gnugrep "grep"} -oP '\\d*(?=%)' > /run/user/1000/wob.sock"
        "SHIFT,XF86MonBrightnessUp,   exec, ${lib.getExe pkgs.brightnessctl} -e -m s 1%+ | ${lib.getExe' pkgs.gnugrep "grep"} -oP '\\d*(?=%)' > /run/user/1000/wob.sock"
        "SHIFT,XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} -e -m s 1%- | ${lib.getExe' pkgs.gnugrep "grep"} -oP '\\d*(?=%)' > /run/user/1000/wob.sock"
      ];

      ##############################
      ### WINDOWS AND WORKSPACES ###
      ##############################

      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
      # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

      windowrulev2 = [
        "suppressevent maximize, class:.*" # You'll probably like this.

        "workspace 1, class:kitty"

        "workspace 2, class:firefox"

        "workspace 3, title:^(.*)(VSCodium)$"
        "workspace 3, class:code"
        "workspace 3, class:^jetbrains-.*$"
        "noinitialfocus,workspace 3, class:^jetbrains-.*$,floating:1"

        "workspace 5, class:cinny$"
        "workspace 5, title:^(.*)(Discord)$"
        "workspace 5, title:^Discord Updater$"
        "workspace 5, title:^(Element)(.*)$"
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

