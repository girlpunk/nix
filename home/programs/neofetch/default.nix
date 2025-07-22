{
  pkgs,
  lib,
  config,
  ...
}:

let
  filePath = "${config.dotfiles.path}/programs/neofetch/neofetch.conf";
  #configSrc =
  #  if !config.dotfiles.mutable then ./neofetch.conf
  #  else config.lib.file.mkOutOfStoreSymlink filePath;

  #neofetchPath = lib.makeBinPath (with pkgs; [ chafa imagemagick ]);

  #neofetchSixelsSupport = pkgs.neofetch.overrideAttrs (old: {
  # --add-flags "--source=./nixos.png" doesn't work ¯\_(ツ)_/¯
  #postInstall = lib.optionalString (!config.dotfiles.mutable) ''
  #  substituteInPlace $out/bin/neofetch \
  #    --replace "image_source=\"auto\"" "image_source=\"${./nixos.png}\""
  #'' + ''
  #  wrapProgram $out/bin/neofetch --prefix PATH : ${neofetchPath}
  #'';
  #});
in
{
  #home.packages = [ pkgs.neofetch ];
  #xdg.configFile."hyfetch.json".source = ./hyfetch.json;
  #xdg.configFile."neofetch/config.conf".source = configSrc;

  programs.hyfetch = {
    enable = true;
    settings = {
      preset = "rainbow";
      mode = "rgb";
      light_dark = "dark";
      lightness = 0.65;
      color_align = {
        mode = "horizontal";
#        custom_colors = [];
#        fore_back = null;
      };
      backend = "fastfetch";
#      args = null;
#      distro = null;
#      pride_month_shown = [];
      pride_month_disable = false;
    };
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      logo = {
        padding = {
            top = 2;
        };
      };
      display = {
        key = {
            width = 18;
            type = "both";
        };
        percent = {
            type = 3;
        };
      };
      modules = [
        "title"
        "separator"
        "os"
        {
            type = "chassis";
            format = "{2} {3} {1} ({4})";
        }
        "kernel"
        "uptime"
        #"editor"
        "brightness"
        {
            type = "cpu";
            showPeCoreCount = true;
            temp = true;
            format = "{1} ({5}) @ {7} {8}";
        }
        "cpuusage"
        {
            type = "gpu";
            driverSpecific = true;
            temp = true;
            format = "{1} {2} {5} @ {12} {7} / {8} {4}";
        }
        "memory"
        "swap"
        {
            type = "disk";
            format = "{13} {1} / {2} ({3}) - {9} {10}";
        }
        "zpool"
        {
            type = "battery";
            temp = true;
        }
        "poweradapter"
        "player"
        "media"
        {
            type = "publicip";
            timeout = 1000;
        }
        {
            type = "localip";
            showIpv6 = true;
            showMac = true;
        }
        "wifi"
        "locale"
        "bluetooth"
        "sound"
        "camera"
        "gamepad"
        {
          type = "weather";
          timeout = 1000;
        }
        "break"
        "colors"
      ];
    };
  };
}
