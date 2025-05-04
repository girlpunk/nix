{ pkgs, lib, ... }:

let
  username = "sam";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  packages = with pkgs; [
    dig # dns command-line tool
    docker-compose # docker manager
    duf # disk usage/free utility
    du-dust
    eza # a better `ls`
    killall # kill processes by name
    ncdu # disk space info (a better du)
    tree # display files in a tree view
    jq
    file
    tree
    kubectl
    wget
    (with dotnetCorePackages; combinePackages [
      dotnet_9.sdk
    ])
    ffmpeg-headless
    yt-dlp
    watch
    nano
    _1password
    python3
    hatch

    unstable.jetbrains.pycharm-professional
    unstable.jetbrains.rider
  ];
in
{
  programs.home-manager.enable = true;

  imports = lib.concatMap import [
    ../modules
    #../scripts
    #../themes
    ./programs.nix
    ./services.nix
  ];

  xdg = {
    inherit configHome;
    enable = true;
  };

  home = {
    inherit username homeDirectory packages;

    #unstable.jetbrains.rider
    #unstable.jetbrains.pycharm-professional

    changes-report.enable = true;

    language.base = "en_GB";

    sessionVariables = {
      DOTNET_ROOT = "${pkgs.dotnet-sdk_9}/share/dotnet";
      #LANG = "en_GB.UTF-8";
      LC_CTYPE = "en_GB.UTF-8";
      LC_ALL = "en_GB.UTF-8";
      PAGER = "less -FirSwX";
      # https://github.com/NixOS/nixpkgs/issues/24311#issuecomment-980477051
      GIT_ASKPASS = "";
    };
  };

  # garbage collection
  #nix.gc = {
  #  automatic = true;
  #  frequency = "weekly";
  #  options = "--delete-older-than 7d";
  #};

  # restart services on change
  #systemd.user.startServices = "sd-switch";

  # notifications about home-manager news
  #news.display = "silent";

  home.stateVersion = "24.05";
}
