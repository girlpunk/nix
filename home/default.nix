{
  pkgs,
  lib,
  ...
}: let
  username = "sam";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  packages = with pkgs; [
    dig # dns command-line tool
    docker-compose # docker manager
    duf # disk usage/free utility
    dust
    eza # a better `ls`
    killall # kill processes by name
    ncdu # disk space info (a better du)
    tree # display files in a tree view
    jq
    file
    tree
    #    kubectl
    wget
    #    ffmpeg-headless
    #    yt-dlp
    watch
    _1password-cli
    alejandra
    treefmt
    #    comma
  ];
in {
  imports = [
    ./modules/changes-report.nix
    ./modules/hidpi.nix
    ./modules/terminal
    ./programs/git
    ./programs/nano
    ./programs/neofetch
    ./programs/ssh
    ./programs/statix
  ];

  xdg = {
    inherit configHome;
    enable = true;
    autostart.enable = true;
    userDirs.enable = true;
    userDirs.createDirectories = true;
  };

  home = {
    inherit username homeDirectory packages;

    language.base = "en_GB";

    sessionVariables = {
      #DOTNET_ROOT = "${pkgs.dotnet-sdk_9}/share/dotnet";
      #LANG = "en_GB.UTF-8";
      LC_CTYPE = "en_GB.UTF-8";
      LC_ALL = "en_GB.UTF-8";
      PAGER = "less -FirSwX";
      # https://github.com/NixOS/nixpkgs/issues/24311#issuecomment-980477051
      GIT_ASKPASS = "";

      # https://github.com/rust-lang/rust-bindgen#environment-variables
      #LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];
      #LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (buildInputs ++ nativeBuildInputs);
      # Add precompiled library to rustc search path
      #RUSTFLAGS = (builtins.map (a: ''-L ${a}/lib'') [
      #  # add libraries here (e.g. pkgs.libvmi)
      #]);
      # Add glibc, clang, glib, and other headers to bindgen search path
      #BINDGEN_EXTRA_CLANG_ARGS =
      #  # Includes normal include path
      #  (builtins.map (a: ''-I"${a}/include"'') [
      #    # add dev libraries here (e.g. pkgs.libvmi.dev)
      #    pkgs.glibc.dev
      #  ])
      #  # Includes with special directory paths
      #  ++ [
      #    ''-I"${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"''
      #    ''-I"${pkgs.glib.dev}/include/glib-2.0"''
      #    ''-I${pkgs.glib.out}/lib/glib-2.0/include/''
      #  ];
      #      RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    };

    #    sessionPath = [
    #      "$HOME/.dotnet/tools"
    #    ];
  };

  programs = {
    home-manager = {
      enable = true;
      useGlobalPkgs = true;
    };

    nh = {
      enable = true;
      flake = "/home/sam/programs/nix";
    };

    jq.enable = true;

    nix-index.enable = true;
  };

  manual.html.enable = true;

  # notifications about home-manager news
  news.display = "show";

  home.stateVersion = "24.05";
}
