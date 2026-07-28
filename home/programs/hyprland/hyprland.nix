{
  config,
  lib,
  pkgs,
  ...
}: let
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

  mainMod = "SUPER";
in {
  options = {
    hyprland = {
      monitors = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
      };
    };
  };

  config.wayland.windowManager.hyprland = {
    enable = true;
    #configType = "hyprlang";
    configType = "lua";
    systemd.enableXdgAutostart = true;

    settings = {
      # See https://wiki.hyprland.org/Configuring/Keywords/
      monitor = config.hyprland.monitors;

      #################
      ### AUTOSTART ###
      #################

      # exec-once = [
      #   # Lock immediately on start, as we don't have a greeter
      #   #("" + ./idle/lock.sh)
      #   "${lib.getExe' pkgs._1password-gui "1password"} --silent"
      # ];

      #############################
      ### ENVIRONMENT VARIABLES ###
      #############################

      # See https://wiki.hyprland.org/Configuring/Environment-variables/

      # env = [
      #   "XCURSOR_SIZE,24"
      #   "HYPRCURSOR_SIZE,24"
      #   "XCURSOR_SIZE,24"
      #   #"XDG_SESSION_TYPE,wayland"
      #   #"XDG_MENU_PREFIX,arch-"
      #   "XKB_DEFAULT_OPTIONS,caps:super"
      #   "XKB_DEFAULT_LAYOUT,gb"
      #   "_JAVA_AWT_WM_NONREPARENTING,1"
      #   "QT_QPA_PLATFORM,wayland-egl"
      #   "QT_STYLE_OVERRIDE,gtk2"
      #   "SDL_VIDEODRIVER,wayland"
      #   "MOZ_USE_XINPUT2,1"
      # ];

      #####################
      ### LOOK AND FEEL ###
      #####################
      # # Refer to https://wiki.hyprland.org/Configuring/Variables/
      #
      # # https://wiki.hyprland.org/Configuring/Variables/#general
      # general = {
      #   gaps_in = 5;
      #   gaps_out = 0;
      #
      #   border_size = 2;
      #
      #   # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colours
      #   "col.active_border" = "rgba(ff30c7ee) rgba(00ff99ee) 45deg";
      #   "col.inactive_border" = "rgba(5959b4aa)";
      #
      #   # Set to true enable resizing windows by clicking and dragging on borders and gaps
      #   resize_on_border = false;
      #
      #   # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
      #   allow_tearing = false;

      #   layout = "dwindle";
      # };

      # # https://wiki.hyprland.org/Configuring/Variables/#decoration
      # decoration = {
      #   rounding = 5;

      #   # Change transparency of focused and unfocused windows
      #   active_opacity = 1.0;
      #   inactive_opacity = 1.0;

      #   shadow = {
      #     enabled = true;
      #     range = 4;
      #     render_power = 3;
      #     color = "rgba(1a1a1aee)";
      #   };

      #   # https://wiki.hyprland.org/Configuring/Variables/#blur
      #   blur = {
      #     enabled = true;
      #     size = 5;
      #     passes = 2;
      #
      #     vibrancy = 0.1696;
      #   };
      # };

      curve = {
        _args = [
          "myBezier"
          {
            type = "bezier";
            points = [[0.05 0.9] [0.1 1.05]];
          }
        ];
      };

      animation = [
        {
          leaf = "windows";
          enabled = true;
          speed = 4;
          bezier = "myBezier";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 4;
          bezier = "default";
          style = "popin 80%";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 4;
          bezier = "default";
        }
        {
          leaf = "borderangle";
          enabled = true;
          speed = 3;
          bezier = "default";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 3;
          bezier = "default";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 3;
          bezier = "default";
        }
      ];

      # # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      # dwindle = {
      #   preserve_split = true; # You probably want this
      # };

      # # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      # master = {
      #   new_status = "master";
      # };

      # # https://wiki.hyprland.org/Configuring/Variables/#misc
      # misc = {
      #   force_default_wallpaper = -1; # Set to 0 or 1 to disable the anime mascot wallpapers
      #   disable_hyprland_logo = false; # If true disables the random hyprland logo / anime girl background. :(
      # };

      #############
      ### INPUT ###
      #############

      # # https://wiki.hyprland.org/Configuring/Variables/#input
      # input = {
      #   kb_layout = "gb";
      #   kb_variant = "";
      #   kb_model = "";
      #   kb_options = "";
      #   kb_rules = "";
      #
      #   follow_mouse = 1;
      #
      #   sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
      #
      #   touchpad = {
      #     natural_scroll = true;
      #   };
      # };

      # # https://wiki.hyprland.org/Configuring/Variables/#gestures
      # gesture = [
      #   "3, horizontal, workspace"
      # ];
      # # gestures = {
      # #   workspace_swipe = true;
      # # };

      ####################
      ### KEYBINDINGSS ###
      ####################

      # bind =
      #   [
      #     ## Basics // Start a Terminal // <Super> Q ##
      #     "${mainMod}, Q, exec, ${lib.getExe pkgs.kitty}"

      #     ## Basics // Kill focused window // <Super> C ##
      #     "${mainMod}, C, killactive,"

      #     ## Basics // Exit Hypr // <Super> M ##
      #     "${mainMod}, M, exec, ${confirm-before-exit} exit"
      #     ## Basics // Shut Down // <Super> <Shift> M ##
      #     "${mainMod} SHIFT, M, exec, ${confirm-before-exit} poweroff"
      #     ## Basics // Reboot // <Super> <Ctrl> M ##
      #     "${mainMod} CTRL, M, exec, ${confirm-before-exit} reboot"

      #     ## Basics // File Manager // <Super> E ##
      #     "${mainMod}, E, exec, ${lib.getExe pkgs.yazi}"
      #     "${mainMod}, V, togglefloating,"

      #     ## Basics // Start Launcher // <Super> R ##
      #     "${mainMod}, R, exec, ${lib.getExe pkgs.rofi} -show-icons -markup -show drun -modes drun"

      #     "${mainMod}, P, pseudo," # dwindle
      #     #"${mainMod}, J, togglesplit," # dwindle

      #     # Move focus with mainMod + arrow keys
      #     ## Navigate // Change Focus // <Super> ↑ ↓ ← → ##
      #     "${mainMod}, left, movefocus, l"
      #     "${mainMod}, right, movefocus, r"
      #     "${mainMod}, up, movefocus, u"
      #     "${mainMod}, down, movefocus, d"

      #     # Move windows between monitors
      #     ## Navigate // Move Window to Monitor // <Super> <Ctrl> ← → ##
      #     "${mainMod} CTRL, left, movecurrentworkspacetomonitor, l"
      #     "${mainMod} CTRL, right, movecurrentworkspacetomonitor, r"
      #     "${mainMod} CTRL, up, movecurrentworkspacetomonitor, u"
      #     "${mainMod} CTRL, down, movecurrentworkspacetomonitor, d"

      #     # Fullscreen and floating
      #     ## Navigate // Move Window to Floating // <Super> <Shift> F ##
      #     "${mainMod} SHIFT, F, togglefloating,"
      #     ## Navigate // Move Window to Fullscreen // <Super> F ##
      #     "${mainMod} , F, fullscreen"

      #     # Swap window tiles
      #     ## Navigate // Swap the Focused Window // <Super> <Shift> ↑ ↓ ← → ##
      #     "${mainMod} SHIFT, left, swapwindow, l"
      #     "${mainMod} SHIFT, down, swapwindow, d"
      #     "${mainMod} SHIFT, up, swapwindow, u"
      #     "${mainMod} SHIFT, right, swapwindow, r"

      #     # Move windows
      #     ## Navigate // Move the Focused Window // <Super> <Ctrl> <Shift> ↑ ↓ ← → ##
      #     "${mainMod} CTRL SHIFT, left, movewindow, l"
      #     "${mainMod} CTRL SHIFT, down, movewindow, d"
      #     "${mainMod} CTRL SHIFT, up, movewindow, u"
      #     "${mainMod} CTRL SHIFT, right, movewindow, r"

      #     # Example special workspace (scratchpad)
      #     ## Navigate // Show Scratchpad // <Super> S ##
      #     "${mainMod}, S, togglespecialworkspace, magic"
      #     ## Navigate // Move Window to Scratchpad // <Super> <Shift> S ##
      #     "${mainMod} SHIFT, S, movetoworkspace, special:magic"

      #     # Screenshot
      #     #bind = SHIFT, 107, exec, ~/.config/hypr/scripts/screenshot/captureAll.sh
      #     ## Navigate // Printscreen area to Clipboard // <PrtSc> ##
      #     #", 107, exec, hyprshot -m region"
      #     ", 107, exec, ${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\" -t png - | ${lib.getExe' pkgs.coreutils "tee"} \"$HOME/Pictures/Screenshots/Screenshots_$(date +%Y%m%d_%H%M%S).png\" | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}"

      #     # Scroll through existing workspaces with mainMod + scroll
      #     "${mainMod}, mouse_down, workspace, e+1"
      #     "${mainMod}, mouse_up, workspace, e-1"

      #     # Session management
      #     "${mainMod}, L, exec, ${lib.getExe pkgs.hyprlock}"
      #     "CTRL, Escape, exec, gnome-system-monitor"

      #     "${mainMod}, T, togglegroup"
      #   ]
      #   ++ (
      #     # Workspaces
      #     builtins.concatLists (
      #       builtins.genList (workspace: [
      #         # Switch workspaces with mainMod + [0-9]
      #         ## Workspaces // Switch to Workspace // <Super> [0-9] ##
      #         "${mainMod}, ${toString workspace}, workspace, ${toString workspace}"
      #
      #         # Move active window to a workspace with mainMod + SHIFT + [0-9]
      #         ## Navigate // Move Focused Window to Workspace // <Super> <Shift> [0-9] ##
      #         "${mainMod} SHIFT, ${toString workspace}, movetoworkspace, ${toString workspace}"
      #
      #         # Move active workspace to a monitor
      #         "${mainMod} CONTROL, ${toString workspace}, exec, ${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch moveworkspacetomonitor ${toString workspace} $(${lib.getExe' pkgs.hyprland "hyprctrl"} activewindow | ${lib.getExe' pkgs.gnugrep "egrep"} \"monitor: [[:digit:]]+\" | ${lib.getExe' pkgs.gnugrep "egrep"} -o \"[[:digit:]]+\") && ${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch workspace ${toString workspace}"
      #       ])
      #       9
      #     )
      #   );

      # bindm = [
      #   # Move/resize windows with mainMod + LMB/RMB and dragging
      #   "${mainMod}, mouse:272, movewindow"
      #   "${mainMod}, mouse:273, resizewindow"
      # ];

      # bindl = [
      #   # Session management
      #   ",switch:Lid Switch, exec, ${lib.getExe pkgs.hyprlock}"
      #
      #   ",XF86AudioMute,         exec, ${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_SINK@ toggle && ${lib.getExe' pkgs.pipewire "pw-cat"} /home/jacob/.local/share/Steam/steamui/sounds/deck_ui_volume.wav"
      #   ",XF86AudioMicMute,      exec, ${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_SOURCE@ toggle"
      # ];

      # bindel = [
      #   "     ,XF86AudioRaiseVolume, exec, ${volume} 5%+"
      #   "     ,XF86AudioLowerVolume, exec, ${volume} 5%-"
      #   "SHIFT,XF86AudioRaiseVolume, exec, ${volume} 1%+"
      #   "SHIFT,XF86AudioLowerVolume, exec, ${volume} 1%-"
      #
      #   "     ,XF86MonBrightnessUp,   exec, ${lib.getExe pkgs.brightnessctl} -e -m s 5%+ | ${lib.getExe' pkgs.gnugrep "grep"} -oP '\\d*(?=%)' > /run/user/1000/wob.sock"
      #   "     ,XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} -e -m s 5%- | ${lib.getExe' pkgs.gnugrep "grep"} -oP '\\d*(?=%)' > /run/user/1000/wob.sock"
      #   "SHIFT,XF86MonBrightnessUp,   exec, ${lib.getExe pkgs.brightnessctl} -e -m s 1%+ | ${lib.getExe' pkgs.gnugrep "grep"} -oP '\\d*(?=%)' > /run/user/1000/wob.sock"
      #   "SHIFT,XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} -e -m s 1%- | ${lib.getExe' pkgs.gnugrep "grep"} -oP '\\d*(?=%)' > /run/user/1000/wob.sock"
      # ];

      ##############################
      ### WINDOWS AND WORKSPACES ###
      ##############################

      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
      # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

      #windowrule = [
      #  "match:class .*, suppress_event maximize" # You'll probably like this.

      #  "match:class kitty, workspace 1"

      #  "match:class firefox, workspace 2"

      #  "match:title ^(.*)(VSCodium)$, workspace 3"
      #  "match:class code, workspace 3"
      #  "match:class ^jetbrains-.*$, workspace 3"
      #  "match:class ^jetbrains-.*$,match:float true, workspace 3, no_initial_focus on"

      #  "match:class cinny$, workspace 5"
      #  "match:title ^(.*)(Discord)$, workspace 5"
      #  "match:title ^Discord Updater$, workspace 5"
      #  "match:title ^(Element)(.*)$, workspace 5"
      #];

      # windowrulev2 = [
      #   "suppressevent maximize, class:.*" # You'll probably like this.
      #
      #   "workspace 1, class:kitty"
      #
      #   "workspace 2, class:firefox"
      #
      #   "workspace 3, title:^(.*)(VSCodium)$"
      #   "workspace 3, class:code"
      #   "workspace 3, class:^jetbrains-.*$"
      #   "noinitialfocus,workspace 3, class:^jetbrains-.*$,floating:1"
      #
      #   "workspace 5, class:cinny$"
      #   "workspace 5, title:^(.*)(Discord)$"
      #   "workspace 5, title:^Discord Updater$"
      #   "workspace 5, title:^(Element)(.*)$"
      # ];

      # debug = {
      #   disable_logs = false;
      # };
    };

    extraConfig = ''
      local fileManager = "${lib.getExe pkgs.yazi}"
      local mainMod = "SUPER"
      local menu = "${lib.getExe pkgs.rofi} -show-icons -markup -show drun -modes drun"
      local terminal = "${lib.getExe pkgs.kitty}"

      hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
      hl.bind(mainMod .. " + C", hl.dsp.window.close())
      hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("${confirm-before-exit} exit"))
      hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("${confirm-before-exit} poweroff"))
      hl.bind(mainMod .. " + CTRL + M", hl.dsp.exec_cmd("${confirm-before-exit} reboot"))
      hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
      hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
      hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
      hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
      hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
      hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
      hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
      hl.bind(mainMod .. " + CTRL + left", function() local w = hl.get_active_workspace(); if not w then return end; hl.dispatch(hl.dsp.workspace.move({ workspace = w.id, monitor = "l" })) end)
      hl.bind(mainMod .. " + CTRL + right", function() local w = hl.get_active_workspace(); if not w then return end; hl.dispatch(hl.dsp.workspace.move({ workspace = w.id, monitor = "r" })) end)
      hl.bind(mainMod .. " + CTRL + up", function() local w = hl.get_active_workspace(); if not w then return end; hl.dispatch(hl.dsp.workspace.move({ workspace = w.id, monitor = "u" })) end)
      hl.bind(mainMod .. " + CTRL + down", function() local w = hl.get_active_workspace(); if not w then return end; hl.dispatch(hl.dsp.workspace.move({ workspace = w.id, monitor = "d" })) end)
      hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
      hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.swap({ direction = "l" }))
      hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "d" }))
      hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "u" }))
      hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "r" }))
      hl.bind(mainMod .. " + CTRL + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
      hl.bind(mainMod .. " + CTRL + SHIFT + down", hl.dsp.window.move({ direction = "d" }))
      hl.bind(mainMod .. " + CTRL + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
      hl.bind(mainMod .. " + CTRL + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
      hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
      hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
      hl.bind("code:107", hl.dsp.exec_cmd("${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\" -t png - | ${lib.getExe' pkgs.coreutils "tee"} \"$HOME/Pictures/Screenshots/Screenshots_$(date +%Y%m%d_%H%M%S).png\" | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}"))
      hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
      hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("${lib.getExe pkgs.hyprlock}"))
      hl.bind("CTRL + Escape", hl.dsp.exec_cmd("gnome-system-monitor"))
      hl.bind(mainMod .. " + T", hl.dsp.group.toggle())
      hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 0 }))
      hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 0 }))
      hl.bind(mainMod .. " + CONTROL + 0", hl.dsp.exec_cmd("${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch moveworkspacetomonitor 0 $(${lib.getExe' pkgs.hyprland "hyprctrl"} activewindow | ${lib.getExe' pkgs.gnugrep "egrep"} \"monitor: [[:digit:]]+\" | ${lib.getExe' pkgs.gnugrep "egrep"} -o \"[[:digit:]]+\") && ${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch workspace 0"))
      hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
      hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
      hl.bind(mainMod .. " + CONTROL + 1", hl.dsp.exec_cmd("${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch moveworkspacetomonitor 1 $(${lib.getExe' pkgs.hyprland "hyprctrl"} activewindow | ${lib.getExe' pkgs.gnugrep "egrep"} \"monitor: [[:digit:]]+\" | ${lib.getExe' pkgs.gnugrep "egrep"} -o \"[[:digit:]]+\") && ${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch workspace 1"))
      hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
      hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
      hl.bind(mainMod .. " + CONTROL + 2", hl.dsp.exec_cmd("${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch moveworkspacetomonitor 2 $(${lib.getExe' pkgs.hyprland "hyprctrl"} activewindow | ${lib.getExe' pkgs.gnugrep "egrep"} \"monitor: [[:digit:]]+\" | ${lib.getExe' pkgs.gnugrep "egrep"} -o \"[[:digit:]]+\") && ${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch workspace 2"))
      hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
      hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
      hl.bind(mainMod .. " + CONTROL + 3", hl.dsp.exec_cmd("${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch moveworkspacetomonitor 3 $(${lib.getExe' pkgs.hyprland "hyprctrl"} activewindow | ${lib.getExe' pkgs.gnugrep "egrep"} \"monitor: [[:digit:]]+\" | ${lib.getExe' pkgs.gnugrep "egrep"} -o \"[[:digit:]]+\") && ${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch workspace 3"))
      hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
      hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
      hl.bind(mainMod .. " + CONTROL + 4", hl.dsp.exec_cmd("${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch moveworkspacetomonitor 4 $(${lib.getExe' pkgs.hyprland "hyprctrl"} activewindow | ${lib.getExe' pkgs.gnugrep "egrep"} \"monitor: [[:digit:]]+\" | ${lib.getExe' pkgs.gnugrep "egrep"} -o \"[[:digit:]]+\") && ${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch workspace 4"))
      hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
      hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
      hl.bind(mainMod .. " + CONTROL + 5", hl.dsp.exec_cmd("${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch moveworkspacetomonitor 5 $(${lib.getExe' pkgs.hyprland "hyprctrl"} activewindow | ${lib.getExe' pkgs.gnugrep "egrep"} \"monitor: [[:digit:]]+\" | ${lib.getExe' pkgs.gnugrep "egrep"} -o \"[[:digit:]]+\") && ${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch workspace 5"))
      hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
      hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
      hl.bind(mainMod .. " + CONTROL + 6", hl.dsp.exec_cmd("${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch moveworkspacetomonitor 6 $(${lib.getExe' pkgs.hyprland "hyprctrl"} activewindow | ${lib.getExe' pkgs.gnugrep "egrep"} \"monitor: [[:digit:]]+\" | ${lib.getExe' pkgs.gnugrep "egrep"} -o \"[[:digit:]]+\") && ${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch workspace 6"))
      hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
      hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
      hl.bind(mainMod .. " + CONTROL + 7", hl.dsp.exec_cmd("${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch moveworkspacetomonitor 7 $(${lib.getExe' pkgs.hyprland "hyprctrl"} activewindow | ${lib.getExe' pkgs.gnugrep "egrep"} \"monitor: [[:digit:]]+\" | ${lib.getExe' pkgs.gnugrep "egrep"} -o \"[[:digit:]]+\") && ${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch workspace 7"))
      hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
      hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
      hl.bind(mainMod .. " + CONTROL + 8", hl.dsp.exec_cmd("${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch moveworkspacetomonitor 8 $(${lib.getExe' pkgs.hyprland "hyprctrl"} activewindow | ${lib.getExe' pkgs.gnugrep "egrep"} \"monitor: [[:digit:]]+\" | ${lib.getExe' pkgs.gnugrep "egrep"} -o \"[[:digit:]]+\") && ${lib.getExe' pkgs.hyprland "hyprctrl"} dispatch workspace 8"))

      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("${volume} 5%+"), { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("${volume} 5%-"), { locked = true, repeating = true })
      hl.bind("SHIFT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("${volume} 1%+"), { locked = true, repeating = true })
      hl.bind("SHIFT + XF86AudioLowerVolume", hl.dsp.exec_cmd("${volume} 1%-"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("${lib.getExe pkgs.brightnessctl} -e -m s 5%+ | ${lib.getExe' pkgs.gnugrep "grep"} -oP '\\d*(?=%)' > /run/user/1000/wob.sock"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("${lib.getExe pkgs.brightnessctl} -e -m s 5%- | ${lib.getExe' pkgs.gnugrep "grep"} -oP '\\d*(?=%)' > /run/user/1000/wob.sock"), { locked = true, repeating = true })
      hl.bind("SHIFT + XF86MonBrightnessUp", hl.dsp.exec_cmd("${lib.getExe pkgs.brightnessctl} -e -m s 1%+ | ${lib.getExe' pkgs.gnugrep "grep"} -oP '\\d*(?=%)' > /run/user/1000/wob.sock"), { locked = true, repeating = true })
      hl.bind("SHIFT + XF86MonBrightnessDown", hl.dsp.exec_cmd("${lib.getExe pkgs.brightnessctl} -e -m s 1%- | ${lib.getExe' pkgs.gnugrep "grep"} -oP '\\d*(?=%)' > /run/user/1000/wob.sock"), { locked = true, repeating = true })

      hl.bind("switch:Lid Switch", hl.dsp.exec_cmd("${lib.getExe pkgs.hyprlock}"), { locked = true })
      hl.bind("XF86AudioMute", hl.dsp.exec_cmd("${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_SINK@ toggle && ${lib.getExe' pkgs.pipewire "pw-cat"} $HOME/.local/share/Steam/steamui/sounds/deck_ui_volume.wav"), { locked = true })
      hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })

      hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
      hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

      hl.device({
          name = "epic-mouse-v1",
          sensitivity = -0.500000,
      })

      hl.env("XCURSOR_SIZE", "24")
      hl.env("HYPRCURSOR_SIZE", "24")
      hl.env("XCURSOR_SIZE", "24")
      hl.env("XKB_DEFAULT_OPTIONS", "caps:super")
      hl.env("XKB_DEFAULT_LAYOUT", "gb")
      hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
      hl.env("QT_QPA_PLATFORM", "wayland-egl")
      hl.env("QT_STYLE_OVERRIDE", "gtk2")
      hl.env("SDL_VIDEODRIVER", "wayland")
      hl.env("MOZ_USE_XINPUT2", "1")

      hl.gesture({
          fingers = 3,
          direction = "horizontal",
          action = "workspace",
      })

      hl.window_rule({
          match = {
              class = ".*",
          },
          suppress_event = "maximize",
      })

      hl.window_rule({
          match = {
              class = "kitty",
          },
          workspace = "1",
      })

      hl.window_rule({
          match = {
              class = "firefox",
          },
          workspace = "2",
      })

      hl.window_rule({
          match = {
              title = "^(.*)(VSCodium)$",
          },
          workspace = "3",
      })

      hl.window_rule({
          match = {
              class = "code",
          },
          workspace = "3",
      })

      hl.window_rule({
          match = {
              class = "^jetbrains-.*$",
          },
          workspace = "3",
      })

      hl.window_rule({
          match = {
              class = "^jetbrains-.*$",
              float = 1,
          },
          no_initial_focus = true,
          workspace = "3",
      })

      hl.window_rule({
          match = {
              class = "cinny$",
          },
          workspace = "5",
      })

      hl.window_rule({
          match = {
              title = "^(.*)(Discord)$",
          },
          workspace = "5",
      })

      hl.window_rule({
          match = {
              title = "^Discord Updater$",
          },
          workspace = "5",
      })

      hl.window_rule({
          match = {
              title = "^(Element)(.*)$",
          },
          workspace = "5",
      })

      hl.config({
          animations = {
              enabled = true,
          },
          debug = {
              disable_logs = false,
          },
          decoration = {
              blur = {
                  enabled = true,
                  passes = 2,
                  size = 5,
                  vibrancy = 0.169600,
              },
              shadow = {
                  color = "rgba(1a1a1aee)",
                  enabled = true,
                  range = 4,
                  render_power = 3,
              },
              active_opacity = 1.000000,
              inactive_opacity = 1.000000,
              rounding = 5,
          },
          dwindle = {
              preserve_split = true,
          },
          general = {
              allow_tearing = false,
              border_size = 2,
              col = {
                  active_border = { colors = { "rgba(ff30c7ee)", "rgba(00ff99ee)" }, angle = 45 },
                  inactive_border = "rgba(5959b4aa)",
              },
              gaps_in = 5,
              gaps_out = 0,
              layout = "dwindle",
              resize_on_border = false,
          },
          input = {
              touchpad = {
                  natural_scroll = true,
              },
              follow_mouse = 1,
              kb_layout = "gb",
              kb_model = "",
              kb_options = "",
              kb_rules = "",
              kb_variant = "",
              sensitivity = 0,
          },
          master = {
              new_status = "master",
          },
          misc = {
              disable_hyprland_logo = false,
              force_default_wallpaper = -1,
          },
      })

      hl.on("hyprland.start", function()
          hl.exec_cmd("${lib.getExe' pkgs._1password-gui "1password"} --silent")
      end)
    '';
  };
}
# bind = ${mainMod}, 0&1&2&3&4&5&6&7&8&9, exec, echo 1 > $XDG_RUNTIME_DIR/sov.sock
# bind = ${mainMod}, 1, exec, echo 1 > $XDG_RUNTIME_DIR/sov.sock
# bindr = ${mainMod}, 0&1&2&3&4&5&6&7&8&9, exec, echo 0 > $XDG_RUNTIME_DIR/sov.sock
# bindr = ${mainMod}, 1, exec, echo 0 > $XDG_RUNTIME_DIR/sov.sock

