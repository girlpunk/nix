{ ... }:
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "" + ./idle/lock.sh;
        ignore_dbus_inhibit = false;     # whether to ignore dbus-sent idle-inhibit requests (used by e.g. firefox or steam)
        ignore_systemd_inhibit = false;  # whether to ignore systemd-inhibit --what=idle inhibitors
      };

      listener = [
        {
          timeout    = 60;
          on-timeout = "" + ./idle/dim_screen.sh;
          on-resume  = "" + ./idle/brighten_screen.sh;
        }
        {
          timeout    = 180;
          on-timeout = "" + ./idle/lock.sh;
        }
        {
          timeout    = 300;
          on-timeout = "" + ./idle/outputs_off.sh;
          on-resume  = "" + ./idle/outputs_on.sh;
        }
        {
          timeout    = 420;
          on-timeout = "" + ./idle/suspend.sh;
        }
      ];
    };
  };
}
