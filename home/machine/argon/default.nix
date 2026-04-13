_: {
  imports = [
    ../../modules/remoteBuild.nix
    ../../programs/discord
    ../../programs/vscode
    ../../programs/activitywatch
  ];

  hyprland.monitors = [
    # See https://wiki.hyprland.org/Configuring/Monitors/
    "eDP-1,preferred,auto,1"
    "HDMI-A-2,preferred,auto-left,1"
  ];
}
