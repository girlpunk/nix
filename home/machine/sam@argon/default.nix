_: {
  imports = [
    ../../modules/remoteBuild.nix
    ../../programs/activitywatch
    ../../programs/discord
    ../../programs/hyprland
    ../../programs/kubernetes-client
    ../../programs/obsidian
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

  services = {
    pipewire = {
      enable = true;

      # Use wiremix to select this sink
      configs."20-rtp-sink"."context.modules" = [{
        name = "libpipewire-module-rtp-sink";
        args = {
          "sess.name" = "RTP port=46000";
          "sess.media" = "opus";
          "audio.rate" = "48000";
          "audio.channels" = 2;
          "destination.port" = "46000";
          "stream.props" = {
            "node.name" = "rtp-out";
            "media.class" = "Audio/Sink";
          };
        };
      }];
    };
  };
}
