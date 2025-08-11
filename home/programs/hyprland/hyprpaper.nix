_: let
  wave = builtins.fetchurl {
    url = "https://github.com/xyproto/archlinux-wallpaper/blob/masterkey/img/wave.png?raw=true";
    sha256 = "1zcbq60a6pjn7n335vkcjn4vw78l6psg6mf3v2vj4g48qlffg5hh";
  };
  awesome = builtins.fetchurl {
    url = "https://github.com/xyproto/archlinux-wallpaper/blob/masterkey/img/awesome.png?raw=true";
    sha256 = "0jqzqa1nszx9lf7xzsf2vplj8yp2wl2mh5qy2ycsh70qmfm5q3k7";
  };
in {
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = true;
      preload = [
        wave
        awesome
      ];
      wallpaper = [
        "eDP-1, ${wave}"
        "HDMI-A-1, ${awesome}"
      ];
    };
  };
}
