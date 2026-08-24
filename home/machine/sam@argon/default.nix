_: {
  imports = [
    ../../modules/remoteBuild.nix
    ../../programs/activitywatch
    ../../programs/discord
    ../../programs/hyprland
    ../../programs/kubernetes-client
    ../../programs/vscode
    #../../programs/android
  ];

  hyprland.monitors = [
    # See https://wiki.hyprland.org/Configuring/Monitors/
    {
      output = "eDP-1";
      mode = "preferred";
      position = "auto";
      scale = "1";
    }
    {
      output = "HDMI-A-2";
      mode = "preferred";
      position = "auto-left";
      scale = "1";
    }
  ];
}
