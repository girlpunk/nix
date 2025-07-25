{ config, lib, ... }:

with lib;

let
  inherit (config.wayland.windowManager) hyprland;
in
{
    # Make cursor not tiny on HiDPI screens
    home.pointerCursor = lib.mkIf (!isWSL) {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 128;
    };

    programs = {
      browser.settings.dpi = mkOption {
        type = types.str;
        default = if hyprland.enable then (if config.hidpi then "0" else "1.7") else "0";
      };

      foot.fontsize = mkOption {
        type = types.str;
        default = if config.hidpi then "14" else "10";
      };

      signal.scaleFactor = mkOption {
        type = types.str;
        default = if config.hidpi then "2" else "1.5";
      };
    };
  };
}
