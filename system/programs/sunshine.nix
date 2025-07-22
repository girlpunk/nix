{ ... }:
{
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    openFirewall = true;
    settings = {
      locale = "en_GB";
      adapter_name = "/dev/dri/renderD128";
      origin_web_ui_allowed = "wan";
    };
  };
}
