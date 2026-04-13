{pkgs, ...}:
{
  services.activitywatch = {
    activitywatch = {
      enable = true;

      watchers = {
      };
    };
  };
}
