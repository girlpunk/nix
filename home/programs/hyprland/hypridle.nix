{pkgs, ...}: let
  pulse = pkgs.writeShellScript "inhibitor-pulse.sh" ''
    pactl list | grep RUNNING && exit 1 || exit 0
  '';
  lock = pkgs.writeShellScript "lock.sh" ''
    # If pulse says something is playing, don't lock
    ${pulse} || exit 1

    # Start lock screen
    pidof hyprlock || hyprlock
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
          on-timeout = "" + ./idle/dim_screen.sh;
          on-resume = "" + ./idle/brighten_screen.sh;
        }
        {
          timeout = 120;
          on-timeout = "${./idle/dim_screen.sh} --always";
          on-resume = "" + ./idle/brighten_screen.sh;
        }
        {
          timeout = 180;
          on-timeout = "" + lock;
        }
        {
          timeout = 300;
          on-timeout = "" + ./idle/outputs_off.sh;
          on-resume = "" + ./idle/outputs_on.sh;
        }
        {
          timeout = 600;
          on-timeout = "${./idle/outputs_off.sh} --always";
          on-resume = "" + ./idle/outputs_on.sh;
        }
        {
          timeout = 420;
          on-timeout = "" + ./idle/suspend.sh;
        }
        {
          timeout = 840;
          on-timeout = "${./idle/suspend.sh} --always";
        }
      ];
    };
  };
}
