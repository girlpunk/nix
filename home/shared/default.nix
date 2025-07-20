{ inputs, pkgs, lib, ... }:

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
    ffmpeg-headless
    yt-dlp
    watch
    nano
    _1password-cli
    nixfmt-rfc-style

    # Python
    python3
    hatch
    unstable.jetbrains.pycharm-professional
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
    autostart.enable = true;
    userDirs.enable = true;
    userDirs.createDirectories = true;
    portal.enable = true;
  };

  home = {
    inherit username homeDirectory packages;

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

  manual.html.enable = true;

  # restart services on change
  #systemd.user.startServices = "sd-switch";

  # notifications about home-manager news
  news.display = "show";

  home.stateVersion = "24.05";
}
