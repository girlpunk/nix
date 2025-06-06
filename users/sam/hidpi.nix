{ config, lib, ... }:

with lib;

let
  inherit (config.wayland.windowManager) hyprland;
  inherit (config.xsession.windowManager) xmonad;
in
{
  meta.maintainers = [ hm.maintainers.gvolpe ];

  options = {
    hidpi = lib.mkEnableOption "HiDPI displays";

    # Make cursor not tiny on HiDPI screens
    home.pointerCursor = lib.mkIf (!isWSL) {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 128;
    };

    fonts.fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "FiraCode NerdFont" ];
    };

    programs = {
      browser.settings.dpi = mkOption {
        type = types.str;
        default =
          if hyprland.enable then (if config.hidpi then "0" else "1.7")
          else "0";
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

    services = {
      hypridle.dpms = mkOption {
        type = types.attrs;
        default = if config.hidpi then { } else
        {
          timeout = 1200;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        };
      };

      polybar.fontsizes = {
        font0 = mkOption {
          type = types.int;
          default = if config.hidpi then 16 else 10;
          description = "FiraCode Nerd font size (text font)";
        };
        font1 = mkOption {
          type = types.int;
          default = if config.hidpi then 18 else 12;
          description = "FiraCode font size (icon font)";
        };
        font2 = mkOption {
          type = types.int;
          default = if config.hidpi then 40 else 24;
          description = "FiraCode font size (Powerline Glyphs)";
        };
        font3 = mkOption {
          type = types.int;
          default = if config.hidpi then 28 else 18;
          description = "FiraCode font size (larger font size for bar fill icons)";
        };
        font4 = mkOption {
          type = types.int;
          default = if config.hidpi then 7 else 5;
          description = "FiraCode font size (smaller font size for shorter spaces)";
        };
        font5 = mkOption {
          type = types.int;
          default = if config.hidpi then 16 else 10;
          description = "FlagsWorldColor font size (keyboard layout icons)";
        };
      };
    };
  };
}
