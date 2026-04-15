_: {
  imports = [
    ../../modules/remoteBuild.nix
    ../../programs/activitywatch
    ../../programs/discord
    ../../programs/hyprland
    ../../programs/vscode
  ];

  hyprland.monitors = [
    # See https://wiki.hyprland.org/Configuring/Monitors/
    "eDP-1,preferred,auto,1"
    "HDMI-A-2,preferred,auto-left,1"
  ];
}
