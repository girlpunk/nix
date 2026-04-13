{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./ashell.nix
    ./cursor.nix
    ./fonts.nix
    ./gconf.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./kitty.nix
    ./rofi.nix
    ./tomat.nix
    #./waybar.nix
    ./wluma.nix
    ../firefox
  ];

  home.packages = with pkgs; [
    rofi
  ];

  xdg = {
    enable = true;
    portal.enable = true;

    mime.enable = true;
    mimeApps.enable = true;
    mimeApps.defaultApplications = {
      "x-scheme-handler/jetbrains-gateway" = "jetbrains-gateway.desktop";
    };
  };

  services = {
    activitywatch = mkIf services.activitywatch.enable {
      watchers = {
        awatcher = {
          package = pkgs.awatcher;
        };
      };
    };

    blueman-applet.enable = true;
    clipman.enable = true;

    gammastep = {
      enable = true;
      latitude = 51.48;
      longitude = -0.22;
      provider = "geoclue2";
      tray = false;
    };

    hyprpolkitagent.enable = true;
    network-manager-applet.enable = true;
    poweralertd.enable = true;

    mako = {
      enable = true;
      settings = {
        font = "Fira Code Nerd Font 10";
        border-size = 2;
        icon-location = "top";
        margin = "25,10,10";

        "app-name=.cinny-wrapped" = {
          default-timeout = 5000;
        };
        "app-name=discord" = {
          default-timeout = 5000;
        };
        "app-name=Element" = {
          default-timeout = 5000;
        };
      };
    };

    ssh-agent.enable = false;

    wob = {
      enable = true;
    };

    hyprsunset = {
      enable = true;
    };
  };

  programs = {
    ssh.matchBlocks."*".identityAgent = "~/.1password/agent.sock";
    git.settings.gpg.ssh.program = lib.getExe' pkgs._1password-gui "op-ssh-sign";
  };
}
