{ pkgs, lib, ... }:

{
  imports = [
    ./hyprland.nix
    ./hypridle.nix
    ./hyprpaper.nix
    ./hyprlock.nix
    ./waybar.nix
    ./kitty.nix
    ./gconf.nix
    ./fonts.nix
    ./cursor.nix
    ./rofi.nix
    ./wluma.nix
  ];

  home.packages = [
    pkgs.rofi
  ];

  xdg = {
    enable = true;
    portal.enable = true;
  };

  services = {
    arrpc.enable = true;
    activitywatch.enable = true;
    blueman-applet.enable = true;
    clipman.enable = true;

    darkman.enable = true;
    darkman.settings = {
      lat = 51.48;
      lng = -0.22;
      usegeoclue = true;
    };

    gammastep = {
      enable = true;
      latitude = 51.48;
      longitude = -0.22;
      provider = "geoclue2";
      tray = true;
    };

    hyprpolkitagent.enable = true;
    network-manager-applet.enable = true;
    poweralertd.enable = true;
    ssh-agent.enable = false;

    wob = {
      enable = true;
      #config.systemd.user.sockets.wob.Socket.ListenFIFO = "${config.xdg.dataHome}/wob.sock";
    };
  };

  #config.systemd.user.sockets.wob.Socket.ListenFIFO = "${config.xdg.dataHome}/wob.sock";

  programs = {
    firefox.languagePacks = [ "en-GB" ];
    ssh.matchBlocks."*".identityAgent = "~/.1password/agent.sock";
    git.extraConfig.gpg.ssh.program = "${pkgs._1password-gui}/bin/op-ssh-sign";
  };
}
