{pkgs, ...}: let
  pulse = pkgs.writeShellScript "inhibitor-pulse.sh" ''
    ${pkgs.wireplumber}/bin/wpctl status | grep active && exit 1 || exit 0
  '';

  lock = pkgs.writeShellScript "lock.sh" ''
    # If pulse says something is playing, don't lock
    ${pulse} || exit 1

    # Start lock screen
    pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock
  '';

  ac = pkgs.writeShellScript "inhibitor-ac.sh" ''
    grep 1 /sys/class/power_supply/AC/online && exit 1 || exit 0
  '';

  dim_screen = pkgs.writeShellScript "dim_screen.sh" ''
    # If pulseaudio says something is playing, don't dim
    ${pulse} || exit 1

    # Skip AC check for longer timeout periods
    if [[ $* != *--always* ]]; then
        # If on AC power, don't dim
        ${ac} || exit 1
    fi

    # Save current brightness state
    ${pkgs.brightnessctl}/bin/brightnessctl -qs

    # Set 5% as new brightness
    ${pkgs.brightnessctl}/bin/brightnessctl -q set 5%

    # Turn off keyboard backlight
    ${pkgs.brightnessctl}/bin/brightnessctl s -q -d 'tpacpi::kbd_backlight' 0
  '';

  outputs_off = pkgs.writeShellScript "outputs_off.sh" ''
    # Skip AC check for longer timeout periods
    if [[ $* != *--always* ]]; then
        # If on AC power, don't turn off monitor
        ${ac} || exit 1
    fi

    # If pulse says something is playing, don't turn off monitor
    ${pulse} || exit 1

    # Turn off monitor
    ${pkgs.hyprland}/bin/hyprctl dispatch dpms off
  '';

  suspend = pkgs.writeShellScript "suspend.sh" ''
    # Skip AC check for longer timeout periods
    if [[ $* != *--always* ]]; then
        # If on AC power, don't suspend
        ${ac} || exit 1
    fi

    # If pulse says something is playing, don't suspend
    ${pulse} || exit 1

    # Suspend
    ${pkgs.systemd}/bin/systemctl suspend-then-hibernate
  '';
in {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = lock + "";
        ignore_dbus_inhibit = false; # whether to ignore dbus-sent idle-inhibit requests (used by e.g. firefox or steam)
        ignore_systemd_inhibit = false; # whether to ignore systemd-inhibit --what=idle inhibitors
      };

      listener = [
        {
          timeout = 60;
          on-timeout = "" + dim_screen;
          on-resume = "" + ./idle/brighten_screen.sh;
        }
        {
          timeout = 120;
          on-timeout = "${dim_screen} --always";
          on-resume = "" + ./idle/brighten_screen.sh;
        }
        {
          timeout = 180;
          on-timeout = "" + lock;
        }
        {
          timeout = 300;
          on-timeout = "" + outputs_off;
          on-resume = "" + ./idle/outputs_on.sh;
        }
        {
          timeout = 600;
          on-timeout = "${outputs_off} --always";
          on-resume = "" + ./idle/outputs_on.sh;
        }
        {
          timeout = 420;
          on-timeout = "" + suspend;
        }
        {
          timeout = 840;
          on-timeout = "${suspend} --always";
        }
      ];
    };
  };
}
