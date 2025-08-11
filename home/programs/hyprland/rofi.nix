{pkgs, ...}: {
  programs.rofi = {
    enable = true;
    font = "'Fira Code Nerd Font Mono' 12";
    #    cycle = true;

    #    plugins = [
    #      pkgs.rofi-calc
    #      pkgs.rofi-emoji
    #      pkgs.rofi-systemd
    #    ];

    pass.enable = true;
    terminal = "kitty";

    modes = [
      "drun"
      "window"
      "windowcd"
      "run"
      "ssh"
      "combi"
      "keys"
      "filebrowser"
      "recursivebrowser"
    ];
  };

  #  home.packages = with pkgs; [
  #    jq # Required for rofi-systemd
  #  ];
}
